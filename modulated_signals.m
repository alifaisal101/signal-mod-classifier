% Parameters
fs = 1000; % Sampling frequency
T = 1; % Duration of signal (1 second)
t = 0:1/fs:T-1/fs; % Time vector

% Message Signal (random binary)
msg = randi([0 1], 1, length(t)); % Random binary sequence

% 1. Amplitude Shift Keying (ASK)
ask_signal = msg .* cos(2*pi*100*t); % ASK with frequency 100Hz

% 2. Phase Shift Keying (PSK)
psk_signal = cos(2*pi*100*t + pi*msg); % PSK (BPSK)

% 3. Quadrature Phase Shift Keying (QPSK)
qpsk_signal = cos(2*pi*100*t + pi*mod(msg,2)) + 1i*sin(2*pi*100*t + pi*mod(msg+1,2));

% 4. Frequency Shift Keying (FSK)
fsk_signal = cos(2*pi*100*t + pi*msg); % BPSK approximation for FSK, can change frequencies for true FSK

% Plot signals
figure;
subplot(4, 1, 1); plot(t, ask_signal); title('ASK Signal');
subplot(4, 1, 2); plot(t, real(psk_signal)); title('PSK Signal');
subplot(4, 1, 3); plot(t, real(qpsk_signal)); title('QPSK Signal');
subplot(4, 1, 4); plot(t, fsk_signal); title('FSK Signal');
