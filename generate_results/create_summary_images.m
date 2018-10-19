% Compare refaced data with ground truth. Calculate L1 and L2 norm. Plot
% convergence of training across epochs. Create summary images.

dirGroundTruth = fullfile('data','Dataset-defacing5-maskface');
dirGTIm = fullfile(dirGroundTruth,'testA');

dirUnsup = fullfile('generate_images', '20181001-105440-defacing5-maskface-batch5');
dirSup = fullfile('generate_images', '20181002-111504-defacing5-maskface-supervised-batch5');

dirResults = fullfile('data','Dataset-defacing5-maskface','results');
if(~exist(dirResults,'dir'))
    mkdir(dirResults);
end

epochsList = 20:20:200;
nEpochs = length(epochsList);

% Find number of images and size
GTImList = dir(fullfile(dirGTIm, 'im*.png'));
nImages = length(GTImList);

exampleImage = imread(fullfile(GTImList(1).folder, GTImList(1).name));
dim = size(exampleImage);

% Load all ground truth images
GTImages = zeros(dim(1),dim(2),nImages);
for i = 1:nImages
    im = imread(fullfile(GTImList(i).folder, GTImList(i).name));
    GTImages(:,:,i) = double(im);
end

%% Create summary images

for e = 1:nEpochs
    fprintf('e: %i \n', e)
    
    dirUnsupIm = fullfile(dirUnsup, ['epoch_', num2str(epochsList(e))], 'A');
    unsupImList = dir(fullfile(dirUnsupIm, 'im*.png'));
    
    dirSupIm = fullfile(dirSup, ['epoch_', num2str(epochsList(e))], 'A');
    supImList = dir(fullfile(dirSupIm, 'im*.png'));
    
    dirOut = fullfile(dirResults, ['epoch_', num2str(epochsList(e))]);
    if(~exist(dirOut,'dir'))
        mkdir(dirOut)
    end
    
    for i = 1:nImages
        imUnsup = imread(fullfile(unsupImList(i).folder, unsupImList(i).name));
        imSup = imread(fullfile(supImList(i).folder, supImList(i).name));
        
        imOut = zeros(2*dim(1), 3*dim(2));
        imOut(1:dim(1),1:dim(2)) = GTImages(:,:,i);
        imOut(1:dim(1),dim(2)+1:2*dim(2)) = imUnsup;
        imOut(1:dim(1),2*dim(2)+1:3*dim(2)) = imSup;
        imOut(dim(1)+1:2*dim(1),dim(2)+1:2*dim(2)) = GTImages(:,:,i) - double(imUnsup) + 128;
        imOut(dim(1)+1:2*dim(1),2*dim(2)+1:3*dim(2)) = GTImages(:,:,i) - double(imSup) + 128;
        
        fileOut = fullfile(dirOut, unsupImList(i).name);
        imwrite(uint8(imOut), fileOut);
    end
    
end
