clc;
clear;

fprintf("📦 Generating spectrogram-based modulation dataset...\n");

% === Parameters ===
num_samples_per_mod_M = 1000;
mod_names = {'ASK', 'FSK', 'PSK', 'QAM', 'Chirp', 'DPSK'};
M_values = [2, 4, 8, 16, 32, 64];  % Max M = 64
Fs = 20000;
symbol_rate = 1000;
f_c = 2000;
desired_signal_len = 8000;
image_size = [128 128];

% === Preallocate (cell for variable-length spectrograms)
total_classes = length(mod_names) * length(M_values);
total_samples = num_samples_per_mod_M * total_classes;

spectrograms = zeros([image_size, 1, total_samples], 'single');
labels = strings(total_samples, 1);

idx = 1;

for m_idx = 1:length(M_values)
    M = M_values(m_idx);
    N = log2(M);

    for mod_idx = 1:length(mod_names)
        mod_type = mod_names{mod_idx};
        full_label = sprintf('%s_%d', mod_type, M);
        fprintf("🔧 Generating %s (%d samples)\n", full_label, num_samples_per_mod_M);

        for sample = 1:num_samples_per_mod_M
            % === Input bits & Timing ===
            input_bits = randi([0 1], 1, 1000);
            num_symbols = ceil(length(input_bits) / N);
            T = num_symbols / symbol_rate;

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
                    otherwise
                        error('Unknown modulation');
                end
            catch ME
                warning("⚠️ Skipped sample due to error: %s", ME.message);
                continue;
            end

            % === Truncate or pad to fixed length ===
            if length(sig) > desired_signal_len
                sig = sig(1:desired_signal_len);
            elseif length(sig) < desired_signal_len
                sig = [sig, zeros(1, desired_signal_len - length(sig))];
            end

            % === Spectrogram ===
            [~, ~, ~, ps] = spectrogram(sig, 256, 200, 256, Fs);
            spec_img = imresize(10 * log10(abs(ps) + eps), image_size);
            spec_img = mat2gray(spec_img);  % Scale to [0,1]

            % === Store image and label ===
            spectrograms(:, :, 1, idx) = single(spec_img);
            labels(idx) = full_label;
            idx = idx + 1;
        end
    end
end

% === Trim if necessary ===
spectrograms = spectrograms(:, :, :, 1:idx-1);
labels = labels(1:idx-1);

fprintf("✅ Total samples: %d\n", idx-1);
fprintf("💾 Saving to 'spectrogram_modulation_dataset.mat'...\n");
save('spectrogram_modulation_dataset.mat', 'spectrograms', 'labels', '-v7.3');
fprintf("🎉 Dataset ready!\n");
