% =========================================================================
% INTERÓPTIMO DE LAGRANGE - TORNEO DE ESTRATEGIAS (LIGA PRIVADA)
% =========================================================================
clear; clc;

% --- 1. CONFIGURACIÓN DE RUTAS ---
rutaProyecto = '..\PROYECTO';
addpath(genpath(rutaProyecto));

fprintf('======================================================\n');
fprintf('🏆 INICIANDO EL TORNEO DE METAHEURÍSTICAS 🏆\n');
fprintf('======================================================\n\n');

% --- 2. GENERACIÓN DE CANDIDATOS ---
% Vamos a sacar 4 equipos con 4 estrategias distintas. 
% Usamos parámetros rápidos para no eternizar la prueba.

% 1. El Baseline (Crashing / PL)
fprintf('Generando Candidato 1: Crashing Baseline...\n');
try 
    load('sensitivity_baseline.mat', 'results');
    eq_crashing = crashingBaseline(results.deltas);
catch
    eq_crashing = [3, 3, 15, 3, 15, 3, 15, 3, 20, 20]; % Fallback seguro
end

% 2. El Evolutivo (Algoritmo Genético)
fprintf('Generando Candidato 2: Algoritmo Genético...\n');
gaOpts = struct('popSize', 50, 'generations', 30, 'numRivales', 30, 'numPartidos', 10, 'verbose', false);
[eq_ga, ~, ~] = geneticAlgorithm(gaOpts);

% 3. El Refinado (Recocido Simulado)
fprintf('Generando Candidato 3: Recocido Simulado...\n');
saOpts = struct('maxIter', 1000, 'T0', 2, 'alpha', 0.99, 'numRivales', 30, 'numPartidos', 10, 'verbose', false);
[eq_sa, ~, ~] = simulatedAnnealing(eq_ga, saOpts); % Partimos del GA para afinar

% 4. El Aleatorio Puro (Fuerza Bruta)
fprintf('Generando Candidato 4: Fuerza Bruta / Aleatorio...\n');
eq_rand = generar_valido();

% Guardamos los candidatos en una estructura
candidatos = {eq_crashing, eq_ga, eq_sa, eq_rand};
nombres = {'Crashing Baseline', 'Algoritmo Genético', 'Recocido Simulado', 'Fuerza Bruta'};
num_equipos = length(candidatos);

% --- 3. LIGA PRIVADA (TODOS CONTRA TODOS) ---
fprintf('\n⚔️ INICIANDO ENFRENTAMIENTOS DIRECTOS (500 partidos por cruce) ⚔️\n');
partidos_cruce = 1000;
matriz_puntos = zeros(num_equipos, 1);
matriz_goles = zeros(num_equipos, 2); % [GF, GC]

for i = 1:num_equipos
    for j = 1:num_equipos
        if i ~= j
            puntos_i = 0; gf_cruce = 0; gc_cruce = 0;
            
            for k = 1:partidos_cruce
                % Usamos playMatch.p para la verdad absoluta
                [gf, gc] = playMatch(candidatos{i}, candidatos{j});
                gf_cruce = gf_cruce + gf;
                gc_cruce = gc_cruce + gc;
                
                if gf > gc
                    puntos_i = puntos_i + 3;
                elseif gf == gc
                    puntos_i = puntos_i + 1;
                end
            end
            
            % Acumulamos en la tabla general
            matriz_puntos(i) = matriz_puntos(i) + puntos_i;
            matriz_goles(i, 1) = matriz_goles(i, 1) + gf_cruce;
            matriz_goles(i, 2) = matriz_goles(i, 2) + gc_cruce;
        end
    end
end

% --- 4. CLASIFICACIÓN FINAL ---
diferencia_goles = matriz_goles(:,1) - matriz_goles(:,2);
% Ordenamos por Puntos y luego por Diferencia de Goles
tabla = [matriz_puntos, diferencia_goles, (1:num_equipos)'];
tabla_ordenada = sortrows(tabla, [1, 2], 'descend');

fprintf('\n======================================================\n');
fprintf('📊 RESULTADOS FINALES DEL TORNEO 📊\n');
fprintf('======================================================\n');
fprintf('%-20s | %-6s | %-4s \n', 'ESTRATEGIA', 'PUNTOS', 'DIF. GOLES');
fprintf('------------------------------------------------------\n');

for i = 1:num_equipos
    idx = tabla_ordenada(i, 3);
    fprintf('%-20s | %6d | %+4d \n', nombres{idx}, matriz_puntos(idx), diferencia_goles(idx));
end

ganador_idx = tabla_ordenada(1, 3);
v_campeon_torneo = candidatos{ganador_idx};

fprintf('\n👑 CAMPEÓN ABSOLUTO: %s 👑\n', nombres{ganador_idx});
fprintf('Vector: [%2d %2d %2d %2d %2d %2d %2d %2d %2d %2d]\n', v_campeon_torneo);
save('campeon_torneo.mat', 'v_campeon_torneo');
fprintf('El vector ganador ha sido guardado en "campeon_torneo.mat"\n');

% Función auxiliar
function eq = generar_valido()
    eq = ones(1, 10);
    p = 90;
    for i=1:p, idx=randi(10); eq(idx)=eq(idx)+1; end
end