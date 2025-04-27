function [s_t, t] = fskMModulate(input_bits, Fs, f_base, T, M)
    % M-ary FSK Modulation
    % input_bits : array of 0s and 1s
    % Fs         : sampling frequency (Hz)
    % f_base     : base frequency (Hz), FSK will offset from this
    % T          : total duration of signal (seconds)
    % M          : number of frequency levels (e.g. 2, 4, 8, 16, ...)
    
    if log2(M) ~= floor(log2(M))
        error('M must be a power of 2.');
    end

    N = log2(M);  % bits per symbol
    pad_len = mod(-length(input_bits), N);
    input_bits = [input_bits, zeros(1, pad_len)];
    num_symbols = length(input_bits) / N;

    % Convert bit groups into symbol indices
    symbols = reshape(input_bits, N, []).';
    symbol_indices = bi2de(symbols, 'left-msb');

    % Frequency mapping
    % For example, 2000 Hz ± 500 Hz range, equally spaced
    freq_range = 1000;  % total frequency swing
    freqs = linspace(f_base - freq_range/2, f_base + freq_range/2, M);
    symbol_freqs = freqs(symbol_indices + 1);

    % Time setup
    total_samples = round(T * Fs);
    t = linspace(0, T, total_samples);
    samples_per_symbol = floor(total_samples / num_symbols);

    % Modulate signal
    s_t = zeros(1, total_samples);
    for i = 1:num_symbols
        start_idx = (i - 1) * samples_per_symbol + 1;
        end_idx = min(i * samples_per_symbol, total_samples);
        s_t(start_idx:end_idx) = cos(2 * pi * symbol_freqs(i) * t(start_idx:end_idx));
    end
end
