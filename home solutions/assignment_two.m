% Assignment 02: A New Way of Thinking

%% Part 1: Create the Specified Vectors
% Define vector u with the values [-4, -2, 0, 2, 4]
u = [-4, -2, 0, 2, 4];

% Define vector v with angles in radians: [0, pi/4, pi/2, 3*pi/4, pi]
v = [0, pi/4, pi/2, 3*pi/4, pi];

%% Part 2: Calculate 10! Using prod()
% Compute the factorial of 10 as the product of numbers from 1 to 10
% Store the result in variable f
f = prod(1:10);  % f = 1 * 2 * 3 * ... * 10 = 3628800

%% Part 3: Create the Specified Matrices
% (a) Matrix A = [1 0 0 0; 0 0 1 0]
% This is a 2x4 matrix with 1s at positions (1,1) and (2,3), and 0s elsewhere
A = zeros(2, 4);  % Initialize a 2x4 matrix filled with zeros
A(1,1) = 1;       % Set element at row 1, column 1 to 1
A(2,3) = 1;       % Set element at row 2, column 3 to 1

% (b) Matrix B = [1 9 2 10; 3 11 4 12; 5 13 6 14; 7 15 8 16]
% This is a 4x4 matrix. We can construct it efficiently by recognizing
% MATLAB's column-major order and reshaping a sequence of numbers
temp = [1:8; 9:16]';  % Create a temporary matrix with two rows, then transpose
                      % Result: [1 9; 2 10; 3 11; 4 12; 5 13; 6 14; 7 15; 8 16]
B = reshape(temp, 4, 4);  % Reshape into a 4x4 matrix, filling column-wise

%% Part 4: Plot the Fourier Series Approximation of a Square Wave
% The series is s(t) = sum_{n=0}^{50} sin(a_n * t) / a_n, where a_n = 2*n + 1
% Plot this over t in [-pi, pi] with 1000 points

% Define parameters
N = 50;               % Number of terms in the series (n from 0 to 50)
t = linspace(-pi, pi, 1000);  % Create 1000 evenly spaced points from -pi to pi

% Compute the coefficients a_n for n = 0 to 50
n = 0:N;              % Vector of indices from 0 to 50
a_n = 2*n + 1;        % a_n = 2*n + 1, so a_n = [1, 3, 5, ..., 101]

% Compute the Fourier series efficiently using vectorization
a_n_col = a_n';       % Reshape a_n into a column vector (51 x 1) for broadcasting
sin_terms = sin(a_n_col * t);  % Compute sin(a_n * t) for all n and t
                               % Results in a 51 x 1000 matrix
terms = sin_terms ./ a_n_col;  % Divide each row by corresponding a_n
                               % Element-wise division using broadcasting
s = sum(terms, 1);    % Sum along rows to get the total approximation
                      % s is a 1 x 1000 vector representing s(t)

% Plot the approximation
figure;               % Open a new figure window
plot(t, s, 'LineWidth', 1.5);  % Plot s(t) vs t with a thicker line for clarity
xlabel('t');          % Label the x-axis
ylabel('s(t)');       % Label the y-axis
title('Fourier Series Approximation of Square Wave');  % Add a title
grid on;              % Add a grid for better readability

%% Display Results (Optional for Verification)
disp('Vector u:'); disp(u);
disp('Vector v:'); disp(v);
disp('10! (f):'); disp(f);
disp('Matrix A:'); disp(A);
disp('Matrix B:'); disp(B);