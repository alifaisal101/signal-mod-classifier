clc;
clear;

fprintf("Generating spectrogram-based modulation dataset (with multiple SNRs)...\n");

num_samples_per_mod_M = 1000;
Fs = 20000;
symbol_rate = 1000;
f_c = 2000;
desired_signal_len = 8000;
image_size = [128 128];
SNR_values = [Inf, 10, 8, 5];

mod_config = {
    'ASK',     [2, 4, 8, 16, 32, 64];
    'FSK',     [2, 4, 8, 16, 32, 64];
    'PSK',     [2, 4, 8, 16, 32, 64];
    'QAM',     [4, 16, 32, 64];
    'Chirp',   [2, 4, 8, 16, 32, 64];
    'DQPSK',   [4]
};

total_samples = 0;
for i = 1:size(mod_config, 1)
    total_samples = total_samples + numel(mod_config{i,2}) * num_samples_per_mod_M * numel(SNR_values);
end

spectrograms = zeros([image_size, 1, total_samples], 'single');
labels = strings(total_samples, 1);
idx = 1;

for i = 1:size(mod_config, 1)
    mod_type = mod_config{i, 1};
    M_list = mod_config{i, 2};

    for M = M_list
        base_label = sprintf('%s_%d', mod_type, M);

        for snrVal = SNR_values
            fprintf("📡 Generating %s at SNR = %s (%d samples)\n", base_label, num2str(snrVal), num_samples_per_mod_M);

            N = log2(M);

            for sample = 1:num_samples_per_mod_M
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
                            error('Unknown modulation type: %s', mod_type);
                    end

                    if ~isinf(snrVal)
                        sig = awgn(sig, snrVal, 'measured');
                    end
                catch ME
                    warning("Skipped %s sample due to error: %s", base_label, ME.message);
                    continue;
                end

                if length(sig) > desired_signal_len
                    sig = sig(1:desired_signal_len);
                elseif length(sig) < desired_signal_len
                    sig = [sig, zeros(1, desired_signal_len - length(sig))];
                end

                [~, ~, ~, ps] = spectrogram(sig, 256, 200, 256, Fs);
                spec_img = imresize(10 * log10(abs(ps) + eps), image_size);
                spec_img = mat2gray(spec_img);  % Normalize

                spectrograms(:, :, 1, idx) = single(spec_img);
                labels(idx) = base_label;  % label WITHOUT SNR info
                idx = idx + 1;
            end
        end
    end
end

spectrograms = spectrograms(:, :, :, 1:idx-1);
labels = labels(1:idx-1);

fprintf("Total samples generated: %d\n", idx-1);
fprintf("Saving to 'spectrogram_modulation_dataset_multiSNR.mat'...\n");
save('spectrogram_modulation_dataset_multiSNR.mat', 'spectrograms', 'labels', '-v7.3');
fprintf("Dataset ready!\n");
