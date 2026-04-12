function results = sensitivityAnalysis(baseTeam, nRivals, nMatches)
% SENSITIVITYANALYSIS - Analyzes impact of each parameter on win rate
%
% Inputs:
%   baseTeam  - 1x10 base team vector (default: balanced [10..10])
%   nRivals   - rivals per evaluation (default 150)
%   nMatches  - matches per rival (default 30)
%
% Outputs:
%   results   - struct with analysis data and generates plots

    if nargin < 1, baseTeam = 10*ones(1,10); end
    if nargin < 2, nRivals = 150; end
    if nargin < 3, nMatches = 30; end

    paramNames = {'FI','GO','JD','MA','OR','PR','PO','TR','EF','TE'};
    paramFull  = {'Finalizacion','Gen.Ofensiva','Juego Directo',...
                  'Marcaje','Org.Defensiva','Presion',...
                  'Posesion','Transicion','Eficacia','Tecnico'};

    fprintf('=== SENSITIVITY ANALYSIS ===\n');
    fprintf('Base team: [%s] sum=%d\n', num2str(baseTeam), sum(baseTeam));

    % --- 1. One-at-a-time sensitivity ---
    fprintf('\n--- One-at-a-time: vary each param +5/-5 from base ---\n');
    fprintf('%-15s  Base%%  -5%%    +5%%    Delta\n', 'Parameter');
    fprintf('%s\n', repmat('-', 1, 55));

    baseWR = evaluateTeam(baseTeam, nRivals, nMatches);
    deltas = zeros(10, 1);

    for p = 1:10
        % -5 variant (redistribute to all others equally)
        teamMinus = baseTeam;
        reduction = min(5, teamMinus(p));
        teamMinus(p) = teamMinus(p) - reduction;
        % Add back to maintain budget
        others = setdiff(1:10, p);
        for k = 1:reduction
            idx = others(randi(length(others)));
            teamMinus(idx) = teamMinus(idx) + 1;
        end

        % +5 variant (take from others)
        teamPlus = baseTeam;
        teamPlus(p) = teamPlus(p) + 5;
        % Remove from others
        for k = 1:5
            nonzero_others = others(teamPlus(others) > 0);
            if isempty(nonzero_others), break; end
            idx = nonzero_others(randi(length(nonzero_others)));
            teamPlus(idx) = teamPlus(idx) - 1;
        end

        wrMinus = evaluateTeam(teamMinus, nRivals, nMatches);
        wrPlus  = evaluateTeam(teamPlus, nRivals, nMatches);
        deltas(p) = wrPlus - wrMinus;

        fprintf('%-15s  %.1f   %.1f   %.1f   %+.1f\n', ...
            paramFull{p}, 100*baseWR, 100*wrMinus, 100*wrPlus, 100*deltas(p));
    end

    % --- 2. Rank parameters by impact ---
    fprintf('\n--- PARAMETER RANKING (by sensitivity delta) ---\n');
    [sortedDeltas, sortIdx] = sort(deltas, 'descend');
    for i = 1:10
        fprintf('%2d. %-15s  delta=%+.1f%%\n', i, paramFull{sortIdx(i)}, 100*sortedDeltas(i));
    end

    % --- 3. Generate bar chart ---
    figure('Name', 'Sensitivity Analysis', 'Position', [100 100 800 400]);
    bar(deltas * 100);
    set(gca, 'XTickLabel', paramNames);
    ylabel('Win Rate Change (%)');
    title('Parameter Sensitivity: Effect of +5/-5 on Win Rate');
    grid on;

    results.paramNames = paramNames;
    results.deltas = deltas;
    results.baseWR = baseWR;
    results.sortIdx = sortIdx;

    fprintf('\nAnalysis complete.\n');
end
