function s_t = askModFunc(input_bits, Fs, f_c, T)
    % Function to perform Amplitude Shift Keying (ASK) modulation
    
    % Parameters:
    % input_bits  : binary sequence to be transmitted
    % Fs          : sampling frequency (Hz)
    % f_c         : carrier frequency (Hz)
    % T           : duration of the signal (seconds)
    
    % Number of bits in the input sequence
    num_bits = length(input_bits);  
    
    % Time vector based on the signal duration
    t = 0:1/Fs:T-1/Fs;
    
    % Duration of each bit in time
    bit_duration = T / num_bits;  
    
    % Initialize amplitude array for the signal
    A = zeros(1, length(t));
    
    % Map the binary sequence to the amplitude (0 for '0', 1 for '1')
    for i = 1:num_bits
        start_idx = round((i-1) * bit_duration * Fs) + 1;
        end_idx = round(i * bit_duration * Fs);
        A(start_idx:end_idx) = input_bits(i);
    end
    
    % Scale the amplitude (0.5 for '0', 1.0 for '1')
    A_modulated = A * 0.5 + 0.5;
    
    % Generate the ASK modulated signal by multiplying with the carrier
    s_t = A_modulated .* cos(2 * pi * f_c * t);
end
