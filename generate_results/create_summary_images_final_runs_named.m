% Compare refaced data with ground truth. Calculate L1 and L2 norm. Plot
% convergence of training across epochs. Create summary images.


dataset = 4;

dirCycleGAN = '/home/davab27/GAN_MRI/CycleGAN3';
dirIXI = '/flush/davab27/IXI';

epochsList = 20:20:200;
nEpochs = length(epochsList);

switch dataset
    case 1
        currentRun = '20181008-103000-blurred101-Guys-norm';
        currentDataset = 'Dataset-blurred101-Guys-norm';
        dirOrig = fullfile(dirCycleGAN, 'data', currentDataset, 'testA');
        dirDefaced = fullfile(dirCycleGAN, 'data', currentDataset, 'testB');
        dirRefaced = fullfile(dirCycleGAN, 'generate_images', currentRun);
        onlyGuys = 1;
        selectedEpochs = epochsList([5,8,10]);
    case 2
        currentRun = '20181009-180000-removed101-Guys-norm';
        currentDataset = 'Dataset-removed101-Guys-norm';
        dirOrig = fullfile(dirCycleGAN, 'data', currentDataset, 'testA');
        dirDefaced = fullfile(dirCycleGAN, 'data', currentDataset, 'testB');
        dirRefaced = fullfile(dirCycleGAN, 'generate_images', currentRun);
        onlyGuys = 1;
        selectedEpochs = epochsList([9,10]);
    case 3
        currentRun = '20181010-092000-blurred101-norm';
        currentDataset = 'Dataset-blurred101-norm';
        dirOrig = fullfile(dirCycleGAN, 'data', currentDataset, 'testA');
        dirDefaced = fullfile(dirCycleGAN, 'data', currentDataset, 'testB');
        dirRefaced = fullfile(dirCycleGAN, 'generate_images', currentRun);
        onlyGuys = 0;
        selectedEpochs = epochsList([5,10]);
    case 4
        currentRun = '20181011-151500-removed101-norm';
        currentDataset = 'Dataset-removed101-norm';
        dirOrig = fullfile(dirCycleGAN, 'data', currentDataset, 'testA');
        dirDefaced = fullfile(dirCycleGAN, 'data', currentDataset, 'testB');
        dirRefaced = fullfile(dirCycleGAN, 'generate_images', currentRun);
        onlyGuys = 0;
        selectedEpochs = epochsList([8,10]);
end

dirResults = fullfile('data', currentDataset, 'results2');
if(~exist(dirResults,'dir'))
    mkdir(dirResults);
end

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


%% Create summary images

fprintf([currentDataset, '\n'])

for e = 1:length(selectedEpochs)
    fprintf('e: %i \n', e)
    
    epochString = ['epoch_', num2str(selectedEpochs(e))];
    
    dirRefacedEpoch = fullfile(dirRefaced, epochString, 'A');
    refacedList = dir(fullfile(dirRefacedEpoch, 'im*.png'));
       
    dirOut = fullfile(dirResults, epochString);
    
    if(~exist(dirOut,'dir'))
        mkdir(dirOut)
    end
    
    for i = 1:numTestImages
        for j = 1:101
            imageIndex = (i-1)*101 + j;
            
            imRefaced = double(imread(fullfile(dirRefacedEpoch, refacedList(imageIndex).name)));
        
            imOut = zeros(dim(1), 4*dim(2));

            imOut(1:dim(1), 1:dim(2)) = defacedImages(:,:,imageIndex);
            imOut(1:dim(1), dim(2)+1:2*dim(2)) = origImages(:,:,imageIndex);
            imOut(1:dim(1), 2*dim(2)+1:3*dim(2)) = imRefaced;
            imOut(1:dim(1), 3*dim(2)+1:4*dim(2)) = origImages(:,:,imageIndex) - imRefaced + 128;
        
            fileOut = fullfile(dirOut, [imagesIXI(i).name(1:end-7), '_', num2str(j), '.png']);
            imwrite(uint8(imOut), fileOut);
        end
    end    
   
end
