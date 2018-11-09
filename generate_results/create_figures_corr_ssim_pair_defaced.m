% Compare refaced data with ground truth. Calculate L1 and L2 norm. Plot
% convergence of training across epochs. Create summary images.

pair = 2;

switch pair
    case 1
        datasets = [1,2];
        nImagesPerSubj = 21;
        onlyGuys = 1;
    case 2
        datasets = [3,4];
        nImagesPerSubj = 21;
        onlyGuys = 0;
end

dirCycleGAN = '/flush/davab27/CycleGAN/CycleGAN_results';
dirIXI = '/flush/davab27/IXI';

epochsList = 20:20:200;
nEpochs = length(epochsList);

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

dim = [256, 256];

nImages = numTestImages * nImagesPerSubj;

allCorrs = zeros(nImages, length(datasets));
allCorrsDefaced = zeros(nImages, length(datasets));
allSSIMs = zeros(nImages, length(datasets));
allSSIMsDefaced = zeros(nImages, length(datasets));

allMean = zeros(nImages, length(datasets));

for iDataset = 1:length(datasets)

    dataset = datasets(iDataset);

    switch dataset
        % 21 images / subject
        case 1
            currentRun = '20181005-135815-blurred21-Guys-norm';
            currentDataset = 'Dataset-blurred21-Guys-norm';
            dirOrig = fullfile(dirCycleGAN, 'data', currentDataset, 'testA');
            dirDefaced = fullfile(dirCycleGAN, 'data', currentDataset, 'testB');
            dirRefaced = fullfile(dirCycleGAN, 'generate_images', currentRun);

            selectedEpochs = epochsList(5);
        case 2
            currentRun = '20181005-150359-removed21-Guys-norm';
            currentDataset = 'Dataset-removed21-Guys-norm';
            dirOrig = fullfile(dirCycleGAN, 'data', currentDataset, 'testA');
            dirDefaced = fullfile(dirCycleGAN, 'data', currentDataset, 'testB');
            dirRefaced = fullfile(dirCycleGAN, 'generate_images', currentRun);

            selectedEpochs = epochsList(9);
        case 3
            currentRun = '20181005-135214-blurred21-norm';
            currentDataset = 'Dataset-blurred21-norm';
            dirOrig = fullfile(dirCycleGAN, 'data', currentDataset, 'testA');
            dirDefaced = fullfile(dirCycleGAN, 'data', currentDataset, 'testB');
            dirRefaced = fullfile(dirCycleGAN, 'generate_images', currentRun);

            selectedEpochs = epochsList(5);
        case 4
            currentRun = '20181005-150104-removed21-norm';
            currentDataset = 'Dataset-removed21-norm';
            dirOrig = fullfile(dirCycleGAN, 'data', currentDataset, 'testA');
            dirDefaced = fullfile(dirCycleGAN, 'data', currentDataset, 'testB');
            dirRefaced = fullfile(dirCycleGAN, 'generate_images', currentRun);

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

    %% Create summary images

    fprintf([currentDataset, '\n'])

    epochString = ['epoch_', num2str(selectedEpochs)];

    origList = dir(fullfile(dirOrig, 'im*.png'));

    defacedList = dir(fullfile(dirDefaced, 'im*.png'));
    
    dirRefacedEpoch = fullfile(dirRefaced, epochString, 'A');
    refacedList = dir(fullfile(dirRefacedEpoch, 'im*.png'));
    
    for i = 1:numTestImages
        for j = 1:nImagesPerSubj
            % Correct for reordering of images
            imageIndex = (newOrder(i)-1)*nImagesPerSubj + j;

            imOrig = double(imread(fullfile(dirOrig, origList(imageIndex).name)));
            imDefaced = double(imread(fullfile(dirDefaced, defacedList(imageIndex).name)));
            imRefaced = double(imread(fullfile(dirRefacedEpoch, refacedList(imageIndex).name)));

            a = round(dim(2)/1);
            imOrig = imOrig(:,1:a);
            imDefaced = imDefaced(:,1:a);
            imRefaced = imRefaced(:,1:a);

            correction = 1;
            
            resultsIndex = (i-1)*nImagesPerSubj + j;
            allCorrs(resultsIndex,iDataset) = corr(imOrig(:), imRefaced(:));
            allSSIMs(resultsIndex,iDataset) = ssim(imOrig/255, imRefaced/255 / correction);
            
            allCorrsDefaced(resultsIndex,iDataset) = corr(imOrig(:), imDefaced(:));
            allSSIMsDefaced(resultsIndex,iDataset) = ssim(imOrig/255, imDefaced/255);
            
            allMean(resultsIndex,iDataset) = mean(imRefaced(:)) / mean(imOrig(:));
        end
    end

end

%% Create figures

% Colors to be used in plots
colors = lines(8);
colors = colors([1,2,5,4],:);

if (onlyGuys)
    % Calculate means
    meanCorr = mean(allCorrs);
    meanSSIM = mean(allSSIMs);
    
    figure

    subplot(211)
    hold on
    % Plot correlations and means
    plot(1:length(allCorrs(:,1)), allCorrs(:,1), 'LineWidth', 1, 'Color', colors(1,:))
    plot([1; nImages], [meanCorr(:,1); meanCorr(:,1)], 'LineWidth', 2, 'Color', colors(2,:))
    plot(allCorrs(:,2), 'LineWidth', 1, 'Color', colors(3,:))    
    plot([1; nImages], [meanCorr(:,2); meanCorr(:,2)], 'LineWidth', 2, 'Color', colors(4,:))

    % Axes, etc.
    axis tight
    title('Correlation coefficient')
    xlabel('Image index')
    legend('Face-blurred','Mean face-blurred', 'Face-removed', 'Mean face-removed','location','southeast')

    subplot(212)
    hold on
    % Plot SSIMs
    plot(allSSIMs(:,1), 'LineWidth', 1, 'Color', colors(1,:))
    plot(allSSIMs(:,2), 'LineWidth', 1, 'Color', colors(3,:))
    % Plot means
    plot([1; nImages], [meanSSIM(:,1); meanSSIM(:,1)], 'LineWidth', 2, 'Color', colors(2,:))
    plot([1; nImages], [meanSSIM(:,2); meanSSIM(:,2)], 'LineWidth', 2, 'Color', colors(4,:))
    % Axes, etc.
    axis tight
    title('Structural similarity index (SSIM)')
    xlabel('Image index')
else  
    % Calculate separator positions
    nGuys = nnz(indexGuys);
    nHH = nnz(indexHH);

    p1 = nGuys*nImagesPerSubj + 0.5;
    p2 = (nGuys+nHH)*nImagesPerSubj + 0.5;
    minCorr = min([allCorrs(:); allCorrsDefaced(:)]);
    maxCorr = max([allCorrs(:); allCorrsDefaced(:)]);
    minSSIM = min([allSSIMs(:); allSSIMsDefaced(:)]);
    maxSSIM = max([allSSIMs(:); allSSIMsDefaced(:)]);
    
    % Calculate means
    xGuys = 1 : nGuys*nImagesPerSubj;
    xHH = nGuys*nImagesPerSubj+1 : (nGuys+nHH)*nImagesPerSubj;
    xIOP = (nGuys+nHH)*nImagesPerSubj+1 : nImages;
    
    meanCorrGuys = mean(allCorrs(xGuys,:));
    meanCorrHH = mean(allCorrs(xHH,:));
    meanCorrIOP = mean(allCorrs(xIOP,:));
    
    meanSSIMGuys = mean(allSSIMs(xGuys,:));
    meanSSIMHH = mean(allSSIMs(xHH,:));
    meanSSIMIOP = mean(allSSIMs(xIOP,:));
    
    meanCorrGuysDefaced = mean(allCorrsDefaced(xGuys,:));
    meanCorrHHDefaced = mean(allCorrsDefaced(xHH,:));
    meanCorrIOPDefaced = mean(allCorrsDefaced(xIOP,:));
    
    meanSSIMGuysDefaced = mean(allSSIMsDefaced(xGuys,:));
    meanSSIMHHDefaced = mean(allSSIMsDefaced(xHH,:));
    meanSSIMIOPDefaced = mean(allSSIMsDefaced(xIOP,:));


    figure

    subplot(231)
    hold on
    % Plot correlations
    plot(allCorrs(:,1), 'LineWidth', .1, 'Color', colors(1,:))
    plot(xGuys, meanCorrGuys(1)*ones(size(xGuys)), 'LineWidth' , 2, 'Color', colors(2,:))
    plot(allCorrs(:,2), 'LineWidth', .1, 'Color', colors(3,:))
    plot(xGuys, meanCorrGuys(2)*ones(size(xGuys)), 'LineWidth' , 2, 'Color', colors(4,:))
    % Plot means
%     plot(xGuys, meanCorrGuys(1)*ones(size(xGuys)), 'LineWidth' , 2, 'Color', colors(2,:))
    plot(xHH, meanCorrHH(1)*ones(size(xHH)), 'LineWidth', 2, 'Color', colors(2,:))
    plot(xIOP, meanCorrIOP(1)*ones(size(xIOP)), 'LineWidth', 2, 'Color', colors(2,:))
%     plot(xGuys, meanCorrGuys(2)*ones(size(xGuys)), 'LineWidth' , 2, 'Color', colors(4,:))
    plot(xHH, meanCorrHH(2)*ones(size(xHH)), 'LineWidth', 2, 'Color', colors(4,:))
    plot(xIOP, meanCorrIOP(2)*ones(size(xIOP)), 'LineWidth', 2, 'Color', colors(4,:))
    % Plot separators
    plot([p1 p2; p1 p2], [minCorr minCorr; maxCorr maxCorr], 'k--','LineWidth',2)
    
    % Axes, etc.
    axis tight
    title('Correlation coefficient, reconstructed')
    xlabel('Image index')
    legend('Face-blurred','Mean face-blurred', 'Face-removed', 'Mean face-removed','location','southeast')

    
    subplot(232)
    hold on
    plot(allCorrsDefaced(:,1), 'LineWidth', .1, 'Color', colors(1,:))
    plot(allCorrsDefaced(:,2), 'LineWidth', .1, 'Color', colors(3,:))
    
    plot(xGuys, meanCorrGuysDefaced(1)*ones(size(xGuys)), 'LineWidth', 2, 'Color', colors(2,:))
    plot(xHH, meanCorrHHDefaced(1)*ones(size(xHH)), 'LineWidth', 2, 'Color', colors(2,:))
    plot(xIOP, meanCorrIOPDefaced(1)*ones(size(xIOP)), 'LineWidth', 2, 'Color', colors(2,:))
    
    plot(xGuys, meanCorrGuysDefaced(2)*ones(size(xGuys)), 'LineWidth', 2, 'Color', colors(4,:))
    plot(xHH, meanCorrHHDefaced(2)*ones(size(xHH)), 'LineWidth', 2, 'Color', colors(4,:))
    plot(xIOP, meanCorrIOPDefaced(2)*ones(size(xIOP)), 'LineWidth', 2, 'Color', colors(4,:))

    % Plot separators
    plot([p1 p2; p1 p2], [minCorr minCorr; maxCorr maxCorr], 'k--','LineWidth',2)

    
    % Axes, etc.
    axis tight
    title('Correlation coefficient, facemasked')
    xlabel('Image index')


    subplot(234)
    hold on
    % Plot SSIMs
    plot(allSSIMs(:,1), 'LineWidth', .1, 'Color', colors(1,:))
    plot(allSSIMs(:,2), 'LineWidth', .1, 'Color', colors(3,:))
    % Plot means
    plot(xGuys, meanSSIMGuys(1)*ones(size(xGuys)), 'LineWidth', 2, 'Color', colors(2,:))
    plot(xHH, meanSSIMHH(1)*ones(size(xHH)), 'LineWidth', 2, 'Color', colors(2,:))
    plot(xIOP, meanSSIMIOP(1)*ones(size(xIOP)), 'LineWidth', 2, 'Color', colors(2,:))
    plot(xGuys, meanSSIMGuys(2)*ones(size(xGuys)), 'LineWidth', 2, 'Color', colors(4,:))
    plot(xHH, meanSSIMHH(2)*ones(size(xHH)), 'LineWidth', 2, 'Color', colors(4,:))
    plot(xIOP, meanSSIMIOP(2)*ones(size(xIOP)), 'LineWidth', 2, 'Color', colors(4,:))
    % Plot separators
    plot([p1 p2; p1 p2], [minSSIM minSSIM; maxSSIM maxSSIM], 'k--','LineWidth',2)
    
    axis tight
    title('Structural similarity index (SSIM), reconstructed')
    xlabel('Image index')

    
    subplot(235)
    hold on
    plot(allSSIMsDefaced(:,1), 'LineWidth', .1, 'Color', colors(1,:))
    plot(allSSIMsDefaced(:,2), 'LineWidth', .1, 'Color', colors(3,:))

    plot(xGuys, meanSSIMGuysDefaced(1)*ones(size(xGuys)), 'LineWidth', 2, 'Color', colors(2,:))
    plot(xHH, meanSSIMHHDefaced(1)*ones(size(xHH)), 'LineWidth', 2, 'Color', colors(2,:))
    plot(xIOP, meanSSIMIOPDefaced(1)*ones(size(xIOP)), 'LineWidth', 2, 'Color', colors(2,:))
    
    plot(xGuys, meanSSIMGuysDefaced(2)*ones(size(xGuys)), 'LineWidth', 2, 'Color', colors(4,:))
    plot(xHH, meanSSIMHHDefaced(2)*ones(size(xHH)), 'LineWidth', 2, 'Color', colors(4,:))
    plot(xIOP, meanSSIMIOPDefaced(2)*ones(size(xIOP)), 'LineWidth', 2, 'Color', colors(4,:))

    % Plot separators
    plot([p1 p2; p1 p2], [minSSIM minSSIM; maxSSIM maxSSIM], 'k--','LineWidth',2)
    
    % Axes, etc.
    axis tight
    title('Structural similarity index (SSIM), facemasked')
    xlabel('Image index')
    
    subplot(233)
    hold on
    
    plot(xGuys, meanCorrGuys(1)*ones(size(xGuys)), 'LineWidth' , 2, 'Color', colors(2,:))
    plot(xGuys, meanCorrGuys(2)*ones(size(xGuys)), 'LineWidth' , 2, 'Color', colors(4,:))
    plot(xHH, meanCorrHH(1)*ones(size(xHH)), 'LineWidth', 2, 'Color', colors(2,:))
    plot(xIOP, meanCorrIOP(1)*ones(size(xIOP)), 'LineWidth', 2, 'Color', colors(2,:))
    plot(xHH, meanCorrHH(2)*ones(size(xHH)), 'LineWidth', 2, 'Color', colors(4,:))
    plot(xIOP, meanCorrIOP(2)*ones(size(xIOP)), 'LineWidth', 2, 'Color', colors(4,:))
    
    plot(xGuys, meanCorrGuysDefaced(1)*ones(size(xGuys)), '--', 'LineWidth', 2, 'Color', colors(2,:))
    plot(xHH, meanCorrHHDefaced(1)*ones(size(xHH)), '--', 'LineWidth', 2, 'Color', colors(2,:))
    plot(xIOP, meanCorrIOPDefaced(1)*ones(size(xIOP)), '--', 'LineWidth', 2, 'Color', colors(2,:))
    plot(xGuys, meanCorrGuysDefaced(2)*ones(size(xGuys)), '--', 'LineWidth', 2, 'Color', colors(4,:))
    plot(xHH, meanCorrHHDefaced(2)*ones(size(xHH)), '--', 'LineWidth', 2, 'Color', colors(4,:))
    plot(xIOP, meanCorrIOPDefaced(2)*ones(size(xIOP)), '--', 'LineWidth', 2, 'Color', colors(4,:))

    % Plot separators
    plot([p1 p2; p1 p2], [minCorr minCorr; maxCorr maxCorr], 'k--','LineWidth',2)
    
    % Axes, etc.
    axis tight
    title('Correlation coefficient, means')
    xlabel('Image index')    
    
    
    subplot(236)
    hold on

    plot(xGuys, meanSSIMGuys(1)*ones(size(xGuys)), 'LineWidth', 2, 'Color', colors(2,:))
    plot(xHH, meanSSIMHH(1)*ones(size(xHH)), 'LineWidth', 2, 'Color', colors(2,:))
    plot(xIOP, meanSSIMIOP(1)*ones(size(xIOP)), 'LineWidth', 2, 'Color', colors(2,:))
    plot(xGuys, meanSSIMGuys(2)*ones(size(xGuys)), 'LineWidth', 2, 'Color', colors(4,:))
    plot(xHH, meanSSIMHH(2)*ones(size(xHH)), 'LineWidth', 2, 'Color', colors(4,:))
    plot(xIOP, meanSSIMIOP(2)*ones(size(xIOP)), 'LineWidth', 2, 'Color', colors(4,:))

    plot(xGuys, meanSSIMGuysDefaced(1)*ones(size(xGuys)), '--', 'LineWidth', 2, 'Color', colors(2,:))
    plot(xHH, meanSSIMHHDefaced(1)*ones(size(xHH)), '--', 'LineWidth', 2, 'Color', colors(2,:))
    plot(xIOP, meanSSIMIOPDefaced(1)*ones(size(xIOP)), '--', 'LineWidth', 2, 'Color', colors(2,:))
    plot(xGuys, meanSSIMGuysDefaced(2)*ones(size(xGuys)), '--', 'LineWidth', 2, 'Color', colors(4,:))
    plot(xHH, meanSSIMHHDefaced(2)*ones(size(xHH)), '--', 'LineWidth', 2, 'Color', colors(4,:))
    plot(xIOP, meanSSIMIOPDefaced(2)*ones(size(xIOP)), '--', 'LineWidth', 2, 'Color', colors(4,:))

    % Plot separators
    plot([p1 p2; p1 p2], [minSSIM minSSIM; maxSSIM maxSSIM], 'k--','LineWidth',2)
    
    % Axes, etc.
    axis tight
    title('Structural similarity index (SSIM), means')
    xlabel('Image index')
end

set(gcf,'Position',[1500,500,500,500])
