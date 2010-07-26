#!/bin/bash

PROJECTS=( "mueval-darcs" )
BASE_DIR="$HOME/darcs-git-mirrors"
GIT_MIRROR_DIR="$BASE_DIR/git-mirrors"

set -e -u
DARCS_TO_GIT_BASE_DIR=$(readlink -f "$(dirname "$0")")
DARCS_TO_GIT="$DARCS_TO_GIT_BASE_DIR/darcs-to-git"
RUN_WITH_WATCHDOG="$DARCS_TO_GIT_BASE_DIR/run_with_watchdog.sh"

run() {
    local LOG
    if ! LOG=$("$RUN_WITH_WATCHDOG" 60 "$@" 2>&1); then
        printf "$*\nfailed on project %s in update-git-mirrors.sh.\n\n%s\n" \
            "$PROJECT" "$LOG" | \
            mail -s "$(basename "$1") failed" github@christoph-d.de
    fi
}

for PROJECT in $PROJECTS; do
    cd "$BASE_DIR/$PROJECT"
    run darcs pull
    # Remove spurious empty files that remain when a previous pull
    # failed.
    run find . -maxdepth 1 -empty -name 'darcs*-new' -delete
    cd "$GIT_MIRROR_DIR/$PROJECT"
    run "$DARCS_TO_GIT" "$BASE_DIR/$PROJECT"
    run git push origin master
done

exit 0
