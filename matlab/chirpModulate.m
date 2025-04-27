function [s_t, t] = chirpModulate(input_bits, Fs, T, M)
    % Chirp Spread Spectrum (CSS) Modulation
    % input_bits : binary sequence
    % Fs         : sampling frequency
    % T          : total signal time (sec)
    % M          : number of chirp levels (e.g., 2^n)

    if log2(M) ~= floor(log2(M))
        error('M must be a power of 2.');
    end

    N = log2(M);
    pad_len = mod(-length(input_bits), N);
    input_bits = [input_bits, zeros(1, pad_len)];
    num_symbols = length(input_bits) / N;

    symbols = reshape(input_bits, N, []).';
    symbol_indices = bi2de(symbols, 'left-msb');

    total_samples = round(Fs * T);
    t = linspace(0, T, total_samples);
    samples_per_symbol = floor(total_samples / num_symbols);

    s_t = zeros(1, total_samples);

    for i = 1:num_symbols
        f0 = symbol_indices(i) / M;  % starting frequency normalized (0 to 1)
        idx_start = (i - 1) * samples_per_symbol + 1;
        idx_end = min(i * samples_per_symbol, total_samples);
        t_sym = linspace(0, 1, idx_end - idx_start + 1);  % normalized symbol time

        % Linear chirp from f0 to f0+1 (wraps around in digital systems)
        phase = 2 * pi * (f0 * t_sym + 0.5 * t_sym.^2);
        s_t(idx_start:idx_end) = cos(phase);
    end
end
