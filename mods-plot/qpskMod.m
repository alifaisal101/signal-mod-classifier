% Parameters
Fs = 100;           % Sampling frequency (Hz)
Tb = 1;             % Bit duration (s)
t = 0:1/Fs:Tb-1/Fs; % Time vector for one bit duration

% Binary sequence (example: 0, 0, 1, 1, 0, 1, 1, 0)
binarySequence = [0 0 1 1 0 1 1 0]; 

% Initialize modulated signal
modulatedSignal = [];

% QPSK modulation
for i = 1:2:length(binarySequence)-1
    % Combine two bits for QPSK (00, 01, 10, 11)
    bits = binarySequence(i:i+1);
    if isequal(bits, [0 0])
        modulatedSignal = [modulatedSignal cos(2 * pi * 1 * t)]; % Phase 0
    elseif isequal(bits, [0 1])
        modulatedSignal = [modulatedSignal cos(2 * pi * 1 * t + pi/2)]; % Phase 90 degrees
    elseif isequal(bits, [1 0])
        modulatedSignal = [modulatedSignal cos(2 * pi * 1 * t + pi);]; % Phase 180 degrees
    else
        modulatedSignal = [modulatedSignal cos(2 * pi * 1 * t + 3*pi/2)]; % Phase 270 degrees
    end
end

% Time vector for the entire modulated signal
timeVector = 0:1/Fs:(length(modulatedSignal) / Fs) - 1/Fs; 

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
title('QPSK Modulated Signal');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;
