clc;
clear;

fprintf("? Loading dataset...\n");
load('diverse_modulation_dataset.mat');  % loads: all_signals, all_labels

% === Encode labels ===
unique_labels = unique(all_labels);
Y = categorical(all_labels, unique_labels);  % Convert string labels to categorical

% === Prepare inputs ===
X = all_signals;  % [30000 x 8000]
X = normalize(X, 2);  % Normalize each signal (row-wise)

% Reshape to [samples x signal_length x 1 x 1]
X = reshape(X, [size(X, 1), size(X, 2), 1, 1]);  % [30000 x 8000 x 1 x 1]

% === Train/Validation Split ===
rng(1);  % Reproducibility
cv = cvpartition(size(X, 1), 'HoldOut', 0.2);  % 80% for training, 20% for testing

XTrain = X(training(cv), :, :, :);  % Training data (80% of the data)
YTrain = Y(training(cv));           % Training labels
XVal   = X(test(cv), :, :, :);      % Validation data (20% of the data)
YVal   = Y(test(cv));               % Validation labels

% --- Debugging Check: Ensuring alignment ---
fprintf("Size of XTrain: [%d, %d, %d, %d]\n", size(XTrain));  % Should be [24000, 8000, 1, 1]
fprintf("Size of YTrain: [%d, %d]\n", size(YTrain));          % Should be [24000, 1]
fprintf("Size of XVal: [%d, %d, %d, %d]\n", size(XVal));      % Should be [6000, 8000, 1, 1]
fprintf("Size of YVal: [%d, %d]\n", size(YVal));              % Should be [6000, 1]

% Check if XTrain and YTrain have the same number of rows
if size(XTrain, 1) ~= numel(YTrain)
    error('Mismatch between number of samples in XTrain and YTrain. XTrain has %d samples, YTrain has %d labels.', size(XTrain, 1), numel(YTrain));
end

% Check if XVal and YVal have the same number of rows
if size(XVal, 1) ~= numel(YVal)
    error('Mismatch between number of samples in XVal and YVal. XVal has %d samples, YVal has %d labels.', size(XVal, 1), numel(YVal));
end

% === Define CNN Architecture ===
signalLength = size(XTrain, 2);  % Signal length (number of time steps)
numClasses = numel(categories(YTrain));  % Number of unique modulation types

layers = [
    imageInputLayer([signalLength 1 1], "Name", "input")

    convolution2dLayer([7 1], 32, 'Padding', 'same', 'Name', 'conv1')
    batchNormalizationLayer("Name", "bn1")
    reluLayer("Name", "relu1")
    maxPooling2dLayer([2 1], "Stride", [2 1], "Name", "pool1")

    convolution2dLayer([5 1], 64, 'Padding', 'same', 'Name', 'conv2')
    batchNormalizationLayer("Name", "bn2")
    reluLayer("Name", "relu2")
    maxPooling2dLayer([2 1], "Stride", [2 1], "Name", "pool2")

    fullyConnectedLayer(128, "Name", "fc1")
    dropoutLayer(0.4, "Name", "dropout1")
    fullyConnectedLayer(numClasses, "Name", "fc2")
    softmaxLayer("Name", "softmax")
    classificationLayer("Name", "output")
];

% === Training Options ===
options = trainingOptions('adam', ...
    'InitialLearnRate', 1e-3, ...
    'MaxEpochs', 20, ...
    'MiniBatchSize', 64, ...
    'Shuffle', 'every-epoch', ...
    'ValidationData', {XVal, YVal}, ...
    'ValidationFrequency', 30, ...
    'Verbose', true, ...
    'Plots', 'training-progress', ...
    'ExecutionEnvironment', 'gpu');  % Enable GPU support

% === Train the Network ===
fprintf("? Training model...\n");
net = trainNetwork(XTrain, YTrain, layers, options);

% === Save Model ===
save('modulation_classifier_net.mat', 'net', 'unique_labels');
fprintf("? Model saved to 'modulation_classifier_net.mat'\n");
