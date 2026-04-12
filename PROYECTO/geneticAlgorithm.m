function [bestTeam, bestFitness, history] = geneticAlgorithm(opts)
% GENETICALGORITHM - Genetic Algorithm to optimize a team vector
%
% Inputs:
%   opts - struct with optional fields:
%     .popSize      - population size (default 100)
%     .generations  - number of generations (default 200)
%     .nRivals      - rivals per fitness evaluation (default 100)
%     .nMatches     - matches per rival (default 20)
%     .eliteRate    - fraction of elite preserved (default 0.1)
%     .mutRate      - mutation probability per individual (default 0.3)
%     .tournSize    - tournament selection size (default 3)
%     .budget       - total budget (default 100)
%     .verbose      - print progress (default true)
%
% Outputs:
%   bestTeam    - best 1x10 team vector found
%   bestFitness - win rate of best team
%   history     - struct with convergence data

    if nargin < 1, opts = struct(); end
    popSize    = getOpt(opts, 'popSize', 100);
    generations= getOpt(opts, 'generations', 200);
    nRivals    = getOpt(opts, 'nRivals', 100);
    nMatches   = getOpt(opts, 'nMatches', 20);
    eliteRate  = getOpt(opts, 'eliteRate', 0.1);
    mutRate    = getOpt(opts, 'mutRate', 0.3);
    tournSize  = getOpt(opts, 'tournSize', 3);
    budget     = getOpt(opts, 'budget', 100);
    verbose    = getOpt(opts, 'verbose', true);

    nElite = max(1, round(popSize * eliteRate));

    % --- Initialize population ---
    pop = zeros(popSize, 10);
    for i = 1:popSize
        pop(i,:) = generateTeam(budget);
    end

    % Seed with known good candidates
    pop(1,:) = [8 8 8 8 8 8 8 8 16 20];     % high-tech baseline
    pop(2,:) = [12 10 8 10 10 7 8 8 12 15];  % candidate from analysis
    pop(3,:) = [10 8 8 8 8 8 8 8 14 20];     % variant
    pop(4,:) = [8 8 10 8 8 6 8 8 16 18];     % variant 2

    % --- Evaluate initial population ---
    fitness = zeros(popSize, 1);
    for i = 1:popSize
        fitness(i) = evaluateTeam(pop(i,:), nRivals, nMatches);
    end

    [bestFitness, bestIdx] = max(fitness);
    bestTeam = pop(bestIdx,:);

    history.bestFit = zeros(generations, 1);
    history.avgFit  = zeros(generations, 1);
    history.bestTeam = zeros(generations, 10);

    if verbose
        fprintf('Gen 0: Best=%.3f Avg=%.3f Team=[%s]\n', ...
            bestFitness, mean(fitness), num2str(bestTeam));
    end

    % --- Evolution loop ---
    for gen = 1:generations
        % Sort by fitness
        [fitness, sortIdx] = sort(fitness, 'descend');
        pop = pop(sortIdx, :);

        newPop = zeros(popSize, 10);

        % Elitism: keep top individuals
        newPop(1:nElite, :) = pop(1:nElite, :);

        % Fill rest with crossover + mutation
        for i = (nElite+1):popSize
            % Tournament selection for two parents
            p1 = tournamentSelect(pop, fitness, tournSize);
            p2 = tournamentSelect(pop, fitness, tournSize);

            % Crossover
            child = crossover(pop(p1,:), pop(p2,:), budget);

            % Mutation
            if rand() < mutRate
                child = mutate(child, budget);
            end

            newPop(i,:) = child;
        end

        pop = newPop;

        % Evaluate new population (skip elites to save time)
        newFitness = zeros(popSize, 1);
        newFitness(1:nElite) = fitness(1:nElite);
        for i = (nElite+1):popSize
            newFitness(i) = evaluateTeam(pop(i,:), nRivals, nMatches);
        end
        fitness = newFitness;

        [genBest, genBestIdx] = max(fitness);
        if genBest > bestFitness
            bestFitness = genBest;
            bestTeam = pop(genBestIdx,:);
        end

        history.bestFit(gen) = bestFitness;
        history.avgFit(gen) = mean(fitness);
        history.bestTeam(gen,:) = bestTeam;

        if verbose && (mod(gen,10)==0 || gen==1)
            fprintf('Gen %3d: Best=%.3f Avg=%.3f Team=[%s]\n', ...
                gen, bestFitness, mean(fitness), num2str(bestTeam));
        end
    end

    if verbose
        fprintf('\n=== GA RESULT ===\n');
        fprintf('Best team: [%s]\n', num2str(bestTeam));
        fprintf('Win rate:  %.1f%%\n', 100*bestFitness);
        fprintf('Sum: %d\n', sum(bestTeam));
    end
end

% --- Helper functions ---

function val = getOpt(opts, field, default)
    if isfield(opts, field)
        val = opts.(field);
    else
        val = default;
    end
end

function idx = tournamentSelect(pop, fitness, k)
    candidates = randperm(size(pop,1), k);
    [~, best] = max(fitness(candidates));
    idx = candidates(best);
end

function child = crossover(p1, p2, budget)
    % Uniform crossover with budget repair
    mask = rand(1,10) > 0.5;
    child = p1 .* mask + p2 .* (~mask);
    child = round(child);
    child = max(child, 0);
    child = repairBudget(child, budget);
end

function team = mutate(team, budget)
    % Multiple mutation types for diversity
    r = rand();
    if r < 0.5
        % Swap mutation: move points between two parameters
        i = randi(10);
        j = randi(10);
        while j == i, j = randi(10); end
        amount = randi(3);
        if team(i) >= amount
            team(i) = team(i) - amount;
            team(j) = team(j) + amount;
        end
    elseif r < 0.8
        % Random reset of one parameter + repair
        idx = randi(10);
        team(idx) = randi([0, 25]);
        team = repairBudget(team, budget);
    else
        % Scramble: shuffle a subset of parameters
        indices = randperm(10, 3);
        vals = team(indices);
        team(indices) = vals(randperm(3));
    end
end

function team = repairBudget(team, budget)
    % Ensure team sums to exactly budget with non-negative integers
    team = max(round(team), 0);
    diff = sum(team) - budget;
    while diff ~= 0
        if diff > 0
            % Remove from a random non-zero parameter
            nonzero = find(team > 0);
            idx = nonzero(randi(length(nonzero)));
            reduce = min(team(idx), diff);
            team(idx) = team(idx) - reduce;
            diff = diff - reduce;
        else
            % Add to a random parameter
            idx = randi(10);
            team(idx) = team(idx) + 1;
            diff = diff + 1;
        end
    end
end
