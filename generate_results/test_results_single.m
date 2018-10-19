% Compare refaced data with ground truth. Calculate L1 and L2 norm. Plot
% convergence fo training across epochs. Create summary images.

dataset = 5;

switch dataset
    case 1
        dirGroundTruth = fullfile('data','Dataset-blurred21-Guys-norm');
        dirUnsup = fullfile('generate_images', '20181005-135815-blurred21-Guys-norm');
        figureName = 'blurred21-Guys-norm';
    case 2
        dirGroundTruth = fullfile('data','Dataset-blurred101-Guys-norm');
        dirUnsup = fullfile('generate_images', '20181008-103000-blurred101-Guys-norm');
        figureName = 'blurred101-Guys-norm';
    case 3
        dirGroundTruth = fullfile('data','Dataset-removed21-Guys-norm');
        dirUnsup = fullfile('generate_images', '20181005-150359-removed21-Guys-norm');
        figureName = 'removed21-Guys-norm';
    case 4
        dirGroundTruth = fullfile('data','Dataset-removed101-Guys-norm');
        dirUnsup = fullfile('generate_images', '20181009-180000-removed101-Guys-norm');
        figureName = 'removed101-Guys-norm';
    case 5
        dirGroundTruth = fullfile('data','Dataset-blurred21-norm');
        dirUnsup = fullfile('generate_images', '20181005-135214-blurred21-norm');
        figureName = 'blurred21-norm';
    case 6
        dirGroundTruth = fullfile('data','Dataset-blurred101-norm');
        dirUnsup = fullfile('generate_images', '20181010-092000-blurred101-norm');
        figureName = 'blurred101-norm';
    case 7
        dirGroundTruth = fullfile('data','Dataset-removed21-norm');
        dirUnsup = fullfile('generate_images', '20181005-150104-removed21-norm');
        figureName = 'removed101-Guys-norm';
    case 8
        dirGroundTruth = fullfile('data','Dataset-removed101-norm');
        dirUnsup = fullfile('generate_images', '20181011-151500-removed101-norm');
        figureName = 'removed101-norm';
end

dirGTIm = fullfile(dirGroundTruth,'testA');
dirDefaced = fullfile(dirGroundTruth,'testB');

epochsList = 20:20:200;
nEpochs = length(epochsList);

% Find number of images and size
GTImList = dir(fullfile(dirGTIm, 'im*.png'));
nImages = length(GTImList);

exampleImage = imread(fullfile(GTImList(1).folder, GTImList(1).name));
dim = size(exampleImage);

% Load all ground truth images
GTImages = zeros(dim(1),dim(2),nImages);
defacedImages = zeros(dim(1),dim(2),nImages);
for i = 1:nImages
    im = double(imread(fullfile(dirGTIm, GTImList(i).name)));
    GTImages(:,:,i) = im;
    
    im = double(imread(fullfile(dirDefaced, GTImList(i).name)));
    defacedImages(:,:,i) = im;
end

%% Calculate L1 and L2 norms of errors and correlation with ground truth 

% Total norm for each epoch
l1normsUnsup = zeros(nEpochs,1);
l2normsUnsup = zeros(nEpochs,1);

% Norm for each image and epoch separately
l1normsUnsupAll = zeros(nEpochs,nImages);
l2normsUnsupAll = zeros(nEpochs,nImages);

% Correlations
corrUnsup = zeros(nEpochs,1);
corrUnsupAll = zeros(nEpochs,nImages);

for e = 1:nEpochs
    fprintf('e: %i \n', e)
    
    dirUnsupIm = fullfile(dirUnsup, ['epoch_', num2str(epochsList(e))], 'A');
    unsupImList = dir(fullfile(dirUnsupIm, 'im*.png'));
    
    unsupImages = zeros(dim(1),dim(2),nImages);
    
    for i = 1:nImages
        imGT = GTImages(:,:,i);
        im = double(imread(fullfile(unsupImList(i).folder, unsupImList(i).name)));
        
        l1normsUnsupAll(e,i) = norm(imGT(:) - im(:), 1);
        l2normsUnsupAll(e,i) = norm(imGT(:) - im(:), 2);
        
%         corrUnsupAll(e,i) = corr(imGT(:), im(:));
        corrUnsupAll(e,i) = ssim(imGT, im);
        
        unsupImages(:,:,i) = im;
    end
    
    l1normsUnsup(e) = norm(GTImages(:) - unsupImages(:), 1);
    l2normsUnsup(e) = norm(GTImages(:) - unsupImages(:), 2);
    
    corrUnsup(e) = corr(GTImages(:), unsupImages(:));
end

% Defaced images
l1normDefaced = zeros(nEpochs,1);
l1normDefacedAll = zeros(nEpochs,nImages);

l2normDefaced = zeros(nEpochs,1);
l2normDefacedAll = zeros(nEpochs,nImages);

corrDefaced = zeros(nEpochs,1);
corrDefacedAll = zeros(nEpochs,nImages);

for i = 1:nImages
    imGT = GTImages(:,:,i);
    im = defacedImages(:,:,i);

    l1normDefacedAll(:,i) = norm(imGT(:) - im(:), 1);
    l2normDefacedAll(:,i) = norm(imGT(:) - im(:), 2);

%     corrDefacedAll(:,i) = corr(imGT(:), im(:));
    corrDefacedAll(:,i) = ssim(imGT, im);
end

l1normDefaced(:) = norm(GTImages(:) - defacedImages(:), 1);
l2normDefaced(:) = norm(GTImages(:) - defacedImages(:), 2);

corrDefaced(:) = corr(GTImages(:), defacedImages(:));

%% Figures

figure('Name',figureName)

% Total L1, L2, correlation
subplot(331)
hold on
plot(epochsList, l1normsUnsup, 'LineWidth', 3)
plot(epochsList, l1normDefaced, 'LineWidth', 3)
title('Total L1 norms')
legend('Unsupervised','Defaced')

subplot(332)
hold on
plot(epochsList, l2normsUnsup, 'LineWidth', 3)
plot(epochsList, l2normDefaced, 'LineWidth', 3)
title('Total L2 norms')
legend('Unsupervised','Defaced')

subplot(333)
hold on
plot(epochsList, corrUnsup, 'LineWidth', 3)
plot(epochsList, corrDefaced, 'LineWidth', 3)
title('Total correlation')
legend('Unsupervised', 'Defaced', 'Location', 'northwest')

% Percentiles of L1, L2, correlation

percentileMode = 1;
switch percentileMode
    case 1
        lowPerc = 5;
        highPerc = 95;
    case 2
        lowPerc = 25;
        highPerc = 75;
    case 3
        lowPerc = 33;
        highPerc = 66;
end

% 5% and 95% percentiles for each epoch
meanVal = [median(l1normsUnsupAll,2), median(l1normDefacedAll,2)];
overMeanVal = cat(3, prctile(l1normsUnsupAll',highPerc)' - meanVal(:,1), prctile(l1normDefacedAll',highPerc)' - meanVal(:,2));
underMeanVal = cat(3, meanVal(:,1) - prctile(l1normsUnsupAll',lowPerc)', meanVal(:,2) - prctile(l1normDefacedAll',lowPerc)');

subplot(334)
hold on
boundedline(epochsList, meanVal, [underMeanVal, overMeanVal],'alpha')
title([num2str(lowPerc), '%-', num2str(highPerc), '% percentiles L1 norms'])
legend('Unsupervised','Defaced')

meanVal = [median(l2normsUnsupAll,2), median(l2normDefacedAll,2)];
overMeanVal = cat(3, prctile(l2normsUnsupAll',highPerc)' - meanVal(:,1), prctile(l2normDefacedAll',highPerc)' - meanVal(:,2));
underMeanVal = cat(3, meanVal(:,1) - prctile(l2normsUnsupAll',lowPerc)', meanVal(:,2) - prctile(l2normDefacedAll',lowPerc)');

subplot(335)
hold on
boundedline(epochsList, meanVal, [underMeanVal, overMeanVal],'alpha')
title([num2str(lowPerc), '%-', num2str(highPerc), '% percentiles L2 norms'])
legend('Unsupervised','Defaced')

meanVal = [median(corrUnsupAll,2), median(corrDefacedAll,2)];
overMeanVal = cat(3, prctile(corrUnsupAll',highPerc)' - meanVal(:,1), prctile(corrDefacedAll',highPerc)' - meanVal(:,2));
underMeanVal = cat(3, meanVal(:,1) - prctile(corrUnsupAll',lowPerc)', meanVal(:,2) - prctile(corrDefacedAll',lowPerc)');

subplot(336)
hold on
boundedline(epochsList, meanVal, [underMeanVal, overMeanVal],'alpha')
title([num2str(lowPerc), '%-', num2str(highPerc), '% percentiles correlation'])
legend('Unsupervised', 'Defaced', 'Location', 'northwest')


binEdges = [epochsList - 10, epochsList(end)+10];

[~,I1] = min(l1normsUnsupAll);

subplot(337)
hold on
histogram(epochsList(I1),binEdges);
title('Epoch of minimum L1 norm per image')
legend('Unsupervised', 'Location', 'northwest')

[~,I1] = min(l2normsUnsupAll);

subplot(338)
hold on
histogram(epochsList(I1),binEdges);
title('Epoch of minimum L2 norm per image')
legend('Unsupervised', 'Location', 'northwest')


[~,I1] = max(corrUnsupAll);

subplot(339)
hold on
histogram(epochsList(I1),binEdges);
title('Epoch of maximum correlation per image')
legend('Unsupervised', 'Location', 'northwest')