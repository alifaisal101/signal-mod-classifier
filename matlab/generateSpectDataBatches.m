clc;
clear;

% Will generate many parts. Useful for very large datasets

fprintf("Generating stratified randomized spectrogram dataset parts...\n");

% === Config ===
image_size = [128 128];
desired_signal_len = 8000;
total_per_type = 10000;          % Each modulation-M-SNR type will have this many total
samples_per_part = 12000;        % Number of samples per part file
batch_size_range = [200, 600];   % Random batch size range

SNR_values = [Inf, 10, 8, 5, 3];
SNR_labels = ["Clean", "10dB", "8dB", "5dB", "3dB"];

mod_config = {
    'ASK',     [2, 4, 8, 16, 32, 64];
    'FSK',     [2, 4, 8, 16, 32, 64];
    'PSK',     [2, 4, 8, 16, 32, 64];
    'QAM',     [4, 16, 32, 64];
    'Chirp',   [2, 4, 8, 16, 32, 64];
    'DQPSK',   [4];
};

% === Build class table ===
% Table will help us keep track of how many samples are left to be generated
type_list = {};
for i = 1:size(mod_config, 1)
    mod_type = mod_config{i, 1};
    M_list = mod_config{i, 2};
    for M = M_list
        for s = 1:length(SNR_values)
            snr = SNR_values(s);
            snr_label = SNR_labels(s);
            key = sprintf('%s_%d_SNR%s', mod_type, M, snr_label);
            type_list{end+1, 1} = mod_type;
            type_list{end, 2} = M;
            type_list{end, 3} = snr;
            type_list{end, 4} = snr_label;
            type_list{end, 5} = total_per_type;  % remaining samples
            type_list{end, 6} = key;
        end
    end
end

output_base = 'stratified_dataset_parts';
if ~exist(output_base, 'dir'), mkdir(output_base); end

part_idx = 1;

while any(cell2mat(type_list(:, 5)) > 0)
    fprintf("Generating part %d...\n", part_idx);
    part_spectrograms = zeros([image_size, 1, samples_per_part], 'single');
    part_labels = strings(samples_per_part, 1);
    idx = 1;

    while idx <= samples_per_part && any(cell2mat(type_list(:, 5)) > 0)
        % Pick the type with the most remaining (but shuffle first to break ties randomly)
        shuffled = type_list(randperm(size(type_list,1)), :);
        [~, max_idx] = max(cell2mat(shuffled(:,5)));
        chosen = shuffled(max_idx, :);

        mod_type = chosen{1};
        M = chosen{2};
        snr_val = chosen{3};
        snr_label = chosen{4};
        remaining = chosen{5};
        label_key = chosen{6};

        % How many samples this round
        batch_size = randi(batch_size_range);
        if batch_size > remaining
            batch_size = remaining;
        end
        if idx + batch_size - 1 > samples_per_part
            batch_size = samples_per_part - idx + 1;
        end

        fprintf("   ➤ %s: generating %d samples...\n", label_key, batch_size);

        for b = 1:batch_size
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
                end

                if ~isinf(snr_val)
                    sig = awgn(sig, snr_val, 'measured');
                end

                sig = pad_or_truncate(sig, desired_signal_len);
                [~, ~, ~, ps] = spectrogram(sig, 256, 200, 256, Fs);
                spec_img = imresize(10 * log10(abs(ps) + eps), image_size);
                spec_img = mat2gray(spec_img);

                part_spectrograms(:, :, 1, idx) = single(spec_img);
                part_labels(idx) = label_key;
                idx = idx + 1;
            catch ME
                warning("Skipping sample due to error: %s", ME.message);
                continue;
            end
        end

        % Update master type list count
        row_idx = find(strcmp(type_list(:,6), label_key));
        type_list{row_idx, 5} = type_list{row_idx, 5} - batch_size;
    end

    % Save this part
    out_path = fullfile(output_base, sprintf('Part_%d_MixedStratified.mat', part_idx));
    save(out_path, 'part_spectrograms', 'part_labels', '-v7.3');
    fprintf("Saved part %d (%d samples)\n", part_idx, idx-1);
    part_idx = part_idx + 1;
end

fprintf("All parts generated with balanced representation.\n");

% === Padding Helper ===
function padded = pad_or_truncate(sig, target_len)
    if length(sig) > target_len
        padded = sig(1:target_len);
    else
        padded = [sig, zeros(1, target_len - length(sig))];
    end
end
