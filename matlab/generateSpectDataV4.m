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
image_size = [128 128];  % Output image size
SNR_values = [Inf, 10, 8, 5];

% Output folder
out_dir = 'spectrogram_outputs';
if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end

% Generate signals
[ask, ~]   = askMModulate(input_bits, Fs, f_c, T, M);
[fsk, ~]   = fskMModulate(input_bits, Fs, f_base, T, M);
[psk, ~]   = pskMModulate(input_bits, Fs, f_c, T, M);
[qam, ~]   = qamMModulate(input_bits, Fs, f_c, T, M);
[chirp, ~] = chirpModulate(input_bits, Fs, T, M);
[dpsk, ~]  = dpskMModulate(input_bits, Fs, f_c, T, M);

mod_names = {'ASK', 'FSK', 'PSK', 'QAM', 'Chirp', 'DQPSK'};
mod_signals = {ask, fsk, psk, qam, chirp, dpsk};

% Loop through all modulations and SNRs
for i = 1:length(mod_signals)
    mod_name = mod_names{i};
    base_signal = mod_signals{i};

    for j = 1:length(SNR_values)
        snr = SNR_values(j);

        % Apply noise
        if isinf(snr)
            signal = base_signal;
            label = 'Clean';
        else
            signal = awgn(base_signal, snr, 'measured');
            label = sprintf('%ddB', snr);
        end

        % Spectrogram
        [~, ~, ~, ps] = spectrogram(signal, 256, 200, 256, Fs);
        spec_img = imresize(10 * log10(abs(ps) + eps), image_size);  % Resize
        spec_img = mat2gray(spec_img);  % Normalize grayscale

        % Save as PNG
        filename = sprintf('%s_%s.png', mod_name, label);
        fullpath = fullfile(out_dir, filename);
        imwrite(spec_img, fullpath);

        fprintf('Saved: %s\n', fullpath);
    end
end
