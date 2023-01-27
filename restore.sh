#!/bin/bash

# Debug
#set -x
set -Eeo pipefail

### Force override of environmental variable for csv file
#INPUT_FILE="/tmp/saved_aliases.csv" # Input csv file

### Default targets and flag strings for the script, can be overriden by env vars
# Bashrc location
RC_FILE="$HOME/.bashrc"
# Flag to indicate the start of custom bashrc additions
START_FLAG="#### Start Custom"
# Flag to indicate the end of custom bashrc additions
END_FLAG="#### End Custom"

# Check if environmetal variable override has been set, also warn if missing var
if [ -z "$INPUT_FILE" ]; then
  if [ -z "$ALIASTORE_CSV_FILE" ]; then
    echo "Error, please export the input file location with: 
  export ALIASTORE_CSV_FILE=/dir/input_file.csv"
    exit 1
  else
    INPUT_FILE="$ALIASTORE_CSV_FILE"
  fi
fi
# Check for env variables to override local defines if present
[ -n "$ALIASTORE_RC_FILE" ] && RC_FILE="$ALIASTORE_RC_FILE"
[ -n "$ALIASTORE_START_FLAG" ] && START_FLAG="$ALIASTORE_START_FLAG"
[ -n "$ALIASTORE_END_FLAG" ] && END_FLAG="$ALIASTORE_END_FLAG"
# Check for bashrc
[ -f "$RC_FILE" ] || (echo "Error, bashrc file not found: $RC_FILE"; exit 1)
# Guard against empty alias CSV file
if [[ $(wc -l < "$INPUT_FILE") -eq 0 ]]; then
  echo "Error, no custom aliases found in $INPUT_FILE"
  exit
fi
# Make a copy of the old alias file
cp "$RC_FILE" "$RC_FILE.old"
# Add flags if they don't already exist
if ! grep -qF "$START_FLAG" "$RC_FILE" || ! grep -qF "$END_FLAG" "$RC_FILE"; then
  sed -i "/${START_FLAG}/d" "$RC_FILE"
  sed -i "/${END_FLAG}/d" "$RC_FILE"
  echo "" >> "$RC_FILE"
  echo "$START_FLAG" >> "$RC_FILE"
  echo "$END_FLAG" >> "$RC_FILE"
fi
# Replace content between flags in the rc file
HEAD_LINE=$(grep -nFm 1 "$START_FLAG" "$RC_FILE" | cut -d ":" -f 1)
STOP_LINE=$(grep -nFm 1 "$END_FLAG" "$RC_FILE" | cut -d ":" -f 1)
TOTAL_LINES=$(wc -l < "$RC_FILE")
TAIL_LINE=$((TOTAL_LINES - STOP_LINE + 1))
TEMP_RC_FILE=$(mktemp /tmp/aliastore.XXXXXX || exit 1)
head -n "$HEAD_LINE" < "$RC_FILE" > "$TEMP_RC_FILE"
while read -r LINE; do
  ALIAS_NAME=$(echo "$LINE" | cut -d "," -f 1)
  ALIAS_MACRO=$(echo "$LINE" | cut -d "," -f 2-)
  echo "alias $ALIAS_NAME=$ALIAS_MACRO" >> "$TEMP_RC_FILE"
done < "$INPUT_FILE"
tail -n "$TAIL_LINE" < "$RC_FILE" >> "$TEMP_RC_FILE"
mv "$TEMP_RC_FILE" "$RC_FILE"
# Reload bashrc for current session
. ${RC_FILE}
# Notify user of completion and save location
echo "
Aliases from $INPUT_FILE have been copied to $RC_FILE, bashrc was reloaded, and a backup of the rc file was saved to $RC_FILE.old
"
