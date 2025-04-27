clc;
clear;

dataFolder = "spectrogram_data";
imds = imageDatastore(dataFolder, ...
    'IncludeSubfolders', true, ...
    'LabelSource', 'foldernames');

% Split into training and validation
[imdsTrain, imdsVal] = splitEachLabel(imds, 0.8);

% Define CNN
layers = [
    imageInputLayer([128 128 1])
    convolution2dLayer(5, 16, 'Padding', 'same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2, 'Stride', 2)

    convolution2dLayer(3, 32, 'Padding', 'same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2, 'Stride', 2)

    convolution2dLayer(3, 64, 'Padding', 'same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer(2, 'Stride', 2)

    fullyConnectedLayer(numel(unique(imds.Labels)))
    softmaxLayer
    classificationLayer
];

% Train options
options = trainingOptions('adam', ...
    'InitialLearnRate', 1e-3, ...
    'MaxEpochs', 10, ...
    'MiniBatchSize', 64, ...
    'Shuffle', 'every-epoch', ...
    'Plots', 'training-progress', ...
    'ValidationData', imdsVal, ...
    'Verbose', true, ...
    'ExecutionEnvironment', 'gpu');

% Train
fprintf(" Training CNN on spectrograms...\n");
net = trainNetwork(imdsTrain, layers, options);
save('spectrogram_mod_classifier.mat', 'net');
