clear all;

all_documents = {};

for i = 1:1000
    Fs = randi([500, 2000]);              % Sampling frequency (Hz)
    f_c = randi([10000, 100000]);         % Carrier frequency (Hz)
    T = randi([1, 100]);                  % Duration of the signal (seconds)
    num_bits = randi([100, 200]);         % Number of bits
    if mod(num_bits, 2) ~= 0
        num_bits = num_bits + 1;          % If odd, make it even
    end
    
    input_bits = randi([0 1], 1, num_bits); % Random binary sequence
    t = 0:1/Fs:T-1/Fs;

    % Modulate the signal (ASK, BPSK, QPSK, FSK)
    s_t_ask = askModFunc(input_bits, Fs, f_c, T);
    s_t_bpsk = bpskModFunc(input_bits, Fs, T);
    s_t_qpsk = qpskModFunc(input_bits, Fs, T);

    f0 = randi([10, 500]);                % Frequency for bit 0 (Hz)
    f1 = randi([100, 1500]);               % Frequency for bit 1 (Hz)
    s_t_fsk = fskModFunc(input_bits, Fs, T, f0, f1);

    % Add noise to the modulated signals (SNR range can be adjusted)
    snr_dB_ask = randi([25, 30]);   % SNR for ASK (you can adjust this)
    s_t_ask_noisy = awgn(s_t_ask, snr_dB_ask, 'measured');

    snr_dB_bpsk = randi([25, 30]);  % SNR for BPSK
    s_t_bpsk_noisy = awgn(s_t_bpsk, snr_dB_bpsk, 'measured');

    snr_dB_qpsk = randi([25, 30]);  % SNR for QPSK
    s_t_qpsk_noisy = awgn(s_t_qpsk, snr_dB_qpsk, 'measured');

    snr_dB_fsk = randi([25, 30]);   % SNR for FSK
    s_t_fsk_noisy = awgn(s_t_fsk, snr_dB_fsk, 'measured');

    % Feature extraction for noisy signals
    features_ask = featureExtraction(s_t_ask_noisy, Fs, T);
    features_bpsk = featureExtraction(s_t_bpsk_noisy, Fs, T);
    features_qpsk = featureExtraction(s_t_qpsk_noisy, Fs, T);
    features_fsk = featureExtraction(s_t_fsk_noisy, Fs, T);

    % Prepare data for MongoDB
    document_ask = struct('type', 'ask', 'features', features_ask);
    document_bpsk = struct('type', 'bpsk', 'features', features_bpsk);
    document_qpsk = struct('type', 'qpsk', 'features', features_qpsk);
    document_fsk = struct('type', 'fsk', 'features', features_fsk);

    % Add documents to the array
    all_documents{end+1} = document_ask;
    all_documents{end+1} = document_bpsk;
    all_documents{end+1} = document_qpsk;
    all_documents{end+1} = document_fsk;

    fprintf('Iteration %d: Document created with noisy data.\n', i);
end

% Save documents to JSON and insert them into MongoDB
jsonfile_all = '../all_documents.json';
fid_all = fopen(jsonfile_all, 'w');
fwrite(fid_all, jsonencode(all_documents));
fclose(fid_all);

fprintf('All documents with noise saved to JSON file in parent directory.\n');
system('python ../insert_data_to_mongodb.py ../all_documents.json');  
delete(jsonfile_all);
fprintf('JSON file deleted after insertion.\n');
