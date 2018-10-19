% Compare refaced data with ground truth. Calculate L1 and L2 norm. Plot
% convergence of training across epochs. Create summary images.


dataset = 2;

dirCycleGAN = '/home/davab27/GAN_MRI/CycleGAN3';
dirIXI = '/flush/davab27/IXI';

epochsList = 20:20:200;
nEpochs = length(epochsList);

switch dataset
    % 21 images / subject
    case 1
        currentRun = '20181005-135815-blurred21-Guys-norm';
        currentDataset = 'Dataset-blurred21-Guys-norm';
        dirOrig = fullfile(dirCycleGAN, 'data', currentDataset, 'testA');
        dirDefaced = fullfile(dirCycleGAN, 'data', currentDataset, 'testB');
        dirRefaced = fullfile(dirCycleGAN, 'generate_images', currentRun);

        nImagesPerSubj = 21;
        onlyGuys = 1;
        selectedEpochs = epochsList(5);
    case 2
        currentRun = '20181005-150359-removed21-Guys-norm';
        currentDataset = 'Dataset-removed21-Guys-norm';
        dirOrig = fullfile(dirCycleGAN, 'data', currentDataset, 'testA');
        dirDefaced = fullfile(dirCycleGAN, 'data', currentDataset, 'testB');
        dirRefaced = fullfile(dirCycleGAN, 'generate_images', currentRun);
        
        nImagesPerSubj = 21;
        onlyGuys = 1;
        selectedEpochs = epochsList(9);
    case 3
        currentRun = '20181005-135214-blurred21-norm';
        currentDataset = 'Dataset-blurred21-norm';
        dirOrig = fullfile(dirCycleGAN, 'data', currentDataset, 'testA');
        dirDefaced = fullfile(dirCycleGAN, 'data', currentDataset, 'testB');
        dirRefaced = fullfile(dirCycleGAN, 'generate_images', currentRun);
        
        nImagesPerSubj = 21;
        onlyGuys = 0;
        selectedEpochs = epochsList(5);
    case 4
        currentRun = '20181005-150104-removed21-norm';
        currentDataset = 'Dataset-removed21-norm';
        dirOrig = fullfile(dirCycleGAN, 'data', currentDataset, 'testA');
        dirDefaced = fullfile(dirCycleGAN, 'data', currentDataset, 'testB');
        dirRefaced = fullfile(dirCycleGAN, 'generate_images', currentRun);
        
        nImagesPerSubj = 21;
        onlyGuys = 0;
        selectedEpochs = epochsList(8);
        
        % 101 images / subject
    case 5
        currentRun = '20181008-103000-blurred101-Guys-norm';
        currentDataset = 'Dataset-blurred101-Guys-norm';
        dirOrig = fullfile(dirCycleGAN, 'data', currentDataset, 'testA');
        dirDefaced = fullfile(dirCycleGAN, 'data', currentDataset, 'testB');
        dirRefaced = fullfile(dirCycleGAN, 'generate_images', currentRun);

        nImagesPerSubj = 101;
        onlyGuys = 1;
        selectedEpochs = epochsList(5);
    case 6
        currentRun = '20181009-180000-removed101-Guys-norm';
        currentDataset = 'Dataset-removed101-Guys-norm';
        dirOrig = fullfile(dirCycleGAN, 'data', currentDataset, 'testA');
        dirDefaced = fullfile(dirCycleGAN, 'data', currentDataset, 'testB');
        dirRefaced = fullfile(dirCycleGAN, 'generate_images', currentRun);

        nImagesPerSubj = 101;
        onlyGuys = 1;
        selectedEpochs = epochsList(9);
    case 7
        currentRun = '20181010-092000-blurred101-norm';
        currentDataset = 'Dataset-blurred101-norm';
        dirOrig = fullfile(dirCycleGAN, 'data', currentDataset, 'testA');
        dirDefaced = fullfile(dirCycleGAN, 'data', currentDataset, 'testB');
        dirRefaced = fullfile(dirCycleGAN, 'generate_images', currentRun);

        nImagesPerSubj = 101;
        onlyGuys = 0;
        selectedEpochs = epochsList(5);
    case 8
        currentRun = '20181011-151500-removed101-norm';
        currentDataset = 'Dataset-removed101-norm';
        dirOrig = fullfile(dirCycleGAN, 'data', currentDataset, 'testA');
        dirDefaced = fullfile(dirCycleGAN, 'data', currentDataset, 'testB');
        dirRefaced = fullfile(dirCycleGAN, 'generate_images', currentRun);

        nImagesPerSubj = 101;
        onlyGuys = 0;
        selectedEpochs = epochsList(8);
end

% Find IXI images
if onlyGuys
    imagesIXI = dir(fullfile(dirIXI, 'IXI*-Guys-*T1.nii.gz'));
    numTestImages = 22;
    imagesIXI = imagesIXI(end-numTestImages+1 : end);
    newOrder = 1:numTestImages;
else
    imagesIXI = dir(fullfile(dirIXI, 'IXI*-T1.nii.gz'));
    numTestImages = 81;
    imagesIXI = imagesIXI(end-numTestImages+1 : end);
    
    % Sort by scanning location
    imageNames = {imagesIXI(:).name};
    indexGuys = cellfun(@(x)( contains(x,'Guys') ), imageNames);
    indexHH = cellfun(@(x)( contains(x,'HH') ), imageNames);
    indexIOP = cellfun(@(x)( contains(x,'IOP') ), imageNames);
    newOrder = [find(indexGuys)'; find(indexHH)'; find(indexIOP)'];
    
    imagesIXISorted = imagesIXI(newOrder);
end


% Find number of images and size
origList = dir(fullfile(dirOrig, 'im*.png'));
nImages = length(origList);

exampleImage = imread(fullfile(dirOrig, origList(1).name));
dim = size(exampleImage);

% dim(2) = round(dim(2)/2);
% dim(2) = round(dim(2)/3);

%% Create summary images

fprintf([currentDataset, '\n'])

epochString = ['epoch_', num2str(selectedEpochs)];

dirRefacedEpoch = fullfile(dirRefaced, epochString, 'A');
refacedList = dir(fullfile(dirRefacedEpoch, 'im*.png'));

allCorrs = zeros(nImages,1);
allSSIMs = zeros(nImages,1);

fprintf('Calculating results... \n')
for i = 1:numTestImages
    for j = 1:nImagesPerSubj
        % Correct for reordering of images
        imageIndex = (newOrder(i)-1)*nImagesPerSubj + j;

        imOrig = double(imread(fullfile(dirOrig, origList(imageIndex).name)));
        imRefaced = double(imread(fullfile(dirRefacedEpoch, refacedList(imageIndex).name)));
        
        imOrig = imOrig(:,1:dim(2));
        imRefaced = imRefaced(:,1:dim(2));
        
        resultsIndex = (i-1)*nImagesPerSubj + j;
        allCorrs(resultsIndex) = corr(imOrig(:), imRefaced(:));
        allSSIMs(resultsIndex) = ssim(imOrig, imRefaced);
    end
end

%% Create figures

if (onlyGuys)
    meanCorr = mean(allCorrs);
    meanSSIM = mean(allSSIMs);
    
    figure(1)

    subplot(211)
    hold on
%     plot(allCorrs, 'b', 'LineWidth',1)
    plot(allCorrs, 'LineWidth',1)
%     plot([1; nImages], [meanCorr; meanCorr], 'r', 'LineWidth',2)
    plot([1; nImages], [meanCorr; meanCorr], 'LineWidth',2)
    axis tight
    title('Correlation')
    xlabel('Image index')

    subplot(212)
    hold on
%     plot(allSSIMs, 'b', 'LineWidth',1)
    plot(allSSIMs, 'LineWidth',1)
%     plot([1; nImages], [meanSSIM; meanSSIM], 'r', 'LineWidth',2)
    plot([1; nImages], [meanSSIM; meanSSIM], 'LineWidth',2)
    axis tight
    title('Structural similarity index')
    xlabel('Image index')
else    
    % Calculate separator positions
    nGuys = nnz(indexGuys);
    nHH = nnz(indexHH);

    p1 = nGuys*nImagesPerSubj + 0.5;
    p2 = (nGuys+nHH)*nImagesPerSubj + 0.5;
    minCorr = min(allCorrs);
    maxCorr = max(allCorrs);
    minSSIM = min(allSSIMs);
    maxSSIM = max(allSSIMs);
    
    % Calculate means
    xGuys = 1 : nGuys*nImagesPerSubj;
    xHH = nGuys*nImagesPerSubj+1 : (nGuys+nHH)*nImagesPerSubj;
    xIOP = (nGuys+nHH)*nImagesPerSubj+1 : nImages;
    
    meanCorrGuys = mean(allCorrs(xGuys));
    meanCorrHH = mean(allCorrs(xHH));
    meanCorrIOP = mean(allCorrs(xIOP));
    
    meanSSIMGuys = mean(allSSIMs(xGuys));
    meanSSIMHH = mean(allSSIMs(xHH));
    meanSSIMIOP = mean(allSSIMs(xIOP));

    figure

    subplot(211)
    hold on
    % Plot correlations
    plot(allCorrs, 'b', 'LineWidth',1)
    % Plot separators
    plot([p1 p2; p1 p2], [minCorr minCorr; maxCorr maxCorr], 'k--','LineWidth',2)
    % Plot means
    plot(xGuys, meanCorrGuys*ones(size(xGuys)), 'r', 'LineWidth',2)
    plot(xHH, meanCorrHH*ones(size(xHH)), 'r', 'LineWidth',2)
    plot(xIOP, meanCorrIOP*ones(size(xIOP)), 'r', 'LineWidth',2)
    axis tight
    title('Correlation')
    xlabel('Image index')

    subplot(212)
    hold on
    % Plot SSIMs
    plot(allSSIMs, 'b', 'LineWidth',1)
    % Plot separators
    plot([p1 p2; p1 p2], [minSSIM minSSIM; maxSSIM maxSSIM], 'k--','LineWidth',2)
    % Plot means
    plot(xGuys, meanSSIMGuys*ones(size(xGuys)), 'r', 'LineWidth',2)
    plot(xHH, meanSSIMHH*ones(size(xHH)), 'r', 'LineWidth',2)
    plot(xIOP, meanSSIMIOP*ones(size(xIOP)), 'r', 'LineWidth',2)
    axis tight
    title('Structural similarity index')
    xlabel('Image index')
end