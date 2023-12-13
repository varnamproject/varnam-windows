#!/usr/bin/env bash

SUDO=${SUDO:-sudo}
PREFIX=/usr/local

"${SUDO}" mkdir -p "${PREFIX}/share/varnam/schemes/"
for scheme in schemes/*/*.vst; do
  echo $scheme;
  "${SUDO}" cp $scheme "${PREFIX}/share/varnam/schemes/"
done
