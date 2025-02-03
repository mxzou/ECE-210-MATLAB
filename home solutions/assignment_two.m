% UNSTYLED

% SPDX-License-Identifier: GPL-3.0-or-later
%
% assignment02.m -- Second homework exploring vectorization
% Copyright (C) 2024 Your Name <your.email@example.com>

% 1. Create vectors
u = [-4, -2, 0, 2, 4];  % Row vector
v = [0, pi / 4, pi / 2, 3 * pi / 4, pi];  % Row vector

% 2. Calculate factorial using prod()
f = prod(1:10);  % 10!

% 3. Create matrices
% (a) Create 2x4 matrix with specific pattern
A = zeros(2, 4);  % Initialize with zeros
A(1, 1) = 1;  % Set first element of first row
A(2, 3) = 1;  % Set third element of second row

% (b) Create 4x4 matrix B
% Using reshape and column-major order to create the matrix
B = reshape([1 3 5 7 9 11 13 15 2 4 6 8 10 12 14 16], [4, 4]);

% 4. Plot square wave Fourier series approximation
% Create time vector with 1000 points
t = linspace(-pi, pi, 1000);

% Generate n values from 0 to 50
n = 0:50;

% Create matrix of a_n values (2n + 1)
a_n = 2 * n + 1;

% Use broadcasting to create matrix of a_n*t values
% Each row corresponds to a different n, each column a different t
[A_n, T] = meshgrid(a_n, t);

% Calculate sum of sine terms using matrix operations
s = sum(sin(A_n .* T) ./ A_n, 2);

% Plot the result
plot(t, s);
xlabel('t');
ylabel('s(t)');
title('Square Wave Fourier Series Approximation');
grid on;

% Optional: Add axis lines for better visualization
hold on;
plot([-pi pi], [0 0], 'k--');  % x-axis
plot([0 0], ylim, 'k--');      % y-axis
hold off; 