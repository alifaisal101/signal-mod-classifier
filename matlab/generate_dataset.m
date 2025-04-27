% === Parameters ===
num_samples_per_class = 5000;
mod_names = {'ASK', 'FSK', 'PSK', 'QAM', 'Chirp', 'DQPSK'};  % Removed GMSK
M_values = [2, 4, 8, 16, 32, 64, 128, 256];                  % Vary modulation order
SNR_range = [0, 20];                                         % SNR range in dB
symbol_rate_range = [500, 2000];                             % Symbols per second
Fs_range = [10000, 40000];                                   % Sampling frequency range
f_c_range = [1000, 5000];                                    % Carrier frequency

% === Preallocate (use cell if length varies)
total_samples = num_samples_per_class * length(mod_names);
signal_length = round(max(Fs_range) * (100 / min(symbol_rate_range)));  % worst case
all_signals = zeros(total_samples, signal_length);
all_labels = strings(total_samples, 1);

sample_idx = 1;
fprintf("Generating diverse dataset...\n");

for mod_i = 1:length(mod_names)
    mod_type = mod_names{mod_i};

    for sample = 1:num_samples_per_class
        % === Randomize parameters ===
        M = M_values(randi(length(M_values)));
        N = log2(M);
        symbol_rate = randi(symbol_rate_range);
        Fs = randi(Fs_range);
        f_c = randi(f_c_range);
        f_base = f_c; % Could be separate
        SNR_dB = rand * (SNR_range(2) - SNR_range(1)) + SNR_range(1);

        % === Random input bits ===
        input_bits = randi([0 1], 1, 10000);
        num_symbols = ceil(length(input_bits) / N);
        T = num_symbols / symbol_rate;

        % === Generate signal ===
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
                    error('Unknown modulation');
            end
        catch ME
            warning("Skipped sample %d for %s due to error: %s", sample, mod_type, ME.message);
            continue;
        end

        % === Normalize length ===
        if length(sig) > signal_length
            sig = sig(1:signal_length);
        elseif length(sig) < signal_length
            sig = [sig, zeros(1, signal_length - length(sig))];
        end

        % === Add noise ===
        sig_noisy = awgn(sig, SNR_dB, 'measured');

        % === Store data ===
        all_signals(sample_idx, :) = sig_noisy;
        all_labels(sample_idx) = mod_type;
        sample_idx = sample_idx + 1;
    end

    fprintf("? Done with %s\n", mod_type);
end

% === Trim unused rows if any samples were skipped ===
all_signals = all_signals(1:sample_idx-1, :);
all_labels = all_labels(1:sample_idx-1);

% === Save ===
save('diverse_modulation_dataset.mat', 'all_signals', 'all_labels', '-v7.3');
fprintf("? Dataset saved to 'diverse_modulation_dataset.mat'\n");
