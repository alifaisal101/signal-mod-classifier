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
f_c = 2000;
SNR_values = [Inf, 10, 8, 5];  % Include clean version as Inf
mod_name = 'ASK';

% Generate ASK signal
[ask, t] = askMModulate(input_bits, Fs, f_c, T, M);

% Generate noisy versions
signals = cell(length(SNR_values), 1);
for j = 1:length(SNR_values)
    if isinf(SNR_values(j))
        signals{j} = ask;
    else
        signals{j} = awgn(ask, SNR_values(j), 'measured');
    end
end

% Create folder for saving if needed
output_folder = 'ask_outputs';
if ~exist(output_folder, 'dir')
    mkdir(output_folder);
end

% Plot and save each figure
for j = 1:length(SNR_values)
    fig = figure('Visible', 'off');  % Hide the figure window for faster export
    set(fig, 'Color', 'w', 'Position', [100 100 800 600]);  % High-res export

    % --- Time-domain plot ---
    subplot(2,1,1);
    plot(t, signals{j}, 'b', 'LineWidth', 1.2);
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

    % --- Spectrogram ---
    subplot(2,1,2);
    [~, ~, ~, ps] = spectrogram(signals{j}, 256, 200, 256, Fs);
    imagesc(10*log10(abs(ps)+eps));
    axis xy;
    title('Spectrogram', 'FontSize', 13);
    xlabel('Time Frame');
    ylabel('Frequency Bin');
    set(gca, 'Color', 'k');
    colormap jet;

    % --- Save PNG ---
    filename = fullfile(output_folder, sprintf('%s_%s.png', mod_name, filename_suffix));
    exportgraphics(fig, filename, 'Resolution', 300);  % High-quality PNG

    close(fig);  % Close to free memory
end

fprintf("✅ Exported ASK plots with spectrograms to folder: %s\n", output_folder);
