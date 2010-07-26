#!/bin/bash

if [[ $# -lt 2 ]]; then
    echo "Usage: $(basename $0) timeout_in_seconds commandline..."
    echo "Runs the command and sends SIGTERM to the child after the specified timeout."
    exit 0
fi

# Enable job control.
set -mb

TIMEOUT="$1"
shift

# Use SIGUSR1 to interrupt the wait call.
trap ':' USR1

# Run the desired command.
"$@" &

# Suppress any output from now on.
exec &>/dev/null
# Run the watchdog.
{ sleep $TIMEOUT ; kill -USR1 $$; } &

# Give the command a chance to complete.
wait %1
EXIT_STATUS=$?

# Send SIGTERM to the watchdog and the command. If a job is not
# running, the kill has no effect.
kill %2
kill %1

exit $EXIT_STATUS
