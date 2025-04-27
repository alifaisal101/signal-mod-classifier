clc;
clear;

fprintf("🔍 Loading trained model and dataset...\n");

% Load trained network
load('trainedSimpleCNN_Spectrogram.mat', 'trainedNet');

% Load dataset
load('spectrogram_modulation_dataset.mat', 'spectrograms', 'labels');
Y = categorical(labels);

% Split data (same as training)
cv = cvpartition(Y, 'HoldOut', 0.2);
valIdx = test(cv);

XVal = spectrograms(:, :, 1, valIdx);
YVal = Y(valIdx);

% Run predictions
fprintf("📊 Classifying validation set (%d samples)...\n", numel(YVal));
YPred = classify(trainedNet, XVal, 'ExecutionEnvironment', 'gpu');

% Accuracy
acc = mean(YPred == YVal);
fprintf("✅ Validation Accuracy: %.2f%%\n", acc * 100);

% Show some examples
numShow = 10;
randIdx = randperm(numel(YVal), numShow);
figure;
for i = 1:numShow
    subplot(2, 5, i);
    imshow(XVal(:, :, 1, randIdx(i)), []);
    title(sprintf("True: %s\nPred: %s", string(YVal(randIdx(i))), string(YPred(randIdx(i)))));
end
