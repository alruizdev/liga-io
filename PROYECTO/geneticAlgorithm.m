function [mejorEquipo, mejorAptitud, historial] = geneticAlgorithm(opciones)
% ALGORITMO GENETICO - Optimiza el vector del equipo
%
% Parámetros de entrada:
%   opciones - struct con campos opcionales:
%     .tamPoblacion    - tamaño de la población (por defecto 100)
%     .generaciones    - número de generaciones (por defecto 200)
%     .numRivales      - rivales por evaluación (por defecto 100)
%     .numPartidos     - partidos por rival (por defecto 20)
%     .porcentajeElite - fracción de élite conservada (por defecto 0.1)
%     .probMutacion    - probabilidad de mutación (por defecto 0.3)
%     .tamTorneo       - tamaño del torneo de selección (por defecto 3)
%     .presupuesto     - suma total del equipo (por defecto 100)
%     .mostrarProgreso - imprimir avance por consola (por defecto true)
%
% Salidas:
%   mejorEquipo   - mejor vector 1x10 encontrado
%   mejorAptitud  - tasa de victorias del mejor equipo
%   historial     - struct con datos de convergencia

    if nargin < 1, opciones = struct(); end
    tamPoblacion    = obtenerOpcion(opciones, 'tamPoblacion',    100);
    generaciones    = obtenerOpcion(opciones, 'generaciones',    200);
    numRivales      = obtenerOpcion(opciones, 'numRivales',      100);
    numPartidos     = obtenerOpcion(opciones, 'numPartidos',      20);
    porcentajeElite = obtenerOpcion(opciones, 'porcentajeElite',  0.1);
    probMutacion    = obtenerOpcion(opciones, 'probMutacion',     0.3);
    tamTorneo       = obtenerOpcion(opciones, 'tamTorneo',          3);
    presupuesto     = obtenerOpcion(opciones, 'presupuesto',      100);
    mostrarProgreso = obtenerOpcion(opciones, 'mostrarProgreso',  true);

    numElite = max(1, round(tamPoblacion * porcentajeElite));

    % --- Inicializar población ---
    poblacion = zeros(tamPoblacion, 10);
    for i = 1:tamPoblacion
        poblacion(i,:) = generateTeam(presupuesto);
    end

    % Sembrar con candidatos conocidos
    poblacion(1,:) = [8 8 8 8 8 8 8 8 16 20];
    poblacion(2,:) = [12 10 8 10 10 7 8 8 12 15];
    poblacion(3,:) = [10 8 8 8 8 8 8 8 14 20];
    poblacion(4,:) = [8 8 10 8 8 6 8 8 16 18];

    % --- Evaluar población inicial ---
    aptitud = zeros(tamPoblacion, 1);
    for i = 1:tamPoblacion
        aptitud(i) = evaluateTeam(poblacion(i,:), numRivales, numPartidos);
    end

    [mejorAptitud, mejorIndice] = max(aptitud);
    mejorEquipo = poblacion(mejorIndice,:);

    historial.mejorAptitud = zeros(generaciones, 1);
    historial.aptitudMedia = zeros(generaciones, 1);
    historial.mejorEquipo  = zeros(generaciones, 10);

    if mostrarProgreso
        fprintf('Gen 0: Mejor=%.3f Media=%.3f Equipo=[%s]\n', ...
            mejorAptitud, mean(aptitud), num2str(mejorEquipo));
    end

    % --- Bucle evolutivo ---
    for gen = 1:generaciones
        % Ordenar por aptitud
        [aptitud, ordenIdx] = sort(aptitud, 'descend');
        poblacion = poblacion(ordenIdx, :);

        nuevaPoblacion = zeros(tamPoblacion, 10);

        % Elitismo: conservar los mejores individuos
        nuevaPoblacion(1:numElite, :) = poblacion(1:numElite, :);

        % Rellenar el resto con cruce + mutación
        for i = (numElite+1):tamPoblacion
            p1   = seleccionTorneo(poblacion, aptitud, tamTorneo);
            p2   = seleccionTorneo(poblacion, aptitud, tamTorneo);
            hijo = cruce(poblacion(p1,:), poblacion(p2,:), presupuesto);
            if rand() < probMutacion
                hijo = mutar(hijo, presupuesto);
            end
            nuevaPoblacion(i,:) = hijo;
        end

        poblacion = nuevaPoblacion;

        % Evaluar nueva población (saltar élites para ahorrar tiempo)
        nuevaAptitud = zeros(tamPoblacion, 1);
        nuevaAptitud(1:numElite) = aptitud(1:numElite);
        for i = (numElite+1):tamPoblacion
            nuevaAptitud(i) = evaluateTeam(poblacion(i,:), numRivales, numPartidos);
        end
        aptitud = nuevaAptitud;

        [mejorGen, mejorGenIndice] = max(aptitud);
        if mejorGen > mejorAptitud
            mejorAptitud = mejorGen;
            mejorEquipo  = poblacion(mejorGenIndice,:);
        end

        historial.mejorAptitud(gen)  = mejorAptitud;
        historial.aptitudMedia(gen)  = mean(aptitud);
        historial.mejorEquipo(gen,:) = mejorEquipo;

        if mostrarProgreso && (mod(gen,10)==0 || gen==1)
            fprintf('Gen %3d: Mejor=%.3f Media=%.3f Equipo=[%s]\n', ...
                gen, mejorAptitud, mean(aptitud), num2str(mejorEquipo));
        end
    end

    if mostrarProgreso
        fprintf('\n=== RESULTADO ALGORITMO GENÉTICO ===\n');
        fprintf('Mejor equipo: [%s]\n', num2str(mejorEquipo));
        fprintf('Tasa victorias: %.1f%%\n', 100*mejorAptitud);
        fprintf('Suma: %d\n', sum(mejorEquipo));
    end
end

% --- Funciones auxiliares ---

function val = obtenerOpcion(opciones, campo, porDefecto)
    if isfield(opciones, campo)
        val = opciones.(campo);
    else
        val = porDefecto;
    end
end

function idx = seleccionTorneo(poblacion, aptitud, k)
    candidatos = randperm(size(poblacion,1), k);
    [~, mejor] = max(aptitud(candidatos));
    idx = candidatos(mejor);
end

function hijo = cruce(padre1, padre2, presupuesto)
    % Cruce uniforme con reparación de presupuesto
    mascara = rand(1,10) > 0.5;
    hijo = padre1 .* mascara + padre2 .* (~mascara);
    hijo = round(hijo);
    hijo = max(hijo, 1);   % PDF: enteros positivos, cero prohibido
    hijo = repararPresupuesto(hijo, presupuesto);
end

function equipo = mutar(equipo, presupuesto)
    % Tres tipos de mutación para mantener diversidad.
    % Siempre se preserva min(equipo) >= 1 (PDF: "entradas enteras positivas").
    r = rand();
    if r < 0.5
        % Intercambio: mover puntos entre dos parámetros, nunca por debajo de 1
        i = randi(10);
        j = randi(10);
        while j == i, j = randi(10); end
        cantidad = randi(3);
        if equipo(i) - cantidad >= 1
            equipo(i) = equipo(i) - cantidad;
            equipo(j) = equipo(j) + cantidad;
        end
    elseif r < 0.8
        % Reinicio aleatorio de un parámetro + reparación (mínimo 1)
        idx = randi(10);
        equipo(idx) = randi([1, 25]);
        equipo = repararPresupuesto(equipo, presupuesto);
    else
        % Barajar: mezclar un subconjunto de parámetros
        indices = randperm(10, 3);
        valores = equipo(indices);
        equipo(indices) = valores(randperm(3));
    end
end

function equipo = repararPresupuesto(equipo, presupuesto)
    % Asegura suma = presupuesto exacto con enteros >= 1.
    equipo = max(round(equipo), 1);
    diferencia = sum(equipo) - presupuesto;
    while diferencia ~= 0
        if diferencia > 0
            % Reducir un parámetro que sea > 1 (mantener >= 1)
            reducibles = find(equipo > 1);
            if isempty(reducibles), break; end
            idx      = reducibles(randi(length(reducibles)));
            reduccion = min(equipo(idx) - 1, diferencia);
            equipo(idx) = equipo(idx) - reduccion;
            diferencia  = diferencia  - reduccion;
        else
            idx = randi(10);
            equipo(idx) = equipo(idx) + 1;
            diferencia  = diferencia  + 1;
        end
    end
end
