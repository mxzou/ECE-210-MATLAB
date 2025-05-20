%% ECE 210 - Assignment 06: Corrected Code with Explanations
% Note: used with the help of MATLAB docs + Grok

% Housekeeping commands
clc;
clear;
close all;

% Sampling parameters (as given in assignment)
Fs = 96000;   % Sampling frequency (96 kHz) [cf. cite: 10]
N = 192000;   % Number of samples [cf. cite: 3]
T = 1/Fs;     % Sample period
t = (0:N-1)*T; % Time vector [cf. cite: 17]

%% Problem 1: Define db2mag function

% Define anonymous function to convert dB to magnitude [cf. cite: 2]
% Your original implementation was correct.
db2mag = @(dB) 10.^(dB/20); % [cf. cite: 13, 55]

%% Problem 2: Signal Generation, Noise, and DFT Plot

% --- Define Signal Parameters ---
% Frequencies and dB levels specified in the assignment [cf. cite: 3]
% *** CORRECTION 1: Your original code had incorrect dB levels. ***
% Original dB levels: [0, -0.8, -2, -8] dB
% Correct dB levels:  [14, -10, 0, 2] dB
frequencies = [-20.48e3; -360; 996; 19.84e3]; % Hz (column vector) [cf. cite: 21]
amplitudes_dB = [14; -10; 0; 2];             % dB (column vector)

% Convert dB amplitudes to linear magnitudes
amplitudes_lin = db2mag(amplitudes_dB); % [cf. cite: 22]

% --- Generate Signal Components ---
% *** CORRECTION 2: Use complex exponentials for single-sided frequencies. ***
% Your original code used A*cos(2*pi*f*t). Using cosine creates *two*
% frequency components (at +f and -f) for each specified frequency 'f'.
% For negative frequencies specifically (-20.48 kHz, -360 Hz), this is
% likely not the intent. The assignment asks for components *at* those
% specific frequencies. Using complex exponentials exp(1j*2*pi*f*t)
% creates a single frequency component at 'f'.
% The reference solution uses this vectorized complex exponential approach.
signal_components = amplitudes_lin .* exp(1j * 2 * pi * frequencies .* t); % [cf. cite: 23]

% Sum the components to get the clean signal
signal_clean = sum(signal_components, 1); % Sum across components (rows) [cf. cite: 23]

% --- Add White Noise ---
% Add white noise at -10 dB as specified [cf. cite: 4]
% Your original implementation for adding noise was correct.
noise_dB = -10;
noise_amp = db2mag(noise_dB); % [cf. cite: 10]
noise = noise_amp * randn(1, N); % Use randn for Gaussian white noise (same size as t) [cf. cite: 57]
signal_noisy = signal_clean + noise; % [cf. cite: 10]

% --- Calculate and Plot DFT ---
% Calculate the DFT using fft
% *** CORRECTION 3: Use fftshift and adjust frequency axis accordingly. ***
% Your original code used X = fft(x_noisy)/N and f_axis = (0:N-1)*(Fs/N).
% This results in a frequency axis from 0 to Fs, with the negative frequencies
% appearing in the upper half of the plot due to FFT periodicity.
% It's standard practice (and shown in the lecture/solution [cf. cite: 24, 25]) to use fftshift()
% to center the DC component (0 Hz) in the middle of the plot.
% The corresponding frequency axis should then range from -Fs/2 to Fs/2.
S = fftshift(fft(signal_noisy)); % Calculate FFT and shift [cf. cite: 10, 25]

% Create the frequency axis centered around zero
% Note: 'linspace' is often more robust than the (0:N-1)*Fs/N method for generating axes.
f_axis_shifted = linspace(-Fs/2, Fs/2 - Fs/N, N); % Freq axis from -Fs/2 to nearly +Fs/2 [cf. cite: 24]
% Alternative manual calculation matching reference solution:
% f_axis_shifted = Fs/N * (-N/2 : N/2 - 1);

% Convert magnitude to dB
% *** CORRECTION 4: dB calculation based on non-normalized FFT. ***
% Your original code normalized the FFT by N (X = fft(x_noisy)/N) before dB conversion.
% The reference solution calculates dB directly from the unnormalized FFT output (S = fft(s)).
% Normalization changes the absolute dB values. We will follow the reference.
S_dB = 20*log10(abs(S)); % [cf. cite: 28]

% Plot the DFT Magnitude
figure;
plot(f_axis_shifted, S_dB);
title('DFT Magnitude Spectrum');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
% Limit x-axis to focus on the main components if desired, or show full range
xlim([-Fs/2, Fs/2]); % Show the full range up to +/- Nyquist [cf. cite: 29]
grid on;

%% Problem 3: Filter Analysis

% --- Define Filter Poles, Zeros, and Gain ---
% From the assignment equation H(z) [cf. cite: 5]
% *** CORRECTION 5: Your original definition missed several poles/zeros. ***
% The formula H(z) specifies conjugate pairs for poles and zeros.
% Your original code only defined z1, z2, z3 and a repeated p1.
% The correct H(z) has 3 pairs of complex conjugate zeros and
% 2 pairs of complex conjugate poles plus 2 real poles.
% The reference solution correctly includes the conjugates and real poles. [cf. cite: 11, 12]

% Define the complex zeros given
z_given = [ 0.76 + 0.64j;
            0.69 + 0.71j; % Corrected imaginary part from 0.17j in your code to 0.71j from assignment/solution [cf. cite: 5, 11]
            0.82 + 0.57j ];
% Add their conjugates
z = [z_given; conj(z_given)]; % Full set of zeros (column vector)

% Define the complex poles given
p_complex_given = [ 0.57 + 0.78j;
                    0.85 + 0.48j ]; % Corrected pole location from repeated p1 in your code [cf. cite: 5, 12]
% Define the real poles given
p_real = [0.24; 0.64];
% Combine complex conjugates and real poles
p = [p_complex_given; conj(p_complex_given); p_real]; % Full set of poles (column vector)

% Define gain
k = 0.53; % [cf. cite: 5, 12]

% --- Pole-Zero Plot ---
figure;
% Use the full z, p vectors. Your original zplane call was okay but used incomplete z/p.
zplane(z, p); % [cf. cite: 12, 40]
title('Pole-Zero Plot of H(z)');
grid on;

% --- Magnitude and Phase Response ---
% Convert pole-zero-gain form to transfer function (numerator/denominator coeffs)
% This step is needed for freqz if providing poles/zeros isn't directly supported
% or if you prefer working with b, a coefficients.
% Your original call [b,a]=zp2tf(z_vec, p_vec, k); was correct in principle.
[b, a] = zp2tf(z, p, k); % Use the full z, p vectors [cf. cite: 12]

% Calculate frequency response using freqz over physical frequencies
% Assignment requires plotting against physical frequencies up to Nyquist [cf. cite: 6]
% Your original code used [H, freq] = freqz(b, a, 1024, Fs); which is correct.
num_freq_points = 1024; % Number of points for freqz calculation
[H, freq_vec] = freqz(b, a, num_freq_points, Fs); % [cf. cite: 12, 61]

% Calculate magnitude in dB
H_mag_dB = 20*log10(abs(H)); % [cf. cite: 13, 63]

% Calculate phase in degrees and unwrap it
% Your original angle calculation was correct.
H_phase_deg = rad2deg(unwrap(angle(H))); % Use unwrap() to handle phase jumps [cf. cite: 14, 44]

% Plot Magnitude and Phase Responses
figure;
sgtitle('Filter Frequency Response H(z)'); % Overall title [cf. cite: 13]

% Magnitude Plot
subplot(2, 1, 1); % [cf. cite: 13]
plot(freq_vec, H_mag_dB);
title('Magnitude Response');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
xlim([0, Fs/2]); % Show up to Nyquist frequency [cf. cite: 7, 13]
grid on;

% Phase Plot
subplot(2, 1, 2); % [cf. cite: 14]
plot(freq_vec, H_phase_deg);
title('Phase Response');
xlabel('Frequency (Hz)');
ylabel('Phase (degrees)');
xlim([0, Fs/2]); % Show up to Nyquist frequency [cf. cite: 7, 14]
grid on;