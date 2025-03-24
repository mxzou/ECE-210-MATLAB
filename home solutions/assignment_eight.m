%% SPDX-License-Identifier: MIT License
%
% assignment_eight.m - HW08 Must Be Easy
% Copyright (C) 2024 Senik Zou <mengxuan.zou@cooper.edu>
%

% Problem 1: Solve for A_E in terms of I_C
syms I_C V_BE V_T q D_n n_i N_B W_B;
A_E = (I_C * N_B * W_B) / (q * D_n * n_i^2 * exp(V_BE / V_T));
disp('Problem 1 Solution:');
disp(['A_E = ' char(A_E)]);

% Problem 2: Solve the RC circuit differential equation
syms V_C(t) V_S(t) R C;
eqn = V_S(t) == R * C * diff(V_C(t), t) + V_C(t);
sol = dsolve(eqn);
disp('Problem 2 Solution:');
disp(sol);

% Problem 3: Evaluate mu0 to [1000*pi] decimal places
n = ceil(1000 * pi); % Calculate 3142 digits
mu0 = vpa(4 * sym(pi) * sym(10)^-7, n);
disp('Problem 3 Solution:');
disp(mu0);