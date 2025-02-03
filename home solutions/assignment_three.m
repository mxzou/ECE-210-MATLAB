% UNSTYLED

% SPDX-License-Identifier: GPL-3.0-or-later
%
% assignment03.m -- Third homework simulating Among Us game scenarios
% Copyright (C) 2024 Your Name <your.email@example.com>

% Initialize constants as provided
ITERATIONS = 1e6;
CREWMATES = 6;
ROUNDS = 12;
CREWMATE_SIDES = 4;
IMPOSTER_ROLLS = 2;
IMPOSTER_SIDES = 2;

% Set random seed for reproducibility
rng(0x73757300);

% 1. Generate random matrices for game events
% Create crewmate sus resistance (one d4 roll per crewmate per iteration)
crewmates = randi(CREWMATE_SIDES, [CREWMATES, ITERATIONS]);

% Generate imposter sus ability (sum of two d2 rolls per iteration)
imposter_rolls = randi(IMPOSTER_SIDES, [IMPOSTER_ROLLS, ITERATIONS]);
sus = sum(imposter_rolls, 1);

% Generate random targets for each round and iteration
targets = randi(CREWMATES, [ROUNDS, ITERATIONS]);

% 2. Create kills matrix
% Initialize kills matrix to track who dies when
kills = false(CREWMATES, ITERATIONS);

% For each round, determine if target dies
for round = 1:ROUNDS
    % Get current targets for this round
    current_targets = targets(round, :);
    % Get sus resistance of current targets
    target_resistance = crewmates(sub2ind(size(crewmates), ...
        current_targets, 1:ITERATIONS));
    % Determine if kill is successful (imposter sus > target resistance)
    successful_kills = sus > target_resistance;
    % Only count kills if target hasn't been killed yet
    valid_targets = ~any(kills(current_targets, :), 1);
    % Update kills matrix
    kills(sub2ind(size(kills), current_targets, 1:ITERATIONS)) = ...
        successful_kills & valid_targets;
end

% 3. Create survivors matrix
% A crewmate survives if they weren't killed
survivors = ~kills;

% 4. Calculate loss rate
% A loss occurs if 1 or fewer crewmates survive
loss_rate = mean(sum(survivors, 1) <= 1);

% Display result
fprintf('Loss rate: %.4f\n', loss_rate);

% Verify result matches expected value
if abs(loss_rate - 0.1174) < 1e-4
    disp('Success! Loss rate matches expected value.');
else
    warning('Loss rate does not match expected value!');
end