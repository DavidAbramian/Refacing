% Compare refaced data with ground truth. Calculate L1 and L2 norm. Plot
% convergence fo training across epochs. Create summary images.

dataset = 3;

dirCycleGAN = '/home/davab27/GAN_MRI/CycleGAN3';
dirIXI = '/flush/davab27/IXI';

switch dataset
    case 1
        currentRun = '20181008-103000-blurred101-Guys-norm';
        dirSynthIm = fullfile(dirCycleGAN, 'generate_images', currentRun);
        onlyGuys = 1;
    case 2
        currentRun = '20181009-180000-removed101-Guys-norm';
        dirSynthIm = fullfile(dirCycleGAN, 'generate_images', currentRun);
        onlyGuys = 1;
    case 3
        currentRun = '20181010-092000-blurred101-norm';
        dirSynthIm = fullfile(dirCycleGAN, 'generate_images', currentRun);
        onlyGuys = 0;
    case 4
        currentRun = '20181011-??????-removed101-norm';
        dirSynthIm = fullfile(dirCycleGAN, 'generate_images', currentRun);
        onlyGuys = 0;
end

epochsList = 20:20:200;
nEpochs = length(epochsList);

% Find IXI images
if onlyGuys
    imagesIXI = dir(fullfile(dirIXI, 'IXI*-Guys-*T1.nii.gz'));
    numTestImages = 22;
    imagesIXI = imagesIXI(end-numTestImages+1 : end);
else
    imagesIXI = dir(fullfile(dirIXI, 'IXI*-T1.nii.gz'));
    numTestImages = 81;
    imagesIXI = imagesIXI(end-numTestImages+1 : end);
end

%% Generate synthetic images for all epochs

% Output folder for current dataset
dirSynthOut = fullfile(dirCycleGAN, 'synthetic_volumes', currentRun);
if ~exist(dirSynthOut, 'dir')
    mkdir(dirSynthOut);
end

% Load a reference image
[header, vol] = ml_load_nifti(fullfile(dirIXI, imagesIXI(1).name));
header.dt(1) = 16;
dim = header.dim;
mat = header.mat;

% Slice indices around middle sagittal slice
midSliceX = round(dim(1)/2);
selectedSlicesAroundMid = -50:50;
slices = midSliceX + selectedSlicesAroundMid;

% For each epoch...
for e = 1:nEpochs
    
    % Output folder for current epoch
    dirSynthOutEpoch = fullfile(dirSynthOut, ['epoch_', num2str(epochsList(e))]);
    if ~exist(dirSynthOutEpoch, 'dir')
        mkdir(dirSynthOutEpoch)
    end
    
    % Synthetic images
    dirSyntImEpoch = fullfile(dirSynthIm, ['epoch_', num2str(epochsList(e))], 'A');
    synthImList = dir(fullfile(dirSyntImEpoch, 'im*_synthetic.png'));
    
    % For each test subject...
    for s = 1:numTestImages
        fprintf('e: %i, subj: %i \n', e, s)

        volOut = zeros(dim);
        
        % For each slice image...
        for i = 1:length(slices)
            imageIndex = (s-1)*length(slices) + i;
            
            % Load and rotate synthetic image
            im = double(imread(fullfile(dirSyntImEpoch, synthImList(imageIndex).name)));
            im = rot90(im',2);
            
            % Put as single slice in volume
            volOut(slices(i),:,:) = im;
        end
        
        % Write out synthetic volume
        fileOut = fullfile(dirSynthOutEpoch, imagesIXI(s).name(1:end-3));
        header.fname = fileOut;
        spm_write_vol(header, volOut);
        gzip(fileOut);
        delete(fileOut);
    end
end
