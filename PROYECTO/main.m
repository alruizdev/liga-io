%% MAIN - Liga IO 2026 - Pipeline de Optimización del Equipo
% Ejecuta este script para correr el flujo completo de optimización.
% Ajusta los parámetros en cada sección según necesites.

clear; clc;
fprintf('========================================\n');
fprintf('  LIGA IO 2026 - Optimizador de Equipo  \n');
fprintf('========================================\n\n');

% ╔══════════════════════════════════════════════════════╗
% ║  AL PROFESOR SE ENTREGA SOLO EL ARCHIVO .mat         ║
% ║  Solo los 10 números. Nada de código. Nada de PDF.   ║
% ║  Solo el archivo XY.mat (XY = tu serial asignado).   ║
% ╚══════════════════════════════════════════════════════╝

%% 1. CONFIGURACIÓN
SERIAL_1 = '01';   % <-- CAMBIA a tu serial asignado
SERIAL_2 = '02';   % <-- CAMBIA a tu segundo serial (opcional)
EJECUTAR_AG           = true;
EJECUTAR_SA           = true;
EJECUTAR_SENSIBILIDAD = false;  % pon true para análisis completo (tarda varios minutos)
RIVALES_EVAL_FINAL    = 500;
PARTIDOS_EVAL_FINAL   = 100;

%% 2. ALGORITMO GENÉTICO
if EJECUTAR_AG
    fprintf('--- Fase 1: Algoritmo Genético ---\n');
    opcionesAG.tamPoblacion    = 100;
    opcionesAG.generaciones    = 80;
    opcionesAG.numRivales      = 80;
    opcionesAG.numPartidos     = 20;
    opcionesAG.mostrarProgreso = true;

    tic;
    [equipoAG, aptitudAG, historialAG] = geneticAlgorithm(opcionesAG);
    fprintf('AG completado en %.1f segundos\n\n', toc);
else
    % Usar el mejor conocido hasta ahora
    equipoAG  = [6 9 9 11 10 1 6 6 24 18];
    aptitudAG = 0;
    fprintf('AG omitido, usando equipo precargado\n\n');
end

%% 3. RECOCIDO SIMULADO (refinar resultado del AG)
if EJECUTAR_SA
    fprintf('--- Fase 2: Recocido Simulado ---\n');
    opcionesSA.maxIteraciones     = 2000;
    opcionesSA.temperaturaInicial = 3;
    opcionesSA.tasaEnfriamiento   = 0.997;
    opcionesSA.numRivales         = 80;
    opcionesSA.numPartidos        = 20;
    opcionesSA.mostrarProgreso    = true;

    tic;
    [equipoSA, aptitudSA, historialSA] = simulatedAnnealing(equipoAG, opcionesSA);
    fprintf('SA completado en %.1f segundos\n\n', toc);
else
    equipoSA  = equipoAG;
    aptitudSA = aptitudAG;
end

%% 4. EVALUACIÓN FINAL
fprintf('--- Fase 3: Evaluación Final ---\n');
fprintf('Evaluando con %d rivales x %d partidos...\n', ...
    RIVALES_EVAL_FINAL, PARTIDOS_EVAL_FINAL);

[tasaVic, tasaEmp, tasaDer, mediaGF, mediaGC] = evaluateTeam(equipoSA, RIVALES_EVAL_FINAL, PARTIDOS_EVAL_FINAL);
fprintf('\nEQUIPO FINAL: [%s]\n', num2str(equipoSA));
fprintf('  Suma: %d\n', sum(equipoSA));
fprintf('  Victorias: %.1f%%  Empates: %.1f%%  Derrotas: %.1f%%\n', 100*tasaVic, 100*tasaEmp, 100*tasaDer);
fprintf('  Goles a favor: %.2f  Goles en contra: %.2f\n', mediaGF, mediaGC);

% ╔══════════════════════════════════════════════════════════════════╗
% ║  PARA EL ANALISTA — CÓMO PROBAR TU PROPIO VECTOR               ║
% ║                                                                  ║
% ║  ¿Quieres testear un equipo concreto que se te ocurra?           ║
% ║  Copia el bloque de abajo en la ventana de comandos de MATLAB   ║
% ║  (Command Window), cambia los 10 números y pulsa Enter.         ║
% ║                                                                  ║
% ║  POSICIONES: [FI  GO  JD  MA  OR  PR  PO  TR  EF  TE]          ║
% ║    FI = Finalización      GO = Generación Ofensiva              ║
% ║    JD = Juego Directo     MA = Marcaje                          ║
% ║    OR = Organización Def. PR = Presión                          ║
% ║    PO = Posesión          TR = Transición                       ║
% ║    EF = Eficacia (clave!) TE = Técnico (clave!)                 ║
% ║                                                                  ║
% ║  REGLAS:                                                         ║
% ║    - Exactamente 10 números                                      ║
% ║    - Todos >= 1  (¡cero PROHIBIDO, descalifica automáticamente!) ║
% ║    - Suma entre 95 y 100                                         ║
% ╚══════════════════════════════════════════════════════════════════╝
%
% --- PEGA ESTO EN LA COMMAND WINDOW ---
%
%   miEquipo = [6 9 9 11 10 1 6 6 24 18];  % <-- cambia estos números
%   [valido, msg] = validateTeam(miEquipo);
%   if valido
%       [v, e, d, gf, gc] = evaluateTeam(miEquipo, 200, 30);
%       fprintf('Victorias: %.1f%%, Empates: %.1f%%, Derrotas: %.1f%%\n', 100*v, 100*e, 100*d);
%       fprintf('Goles a favor: %.2f, Goles en contra: %.2f\n', gf, gc);
%   else
%       fprintf('Equipo invalido: %s\n', msg);
%   end
%
% --- FIN DEL BLOQUE PARA ANALISTA ---

%% 5. ANÁLISIS DE SENSIBILIDAD (opcional)
if EJECUTAR_SENSIBILIDAD
    fprintf('\n--- Fase 4: Análisis de Sensibilidad ---\n');
    resultados = sensitivityAnalysis(equipoSA, 100, 20);
end

%% 6. GUARDAR EQUIPO FINAL
fprintf('\n--- Fase 5: Guardar Equipo ---\n');
fprintf('Equipo final: [%s]\n', num2str(equipoSA));
createTeamFile(equipoSA, SERIAL_1);

% Descomenta para guardar segundo equipo:
% createTeamFile(equipoSA, SERIAL_2);

%% 7. RESUMEN FINAL
fprintf('\n========================================\n');
fprintf('  OPTIMIZACIÓN COMPLETADA               \n');
fprintf('========================================\n');
fprintf('Equipo: [%s] | Victorias=%.1f%%\n', num2str(equipoSA), 100*tasaVic);
fprintf('Archivo generado: %s.mat\n', SERIAL_1);
fprintf('\n  RECUERDA: al profesor solo se entrega el .mat\n');
fprintf('  No entregar codigo, no entregar PDF.\n');
fprintf('  Solo el archivo XY.mat (XY = serial asignado).\n');
fprintf('========================================\n');
