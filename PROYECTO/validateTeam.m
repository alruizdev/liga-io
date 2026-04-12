function [valid, msg] = validateTeam(A)
% VALIDATETEAM - Validates a team vector meets all constraints
%
% Inputs:
%   A - 1x10 vector representing a team
%
% Outputs:
%   valid - true if team is valid, false otherwise
%   msg   - description of issue (empty if valid)

    valid = true;
    msg = '';

    if length(A) ~= 10
        valid = false;
        msg = sprintf('Team must have 10 parameters, got %d', length(A));
        return;
    end

    if any(A < 0)
        valid = false;
        msg = 'All parameters must be non-negative (>= 0)';
        return;
    end

    if any(A ~= floor(A))
        valid = false;
        msg = 'All parameters must be integers';
        return;
    end

    s = sum(A);
    if s < 95 || s > 100
        valid = false;
        msg = sprintf('Budget must be 95-100, got %d', s);
        return;
    end
end
