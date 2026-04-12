%% MAIN - Liga IO 2026 - Team Optimization Pipeline
% Run this script to execute the full optimization workflow.
% Adjust parameters in each section as needed.

clear; clc;
fprintf('========================================\n');
fprintf('  LIGA IO 2026 - Team Optimizer\n');
fprintf('========================================\n\n');

%% 1. CONFIGURATION
SERIAL_1 = '01';  % <-- CHANGE to your assigned serial
SERIAL_2 = '02';  % <-- CHANGE to your second serial (optional)
RUN_GA = true;
RUN_SA = true;
RUN_SENSITIVITY = false;  % set true for full analysis (slow)
FINAL_EVAL_RIVALS = 500;
FINAL_EVAL_MATCHES = 100;

%% 2. GENETIC ALGORITHM
if RUN_GA
    fprintf('--- Phase 1: Genetic Algorithm ---\n');
    gaOpts.popSize = 100;
    gaOpts.generations = 80;
    gaOpts.nRivals = 80;
    gaOpts.nMatches = 20;
    gaOpts.verbose = true;

    tic;
    [gaTeam, gaFit, gaHistory] = geneticAlgorithm(gaOpts);
    gaTime = toc;
    fprintf('GA completed in %.1f seconds\n\n', gaTime);
else
    % Use previously known best
    gaTeam = [9 4 10 10 12 0 11 0 27 17];
    gaFit = 0;
    fprintf('Skipped GA, using preset team\n\n');
end

%% 3. SIMULATED ANNEALING (refine GA result)
if RUN_SA
    fprintf('--- Phase 2: Simulated Annealing ---\n');
    saOpts.maxIter = 2000;
    saOpts.T0 = 3;
    saOpts.alpha = 0.997;
    saOpts.nRivals = 80;
    saOpts.nMatches = 20;
    saOpts.verbose = true;

    tic;
    [saTeam, saFit, saHistory] = simulatedAnnealing(gaTeam, saOpts);
    saTime = toc;
    fprintf('SA completed in %.1f seconds\n\n', saTime);
else
    saTeam = gaTeam;
    saFit = gaFit;
end

%% 4. FINAL EVALUATION
fprintf('--- Phase 3: Final Evaluation ---\n');
fprintf('Evaluating with %d rivals x %d matches...\n', ...
    FINAL_EVAL_RIVALS, FINAL_EVAL_MATCHES);

[wr1,dr1,lr1,gf1,ga1] = evaluateTeam(saTeam, FINAL_EVAL_RIVALS, FINAL_EVAL_MATCHES);
fprintf('\nTEAM 1 (Liga): [%s]\n', num2str(saTeam));
fprintf('  Sum: %d\n', sum(saTeam));
fprintf('  Win: %.1f%%  Draw: %.1f%%  Loss: %.1f%%\n', 100*wr1, 100*dr1, 100*lr1);
fprintf('  Goals For: %.2f  Goals Against: %.2f\n', gf1, ga1);

%% 5. OPTIONAL: Second team for Copa
fprintf('\n--- Copa Team (variant optimized for penalties) ---\n');
% Copa priorities: high TE, FI, moral, low fatigue
copaTeam = saTeam;
% Boost TE and FI if possible
fprintf('Copa team: [%s] sum=%d\n', num2str(copaTeam), sum(copaTeam));
[wr2,dr2,lr2,gf2,ga2] = evaluateTeam(copaTeam, FINAL_EVAL_RIVALS, FINAL_EVAL_MATCHES);
fprintf('  Win: %.1f%%  Draw: %.1f%%  Loss: %.1f%%\n', 100*wr2, 100*dr2, 100*lr2);

%% 6. SENSITIVITY ANALYSIS (optional)
if RUN_SENSITIVITY
    fprintf('\n--- Phase 4: Sensitivity Analysis ---\n');
    results = sensitivityAnalysis(saTeam, 100, 20);
end

%% 7. SAVE TEAMS
fprintf('\n--- Phase 5: Saving Teams ---\n');
fprintf('Team 1 (Liga):  [%s]\n', num2str(saTeam));
createTeamFile(saTeam, SERIAL_1);

% Uncomment to save second team:
% createTeamFile(copaTeam, SERIAL_2);

%% 8. SUMMARY
fprintf('\n========================================\n');
fprintf('  OPTIMIZATION COMPLETE\n');
fprintf('========================================\n');
fprintf('Team 1: [%s] | Win=%.1f%%\n', num2str(saTeam), 100*wr1);
fprintf('File: %s.mat\n', SERIAL_1);
fprintf('\nRemember:\n');
fprintf('  - Verify .mat with lector.m before submitting\n');
fprintf('  - Only the designated person uploads\n');
fprintf('  - Upload ONCE - no re-uploads allowed\n');
fprintf('========================================\n');
