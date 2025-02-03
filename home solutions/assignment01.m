%% SPDX-License-Identifier: MIT License
%
% assignment01.m 
% First homework to the MATLAB course focused on Signal Processing
% Copyright (C) 2024 Senik Zou <mengxuan.zou@cooper.edu>
%

%% 1. Create the matrices
u = [11 13 17];          % Row vector
v = [-1; -1; -1];        % Column vector

% Create matrix A using u
A = [-u; 2*u; 7*u];      % Constructed from row vector u

% Create matrix B by concatenating A transpose and v
B = [A', v];             % Concatenated matrix

% Display matrices
disp('Row Vector u')     % Use single quotes for strings
disp(u)
disp('Col Vector v')
disp(v)
disp('Matrix A using u')
disp(A)
disp('Matrix B using A transpose + v')
disp(B)

%% 2. Perform calculations
c = exp(1i*pi/4);        % e^(jπ/4)
d = sqrt(-1);            % √j
l = floor(nthroot(8.4108e6, 2.1));
k = floor(100*log(2)) + abs(ceil(exp(7.5858)));    % ⌊100log(2)⌋ + ⌈e^7.5858⌉

% 3. Solve system of linear equations
A = [1 -11 -3; 1 1 0; 2 5 1];
b = [-37; -1; 10];

% Use mldivide (left division) to solve Ax = b
x = A\b;

% Display results
disp('Results:')
disp('Matrix A:')
disp(A)
disp('Vector b:')
disp(b)
disp('Solution x:')
disp(x)

% Verify solution by checking if Ax = b
disp('Verification (should be close to zero):')
disp(norm(A*x - b)) 
