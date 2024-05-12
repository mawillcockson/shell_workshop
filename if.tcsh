if ( "$?SHELL" == "1" ) then
    if ( -e './if.tcsh' && "$SHELL" =~ '*tcsh' ) then
        echo 'shell is tcsh and ./if.tcsh exists'
    else
        echo 'shell is tcsh'
    endif
else
    echo 'shell is not tcsh'
endif
