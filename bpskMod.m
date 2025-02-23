% BPSK Modulation Example

% Parameters
Fs = 1000;             % Sampling frequency (Hz)
Tb = 1;                % Bit duration (s)
t = 0:1/Fs:Tb-1/Fs;    % Time vector for one bit duration

% Binary sequence (example: 0, 1, 0, 1)
binarySequence = [0 1 0 1]; 

% Initialize modulated signal
modulatedSignal = [];
currentPhase = 0; % Start with phase 0

% BPSK modulation
for bit = binarySequence
    if bit == 1
        % If the bit is 1, maintain current phase
        modulatedSignal = [modulatedSignal cos(2 * pi * t / Tb + currentPhase)];
    else
        % If the bit is 0, change phase by 180 degrees
        currentPhase = currentPhase + pi;
        modulatedSignal = [modulatedSignal cos(2 * pi * t / Tb + currentPhase)];
    end
end

% Time vector for the entire modulated signal
timeVector = 0:1/Fs:(length(binarySequence) * Tb) - 1/Fs; 

% Plotting the results
figure;
subplot(2,1,1);
stairs((0:length(binarySequence)-1)*Tb, binarySequence, 'r', 'LineWidth', 2);
title('Binary Sequence');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

subplot(2,1,2);
plot(timeVector, modulatedSignal);
title('BPSK Modulated Signal');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

% Set axis limits
xlim([0 (length(binarySequence) * Tb)]);
