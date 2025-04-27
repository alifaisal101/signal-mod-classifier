clc;
clear;

fprintf("📦 Loading dataset...\n");
load('diverse_modulation_dataset.mat');  % loads: all_signals, all_labels

% === Convert labels to categorical ===
Y = categorical(all_labels);  % [N x 1 categorical]

% === Normalize signals ===
X = normalize(all_signals, 2);  % [N x 8000]

% === Train/Validation split BEFORE reshaping ===
rng(1);  % For reproducibility
cv = cvpartition(size(X,1), 'HoldOut', 0.2);

% Split data
XTrain_raw = X(training(cv), :);
YTrain = Y(training(cv));
XVal_raw   = X(test(cv), :);
YVal   = Y(test(cv));

% === Reshape AFTER splitting ===
XTrain = reshape(XTrain_raw', size(XTrain_raw,2), 1, 1, size(XTrain_raw,1));
XVal   = reshape(XVal_raw', size(XVal_raw,2), 1, 1, size(XVal_raw,1));

% === Final size checks ===
fprintf("✅ Training samples: %d\n", size(XTrain,4));
fprintf("✅ Validation samples: %d\n", size(XVal,4));

% === Define CNN architecture ===
inputSize = size(XTrain,1);
numClasses = numel(categories(YTrain));

layers = [
    imageInputLayer([inputSize 1 1], 'Name', 'input')

    convolution2dLayer([7 1], 32, 'Padding', 'same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer([2 1], 'Stride', [2 1])

    convolution2dLayer([5 1], 64, 'Padding', 'same')
    batchNormalizationLayer
    reluLayer
    maxPooling2dLayer([2 1], 'Stride', [2 1])

    fullyConnectedLayer(128)
    dropoutLayer(0.4)
    fullyConnectedLayer(numClasses)
    softmaxLayer
    classificationLayer
];

% === Training options ===
options = trainingOptions('adam', ...
    'InitialLearnRate', 1e-3, ...
    'MaxEpochs', 10, ...
    'MiniBatchSize', 64, ...
    'Shuffle', 'every-epoch', ...
    'ValidationData', {XVal, YVal}, ...
    'ValidationFrequency', 30, ...
    'Verbose', true, ...
    'Plots', 'training-progress', ...
    'ExecutionEnvironment', 'gpu');  % Use GPU if available

% === Train model ===
fprintf("🧠 Training model...\n");
net = trainNetwork(XTrain, YTrain, layers, options);

% === Save model ===
save('modulation_classifier_net.mat', 'net');
fprintf("🎉 Model saved to 'modulation_classifier_net.mat'\n");
