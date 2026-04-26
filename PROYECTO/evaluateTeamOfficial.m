function [tasaVictorias, tasaEmpates, tasaDerrotas, mediaGF, mediaGC, ...
          diferenciaGolesMedia, puntosLigaMedios] = ...
          evaluateTeamOfficial(equipo, numRivales, numPartidos, engine)
% EVALUATETEAM OFICIAL - Evalúa un equipo con el simulador elegido
%
% Parámetros de entrada:
%   equipo      - vector 1x10 a evaluar
%   numRivales  - número de rivales aleatorios distintos (por defecto 200)
%   numPartidos - partidos por rival (por defecto 30)
%   engine      - 'official' usa playMatch.p; 'open' usa playMatchOpen.m
%                 (por defecto 'official', con fallback a 'open' si no existe)
%
% Salidas:
%   tasaVictorias        - fracción de partidos ganados
%   tasaEmpates          - fracción de empates
%   tasaDerrotas         - fracción de partidos perdidos
%   mediaGF              - media de goles a favor por partido
%   mediaGC              - media de goles en contra por partido
%   diferenciaGolesMedia - mediaGF - mediaGC (desempate liga)
%   puntosLigaMedios     - 3*victorias + 1*empates por partido
%
% El engine 'official' espera playMatch en el path. Si no se encuentra,
% se hace fallback automático a 'open' con un aviso por consola.

    if nargin < 2 || isempty(numRivales),  numRivales  = 200; end
    if nargin < 3 || isempty(numPartidos), numPartidos = 30;  end
    if nargin < 4 || isempty(engine),      engine      = 'official'; end

    % Resolver engine: si el oficial no está en el path, caer al abierto
    usaOficial = strcmpi(engine, 'official');
    if usaOficial && exist('playMatch', 'file') ~= 6 && exist('playMatch', 'file') ~= 2
        warning('evaluateTeamOfficial:NoOfficial', ...
            'playMatch no está en el path. Cayendo a playMatchOpen.');
        usaOficial = false;
    end

    victorias = 0;
    empates   = 0;
    derrotas  = 0;
    gfTotal   = 0;
    gcTotal   = 0;
    partidos  = 0;

    for r = 1:numRivales
        rival = generateTeam(100);
        for p = 1:numPartidos
            if usaOficial
                [gf, gc] = playMatch(equipo, rival);
            else
                [gf, gc] = playMatchOpen(equipo, rival);
            end
            gfTotal = gfTotal + gf;
            gcTotal = gcTotal + gc;
            if gf > gc
                victorias = victorias + 1;
            elseif gc > gf
                derrotas  = derrotas  + 1;
            else
                empates   = empates   + 1;
            end
            partidos = partidos + 1;
        end
    end

    tasaVictorias        = victorias / partidos;
    tasaEmpates          = empates   / partidos;
    tasaDerrotas         = derrotas  / partidos;
    mediaGF              = gfTotal   / partidos;
    mediaGC              = gcTotal   / partidos;
    diferenciaGolesMedia = mediaGF - mediaGC;
    puntosLigaMedios     = (3*victorias + 1*empates) / partidos;
end
