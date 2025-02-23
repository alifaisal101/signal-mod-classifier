% BPSK Modulation Function (Modified)
function modulatedSignal = bpskModFunc(binarySequence, Fs, T)
    % BPSK Modulation Function
    %
    % Parameters:
    % binarySequence : Binary sequence to be modulated
    % Fs             : Sampling frequency (Hz)
    % T              : Total signal duration (seconds)
    
    % Number of bits in the sequence
    num_bits = length(binarySequence);
    
    % Calculate bit duration based on total signal time
    Tb = T / num_bits;  % Time duration of each bit
    
    % Create time vector for the total duration
    t = 0:1/Fs:T-1/Fs;  % Time vector for the entire signal duration
    
    % Initialize modulated signal
    modulatedSignal = [];
    currentPhase = 0;  % Start with phase 0
    
    % Generate modulated signal over the entire signal duration
    for i = 1:num_bits
        % Time vector for the current bit
        t_bit = (i-1)*Tb : 1/Fs : i*Tb-1/Fs;  % Time interval for this bit
        
        if binarySequence(i) == 1
            % If the bit is 1, maintain current phase
            modulatedSignal = [modulatedSignal cos(2 * pi * t_bit / Tb + currentPhase)];
        else
            % If the bit is 0, change phase by 180 degrees (pi)
            currentPhase = currentPhase + pi;
            modulatedSignal = [modulatedSignal cos(2 * pi * t_bit / Tb + currentPhase)];
        end
    end
end
