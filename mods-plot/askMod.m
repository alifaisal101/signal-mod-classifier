% Parameters
Fs = 1000;              % Sampling frequency (Hz)
f_c = 50;               % Carrier frequency (Hz)
T = 1;                  % Duration of the signal (seconds)
t = 0:1/Fs:T-1/Fs;     % Time vector

% Generate a random binary input signal
num_bits = 10;          % Number of bits
input_bits = randi([0 1], 1, num_bits); % Random binary sequence
bit_duration = T / num_bits;             % Duration of each bit

% Create the amplitude function
A = zeros(1, length(t)); % Initialize amplitude array
for i = 1:num_bits
    start_idx = round((i-1) * bit_duration * Fs) + 1;
    end_idx = round(i * bit_duration * Fs);
    A(start_idx:end_idx) = input_bits(i);
end

% Generate the modulated signal
A_modulated = A * 0.5 + 0.5; % Scale amplitudes (0.5 for '0', 1.0 for '1')
s_t = A_modulated .* cos(2 * pi * f_c * t); % ASK modulated signal

% Create time vector for input digital signal
t_input = linspace(0, T, num_bits + 1); % Time vector for the input bits

% Plotting
figure;

% Plot input digital signal
subplot(2, 1, 1);
stem(t_input, [input_bits 0], 'o-', 'LineWidth', 2); % Use plot with correct lengths
title('Input Digital Signal');
xlabel('Time (s)');
ylabel('Amplitude');
xlim([0 T]);
ylim([-0.5 1.5]);
grid on;

% Plot modulated signal
subplot(2, 1, 2);
plot(t, s_t, 'LineWidth', 2);
title('ASK Modulated Signal');
xlabel('Time (s)');
ylabel('Amplitude');
xlim([0 T]);
grid on;

