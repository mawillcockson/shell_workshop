if [ -z "${SHELL:+'set'}" ] || { printf '%s' "$SHELL" | grep -qviE '*/((((b|d)a)?)|z|k)sh' ; }
then
    echo 'shell is not sh/bash/ash/zsh/dash/ksh'
elif [ -e './if.sh' ]; then
    echo 'shell is sh and ./if.sh exists'
else
    echo 'shell is sh (or bash, ash, zsh, dash, or ksh)'
fi
