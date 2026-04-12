function [winRate, drawRate, lossRate, avgGF, avgGA] = evaluateTeam(team, nRivals, nMatches)
% EVALUATETEAM - Evaluates a team's performance via Monte Carlo simulation
%
% Inputs:
%   team     - 1x10 team vector
%   nRivals  - number of random rival teams to test against (default 200)
%   nMatches - number of matches per rival (default 30)
%
% Outputs:
%   winRate  - fraction of matches won [0,1]
%   drawRate - fraction of matches drawn [0,1]
%   lossRate - fraction of matches lost [0,1]
%   avgGF    - average goals scored per match
%   avgGA    - average goals conceded per match

    if nargin < 2, nRivals = 200; end
    if nargin < 3, nMatches = 30; end

    totalWins = 0;
    totalDraws = 0;
    totalLosses = 0;
    totalGF = 0;
    totalGA = 0;
    totalGames = 0;

    for r = 1:nRivals
        rival = generateTeam(100);
        for m = 1:nMatches
            [gA, gB] = playMatchOpen(team, rival);
            totalGF = totalGF + gA;
            totalGA = totalGA + gB;
            if gA > gB
                totalWins = totalWins + 1;
            elseif gB > gA
                totalLosses = totalLosses + 1;
            else
                totalDraws = totalDraws + 1;
            end
            totalGames = totalGames + 1;
        end
    end

    winRate  = totalWins / totalGames;
    drawRate = totalDraws / totalGames;
    lossRate = totalLosses / totalGames;
    avgGF    = totalGF / totalGames;
    avgGA    = totalGA / totalGames;
end
