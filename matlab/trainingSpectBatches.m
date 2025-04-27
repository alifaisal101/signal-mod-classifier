clc;
clear;

fprintf("🧠 Starting CNN training from parts in batches of 5...\n");

% === Settings ===
data_folder = 'stratified_dataset_parts';
part_files = dir(fullfile(data_folder, 'Part_*.mat'));
num_parts = length(part_files);

batch_size = 5;  % Load 5 parts at a time
inputSize = [128 128 1];

% === Load one part to get categories info ===
sample_data = load(fullfile(data_folder, part_files(1).name));
numClasses = numel(categories(categorical(sample_data.part_labels)));

% === Define CNN ===
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

% === Training loop over part batches ===
net = [];  % Init net
maxEpochs = 3;  % total epochs per batch (change as needed)

% === Use one fixed part as validation ===
val_data = load(fullfile(data_folder, part_files(end).name));
XVal = val_data.part_spectrograms;
YVal = categorical(val_data.part_labels);

for batch_start = 1:batch_size:num_parts-1  % exclude last part (used for val)
    batch_end = min(batch_start + batch_size - 1, num_parts-1);

    fprintf("📦 Loading parts %d to %d...\n", batch_start, batch_end);

    % === Load current batch ===
    XTrain = [];
    YTrain = [];

    for i = batch_start:batch_end
        data = load(fullfile(data_folder, part_files(i).name));
        XTrain = cat(4, XTrain, data.part_spectrograms);
        YTrain = [YTrain; categorical(data.part_labels)];
    end

    % === Shuffle the batch ===
    rand_idx = randperm(size(XTrain, 4));
    XTrain = XTrain(:, :, :, rand_idx);
    YTrain = YTrain(rand_idx);

    % === Training Options ===
    options = trainingOptions('adam', ...
        'InitialLearnRate', 5e-4, ...
        'MaxEpochs', maxEpochs, ...
        'MiniBatchSize', 256, ...
        'Shuffle', 'every-epoch', ...
        'ValidationData', {XVal, YVal}, ...
        'ValidationFrequency', 30, ...
        'Verbose', true, ...
        'Plots', 'training-progress', ...
        'ExecutionEnvironment', 'gpu', ...
        'GradientThreshold', 1);

    % === Train ===
    fprintf("🚀 Training on batch %d to %d...\n", batch_start, batch_end);

    if isempty(net)
        net = trainNetwork(XTrain, YTrain, layers, options);  % first time
    else
        net = trainNetwork(XTrain, YTrain, net.Layers, options);  % continue training
    end

    % === Clear memory ===
    clear XTrain YTrain data;
end

% === Save Trained Network ===
save('trainedCNN_batched5Parts.mat', 'net');
fprintf("✅ Finished training and saved model.\n");
