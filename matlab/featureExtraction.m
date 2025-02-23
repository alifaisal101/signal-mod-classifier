function features = featureExtraction(modulatedSignal, Fs, T)
    % Global Feature Extraction for any modulation scheme
    %
    % Parameters:
    % modulatedSignal : The modulated signal (time-domain)
    % Fs              : Sampling frequency (Hz)
    % T               : Total duration of the signal (seconds)

    % Duration
    features.duration = T;

    % Time Domain Features
    features.mean = mean(modulatedSignal); 
    features.rms = rms(modulatedSignal); 
    features.peakToPeak = max(modulatedSignal) - min(modulatedSignal); 
    features.crestFactor = max(modulatedSignal) / features.rms; 

    % Frequency Domain Features: Power Spectral Density (PSD)
    [Pxx, Freqs] = pwelch(modulatedSignal, [], [], [], Fs);
    features.psd = Pxx;
    features.peakFrequency = Freqs(find(Pxx == max(Pxx), 1));  % Peak frequency

    % Bandwidth: Range where significant power is located (within 90% power)
    totalPower = sum(Pxx);
    significantFreqs = Freqs(Pxx > 0.1 * totalPower);
    features.bandwidth = max(significantFreqs) - min(significantFreqs);

    % Statistical Features
    features.meanAbsDev = mean(abs(modulatedSignal - mean(modulatedSignal)));
    features.skewness = skewness(modulatedSignal);
    features.kurtosis = kurtosis(modulatedSignal);
    features.entropy = -sum(Pxx .* log2(Pxx + eps));

    [acf, lags] = xcorr(modulatedSignal, 'coeff');
    features.autocorrPeak = max(acf);

    features.harmonics = find(Pxx > 0.1 * max(Pxx)); 
end
