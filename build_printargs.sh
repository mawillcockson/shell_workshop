#!/bin/sh
set -eu

TMPDIR="$(mktemp -d)"
export TMPDIR
source_file="${TMPDIR}/print_args.zig"
source_file_url='https://github.com/mawillcockson/shell_workshop/raw/main/print_args.zig'
ZIG_ARCHIVE="${TMPDIR}/zig.zip"

log() {
    if [ "$#" -ne 2 ]; then
        printf '\x2d\x2dERROR\x2d\x2d log only takes 2 arguments, the level, and the message\n'
        return 1
    fi

    printf '\x2d\x2d%s\x2d\x2d %s\n' "$1" "$2"
}

info() {
    log 'INFO' "$@"
}

error() {
    log 'ERROR' "$@"
    return 1
}

cleanup() {
    if ! rm -rf "${TMPDIR}"; then
        log 'ERROR' "can't delete \$TMPDIR"
    fi
    trap - EXIT INT TERM QUIT
}

trap 'cleanup' EXIT INT TERM QUIT

case "x$(uname --operating-system)x" in
    xAndroidx|xLinuxx)
        OS='linux';;
    xMsysx)
        OS='windows';;
    *)
        error 'unknown operating system: '"$(uname --operating-system)";;
esac

info "os is ${OS}"

case "x$(uname --machine)x" in
    xx86_64x)
        ARCH='x86_64';;
    xaarch64x)
        ARCH='aarch64';;
    *)
        error 'unknown architecture: '"$(uname --machine)";;
esac

if [ "x${OS}x" = 'xwindowsx' ]; then
    EXT='zip'
else
    EXT='tar.xz'
fi

info "cpu architecture is ${ARCH}"

info "downloading zig to -> ${ZIG_ARCHIVE}"
curl -L "https://ziglang.org/download/0.13.0/zig-${OS}-${ARCH}-0.13.0.${EXT}" --output "${ZIG_ARCHIVE}"

info 'unpacking zig archive'
if [ "x${OS}x" = 'xwindowsx' ]; then
    unzip "${ZIG_ARCHIVE}" -d "${TMPDIR}"
else
    tar -xJf "${ZIG_ARCHIVE}" -C "${TMPDIR}"
fi

info 'locating zig executable'
ZIG="$(find "${TMPDIR}" -type f -executable -name 'zig*')"

if ! "${ZIG}" version; then
    error 'could not find the zig executable!'
fi

info 'downloading source file'
curl -L "${source_file_url}" --output "${source_file}"

info 'building print_args.exe'
"${ZIG}" build-exe \
    -O ReleaseSmall \
    -fstrip \
    -fsingle-threaded \
    -femit-bin="${TMPDIR}/print_args.exe" \
    "${source_file}"

info 'moving binary to current directory, and making it executable'
mv "${TMPDIR}/print_args.exe" './print_args.exe'
chmod +x './print_args.exe'
