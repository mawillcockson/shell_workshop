#!/bin/sh
set -eu

write_lines() {
    echo stderr >&2
    echo stdout
}
export write_lines

STDOUT="$(write_lines)"
STDERR="$(write_lines 2>&1 1>/dev/null)" # the use of 1 is not necessary, but being explicit
NOTHING="$(write_lines 1>/dev/null 2>&1)"

printf 'STDOUT: %s\n' "${STDOUT}"
printf 'STDERR: %s\n' "${STDERR}"
printf 'NOTHING: %s\n' "${NOTHING}"
