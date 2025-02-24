%% SPDX-License-Identifier: MIT License
%
% assignment_two.m - HW02 solution ECE-211 MATLAB course
% Copyright (C) 2024 Senik Zou <mengxuan.zou@cooper.edu>
%

% Problem 1
u = [-4, -2, 0, 2, 4];
v = [0, pi / 4, pi / 2, 3 * pi / 4, pi];

% Problem 2
f = prod(1:10);

% Problem 3 a)
A = zeros(2, 4);
A(1, 1) = 1; % set first row and column to value 1
A(2, 3) = 1; % changed index

% Problem 3 b)
% uses the colon operator to create two row vectors, combined into a 2x8 matrix
temp = [1:8; 9:16]';
B = reshape(temp, 4, 4); % reshape into a 4x4 matrix, filling column-wise

% Problem 4 - Fourier series plot
N = 50; % (n from 0 to 50)
t = linspace(-pi, pi, 1000); % create 1000 evenly spaced points from -pi to pi
n = 0:N; % see N
a_n = 2 * n + 1;        % a_n = 2*n + 1, so a_n = [1, 3, 5, ..., 101]

% step - vectorization
a_n_col = a_n'; % transpose

sin_terms = sin(a_n_col * t);
terms = sin_terms ./ a_n_col;

s = sum(terms, 1);

% plot
figure;
plot(t, s, 'LineWidth', 1.5);  % plot s(t) vs t
xlabel('t');
ylabel('s(t)');
title('Fourier Series Approximation of Square Wave');
grid on;

% display results
disp('Vector u:');
disp(u);
disp('Vector v:');
disp(v);
disp('10! (f):');
disp(f);
disp('Matrix A:');
disp(A);
disp('Matrix B:');
disp(B);
 