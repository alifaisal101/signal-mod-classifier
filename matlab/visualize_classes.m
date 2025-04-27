clc;
clear;

% Load the data
fprintf("? Loading dataset...\n");
load('diverse_modulation_dataset.mat');  % loads: all_signals, all_labels

% === Encode labels ===
unique_labels = unique(all_labels);
Y = categorical(all_labels, unique_labels);  % Convert string labels to categorical

% === Prepare inputs ===
X = all_signals;  % [30000 x 8000]
X = normalize(X, 2);  % Normalize each signal (row-wise)

% === Feature Extraction: Power Spectral Density (PSD) ===
nfft = 1024; % FFT length, can be adjusted based on your signal length
fs = 1; % Sample frequency, set it appropriately if known

% We use the `pwelch` function to compute PSD
[pxx, f] = pwelch(X', hamming(nfft), [], nfft, fs);  % X' to transpose for proper dimensions
% pxx is [nfft x samples], where each column corresponds to the PSD of each signal

% Use the average PSD for each signal across all frequencies
features = mean(pxx, 1);  % Mean across the frequency bins (size: [1 x num_samples])

% === GPU Acceleration ===
features_gpu = gpuArray(features);  % Move to GPU

% === Perform t-SNE with GPU ===
fprintf("Performing t-SNE...\n");

% Use t-SNE with GPU (by using the 'gpuArray' type)
X_tsne_gpu = tsne(features_gpu', 'NumDimensions', 2);

% Convert back to CPU for plotting
X_tsne = gather(X_tsne_gpu);

% === Plot the Results ===
figure;
gscatter(X_tsne(:, 1), X_tsne(:, 2), Y, 'rgbymc', 'o', 8);
title('t-SNE of Power Spectral Density Features');
xlabel('t-SNE Dimension 1');
ylabel('t-SNE Dimension 2');
legend(unique_labels, 'Location', 'best');
grid on;
