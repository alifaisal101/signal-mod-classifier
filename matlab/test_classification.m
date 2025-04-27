clc;
clear;

fprintf("🔍 Testing modulation classifier on various signals...\n");

% Load the trained model
load('modulation_classifier_net.mat');  % loads 'net'

% === Parameters ===
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
desired_len = 8000;

% === Loop over modulations and test both clean and noisy ===
for i = 1:length(mod_names)
    mod_type = mod_names{i};

    % --- Generate signal ---
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

    % --- Pad/truncate ---
    if length(sig) > desired_len
        sig = sig(1:desired_len);
    elseif length(sig) < desired_len
        sig = [sig, zeros(1, desired_len - length(sig))];
    end

    % --- Normalize ---
    sig_clean = normalize(sig, 2);
    sig_noisy = awgn(sig_clean, SNR_dB, 'measured');

    % --- Reshape both ---
    sig_clean_input = reshape(sig_clean(:), [8000, 1, 1]);
    sig_noisy_input = reshape(sig_noisy(:), [8000, 1, 1]);

    % --- Classify both ---
    pred_clean = classify(net, sig_clean_input);
    pred_noisy = classify(net, sig_noisy_input);

    % --- Display ---
    fprintf("\n📡 %s:\n", mod_type);
    fprintf("   Clean  → Predicted: %s\n", string(pred_clean));
    fprintf("   Noisy  → Predicted: %s (SNR = %d dB)\n", string(pred_noisy), SNR_dB);
end
