clc;
clear;

fprintf("🔍 Full Evaluation on All Modulation+M Combinations\n");

% === Load model ===
load('trainedSimpleCNN_Spectrogram.mat', 'trainedNet');

% === Params ===
mod_names = {'ASK', 'FSK', 'PSK', 'QAM', 'Chirp', 'DPSK'};
M_values = [2, 4, 8, 16, 32, 64];
Fs = 20000;
symbol_rate = 1000;
f_c = 2000;
desired_signal_len = 8000;
image_size = [128 128];
input_bits = randi([0 1], 1, 1000);

% === Storage ===
results = [];

for m_idx = 1:length(M_values)
    M = M_values(m_idx);
    N = log2(M);
    num_symbols = ceil(length(input_bits) / N);
    T = num_symbols / symbol_rate;

    for mod_idx = 1:length(mod_names)
        mod_type = mod_names{mod_idx};
        true_label = sprintf('%s_%d', mod_type, M);

        % === Generate signal ===
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
                case 'DPSK'
                    [sig, ~] = dpskMModulate(input_bits, Fs, f_c, T, M);
            end
        catch
            warning("⚠️ Failed to generate %s_%d", mod_type, M);
            continue;
        end

        % === Fix length ===
        if length(sig) > desired_signal_len
            sig = sig(1:desired_signal_len);
        elseif length(sig) < desired_signal_len
            sig = [sig, zeros(1, desired_signal_len - length(sig))];
        end

        % === Spectrogram ===
        [~, ~, ~, ps] = spectrogram(sig, 256, 200, 256, Fs);
        spec_img = imresize(10 * log10(abs(ps) + eps), image_size);
        spec_img = mat2gray(spec_img);

        img_input = reshape(single(spec_img), [image_size, 1]);
        predicted_label = classify(trainedNet, img_input, 'ExecutionEnvironment', 'gpu');
        [predications] = predict(trainedNet, img_input);

        % === Store ===
        results = [results; {true_label, string(predicted_label)}];
        fprintf("✅ %s → %s\n", true_label, string(predicted_label));
    end
end

% === Summary ===
fprintf("\n📊 Evaluation Summary:\n");
num_correct = sum(strcmp(results(:,1), results(:,2)));
accuracy = num_correct / size(results,1) * 100;
fprintf("✅ Accuracy: %.2f%% (%d / %d)\n", accuracy, num_correct, size(results,1));

fprintf("\n❌ Misclassifications:\n");
wrong = results(~strcmp(results(:,1), results(:,2)), :);
disp(wrong);
