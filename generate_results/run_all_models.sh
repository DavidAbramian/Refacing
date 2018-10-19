#!/bin/bash

# # Saved models go here
mkdir -p generate_images/models

# for run in $(ls saved_models); do
for run in 20181005-150104-removed21-norm; do
  echo $run

  # Folder for end results
  mkdir -p generate_images/${run}

  for epoch in $(ls saved_models/${run}/G_A2B*.hdf5); do
  # for epoch in $(ls saved_models/${run}/G_A2B_model_weights_epoch_20.hdf5); do

    # File names for both generators of an epoch
    G_A2B=${epoch##*/}
    G_B2A=G_B2A${G_A2B##G_A2B}

    # Folder for end results (leave only epoch_N)
    dirName=${G_A2B%%.hdf5}
    dirName=${dirName##*weights_}
    echo $dirName
    mkdir generate_images/${run}/${dirName}

    # Code saves results here
    mkdir -p generate_images/synthetic_images/{A,B}

    # Move saved model into folder
    cp saved_models/${run}/${G_A2B} generate_images/models/G_A2B_model.hdf5
    cp saved_models/${run}/${G_B2A} generate_images/models/G_B2A_model.hdf5

    # Create synthetic images
    # python3 CycleGAN3_47layers.py &> /dev/null
    python3 CycleGAN3_47layers.py

    # Move created images to results Folder
    mv generate_images/synthetic_images/* generate_images/${run}/$dirName

  done
done
