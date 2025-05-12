%% ECE 210 - Assignment 07: Corrected Code with Explanations
% This script addresses the problems from Assignment 07, focusing on reading
% real-world ADC data, performing frequency analysis, designing an elliptic
% filter, and applying it. Corrections are based on the assignment
% requirements and the provided solution key.

% Housekeeping commands
clc;
clear;
close all;

%% Task 1: Read the CSV Data

% URL for the data file [cf. cite: 71]
% Your original method of reading from URL is kept.
url = ['https://raw.githubusercontent.com/jacobkoziej/', ...
       'jk-ece210/master/src/assignments/', ...
       '07-under-pressure.d/40p_1000ms.csv'];
data = readmatrix(url); % [cf. cite: 10]

% Extract the ADC samples (second column) [cf. cite: 13, 72]
adc_samples = data(:, 2);

% Define the sampling frequency (80 kHz) [cf. cite: 16, 67]
fs = 80e3;
fn = fs / 2; % Nyquist frequency

%% Task 2: Normalize the Signal, Compute DFT, and Plot

% Normalize the signal between 0 and 1 [cf. cite: 73]
% ADC is 12-bit, so values range from 0 to 2^12 - 1 = 4095 [cf. cite: 68]
RESOLUTION = 2^12;
adc_max = RESOLUTION - 1; % Max value is 4095 [cf. cite: 21]
signal_normalized = adc_samples / adc_max; % [cf. cite: 22, 51]

% --- Compute the DFT ---
N = length(signal_normalized); % Get signal length [cf. cite: 25]

% *** CORRECTION 1: Remove unnecessary N adjustment. ***
% Your original code had a block to force N to be even [cf. cite: 30, 35]. This is not
% necessary. Standard FFT indexing handles odd/even N. Removing this block.

DFT = fft(signal_normalized); % [cf. cite: 26, 51]

% Create frequency vector
% The reference solution uses linspace for the angular frequency axis first,
% then converts. The direct method f = (0:N-1)*fs/N is also common.
% Let's stick to the direct method but ensure correct indexing for positive frequencies.
f_full = (0:N-1)*fs/N; % Full frequency vector (0 to fs) [cf. cite: 27]

% Keep only positive frequencies (0 to fs/2) [cf. cite: 73]
% Use floor(N/2)+1 for index to include Nyquist potentially, or floor(N/2)
% Reference uses floor(end/2) index [cf. cite: 51]. User used N/2 index [cf. cite: 38]. Let's use floor.
N_pos = floor(N/2); % Number of unique positive frequency points (excluding DC for strict positive)
f_positive = f_full(1:N_pos + 1); % Frequencies from 0 up to Nyquist (inclusive)
DFT_positive = DFT(1:N_pos + 1); % Corresponding DFT values

% Handle DFT amplitude scaling for single-sided spectrum (optional but good practice)
% Multiply by 2 (except DC and Nyquist) to account for energy from negative frequencies.
DFT_positive(2:end-1) = 2 * DFT_positive(2:end-1);

% Compute magnitude in dB
mag_dB = 20*log10(abs(DFT_positive)); % [cf. cite: 42]

% Find the peak frequency and its magnitude in the positive spectrum
[peak_mag, peak_idx] = max(mag_dB); % [cf. cite: 45]
peak_freq = f_positive(peak_idx); % [cf. cite: 46]
fprintf('Peak frequency found at: %.2f Hz with magnitude: %.2f dB\n', peak_freq, peak_mag);

% --- Plot DFT between 5 and 40 Hz --- [cf. cite: 74]
figure(1); % Use figure handles for clarity if adding more plots later.

% Find indices for frequencies between 5 and 40 Hz in f_positive
freq_range_idx = (f_positive >= 5) & (f_positive <= 40); % [cf. cite: 51]

plot(f_positive(freq_range_idx), mag_dB(freq_range_idx), 'b-', 'LineWidth', 1.5); % [cf. cite: 52]
hold on;
xlim([5, 40]); % Limit x-axis to 5-40 Hz [cf. cite: 55]

% Add dashed lines at -20 and -40 dB from the peak [cf. cite: 75]
yline(peak_mag - 20, 'r--', '-20 dB from peak'); % [cf. cite: 56]
yline(peak_mag - 40, 'g--', '-40 dB from peak'); % [cf. cite: 57]

title('DFT Magnitude (dB Scale) between 5 and 40 Hz'); % [cf. cite: 58]
xlabel('Frequency (Hz)'); % [cf. cite: 59]
ylabel('Magnitude (dB)'); % [cf. cite: 60]
grid on; % [cf. cite: 61]
hold off;

%% Task 3: Design Elliptic Low-Pass Filter

% Determine the corner frequency (Wp) using the -20 dB line [cf. cite: 76]
% Your original method of finding the first frequency below peak-20dB is kept.
% Note: The reference solution assumes Wp = 10 Hz directly [cf. cite: 54]. Finding it
% from the data seems more aligned with the assignment text.
corner_idx = find(mag_dB(freq_range_idx) <= peak_mag - 20, 1, 'first');
f_sub = f_positive(freq_range_idx); % Frequencies in the 5-40Hz range
if isempty(corner_idx)
    warning('Could not find -20dB point in 5-40Hz range. Using default Wp=10Hz.');
    Wp = 10; % Default passband edge if not found
else
    Wp = f_sub(corner_idx); % Passband edge frequency (Hz)
end
fprintf('Determined Passband Edge Wp = %.2f Hz\n', Wp);

% Filter specifications [cf. cite: 77]
Rp = 0.1; % Passband ripple (dB) [cf. cite: 69]
Rs = 40;  % Stopband attenuation (dB) [cf. cite: 70]
transition_band = 10; % Transition band width (Hz) [cf. cite: 71]

% Calculate stopband edge frequency
Ws = Wp + transition_band; % [cf. cite: 75]
fprintf('Stopband Edge Ws = %.2f Hz\n', Ws);

% Normalize frequencies by Nyquist frequency (fn = fs/2) [cf. cite: 77]
Wp_norm = Wp / fn; % [cf. cite: 78]
Ws_norm = Ws / fn; % [cf. cite: 79]

% Check if frequencies are valid (must be between 0 and 1)
if Wp_norm <= 0 || Ws_norm >= 1
    error('Calculated filter frequencies are invalid (Wp=%.2f, Ws=%.2f normalized). Check DFT or parameters.', Wp_norm, Ws_norm);
end

% Determine minimum filter order using ellipord [cf. cite: 82]
[N_ord, Wn_ord] = ellipord(Wp_norm, Ws_norm, Rp, Rs); % [cf. cite: 82]
fprintf('Calculated filter order N = %d\n', N_ord);

% Design the elliptic filter
% *** CORRECTION 2: Use normalized passband edge Wp_norm in ellip call. ***
% Your original code used Wn from ellipord [cf. cite: 8]. Reference used Wp [cf. cite: 54].
% For lowpass, the cutoff frequency argument should be the passband edge.
[b, a] = ellip(N_ord, Rp, Rs, Wp_norm); % Use Wp_norm [cf. cite: 54]

%% Task 4: Obtain SOS and Plot Filter Response

% Convert to Second-Order Sections (SOS) for numerical stability [cf. cite: 9, 78]
[sos, g] = tf2sos(b, a); % [cf. cite: 9]

% --- Plot Filter Magnitude Response ---
% *** CORRECTION 3: Add the missing filter response plot. ***
% Task 4 required plotting the filter's magnitude response [cf. cite: 78].
% Define frequency range for plotting: 0 Hz up to Ws + 20 Hz [cf. cite: 78]
f_response_max = Ws + 20;
num_plot_points = 2048; % More points for smoother plot
f_plot_vec = linspace(0, f_response_max, num_plot_points);

% Calculate frequency response using freqz with SOS
[h, w_resp] = freqz(sos, f_plot_vec, fs);
h_mag_dB = 20*log10(abs(h * g)); % Apply gain g for correct magnitude [cf. cite: 55]

% Create a new figure for combined results or add to subplot
figure(2);
subplot(2, 2, 3); % Place filter response in the 3rd subplot position

plot(f_plot_vec, h_mag_dB);
title(sprintf('Elliptic Lowpass Filter Response (N=%d)', N_ord));
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
grid on;
xlim([0, f_response_max]); % Limit x-axis as specified [cf. cite: 89]
ylim([-Rs*1.5, 5]); % Set y-limits to show passband and stopband clearly [cf. cite: 92]

% Add lines indicating passband and stopband specs [cf. cite: 79]
hold on;
xline(Wp, 'r--', 'Passband Edge (Wp)'); % [cf. cite: 87]
xline(Ws, 'g--', 'Stopband Edge (Ws)'); % [cf. cite: 88]
yline(-Rp, 'r--', sprintf('Passband Ripple (-%.1f dB)', Rp)); % [cf. cite: 90]
yline(-Rs, 'g--', sprintf('Stopband Atten. (-%d dB)', Rs)); % [cf. cite: 91]
hold off;

%% Task 5: Apply SOS Filter and Plot Time Domain Signals

% Apply the SOS filter to the original normalized signal [cf. cite: 83]
% Your original application was correct.
signal_filtered = sosfilt(sos, signal_normalized) * g; % Apply gain g [cf. cite: 10]

% *** CORRECTION 4: Remove unnecessary signal length check. ***
% The check `if length(signal_filtered) ~= length(signal_normalized)` [cf. cite: 91]
% is generally not needed with sosfilt. Output length should match input.

% Compute DC bias (mean of the filtered signal) [cf. cite: 84]
% Your original calculation was correct.
dc_bias = mean(signal_filtered); % [cf. cite: 96]
fprintf('Calculated DC Bias of filtered signal: %.4f\n', dc_bias);

% Create time vector for plotting
% *** CORRECTION 5: Base time vector on final signal length. ***
% Ensure time vector matches the length of the signals being plotted.
N_final = length(signal_normalized); % Use length AFTER any potential changes (none here after removing N adjust)
t = (0:N_final-1) / fs; % [cf. cite: 11]

% --- Plot Original and Filtered Signals --- [cf. cite: 83]
% Plotting in the same figure as DFT and filter response using subplots
figure(2); % Use the same figure handle as the filter response plot

% Plot Raw Data
subplot(2, 2, 1); % Place raw data in the 1st subplot position
plot(t, signal_normalized, 'b'); % Linewidth optional [cf. cite: 104]
title('Raw Data'); % [cf. cite: 105]
xlabel('Time [s]'); % [cf. cite: 106]
ylabel('Normalized Amplitude'); % [cf. cite: 107]
xlim_time = [0, N_final/fs]; % Show full time duration
xlim(xlim_time); % [cf. cite: 12] - Adjusted to show maybe more than 2s if data is longer
ylim_amp = [min(signal_normalized)*0.9, max(signal_normalized)*1.1]; % Auto-adjust Y limits slightly
ylim(ylim_amp); % Your original [0.3, 0.9] might clip data [cf. cite: 109]
grid on; % [cf. cite: 110]

% Plot Filtered Data
subplot(2, 2, 4); % Place filtered data in the 4th subplot position
plot(t, signal_filtered, 'b'); % [cf. cite: 113]
hold on;
% Add line for DC bias [cf. cite: 84]
% Use the calculated DC bias, not a hardcoded value like reference [cf. cite: 60]
yline(dc_bias, 'r--', sprintf('DC Bias (%.3f)', dc_bias)); % [cf. cite: 13]
title('Filtered Data'); % [cf. cite: 116]
xlabel('Time [s]'); % [cf. cite: 117]
ylabel('Normalized Amplitude'); % [cf. cite: 118]
xlim(xlim_time); % [cf. cite: 119]
ylim(ylim_amp); % Match Y limits with raw data plot [cf. cite: 120]
grid on; % [cf. cite: 121]
hold off;

% Add overall title to the figure
sgtitle('Raw ADC Data Analysis and Filtering (Assignment 07)'); % [cf. cite: 14, 56]