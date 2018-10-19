
for image in IXI*.nii.gz; do

  imname=${image##*/}

  # Only if file does not already exist
  if [ ! -f d_$imname ]; then
    ./mri_deface-v1.22-Linux64 ${image} talairach_mixed_with_skull.gca face.gca d_${imname}
  fi

done
