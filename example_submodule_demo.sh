#!/bin/bash

# Debug
#set -x
set -Eeuo pipefail

# Save script dir
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)

################################################################################
# File to save/restore repositories to/from:
CSV_FILE="$SCRIPT_DIR/saved_repos.csv"
################################################################################

# Submodule update
git submodule init
git submodule update
git submodule update --remote

# Check for repostore submodule
ALIASTORE_SUBMODULE="$SCRIPT_DIR/repostore"
ALIASTORE_BACKUP="$ALIASTORE_SUBMODULE/backup.sh"
ALIASTORE_RESTORE="$ALIASTORE_SUBMODULE/restore.sh"
[ -d "$ALIASTORE_SUBMODULE" ] || (echo "Error, aliastore submodule not found: $ALIASTORE_SUBMODULE"; exit 1)
[ -f "$ALIASTORE_BACKUP" ] && [ -f "$ALIASTORE_RESTORE" ] || (echo "Error, repostore script(s) not found in: $ALIASTORE_SUBMODULE"; exit 1)

# Export submodule variables
export ALIASTORE_CSV_FILE="$CSV_FILE"

# Backup the repos using the backup script
${ALIASTORE_BACKUP}

# Unset submodule variables
unset ALIASTORE_CSV_FILE

# Add changes to git
#git add "$CSV_FILE"
#git commit -m "Stored current repos"
#git push