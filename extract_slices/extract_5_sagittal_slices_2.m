% Extract five sagittal slices as .png files from original and defaced
% images in IXI dataset, to use for GAN training

dirDataRoot = '/flush/davab27/IXI';

% Output folders
dirNormal = fullfile(dirDataRoot, 'normal_21_Guys_norm');
dirDefaced = fullfile(dirDataRoot, 'defaced_21_Guys_norm');
% dirNormal = fullfile(dirDataRoot, 'normal_5');
% dirDefaced = fullfile(dirDataRoot, 'defaced_5');


if (~exist(dirNormal, 'dir'))
    mkdir(dirNormal);
end

if (~exist(dirDefaced, 'dir'))
    mkdir(dirDefaced);
end

% Slices to extract around the middle slice
% selectedSlicesAroundMid = [-6, -3, 0, 3, 6];
selectedSlicesAroundMid = 5 * (-10:10); % Loose spacing

% List of non-defaced files
listFiles = dir(fullfile(dirDataRoot, 'IXI*Guys*.nii.gz'));

for i = 1:length(listFiles)  
    fprintf('i = %d \n', i)
    
    % Normal and defaced volumes
    fileNormal = fullfile(listFiles(i).folder, listFiles(i).name);
%     fileDefaced = fullfile(listFiles(i).folder, 'mask', ['dm_',listFiles(i).name]);  % face blurred
    fileDefaced = fullfile(listFiles(i).folder, ['d_',listFiles(i).name]);  % face removed
    
    %% Non-defaced
    % Load non-defaced data
    [header, vol] = ml_load_nifti(fileNormal);
    
    % Select middle sagittal slice
    dim = header.dim;
    midSliceX = round(dim(1)/2);
    
    maxVol = max(vol(:)); % Use same value for normal and defaced
    
    % Extract 5 sagittal slices around the middle slice
    slices = midSliceX + selectedSlicesAroundMid;
    
    for j = 1:length(slices) 
        im = squeeze(vol(slices(j),:,:));
    
        % Convert and rearrange dimensions
%         im = uint8((im ./ max(im(:))) .* 255);
        im = uint8((im ./ maxVol) .* 255);
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
    midSliceX = round(dim(1)/2); % Dimensions of IXI data are in the wrong order
        
    % Extract 5 sagittal slices around the middle slice
    slices = midSliceX + selectedSlicesAroundMid;
    
    for j = 1:length(slices) 
        im = squeeze(vol(slices(j),:,:));

        % Convert and rearrange dimensions
%         im = uint8((im ./ max(im(:))) .* 255);
        im = uint8((im ./ maxVol) .* 255);
        im = rot90(im',2);

        % Save image
        imageIndex = (i-1)*length(slices) + j;
        fileOut = fullfile(dirDefaced, ['im', num2str(imageIndex), '.png']);
        imwrite(im, fileOut)
    end
end