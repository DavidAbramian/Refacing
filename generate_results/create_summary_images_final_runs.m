% Compare refaced data with ground truth. Calculate L1 and L2 norm. Plot
% convergence of training across epochs. Create summary images.


dataset = 4;

dirCycleGAN = '/home/davab27/GAN_MRI/CycleGAN3';

switch dataset
    case 1
        currentRun = '20181008-103000-blurred101-Guys-norm';
        currentDataset = 'Dataset-blurred101-Guys-norm';
        dirOrig = fullfile(dirCycleGAN, 'data', currentDataset, 'testA');
        dirDefaced = fullfile(dirCycleGAN, 'data', currentDataset, 'testB');
        dirRefaced = fullfile(dirCycleGAN, 'generate_images', currentRun);
    case 2
        currentRun = '20181009-180000-removed101-Guys-norm';
        currentDataset = 'Dataset-removed101-Guys-norm';
        dirOrig = fullfile(dirCycleGAN, 'data', currentDataset, 'testA');
        dirDefaced = fullfile(dirCycleGAN, 'data', currentDataset, 'testB');
        dirRefaced = fullfile(dirCycleGAN, 'generate_images', currentRun);
    case 3
        currentRun = '20181010-092000-blurred101-norm';
        currentDataset = 'Dataset-blurred101-norm';
        dirOrig = fullfile(dirCycleGAN, 'data', currentDataset, 'testA');
        dirDefaced = fullfile(dirCycleGAN, 'data', currentDataset, 'testB');
        dirRefaced = fullfile(dirCycleGAN, 'generate_images', currentRun);
    case 4
        currentRun = '20181011-151500-removed101-norm';
        currentDataset = 'Dataset-removed101-norm';
        dirOrig = fullfile(dirCycleGAN, 'data', currentDataset, 'testA');
        dirDefaced = fullfile(dirCycleGAN, 'data', currentDataset, 'testB');
        dirRefaced = fullfile(dirCycleGAN, 'generate_images', currentRun);
end

dirResults = fullfile('data', currentDataset, 'results');
if(~exist(dirResults,'dir'))
    mkdir(dirResults);
end

epochsList = 20:20:200;
nEpochs = length(epochsList);

% Find number of images and size
origList = dir(fullfile(dirOrig, 'im*.png'));
nImages = length(origList);

exampleImage = imread(fullfile(dirOrig, origList(1).name));
dim = size(exampleImage);

% Load all original and defaced images
origImages = zeros(dim(1), dim(2), nImages);
defacedImages = zeros(dim(1), dim(2), nImages);
for i = 1:nImages
    im = double(imread(fullfile(dirOrig, origList(i).name))); 
    origImages(:,:,i) = im;
    
    im = double(imread(fullfile(dirDefaced, origList(i).name)));
    defacedImages(:,:,i) = im;
end

%% Create summary images

fprintf([currentDataset, '\n'])

for e = 1:nEpochs
    fprintf('e: %i \n', e)
    
    epochString = ['epoch_', num2str(epochsList(e))];
    
    dirRefacedEpoch = fullfile(dirRefaced, epochString, 'A');
    refacedList = dir(fullfile(dirRefacedEpoch, 'im*.png'));
       
    dirOut = fullfile(dirResults, epochString);
    
    if(~exist(dirOut,'dir'))
        mkdir(dirOut)
    end
    
    for i = 1:nImages
        imRefaced = double(imread(fullfile(dirRefacedEpoch, refacedList(i).name)));
        
        imOut = zeros(dim(1), 4*dim(2));
        
        imOut(1:dim(1), 1:dim(2)) = defacedImages(:,:,i);
        imOut(1:dim(1), dim(2)+1:2*dim(2)) = origImages(:,:,i);
        imOut(1:dim(1), 2*dim(2)+1:3*dim(2)) = imRefaced;
        imOut(1:dim(1), 3*dim(2)+1:4*dim(2)) = origImages(:,:,i) - imRefaced + 128;
%         imOut(dim(1)+1:2*dim(1),dim(2)+1:2*dim(2)) = origImages(:,:,i) - double(imUnsup) + 128;
%         imOut(dim(1)+1:2*dim(1),2*dim(2)+1:3*dim(2)) = origImages(:,:,i) - double(imSup) + 128;
        
        fileOut = fullfile(dirOut, refacedList(i).name);
        imwrite(uint8(imOut), fileOut);
    end
    
end
