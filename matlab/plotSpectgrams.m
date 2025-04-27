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
f_base = 2000;
BT = 0.3;
SNR_values = [Inf, 10, 8, 5];

% Generate signals
[ask, ~]   = askMModulate(input_bits, Fs, f_c, T, M);
[fsk, ~]   = fskMModulate(input_bits, Fs, f_base, T, M);
[psk, ~]   = pskMModulate(input_bits, Fs, f_c, T, M);
[qam, ~]   = qamMModulate(input_bits, Fs, f_c, T, M);
[chirp, ~] = chirpModulate(input_bits, Fs, T, M);
[dpsk, ~]  = dpskMModulate(input_bits, Fs, f_c, T, M);

mod_names = {'ASK', 'FSK', 'PSK', 'QAM', 'Chirp', 'DQPSK'};
mod_signals = {ask, fsk, psk, qam, chirp, dpsk};

figure;
set(gcf, 'Color', 'w');
colormap(gray);

for i = 1:length(mod_signals)
    for j = 1:length(SNR_values)
        % Add noise
        if isinf(SNR_values(j))
            signal = mod_signals{i};
            label = 'Clean';
        else
            signal = awgn(mod_signals{i}, SNR_values(j), 'measured');
            label = sprintf('%ddB', SNR_values(j));
        end

        % Spectrogram
        subplot(length(mod_signals), length(SNR_values), (i-1)*length(SNR_values) + j);
        [~, ~, ~, ps] = spectrogram(signal, 256, 200, 256, Fs);

        % Normalize and display in grayscale
        spec_img = mat2gray(10 * log10(abs(ps) + eps));
        imagesc(spec_img);
        axis xy;
        title(sprintf('%s - %s', mod_names{i}, label), 'FontSize', 9);
        set(gca, 'XTick', [], 'YTick', []);
    end
end
sgtitle('Grayscale Spectrograms of Modulated Signals', 'FontSize', 14);
