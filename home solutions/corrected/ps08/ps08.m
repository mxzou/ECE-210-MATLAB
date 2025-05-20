%% ECE 210 - Assignment 08: Corrected Code with Explanations
% Note: used with the help of MATLAB docs + Grok

% Housekeeping commands
clc;
clear;
close all;

%% Problem 1: Solve for BJT Cross-Sectional Area (A_E)

% Given equations:
% I_C = I_S * exp(V_BE / V_T)  [cf. cite: 39] Eq (1)
% I_S = (A_E * q * D_n * n_i^2) / (N_B * W_B) [cf. cite: 39] Eq (2)
% Goal: Solve for A_E in terms of I_C and other variables.

% Define symbolic variables
syms I_C V_BE V_T q D_n n_i N_B W_B A_E I_S % Include A_E and I_S too

% Define the two equations symbolically
eqn1 = I_C == I_S * exp(V_BE / V_T);
eqn2 = I_S == (A_E * q * D_n * n_i^2) / (N_B * W_B);

% Solve for A_E. We can first solve eqn1 for I_S, substitute into eqn2,
% and then solve for A_E. Or use solve on both equations.
% Let's try solving for I_S first:
I_S_solved = solve(eqn1, I_S); % Solves for I_S = I_C * exp(-V_BE/V_T)

% Substitute this into eqn2:
eqn2_subs = subs(eqn2, I_S, I_S_solved);
% Now eqn2_subs is: I_C * exp(-V_BE/V_T) == (A_E*q*D_n*n_i^2)/(N_B*W_B)

% Solve the substituted equation for A_E
A_E_solution = solve(eqn2_subs, A_E);

% Your original direct calculation method also works and gives the same result:
% syms I_C V_BE V_T q D_n ni NB W_B; % Original variables declared
% A_E_original = (I_C * NB * W_B) / (q * D_n * ni^2 * exp(V_BE / V_T)); [cf. cite: 2]
% This direct approach is likely sufficient here as the derivation is simple.
% We'll keep the result from the solve method for demonstration.

disp('Problem 1 Solution (Symbolic):');
fprintf('A_E = %s\n', char(A_E_solution)); % Display the symbolic solution [cf. cite: 2]

%% Problem 2: Solve RC Circuit Differential Equation

% Given differential equation:
% V_S(t) = R*C * dV_C(t)/dt + V_C(t) [cf. cite: 40] Eq (3)

% Define symbolic variables and functions
% *** CORRECTION 1: Explicitly declare R and C as symbolic variables. ***
% Your original code declared RC as a single variable [cf. cite: 3], but used R and C
% separately in the equation. Declaring them individually is correct practice.
syms V_C(t) V_S(t) R C t % Declare R and C separately

% Define the differential equation
% Your original equation was correct, assuming R and C were available.
eqn = V_S(t) == R*C*diff(V_C(t), t) + V_C(t); % [cf. cite: 3]

% Solve the differential equation using dsolve
% This finds the general solution including an integration constant (C1).
sol_Vc = dsolve(eqn, V_C(t)); % Solve for V_C(t) [cf. cite: 3]

disp(' '); % Add spacing
disp('Problem 2 Solution (Differential Equation):');
fprintf('V_C(t) = %s\n', char(sol_Vc)); % Display the general solution [cf. cite: 3]

%% Problem 3: Evaluate mu_0 to High Precision

% Goal: Evaluate mu_0 = 4*pi*10^-7 to ceil(1000*pi) decimal places [cf. cite: 41]

% Calculate the required number of decimal digits
% Your original calculation was correct.
num_digits = ceil(1000*pi); % [cf. cite: 4]
fprintf('\nCalculating mu_0 to %d decimal digits.\n', num_digits);

% Evaluate mu_0 using vpa (Variable-Precision Arithmetic)
% *** CORRECTION 2: Ensure the constant is fully symbolic before vpa. ***
% Your original code used numeric 4 and -7: vpa(4*sym(pi)*sym(10)^-7, n) [cf. cite: 4].
% While this might work, the hint suggested using sym() on the constant [cf. cite: 41].
% Applying sym() to the numeric part ensures it's treated symbolically.
mu0_symbolic_constant = sym(4)*sym(pi)*sym(10)^(-7); % Make the whole constant symbolic first
% Alternatively: mu0_symbolic_constant = sym('4*pi*1e-7');

mu0_high_precision = vpa(mu0_symbolic_constant, num_digits); % Evaluate to n digits [cf. cite: 4]

disp(' '); % Add spacing
disp('Problem 3 Solution (High Precision mu_0):');
disp(mu0_high_precision); % Display the high-precision result [cf. cite: 4]