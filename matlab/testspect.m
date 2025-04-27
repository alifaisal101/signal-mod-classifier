clc;
clear;

fprintf("🔍 Testing spectrogram-based modulation classifier...\n");

% Load trained CNN
load('spectrogram_mod_classifier.mat');  % loads 'net'

% Parameters
mod_names = {'ASK', 'FSK', 'PSK', 'QAM', 'Chirp', 'DQPSK'};
M = 32;
Fs = 20000;
symbol_rate = 1000;
N = log2(M);
input_bits = randi([0 1], 1, 1000);
num_symbols = ceil(length(input_bits) / N);
T = num_symbols / symbol_rate;
f_c = 2000;
f_base = 2000;
SNR_dB = 10;
imgSize = [128 128];

for i = 1:length(mod_names)
    mod_type = mod_names{i};

    % --- Generate clean signal ---
    try
        switch mod_type
            case 'ASK'
                [sig, ~] = askMModulate(input_bits, Fs, f_c, T, M);
            case 'FSK'
                [sig, ~] = fskMModulate(input_bits, Fs, f_base, T, M);
            case 'PSK'
                [sig, ~] = pskMModulate(input_bits, Fs, f_c, T, M);
            case 'QAM'
                [sig, ~] = qamMModulate(input_bits, Fs, f_c, T, M);
            case 'Chirp'
                [sig, ~] = chirpModulate(input_bits, Fs, T, M);
            case 'DQPSK'
                [sig, ~] = dpskMModulate(input_bits, Fs, f_c, T, M);
            otherwise
                error("Unsupported modulation type: %s", mod_type);
        end
    catch ME
        warning("❌ Failed to generate %s: %s", mod_type, ME.message);
        continue;
    end

    % --- Create spectrograms ---
    [~, ~, ~, ps_clean] = spectrogram(sig, 256, 200, 256, 1e4);
    img_clean = imresize(10 * log10(abs(ps_clean) + eps), imgSize);
    img_clean = mat2gray(img_clean);

    % Add noise and create spectrogram
    sig_noisy = awgn(sig, SNR_dB, 'measured');
    [~, ~, ~, ps_noisy] = spectrogram(sig_noisy, 256, 200, 256, 1e4);
    img_noisy = imresize(10 * log10(abs(ps_noisy) + eps), imgSize);
    img_noisy = mat2gray(img_noisy);

    % --- Classify ---
    pred_clean = classify(net, img_clean);
    pred_noisy = classify(net, img_noisy);

    % --- Display Results ---
    fprintf("\n📡 %s:\n", mod_type);
    fprintf("   Clean  → Predicted: %s\n", string(pred_clean));
    fprintf("   Noisy  → Predicted: %s (SNR = %d dB)\n", string(pred_noisy), SNR_dB);
end
