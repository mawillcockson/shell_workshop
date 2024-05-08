local ffi = require("ffi")
--local bit = require("bit")

if ffi.abi("64bit") then
	ffi.cdef([[typedef uint64_t ULONG_PTR;]])
else
	ffi.cdef([[typedef unsigned long ULONG_PTR;]])
end

ffi.cdef([[
typedef void *PVOID;
typedef PVOID HANDLE;
typedef const char *LPCSTR;
typedef unsigned long DWORD;
typedef void *LPVOID;
typedef DWORD *LPDWORD;
typedef int BOOL;

// not needed, so defined to void *
typedef LPVOID LPSECURITY_ATTRIBUTES;

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

HANDLE CreateFileA(
/* [in]           */ LPCSTR                lpFileName,
/* [in]           */ DWORD                 dwDesiredAccess,
/* [in]           */ DWORD                 dwShareMode,
/* [in, optional] */ LPSECURITY_ATTRIBUTES lpSecurityAttributes,
/* [in]           */ DWORD                 dwCreationDisposition,
/* [in]           */ DWORD                 dwFlagsAndAttributes,
/* [in, optional] */ HANDLE                hTemplateFile
);

BOOL ReadFile(
/* [in]                */ HANDLE       hFile,
/* [out]               */ LPVOID       lpBuffer,
/* [in]                */ DWORD        nNumberOfBytesToRead,
/* [out, optional]     */ LPDWORD      lpNumberOfBytesRead,
/* [in, out, optional] */ LPOVERLAPPED lpOverlapped
);

BOOL CloseHandle(
/*  [in]  */ HANDLE hObject
);
]])

local NULL = ffi.cast("void *", 0)
local GENERIC_READ = 0x80000000
local FILE_SHARE_READ = 0x00000001

local CREATE_NEW = 1
local CREATE_ALWAYS = 2
local OPEN_EXISTING = 3
local OPEN_ALWAYS = 4

local FILE_ATTRIBUTE_NORMAL = 0x80
local INVALID_HANDLE_VALUE = ffi.cast("HANDLE", ffi.new("unsigned long long", 0) - 1)

local overlapped = ffi.new("OVERLAPPED")
overlapped.Internal = ffi.new("ULONG_PTR", 0)
overlapped.InternalHigh = ffi.new("ULONG_PTR", 0)
overlapped.DUMMYUNIONNAME.DUMMYSTRUCTNAME.Offset = ffi.new("DWORD", 0)
overlapped.DUMMYUNIONNAME.DUMMYSTRUCTNAME.OffsetHigh = ffi.new("DWORD", 0)
--overlapped.DUMMYUNIONNAME.Pointer = ffi.cast("PVOID", 0)
overlapped.hEvent = ffi.cast("HANDLE", 0)

local handle =
	ffi.C.CreateFileA("temp.txt", GENERIC_READ, FILE_SHARE_READ, NULL, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, NULL)

if handle == INVALID_HANDLE_VALUE then
	print("invalid handle")
	os.exit(1)
end

local buffer_size_bytes = 8192
local buffer = ffi.new("char [?]", buffer_size_bytes)
local num_bytes = ffi.new("DWORD [?]", 1)
local ret = ffi.C.ReadFile(handle, buffer, buffer_size_bytes, num_bytes, overlapped)
if ret == 0 then
	print("error reading file")
end

if ffi.C.CloseHandle(handle) == 0 then
	print("error closing file handle")
end

if ret == 0 then
  os.exit(1)
end
--print(ffi.string(buffer, num_bytes[0]))
local i = 0
while i < num_bytes[0] do
  io.write(string.char(buffer[i]))
  i = i + 1
end
--io.write("\n")
