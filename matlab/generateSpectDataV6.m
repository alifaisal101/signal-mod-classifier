clc;
clear;

fprintf("🚀 Generating spectrogram-based modulation dataset in diverse mixed parts...\n");

% === Parameters ===
num_samples_per_part = 10000;  % Total samples per part (mixed modulation types & SNRs)
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

output_base = 'generated_spectrogram_datasets_parts';
if ~exist(output_base, 'dir'), mkdir(output_base); end

part_idx = 1;  % Initialize part index

% === Generate Mixed Data Parts ===
while part_idx <= 5  % Create a fixed number of parts, e.g., 5 parts (you can adjust this)
    
    fprintf("🎧 Generating Part %d with mixed modulation and SNR...\n", part_idx);
    
    % Preallocate for one part
    part_spectrograms = zeros([image_size, 1, num_samples_per_part], 'single');
    part_labels = strings(num_samples_per_part, 1);
    
    idx = 1;

    % Randomly select modulations and SNRs for each part
    for i = 1:size(mod_config, 1)
        mod_type = mod_config{i, 1};
        M_list = mod_config{i, 2};
        
        for M = M_list
            % Randomly select an SNR value for each sample
            snr_val = SNR_values(randi(length(SNR_values)));  % Random SNR
            if isinf(snr_val)
                snr_label = 'Clean';
            else
                snr_label = sprintf('%ddB', snr_val);
            end
            
            fprintf("   Generating data for %s M=%d SNR=%s (%d samples)\n", mod_type, M, snr_label, num_samples_per_part);

            % Generate samples for this combination
            for sample = 1:(num_samples_per_part / (length(mod_config) * length(M_list)))  % Distribute samples evenly
                % === Random signal parameters ===
                input_len = randi([500, 2500]);
                input_bits = randi([0 1], 1, input_len);
                Fs = randi([20000, 40000]);
                f_c = randi([1000, 10000]);
                symbol_rate = randi([500, 4000]);

                N = log2(M);
                num_symbols = ceil(length(input_bits) / N);
                T = num_symbols / symbol_rate;

                try
                    % Modulate signal based on type
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

                    % Add noise if SNR is not clean
                    if ~isinf(snr_val)
                        sig = awgn(sig, snr_val, 'measured');
                    end

                catch ME
                    warning("⚠️ Skipping sample %d due to error: %s", sample, ME.message);
                    continue;
                end

                % Adjust signal length
                sig = pad_or_truncate(sig, desired_signal_len);

                % Generate spectrogram
                [~, ~, ~, ps] = spectrogram(sig, 256, 200, 256, Fs);
                spec_img = imresize(10 * log10(abs(ps) + eps), image_size);
                spec_img = mat2gray(spec_img);

                % Store in part
                part_spectrograms(:, :, 1, idx) = single(spec_img);
                part_labels(idx) = sprintf('%s_%d_SNR%s', mod_type, M, snr_label);
                idx = idx + 1;
            end
        end
    end

    % Trim any skipped samples if needed
    part_spectrograms = part_spectrograms(:, :, :, 1:idx-1);
    part_labels = part_labels(1:idx-1);

    % Save each part as a .mat file
    out_name = sprintf('Part_%d_Mixed.mat', part_idx);
    out_path = fullfile(output_base, out_name);
    save(out_path, 'part_spectrograms', 'part_labels', '-v7.3');
    fprintf("💾 Saved part %d: %s\n", part_idx, out_name);

    part_idx = part_idx + 1;
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
