function modulatedSignal = fskModFunc(binarySequence, Fs, T, f0, f1)
    % FSK Modulation Function
    %
    % Parameters:
    % binarySequence : Binary sequence to be modulated
    % Fs             : Sampling frequency (Hz)
    % T              : Total signal duration (seconds)
    % f0             : Frequency for bit 0 (Hz)
    % f1             : Frequency for bit 1 (Hz)
    
    % Number of bits in the sequence
    num_bits = length(binarySequence);
    
    % Calculate bit duration based on total signal time
    Tb = T / num_bits;  % Time duration of each bit
    
    % Create time vector for the entire signal duration
    t = 0:1/Fs:T-1/Fs;  % Time vector for the entire signal duration
    
    % Initialize modulated signal
    modulatedSignal = [];

    % FSK modulation
    for i = 1:num_bits
        % Time vector for the current bit
        t_bit = (i-1)*Tb : 1/Fs : i*Tb-1/Fs;  % Time interval for this bit
        
        if binarySequence(i) == 1
            % Frequency for bit 1
            modulatedSignal = [modulatedSignal cos(2 * pi * f1 * t_bit)];
        else
            % Frequency for bit 0
            modulatedSignal = [modulatedSignal cos(2 * pi * f0 * t_bit)];
        end
    end
end
