#!/usr/bin/env bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

schemeID=$(ls $SCRIPT_DIR/*.vst)
schemeID=${schemeID/$SCRIPT_DIR\//}
schemeID=${schemeID/.vst/}

ARG1=${1:-install}

if [ "$ARG1" == "install" ]; then
  # Install Scheme

  sudo mkdir -p /usr/local/share/varnam/schemes/
  sudo cp *.vst /usr/local/share/varnam/schemes/

  msg="Installed basic $schemeID language support. Use import.sh for importing words"
  echo "$msg"
  notify-send "$msg" &> /dev/null || true
elif [ "$1" = "uninstall" ]; then
  sudo rm "/usr/local/share/varnam/schemes/$schemeID.vst"
  sudo rmdir "/usr/local/share/varnam/schemes/"

  echo "Uninstallation finished"
fi
