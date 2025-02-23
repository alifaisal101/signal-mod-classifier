function modulatedSignal = qpskModFunc(binarySequence, Fs, T)
    % QPSK Modulation Function
    %
    % Parameters:
    % binarySequence : Binary sequence to be modulated (must be even length)
    % Fs             : Sampling frequency (Hz)
    % T              : Total signal duration (seconds)
    
    % Number of bits in the sequence (it should be even)
    num_bits = length(binarySequence);
    
    % Ensure the binary sequence length is even
    if mod(num_bits, 2) ~= 0
        error('The binary sequence length must be even for QPSK modulation.');
    end
    
    % Calculate bit duration based on total signal time
    Tb = T / (num_bits / 2);  % Time duration of each symbol (each pair of bits)
    
    % Create time vector for the entire signal duration
    t = 0:1/Fs:T-1/Fs;  % Time vector for the entire signal duration
    
    % Initialize modulated signal
    modulatedSignal = [];
    
    % Generate modulated signal over the entire signal duration
    for i = 1:2:num_bits
        % Combine two bits for QPSK (00, 01, 10, 11)
        bits = binarySequence(i:i+1);
        
        % Time vector for the current symbol (pair of bits)
        t_symbol = (i-1)*Tb : 1/Fs : i*Tb-1/Fs;  % Time interval for this symbol
        
        % Define phase shifts for QPSK (0, 90, 180, 270 degrees)
        if isequal(bits, [0 0])
            phaseShift = 0;  % Phase 0
        elseif isequal(bits, [0 1])
            phaseShift = pi/2;  % Phase 90 degrees
        elseif isequal(bits, [1 0])
            phaseShift = pi;  % Phase 180 degrees
        else
            phaseShift = 3*pi/2;  % Phase 270 degrees
        end
        
        % Generate the QPSK signal for the current symbol
        modulatedSignal = [modulatedSignal cos(2*pi*t_symbol/Tb + phaseShift)];
    end
end
