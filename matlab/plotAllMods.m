% Define Parameters
Fs = 1000;              % Sampling frequency (Hz)
f_c = 50;               % Carrier frequency (Hz)
T = 1;                  % Duration of the signal (seconds)
num_bits = 20;          % Number of bits
input_bits = randi([0 1], 1, num_bits); % Random binary sequence

% Call the askModFunc function to get the modulated signal (ASK)
s_t_ask = askModFunc(input_bits, Fs, f_c, T);

% Call the bpskModFunc function to get the modulated signal (BPSK)
Tb = 1; % Bit duration for BPSK (same as T for simplicity)
s_t_bpsk = bpskModFunc(input_bits, Fs, Tb);

s_t_qpsk = qpskModFunc(input_bits, Fs, T);

% FSK Parameters
f0 = 20;               % Frequency for bit 0 (Hz)
f1 = 100;              % Frequency for bit 1 (Hz)

% Call the fskModFunc function to get the modulated signal (FSK)
s_t_fsk = fskModFunc(input_bits, Fs, T, f0, f1);

% Add noise to the signals (you can change the SNR value)
snr_dB = 0;  % Signal-to-Noise Ratio (dB)

s_t_ask_noisy = awgn(s_t_ask, snr_dB, 'measured');
s_t_bpsk_noisy = awgn(s_t_bpsk, snr_dB, 'measured');
s_t_qpsk_noisy = awgn(s_t_qpsk, snr_dB, 'measured');
s_t_fsk_noisy = awgn(s_t_fsk, snr_dB, 'measured');

% Create time vector for plotting (shared time vector)
t = 0:1/Fs:T-1/Fs;

% Plotting the results
figure;

% Plot the Input Digital Signal
subplot(5, 2, 1);
stem(linspace(0, T, num_bits), input_bits, 'o-', 'LineWidth', 2);
title('Input Digital Signal');
xlabel('Time (s)');
ylabel('Amplitude');
xlim([0 T]);
ylim([-0.5 1.5]);
grid on;

% Plot the ASK Modulated Signal
subplot(5, 2, 2);
plot(t, s_t_ask, 'LineWidth', 2);
title('ASK Modulated Signal');
xlabel('Time (s)');
ylabel('Amplitude');
xlim([0 T]);
grid on;

% Plot the Noisy ASK Modulated Signal
subplot(5, 2, 3);
plot(t, s_t_ask_noisy, 'LineWidth', 2);
title('Noisy ASK Modulated Signal');
xlabel('Time (s)');
ylabel('Amplitude');
xlim([0 T]);
grid on;

% Plot the BPSK Modulated Signal
subplot(5, 2, 4);
plot(t, s_t_bpsk, 'LineWidth', 2);
title('BPSK Modulated Signal');
xlabel('Time (s)');
ylabel('Amplitude');
xlim([0 T]);
grid on;

% Plot the Noisy BPSK Modulated Signal
subplot(5, 2, 5);
plot(t, s_t_bpsk_noisy, 'LineWidth', 2);
title('Noisy BPSK Modulated Signal');
xlabel('Time (s)');
ylabel('Amplitude');
xlim([0 T]);
grid on;

% Plot the QPSK Modulated Signal
subplot(5, 2, 6);
plot(t, s_t_qpsk, 'LineWidth', 2);
title('QPSK Modulated Signal');
xlabel('Time (s)');
ylabel('Amplitude');
xlim([0 T]);
grid on;

% Plot the Noisy QPSK Modulated Signal
subplot(5, 2, 7);
plot(t, s_t_qpsk_noisy, 'LineWidth', 2);
title('Noisy QPSK Modulated Signal');
xlabel('Time (s)');
ylabel('Amplitude');
xlim([0 T]);
grid on;

% Plot the FSK Modulated Signal
subplot(5, 2, 8);
plot(t, s_t_fsk, 'LineWidth', 2);
title('FSK Modulated Signal');
xlabel('Time (s)');
ylabel('Amplitude');
xlim([0 T]);
grid on;

% Plot the Noisy FSK Modulated Signal
subplot(5, 2, 9);
plot(t, s_t_fsk_noisy, 'LineWidth', 2);
title('Noisy FSK Modulated Signal');
xlabel('Time (s)');
ylabel('Amplitude');
xlim([0 T]);
grid on;

% Feature extraction for the ASK signal (you can do this for other signals too)
features_ask = featureExtraction(s_t_ask, Fs, T);
features_bpsk = featureExtraction(s_t_bpsk, Fs, T);
features_qpsk = featureExtraction(s_t_qpsk, Fs, T);
features_fsk = featureExtraction(s_t_fsk, Fs, T);

% Display the extracted features (for ASK as an example)
disp('Features for ASK Modulated Signal:');
disp(features_ask);