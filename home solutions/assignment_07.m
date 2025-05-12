%% SPDX-License-Identifier: MIT License
%
% assignment_seven.m - HW07 Under Pressure
% Copyright (C) 2024 Senik Zou <mengxuan.zou@cooper.edu>
%

%% Read the CSV Data (first column is sample number, second is ADC samples)
url = ['https://raw.githubusercontent.com/jacobkoziej/jk-ece210/master/', ...
       'src/assignments/07-under-pressure.d/40p_1000ms.csv'];
data = readmatrix(url);

% Extract the ADC samples
adc_samples = data(:, 2);

% Define the sampling frequency (80 kHz)
fs = 80e3;

%% Task 2: Normalize the Signal, Compute DFT, and Plot
% Normalize the signal between 0 and 1
% ADC is 12-bit so values range from 0 to 4095 (2^12 - 1)
adc_max = 4095;
signal_normalized = adc_samples / adc_max;

% Compute the DFT
N = length(signal_normalized);
DFT = fft(signal_normalized);
f = (0:N - 1) * fs / N;  % frequency vector (Hz)

% Make sure N is even for clean division
if mod(N, 2) ~= 0
    N = N - 1;  % Adjust N to be even
    signal_normalized = signal_normalized(1:N);
    DFT = fft(signal_normalized);
    f = (0:N - 1) * fs / N;  % Update frequency vector
end

% Keep only positive frequencies (real signal)
f_positive = f(1:N / 2);
DFT_positive = DFT(1:N / 2);

% Compute magnitude in dB
mag_dB = 20 * log10(abs(DFT_positive));

% Find the peak frequency and its magnitude
[peak_mag, peak_idx] = max(mag_dB);
peak_freq = f_positive(peak_idx);

% Plot DFT between 5 and 40 Hz
figure(1);
% Find indices for frequencies between 5 and 40 Hz
freq_range_idx = (f_positive >= 5) & (f_positive <= 40);
plot(f_positive(freq_range_idx), mag_dB(freq_range_idx), ...
     'b-', 'LineWidth', 1.5);
hold on;
xlim([5, 40]);  % limit to 5-40 Hz
yline(peak_mag - 20, 'r--', '-20 dB from peak');  % dashed line at -20 dB
yline(peak_mag - 40, 'g--', '-40 dB from peak');  % dashed line at -40 dB
title('DFT Magnitude (dB Scale) between 5 and 40 Hz');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
grid on;
hold off;

%% Task 3: Design Elliptic Low-Pass Filter
corner_idx = find(mag_dB <= peak_mag - 20, 1, 'first');
f_corner = f_positive(corner_idx);

% Filter specifications
Rp = 0.1;  % passband ripple (dB)
Rs = 40;   % stopband attenuation (dB)
transition_band = 10;  % transition band (Hz)

% Calculate passband and stopband frequencies
Wp = f_corner;  % passband edge (corner frequency)
Ws = Wp + transition_band;  % stopband edge

% Normalize frequencies by Nyquist frequency (fs/2)
Wp_norm = Wp / (fs / 2);
Ws_norm = Ws / (fs / 2);

% Design elliptic filter
[N, Wn] = ellipord(Wp_norm, Ws_norm, Rp, Rs);
[b, a] = ellip(N, Rp, Rs, Wn);

% Convert to SOS format (for numerical stability)
[sos, g] = tf2sos(b, a);

%% Task 4: Apply SOS Filter and Plot with DC Bias
signal_filtered = sosfilt(sos, signal_normalized) * g;

if length(signal_filtered) ~= length(signal_normalized)
    signal_filtered = signal_filtered(1:length(signal_normalized));
end

% Compute DC bias (mean of the filtered signal)
dc_bias = mean(signal_filtered);

% Time vector for plotting - ensure it matches the signal length
t = (0:length(signal_normalized) - 1) / fs;

% Plot original and filtered signals
figure(2);
subplot(2, 1, 1);
plot(t, signal_normalized, 'b-', 'LineWidth', 1.5);
title('Raw Data');
xlabel('Time [s]');
ylabel('Amplitude');
xlim([0, 2]);
ylim([0.3, 0.9]);
grid on;

subplot(2, 1, 2);
plot(t, signal_filtered, 'b-', 'LineWidth', 1.5);
hold on;
yline(dc_bias, 'r--', 'DC Bias');  % Dashed line for DC bias
title('Filtered Data');
xlabel('Time [s]');
ylabel('Amplitude');
xlim([0, 2]);
ylim([0.3, 0.9]);
grid on;
hold off;

% Figure title
sgtitle('Raw and Filtered Data with DC Bias');
