% Compare refaced data with ground truth. Calculate L1 and L2 norm. Plot
% convergence fo training across epochs. Create summary images.

dataset = 3;

switch dataset
    case 1
        dirGroundTruth = fullfile('data','Dataset-defacing5-maskface');
        dirUnsup = fullfile('generate_images', '20181001-105440-defacing5-maskface-batch5');
        dirSup = fullfile('generate_images', '20181002-111504-defacing5-maskface-supervised-batch5');
        figureName = 'defacing5-maskface';
    case 2
        dirGroundTruth = fullfile('data','Dataset-defacing5');
        dirUnsup = fullfile('generate_images', '20180914-163550-defacing5');
        dirSup = fullfile('generate_images', '20180917-095331-defacing5-supervised');
        figureName = 'defacing5';
    case 3
        dirGroundTruth = fullfile('data','Dataset-defacing20-tight');
        dirUnsup = fullfile('generate_images', '20180918-215012-defacing20-tight');
        dirSup = fullfile('generate_images', '20180918-215150-defacing20-tight-supervised');
        figureName = 'defacing20-tight';
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
        
        corrUnsupAll(e,i) = corr(imGT(:), im(:));
        
        unsupImages(:,:,i) = im;
    end
    
    l1normsUnsup(e) = norm(GTImages(:) - unsupImages(:), 1);
    l2normsUnsup(e) = norm(GTImages(:) - unsupImages(:), 2);
    
    corrUnsup(e) = corr(GTImages(:), unsupImages(:));
end

% Calculate L1 and L2 norms of errors for supervised data
l1normsSup = zeros(nEpochs,1);
l2normsSup = zeros(nEpochs,1);

l1normsSupAll = zeros(nEpochs,nImages);
l2normsSupAll = zeros(nEpochs,nImages);

% Correlations
corrSup = zeros(nEpochs,1);
corrSupAll = zeros(nEpochs,nImages);

for e = 1:nEpochs
    fprintf('e: %i \n', e)
    
    dirSupIm = fullfile(dirSup, ['epoch_', num2str(epochsList(e))], 'A');
    supImList = dir(fullfile(dirSupIm, 'im*.png'));
    
    supImages = zeros(dim(1),dim(2),nImages);
    
    for i = 1:nImages
        imGT = GTImages(:,:,i);
        im = double(imread(fullfile(supImList(i).folder, supImList(i).name)));
        
        l1normsSupAll(e,i) = norm(imGT(:) - im(:), 1);
        l2normsSupAll(e,i) = norm(imGT(:) - im(:), 2);
        
        corrSupAll(e,i) = corr(imGT(:), im(:));
        
        supImages(:,:,i) = im;
    end
    
    l1normsSup(e) = norm(GTImages(:) - supImages(:), 1);
    l2normsSup(e) = norm(GTImages(:) - supImages(:), 2);
    
    corrSup(e) = corr(GTImages(:), supImages(:));
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

    corrDefacedAll(:,i) = corr(imGT(:), im(:));
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
plot(epochsList, l1normsSup, 'LineWidth', 3)
plot(epochsList, l1normDefaced, 'LineWidth', 3)
title('Total L1 norms')
legend('Unsupervised','Supervised','Defaced')

subplot(332)
hold on
plot(epochsList, l2normsUnsup, 'LineWidth', 3)
plot(epochsList, l2normsSup, 'LineWidth', 3)
plot(epochsList, l2normDefaced, 'LineWidth', 3)
title('Total L2 norms')
legend('Unsupervised','Supervised','Defaced')

subplot(333)
hold on
plot(epochsList, corrUnsup, 'LineWidth', 3)
plot(epochsList, corrSup, 'LineWidth', 3)
plot(epochsList, corrDefaced, 'LineWidth', 3)
title('Total correlation')
legend('Unsupervised','Supervised', 'Defaced', 'Location', 'northwest')

% Percentiles of L1, L2, correlation

% 5% and 95% percentiles for each epoch
meanVal = [median(l1normsUnsupAll,2), median(l1normsSupAll,2), median(l1normDefacedAll,2)];
overMeanVal = cat(3, prctile(l1normsUnsupAll',95)' - meanVal(:,1), prctile(l1normsSupAll',95)' - meanVal(:,2), prctile(l1normDefacedAll',95)' - meanVal(:,3));
underMeanVal = cat(3, meanVal(:,1) - prctile(l1normsUnsupAll',5)', meanVal(:,2) - prctile(l1normsSupAll',5)', meanVal(:,3) - prctile(l1normDefacedAll',5)');

subplot(334)
hold on
% plot(epochsList, mean(l1normsUnsupAll,2), 'LineWidth', 3)
% plot(epochsList, mean(l1normsSupAll,2), 'LineWidth', 3)
% plot(epochsList, mean(l1normDefacedAll,2), 'LineWidth', 3)
boundedline(epochsList, meanVal, [underMeanVal, overMeanVal],'alpha')
title('5%-95% percentiles L1 norms')
legend('Unsupervised','Supervised','Defaced')

meanVal = [median(l2normsUnsupAll,2), median(l2normsSupAll,2), median(l2normDefacedAll,2)];
overMeanVal = cat(3, prctile(l2normsUnsupAll',95)' - meanVal(:,1), prctile(l2normsSupAll',95)' - meanVal(:,2), prctile(l2normDefacedAll',95)' - meanVal(:,3));
underMeanVal = cat(3, meanVal(:,1) - prctile(l2normsUnsupAll',5)', meanVal(:,2) - prctile(l2normsSupAll',5)', meanVal(:,3) - prctile(l2normDefacedAll',5)');

subplot(335)
hold on
% plot(epochsList, mean(l2normsUnsupAll,2), 'LineWidth', 3)
% plot(epochsList, mean(l2normsSupAll,2), 'LineWidth', 3)
% plot(epochsList, mean(l2normDefacedAll,2), 'LineWidth', 3)
boundedline(epochsList, meanVal, [underMeanVal, overMeanVal],'alpha')
title('5%-95% percentiles L2 norms')
legend('Unsupervised','Supervised','Defaced')

meanVal = [median(corrUnsupAll,2), median(corrSupAll,2), median(corrDefacedAll,2)];
overMeanVal = cat(3, prctile(corrUnsupAll',95)' - meanVal(:,1), prctile(corrSupAll',95)' - meanVal(:,2), prctile(corrDefacedAll',95)' - meanVal(:,3));
underMeanVal = cat(3, meanVal(:,1) - prctile(corrUnsupAll',5)', meanVal(:,2) - prctile(corrSupAll',5)', meanVal(:,3) - prctile(corrDefacedAll',5)');

subplot(336)
hold on
% plot(epochsList, mean(corrUnsupAll,2), 'LineWidth', 3)
% plot(epochsList, mean(corrSupAll,2), 'LineWidth', 3)
% plot(epochsList, mean(corrDefacedAll,2), 'LineWidth', 3)
boundedline(epochsList, meanVal, [underMeanVal, overMeanVal],'alpha')
title('5%-95% percentiles correlation')
legend('Unsupervised','Supervised', 'Defaced', 'Location', 'northwest')


binEdges = [epochsList - 10, epochsList(end)+10];

[~,I1] = min(l1normsUnsupAll);
[~,I2] = min(l1normsSupAll);

subplot(337)
hold on
histogram(epochsList(I1),binEdges);
histogram(epochsList(I2),binEdges);
title('Epoch of minimum L1 norm per image')
legend('Unsupervised','Supervised', 'Location', 'northwest')

[~,I1] = min(l2normsUnsupAll);
[~,I2] = min(l2normsSupAll);

subplot(338)
hold on
histogram(epochsList(I1),binEdges);
histogram(epochsList(I2),binEdges);
title('Epoch of minimum L2 norm per image')
legend('Unsupervised','Supervised', 'Location', 'northwest')


[~,I1] = max(corrUnsupAll);
[~,I2] = max(corrSupAll);

subplot(339)
hold on
histogram(epochsList(I1),binEdges);
histogram(epochsList(I2),binEdges);
title('Epoch of maximum correlation per image')
legend('Unsupervised','Supervised', 'Location', 'northwest')