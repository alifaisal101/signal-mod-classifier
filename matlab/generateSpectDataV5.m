clc;
clear;

fprintf("🚀 Generating extended spectrogram-based modulation dataset...\n");

% === Parameters ===
num_samples_per_mod_M = 5000;  % Per M per SNR — will multiply fast
desired_signal_len = 8000;
image_size = [128 128];
SNR_values = [Inf, 10, 8, 5, 3];

% === Modulation Config ===
mod_config = {
    'ASK',     [2, 4, 8, 16, 32, 64];
    'FSK',     [2, 4, 8, 16, 32, 64];
    'PSK',     [2, 4, 8, 16, 32, 64];
    'QAM',     [4, 16, 32, 64];
    'Chirp',   [2, 4, 8, 16, 32, 64];
    'DQPSK',   [4]
};

output_base = 'generated_spectrogram_datasets';
if ~exist(output_base, 'dir'), mkdir(output_base); end

for i = 1:size(mod_config, 1)
    mod_type = mod_config{i, 1};
    M_list = mod_config{i, 2};

    for M = M_list
        for snr_val = SNR_values

            if isinf(snr_val)
                label_suffix = 'Clean';
            else
                label_suffix = sprintf('%ddB', snr_val);
            end

            fprintf("🎧 Generating %s M=%d SNR=%s (%d samples)\n", mod_type, M, label_suffix, num_samples_per_mod_M);
            
            % Preallocate
            spectrograms = zeros([image_size, 1, num_samples_per_mod_M], 'single');
            labels = strings(num_samples_per_mod_M, 1);
            idx = 1;

            for sample = 1:num_samples_per_mod_M
                % === Random parameters ===
                input_len = randi([500, 2500]);
                input_bits = randi([0 1], 1, input_len);
                Fs = randi([20000, 40000]);
                f_c = randi([1000, 10000]);
                symbol_rate = randi([500, 4000]);

                N = log2(M);
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

                    if ~isinf(snr_val)
                        sig = awgn(sig, snr_val, 'measured');
                    end

                catch ME
                    warning("⚠️ Skipping sample %d due to error: %s", sample, ME.message);
                    continue;
                end

                % Adjust signal length
                sig = pad_or_truncate(sig, desired_signal_len);

                % Spectrogram
                [~, ~, ~, ps] = spectrogram(sig, 256, 200, 256, Fs);
                spec_img = imresize(10 * log10(abs(ps) + eps), image_size);
                spec_img = mat2gray(spec_img);

                spectrograms(:, :, 1, idx) = single(spec_img);
                labels(idx) = sprintf('%s_%d_%s', mod_type, M, label_suffix);
                idx = idx + 1;
            end

            % Trim any skipped samples
            spectrograms = spectrograms(:, :, :, 1:idx-1);
            labels = labels(1:idx-1);

            % Save to file
            out_name = sprintf('%s_M%d_SNR%s.mat', mod_type, M, label_suffix);
            out_path = fullfile(output_base, out_name);
            save(out_path, 'spectrograms', 'labels', '-v7.3');
            fprintf("💾 Saved %s\n", out_name);
        end
    end
end

fprintf("✅ Dataset generation complete.\n");

% === Helper ===
function padded = pad_or_truncate(sig, target_len)
    if length(sig) > target_len
        padded = sig(1:target_len);
    else
        padded = [sig, zeros(1, target_len - length(sig))];
    end
end
