if not set -q 'FISH_VERSION' || not string match -q '3.*' $FISH_VERSION
    echo 'shell is not fish v3'
else if test -e './if.fish'
    echo 'shell is fish v3 and ./if.fish exists'
else
    echo 'shell is fish v3'
end
