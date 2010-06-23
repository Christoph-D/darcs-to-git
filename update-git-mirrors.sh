#!/bin/bash

PROJECTS=( "mueval-darcs" )
BASE_DIR="$HOME/darcs-git-mirrors"

set -e -u
DARCS_TO_GIT="$(readlink -f "$(dirname "$0")")/darcs-to-git"

GIT_MIRROR_DIR="$BASE_DIR/git-mirrors"
for PROJECT in $PROJECTS; do
    cd "$GIT_MIRROR_DIR/$PROJECT"
    LOG=$($DARCS_TO_GIT "$BASE_DIR/$PROJECT" 2>&1)
    if [[ $? -ne 0 ]]; then
        printf "darcs-to-git failed on project %s in update-git-mirrors.sh.\n\n%s" \
            "$PROJECT" "$LOG" | \
            mail -s 'darcs-to-git failed' github@christoph-d.de
    fi
    LOG=$(git push origin master 2>&1)
    if [[ $? -ne 0 ]]; then
        printf "git push failed on project %s in update-git-mirrors.sh.\n\n%s" \
            "$PROJECT" "$LOG" | \
            mail -s 'git push failed' github@christoph-d.de
    fi
done

exit 0
