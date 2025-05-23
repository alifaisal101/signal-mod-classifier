clc;
clear;

fprintf("📊 Full Evaluation on Valid Modulation + M Combinations\n");

% === Load model ===
load('trainedSimpleCNN_SpectrogramSNR.mat', 'trainedNet');

% === Parameters ===
Fs = 20000;
symbol_rate = 1000;
f_c = 2000;
desired_signal_len = 8000;
image_size = [128 128];
input_bits = randi([0 1], 1, 1000);

% === Modulation types and valid M values ===
mod_config = {
    'ASK',     [2, 4, 8, 16, 32, 64];
    'FSK',     [2, 4, 8, 16, 32, 64];
    'PSK',     [2, 4, 8, 16, 32, 64];
    'QAM',     [4, 16, 32, 64];  % Removed QAM_2
    'Chirp',   [2, 4, 8, 16, 32, 64];
    'DQPSK',   [4]
};

% === Results storage ===
results = {};

% === Loop through each modulation and its valid M values ===
for i = 1:size(mod_config, 1)
    mod_type = mod_config{i, 1};
    M_list = mod_config{i, 2};

    for m_idx = 1:length(M_list)
        M = M_list(m_idx);
        N = log2(M);
        num_symbols = ceil(length(input_bits) / N);
        T = num_symbols / symbol_rate;
        true_label = sprintf('%s_%d', mod_type, M);

        try
            % Generate signal
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
                    error("Unknown modulation: %s", mod_type);
            end

            % Add AWGN
            sig = awgn(sig, 5, 'measured');

        catch
            warning("⚠️ Failed to generate %s_%d", mod_type, M);
            continue;
        end

        % Pad or truncate
        if length(sig) > desired_signal_len
            sig = sig(1:desired_signal_len);
        elseif length(sig) < desired_signal_len
            sig = [sig, zeros(1, desired_signal_len - length(sig))];
        end

        % === Spectrogram ===
        [~, ~, ~, ps] = spectrogram(sig, 256, 200, 256, Fs);
        spec_img = imresize(10 * log10(abs(ps) + eps), image_size);
        spec_img = mat2gray(spec_img);  % Normalize to [0,1]
        img_input = reshape(single(spec_img), [image_size, 1]);

        % === Predict ===
        probs = predict(trainedNet, img_input);
        class_labels = trainedNet.Layers(end).Classes;
        [sorted_probs, idx] = sort(probs, 'descend');

        top1_label = class_labels(idx(1));
        top2_label = class_labels(idx(2));
        top3_label = class_labels(idx(3));
        is_correct = strcmp(string(top1_label), true_label);
        status = "✅";
        if ~is_correct
            status = "❌";
        end

        % === Store result ===
        results(end+1, :) = {
            status, ...
            true_label, ...
            string(top1_label), ...
            sprintf('%.2f%%', sorted_probs(1) * 100), ...
            string(top2_label), ...
            sprintf('%.2f%%', sorted_probs(2) * 100), ...
            string(top3_label), ...
            sprintf('%.2f%%', sorted_probs(3) * 100)
        };

        fprintf("%s %s → %s (%.2f%%)\n", status, true_label, top1_label, sorted_probs(1) * 100);
    end
end

% === Table ===
results_table = cell2table(results, ...
    'VariableNames', {'Status', 'TrueLabel', 'Prediction', ...
    'Top1Prob', 'Top2', 'Top2Prob', 'Top3', 'Top3Prob'});

fprintf("\n📋 Final Results Table:\n");
disp(results_table);

% === Accuracy Summary ===
correct_count = sum(strcmp(results_table.TrueLabel, results_table.Prediction));
total_count = size(results_table, 1);
accuracy = correct_count / total_count * 100;
fprintf("✅ Overall Accuracy: %.2f%% (%d / %d)\n", accuracy, correct_count, total_count);

% === Misclassifications ===
fprintf("\n❌ Misclassifications:\n");
misclassified = results_table(~strcmp(results_table.TrueLabel, results_table.Prediction), :);
disp(misclassified);
