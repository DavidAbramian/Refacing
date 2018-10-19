% Compare refaced data with ground truth. Calculate L1 and L2 norm. Plot
% convergence fo training across epochs. Create summary images.

dirGroundTruth = fullfile('data','Dataset-defacing20-tight');
dirGTIm = fullfile(dirGroundTruth,'testA');

dirUnsup = fullfile('generate_images', '20180918-215012-defacing20-tight');
dirSup = fullfile('generate_images', '20180918-215150-defacing20-tight-supervised');

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

%% Figures

figure('Name','defacing20_tight')

subplot(331)
hold on
plot(epochsList, l1normsUnsup, 'LineWidth', 3)
plot(epochsList, l1normsSup, 'LineWidth', 3)
title('Total L1 norms')
legend('Unsupervised','Supervised')

subplot(332)
hold on
plot(epochsList, l2normsUnsup, 'LineWidth', 3)
plot(epochsList, l2normsSup, 'LineWidth', 3)
title('Total L2 norms')
legend('Unsupervised','Supervised')

subplot(333)
hold on
plot(epochsList, corrUnsup, 'LineWidth', 3)
plot(epochsList, corrSup, 'LineWidth', 3)
title('Total correlation')
legend('Unsupervised','Supervised', 'Location', 'northwest')

subplot(334)
hold on
plot(epochsList, mean(l1normsUnsupAll,2), 'LineWidth', 3)
plot(epochsList, mean(l1normsSupAll,2), 'LineWidth', 3)
title('Mean L1 norms per image')
legend('Unsupervised','Supervised')

subplot(335)
hold on
plot(epochsList, mean(l2normsUnsupAll,2), 'LineWidth', 3)
plot(epochsList, mean(l2normsSupAll,2), 'LineWidth', 3)
title('Mean L2 norms per image')
legend('Unsupervised','Supervised')

subplot(336)
hold on
plot(epochsList, mean(corrUnsupAll,2), 'LineWidth', 3)
plot(epochsList, mean(corrSupAll,2), 'LineWidth', 3)
title('Mean correlation per image')
legend('Unsupervised','Supervised', 'Location', 'northwest')


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