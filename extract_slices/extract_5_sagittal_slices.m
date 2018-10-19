% Extract five sagittal slices as .png files from original and defaced
% images in IXI dataset, to use for GAN training

dirDataRoot = '/flush/davab27/IXI';

% Output folders
dirNormal = fullfile(dirDataRoot, 'normal_5');
dirDefaced = fullfile(dirDataRoot, 'defaced_5');

if (~exist(dirNormal, 'dir'))
    mkdir(dirNormal);
end

if (~exist(dirDefaced, 'dir'))
    mkdir(dirDefaced);
end

% Slices to extract around the middle slice
selectedSlicesAroundMid = [-6, -3, 0, 3, 6];

% List of non-defaced files
listFiles = dir(fullfile(dirDataRoot, 'IXI*.nii.gz'));

for i = 1:length(listFiles)  
    fprintf('i = %d \n', i)
    
    % Normal and defaced volumes
    fileNormal = fullfile(listFiles(i).folder, listFiles(i).name);
    fileDefaced = fullfile(listFiles(i).folder, ['d_',listFiles(i).name]);
    
    %% Non-defaced
    % Load non-defaced data
    [header, vol] = ml_load_nifti(fileNormal);
    
    % Select middle sagittal slice
    dim = header.dim;
    midSliceZ = round(dim(3)/2); % Dimensions of IXI data are in the wrong order
    
    % Extract 5 sagittal slices around the middle slice
    slices = midSliceZ + selectedSlicesAroundMid;
    
    for j = 1:length(slices) 
        im = squeeze(vol(:,:,slices(j)));
    
        % Convert and rearrange dimensions
        im = uint8((im ./ max(im(:))) .* 255);
        im = flipud(im');

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
    midSliceZ = round(dim(3)/2); % Dimensions of IXI data are in the wrong order
    
    % Extract 5 sagittal slices around the middle slice
    slices = midSliceZ + selectedSlicesAroundMid;
    
    for j = 1:length(slices) 
        im = squeeze(vol(:,:,slices(j)));

        % Convert and rearrange dimensions
        im = uint8((im ./ max(im(:))) .* 255);
        im = flipud(im');

        % Save image
        imageIndex = (i-1)*length(slices) + j;
        fileOut = fullfile(dirDefaced, ['im', num2str(imageIndex), '.png']);
        imwrite(im, fileOut)
    end
end