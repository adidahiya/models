#!/bin/bash

# Exit script on error.
set -e
# Echo each command, easier for debugging.
set -x

usage() {
  cat << END_OF_USAGE
  Convenience script that helps to run evaluation with latest checkpoint.

  --help              Display this help.
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

python eval_image_classifier.py \
  --checkpoint_path="${TRAIN_DIR}" \
  --eval_dir="${TRAIN_DIR}" \
  --dataset_name=flowers \
  --dataset_split_name=validation \
  --dataset_dir="${DATASET_DIR}" \
  --model_name="${network_type}" \
  --eval_image_size="${image_size}" \
  --quantize
