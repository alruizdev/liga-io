function [tasaVictorias, tasaEmpates, tasaDerrotas, mediaGF, mediaGC] = evaluateTeam(equipo, numRivales, numPartidos)
% EVALUAR EQUIPO - Mide el rendimiento de un equipo por simulación Monte Carlo
%
% Simula el equipo contra muchos rivales aleatorios y devuelve la tasa de victorias.
% Cuanto mayor sea tasaVictorias, mejor es el equipo.
%
% PARÁMETROS:
%   equipo      - vector 1x10 del equipo a evaluar
%   numRivales  - cuántos rivales distintos generar (por defecto 200)
%   numPartidos - partidos contra cada rival (por defecto 30)
%
% SALIDAS:
%   tasaVictorias - fracción de partidos ganados [0,1]  → la más importante
%   tasaEmpates   - fracción de empates [0,1]
%   tasaDerrotas  - fracción de partidos perdidos [0,1]
%   mediaGF       - media de goles a favor por partido
%   mediaGC       - media de goles en contra por partido

    if nargin < 2, numRivales  = 200; end
    if nargin < 3, numPartidos = 30;  end

    victoriasTotal = 0;
    empatesTotal   = 0;
    derrotasTotal  = 0;
    golesAFavor    = 0;
    golesEnContra  = 0;
    partidosTotal  = 0;

    for r = 1:numRivales
        rival = generateTeam(100);           % rival aleatorio válido
        for p = 1:numPartidos
            [gf, gc] = playMatchOpen(equipo, rival);
            golesAFavor   = golesAFavor   + gf;
            golesEnContra = golesEnContra + gc;
            if gf > gc
                victoriasTotal = victoriasTotal + 1;
            elseif gc > gf
                derrotasTotal  = derrotasTotal  + 1;
            else
                empatesTotal   = empatesTotal   + 1;
            end
            partidosTotal = partidosTotal + 1;
        end
    end

    tasaVictorias = victoriasTotal / partidosTotal;
    tasaEmpates   = empatesTotal   / partidosTotal;
    tasaDerrotas  = derrotasTotal  / partidosTotal;
    mediaGF       = golesAFavor    / partidosTotal;
    mediaGC       = golesEnContra  / partidosTotal;
end
