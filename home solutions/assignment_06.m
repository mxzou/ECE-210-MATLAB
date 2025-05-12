%% SPDX-License-Identifier: MIT License
%
% assignment_six.m - HW06 Four-year Transform
% Copyright (C) 2024 Senik Zou <mengxuan.zou@cooper.edu>
%

% Sampling parameters
Fs = 96000;           % 96 kHz
N = 192000;           % number of samples
t = (0:N - 1) / Fs;   % time vector

% Define db2mag() if needed
db2mag = @(dB) 10.^(dB / 20);

% Generate signals, frequencies and dB levels
f1 = -20480;
dB1 = 0;      % -20.48 kHz,  0 dB
f2 = -360;
dB2 = -0.8;   %   -360 Hz,  -0.8 dB
f3 = 996;
dB3 = -2;     %    996 Hz,  -2 dB
f4 = 19840;
dB4 = -8;     % 19.84 kHz,  -8 dB

A1 = db2mag(dB1);
A2 = db2mag(dB2);
A3 = db2mag(dB3);
A4 = db2mag(dB4);

% Generate sinusoids
x1 = A1 * cos(2 * pi * f1 * t);
x2 = A2 * cos(2 * pi * f2 * t);
x3 = A3 * cos(2 * pi * f3 * t);
x4 = A4 * cos(2 * pi * f4 * t);

% Sum of signals
x_sig = x1 + x2 + x3 + x4;

% Add white noise at -10 dB
noise_dB = -10;
noise_amp = db2mag(noise_dB);
noise = noise_amp * randn(size(t));
x_noisy = x_sig + noise;

% Take the DFT and plot in dB scale, divide by N to get normalized amplitude
X = fft(x_noisy) / N;
f_axis = (0:N - 1) * (Fs / N);       % Frequency axis in Hz
X_dB = 20 * log10(abs(X));

figure;
plot(f_axis, X_dB);
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('DFT Magnitude (dB scale)');
xlim([0 Fs / 2]);  % show up to Nyquist

% H(z), poles and zeros from the given expression:
%   H(z) = 0.53 * ((z - z1)*(z - z2)*(z - z3)) / ((z - p1)^2)
z1 = 0.76 + 1j * 0.64;
z2 = 0.69 + 1j * 0.17;
z3 = 0.82 + 1j * 0.57;
p1 = 0.57 + 1j * 0.78;  % Repeated pole
k  = 0.53;              % Gain

% Create vectors for zeros/poles
z_vec = [z1; z2; z3];  % Column vector for zeros
p_vec = [p1; p1];      % Column vector for repeated pole

% Pole-zero plot
figure;
zplane(z_vec, p_vec);
title('Pole-Zero Plot');

% Frequency response with freqz
%    Use zp2tf (Signal Processing Toolbox) to convert Z,P,K --> b,a
[b, a] = zp2tf(z_vec, p_vec, k);

% Evaluate the frequency response
[H, freq] = freqz(b, a, 1024, Fs);
mag = 20 * log10(abs(H));
phase = angle(H) * (180 / pi);

figure;
subplot(2, 1, 1);
plot(freq, mag);
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Magnitude Response');

subplot(2, 1, 2);
plot(freq, phase);
xlabel('Frequency (Hz)');
ylabel('Phase (degrees)');
title('Phase Response');
