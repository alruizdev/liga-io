function res = auditoriaCierre(opts)
% AUDITORIA CIERRE - Última búsqueda local oficial acotada y decisión final.
%
% Genera vecinos discretos alrededor de base01 y base02 moviendo 1 o 2
% puntos entre pares de variables, valida con playMatch.p y aplica un
% criterio estricto para decidir si SUSTITUIR o CONGELAR los vectores.
%
% Tres pasadas, todas con engine='official' (playMatch.p):
%   A) Quick sieve  : 300 rivales x 30 partidos x 3 seeds
%   B) Top-10 robust: 1000 rivales x 50 partidos x 5 seeds
%   C) Mini-liga    : round-robin top-10, 1000 partidos por cruce x 3 seeds
%
% Devuelve struct res con todas las métricas, decisión y diagnóstico.

    if nargin < 1, opts = struct(); end
    raiz = leerOpc(opts, 'raiz', fileparts(fileparts(mfilename('fullpath'))));
    proj = fullfile(raiz,'PROYECTO');
    ivan = fullfile(raiz,'Pruebas_Ivan');
    addpath(proj); addpath(ivan);

    rivQuick    = leerOpc(opts,'rivQuick',300);
    parQuick    = leerOpc(opts,'parQuick',30);
    seedsQuick  = leerOpc(opts,'seedsQuick',[2026 2027 2028]);
    rivRobust   = leerOpc(opts,'rivRobust',1000);
    parRobust   = leerOpc(opts,'parRobust',50);
    seedsRobust = leerOpc(opts,'seedsRobust',[2026 2027 2028 2029 2030]);
    parLiga     = leerOpc(opts,'parLiga',1000);
    seedsLiga   = leerOpc(opts,'seedsLiga',[2026 2027 2028]);
    deltaMax    = leerOpc(opts,'deltaMax',2);

    base01 = [6 9 9 11 10 1 6 6 24 18];
    base02 = [8 7 9 10 11 1 2 6 29 17];

    fprintf('\n=========================================================\n');
    fprintf('  AUDITORIA CIERRE - busqueda local oficial acotada\n');
    fprintf('  Base01 = [%s]   Base02 = [%s]\n', vec2s(base01), vec2s(base02));
    fprintf('  Quick %dx%d x %d seeds   Robust %dx%d x %d seeds   Liga %d x %d seeds\n', ...
        rivQuick, parQuick, numel(seedsQuick), rivRobust, parRobust, numel(seedsRobust), parLiga, numel(seedsLiga));
    fprintf('=========================================================\n');

    % ----------------------------------------------------------------
    % 1) Generar vecinos discretos
    % ----------------------------------------------------------------
    pool = [base01; base02];
    pool = [pool; vecinosDelta(base01, deltaMax)];
    pool = [pool; vecinosDelta(base02, deltaMax)];
    % Filtrar duplicados e invalidos
    pool = unique(pool, 'rows', 'stable');
    valido = false(size(pool,1),1);
    for i = 1:size(pool,1)
        valido(i) = validarTeamLocal(pool(i,:));
    end
    pool = pool(valido,:);
    fprintf('Vecinos validos: %d (delta_max=%d)\n', size(pool,1), deltaMax);

    idxBase01 = find(all(pool == base01, 2), 1);
    idxBase02 = find(all(pool == base02, 2), 1);

    % ----------------------------------------------------------------
    % 2) Quick sieve: 300x30 x 3 seeds
    % ----------------------------------------------------------------
    fprintf('\n--- Fase A: Quick sieve %dx%d x %d seeds ---\n', rivQuick, parQuick, numel(seedsQuick));
    tA = tic;
    [ptsA, vicA, dgA, gfA, gcA] = evaluarPool(pool, rivQuick, parQuick, seedsQuick);
    fprintf('Quick sieve terminado en %.1fs\n', toc(tA));

    ptsAm = mean(ptsA, 2);
    vicAm = mean(vicA, 2);
    dgAm  = mean(dgA, 2);

    % Ranking por puntos/partido
    [~, ord] = sortrows([-ptsAm, -dgAm, -vicAm]);
    top10idx = ord(1:min(10,numel(ord)));
    if ~ismember(idxBase01, top10idx)
        top10idx(end-1) = idxBase01;
    end
    if ~ismember(idxBase02, top10idx)
        top10idx(end) = idxBase02;
    end
    top10idx = unique(top10idx, 'stable');
    while numel(top10idx) < 10 && numel(top10idx) < numel(ord)
        candidatoExtra = ord(find(~ismember(ord, top10idx), 1, 'first'));
        top10idx(end+1) = candidatoExtra; %#ok<AGROW>
    end

    top10 = pool(top10idx, :);
    fprintf('Top 10 (incluye base01=%s, base02=%s):\n', siNo(ismember(idxBase01,top10idx)), siNo(ismember(idxBase02,top10idx)));
    for k = 1:numel(top10idx)
        i = top10idx(k);
        marca = '';
        if i == idxBase01, marca = ' <-- base01'; end
        if i == idxBase02, marca = ' <-- base02'; end
        fprintf('  [%2d] [%s]  pts=%.4f  vic=%.4f  dg=%+.3f%s\n', ...
            k, vec2s(pool(i,:)), ptsAm(i), vicAm(i), dgAm(i), marca);
    end

    % ----------------------------------------------------------------
    % 3) Eval robusto top-10: 1000x50 x 5 seeds (media + std)
    % ----------------------------------------------------------------
    fprintf('\n--- Fase B: Robust eval top-10 %dx%d x %d seeds ---\n', rivRobust, parRobust, numel(seedsRobust));
    tB = tic;
    [ptsB, vicB, dgB, gfB, gcB] = evaluarPool(top10, rivRobust, parRobust, seedsRobust);
    fprintf('Robust eval terminado en %.1fs\n', toc(tB));

    estadB.ptsMean = mean(ptsB, 2); estadB.ptsStd = std(ptsB, 0, 2);
    estadB.vicMean = mean(vicB, 2); estadB.vicStd = std(vicB, 0, 2);
    estadB.dgMean  = mean(dgB, 2);  estadB.dgStd  = std(dgB, 0, 2);
    estadB.gfMean  = mean(gfB, 2);
    estadB.gcMean  = mean(gcB, 2);

    fprintf('  %-30s  pts(mean+-std)         vic(mean+-std)        dg(mean+-std)\n','Vector');
    for k = 1:size(top10,1)
        fprintf('  [%-30s] %.4f +- %.4f   %.4f +- %.4f   %+.3f +- %.3f\n', ...
            vec2s(top10(k,:)), estadB.ptsMean(k), estadB.ptsStd(k), ...
            estadB.vicMean(k), estadB.vicStd(k), estadB.dgMean(k), estadB.dgStd(k));
    end

    % ----------------------------------------------------------------
    % 4) Mini-liga round-robin top-10 x 3 seeds, 1000 partidos por cruce
    % ----------------------------------------------------------------
    fprintf('\n--- Fase C: Mini-liga round-robin %d partidos x %d seeds ---\n', parLiga, numel(seedsLiga));
    tC = tic;
    [ptosLigaSeed, dgLigaSeed, gfLigaSeed] = miniLigaPorSemillas(top10, parLiga, seedsLiga);
    fprintf('Mini-liga terminada en %.1fs\n', toc(tC));

    estadL.ptsMean = mean(ptosLigaSeed, 2);
    estadL.ptsStd  = std(ptosLigaSeed, 0, 2);
    estadL.dgMean  = mean(dgLigaSeed,  2);
    estadL.dgStd   = std(dgLigaSeed,   0, 2);
    estadL.gfMean  = mean(gfLigaSeed,  2);

    [~, ordL] = sortrows([-estadL.ptsMean, -estadL.dgMean]);
    fprintf('Mini-liga ranking:\n');
    for k = 1:numel(ordL)
        i = ordL(k);
        marca = '';
        if all(top10(i,:) == base01), marca = ' <-- base01'; end
        if all(top10(i,:) == base02), marca = ' <-- base02'; end
        fprintf('  %2d. [%-30s] pts=%.1f +- %.1f  dg=%+.1f +- %.1f%s\n', ...
            k, vec2s(top10(i,:)), estadL.ptsMean(i), estadL.ptsStd(i), ...
            estadL.dgMean(i), estadL.dgStd(i), marca);
    end

    % ----------------------------------------------------------------
    % 5) Aplicar criterio de cambio (umbral +0.015 pts/p, mini-liga estable)
    % ----------------------------------------------------------------
    idxBase01Top = find(all(top10 == base01, 2), 1);
    idxBase02Top = find(all(top10 == base02, 2), 1);

    umbralPts  = 0.015;
    decision01 = struct('cambiar', false, 'sustituto', base01, 'razon', '');
    decision02 = struct('cambiar', false, 'sustituto', base02, 'razon', '');

    if ~isempty(idxBase01Top)
        ptsBase01    = estadB.ptsMean(idxBase01Top);
        ligaBase01   = estadL.ptsMean(idxBase01Top);
        ligaBase01St = estadL.ptsStd(idxBase01Top);
        % Buscar candidatos que mejoren a base01 EN AMBAS metricas
        mejoresPts  = (estadB.ptsMean - ptsBase01) >= umbralPts;
        mejoresLiga = estadL.ptsMean > (ligaBase01 + max(ligaBase01St, 1));
        candidatosOK = find(mejoresPts & mejoresLiga);
        if ~isempty(candidatosOK)
            % Elegir el de mejor mini-liga, desempate por robust pts
            [~, mejor] = sortrows([-estadL.ptsMean(candidatosOK), -estadB.ptsMean(candidatosOK)]);
            mejor = candidatosOK(mejor(1));
            decision01.cambiar = true;
            decision01.sustituto = top10(mejor,:);
            decision01.razon = sprintf(['Sustituto supera base01 en eval robusto (+%.4f pts/p, umbral %.3f) ' ...
                                        'Y en mini-liga (+%.1f pts > 1 sigma). '], ...
                estadB.ptsMean(mejor) - ptsBase01, umbralPts, estadL.ptsMean(mejor) - ligaBase01);
        else
            decision01.razon = sprintf(['Ningun vecino supera base01 con +%.3f pts/p en robust ' ...
                                        'Y mini-liga > 1 sigma. Se congela.'], umbralPts);
        end
    else
        decision01.razon = 'base01 no esta en top10 (no deberia pasar). Se congela.';
    end

    if ~isempty(idxBase02Top)
        ptsBase02   = estadB.ptsMean(idxBase02Top);
        ligaBase02  = estadL.ptsMean(idxBase02Top);
        gfBase02    = estadB.gfMean(idxBase02Top);
        % Para 02 prima perfil ofensivo: mas GF y FI+EF+TE alto, sin perder mucho liga
        scoreCopa = top10(:,1) + top10(:,9) + top10(:,10);
        % Filtrar candidatos con perfil > base02 y mini-liga no muy degradada
        ligaPenalizada = estadL.ptsMean < (ligaBase02 - 1);
        ofensivos = (scoreCopa > scoreCopa(idxBase02Top)) | (estadB.gfMean > gfBase02 + 0.05);
        candidatosOK = find(ofensivos & ~ligaPenalizada & ((1:size(top10,1))' ~= idxBase02Top));
        % Excluir el sustituto de 01 si lo hay
        if decision01.cambiar
            sustituto1 = decision01.sustituto;
            esSust1 = all(top10 == sustituto1, 2);
            candidatosOK = candidatosOK(~esSust1(candidatosOK));
        end
        if ~isempty(candidatosOK)
            [~, mejor] = max(top10(candidatosOK,1) + top10(candidatosOK,9) + top10(candidatosOK,10) ...
                             + 0.5*estadB.gfMean(candidatosOK));
            mejor = candidatosOK(mejor);
            decision02.cambiar = true;
            decision02.sustituto = top10(mejor,:);
            decision02.razon = sprintf(['Sustituto mejora perfil Copa: FI+EF+TE=%d (vs %d), GF=%.3f (vs %.3f), ' ...
                                        'mini-liga no degradada (>%.1f - 1 sigma).'], ...
                top10(mejor,1)+top10(mejor,9)+top10(mejor,10), scoreCopa(idxBase02Top), ...
                estadB.gfMean(mejor), gfBase02, ligaBase02);
        else
            decision02.razon = 'Ningun vecino mejora perfil Copa sin degradar liga > 1 sigma. Se congela.';
        end
    else
        decision02.razon = 'base02 no esta en top10. Se congela.';
    end

    fprintf('\n=== DECISION FINAL ===\n');
    fprintf('  01: %s. %s\n', decisionEtq(decision01.cambiar), decision01.razon);
    fprintf('      vector final = [%s]\n', vec2s(decision01.sustituto));
    fprintf('  02: %s. %s\n', decisionEtq(decision02.cambiar), decision02.razon);
    fprintf('      vector final = [%s]\n', vec2s(decision02.sustituto));

    % ----------------------------------------------------------------
    % 6) Empaquetar resultado
    % ----------------------------------------------------------------
    res.base01     = base01;
    res.base02     = base02;
    res.pool       = pool;
    res.top10      = top10;
    res.top10idx   = top10idx;
    res.estadB     = estadB;
    res.estadL     = estadL;
    res.ptsB       = ptsB; res.vicB = vicB; res.dgB = dgB; res.gfB = gfB; res.gcB = gcB;
    res.ptosLigaSeed = ptosLigaSeed;
    res.dgLigaSeed = dgLigaSeed;
    res.gfLigaSeed = gfLigaSeed;
    res.ordL       = ordL;
    res.decision01 = decision01;
    res.decision02 = decision02;
    res.equipo01   = decision01.sustituto;
    res.equipo02   = decision02.sustituto;
    res.umbralPts  = umbralPts;
    res.seedsQuick = seedsQuick;
    res.seedsRobust= seedsRobust;
    res.seedsLiga  = seedsLiga;
    save(fullfile(raiz,'cierre_resumen.mat'),'res');
end

% ====================================================================
% Helpers
% ====================================================================

function v = leerOpc(s,f,d)
    if isfield(s,f) && ~isempty(s.(f)), v = s.(f); else, v = d; end
end

function s = vec2s(v)
    s = strtrim(sprintf('%2d ', v));
end

function ok = validarTeamLocal(v)
    ok = numel(v) == 10 && all(v == round(v)) && all(v >= 1) && sum(v) >= 95 && sum(v) <= 100;
end

function C = vecinosDelta(base, deltaMax)
% Move 1..deltaMax points between any pair of indices (i->j)
    C = zeros(0,10);
    for fromIdx = 1:10
        for toIdx = 1:10
            if fromIdx == toIdx, continue; end
            for d = 1:deltaMax
                v = base;
                if v(fromIdx) - d < 1, continue; end
                v(fromIdx) = v(fromIdx) - d;
                v(toIdx)   = v(toIdx)   + d;
                C(end+1,:) = v; %#ok<AGROW>
            end
        end
    end
end

function s = siNo(b)
    if b, s='SI'; else, s='NO'; end
end

function s = decisionEtq(b)
    if b, s='CAMBIAR'; else, s='CONGELAR'; end
end

function [pts, vic, dg, gf, gc] = evaluarPool(pool, nR, nP, seeds)
% Devuelve matrices NxS con métricas (filas=candidatos, columnas=seeds)
    n = size(pool,1);
    s = numel(seeds);
    pts = zeros(n,s); vic = zeros(n,s); dg = zeros(n,s);
    gf  = zeros(n,s); gc  = zeros(n,s);
    for si = 1:s
        rng(seeds(si));
        for k = 1:n
            [v,~,~,gff,gcc,dgg,ptt] = evaluateTeamOfficial(pool(k,:), nR, nP, 'official');
            pts(k,si) = ptt; vic(k,si) = v; dg(k,si) = dgg;
            gf(k,si)  = gff; gc(k,si)  = gcc;
        end
        fprintf('  seed=%d  %d candidatos evaluados\n', seeds(si), n);
    end
end

function [pts, dg, gf] = miniLigaPorSemillas(equipos, partidosPorCruce, seeds)
    n = size(equipos,1);
    s = numel(seeds);
    pts = zeros(n,s); dg = zeros(n,s); gf = zeros(n,s);
    for si = 1:s
        rng(seeds(si));
        gfS = zeros(n,1); gcS = zeros(n,1); ptosS = zeros(n,1);
        for i = 1:n
            for j = 1:n
                if i == j, continue; end
                for p = 1:partidosPorCruce
                    [g1, g2] = playMatch(equipos(i,:), equipos(j,:));
                    gfS(i) = gfS(i) + g1; gcS(i) = gcS(i) + g2;
                    if g1 > g2
                        ptosS(i) = ptosS(i) + 3;
                    elseif g1 == g2
                        ptosS(i) = ptosS(i) + 1;
                    end
                end
            end
        end
        pts(:,si) = ptosS; dg(:,si) = gfS - gcS; gf(:,si) = gfS;
        fprintf('  miniLiga seed=%d completada\n', seeds(si));
    end
end
