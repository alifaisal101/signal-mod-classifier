function [s_t, t] = pskMModulate(input_bits, Fs, f_c, T, M)
    if log2(M) ~= floor(log2(M))
        error('M must be a power of 2.');
    end

    N = log2(M);
    pad_len = mod(-length(input_bits), N);
    input_bits = [input_bits, zeros(1, pad_len)];
    num_symbols = length(input_bits) / N;

    symbols = reshape(input_bits, N, []).';
    symbol_indices = bi2de(symbols, 'left-msb');

    % Phase mapping (0 to 2pi)
    phases = linspace(0, 2*pi, M+1);
    symbol_phases = phases(symbol_indices + 1);

    total_samples = round(Fs * T);
    t = linspace(0, T, total_samples);
    samples_per_symbol = floor(total_samples / num_symbols);

    s_t = zeros(1, total_samples);
    for i = 1:num_symbols
        idx_start = (i - 1) * samples_per_symbol + 1;
        idx_end = min(i * samples_per_symbol, total_samples);
        s_t(idx_start:idx_end) = cos(2 * pi * f_c * t(idx_start:idx_end) + symbol_phases(i));
    end
end
