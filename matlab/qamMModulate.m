function [s_t, t] = qamMModulate(input_bits, Fs, f_c, T, M)
    if log2(M) ~= floor(log2(M))
        error('M must be a power of 2.');
    end

    N = log2(M);
    pad_len = mod(-length(input_bits), N);
    input_bits = [input_bits, zeros(1, pad_len)];
    num_symbols = length(input_bits) / N;

    symbols = reshape(input_bits, N, []).';
    symbol_indices = bi2de(symbols, 'left-msb');

    % Generate custom QAM constellation using polar coordinates:
    % Multiple rings with different amplitudes and phases
    num_rings = ceil(sqrt(M) / 2);   % e.g., for M=32 ? 4 rings
    points_per_ring = ceil(M / num_rings);
    constellation = [];

    ring_amps = linspace(0.5, 1.5, num_rings);  % Amplitudes for rings

    sym_count = 0;
    for r = 1:num_rings
        amp = ring_amps(r);
        phase_angles = linspace(0, 2*pi, points_per_ring + 1);
        phase_angles(end) = [];  % remove duplicate at 2?
        ring_points = amp * exp(1i * phase_angles);
        constellation = [constellation; ring_points(:)];
        sym_count = sym_count + numel(ring_points);
        if sym_count >= M
            break;
        end
    end

    constellation = constellation(1:M);  % trim to exact M symbols

    % Map input bits to complex symbols
    mapped = constellation(symbol_indices + 1);

    total_samples = round(Fs * T);
    t = linspace(0, T, total_samples);
    samples_per_symbol = floor(total_samples / num_symbols);

    s_t = zeros(1, total_samples);
    for i = 1:num_symbols
        idx_start = (i - 1) * samples_per_symbol + 1;
        idx_end = min(i * samples_per_symbol, total_samples);
        carrier = exp(1i * 2 * pi * f_c * t(idx_start:idx_end));
        s_t(idx_start:idx_end) = real(mapped(i) * carrier);
    end
end
