#!/bin/sh
set -eu

log() {
    printf '# %s\n' "$1"
    while read -r INPUT; do
        printf '%s\n' "${INPUT}"
    done
    printf '\n'
}

named() {
    printf '$1 -> %s\n' $1
    printf '$2 -> %s\n' $2
    printf '$3 -> %s\n' $3
    printf '$4 -> %s\n' $4
    printf '$5 -> %s\n' $5
    printf '$6 -> %s\n' $6
    printf '$7 -> %s\n' $7
    printf '$8 -> %s\n' $8
    printf '$9 -> %s\n' $9
    printf '$10 -> %s\n' $10
}

named first second third fourth fifth sixth seventh eighth ninth tenth eleventh twelth thirteenth fourteenth fifteenth \
    | log 'positional parameters are accessible through the environment variables $1, $2, $3, etc'

named_fixed() {
    printf '$10 -> %s\n' "${10}"
}

named_fixed first second third fourth fifth sixth seventh eighth ninth tenth eleventh twelth thirteenth fourteenth fifteenth | log 'numbers higher than $9 need to use the ${} syntax, like ${10}'

shifts() {
    count=1
    while test -n "${1:+"set"}"; do
        printf '$%s -> %s\n' "${count}" "${1}"
        shift 1
        count="$((count+1))"
    done
}

shifts a b c d e | log 'another way to read through the variables is by using the shift builtin, and $# to count through them'
