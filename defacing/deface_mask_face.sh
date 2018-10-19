
origDir=$(pwd)
finalDir=${origDir}/mask_defaced
# finalDir=${origDir}/test
tempDir=${finalDir}/temp

if [ ! -d $finalDir ]; then
  mkdir $finalDir
fi

for image in IXI*.nii.gz; do
# for image in $(ls IXI*.nii.gz | head -n 2); do

  if [ ! -d $tempDir ]; then
    mkdir $tempDir
  fi

  imageName=${image##*/}
  echo $imageName

  fslswapdim $image -z -x y ${tempDir}/rearranged.nii.gz
  # gunzip ${tempDir}/rearranged.nii.gz
  3dcalc -a ${tempDir}/rearranged.nii.gz -expr 'a' -prefix ${tempDir}/in.hdr

  cd $tempDir
  mask_face in -a &> /dev/null

  cd $origDir
  3dcalc -a ${tempDir}/maskface/in_full_normfilter.hdr -expr 'a' -prefix ${finalDir}/dm_${imageName}

  rm -R $tempDir

done
