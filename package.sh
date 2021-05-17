#! /bin/bash
#
# package.sh - functions for dealing with Ubuntu packages

function PackageIsInstalled(){
    Assert "[ $# -eq 1 ]"

    local -r pkg="$1"

    # restore shell options (pipefail in this case) on function exit
    local -

    # grep -q can cause a pipefail
    set +o pipefail

    if dpkg --get-selections | grep -q "^$pkg[[:space:]]*install$"; then
        return 0
    else
        return 1
    fi
    }

function PackageInstall(){
    local pkg
    
    # for each argument
    for pkg do
        if ! apt-get -qq install $pkg ; then
            Die  "[exit code:$?] Failed to install package " $pkg
        fi
    done
    }
