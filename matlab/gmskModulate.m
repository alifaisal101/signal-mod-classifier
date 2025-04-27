function [s_t, t] = gmskModulate(input_bits, Fs, BT, symbol_rate)
    % BT: bandwidth-time product (e.g., 0.3)
    % symbol_rate: how many symbols per second

    N = 1;  % GMSK is binary
    input_bits = 2 * input_bits - 1;  % Convert to NRZ (+1/-1)

    samples_per_symbol = Fs / symbol_rate;
    T = length(input_bits) / symbol_rate;
    t = linspace(0, T, length(input_bits) * samples_per_symbol);  % Adjust time vector length

    % Gaussian filter
    span = 4;
    h = gaussdesign(BT, span, samples_per_symbol);

    % Apply Gaussian filter
    filtered = conv(repelem(input_bits, samples_per_symbol), h, 'same');

    % Integrate to get phase
    phase = 2 * pi * cumsum(filtered) / Fs;

    % Modulated signal
    s_t = cos(phase);
end
