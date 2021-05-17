#! /bin/bash
# trace.sh - manage tracing state

: <<'END_COMMENT'

Bash contains a trace facility that you turn on with :
    set -o xtrace
and turn off with:
    set -o xtrace

This is effectively a single global flag that indicates/controls
whether tracing is enabled. The global flag becomes inconvenient
when debugging complex scripts with nested function calls. For example,
one may desire to enable tracing in function Foo():
    function Foo() {
        set -o xtrace
        ...
        set +o xtrace
    }
This works fine if Foo() is the only function being traced. But
if some caller of Foo() used the same technique, then Foo() will
effectively terminate the tracing that the caller was trying to
enable.

We offer an alternative interface to the xtrace flag to manage
such problems. TraceOn()/TraceOff() offer a stack-like interface
for the bash tracing state. TraceOn() enables xtrace if it is off
and increments an internal variable. TraceOff() decrements that
internal variable and, if the result is zero, only then restores
the xtrace state that was in effect when the first nested TraceOn
was invoked.

END_COMMENT


# if we have not already been initialized
if [ ! -v TRACE_COUNT ] ; then
    TRACE_COUNT=0
fi

# TraceXtraceSave_ - return the current state of bash xtrace
function TraceXtraceSave_(){
    # will be "x" iff xtrace was on
    TraceXtraceSave=${-/*x*/x}
    return 0
}

# TraceXtraceRestore_ - restore a previous state of bash xtrace
#
# If an argument is supplied, a value of "x" will restore bash
# xtrace to the enabled state; any other value means disabled.
# If no argument is supplied, the value stored by the most recent
# call to TraceXtraceSave will be used.
function TraceXtraceRestore_(){
    Assert "[ $# -le 2 ]"

    local x
    
    # if caller gave us an argument
    if (( $# > 1 )); then
        x=$1
    else
        x=$TraceXtraceSave
    fi
    # now x is "x" iff we are supposed to turn xtrace on
    if [ "$x" == "x" ]; then
        set -o xtrace
    else
        set +o xtrace
    fi
}

function Trace() {
    echo "$@"
}

# TraceOn - turn on tracing
function TraceOn() {
    # if this is outermost call to TraceOn
    if (( TRACE_COUNT++ == 0 )); then
        TraceXtraceSave_
        # force xtrace on, no matter what
        set -o xtrace
    fi
}

function TraceOff() {
    # if not inside nested TraceOn request
    if (( --TRACE_COUNT == 0 )); then
        TraxeXtraceRestore
    fi
}


