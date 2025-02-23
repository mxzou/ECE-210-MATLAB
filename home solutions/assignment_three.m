% Define constants for the simulation and set the random seed
ITERATIONS = 1e6;          % Total number of simulations to run (1,000,000)
CREWMATES = 6;             % Number of crewmates in each simulation (6)
ROUNDS = 12;               % Number of rounds in each simulation (12)
CREWMATE_SIDES = 4;        % Crewmate resistance is 1 to 4 (like a 4-sided die)
IMPOSTER_ROLLS = 2;        % Imposter rolls 2 dice to get sus ability
IMPOSTER_SIDES = 2;        % Each imposter die has 2 sides (1 or 2)
rng(0x73757300);           % Set random seed so results are the same every time (reproducibility)

% Create a matrix of crewmate resistances (6 crewmates x 1,000,000 iterations)
% Each crewmate gets a random resistance value between 1 and 4
crewmates = randi(CREWMATE_SIDES, CREWMATES, ITERATIONS);

% Generate the imposter's sus ability for each round (12 rounds x 1,000,000 iterations)
% Sus ability is the sum of two 2-sided die rolls (values 2, 3, or 4)
sus = randi(IMPOSTER_SIDES, ROUNDS, ITERATIONS) + randi(IMPOSTER_SIDES, ROUNDS, ITERATIONS);

% Decide which crewmate the imposter targets each round (12 rounds x 1,000,000 iterations)
% Targets are random numbers from 1 to 6, picking one of the 6 crewmates
targets = randi(CREWMATES, ROUNDS, ITERATIONS);

% Get the resistance of the crewmate targeted in each round
% This uses linear indexing: calculates the position in the crewmates matrix for each target
% (repmat(1:ITERATIONS, ROUNDS, 1) - 1) * CREWMATES + targets finds the exact spot
targeted_resistances = crewmates((repmat(1:ITERATIONS, ROUNDS, 1) - 1) * CREWMATES + targets);

% Check where the imposter’s sus beats the targeted crewmate’s resistance
% Returns a 12x1,000,000 logical matrix (true where sus > resistance, false otherwise)
potential_kills = sus > targeted_resistances;

% Build a mask showing when each crewmate was targeted
% Reshape targets to 12x1x1,000,000 and compare to 1:6 (reshaped to 1x6x1)
% Result is 12x6x1,000,000: true where a crewmate was the target in that round
target_mask = reshape(targets, [ROUNDS, 1, ITERATIONS]) == reshape(1:CREWMATES, [1, CREWMATES, 1]);

% Find actual kills by combining the target mask with potential kills
% 12x6x1,000,000 logical array: true where a crewmate was targeted AND sus > resistance
kill_attempts = target_mask & reshape(potential_kills, [ROUNDS, 1, ITERATIONS]);

% Check if each crewmate was killed at least once across the 12 rounds
% any() looks along rounds (dimension 1), then squeeze makes it 6x1,000,000
% True means that crewmate was killed at least once in that iteration
kills = squeeze(any(kill_attempts, 1));

% Identify survivors: flip the kills matrix (true where crewmates weren’t killed)
survivors = ~kills;

% Count survivors per iteration and calculate the loss probability
% sum(survivors, 1) gives number of survivors in each iteration (1x1,000,000 vector)
% <= 1 checks for 0 or 1 survivors (a loss), mean gives the fraction of losses
loss_rate = mean(sum(survivors, 1) <= 1);