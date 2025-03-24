%% Problem 1: Define db2mag()
db2mag = @(dB) 10.^(dB / 20);  % Convert dB to linear magnitude

%% Problem 2: Generate Signal and Plot DFT
Fs = 96e3;          % Sampling frequency (96 kHz)
N = 192e3;          % 192k samples
t = (0:N-1)' / Fs;  % Time vector (seconds)

% Define frequencies and dB levels
freqs = [-20480, -360, 996, 19840];  % Frequencies (Hz)
dBs = [14, -10, 0, 2];              % Corresponding dB levels

% Initialize signal
signal = 0;
for i = 1:length(freqs)
    mag = db2mag(dBs(i));             % Convert dB to magnitude
    component = mag * exp(1j*2*pi*freqs(i)*t);  % Complex exponential
    signal = signal + component;      % Sum components
end

% Add -10 dB white noise
noise_power = db2mag(-10)^2;          % Noise power (0.1 in linear)
noise = sqrt(noise_power) * randn(N, 1);  % Scaled real noise
signal = signal + noise;

% Compute DFT
dft = fft(signal);
dft_dB = 20*log10(abs(dft));          % Convert to dB scale
freq_axis = (0:N-1) * Fs / N;         % Frequency axis (Hz)

% Plot DFT magnitude
figure;
plot(freq_axis, dft_dB);
title('DFT Magnitude (dB Scale)');
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
xlim([0, Fs/2]);  % Plot up to Nyquist frequency
grid on;

%% Problem 3: Pole-Zero Plot and Frequency Response
% Define numerator and denominator coefficients
% Numerator: Product of zeros' quadratic terms scaled by 0.53
num_quad1 = [1, -1.52, 0.9872];    % Zero pair (0.76±j0.64)
num_quad2 = [1, -1.38, 0.9802];    % Zero pair (0.69±j0.71)
num_quad3 = [1, -1.64, 0.9973];    % Zero pair (0.82±j0.57)
num = 0.53 * conv(conv(num_quad1, num_quad2), num_quad3);

% Denominator: Product of poles' quadratic and linear terms
den_quad1 = [1, -1.14, 0.9333];    % Pole pair (0.57±j0.78)
den_quad2 = [1, -1.7, 0.9529];     % Pole pair (0.85±j0.48)
den_lin1 = [1, -0.24];             % Pole at 0.24
den_lin2 = [1, -0.64];             % Pole at 0.64
den = conv(conv(conv(den_quad1, den_quad2), conv(den_lin1, den_lin2));

% Pole-zero plot
figure;
zplane(num, den);
title('Pole-Zero Plot');

% Magnitude and phase response
[h, f] = freqz(num, den, 2048, Fs);  % Frequency response in Hz
mag_dB = 20*log10(abs(h));
phase_deg = rad2deg(angle(h));

figure;
subplot(2,1,1);
plot(f, mag_dB);
title('Magnitude Response');
ylabel('Magnitude (dB)');
grid on;

subplot(2,1,2);
plot(f, phase_deg);
title('Phase Response');
xlabel('Frequency (Hz)');
ylabel('Phase (degrees)');
grid on;