# Main function
function perSubjectFunction {
  image=$1

  imageName=${image##*/}
  imageNameNoExtension=${imageName%%.*}
  echo $imageName

  # Convert input image to Analyze format
  # 3dcalc -a ${image} -expr 'a' -prefix ${tempDir}/${imageNameNoExtension}.hdr
  fslchfiletype ANALYZE ${image} ${tempDir}/${imageNameNoExtension}

  # Change to tempDir and run mask_face
  mask_face ${imageNameNoExtension} -a &> /dev/null

  # Copy masked image to tempDir
  cp maskface/${imageNameNoExtension}_full_normfilter.img ${imageNameNoExtension}.img

  # Convert to Nifti format
  # 3dcalc -a ${imageNameNoExtension}.hdr -expr 'a' -prefix ${finalDir}/dm_${imageName}
  fslchfiletype NIFTI_GZ ${imageNameNoExtension} ${finalDir}/dm_${imageName}

  # Remove temporary files
  rm *${imageNameNoExtension}*
  rm maskface/*${imageNameNoExtension}*
}

function perSubjectFunctionSilent {
  image=$1

  imageName=${image##*/}
  imageNameNoExtension=${imageName%%.*}
  echo $imageName

  # Convert input image to Analyze format
  # 3dcalc -a ${image} -expr 'a' -prefix ${tempDir}/${imageNameNoExtension}.hdr &> /dev/null
  fslchfiletype ANALYZE ${image} ${tempDir}/${imageNameNoExtension}

  # Change to tempDir and run mask_face
  mask_face ${imageNameNoExtension} -a &> /dev/null

  # Copy masked image to tempDir
  cp maskface/${imageNameNoExtension}_full_normfilter.img ${imageNameNoExtension}.img

  # Convert to Nifti format
  # 3dcalc -a ${imageNameNoExtension}.hdr -expr 'a' -prefix ${finalDir}/dm_${imageName} &> /dev/null
  fslchfiletype NIFTI_GZ ${imageNameNoExtension}.hdr ${finalDir}/dm_${imageName}

  # Remove temporary files
  rm *${imageNameNoExtension}*
  rm maskface/*${imageNameNoExtension}*
}

if [ "$1" != "" ]; then
    verbose=$1
else
    verbose=false
fi

maxThreads=5 # Max CPU threads to use

origDir=$(pwd)
# finalDir=${origDir}/mask_defaced
finalDir=${origDir}/test
tempDir=${finalDir}/temp

# Create directories if they don't exist
if [ ! -d $finalDir ]; then
  mkdir $finalDir
fi

if [ ! -d $tempDir ]; then
  mkdir $tempDir
fi

# Move into tempDir
cd $tempDir

# Run for all subjtects
for image in ${origDir}/IXI*.nii.gz; do
# for image in $(ls ${origDir}/IXI*.nii.gz | head -n 1); do

  # Run processing for one subject
  if [ "$verbose" = true ]; then
    perSubjectFunction $image &
  else
    perSubjectFunctionSilent $image &
  fi

  # Check number of jobs against max number of threads
  while [[ $(jobs | wc -l) -ge $maxThreads ]]; do
    sleep 1
  done

done
