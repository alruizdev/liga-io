function resultados = sensitivityAnalysis(equipoBase, numRivales, numPartidos)
% ANALISIS DE SENSIBILIDAD - Mide el impacto de cada parámetro en la tasa de victorias
%
% Parámetros de entrada:
%   equipoBase  - vector 1x10 base (por defecto: equilibrado [10..10])
%   numRivales  - rivales por evaluación (por defecto 150)
%   numPartidos - partidos por rival (por defecto 30)
%
% Salidas:
%   resultados - struct con datos del análisis y gráfica

    if nargin < 1, equipoBase  = 10*ones(1,10); end
    if nargin < 2, numRivales  = 150; end
    if nargin < 3, numPartidos = 30;  end

    nombresCortos    = {'FI','GO','JD','MA','OR','PR','PO','TR','EF','TE'};
    nombresCompletos = {'Finalizacion','Gen.Ofensiva','Juego Directo', ...
                        'Marcaje','Org.Defensiva','Presion', ...
                        'Posesion','Transicion','Eficacia','Tecnico'};

    fprintf('=== ANÁLISIS DE SENSIBILIDAD ===\n');
    fprintf('Equipo base: [%s] suma=%d\n', num2str(equipoBase), sum(equipoBase));

    % --- 1. Sensibilidad uno a uno ---
    fprintf('\n--- Uno a uno: variar cada parámetro +5/-5 desde la base ---\n');
    fprintf('%-15s  Base%%  -5%%    +5%%    Delta\n', 'Parametro');
    fprintf('%s\n', repmat('-', 1, 55));

    tasaBase = evaluateTeam(equipoBase, numRivales, numPartidos);
    deltas   = zeros(10, 1);

    for p = 1:10
        % Variante -5: quitar del parámetro p y redistribuir al resto
        equipoMenos = equipoBase;
        reduccion   = min(5, equipoMenos(p));
        equipoMenos(p) = equipoMenos(p) - reduccion;
        otros = setdiff(1:10, p);
        for k = 1:reduccion
            idx = otros(randi(length(otros)));
            equipoMenos(idx) = equipoMenos(idx) + 1;
        end

        % Variante +5: añadir al parámetro p, quitar del resto
        equipoMas = equipoBase;
        equipoMas(p) = equipoMas(p) + 5;
        for k = 1:5
            otrosPositivos = otros(equipoMas(otros) > 0);
            if isempty(otrosPositivos), break; end
            idx = otrosPositivos(randi(length(otrosPositivos)));
            equipoMas(idx) = equipoMas(idx) - 1;
        end

        tasaMenos = evaluateTeam(equipoMenos, numRivales, numPartidos);
        tasaMas   = evaluateTeam(equipoMas,   numRivales, numPartidos);
        deltas(p) = tasaMas - tasaMenos;

        fprintf('%-15s  %.1f   %.1f   %.1f   %+.1f\n', ...
            nombresCompletos{p}, 100*tasaBase, 100*tasaMenos, 100*tasaMas, 100*deltas(p));
    end

    % --- 2. Ranking por impacto ---
    fprintf('\n--- RANKING DE PARÁMETROS (por delta de sensibilidad) ---\n');
    [deltasOrdenados, ordenIndices] = sort(deltas, 'descend');
    for i = 1:10
        fprintf('%2d. %-15s  delta=%+.1f%%\n', i, nombresCompletos{ordenIndices(i)}, 100*deltasOrdenados(i));
    end

    % --- 3. Gráfica de barras ---
    figure('Name', 'Análisis de Sensibilidad', 'Position', [100 100 800 400]);
    bar(deltas * 100);
    set(gca, 'XTickLabel', nombresCortos);
    ylabel('Cambio en Tasa de Victorias (%)');
    title('Sensibilidad de Parámetros: Efecto de +5/-5 en Tasa de Victorias');
    grid on;

    resultados.nombresCortos  = nombresCortos;
    resultados.deltas         = deltas;
    resultados.tasaBase       = tasaBase;
    resultados.ordenIndices   = ordenIndices;

    fprintf('\nAnálisis completado.\n');
end
