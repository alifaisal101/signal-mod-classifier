% Common parameters
input_bits = randi([0 1], 1, 1000);
M = 32;
Fs = 20000;
symbol_rate = 1000;
N = log2(M);
num_symbols = ceil(length(input_bits) / N);
symbol_duration = 1 / symbol_rate;
T = num_symbols * symbol_duration;
f_c = 2000;
f_base = 2000;
freq_range = 3000;
SNR_values = [10, 8, 5];
BT = 0.3;

% Generate signals
[ask, t] = askMModulate(input_bits, Fs, f_c, T, M);
[fsk, ~] = fskMModulate(input_bits, Fs, f_base, T, M);
[psk, ~] = pskMModulate(input_bits, Fs, f_c, T, M);
[qam, ~] = qamMModulate(input_bits, Fs, f_c, T, M);
[chirp, ~] = chirpModulate(input_bits, Fs, T, M);
[gmsk, ~] = gmskModulate(input_bits, Fs, BT, symbol_rate);
[dpsk, ~] = dpskMModulate(input_bits, Fs, f_c, T, M);

% Modulation setup
mod_names = {'ASK', 'FSK', 'PSK', 'QAM', 'Chirp', 'DQPSK'};
mod_signals = {ask, fsk, psk, qam, chirp, dpsk};
mod_colors = {'b', 'r', 'g', 'm', 'c', 'y'};

% Add noise
noisy_signals = cell(length(mod_signals), length(SNR_values));
for i = 1:length(mod_signals)
    for j = 1:length(SNR_values)
        noisy_signals{i, j} = awgn(mod_signals{i}, SNR_values(j), 'measured');
    end
end

% Plotting
figure;
set(gcf, 'Color', 'w');

for i = 1:length(mod_signals)
    % Clean version
    subplot(length(mod_signals), 4, (i-1)*4+1);
    plot(t, mod_signals{i}, mod_colors{i}, 'LineWidth', 1.5);
    title([mod_names{i} ' (Clean)']);
    xlim([0 0.03]); grid on;
    set(gca, 'Color', 'k');

    for j = 1:length(SNR_values)
        subplot(length(mod_signals), 4, (i-1)*4+1+j);
        plot(t, noisy_signals{i, j}, mod_colors{i}, 'LineWidth', 1.5);
        title(sprintf('%s + AWGN (%d dB)', mod_names{i}, SNR_values(j)));
        xlim([0 0.03]); grid on;
        set(gca, 'Color', 'k');
    end
end

xlabel('Time (s)');
