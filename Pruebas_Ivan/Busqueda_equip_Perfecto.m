% =========================================================================
% INTERÓPTIMO DE LAGRANGE - BÚSQUEDA DEL EQUIPO PERFECTO (OFFICIAL SIM)
% =========================================================================
clear; clc;

% --- CONFIGURACIÓN DE RUTAS ---
% Añadimos la carpeta del proyecto y la propia (donde vive playMatch.p)
rutaProyecto = '..\PROYECTO';
addpath(genpath(rutaProyecto));
addpath(pwd);

% --- PARÁMETROS DE ALTA INTENSIDAD (GA + SA) ---
fprintf('Iniciando búsqueda intensiva con el simulador OFICIAL del profesor...\n');
rng(2026); % Semilla fija para reproducibilidad

% 1. Fase de Algoritmo Genético (Exploración global)
gaOpts.tamPoblacion    = 300;
gaOpts.generaciones    = 300;
gaOpts.numRivales      = 150;
gaOpts.numPartidos     = 30;
gaOpts.porcentajeElite = 0.10;
gaOpts.probMutacion    = 0.30;
gaOpts.tamTorneo       = 3;
gaOpts.presupuesto     = 100;
gaOpts.mostrarProgreso = true;

fprintf('\n--- Fase 1: Evolución del equipo (GA) ---\n');
tic;
[gaBest, ~, ~] = geneticAlgorithm(gaOpts);
t_ga = toc;

% 2. Fase de Recocido Simulado (Refinamiento local del mejor candidato)
saOpts.maxIteraciones     = 20000;
saOpts.temperaturaInicial = 4;
saOpts.temperaturaMinima  = 0.01;
saOpts.tasaEnfriamiento   = 0.9995;
saOpts.numRivales         = 150;
saOpts.numPartidos        = 30;
saOpts.presupuesto        = 100;
saOpts.mostrarProgreso    = true;

fprintf('\n--- Fase 2: Refinamiento táctico (SA) ---\n');
tic;
[equipoPerfecto, ~, ~] = simulatedAnnealing(gaBest, saOpts);
t_sa = toc;

% --- EVALUACIÓN FINAL DE ROBUSTEZ ---
fprintf('\n--- Fase 3: Validación final (Monte Carlo 500x100) ---\n');
[wr, ~, ~, gf, gc] = evaluateTeam(equipoPerfecto, 500, 100);

% --- RESULTADOS ---
fprintf('\n======================================================\n');
fprintf('EQUIPO PERFECTO ENCONTRADO\n');
fprintf('Vector: [%s]\n', num2str(equipoPerfecto));
fprintf('Win-Rate Final: %.1f%%\n', 100*wr);
fprintf('Media Goles Favor: %.2f | Contra: %.2f\n', gf, gc);
fprintf('Tiempo total: %.1f minutos\n', (t_ga + t_sa)/60);
fprintf('======================================================\n');

% Guardar el resultado automáticamente para no perderlo
v = equipoPerfecto;
save('equipo_perfecto_oficial.mat', 'v');
fprintf('Resultado guardado en equipo_perfecto_oficial.mat\n');
