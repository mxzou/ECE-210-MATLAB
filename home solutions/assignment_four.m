%% SPDX-License-Identifier: MIT License
%
% assignment_four.m - HW04 Orthonormal Basis Calculation
% Copyright (C) 2024 Senik Zou <mengxuan.zou@cooper.edu>
%

ip = @(x, y) x' * y;             % inner product
np_norm = @(x) sqrt(ip(x, x));   % L2 norm (Euclidean norm) note: the
% "length" of a vector in n-dimensional space

% define the set of vectors S as columns
% note: in MATLAB, both i or j can be used for the imaginary unit
S = [1i, 2 - 1i, -1 + 1i, 6 + 10i
     1i, (1i - 1), 2i, 3 + 4i];

Q = gram_schmidt(S, np_norm); % obtain an orthonormal basis from S

U = Q(:, 1:2); % pick two orthonormal vectors (the first two nonzero columns)

% verify that the columns of U are orthonormal
orthonormal = is_orthonormal(U, np_norm); 

disp('Orthonormal vectors U =');
disp(U);
disp('Are these vectors orthonormal?');
disp(orthonormal);

%{
This function checks if the matrix A has orthonormal columns by
1. Computing A' * A, which for orthonormal columns = the I matrix
2. Creating identity matrix with dimensions matching columns in A
3. Taking the norm of the difference - if close to zero, columns are orthonormal
%}
function val = is_orthonormal(a, norm_func)
    diff_matrix = a' * a - eye(size(a, 2));
    diff_vector = diff_matrix(:);  % reshape matrix to column vector
    if norm_func(diff_vector) < 1e-12
        val = true;
    else
        val = false;
    end
end

%{
The Gram-Schmidt process function takes a matrix A whose columns are vectors
and produces and creates an empy Q matrix of the same size
%}
function q = gram_schmidt(a, norm_func)
    [n, m] = size(a);
    q = zeros(n, m); % creates an empty matrix Q of same size
    
    % iterates through each column of matrix A
    for k = 1:m
        v = a(:, k); % sets a vector
        for j = 1:k - 1
            v = v - (q(:, j)' * a(:, k)) * q(:, j); % for each vector its
            % projection
        end % subtracting this projection from v makes v orthogonal to Q(:,j)
        
        if norm_func(v) > 1e-14 % avoid division by very small numbers
            q(:, k) = v / norm_func(v); % normalizes v by dividing by its norm
        else
            q(:, k) = zeros(n, 1);
        end
    end
end % the result is stored in Q(:,k)
