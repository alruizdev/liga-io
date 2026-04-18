function [equipo01, equipo02, estadisticas] = generateFinalTeams(serial1, serial2, guardarArchivo)
% GENERAR EQUIPOS FINALES - Produce los candidatos 01 y 02 listos para entrega.
%
% ╔══════════════════════════════════════════════════════╗
% ║  AL PROFESOR SE ENTREGA SOLO EL ARCHIVO .mat         ║
% ║  Solo los 10 números. Nada de código. Nada de PDF.   ║
% ║  Solo el archivo XY.mat (XY = tu serial asignado).   ║
% ╚══════════════════════════════════════════════════════╝
%
% Equipo 01: optimizado para LIGA (máxima tasa de victorias esperada).
% Equipo 02: candidato complementario con semilla diferente (por si el
%   playMatch.p del profesor tiene penalizaciones ocultas contra el
%   estilo del equipo 01).
%
% Ambos garantizan entradas >= 1 (PDF: "entradas enteras positivas") y
% suma == 100 exacta.
%
% Parámetros de entrada:
%   serial1        - string, serial para equipo 01 (ej: '01'). Vacío = no guarda.
%   serial2        - string, serial para equipo 02 (ej: '02'). Vacío = no guarda.
%   guardarArchivo - lógico, true para guardar archivos .mat (por defecto false)
%
% Salidas:
%   equipo01, equipo02 - vectores 1x10 enteros
%   estadisticas       - struct con tasas de victorias y estadísticas de goles

    if nargin < 1, serial1        = ''; end
    if nargin < 2, serial2        = ''; end
    if nargin < 3, guardarArchivo = false; end

    % --- Equipo 01: AG agresivo con semilla fija ---
    fprintf('=== EQUIPO 01: optimizado para liga (AG + SA, semilla 42) ===\n');
    rng(42);
    opcionesAG.tamPoblacion    = 150;
    opcionesAG.generaciones    = 120;
    opcionesAG.numRivales      = 100;
    opcionesAG.numPartidos     = 25;
    opcionesAG.mostrarProgreso = false;
    t0 = tic;
    [equipoAG, ~, ~] = geneticAlgorithm(opcionesAG);
    fprintf('  AG: %.1fs\n', toc(t0));

    opcionesSA.maxIteraciones     = 3000;
    opcionesSA.temperaturaInicial = 3;
    opcionesSA.tasaEnfriamiento   = 0.997;
    opcionesSA.numRivales         = 100;
    opcionesSA.numPartidos        = 25;
    opcionesSA.mostrarProgreso    = false;
    t0 = tic;
    [equipo01, ~, ~] = simulatedAnnealing(equipoAG, opcionesSA);
    fprintf('  SA: %.1fs\n', toc(t0));

    % --- Equipo 02: semilla diferente para diversidad ---
    fprintf('\n=== EQUIPO 02: candidato complementario (AG + SA, semilla 2026) ===\n');
    rng(2026);
    t0 = tic;
    [equipoAG2, ~, ~] = geneticAlgorithm(opcionesAG);
    fprintf('  AG: %.1fs\n', toc(t0));
    t0 = tic;
    [equipo02, ~, ~] = simulatedAnnealing(equipoAG2, opcionesSA);
    fprintf('  SA: %.1fs\n', toc(t0));

    % --- Evaluación robusta ---
    fprintf('\n=== Evaluación robusta (500 rivales x 100 partidos) ===\n');
    [tasa01, empate01, derrota01, gf01, gc01] = evaluateTeam(equipo01, 500, 100);
    [tasa02, empate02, derrota02, gf02, gc02] = evaluateTeam(equipo02, 500, 100);

    fprintf('\n| Equipo | Vector                                  | Vic%%  | GF   | GC   | sigma |\n');
    fprintf('|--------|-----------------------------------------|-------|------|------|-------|\n');
    fprintf('| 01     | [%-37s] | %.2f | %.2f | %.2f | %.1f |\n', num2str(equipo01), 100*tasa01, gf01, gc01, sum(abs(equipo01-10))/10);
    fprintf('| 02     | [%-37s] | %.2f | %.2f | %.2f | %.1f |\n', num2str(equipo02), 100*tasa02, gf02, gc02, sum(abs(equipo02-10))/10);

    estadisticas.equipo01   = equipo01;
    estadisticas.equipo02   = equipo02;
    estadisticas.tasa01     = tasa01;     estadisticas.tasa02     = tasa02;
    estadisticas.empate01   = empate01;   estadisticas.empate02   = empate02;
    estadisticas.derrota01  = derrota01;  estadisticas.derrota02  = derrota02;
    estadisticas.gf01       = gf01;       estadisticas.gf02       = gf02;
    estadisticas.gc01       = gc01;       estadisticas.gc02       = gc02;

    % --- Validación final ---
    for k = 1:2
        if k == 1
            t = equipo01; nombre = '01';
        else
            t = equipo02; nombre = '02';
        end
        [ok, msg] = validateTeam(t);
        fprintf('\n[VALIDAR %s] ok=%d  min=%d  suma=%d  msg=%s\n', nombre, ok, min(t), sum(t), msg);
        if ~ok
            error('Equipo %s FALLÓ la validación. NO ENTREGAR.', nombre);
        end
    end

    % --- Guardar archivos .mat si se proporcionaron seriales ---
    if guardarArchivo
        if ~isempty(serial1)
            createTeamFile(equipo01, serial1);
        end
        if ~isempty(serial2)
            createTeamFile(equipo02, serial2);
        end
    else
        fprintf('\n[NOTA] guardarArchivo=false: llama de nuevo con guardarArchivo=true cuando los seriales estén confirmados.\n');
    end
end
