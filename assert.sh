#! /bin/bash
# assert.sh - basic assertion support

# DieMarker
function DieMarker() {
    echo "****************************************************************"
}
function Die(){
    if [ $# ] ; then
        DieMarker
        echo "$@"
    fi
    exit 1
}

function Assert(){
    # really annoying for tracing to be enabled here
    local -   # shell options will be restored on function exit
    set +o xtrace

    # if no condition was supplied, caller just wants to die
    if [ $# -le 0 ]; then
        Die "Assertion failed."
    fi
    # else, caller gave us a command to test
    # shellcheck disable=SC2068
    if $@ ; then
        :
    else
        DieMarker
        echo "Assertion failed: " "$@"
        local -i end=${#BASH_SOURCE[@]}
        local -i i
        for ((i=1; i < end; ++i));
        do
            local -i linenum=${BASH_LINENO[(($i-1))]}
            echo "${FUNCNAME[$i]}() in ${BASH_SOURCE[$i]}:$linenum"
            local Src="${BASH_SOURCE[$i]}"
            if test -r "$Src" -a -f "$Src" ; then
                # read line number of file
                mapfile -t -s $((linenum - 1)) -n 1 LineArray < "${Src}"
                echo "    ${LineArray[*]}"
            else
                echo "During Assert traceback source file [${Src}] not readable!"
            fi
        done
        Die
    fi
}



