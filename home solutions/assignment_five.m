%% SPDX-License-Identifier: MIT License
%
% assignment_five.m - HW05 Plotting, Scheming even
% Copyright (C) 2024 Senik Zou <mengxuan.zou@cooper.edu>
%

%% Assignment tasks:
% 1. Plot the square wave approximation s(t) along with its components in the
%    same plot.
% 2. Plot the approximation in one subplot and the components in another, with
%    a figure title.
% 3. Plot the 3D surface z = x sin(x) - y cos(y) over the domain
%    [-2pi, 2pi] x [-2pi, 2pi].
% Extra: Plot the MATLAB logo using the membrane function.

%% Task 1: Square Wave Approximation with Components
% Define parameters
num_points = 1000;  % Number of points for smooth plotting
N = 51;  % Number of terms (n from 0 to 50, since n in Z_51 implies 51 terms)

% Define t over the interval [-pi, pi]
t = linspace(-pi, pi, num_points);

% Define n from 0 to 50
n = 0:(N - 1);

% Compute a_n = 2n + 1 for each n
a_n = 2 * n + 1;

% Compute components: each row is sin(a_n t) / a_n for a particular n
components = sin(a_n' * t) ./ a_n';

% Compute the approximation s(t) as the sum of components
s = sum(components, 1);

% Create the plot
figure(1);
plot(t, s, 'k-', 'LineWidth', 2);  % Plot s(t) in black with thicker line
hold on;
plot(t, components', 'Color', [0.8 0.8 0.8]);  % Plot components in light gray
hold off;
title('Square Wave Approximation with Components');  % Add title
set(gca, 'XTick', [-pi -pi / 2 0 pi / 2 pi], 'XTickLabel', ...
    {'-\pi', '-\pi/2', '0', '\pi/2', '\pi'});  % X-axis ticks and labels
ylim([min(s) - 0.1, max(s) + 0.1]);  % Set reasonable y-axis bounds with padding
xlabel('t');  % Label x-axis
ylabel('s(t)');  % Label y-axis

%% Task 2: Subplots for Approximation and Components
figure(2);
% Subplot 1: Approximation
subplot(1, 2, 1);
plot(t, s, 'k-', 'LineWidth', 2);
title('Approximation');
set(gca, 'XTick', [-pi -pi / 2 0 pi / 2 pi], 'XTickLabel', ...
    {'-\pi', '-\pi/2', '0', '\pi/2', '\pi'});
ylim([min(s) - 0.1, max(s) + 0.1]);
xlabel('t');
ylabel('s(t)');

% Subplot 2: Components
subplot(1, 2, 2);
plot(t, components', 'Color', [0.8 0.8 0.8]);
title('Components');
set(gca, 'XTick', [-pi -pi / 2 0 pi / 2 pi], 'XTickLabel', ...
    {'-\pi', '-\pi/2', '0', '\pi/2', '\pi'});
% Adjust y-limits based on components
ylim([min(components(:)) - 0.1, max(components(:)) + 0.1]);
xlabel('t');
ylabel('Amplitude');

% Add overall figure title
sgtitle('Square Wave Approximation and Components');

%% Task 3: 3D Surface Plot
% Define parameters
num_points_surface = 100;  % Number of points for x and y

% Define x and y over [-2pi, 2pi]
x = linspace(-2 * pi, 2 * pi, num_points_surface);
y = x;

% Create meshgrid for surface plotting
[X, Y] = meshgrid(x, y);

% Compute z = x sin(x) - y cos(y)
Z = X .* sin(X) - Y .* cos(Y);

% Plot the surface
figure(3);
surf(X, Y, Z);  % Create 3D surface plot
title('Surface Plot of z = x sin(x) - y cos(y)');  % Add title
xlabel('x');  % Label x-axis
ylabel('y');  % Label y-axis
zlabel('z');  % Label z-axis

%% Extra: MATLAB Logo
figure(4);
membrane;  % Plot the L-shaped membrane, representing the MATLAB logo
title('MATLAB Logo')  % Add title