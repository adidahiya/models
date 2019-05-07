r"""Converts local image data to TFRecords of TF-Example protos.

This module reads the image files and creates two TFRecord datasets:
one for train and one for test. Each TFRecord dataset is comprised of a set of
TF-Example protocol buffers, each of which contain a single image and label.

# walkthrough_readingwriting_image_data
See https://www.tensorflow.org/tutorials/load_data/tf_records

"""

import argparse
import os
import tensorflow as tf

from convert_utils import create_image_lists, convert_dataset
from dataset_utils import write_label_file
from local_dataset import CLASS_NAMES_TO_IDS


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--images_dir', help='Path to the folders of categorized images.', required=True)
    parser.add_argument(
        '--dataset_dir', help='Path to the output dataset.', required=True)
    args = parser.parse_args()
    images_dir = os.path.realpath(args.images_dir)
    output_dir = os.path.realpath(args.dataset_dir)
    # for debug testing
    # images_dir = os.getcwd() + "/local_datasets"
    # output_dir = os.getcwd() + "/local_dataset_output"

    # Look at the folder structure, and create lists of all the images.
    image_lists = create_image_lists(images_dir)
    print(image_lists)
    class_count = len(image_lists.keys())
    if class_count == 0:
        tf.logging.error(
            'No valid folders of images found at ' + images_dir)
        return -1
    if class_count == 1:
        tf.logging.error('Only one valid folder of images found at ' +
                         images_dir +
                         ' - multiple classes are needed for classification.')
        return -1

    train_split = []
    validation_split = []

    for class_name in image_lists:
        class_splits = image_lists[class_name]
        # treat 'testing' split as 'training', since we are mashing together hub and flowers prep scripts
        train_split.extend([
            images_dir + '/' + class_splits['dir'] + '/' + fname for fname in class_splits['testing']])
        train_split.extend([
            images_dir + '/' + class_splits['dir'] + '/' + fname for fname in class_splits['training']])
        validation_split.extend([
            images_dir + '/' + class_splits['dir'] + '/' + fname for fname in class_splits['validation']])

    print(str(len(train_split)) + ' images in training split')
    print(str(len(validation_split)) + ' images in validation split')

    convert_dataset('train', train_split, CLASS_NAMES_TO_IDS, output_dir)
    convert_dataset('validation', validation_split,
                    CLASS_NAMES_TO_IDS, output_dir)

    # Finally, write the labels file:
    labels_to_class_names = dict(
        zip(range(len(CLASS_NAMES_TO_IDS)), CLASS_NAMES_TO_IDS))
    write_label_file(labels_to_class_names, output_dir)


if __name__ == "__main__":
    main()
