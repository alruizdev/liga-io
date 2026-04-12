function [bestTeam, bestFitness, history] = simulatedAnnealing(initialTeam, opts)
% SIMULATEDANNEALING - Refines a team vector using Simulated Annealing
%
% Inputs:
%   initialTeam - 1x10 starting team vector (e.g. from GA)
%   opts - struct with optional fields:
%     .maxIter    - max iterations (default 5000)
%     .T0         - initial temperature (default 5)
%     .Tmin       - minimum temperature (default 0.01)
%     .alpha      - cooling rate (default 0.995)
%     .nRivals    - rivals per evaluation (default 100)
%     .nMatches   - matches per rival (default 20)
%     .budget     - total budget (default 100)
%     .verbose    - print progress (default true)
%
% Outputs:
%   bestTeam    - best team found
%   bestFitness - win rate of best team
%   history     - convergence data

    if nargin < 2, opts = struct(); end
    maxIter  = getOpt(opts, 'maxIter', 5000);
    T0       = getOpt(opts, 'T0', 5);
    Tmin     = getOpt(opts, 'Tmin', 0.01);
    coolRate = getOpt(opts, 'alpha', 0.995);
    nRivals  = getOpt(opts, 'nRivals', 100);
    nMatches = getOpt(opts, 'nMatches', 20);
    budget   = getOpt(opts, 'budget', 100);
    verbose  = getOpt(opts, 'verbose', true);

    % Initialize
    current = initialTeam;
    currentFit = evaluateTeam(current, nRivals, nMatches);
    bestTeam = current;
    bestFitness = currentFit;
    T = T0;

    history.fitness = zeros(maxIter, 1);
    history.bestFit = zeros(maxIter, 1);
    history.temp    = zeros(maxIter, 1);

    if verbose
        fprintf('SA Start: Fit=%.3f Team=[%s]\n', currentFit, num2str(current));
    end

    for iter = 1:maxIter
        % Generate neighbor
        neighbor = generateNeighbor(current, budget);

        % Evaluate neighbor
        neighborFit = evaluateTeam(neighbor, nRivals, nMatches);

        % Acceptance criterion
        deltaF = neighborFit - currentFit;
        if deltaF > 0 || rand() < exp(deltaF / T)
            current = neighbor;
            currentFit = neighborFit;
        end

        % Update best
        if currentFit > bestFitness
            bestTeam = current;
            bestFitness = currentFit;
        end

        % Cool down
        T = T * coolRate;
        if T < Tmin
            T = Tmin;
        end

        history.fitness(iter) = currentFit;
        history.bestFit(iter) = bestFitness;
        history.temp(iter) = T;

        if verbose && mod(iter, 200) == 0
            fprintf('SA Iter %4d: T=%.4f Current=%.3f Best=%.3f Team=[%s]\n', ...
                iter, T, currentFit, bestFitness, num2str(bestTeam));
        end
    end

    if verbose
        fprintf('\n=== SA RESULT ===\n');
        fprintf('Best team: [%s]\n', num2str(bestTeam));
        fprintf('Win rate:  %.1f%%\n', 100*bestFitness);
    end
end

function val = getOpt(opts, field, default)
    if isfield(opts, field)
        val = opts.(field);
    else
        val = default;
    end
end

function neighbor = generateNeighbor(team, budget)
    neighbor = team;
    r = rand();
    if r < 0.6
        % Swap: move 1-3 units between two parameters
        i = randi(10); j = randi(10);
        while j == i, j = randi(10); end
        amount = randi(min(3, max(1, neighbor(i))));
        if neighbor(i) >= amount
            neighbor(i) = neighbor(i) - amount;
            neighbor(j) = neighbor(j) + amount;
        end
    elseif r < 0.85
        % Double swap: two simultaneous moves
        indices = randperm(10, 4);
        amt1 = randi(min(2, max(1, neighbor(indices(1)))));
        amt2 = randi(min(2, max(1, neighbor(indices(3)))));
        if neighbor(indices(1)) >= amt1 && neighbor(indices(3)) >= amt2
            neighbor(indices(1)) = neighbor(indices(1)) - amt1;
            neighbor(indices(2)) = neighbor(indices(2)) + amt1;
            neighbor(indices(3)) = neighbor(indices(3)) - amt2;
            neighbor(indices(4)) = neighbor(indices(4)) + amt2;
        end
    else
        % Random perturbation + repair
        idx = randi(10);
        neighbor(idx) = randi([0, 30]);
        neighbor = repairBudget(neighbor, budget);
    end
end

function team = repairBudget(team, budget)
    team = max(round(team), 0);
    diff = sum(team) - budget;
    while diff ~= 0
        if diff > 0
            nonzero = find(team > 0);
            idx = nonzero(randi(length(nonzero)));
            reduce = min(team(idx), diff);
            team(idx) = team(idx) - reduce;
            diff = diff - reduce;
        else
            idx = randi(10);
            team(idx) = team(idx) + 1;
            diff = diff + 1;
        end
    end
end
