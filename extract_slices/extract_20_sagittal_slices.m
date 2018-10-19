% Extract five sagittal slices as .png files from original and defaced
% images in IXI dataset, to use for GAN training

dirDataRoot = '/flush/davab27/IXI';

% Output folders
dirNormal = fullfile(dirDataRoot, 'normal_20_tight');
dirDefaced = fullfile(dirDataRoot, 'defaced_20_tight');

dirNormal2 = fullfile(dirDataRoot, 'normal_20_loose');
dirDefaced2 = fullfile(dirDataRoot, 'defaced_20_loose');


if (~exist(dirNormal, 'dir'))
    mkdir(dirNormal);
end

if (~exist(dirDefaced, 'dir'))
    mkdir(dirDefaced);
end

if (~exist(dirNormal2, 'dir'))
    mkdir(dirNormal2);
end

if (~exist(dirDefaced2, 'dir'))
    mkdir(dirDefaced2);
end

% Slices to extract around the middle slice
selectedSlicesAroundMid = round(1.5 * (-9:10)); % Tight spacing
selectedSlicesAroundMid2 = 3* [-9:10]; % Loose spacing
% selectedSlicesAroundMid = [-18, -16, -14, -12, -10, -8, -6, -4, -2, 0, 2, 4, 6, 8, 10, 12, 14, 16, 18, 20];


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
    
    slices2 = midSliceZ + selectedSlicesAroundMid2;
    
    for j = 1:length(slices) 
        im = squeeze(vol(:,:,slices(j)));
        im2 = squeeze(vol(:,:,slices2(j)));
    
        % Convert and rearrange dimensions
        im = uint8((im ./ max(im(:))) .* 255);
        im = flipud(im');
        
        im2 = uint8((im2 ./ max(im2(:))) .* 255);
        im2 = flipud(im2');

        % Save image
        imageIndex = (i-1)*length(slices) + j;
        fileOut = fullfile(dirNormal, ['im', num2str(imageIndex), '.png']);
        imwrite(im, fileOut)
        
        fileOut2 = fullfile(dirNormal2, ['im', num2str(imageIndex), '.png']);
        imwrite(im2, fileOut2)
    end
    
    %% Defaced
    % Load defaced data
    [header, vol] = ml_load_nifti(fileDefaced);
    
    % Select middle sagittal slice
    dim = header.dim;
    midSliceZ = round(dim(3)/2); % Dimensions of IXI data are in the wrong order
    
    % Extract 5 sagittal slices around the middle slice
    slices = midSliceZ + selectedSlicesAroundMid;
    
    slices2 = midSliceZ + selectedSlicesAroundMid2;
    
    for j = 1:length(slices) 
        im = squeeze(vol(:,:,slices(j)));
        im2 = squeeze(vol(:,:,slices2(j)));

        % Convert and rearrange dimensions
        im = uint8((im ./ max(im(:))) .* 255);
        im = flipud(im');
        
        im2 = uint8((im2 ./ max(im2(:))) .* 255);
        im2 = flipud(im2');


        % Save image
        imageIndex = (i-1)*length(slices) + j;
        fileOut = fullfile(dirDefaced, ['im', num2str(imageIndex), '.png']);
        imwrite(im, fileOut)
        
        fileOut2 = fullfile(dirDefaced2, ['im', num2str(imageIndex), '.png']);
        imwrite(im2, fileOut2)

    end
end