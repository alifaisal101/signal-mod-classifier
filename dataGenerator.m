clear all;

% Define Parameters
for i = 1:10000
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

    % Prepare data for MongoDB (Document structure)
    document_ask = struct('type', 'ask', 'features', features_ask);
    document_bpsk = struct('type', 'bpsk', 'features', features_bpsk);
    document_qpsk = struct('type', 'qpsk', 'features', features_qpsk);
    document_fsk = struct('type', 'fsk', 'features', features_fsk);

    % Save documents to temporary files
    jsonfile_ask = sprintf('temp_ask_%d.json', i);
    jsonfile_bpsk = sprintf('temp_bpsk_%d.json', i);
    jsonfile_qpsk = sprintf('temp_qpsk_%d.json', i);
    jsonfile_fsk = sprintf('temp_fsk_%d.json', i);

    % Save to JSON files
    fid_ask = fopen(jsonfile_ask, 'w');
    fwrite(fid_ask, jsonencode(document_ask));
    fclose(fid_ask);

    fid_bpsk = fopen(jsonfile_bpsk, 'w');
    fwrite(fid_bpsk, jsonencode(document_bpsk));
    fclose(fid_bpsk);

    fid_qpsk = fopen(jsonfile_qpsk, 'w');
    fwrite(fid_qpsk, jsonencode(document_qpsk));
    fclose(fid_qpsk);

    fid_fsk = fopen(jsonfile_fsk, 'w');
    fwrite(fid_fsk, jsonencode(document_fsk));
    fclose(fid_fsk);

    % Call Python function to insert data from file
    system(['python insert_data_to_mongodb.py ', jsonfile_ask]);
    system(['python insert_data_to_mongodb.py ', jsonfile_bpsk]);
    system(['python insert_data_to_mongodb.py ', jsonfile_qpsk]);
    system(['python insert_data_to_mongodb.py ', jsonfile_fsk]);

    % Delete temporary files after insertion
    delete(jsonfile_ask);
    delete(jsonfile_bpsk);
    delete(jsonfile_qpsk);
    delete(jsonfile_fsk);

    fprintf('Iteration %d: Data inserted into MongoDB.\n', i);
end
