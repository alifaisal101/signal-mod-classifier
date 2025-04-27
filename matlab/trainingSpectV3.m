clc;
clear;

fprintf(" Loading dataset...\n");

% === Load Data ===
load('spectrogram_modulation_dataset_multiSNR.mat');  % 'spectrograms', 'labels'

% === Convert Labels ===
Y = categorical(labels);

% === Split using cvpartition ===
cv = cvpartition(Y, 'HoldOut', 0.2);  % 80% train / 20% validation
trainIdx = training(cv);
valIdx = test(cv);

XTrain = spectrograms(:, :, 1, trainIdx);
YTrain = Y(trainIdx);
XVal = spectrograms(:, :, 1, valIdx);
YVal = Y(valIdx);

% === Define Input Size ===
inputSize = [128 128 1];
numClasses = numel(categories(YTrain));

% === Define a Simple CNN ===
layers = [
    imageInputLayer(inputSize, 'Name', 'input', 'Normalization', 'zerocenter')
    
    convolution2dLayer(3, 16, 'Padding', 'same', 'Name', 'conv1')
    batchNormalizationLayer('Name', 'bn1')
    reluLayer('Name', 'relu1')
    maxPooling2dLayer(2, 'Stride', 2, 'Name', 'pool1')

    convolution2dLayer(3, 32, 'Padding', 'same', 'Name', 'conv2')
    batchNormalizationLayer('Name', 'bn2')
    reluLayer('Name', 'relu2')
    maxPooling2dLayer(2, 'Stride', 2, 'Name', 'pool2')

    convolution2dLayer(3, 64, 'Padding', 'same', 'Name', 'conv3')
    batchNormalizationLayer('Name', 'bn3')
    reluLayer('Name', 'relu3')
    maxPooling2dLayer(2, 'Stride', 2, 'Name', 'pool3')

    fullyConnectedLayer(128, 'Name', 'fc1')
    reluLayer('Name', 'relu_fc1')
    dropoutLayer(0.5, 'Name', 'dropout')

    fullyConnectedLayer(numClasses, 'Name', 'fc_out')
    softmaxLayer('Name', 'softmax')
    classificationLayer('Name', 'output')
];

% === Training Options ===
options = trainingOptions('adam', ...
    'InitialLearnRate', 5e-4, ...             % Faster convergence
    'MaxEpochs', 100, ...                      % Longer training to improve learning
    'MiniBatchSize', 256, ...                 % Push the GPU harder, balance with VRAM
    'Shuffle', 'every-epoch', ...
    'ValidationData', {XVal, YVal}, ...
    'ValidationFrequency', 30, ...            % Validate often enough to catch overfitting
    'Verbose', true, ...
    'Plots', 'training-progress', ...
    'ExecutionEnvironment', 'gpu', ...
    'GradientThreshold', 1);                  % Prevent exploding gradients

% === Train Network ===
fprintf(" Training CNN...\n");
trainedNet = trainNetwork(XTrain, YTrain, layers, options);

% === Save Model ===
save('trainedSimpleCNN_SpectrogramSNR.mat', 'trainedNet');
fprintf(" Training complete and model saved.\n");
