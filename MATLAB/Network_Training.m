%% Define directories containing training Images ans Labels
% trainDir = 'MATLAB\trainingData';
% LabelDir = 'MATLAB\trainingLabels';
%% Initialize SegNet architecture
%lgraph = unetLayers([320 320], 2, 'EncoderDepth', 4);
lgraph = segnetLayers([320 320], 2, 6);
imds = imageDatastore(trainDir);
%imds = transform(imds, @(x) normalize_Image(x));
classNames = ["tumor" "background"];
labelIDs = [255 0];
pxds = pixelLabelDatastore(LabelDir, classNames, labelIDs);
%ds = combine(imds, pxds);
ds = pixelLabelImageDatastore(imds, pxds);
segLayer = lgraph.Layers(length(lgraph.Layers));
tbl = countEachLabel(ds);
weights = 1 ./ (tbl.PixelCount ./ tbl.ImagePixelCount); % weight classes by their inverse frequency
segLayer.Classes = classNames;
segLayer.ClassWeights = weights;
ds = transform(ds, @(x) normalize_Image(x)); % normalize each image to mean 0 std 1
newlgraph = replaceLayer(lgraph, 'pixelLabels', segLayer);
inputLayer = imageInputLayer([320 320], 'Normalization', 'none', 'Name', 'ImageInputLayer');
newlgraph = replaceLayer(newlgraph, 'inputImage', inputLayer);

%% Train Network
options = trainingOptions('adam', ...
    'MiniBatchSize', 5, ...
    'MaxEpochs',600, ...
    'InitialLearnRate',5e-4, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropPeriod',5, ...
    'LearnRateDropFactor',0.95, ...
    'Shuffle','every-epoch', ...
    'Verbose',true, ...
    'Plots','training-progress', ...
    'ExecutionEnvironment', 'gpu');
sn = trainNetwork(ds, newlgraph, options);
%% Functions
function x=normalize_Image(x)
img = im2double(x);
img = (img - mean(img(:))) / std(img(:));
%x.inputImage{1} = img;
x = img;
end
function x = filterImg(x)
% filt = fspecial('laplacian');
x = imgaussfilt(x, 3);
% x = imfilter(x, filt);
% x = sum(abs(x(:)));
end