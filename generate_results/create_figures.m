

dataset = 3;

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
        
        selectedEpoch = 5;
        selectedImages = [30653, 31059, 31463, 32170];
        
    case 2
        currentRun = '20181009-180000-removed101-Guys-norm';
        currentDataset = 'Dataset-removed101-Guys-norm';
        dirOrig = fullfile(dirCycleGAN, 'data', currentDataset, 'testA');
        dirDefaced = fullfile(dirCycleGAN, 'data', currentDataset, 'testB');
        dirRefaced = fullfile(dirCycleGAN, 'generate_images', currentRun);
        onlyGuys = 1;
        
        selectedEpoch = 9;
        selectedImages = [31755, 32062, 32272, 30553];
        
    case 3
        currentRun = '20181010-092000-blurred101-norm';
        currentDataset = 'Dataset-blurred101-norm';
        dirOrig = fullfile(dirCycleGAN, 'data', currentDataset, 'testA');
        dirDefaced = fullfile(dirCycleGAN, 'data', currentDataset, 'testB');
        dirRefaced = fullfile(dirCycleGAN, 'generate_images', currentRun);
        onlyGuys = 0;
        
        selectedEpoch = 5;
        selectedImages = [52274, 53481, 54490, 50751];

    case 4
        currentRun = '20181011-151500-removed101-norm';
        currentDataset = 'Dataset-removed101-norm';
        dirOrig = fullfile(dirCycleGAN, 'data', currentDataset, 'testA');
        dirDefaced = fullfile(dirCycleGAN, 'data', currentDataset, 'testB');
        dirRefaced = fullfile(dirCycleGAN, 'generate_images', currentRun);
        onlyGuys = 0;
        
        selectedEpoch = 8;
        selectedImages = [50856, 51158, 51360, 55804];
end

%%
nIm = length(selectedImages);
images = cell(nIm, 3);

for i = 1:length(selectedImages)
    imOrig = fullfile(dirOrig, ['im', num2str(selectedImages(i)), '.png']);
    imDefaced = fullfile(dirDefaced, ['im', num2str(selectedImages(i)), '.png']);
    imRefaced = fullfile(dirRefaced, ['epoch_', num2str(epochsList(selectedEpoch))], 'A', ['im', num2str(selectedImages(i)), '_synthetic.png']);
    
    images{i,1} = imOrig;
    images{i,2} = imDefaced;
    images{i,3} = imRefaced;
end

figure
montage(images)