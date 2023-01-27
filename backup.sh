#!/bin/bash

# Debug
#set -x
set -Eeo pipefail

### Force override of environmental variable for csv file
#OUTPUT_FILE="/tmp/saved_aliases.csv" # Output csv file

### Default targets and flag strings for the script, can be overriden by env vars
# Bashrc location
RC_FILE="$HOME/.bashrc"
# Flag to indicate the start of custom bashrc additions
START_FLAG="#### Start Custom"
# Flag to indicate the end of custom bashrc additions
END_FLAG="#### End Custom"

# Check if environmetal variable override has been set, also warn if missing var
if [ -z "$OUTPUT_FILE" ]; then
  if [ -z "$ALIASTORE_CSV_FILE" ]; then
    echo "Error, please export the output file location with: 
  export ALIASTORE_CSV_FILE=/dir/output_file.csv"
    exit 1
  else
    OUTPUT_FILE="$ALIASTORE_CSV_FILE"
  fi
fi
# Check for env variables to override local defines if present
[ -n "$ALIASTORE_RC_FILE" ] && RC_FILE="$ALIASTORE_RC_FILE"
[ -n "$ALIASTORE_START_FLAG" ] && START_FLAG="$ALIASTORE_START_FLAG"
[ -n "$ALIASTORE_END_FLAG" ] && END_FLAG="$ALIASTORE_END_FLAG"
# Check for bashrc
[ -f "$RC_FILE" ] || (echo "Error, bashrc file not found: $RC_FILE"; exit 1)
# Check for begin and end flags in rc file
if ! grep -qF "$START_FLAG" "$RC_FILE" || ! grep -qF "$END_FLAG" "$RC_FILE"; then
  echo "Error, make sure you have the start and end custom alias flags in your rc file: $RC_FILE
  #### Start Custom
  #### End Custom"
fi
# Get the custom aliases from the rc file
START_LINE=$(grep -nFm 1 "$START_FLAG" "$RC_FILE" | cut -d ":" -f 1)
STOP_LINE=$(grep -nFm 1 "$END_FLAG" "$RC_FILE" | cut -d ":" -f 1)
HEAD_LINE=$((STOP_LINE - 1))
TAIL_LINE=$((STOP_LINE - START_LINE - 1))
TEMP_OUTPUT_FILE=$(mktemp /tmp/aliastore.XXXXXX || exit 1)
head -n "$HEAD_LINE" < "$RC_FILE" | tail -n "$TAIL_LINE" > "$TEMP_OUTPUT_FILE"
if [[ $(wc -l < "$TEMP_OUTPUT_FILE") -eq 0 ]]; then
  echo "No custom aliases found, please add some and run again."
  exit
else
  # Create output file
  touch "$OUTPUT_FILE"
fi
# Iterate through aliases and check for collisions in storage file
while read -r LINE; do
  ALIAS_NAME=$(echo "$LINE" | cut -d " " -f 2 | cut -d "=" -f 1)
  ALIAS_MACRO=$(echo "$LINE" | cut -d "=" -f 2-)
  TEMP_FILE=$(mktemp /tmp/aliastore.XXXXXX || exit 1)
  grep -F "$ALIAS_NAME," < "$OUTPUT_FILE" >> "$TEMP_FILE" || true
  if [[ $(wc -l < "$TEMP_FILE") -ge 1 ]]; then
    while read -r TEMP_LINE; do
      if [[ "$ALIAS_NAME" == $(echo "$TEMP_LINE" | cut -d "," -f 1) ]]; then
        TEMP_MACRO=$(echo "$TEMP_LINE" | cut -d "," -f 2)
        if [[ "$ALIAS_MACRO" != "$TEMP_MACRO" ]]; then
          echo "Warning, found alias collision for '$ALIAS_NAME', skipping copying alias from $OUTPUT_FILE. Please delete the undesired copy and re-run this script."
          break
        fi
      fi
    done < "$TEMP_FILE"
  else
    echo "$ALIAS_NAME,$ALIAS_MACRO" >> "$OUTPUT_FILE"
  fi
  rm -f "$TEMP_FILE"
done < "$TEMP_OUTPUT_FILE"
# Delete temp file
rm -f "$TEMP_OUTPUT_FILE"
# Notify user of completion and save location
echo "
Copied any new aliases from $RC_FILE, $(wc -l < "${OUTPUT_FILE}") aliases are now saved in: $OUTPUT_FILE
"
