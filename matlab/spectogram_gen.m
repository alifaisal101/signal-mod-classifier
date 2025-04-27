clc;
clear;

fprintf("📦 Loading dataset...\n");
load('diverse_modulation_dataset.mat');  % all_signals, all_labels

% Parameters
numSignals = size(all_signals, 1);
signalLength = size(all_signals, 2);
imgSize = [128 128];  % Size of spectrogram image
dataFolder = "spectrogram_data";
mkdir(dataFolder);

% Convert to spectrograms
fprintf("🔄 Converting signals to spectrograms...\n");
for i = 1:numSignals
    signal = all_signals(i,:);
    label = all_labels(i);

    % Compute spectrogram
    [s, f, t, ps] = spectrogram(signal, 256, 200, 256, 1e4);  % adjust Fs to typical value
    ps_dB = 10 * log10(abs(ps) + eps);

    % Resize to standard image
    img = imresize(ps_dB, imgSize);

    % Save as image
    classFolder = fullfile(dataFolder, string(label));
    if ~exist(classFolder, 'dir')
        mkdir(classFolder);
    end
    imwrite(mat2gray(img), fullfile(classFolder, sprintf("%05d.png", i)));
end
fprintf("✅ Spectrograms saved to %s\n", dataFolder);
