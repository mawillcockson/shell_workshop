--[[ cat implemented using win32 api calls
-- This is a (poor) implementation of `cat` using win32 API functions, as a way
-- of showing the complexity under the hood when using system/platform/OS APIs.
--
-- This would be better in C or Zig, but that would require a compiler (and the
-- Windows SDK, probably), whereas luajit is quite lightweight.
--]]

-- https://luajit.org/ext_ffi_api.html
local ffi = require("ffi")
--local bit = require("bit")

local function printe(msg)
  -- https://www.lua.org/manual/5.1/manual.html#5.7
	local old = io.output()
	io.output(io.stderr)
	io.write(tostring(msg) .. "\n")
	io.output(old)
end

-- https://luajit.org/ext_ffi_api.html#ffi_abi
-- https://learn.microsoft.com/en-us/windows/win32/winprog/windows-data-types#ulong_ptr
if ffi.abi("64bit") then
	ffi.cdef([[typedef uint64_t ULONG_PTR;]])
else
	ffi.cdef([[typedef unsigned long ULONG_PTR;]])
end

ffi.cdef([[
// mostly from https://learn.microsoft.com/en-us/windows/win32/winprog/windows-data-types
typedef void *PVOID;
typedef PVOID HANDLE;
typedef const char *LPCSTR;
typedef unsigned long DWORD;
typedef void *LPVOID;
typedef DWORD *LPDWORD;
typedef int BOOL;

// not needed, so defined to void *
typedef LPVOID LPSECURITY_ATTRIBUTES;

// https://learn.microsoft.com/en-us/windows/win32/api/minwinbase/ns-minwinbase-overlapped
typedef struct _OVERLAPPED {
  ULONG_PTR Internal;
  ULONG_PTR InternalHigh;
  union {
    struct {
      DWORD Offset;
      DWORD OffsetHigh;
    } DUMMYSTRUCTNAME;
    PVOID Pointer;
  } DUMMYUNIONNAME;
  HANDLE    hEvent;
} OVERLAPPED, *LPOVERLAPPED;

// https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-createfilea
HANDLE CreateFileA(
/* [in]           */ LPCSTR                lpFileName,
/* [in]           */ DWORD                 dwDesiredAccess,
/* [in]           */ DWORD                 dwShareMode,
/* [in, optional] */ LPSECURITY_ATTRIBUTES lpSecurityAttributes,
/* [in]           */ DWORD                 dwCreationDisposition,
/* [in]           */ DWORD                 dwFlagsAndAttributes,
/* [in, optional] */ HANDLE                hTemplateFile
);

// https://learn.microsoft.com/en-us/windows/win32/api/minwinbase/ns-minwinbase-filetime
typedef struct _FILETIME {
  DWORD dwLowDateTime;
  DWORD dwHighDateTime;
} FILETIME, *PFILETIME, *LPFILETIME;

// https://learn.microsoft.com/en-us/windows/win32/api/fileapi/ns-fileapi-by_handle_file_information
typedef struct _BY_HANDLE_FILE_INFORMATION {
  DWORD    dwFileAttributes;
  FILETIME ftCreationTime;
  FILETIME ftLastAccessTime;
  FILETIME ftLastWriteTime;
  DWORD    dwVolumeSerialNumber;
  DWORD    nFileSizeHigh;
  DWORD    nFileSizeLow;
  DWORD    nNumberOfLinks;
  DWORD    nFileIndexHigh;
  DWORD    nFileIndexLow;
} BY_HANDLE_FILE_INFORMATION, *PBY_HANDLE_FILE_INFORMATION, *LPBY_HANDLE_FILE_INFORMATION;

// https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-getfileinformationbyhandle
BOOL GetFileInformationByHandle(
/* [in]  */ HANDLE                       hFile,
/* [out] */ LPBY_HANDLE_FILE_INFORMATION lpFileInformation
);

// https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-readfile
BOOL ReadFile(
/* [in]                */ HANDLE       hFile,
/* [out]               */ LPVOID       lpBuffer,
/* [in]                */ DWORD        nNumberOfBytesToRead,
/* [out, optional]     */ LPDWORD      lpNumberOfBytesRead,
/* [in, out, optional] */ LPOVERLAPPED lpOverlapped
);

// https://learn.microsoft.com/en-us/windows/win32/api/handleapi/nf-handleapi-closehandle
BOOL CloseHandle(
/*  [in]  */ HANDLE hObject
);
]])

local function CloseHandle(hFile)
	if ffi.C.CloseHandle(hFile) == 0 then
		printe("error closing file handle")
	end
end

local OK = 0
local INVALID_HANDLE_ERROR = 1
local READ_ERROR = 2
local FILE_INFO_ERROR = 3

-- https://stackoverflow.com/a/24851487
local NULL = ffi.cast("void *", 0)

-- https://learn.microsoft.com/en-us/windows/win32/secauthz/generic-access-rights
-- https://learn.microsoft.com/en-us/windows/win32/secauthz/access-mask-format
local GENERIC_READ = 0x80000000
local FILE_SHARE_READ = 0x00000001

-- https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-createfilea
local CREATE_NEW = 1
local CREATE_ALWAYS = 2
local OPEN_EXISTING = 3
local OPEN_ALWAYS = 4

-- https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-createfilea
local FILE_ATTRIBUTE_NORMAL = 0x80

-- https://github.com/PowerShell/PowerShell/issues/3540
local INVALID_HANDLE_VALUE = ffi.cast("HANDLE", ffi.new("unsigned long long", 0) - 1)

-- ffi.new() initializes values with zero bytes, so there's no need to set
-- anything manually here
local overlapped = ffi.new("OVERLAPPED")
--overlapped.Internal = ffi.new("ULONG_PTR", 0)
--overlapped.InternalHigh = ffi.new("ULONG_PTR", 0)
--overlapped.DUMMYUNIONNAME.DUMMYSTRUCTNAME.Offset = ffi.new("DWORD", 0)
--overlapped.DUMMYUNIONNAME.DUMMYSTRUCTNAME.OffsetHigh = ffi.new("DWORD", 0)
--overlapped.DUMMYUNIONNAME.Pointer = ffi.cast("PVOID", 0)
--overlapped.hEvent = ffi.cast("HANDLE", 0)

-- The general flow of CreateFile (OpenFile) -> ReadFile -> CloseHandle is from:
-- https://learn.microsoft.com/en-us/windows/win32/fileio/opening-a-file-for-reading-or-writing
local handle =
	ffi.C.CreateFileA("temp.txt", GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL)

if handle == INVALID_HANDLE_VALUE then
	printe("invalid handle")
	os.exit(INVALID_HANDLE_ERROR)
end

local file_information = ffi.new("BY_HANDLE_FILE_INFORMATION")
if ffi.C.GetFileInformationByHandle(handle, file_information) == 0 then
	printe("error getting file information")
	CloseHandle(handle)
	os.exit(FILE_INFO_ERROR)
end

local break_full = false
local offset_low = 0
local offset_high = 0
local buffer_size_bytes = 8192
local buffer = ffi.new("char [?]", buffer_size_bytes)
local num_bytes = ffi.new("DWORD [?]", 1)
while (not break_full) and offset_high <= file_information.nFileSizeHigh do
	while (not break_full) and offset_low <= file_information.nFileSizeLow do
		overlapped.DUMMYUNIONNAME.DUMMYSTRUCTNAME.Offset = ffi.new("DWORD", offset_low)
		overlapped.DUMMYUNIONNAME.DUMMYSTRUCTNAME.OffsetHigh = ffi.new("DWORD", offset_high)
		if ffi.C.ReadFile(handle, buffer, buffer_size_bytes, num_bytes, overlapped) == 0 then
			printe("error reading file")
			CloseHandle(handle)
			os.exit(READ_ERROR)
		end
		--[[
    local i = 0
    while i < num_bytes[0] do
      io.write(string.char(buffer[i]))
      i = i + 1
    end
    --]]
		io.write(ffi.string(buffer, num_bytes[0]))

		if num_bytes[0] < buffer_size_bytes then
			break_full = true
			break
		end

		offset_low = offset_low + buffer_size_bytes
		if offset_low >= file_information.nFileSizeLow then
			offset_low = offset_low - file_information.nFileSizeLow
			offset_high = offset_high + 1
		end
	end
end

-- A final newline shouldn't be written, as that would add data to the file's
-- apparent content
--io.write("\n")
os.exit(OK)
