clc;
clear;

fprintf("🔎 Testing single modulation signal with trained CNN...\n");

% === Load trained model ===
load('trainedSimpleCNN_Spectrogram.mat', 'trainedNet');

% === Test parameters ===
mod_type = 'Chirp';   % Choose: 'ASK', 'FSK', 'PSK', 'QAM', 'Chirp', 'DPSK'
M = 16;
Fs = 20000;
symbol_rate = 1000;
f_c = 2000;
input_bits = randi([0 1], 1, 1000);

N = log2(M);
num_symbols = ceil(length(input_bits) / N);
T = num_symbols / symbol_rate;
desired_signal_len = 8000;
image_size = [128 128];  % Match training input size

% === Generate signal ===
switch mod_type
    case 'ASK'
        [sig, ~] = askMModulate(input_bits, Fs, f_c, T, M);
    case 'FSK'
        [sig, ~] = fskMModulate(input_bits, Fs, f_c, T, M);
    case 'PSK'
        [sig, ~] = pskMModulate(input_bits, Fs, f_c, T, M);
    case 'QAM'
        [sig, ~] = qamMModulate(input_bits, Fs, f_c, T, M);
    case 'Chirp'
        [sig, ~] = chirpModulate(input_bits, Fs, T, M);
    case 'DPSK'
        [sig, ~] = dpskMModulate(input_bits, Fs, f_c, T, M);
    otherwise
        error('Unsupported modulation type: %s', mod_type);
end

% === Truncate or pad ===
if length(sig) > desired_signal_len
    sig = sig(1:desired_signal_len);
elseif length(sig) < desired_signal_len
    sig = [sig, zeros(1, desired_signal_len - length(sig))];
end

% === Generate spectrogram ===
[~, ~, ~, ps] = spectrogram(sig, 256, 200, 256, Fs);
spec_img = imresize(10 * log10(abs(ps) + eps), image_size);
spec_img = mat2gray(spec_img);  % Normalize [0,1]

% === Reshape for prediction ===
img_input = reshape(single(spec_img), [image_size, 1]);

% === Classify ===
predicted_label = classify(trainedNet, img_input, 'ExecutionEnvironment', 'gpu');

% === Display ===
fprintf("📡 True: %s_%d\n", mod_type, M);
fprintf("🤖 Predicted: %s\n", string(predicted_label));

figure;
imshow(spec_img, []);
title(sprintf("True: %s_%d | Predicted: %s", mod_type, M, string(predicted_label)));
