function [teams, teamNames] = lector()

files = dir('*.mat');

numTeams = length(files);

teams = zeros(numTeams,10);
teamNames = zeros(numTeams,1);

for i = 1:numTeams
    
    filename = files(i).name;
    
    % nombre del equipo
    teamNames(i) = str2double(erase(filename,'.mat'));
    
    % cargar archivo
    data = load(filename);
    
    % extraer vector (única variable del archivo)
    fn = fieldnames(data);
    v = data.(fn{1});
    
    % asegurar vector fila
    teams(i,:) = v(:)';
    
end
end