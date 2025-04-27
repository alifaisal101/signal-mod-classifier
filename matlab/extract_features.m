function feat = extract_features(sig, Fs)
    % Compute amplitude envelope
    amp_env = abs(sig);
    
    % Compute analytic signal for phase
    analytic_sig = hilbert(sig);
    inst_phase = unwrap(angle(analytic_sig));
    inst_freq = diff(inst_phase) * Fs / (2*pi);
    
    % Avoid NaNs in very weird signals
    inst_freq(~isfinite(inst_freq)) = 0;

    % Final feature vector (6D)
    feat = [
        mean(amp_env)
        std(amp_env)
        mean(inst_freq)
        std(inst_freq)
        skewness(inst_freq)
        kurtosis(inst_freq)
    ]';
end
