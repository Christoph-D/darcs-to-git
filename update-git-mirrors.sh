#!/bin/bash

PROJECTS=( "mueval-darcs" )
BASE_DIR="$HOME/darcs-git-mirrors"
GIT_MIRROR_DIR="$BASE_DIR/git-mirrors"

set -e -u
DARCS_TO_GIT="$(readlink -f "$(dirname "$0")")/darcs-to-git"

run() {
    LOG=$("$@" 2>&1)
    if [[ $? -eq 0 ]]; then
        printf "$*\nfailed on project %s in update-git-mirrors.sh.\n\n%s" \
            "$PROJECT" "$LOG" | \
            mail -s "$(basename "$1") failed" github@christoph-d.de
    fi
}

for PROJECT in $PROJECTS; do
    cd "$BASE_DIR/$PROJECT"
    run darcs pull
    cd "$GIT_MIRROR_DIR/$PROJECT"
    run "$DARCS_TO_GIT" "$BASE_DIR/$PROJECT"
    run git push origin master
done

exit 0
