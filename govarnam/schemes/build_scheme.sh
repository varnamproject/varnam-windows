#!/usr/bin/env bash

f=$1
vst=schemes/$f/$f.vst
./compile-scheme.rb -s schemes/$f/$f.scheme -o $vst
if [ -f schemes/$f/symbol-frequency-report.txt ]; then
  python3 scripts/symbol-weight-update-in-vst.py $vst schemes/$f/symbol-frequency-report.txt
  echo "Populated weight column in $vst"
fi
