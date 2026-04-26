% =========================================================================
% BUSCADOR DEL ESPECIALISTA EN COPA (02.mat)
% =========================================================================
clear; clc;

% --- CONFIGURACIÓN DE RUTAS ---
% Añadimos tu carpeta de proyecto para que MATLAB encuentre playMatchOpen.m
rutaProyecto = '..\PROYECTO';
addpath(genpath(rutaProyecto));

% --- CONFIGURACIÓN DE BÚSQUEDA ---
numCandidatos = 10000;
mejorWR = 0;
mejorEquipoCopa = zeros(1, 10);

fprintf('Buscando el equipo especialista para la Copa...\n');
fprintf('Restricciones de Penaltis: Finalización (A1)>=16, Técnico (A10)>=16, Presión (A6)<=5\n\n');

for i = 1:numCandidatos
    % 1. Generar vector válido: suma exacta 100 y mínimo 1 (PDF exige positivas, no ceros)
    eq = ones(1, 10);
    for p = 1:90
        idx = randi(10);
        eq(idx) = eq(idx) + 1;
    end
    
    % 2. Aplicar el filtro estricto de la Copa
    if eq(1) >= 16 && eq(10) >= 16 && eq(6) <= 5
        
        % 3. Si pasa el filtro, evaluar su rendimiento en juego regular
        % Lo probamos contra un equipo balanceado (10 en todo)
        rival = [10, 10, 10, 10, 10, 10, 10, 10, 10, 10];
        victorias = 0;
        
        % Simulamos 50 partidos para ver si además de tirar bien penaltis, gana jugando
        for k = 1:50
            [gf, gc] = playMatchOpen(eq, rival);
            if gf > gc
                victorias = victorias + 1;
            end
        end
        wr = (victorias / 50) * 100;
        
        % 4. Guardar si es el mejor hasta ahora
        if wr > mejorWR
            mejorWR = wr;
            mejorEquipoCopa = eq;
            fprintf('Nuevo candidato de Copa: [%s] -> Win-Rate regular: %.1f%%\n', num2str(eq), wr);
        end
    end
end

fprintf('\n======================================================\n');
fprintf('🏆 EQUIPO DE COPA DEFINITIVO ENCONTRADO 🏆\n');
fprintf('Vector: [%s]\n', num2str(mejorEquipoCopa));
fprintf('Win-Rate estimado en partido regular: %.1f%%\n', mejorWR);
fprintf('Guarda este vector como tu archivo 02.mat\n');
fprintf('======================================================\n');