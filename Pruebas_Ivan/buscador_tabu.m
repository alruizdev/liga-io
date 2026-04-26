% =========================================================================
% INTERÓPTIMO DE LAGRANGE - BÚSQUEDA TABÚ (TABU SEARCH)
% =========================================================================
clear; clc;

% --- 1. CONFIGURACIÓN DE RUTAS ---
rutaProyecto = '..\PROYECTO';
addpath(genpath(rutaProyecto));

fprintf('Iniciando Búsqueda Tabú...\n');
t_inicio = tic;

% --- 2. PARÁMETROS TABÚ ---
maxIter = 300;           % Iteraciones totales
numVecinos = 30;         % Cuántos equipos vecinos miramos en cada turno
tenenciaTabu = 10;       % Cuántos turnos está prohibido deshacer un movimiento
numRivales = 100;         % Evaluación rápida
numPartidos = 30;

% Matriz Tabú: tabuList(i,j) guardará hasta qué iteración está prohibido
% el movimiento "Quitar a i, Sumar a j"
tabuList = zeros(10, 10); 

% --- 3. INICIO ---
% Partimos de vuestro equipo base actual para intentar mejorarlo
eq_actual = [6, 9, 9, 11, 10, 1, 6, 6, 24, 18]; 
[wr_actual, ~, ~] = evaluateTeam(eq_actual, numRivales, numPartidos);

eq_mejor_global = eq_actual;
wr_mejor_global = wr_actual;

fprintf('Equipo inicial: [%s] -> Win-Rate Base: %.1f%%\n', num2str(eq_actual), 100*wr_actual);

% --- 4. BUCLE DE BÚSQUEDA ---
for iter = 1:maxIter
    mejores_vecinos = zeros(numVecinos, 10);
    wr_vecinos = zeros(numVecinos, 1);
    movimientos = zeros(numVecinos, 2); % Guarda [idx_quitado, idx_sumado]
    
    % Generar vecindario (movimientos pequeños)
    for v = 1:numVecinos
        vecino = eq_actual;
        
        % Buscar alguien a quien quitarle (debe ser > 1 para no descalificar)
        idx_quitar = randi(10);
        while vecino(idx_quitar) <= 1
            idx_quitar = randi(10);
        end
        
        % Buscar alguien a quien sumarle
        idx_sumar = randi(10);
        while idx_sumar == idx_quitar
            idx_sumar = randi(10);
        end
        
        % Aplicar el movimiento
        vecino(idx_quitar) = vecino(idx_quitar) - 1;
        vecino(idx_sumar) = vecino(idx_sumar) + 1;
        
        mejores_vecinos(v, :) = vecino;
        movimientos(v, :) = [idx_quitar, idx_sumar];
        [wr_vecinos(v), ~, ~] = evaluateTeam(vecino, numRivales, numPartidos);
    end
    
    % Ordenar vecinos de mejor a peor
    [wr_vecinos_ord, idx_ord] = sort(wr_vecinos, 'descend');
    
    % Seleccionar el mejor vecino NO TABÚ (o que supere el global)
    movimiento_aceptado = false;
    for v = 1:numVecinos
        idx_real = idx_ord(v);
        q = movimientos(idx_real, 1); % Atributo reducido
        s = movimientos(idx_real, 2); % Atributo aumentado
        
        es_tabu = tabuList(q, s) > iter; % ¿Está prohibido este movimiento?
        criterio_aspiracion = wr_vecinos_ord(v) > wr_mejor_global; % ¿Bate récord?
        
        % Si no es tabú, O SI bate el récord histórico absoluto, lo aceptamos
        if ~es_tabu || criterio_aspiracion
            eq_actual = mejores_vecinos(idx_real, :);
            wr_actual = wr_vecinos_ord(v);
            
            % Prohibimos hacer el movimiento INVERSO durante 'tenenciaTabu' turnos
            tabuList(s, q) = iter + tenenciaTabu;
            movimiento_aceptado = true;
            break;
        end
    end
    
    % Actualizar el récord global
    if wr_actual > wr_mejor_global
        wr_mejor_global = wr_actual;
        eq_mejor_global = eq_actual;
        fprintf('¡NUEVO RÉCORD! Iter %d: [%s] -> %.1f%%\n', iter, num2str(eq_mejor_global), 100*wr_mejor_global);
    end
end

% --- 5. EVALUACIÓN FINAL ---
fprintf('\nRealizando evaluación de robustez final...\n');
[wr_final, ~, ~, gf, gc] = evaluateTeam(eq_mejor_global, 500, 100);
tiempo_minutos = toc(t_inicio) / 60;

v_tabu = eq_mejor_global;
save('resultado_tabu.mat', 'v_tabu');

fprintf('\n======================================================\n');
fprintf('⭐ MEJOR EQUIPO (BÚSQUEDA TABÚ) ⭐\n\n');
fprintf('Vector: [%2d  %2d  %2d  %2d  %2d  %2d  %2d  %2d  %2d  %2d]\n\n', eq_mejor_global);
fprintf('Win-Rate Final: %.1f%%\n\n', 100 * wr_final);
fprintf('Media Goles Favor: %.2f | Contra: %.2f\n\n', gf, gc);
fprintf('Tiempo total: %.1f minutos\n', tiempo_minutos);
fprintf('======================================================\n');