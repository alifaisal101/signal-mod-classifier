% Define Parameters
Fs = 1000;              % Sampling frequency (Hz)
f_c = 50;               % Carrier frequency (Hz)
T = 1;                  % Duration of the signal (seconds)
num_bits = 50;          % Number of bits
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

% Create time vector for plotting (shared time vector)
t = 0:1/Fs:T-1/Fs;

% Plotting the results
figure;

% Plot the Input Digital Signal
subplot(5, 1, 1);
stem(linspace(0, T, num_bits), input_bits, 'o-', 'LineWidth', 2);
title('Input Digital Signal');
xlabel('Time (s)');
ylabel('Amplitude');
xlim([0 T]);
ylim([-0.5 1.5]);
grid on;

% Plot the ASK Modulated Signal
subplot(5, 1, 2);
plot(t, s_t_ask, 'LineWidth', 2);
title('ASK Modulated Signal');
xlabel('Time (s)');
ylabel('Amplitude');
xlim([0 T]);
grid on;

% Plot the BPSK Modulated Signal
subplot(5, 1, 3);
plot(t, s_t_bpsk, 'LineWidth', 2);
title('BPSK Modulated Signal');
xlabel('Time (s)');
ylabel('Amplitude');
xlim([0 T]);
grid on;

subplot(5, 1, 4);
plot(t, s_t_qpsk, 'LineWidth', 2);
title('QPSK Modulated Signal');
xlabel('Time (s)');
ylabel('Amplitude');
xlim([0 T]);
grid on;

subplot(5, 1,5);
plot(t, s_t_fsk, 'LineWidth', 2);
title('FSK Modulated Signal');
xlabel('Time (s)');
ylabel('Amplitude');
xlim([0 T]);
grid on;
