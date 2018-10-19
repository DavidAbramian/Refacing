
maxThreads=3 # Max analyses to run in parallel
threads=0 # Thread counter

# # Rearrange dimensions
# for image in {IXI*.nii.gz,d_IXI*.nii.gz}; do
#   imname=${image##*/}
#   echo $imname
#
#   fslswapdim $image -z -x y $image &
#   while [[ $(jobs | wc -l) -ge $maxThreads ]]; do
#     sleep 1
#   done
# done

# # Convert to FLOAT32
# for image in IXI*.nii.gz; do
#   imname=${image##*/}
#   echo $imname
#
#   fslmaths $image $image -odt float &
#   while [[ $(jobs | wc -l) -ge $maxThreads ]]; do
#     sleep 1
#   done
# done
