function [s_t, t] = askMModulate(input_bits, Fs, f_c, T, M)
    % M-ary ASK Modulation
    % input_bits : array of 0s and 1s
    % Fs : sampling frequency (samples per second)
    % f_c : carrier frequency (Hz)
    % T : total duration of signal (seconds)
    % M : number of amplitude levels (e.g. 2, 4, 8, 16, ...)

    if log2(M) ~= floor(log2(M))
        error('M must be a power of 2.');
    end

    N = log2(M);  % bits per symbol
    num_bits = length(input_bits);
    pad_len = mod(-num_bits, N);
    input_bits = [input_bits, zeros(1, pad_len)];
    num_symbols = length(input_bits) / N;

    % Convert bit groups into symbol indices
    symbols = reshape(input_bits, N, []).';
    symbol_indices = bi2de(symbols, 'left-msb');

    % Map symbol index to amplitude (e.g., 0.2 to 1.0)
    amplitudes = linspace(0.2, 1.0, M);
    symbol_amps = amplitudes(symbol_indices + 1);  % MATLAB index starts at 1

    % Time setup
    total_samples = round(T * Fs);
    t = linspace(0, T, total_samples);
    samples_per_symbol = floor(total_samples / num_symbols);

    % Modulate signal
    s_t = zeros(1, total_samples);
    for i = 1:num_symbols
        start_idx = (i - 1) * samples_per_symbol + 1;
        end_idx = min(i * samples_per_symbol, total_samples);
        s_t(start_idx:end_idx) = symbol_amps(i) * cos(2 * pi * f_c * t(start_idx:end_idx));
    end
end
