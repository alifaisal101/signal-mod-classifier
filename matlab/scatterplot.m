clc;
clear;

% Example signal generation (replace with your actual signals)
num_samples = 1000;  % Number of signals
signal_length = 1024;  % Length of each signal
mod_names = {'ASK', 'FSK', 'PSK', 'QAM', 'Chirp', 'DQPSK'};
num_mods = length(mod_names);
fs = 40000;  % Sampling frequency

% Pre-allocate for features and labels (stored on CPU initially)
features = zeros(num_samples, 3);  % Let's extract 3 features: PSD, amplitude, energy
labels = strings(num_samples, 1);

% Move to GPU
features = gpuArray(features);

% Generate random signals and extract features
for i = 1:num_samples
    % Randomly select modulation type
    mod_type = mod_names{randi(num_mods)};
    
    % Generate a random signal for each modulation (using the same parameters as in your dataset)
    % Replace this with actual signal generation code or use your dataset
    
    % (Here I am using a simple random sine wave for demonstration)
    t = (0:signal_length-1)/fs;  % Time vector
    signal = sin(2 * pi * randi([1000, 5000]) * t) + 0.5 * randn(1, signal_length);  % Example: random sine wave + noise
    
    % Move the signal to GPU
    signal_noisy = gpuArray(awgn(signal, randi([0, 20]), 'measured'));  % Add random noise and transfer to GPU
    
    % === Feature Extraction ===
    % 1. Power Spectral Density (PSD)
    nfft = 1024;  % FFT length
    [pxx, f] = pwelch(signal_noisy, hamming(nfft), nfft/2, nfft, fs);  % Compute PSD using Welch's method
    psd_feature = max(pxx);  % Take the maximum value of the PSD as a feature (peak power)

    % 2. Peak-to-peak amplitude
    peak_to_peak_amplitude = max(signal_noisy) - min(signal_noisy);

    % 3. Signal Energy
    energy = sum(abs(signal_noisy).^2);  % Signal energy
    
    % Store the extracted features (on GPU)
    features(i, :) = [psd_feature, peak_to_peak_amplitude, energy];
    labels(i) = mod_type;
end

% === Dimensionality Reduction: PCA ===
% Move features to the CPU for PCA (as pca doesn't support GPU arrays directly)
features_cpu = gather(features);

% Perform PCA (on CPU)
[coeff, score, ~, ~, explained] = pca(features_cpu);

% Plot the first two principal components
figure;
gscatter(score(:, 1), score(:, 2), labels, 'rgbymc', 'o', 8);
title('PCA of Signal Features');
xlabel('Principal Component 1');
ylabel('Principal Component 2');
legend(mod_names, 'Location', 'best');
grid on;

