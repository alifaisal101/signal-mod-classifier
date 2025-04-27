clc;
clear;

% Parameters
input_bits = randi([0 1], 1, 1000);
M = 32;
Fs = 20000;
symbol_rate = 1000;
N = log2(M);
num_symbols = ceil(length(input_bits) / N);
symbol_duration = 1 / symbol_rate;
T = num_symbols * symbol_duration;
f_c = 2000;  % carrier frequency for QAM
SNR_values = [Inf, 10, 8, 5];
mod_name = 'QAM';

% Generate QAM signal
[qam, t] = qamMModulate(input_bits, Fs, f_c, T, M);

% Generate noisy versions
signals = cell(length(SNR_values), 1);
for j = 1:length(SNR_values)
    if isinf(SNR_values(j))
        signals{j} = qam;
    else
        signals{j} = awgn(qam, SNR_values(j), 'measured');
    end
end

% Create output folder
output_folder = 'qam_outputs';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% Plot and export
for j = 1:length(SNR_values)
    fig = figure('Visible', 'off');
    set(fig, 'Color', 'w', 'Position', [100 100 800 600]);

    % Time-domain plot
    subplot(2,1,1);
    plot(t, signals{j}, 'm', 'LineWidth', 1.2);
    if isinf(SNR_values(j))
        title(sprintf('%s (Clean)', mod_name), 'FontSize', 14);
        filename_suffix = 'clean';
    else
        title(sprintf('%s + AWGN (%d dB)', mod_name, SNR_values(j)), 'FontSize', 14);
        filename_suffix = sprintf('%ddB', SNR_values(j));
    end
    xlim([0 0.03]);
    ylabel('Amplitude');
    grid on;
    set(gca, 'Color', 'k');

    % Spectrogram
    subplot(2,1,2);
    [~, ~, ~, ps] = spectrogram(signals{j}, 256, 200, 256, Fs);
    imagesc(10*log10(abs(ps)+eps));
    axis xy;
    title('Spectrogram', 'FontSize', 13);
    xlabel('Time Frame');
    ylabel('Frequency Bin');
    set(gca, 'Color', 'k');
    colormap jet;

    % Export as PNG
    filename = fullfile(output_folder, sprintf('%s_%s.png', mod_name, filename_suffix));
    exportgraphics(fig, filename, 'Resolution', 300);

    close(fig);
end

fprintf("✅ Exported QAM plots with spectrograms to folder: %s\n", output_folder);
