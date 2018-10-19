% Extract five sagittal slices as .png files from original and defaced
% images in IXI dataset, to use for GAN training

dirDataRoot = '/flush/davab27/IXI';

% Output folders
dirNormal = fullfile(dirDataRoot, 'original_101_norm');
dirDefaced = fullfile(dirDataRoot, 'removed_101_norm');

if (~exist(dirNormal, 'dir'))
    mkdir(dirNormal);
end

if (~exist(dirDefaced, 'dir'))
    mkdir(dirDefaced);
end

% Slices to extract around the middle slice
selectedSlicesAroundMid = -50:50; % 21 slices across the face
% selectedSlicesAroundMid = 5 * (-10:10); % 21 slices across the face

% List of non-defaced files
listFiles = dir(fullfile(dirDataRoot, 'IXI*.nii.gz'));
% listFiles = dir(fullfile(dirDataRoot, 'IXI*Guys*.nii.gz'));

maxVal = zeros(length(listFiles),1);

for i = 1:length(listFiles)  
    fprintf('i = %d \n', i)
    
    % Normal and defaced volumes
    fileNormal = fullfile(listFiles(i).folder, listFiles(i).name);
%     fileDefaced = fullfile(listFiles(i).folder, 'mask', ['dm_',listFiles(i).name]);
    fileDefaced = fullfile(listFiles(i).folder, ['d_',listFiles(i).name]);

    %% Non-defaced
    % Load non-defaced data
    [header, vol] = ml_load_nifti(fileNormal);
    
    maxVal(i) = max(vol(:));
    
    % Select middle sagittal slice
    dim = header.dim;
    midSliceX = round(dim(1)/2);
    
    % Extract 5 sagittal slices around the middle slice
    slices = midSliceX + selectedSlicesAroundMid;
    
    for j = 1:length(slices) 
        im = squeeze(vol(slices(j),:,:));
    
        % Convert and rearrange dimensions
        im = uint8((im ./ maxVal(i)) .* 255);
        im = rot90(im',2);

        % Save image
        imageIndex = (i-1)*length(slices) + j;
        fileOut = fullfile(dirNormal, ['im', num2str(imageIndex), '.png']);
        imwrite(im, fileOut)
    end
    
    %% Defaced
    % Load defaced data
    [header, vol] = ml_load_nifti(fileDefaced);
    
   % Select middle sagittal slice
    dim = header.dim;
    midSliceX = round(dim(1)/2);
    
    % Extract 5 sagittal slices around the middle slice
    slices = midSliceX + selectedSlicesAroundMid;
    
    for j = 1:length(slices) 
        im = squeeze(vol(slices(j),:,:));
    
        % Convert and rearrange dimensions
        im = uint8((im ./ maxVal(i)) .* 255);
        im = rot90(im',2);

        % Save image
        imageIndex = (i-1)*length(slices) + j;
        fileOut = fullfile(dirDefaced, ['im', num2str(imageIndex), '.png']);
        imwrite(im, fileOut)
    end
end