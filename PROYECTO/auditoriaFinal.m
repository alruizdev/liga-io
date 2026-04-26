function resumen = auditoriaFinal(opciones)
% AUDITORIA FINAL - Pipeline completo de auditoría y selección de equipos.
%
% Carga todos los candidatos (vectores 10x1 enteros) desde:
%   - lista interna del PDF / sesión actual
%   - PROYECTO/*.mat
%   - Pruebas_Ivan/*.mat
% deduplica, valida, evalúa con engine='official' (playMatch.p) en tres pasadas:
%   1) quick eval (200 rivales x 30 partidos)  -> RESULTADOS_CANDIDATOS_OFICIAL.md
%   2) top-10 robusto (1000 rivales x 50)      -> top10_oficial.mat + RESULTADOS_TOP10_OFICIAL.md
%   3) mini-liga round-robin (1000 partidos)   -> RESULTADOS_MINILIGA_TOP10.md
% Y elige equipos 01 y 02 con justificación, guardándolos en ENTREGA_FINAL/.
%
% Parámetros de entrada (struct opciones, todos opcionales):
%   .rivalesQuick / .partidosQuick   (defecto 200 / 30)
%   .rivalesTop10 / .partidosTop10   (defecto 1000 / 50)
%   .partidosLiga                    (defecto 1000)
%   .engine                          (defecto 'official')
%   .seed                            (defecto 2026)
%   .raizProyecto                    (defecto: carpeta del script)
%
% Salida:
%   resumen - struct con nombres de archivos generados, top10 y elección 01/02

    if nargin < 1, opciones = struct(); end
    rivalesQuick   = leerOpcion(opciones, 'rivalesQuick',   200);
    partidosQuick  = leerOpcion(opciones, 'partidosQuick',   30);
    rivalesTop10   = leerOpcion(opciones, 'rivalesTop10',  1000);
    partidosTop10  = leerOpcion(opciones, 'partidosTop10',   50);
    partidosLiga   = leerOpcion(opciones, 'partidosLiga',  1000);
    engine         = leerOpcion(opciones, 'engine',        'official');
    semilla        = leerOpcion(opciones, 'seed',           2026);
    raizProyecto   = leerOpcion(opciones, 'raizProyecto',   fileparts(mfilename('fullpath')));

    raizPadre   = fileparts(raizProyecto);
    rutaIvan    = fullfile(raizPadre, 'Pruebas_Ivan');
    rutaEntrega = fullfile(raizPadre, 'ENTREGA_FINAL');
    if ~exist(rutaEntrega, 'dir'), mkdir(rutaEntrega); end

    % Asegurar que playMatch.p (Pruebas_Ivan) y nuestras funciones están en el path
    addpath(raizProyecto);
    if exist(rutaIvan, 'dir'), addpath(rutaIvan); end

    rng(semilla);

    fprintf('\n========================================================\n');
    fprintf('  AUDITORIA FINAL - LIGA IO 2026 (Interóptimo de Lagrange)\n');
    fprintf('  Engine = %s | seed = %d\n', engine, semilla);
    fprintf('========================================================\n');

    % ----------------------------------------------------------------
    % 1) Construir candidate pool
    % ----------------------------------------------------------------
    candidatosBase = [
        6  9  9 11 10 1  6  6 24 18;
        4 13  8 11 10 1  4  6 24 19;
        12  9  6 10 11 1  3  5 28 15;
        5  8  9  9 13 1  3  9 28 15;
        8  7  9 10 11 1  2  6 29 17;
        6  7 10 10 11 1  7  7 26 15;
        15 10 10  5  6 2  5  7 25 15;
        14  6 12  8 10 6  7  8 14 15;
        16  8 10  9  9 5  6  7 16 14;
        11  5  9 13  5 1  7  1 30 18];

    candidatosMat = cargarVectoresDeMat({raizProyecto, rutaIvan});

    candidatos = [candidatosBase; candidatosMat];

    % Filtrar inválidos y deduplicar
    valido = false(size(candidatos,1),1);
    for i = 1:size(candidatos,1)
        [okv, ~] = validateTeam(candidatos(i,:));
        valido(i) = okv;
    end
    candidatos = candidatos(valido,:);
    candidatos = unique(candidatos, 'rows', 'stable');

    n = size(candidatos,1);
    fprintf('Candidatos válidos únicos: %d\n', n);

    % ----------------------------------------------------------------
    % 2) Quick eval (engine oficial)
    % ----------------------------------------------------------------
    fprintf('\n--- Fase A: Quick eval %dx%d (engine=%s) ---\n', rivalesQuick, partidosQuick, engine);
    metricasQuick = zeros(n, 7); % vic emp der gf gc dg ptos
    tQuick = tic;
    for i = 1:n
        [v,e,d,gf,gc,dg,pts] = evaluateTeamOfficial(candidatos(i,:), rivalesQuick, partidosQuick, engine);
        metricasQuick(i,:) = [v e d gf gc dg pts];
        fprintf('  [%2d/%2d] %-35s  pts=%.3f  vic=%.3f  dg=%+.2f\n', ...
            i, n, vecToStr(candidatos(i,:)), pts, v, dg);
    end
    fprintf('Quick eval terminado en %.1fs\n', toc(tQuick));

    % Ordenar por puntos liga, luego victorias, luego diferencia goles
    claves = [-metricasQuick(:,7), -metricasQuick(:,1), -metricasQuick(:,6), -metricasQuick(:,4), metricasQuick(:,5)];
    [~, ordenQuick] = sortrows(claves);
    candidatosOrd  = candidatos(ordenQuick,:);
    metricasOrd    = metricasQuick(ordenQuick,:);

    escribirTablaCandidatos(fullfile(raizPadre, 'RESULTADOS_CANDIDATOS_OFICIAL.md'), ...
        candidatosOrd, metricasOrd, engine, rivalesQuick, partidosQuick);

    % ----------------------------------------------------------------
    % 3) Top-10 robusto
    % ----------------------------------------------------------------
    nTop = min(10, n);
    top10 = candidatosOrd(1:nTop, :);
    fprintf('\n--- Fase B: Top-%d robusto %dx%d (engine=%s) ---\n', nTop, rivalesTop10, partidosTop10, engine);
    metricasTop10 = zeros(nTop, 7);
    tTop = tic;
    for i = 1:nTop
        [v,e,d,gf,gc,dg,pts] = evaluateTeamOfficial(top10(i,:), rivalesTop10, partidosTop10, engine);
        metricasTop10(i,:) = [v e d gf gc dg pts];
        fprintf('  [%2d/%2d] %-35s  pts=%.3f  vic=%.3f  dg=%+.2f\n', ...
            i, nTop, vecToStr(top10(i,:)), pts, v, dg);
    end
    fprintf('Top-10 robusto terminado en %.1fs\n', toc(tTop));

    save(fullfile(raizPadre, 'top10_oficial.mat'), 'top10', 'metricasTop10');
    escribirTablaCandidatos(fullfile(raizPadre, 'RESULTADOS_TOP10_OFICIAL.md'), ...
        top10, metricasTop10, engine, rivalesTop10, partidosTop10);

    % ----------------------------------------------------------------
    % 4) Mini-liga round-robin
    % ----------------------------------------------------------------
    fprintf('\n--- Fase C: Mini-liga top-%d (%d partidos por cruce) ---\n', nTop, partidosLiga);
    [puntosLiga, dgLiga, gfLiga, victoriasLiga] = miniLiga(top10, partidosLiga, engine);
    [~, ordenLiga] = sortrows([-puntosLiga, -dgLiga, -gfLiga]);
    escribirMiniLiga(fullfile(raizPadre, 'RESULTADOS_MINILIGA_TOP10.md'), ...
        top10, puntosLiga, dgLiga, gfLiga, victoriasLiga, ordenLiga, partidosLiga, engine);

    % ----------------------------------------------------------------
    % 5) Selección 01 y 02
    % ----------------------------------------------------------------
    indiceCampeon = ordenLiga(1);
    equipo01 = top10(indiceCampeon,:);

    % Candidato 02: segundo de mini-liga si está cerca; si no, perfil Copa
    indiceSegundo = ordenLiga(min(2, length(ordenLiga)));
    distanciaPuntos = puntosLiga(indiceCampeon) - puntosLiga(indiceSegundo);
    if distanciaPuntos < 0.10
        equipo02 = top10(indiceSegundo,:);
        razon02 = sprintf('Segundo en mini-liga (delta puntos = %.3f, dentro del umbral 0.10).', distanciaPuntos);
    else
        % Perfil Copa: priorizar FI(1) + EF(9) + TE(10) y NO ser desastre en liga
        scoreCopa = top10(:,1) + top10(:,9) + top10(:,10);
        % Penalizar si está en la mitad inferior de mini-liga
        rangoLiga = zeros(nTop,1); rangoLiga(ordenLiga) = 1:nTop;
        scoreCopa(rangoLiga > ceil(nTop/2)) = -inf;
        if all(isinf(scoreCopa))
            equipo02 = top10(indiceSegundo,:);
            razon02  = 'Ningún candidato pasa el filtro de mitad superior — usamos segundo de mini-liga.';
        else
            [~, idxCopa] = max(scoreCopa);
            equipo02 = top10(idxCopa,:);
            razon02 = sprintf('Perfil Copa (FI+EF+TE máx = %d), top-%d en mini-liga.', ...
                              scoreCopa(idxCopa), rangoLiga(idxCopa));
        end
    end

    % Métricas finales (rápidas) de 01 y 02
    [v01,e01,d01,gf01,gc01,dg01,pts01] = evaluateTeamOfficial(equipo01, rivalesTop10, partidosTop10, engine);
    [v02,e02,d02,gf02,gc02,dg02,pts02] = evaluateTeamOfficial(equipo02, rivalesTop10, partidosTop10, engine);

    % ----------------------------------------------------------------
    % 6) Guardar en ENTREGA_FINAL/ con seriales placeholder
    % ----------------------------------------------------------------
    cwdPrev = pwd;
    cleanupCwd = onCleanup(@() cd(cwdPrev));
    cd(rutaEntrega);
    serial1 = '01';
    serial2 = '02';
    createTeamFile(equipo01, serial1);
    createTeamFile(equipo02, serial2);

    % Sanity check: lector + un partido contra balanceado
    fprintf('\n--- Validación en ENTREGA_FINAL ---\n');
    try
        [equiposLeidos, nombresLeidos] = lector();  %#ok<ASGLU>
        fprintf('lector() leyó %d archivos en ENTREGA_FINAL.\n', size(equiposLeidos,1));
    catch err
        warning(err.identifier, '%s', err.message);
    end
    rivalReferencia = 10*ones(1,10);
    try
        if exist('playMatch','file')
            [g1, g2] = playMatch(equipo01, rivalReferencia);
            fprintf('playMatch(01, [10*10]) -> %d-%d (sin error)\n', g1, g2);
            [g1, g2] = playMatch(equipo02, rivalReferencia);
            fprintf('playMatch(02, [10*10]) -> %d-%d (sin error)\n', g1, g2);
        else
            fprintf('playMatch no encontrado: solo se ha probado playMatchOpen.\n');
            [g1, g2] = playMatchOpen(equipo01, rivalReferencia);
            fprintf('playMatchOpen(01, [10*10]) -> %d-%d\n', g1, g2);
        end
    catch err
        warning(err.identifier, '%s', err.message);
    end

    % ----------------------------------------------------------------
    % 7) Resumen
    % ----------------------------------------------------------------
    resumen.candidatosTotales = n;
    resumen.top10             = top10;
    resumen.metricasTop10     = metricasTop10;
    resumen.ordenLiga         = ordenLiga;
    resumen.puntosLiga        = puntosLiga;
    resumen.dgLiga            = dgLiga;
    resumen.gfLiga            = gfLiga;
    resumen.equipo01          = equipo01;
    resumen.equipo02          = equipo02;
    resumen.razon02           = razon02;
    resumen.metricas01        = struct('v',v01,'e',e01,'d',d01,'gf',gf01,'gc',gc01,'dg',dg01,'pts',pts01);
    resumen.metricas02        = struct('v',v02,'e',e02,'d',d02,'gf',gf02,'gc',gc02,'dg',dg02,'pts',pts02);
    resumen.archivos          = struct( ...
        'candidatos', fullfile(raizPadre, 'RESULTADOS_CANDIDATOS_OFICIAL.md'), ...
        'top10',      fullfile(raizPadre, 'RESULTADOS_TOP10_OFICIAL.md'), ...
        'top10mat',   fullfile(raizPadre, 'top10_oficial.mat'), ...
        'miniliga',   fullfile(raizPadre, 'RESULTADOS_MINILIGA_TOP10.md'), ...
        'entrega',    rutaEntrega);

    fprintf('\n=== ELECCIÓN FINAL ===\n');
    fprintf('01 = [%s]  pts=%.3f vic=%.3f dg=%+.2f\n', vecToStr(equipo01), pts01, v01, dg01);
    fprintf('02 = [%s]  pts=%.3f vic=%.3f dg=%+.2f\n', vecToStr(equipo02), pts02, v02, dg02);
    fprintf('Razón 02: %s\n', razon02);

    save(fullfile(raizPadre, 'auditoria_resumen.mat'), 'resumen');
end

% ====================================================================
% Helpers
% ====================================================================

function v = leerOpcion(s, f, d)
    if isfield(s, f) && ~isempty(s.(f)), v = s.(f); else, v = d; end
end

function s = vecToStr(v)
    s = sprintf('%2d ', v); s = strtrim(s);
end

function vectores = cargarVectoresDeMat(carpetas)
    vectores = zeros(0,10);
    for c = 1:numel(carpetas)
        if ~exist(carpetas{c}, 'dir'), continue; end
        d = dir(fullfile(carpetas{c}, '*.mat'));
        for k = 1:numel(d)
            try
                S = load(fullfile(d(k).folder, d(k).name));
            catch
                continue;
            end
            campos = fieldnames(S);
            for f = 1:numel(campos)
                x = S.(campos{f});
                if isnumeric(x) && isvector(x) && numel(x) == 10
                    fila = double(x(:)');
                    if all(fila == round(fila)) && all(fila >= 1) && sum(fila) >= 95 && sum(fila) <= 100
                        vectores(end+1,:) = fila; %#ok<AGROW>
                    end
                end
                % Aceptar también structs con un campo 1x10
                if isstruct(x)
                    subc = fieldnames(x);
                    for g = 1:numel(subc)
                        y = x.(subc{g});
                        if isnumeric(y) && isvector(y) && numel(y) == 10
                            fila = double(y(:)');
                            if all(fila == round(fila)) && all(fila >= 1) && sum(fila) >= 95 && sum(fila) <= 100
                                vectores(end+1,:) = fila; %#ok<AGROW>
                            end
                        end
                    end
                end
            end
        end
    end
end

function escribirTablaCandidatos(ruta, candidatos, metricas, engine, nR, nP)
    fid = fopen(ruta, 'w', 'n', 'UTF-8');
    fprintf(fid, '# Resultados — engine=%s, %d rivales x %d partidos\n\n', engine, nR, nP);
    fprintf(fid, 'Generado: %s\n\n', datestr(now)); %#ok<DATST>
    fprintf(fid, '| # | Vector | Pts/p | Vic | Emp | Der | GF | GC | DG |\n');
    fprintf(fid, '|---|--------|-------|-----|-----|-----|------|------|------|\n');
    for i = 1:size(candidatos,1)
        fprintf(fid, '| %d | [%s] | %.3f | %.3f | %.3f | %.3f | %.2f | %.2f | %+.2f |\n', ...
            i, vecToStr(candidatos(i,:)), metricas(i,7), metricas(i,1), metricas(i,2), ...
            metricas(i,3), metricas(i,4), metricas(i,5), metricas(i,6));
    end
    fclose(fid);
end

function [puntos, dg, gf, victorias] = miniLiga(equipos, partidosPorCruce, engine)
    n = size(equipos,1);
    puntos    = zeros(n,1);
    gf        = zeros(n,1);
    gc        = zeros(n,1);
    victorias = zeros(n,1);
    usaOficial = strcmpi(engine,'official') && (exist('playMatch','file') == 6 || exist('playMatch','file') == 2);
    for i = 1:n
        for j = 1:n
            if i == j, continue; end
            for p = 1:partidosPorCruce
                if usaOficial
                    [g1, g2] = playMatch(equipos(i,:), equipos(j,:));
                else
                    [g1, g2] = playMatchOpen(equipos(i,:), equipos(j,:));
                end
                gf(i) = gf(i) + g1; gc(i) = gc(i) + g2;
                if g1 > g2
                    puntos(i) = puntos(i) + 3;
                    victorias(i) = victorias(i) + 1;
                elseif g1 == g2
                    puntos(i) = puntos(i) + 1;
                end
            end
        end
        fprintf('  miniLiga: equipo %d/%d procesado (pts=%d)\n', i, n, puntos(i));
    end
    dg = gf - gc;
end

function escribirMiniLiga(ruta, equipos, puntos, dg, gf, victorias, orden, partidosPorCruce, engine)
    fid = fopen(ruta, 'w', 'n', 'UTF-8');
    fprintf(fid, '# Mini-liga top-10 — engine=%s, %d partidos por cruce\n\n', engine, partidosPorCruce);
    fprintf(fid, 'Generado: %s\n\n', datestr(now)); %#ok<DATST>
    fprintf(fid, '| Pos | Vector | Puntos | Victorias | DG | GF |\n');
    fprintf(fid, '|-----|--------|--------|-----------|------|------|\n');
    for k = 1:numel(orden)
        i = orden(k);
        fprintf(fid, '| %d | [%s] | %d | %d | %+d | %d |\n', ...
            k, vecToStr(equipos(i,:)), puntos(i), victorias(i), dg(i), gf(i));
    end
    fclose(fid);
end
