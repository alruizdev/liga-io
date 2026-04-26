% =========================================================================
% INTERÓPTIMO DE LAGRANGE - BÚSQUEDA DEL EQUIPO PERFECTO (OFFICIAL SIM)
% =========================================================================
clear; clc;

% --- CONFIGURACIÓN DE RUTAS ---
% Añadimos tu carpeta de proyecto para asegurar que encuentre los scripts
rutaProyecto = '..\PROYECTO';
addpath(genpath(rutaProyecto));

% --- PARÁMETROS DE ALTA INTENSIDAD (GA + SA) ---
% Ajustados según la recomendación 'Overnight' del proyecto 
fprintf('Iniciando búsqueda intensiva con el simulador OFICIAL del profesor...\n');
rng(2026); % Semilla fija para reproducibilidad

% 1. Fase de Algoritmo Genético (Exploración global)
gaOpts.popSize = 300;       % Población más grande para mayor diversidad
gaOpts.generations = 300;   % Más generaciones para converger mejor
gaOpts.numRivales = 150;    % Más rivales para una evaluación más robusta
gaOpts.numPartidos = 30;    % Más partidos para reducir la varianza (suerte)
gaOpts.verbose = true;

fprintf('\n--- Fase 1: Evolución del equipo (GA) ---\n');
tic;
[gaBest, ~, ~] = geneticAlgorithm(gaOpts);
t_ga = toc;

% 2. Fase de Recocido Simulado (Refinamiento local del mejor candidato)
saOpts.maxIter = 20000;     % 20.000 iteraciones para pulir el vector
saOpts.T0 = 4;              % Temperatura inicial
saOpts.alpha = 0.9995;      % Enfriamiento muy lento
saOpts.numRivales = 150;
saOpts.numPartidos = 30;
saOpts.verbose = true;

fprintf('\n--- Fase 2: Refinamiento táctico (SA) ---\n');
tic;
[equipoPerfecto, ~, ~] = simulatedAnnealing(gaBest, saOpts);
t_sa = toc;

% --- EVALUACIÓN FINAL DE ROBUSTEZ ---
fprintf('\n--- Fase 3: Validación final (Monte Carlo 500x100) ---\n');
[wr, ~, ~, gf, gc] = evaluateTeam(equipoPerfecto, 500, 100);

% --- RESULTADOS ---
fprintf('\n======================================================\n');
fprintf('⭐ EQUIPO PERFECTO ENCONTRADO ⭐\n');
fprintf('Vector: [%s]\n', num2str(equipoPerfecto));
fprintf('Win-Rate Final: %.1f%%\n', 100*wr);
fprintf('Media Goles Favor: %.2f | Contra: %.2f\n', gf, gc);
fprintf('Tiempo total: %.1f minutos\n', (t_ga + t_sa)/60);
fprintf('======================================================\n');

% Guardar el resultado automáticamente para no perderlo
v = equipoPerfecto;
save('equipo_perfecto_oficial.mat', 'v');
fprintf('Resultado guardado en equipo_perfecto_oficial.mat\n');