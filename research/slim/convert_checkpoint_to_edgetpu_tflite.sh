#!/bin/bash

# adapted from https://coral.withgoogle.com/docs/edgetpu/retrain-classification/

# Exit script on error.
set -e
# Echo each command, easier for debugging.
set -x

usage() {
  cat << END_OF_USAGE
  Converts TensorFlow checkpoint to EdgeTPU-compatible TFLite file.

  --checkpoint_num  Checkpoint number, by default 0.
  --help            Display this help.
END_OF_USAGE
}

ckpt_number=0
while [[ $# -gt 0 ]]; do
  case "$1" in
    --checkpoint_num)
      ckpt_number=$2
      shift 2 ;;
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

mkdir "${OUTPUT_DIR}"

echo "Copying label file to ${OUTPUT_DIR} ..."
cp "${DATASET_DIR}/labels.txt" "${OUTPUT_DIR}"

echo "GETTING frozen graph template ..."
python3 export_inference_graph.py  \
  --alsologtostderr   \
  --model_name="${network_type}"  \
  --image_size="${image_size}"  \
  --output_file="${OUTPUT_DIR}/graph_template.pb" \
  --dataset_name=local_dataset \
  --quantize

echo "CONVERTING from checkpoint to frozen graph ..."
freeze_graph \
  --input_graph="${OUTPUT_DIR}/graph_template.pb" \
  --input_checkpoint="${TRAIN_DIR}/model.ckpt-${ckpt_number}" \
  --input_binary \
  --output_graph="${OUTPUT_DIR}/frozen_graph.pb" \
  --output_node_names="${output_tensors}"

echo "CONVERTING from frozen graph to TFLite graph ..."
tflite_convert \
  --output_file="${OUTPUT_DIR}/output_tflite_graph.tflite" \
  --graph_def_file="${OUTPUT_DIR}/frozen_graph.pb" \
  --inference_type=QUANTIZED_UINT8 \
  --input_arrays="${input_tensors}" \
  --output_arrays="${output_tensors}" \
  --mean_values=128 \
  --std_dev_values=128 \
  --input_shapes="1,${image_size},${image_size},3"

echo "TFLite graph generated at ${OUTPUT_DIR}/output_tflite_graph.tflite"
