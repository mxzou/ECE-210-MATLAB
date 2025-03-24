%% Problem 1: Read CSV Data
data = readmatrix('https://raw.githubusercontent.com/jacobkoziej/jk-ece210/master/src/assignments/07-under-pressure.d/40p_1000ms.csv');
adc_samples = data(:, 2);  % Extract ADC values from column 2

%% Problem 2: Normalize, Compute DFT, and Plot
% Normalize to [0, 1]
normalized = adc_samples / 4095;  % 12-bit ADC (0-4095)
N = length(normalized);
Fs = 80e3;  % Sampling frequency (80 kHz)

% Compute DFT and remove negative frequencies
dft = fft(normalized);
dft_single = dft(1:N/2+1);  % Single-sided DFT
frequencies = (0:N/2) * (Fs / N);  % Frequency axis (Hz)

% Convert to dB scale (20*log10 for voltage)
dB = 20*log10(abs(dft_single));

% Find peak frequency and its magnitude
[peak_dB, peak_idx] = max(dB);
peak_freq = frequencies(peak_idx);

% Plot DFT between 5-40 Hz
figure;
f_mask = (frequencies >= 5) & (frequencies <= 40);
plot(frequencies(f_mask), dB(f_mask));
title('DFT Magnitude (5–40 Hz)');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
grid on;
hold on;
yline(peak_dB - 20, '--', '-20 dB');
yline(peak_dB - 40, '--', '-40 dB');

%% Problem 3: Determine Corner Frequency
% Find passband edge (-20 dB from peak)
target_dB = peak_dB - 20;
valid_freqs = frequencies(f_mask);
valid_dB = dB(f_mask);
passband_edge = max(valid_freqs(valid_dB >= target_dB));  % Highest freq meeting -20 dB
stopband_edge = passband_edge + 10;  % Transition band = 10 Hz

%% Problem 4: Design Elliptic SOS Filter
Rp = 0.1;  % Passband ripple (dB)
Rs = 40;   % Stopband attenuation (dB)
Wp = passband_edge / (Fs/2);  % Normalized passband edge
Ws = stopband_edge / (Fs/2);  % Normalized stopband edge

% Design filter
[n, Wn] = ellipord(Wp, Ws, Rp, Rs);
[sos, ~] = ellip(n, Rp, Rs, Wn, 'low');

% Plot magnitude response
figure;
[h, f] = freqz(sos, 2048, Fs);  % Frequency response up to Fs/2
h_dB = 20*log10(abs(h));
plot(f, h_dB);
title('Filter Magnitude Response');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
xlim([0, stopband_edge + 20]);
grid on;
hold on;
yline(-Rp, '--', 'Passband Ripple (0.1 dB)');
yline(-Rs, '--', 'Stopband Attenuation (40 dB)');
xline(passband_edge, '--', 'Passband Edge');
xline(stopband_edge, '--', 'Stopband Edge');

%% Problem 5: Apply Filter and Plot
% Apply SOS filter
filtered = sosfilt(sos, normalized);

% Time vector (samples to seconds)
t = (0:N-1)' / Fs;

% Plot original vs filtered
figure;
plot(t, normalized, 'b', t, filtered, 'r');
title('Original vs Filtered Signal');
xlabel('Time (s)');
ylabel('Normalized Amplitude');
legend('Original', 'Filtered');
grid on;

% Add DC bias line for filtered signal
dc_bias = mean(filtered);
yline(dc_bias, '--', 'DC Bias', 'LineWidth', 1.5);