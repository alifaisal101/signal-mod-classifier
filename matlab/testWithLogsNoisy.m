clc;
clear;

fprintf("🔍 Testing spectrogram-based modulation classifier with noise and prediction probabilities...\n");

% Load trained model
load('trainedSimpleCNN_Spectrogram.mat', 'trainedNet');

% === Parameters ===
mod_names = {'ASK', 'FSK', 'PSK', 'QAM', 'Chirp', 'DQPSK'};
M_values = [2, 4, 8, 16, 32, 64];
Fs = 20000;
symbol_rate = 1000;
f_c = 2000;
SNR_dB = 20;  % Additive White Gaussian Noise SNR
desired_len = 8000;
image_size = [128 128];

% Initialize result storage
results = {};

for m_idx = 1:length(M_values)
    M = M_values(m_idx);
    N = log2(M);

    for mod_idx = 1:length(mod_names)
        mod_type = mod_names{mod_idx};
        full_label = sprintf('%s_%d', mod_type, M);

        % Generate signal
        input_bits = randi([0 1], 1, 1000);
        num_symbols = ceil(length(input_bits) / N);
        T = num_symbols / symbol_rate;

        try
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
                case 'DQPSK'
                    [sig, ~] = dpskMModulate(input_bits, Fs, f_c, T, M);
                otherwise
                    error('Unknown modulation');
            end
        catch ME
            warning("⚠️ Failed to generate %s: %s", full_label, ME.message);
            continue;
        end

        % Add noise
        sig_noisy = awgn(sig, SNR_dB, 'measured');

        % Normalize length
        if length(sig_noisy) > desired_len
            sig_noisy = sig_noisy(1:desired_len);
        else
            sig_noisy = [sig_noisy, zeros(1, desired_len - length(sig_noisy))];
        end

        % Spectrogram
        [~, ~, ~, ps] = spectrogram(sig_noisy, 256, 200, 256, Fs);
        spec_img = imresize(10 * log10(abs(ps) + eps), image_size);
        spec_img = mat2gray(spec_img);

        % Predict
        img_input = reshape(single(spec_img), [image_size 1]);

        % Get raw network outputs (logits)
        layer_outputs = trainedNet.predict(img_input);  % Get raw network outputs
        probs = softmax(layer_outputs);  % Apply softmax to get probabilities

        % Apply threshold to ignore very small values (probabilities < 0.1%)
        probs(probs < 0.001) = 0;

        % Sort probabilities in descending order
        [sorted_probs, idx_sorted] = sort(probs, 'descend');
        
        % Get the top 3 predictions
        top3_labels = trainedNet.Layers(end).ClassNames(idx_sorted(1:3));
        top3_scores = sorted_probs(1:3) * 100;

        % Debugging: Output the predictions and scores
        fprintf("Predictions for %s:\n", full_label);
        fprintf("1st Prediction: %s with %.2f%%\n", top3_labels{1}, top3_scores(1));
        fprintf("2nd Prediction: %s with %.2f%%\n", top3_labels{2}, top3_scores(2));
        fprintf("3rd Prediction: %s with %.2f%%\n", top3_labels{3}, top3_scores(3));

        % Check if the top prediction is correct
        correct = strcmp(top3_labels{1}, full_label);
        mark = "✅"; if ~correct, mark = "❌"; end

        % Store the result
        results{end+1, 1} = mark;
        results{end, 2} = full_label;
        results{end, 3} = top3_labels{1};
        results{end, 4} = sprintf('%.2f%%', top3_scores(1));
        results{end, 5} = top3_labels{2};
        results{end, 6} = sprintf('%.2f%%', top3_scores(2));
        results{end, 7} = top3_labels{3};
        results{end, 8} = sprintf('%.2f%%', top3_scores(3));
    end
end

% Convert results to a table for better readability
result_table = cell2table(results, 'VariableNames', {'Status', 'Modulation', 'Prediction', '1st Prediction (%)', '2nd Prediction', '2nd Prediction (%)', '3rd Prediction', '3rd Prediction (%)'});

% Display the results in a clear table format
disp(result_table);
