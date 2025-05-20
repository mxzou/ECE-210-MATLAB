%% ECE 210 - Assignment 05: corrected code with explanations
% Note: used with the help of MATLAB docs + Grok

% Housekeeping commands (Good practice to include at the start) [cite: 1]
clc;     % Clears the command window
clear;   % Removes all variables from the workspace
close all; % Closes all open figure windows

%% Problem 1: Square Wave Approximation (Superimposed)

% Define the time vector t [cite: 9]
t = linspace(-pi, pi, 1000);

% Define the number of terms (n goes from 0 to 50, so 51 terms total)
num_terms = 51; % Using a variable instead of a magic number (like 50 directly) is clearer.
n_indices = 0:(num_terms-1); % Indices from 0 to 50

% Calculate a_n vectorially (More efficient than a loop in MATLAB) [cite: 1, 2]
% Original approach used a loop[cite: 9]. Vectorization is preferred.
a_n = (2 * n_indices + 1)'; % Column vector of coefficients (2n+1)

% Calculate components vectorially
% Each row of 's_components' corresponds to sin(a_n*t)/a_n for one a_n
s_components = sin(a_n .* t) ./ a_n; % [cite: 2] Uses element-wise operations (.* and ./)

% Calculate the approximated square wave by summing the components [cite: 2]
% The sum is taken column-wise (summing contributions for each t)
s_approx = sum(s_components, 1); % Sum across the first dimension (rows)

% --- Plotting Problem 1 ---
figure; % Create a new figure window [cite: 20]
hold on; % Retain plots on the same axes [cite: 27, 28]

% Plot the individual components first (optional: adjust color/style)
% Original used light gray[cite: 9, 12], which can be hard to see. Plotting all at once.
plot(t, s_components); % Plot all components [cite: 3]

% Plot the final approximation (sum) on top
plot(t, s_approx, 'b', 'LineWidth', 1.5); % Make the sum line more prominent [cite: 9]

% --- Plot Customization (as required by assignment [cite: 41]) ---
title('Fourier Series Approximation of a Square Wave'); % [cite: 3]
xlabel('t'); % [cite: 3]
ylabel('Amplitude'); % [cite: 9]

% Set x-axis limits and ticks [cite: 3, 9]
xlim([-pi, pi]); % [cite: 3]
xticks([-pi, -pi/2, 0, pi/2, pi]); % [cite: 3]
xticklabels({'-\pi', '-\pi/2', '0', '\pi/2', '\pi'}); % [cite: 3]

% Set y-axis limits
% Original used [-1.5, 1.5][cite: 9]. The theoretical square wave is [-1, 1].
% While Gibbs phenomenon causes overshoot, [-1, 1] is often preferred
% for visualizing the ideal range, as in the solution key[cite: 4].
% Let's use a slightly larger range to capture Gibbs, but tighter than original.
ylim([-1.2, 1.2]); % A compromise reflecting the signal's nature.

grid on; % [cite: 9] Add grid lines for readability
hold off; % Release the figure hold

%% Problem 2: Square Wave Approximation (Subplots) [cite: 42]

figure; % Create a new figure for the subplots

% Use sgtitle for the overall figure title [cite: 43]
sgtitle('Square Wave Approximation and Components'); % [cite: 5, 11]

% --- Subplot 1: Approximation ---
% Original used subplot(2, 1, 1)[cite: 9]. Solution used subplot(1, 2, 1)[cite: 5].
% Using 1 row, 2 columns (side-by-side) often makes comparison easier.
subplot(1, 2, 1); % 1 row, 2 columns, first plot [cite: 5]
plot(t, s_approx, 'b'); % Plot the sum calculated earlier (reuse variables!)
title('Approximation'); % [cite: 5, 9]
xlabel('t'); % [cite: 5]
ylabel('Amplitude');
xlim([-pi, pi]); % [cite: 5, 11]
xticks([-pi, -pi/2, 0, pi/2, pi]); % [cite: 5]
xticklabels({'-\pi', '-\pi/2', '0', '\pi/2', '\pi'}); % [cite: 5]
% Match ylim from Problem 1 for consistency
ylim([-1.2, 1.2]); % Consistent y-limits
grid on; % [cite: 11]

% --- Subplot 2: Components ---
subplot(1, 2, 2); % 1 row, 2 columns, second plot [cite: 6]
% Original recalculated components here using a loop[cite: 11, 12]. Reuse the calculation!
plot(t, s_components); % Plot all components calculated earlier [cite: 6]
title('Components'); % [cite: 6, 11]
xlabel('t'); % [cite: 6]
ylabel('Amplitude');
xlim([-pi, pi]); % [cite: 6, 11]
xticks([-pi, -pi/2, 0, pi/2, pi]); % [cite: 6]
xticklabels({'-\pi', '-\pi/2', '0', '\pi/2', '\pi'}); % [cite: 6]
% Match ylim from Problem 1 for consistency
ylim([-1.2, 1.2]); % Consistent y-limits [cf. cite: 6 uses [-1,1], cite: 11 uses [-1.5,1.5]]
grid on; % [cite: 11]

%% Problem 3: Surface Plot [cite: 43]

% Define the grid resolution (Original used 100[cite: 13], solution used 64 [cite: 7])
% Using 100 provides a smoother plot.
n_points = 100;
axis_range = linspace(-2*pi, 2*pi, n_points); % [cite: 13]

% Create the meshgrid [cite: 35, 13]
[X, Y] = meshgrid(axis_range, axis_range);

% Calculate Z
% ***** MAJOR CORRECTION *****
% Original code used: z = x.*sin(x) - y.*cos(y); [cite: 13]
% This is incorrect! It uses the original vectors 'x' and 'y' (if they existed
% with those names, here 'axis_range') instead of the grid matrices 'X' and 'Y'.
% The function must be evaluated at each point (X, Y) on the grid. [cite: 36]
Z = X .* sin(X) - Y .* cos(Y); % Use X and Y matrices! [cite: 7]

% --- Plotting Problem 3 ---
figure; % New figure
surf(X, Y, Z); % Create the surface plot [cite: 37, 13, 7]

% --- Visualization Enhancements (Good practice, kept from original [cite: 13]) ---
shading interp; % Smooths the colors on the surface [cite: 13]
colorbar; % Adds a color scale bar [cite: 13]
title('Surface: z = x sin(x) - y cos(y)'); % [cite: 13]
xlabel('x'); % [cite: 13]
ylabel('y'); % [cite: 13]
zlabel('z'); % [cite: 13]
axis tight; % Adjust axes to fit the data range

%% Extra: MATLAB Logo [cite: 43]
% This was optional extra credit. Your solution was correct. [cite: 14]

figure; % New figure
membrane; % Built-in function to plot the MATLAB L-shaped membrane [cite: 14]
title('MATLAB Logo (Extra Credit)'); % [cite: 14]
axis tight;