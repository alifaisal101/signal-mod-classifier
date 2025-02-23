% Parameters
Fs = 100;           % Sampling frequency (Hz)
Tb = 1;             % Bit duration (s)
t = 0:1/Fs:Tb-1/Fs; % Time vector for one bit duration

% Binary sequence (example: 0, 1, 0, 1, 1, 0)
binarySequence = [0 1 0 1 1 0]; 

% Frequencies for FSK
f0 = 5;   % Frequency for bit 0 (Hz)
f1 = 15;  % Frequency for bit 1 (Hz)

% Initialize modulated signal
modulatedSignal = [];

% FSK modulation
for bit = binarySequence
    if bit == 1
        modulatedSignal = [modulatedSignal cos(2 * pi * f1 * t)];
    else
        modulatedSignal = [modulatedSignal cos(2 * pi * f0 * t)];
    end
end

% Time vector for the entire modulated signal
timeVector = 0:1/Fs:(length(binarySequence) * Tb) - 1/Fs; 

% Plotting with subplot
figure;

subplot(2,1,1);
stairs((0:length(binarySequence)-1), binarySequence, 'r', 'LineWidth', 2);
title('Binary Sequence');
xlabel('Sample Index');
ylabel('Value');
ylim([-0.5 1.5]);
grid on;

subplot(2,1,2);
plot(timeVector, modulatedSignal);
title('FSK Modulated Signal');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;
