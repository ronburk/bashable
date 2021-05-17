#!/bin/bash
. bashable.sh
Assert "[ 55 -gt 45 ]"

if PackageIsInstalled emacs ; then
    echo "emacs is installed."
else
    echo "emacs is not installed."
fi

echo "Test complete"
