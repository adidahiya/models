#!/bin/bash

# Exit script on error.
set -e
# Echo each command, easier for debugging.
set -x

source "$PWD/constants.sh"

echo "PREPARING checkpoint ..."
mkdir -p "${LEARN_DIR}"
mkdir "${CKPT_DIR}"
cd "${CKPT_DIR}"
wget -O "${ckpt_name}.tgz" "${ckpt_link}"
tar zxvf "${ckpt_name}.tgz"

echo "CHECKPOINT available in ${LEARN_DIR}"
