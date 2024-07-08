% Define parameters
N = 256; % Number of samples
SNRs = [10, 20]; % SNR values in dB

% Define the transfer function H(z)
z = tf('z', 1); % Define z as the variable in the z-domain
H = 1 / ((z - (0.65 + 0.65i)) * (z - (0.65 - 0.65i))); % Transfer function H(z)

% Generate white signal x(t)
x = wgn(N, 1, 0); % White Gaussian noise with zero mean and unit variance

% Initialize arrays for results
autocorr_x = cell(length(SNRs), 1);
autocorr_y = cell(length(SNRs), 1);
crosscorr_xy = cell(length(SNRs), 1);

% Loop over each SNR value
for i = 1:length(SNRs)
    % Calculate the noise variance for the given SNR
    snr = SNRs(i);
    noise_power = var(x) / (10^(snr/10));
    n = sqrt(noise_power) * wgn(N, 1, 0); % Gaussian white noise with zero mean

    % Filter the signal through H(z)
    y = filter(H.Numerator{1}, H.Denominator{1}, x) + n;

    % Calculate auto-correlation of x(t)
    autocorr_x{i} = xcorr(x, 'biased');

    % Calculate auto-correlation of y(t)
    autocorr_y{i} = xcorr(y, 'biased');

    % Calculate cross-correlation between x(t) and y(t)
    crosscorr_xy{i} = xcorr(x, y, 'biased');
end

% Define lag vector for plotting
lags = -(N-1):(N-1);

% Plot the results
figure;
for i = 1:length(SNRs)
    % Plot auto-correlation of x(t)
    subplot(length(SNRs), 3, (i-1)*3 + 1);
    plot(lags, autocorr_x{i});
    title(['Auto-correlation of x(t) for SNR = ', num2str(SNRs(i)), ' dB']);
    xlabel('Lag');
    ylabel('Auto-correlation');

    % Plot auto-correlation of y(t)
    subplot(length(SNRs), 3, (i-1)*3 + 2);
    plot(lags, autocorr_y{i});
    title(['Auto-correlation of y(t) for SNR = ', num2str(SNRs(i)), ' dB']);
    xlabel('Lag');
    ylabel('Auto-correlation');

    % Plot cross-correlation between x(t) and y(t)
    subplot(length(SNRs), 3, (i-1)*3 + 3);
    plot(lags, crosscorr_xy{i});
    title(['Cross-correlation between x(t) and y(t) for SNR = ', num2str(SNRs(i)), ' dB']);
    xlabel('Lag');
    ylabel('Cross-correlation');
end

% Save the figures
saveas(gcf, 'correlations.png');
