#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

if [[ "$EUID" == 0 ]]; then
  msg="This script should NOT be run with sudo"
  echo "$msg"
  notify-send "$msg" &> /dev/null || true
  exit
fi

schemeID=$(ls $SCRIPT_DIR/*.vst)
schemeID=${schemeID/$SCRIPT_DIR\//}
schemeID=${schemeID/.vst/}

# Install Language Packs

for vlf in $SCRIPT_DIR/*/*.vlf; do 
  varnamcli -s $schemeID -import $vlf
done

msg="Finished importing $schemeID language learnings"
echo "$msg"
notify-send "$msg" &> /dev/null || true
