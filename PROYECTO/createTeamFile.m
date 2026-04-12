function createTeamFile(team, serial)
% CREATETEAMFILE - Saves a team vector as a .mat file for submission
%
% Inputs:
%   team   - 1x10 team vector
%   serial - serial number string (e.g. '01', '02')
%
% Example:
%   createTeamFile([9 4 10 10 12 0 11 0 27 17], '01')
%   -> creates file '01.mat' containing the team vector

    % Validate
    [valid, msg] = validateTeam(team);
    if ~valid
        error('Invalid team: %s', msg);
    end

    % Ensure row vector of doubles
    team = double(team(:)');

    % Save as .mat file
    filename = sprintf('%s.mat', serial);
    save(filename, 'team');

    % Verify by reading back
    data = load(filename);
    fn = fieldnames(data);
    loaded = data.(fn{1});

    if isequal(loaded, team)
        fprintf('SUCCESS: Saved team to %s\n', filename);
        fprintf('  Vector: [%s]\n', num2str(team));
        fprintf('  Sum: %d\n', sum(team));
        fprintf('  Verified: read-back matches original\n');
    else
        error('VERIFICATION FAILED: saved data does not match input');
    end

    % Also verify with lector.m format
    fprintf('\n  Testing with lector.m format...\n');
    try
        loaded2 = load(filename);
        fn2 = fieldnames(loaded2);
        v = loaded2.(fn2{1});
        v = v(:)';
        fprintf('  lector.m compatible: [%s] (1x%d double)\n', num2str(v), length(v));
    catch e
        fprintf('  WARNING: lector.m compatibility issue: %s\n', e.message);
    end
end
