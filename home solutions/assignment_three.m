%% SPDX-License-Identifier: MIT License
%
% assignment_three.m - Amongus HW03 solution ECE-211 MATLAB course
% Copyright (C) 2024 Senik Zou <mengxuan.zou@cooper.edu>
%

% define game constants
ITERATIONS = 1e6; % total num of simulations (1,000,000)
CREWMATES = 6;
ROUNDS = 12;
CREWMATE_SIDES = 4;       % Crewmate resistance is 1 to 4 (like d4 die)
IMPOSTER_ROLLS = 2;       % Imposter rolls 2 dice to get sus ability
IMPOSTER_SIDES = 2;       % Each imposter die has 2 sides (1 or 2)

% set random seed for reproducibility
rng(0x73757300);

% generate random values between 1 - 4 for each crewmate across all
% iterations. CREWMATES x ITERATIONS matrix where each column represents
% one game simulation, row represents a crewmate's resistance value
crewmates = randi(CREWMATE_SIDES, CREWMATES, ITERATIONS);

% sum of two 2-sided die rolls (values 2, 3 or 4)
sus = randi(IMPOSTER_SIDES, ROUNDS, ITERATIONS) + ...
    randi(IMPOSTER_SIDES, ROUNDS, ITERATIONS);

% ROUNDS x ITERATIONS matrix where each value is index (1 to CREWMATES)
targets = randi(CREWMATES, ROUNDS, ITERATIONS);

% map each target to their resistance value using linear indexing
idx = (repmat(1:ITERATIONS, ROUNDS, 1) - 1) * CREWMATES + targets;
targeted_resistances = crewmates(idx);

% compare imposter's sus ability to target's resistance
potential_kills = sus > targeted_resistances;

% creates mask of dimensions [ROUNDS x CREWMATES x ITERATIONS]
target_mask = reshape(targets, [ROUNDS, 1, ITERATIONS]) == ...
    reshape(1:CREWMATES, [1, CREWMATES, 1]);

% combine mask with potential kills
kill_attempts = target_mask & reshape(potential_kills, [ROUNDS, 1, ITERATIONS]);

% determine if any crewmate was killed in any round
kills = squeeze(any(kill_attempts, 1));

% create logical array of survivors (opposite of kills)
survivors = ~kills;

% calculate imposter win rate
loss_rate = mean(sum(survivors, 1) <= 1);
