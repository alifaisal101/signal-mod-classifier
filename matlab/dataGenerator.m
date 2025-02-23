clear all;

all_documents = {};

for i = 1:1
    Fs = randi([500, 2000]);              % Sampling frequency (Hz)
    f_c = randi([10000, 100000]);         % Carrier frequency (Hz)
    T = randi([1, 100]);                  % Duration of the signal (seconds)
    num_bits = randi([100, 200]);         % Number of bits
    if mod(num_bits, 2) ~= 0
        num_bits = num_bits + 1;          % If odd, make it even
    end
    
    input_bits = randi([0 1], 1, num_bits); % Random binary sequence
    t = 0:1/Fs:T-1/Fs;

    s_t_ask = askModFunc(input_bits, Fs, f_c, T);
    s_t_bpsk = bpskModFunc(input_bits, Fs, T);
    s_t_qpsk = qpskModFunc(input_bits, Fs, T);

    f0 = randi([10, 500]);                % Frequency for bit 0 (Hz)
    f1 = randi([100, 1500]);               % Frequency for bit 1 (Hz)
    s_t_fsk = fskModFunc(input_bits, Fs, T, f0, f1);

    features_ask = featureExtraction(s_t_ask, Fs, T);
    features_bpsk = featureExtraction(s_t_bpsk, Fs, T);
    features_qpsk = featureExtraction(s_t_qpsk, Fs, T);
    features_fsk = featureExtraction(s_t_fsk, Fs, T);

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

    fprintf('Iteration %d: Document created.\n', i);
end

jsonfile_all = '../all_documents.json';
fid_all = fopen(jsonfile_all, 'w');
fwrite(fid_all, jsonencode(all_documents));
fclose(fid_all);

fprintf('All documents saved to JSON file in parent directory.\n');
system('python ../insert_data_to_mongodb.py ../all_documents.json');  
delete(jsonfile_all);
fprintf('JSON file deleted after insertion.\n');