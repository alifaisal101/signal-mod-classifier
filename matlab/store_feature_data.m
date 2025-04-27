clc;
clear;

fprintf("📦 Loading original dataset...\n");
load('diverse_modulation_dataset.mat');  % all_signals, all_labels

Fs = 20000;  % Assumed fixed sampling rate for all signals

fprintf("🔍 Extracting features from %d signals...\n", size(all_signals, 1));

num_samples = size(all_signals, 1);
feature_matrix = zeros(num_samples, 6);  % Preallocate: 6 features per signal

for i = 1:num_samples
    sig = all_signals(i, :);
    feature_matrix(i, :) = extract_features(sig, Fs);
    
    if mod(i, 1000) == 0
        fprintf("Processed %d/%d signals\n", i, num_samples);
    end
end

% Store labels as categorical
labels = categorical(all_labels);

% Save new dataset
save('modulation_feature_dataset.mat', 'feature_matrix', 'labels');
fprintf("✅ Saved to 'modulation_feature_dataset.mat'\n");

% Optional: show a PCA scatter plot
fprintf("📊 Visualizing with PCA...\n");
[coeff, score] = pca(feature_matrix);
figure;
gscatter(score(:,1), score(:,2), labels);
xlabel('PC 1'); ylabel('PC 2');
title('PCA of Extracted Features');
grid on;
