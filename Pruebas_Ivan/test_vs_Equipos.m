% =========================================================================
% INTERÓPTIMO DE LAGRANGE - TEST DE ESTRÉS CONTRA ARQUETIPOS
% =========================================================================
clear; clc;

rutaProyecto = '..\PROYECTO';
addpath(genpath(rutaProyecto));

% Tu mejor equipo actual (Cámbialo por el que haya ganado vuestros torneos)
mi_equipo = [6, 9, 9, 11, 10, 1, 6, 6, 24, 18];

% --- DEFINICIÓN DE ARQUETIPOS (Suman 100, min 1) ---
% Orden: [FI, GO, JD, MA, OR, PR, PO, TR, EF, TE]
arquetipos.Balanceado   = [10, 10, 10, 10, 10, 10, 10, 10, 10, 10];
arquetipos.TikiTaka     = [ 5, 15,  1,  5,  5, 15, 25,  5,  5, 19]; % Posesión, Técnica, Ofensiva
arquetipos.Catenaccio   = [ 2,  2, 10, 25, 25,  5,  5, 10, 10,  6]; % Defensa brutal, Juego Directo
arquetipos.Gegenpress   = [10, 10,  5,  5,  5, 25,  5, 20, 10,  5]; % Presión máxima, Transición
arquetipos.Cristal      = [25,  1,  1,  1,  1,  1,  1,  1, 35, 33]; % Todo a Eficacia/Finalización/Técnico

nombres = fieldnames(arquetipos);
partidos = 1000;

fprintf('======================================================\n');
fprintf('🛡️ TEST DE ESTRÉS TÁCTICO (1.000 partidos por estilo) 🛡️\n');
fprintf('======================================================\n\n');

for i = 1:length(nombres)
    rival = arquetipos.(nombres{i});
    victorias = 0; empates = 0; derrotas = 0;
    
    for k = 1:partidos
        [gf, gc] = playMatch(mi_equipo, rival); % Usamos el oficial
        if gf > gc, victorias = victorias + 1;
        elseif gf == gc, empates = empates + 1;
        else, derrotas = derrotas + 1;
        end
    end
    
    wr = (victorias/partidos)*100;
    fprintf('%-15s -> Victorias: %5.1f%% | Empates: %5.1f%% | Derrotas: %5.1f%%\n', ...
            nombres{i}, wr, (empates/partidos)*100, (derrotas/partidos)*100);
            
    if wr < 40
        fprintf('   ⚠️ ALERTA: Nuestro equipo es vulnerable a este estilo.\n');
    end
end
fprintf('\n======================================================\n');