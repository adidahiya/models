#!/bin/bash

# Exit script on error.
set -e
# Echo each command, easier for debugging.
set -x

source "$PWD/constants.sh"

echo "PREPARING dataset ..."
mkdir "${DATASET_DIR}"
cd "${SLIM_DIR}/datasets"
python3 convert_local_dataset.py \
  --images="${SLIM_DIR}/datasets/local_datasets" \
  --dataset_dir="${DATASET_DIR}"

echo "dataset available in ${LEARN_DIR}"
