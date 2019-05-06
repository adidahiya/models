#!/bin/bash

# adapted from https://coral.withgoogle.com/docs/edgetpu/retrain-classification/

# Exit script on error.
set -e
# Echo each command, easier for debugging.
set -x

usage() {
  cat << END_OF_USAGE
  Downloads checkpoint and dataset needed for the tutorial.

  --help            Display this help.
END_OF_USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help)
      usage
      exit 0 ;;
    --*)
      echo "Unknown flag $1"
      usage
      exit 1 ;;
  esac
done

source "$PWD/constants.sh"

echo "PREPARING checkpoint ..."
mkdir -p "${LEARN_DIR}"
mkdir "${CKPT_DIR}"
cd "${CKPT_DIR}"
wget -O "${ckpt_name}.tgz" "${ckpt_link}"
tar zxvf "${ckpt_name}.tgz"

echo "PREPARING dataset ..."
mkdir "${DATASET_DIR}"
cd "${SLIM_DIR}"
python3 download_and_convert_data.py \
  --dataset_name=flowers \
  --dataset_dir="${DATASET_DIR}"

echo "CHECKPOINT and dataset available in ${LEARN_DIR}"
