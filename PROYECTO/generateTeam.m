function A = generateTeam(budget)
% GENERATETEAM - Generates a random valid team vector
%
% Inputs:
%   budget - total budget (default 100), must be 95-100
%
% Outputs:
%   A - 1x10 vector of non-negative integers summing to budget

    if nargin < 1
        budget = 100;
    end

    % Start with all ones (guarantees positive base)
    A = ones(1, 10);
    remaining = budget - 10;

    % Distribute remaining budget randomly
    for i = 1:remaining
        idx = randi(10);
        A(idx) = A(idx) + 1;
    end
end
