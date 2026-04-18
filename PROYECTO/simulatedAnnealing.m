function [mejorEquipo, mejorAptitud, historial] = simulatedAnnealing(equipoInicial, opciones)
% RECOCIDO SIMULADO - Refina un vector de equipo usando Simulated Annealing
%
% Parámetros de entrada:
%   equipoInicial - vector 1x10 de partida (ej. resultado del AG)
%   opciones - struct con campos opcionales:
%     .maxIteraciones     - iteraciones máximas (por defecto 5000)
%     .temperaturaInicial - temperatura de inicio (por defecto 5)
%     .temperaturaMinima  - temperatura mínima (por defecto 0.01)
%     .tasaEnfriamiento   - factor de enfriamiento (por defecto 0.995)
%     .numRivales         - rivales por evaluación (por defecto 100)
%     .numPartidos        - partidos por rival (por defecto 20)
%     .presupuesto        - suma total (por defecto 100)
%     .mostrarProgreso    - imprimir avance (por defecto true)
%
% Salidas:
%   mejorEquipo   - mejor equipo encontrado
%   mejorAptitud  - tasa de victorias del mejor equipo
%   historial     - datos de convergencia

    if nargin < 2, opciones = struct(); end
    maxIteraciones     = obtenerOpcion(opciones, 'maxIteraciones',     5000);
    temperaturaInicial = obtenerOpcion(opciones, 'temperaturaInicial',    5);
    temperaturaMinima  = obtenerOpcion(opciones, 'temperaturaMinima',  0.01);
    tasaEnfriamiento   = obtenerOpcion(opciones, 'tasaEnfriamiento',  0.995);
    numRivales         = obtenerOpcion(opciones, 'numRivales',          100);
    numPartidos        = obtenerOpcion(opciones, 'numPartidos',          20);
    presupuesto        = obtenerOpcion(opciones, 'presupuesto',         100);
    mostrarProgreso    = obtenerOpcion(opciones, 'mostrarProgreso',     true);

    % Inicializar
    actual        = equipoInicial;
    aptitudActual = evaluateTeam(actual, numRivales, numPartidos);
    mejorEquipo   = actual;
    mejorAptitud  = aptitudActual;
    temperatura   = temperaturaInicial;

    historial.aptitud      = zeros(maxIteraciones, 1);
    historial.mejorAptitud = zeros(maxIteraciones, 1);
    historial.temperatura  = zeros(maxIteraciones, 1);

    if mostrarProgreso
        fprintf('SA Inicio: Aptitud=%.3f Equipo=[%s]\n', aptitudActual, num2str(actual));
    end

    for iteracion = 1:maxIteraciones
        % Generar vecino
        vecino = generarVecino(actual, presupuesto);

        % Evaluar vecino
        aptitudVecino = evaluateTeam(vecino, numRivales, numPartidos);

        % Criterio de aceptación de Metropolis
        cambioAptitud = aptitudVecino - aptitudActual;
        if cambioAptitud > 0 || rand() < exp(cambioAptitud / temperatura)
            actual        = vecino;
            aptitudActual = aptitudVecino;
        end

        % Actualizar mejor
        if aptitudActual > mejorAptitud
            mejorEquipo  = actual;
            mejorAptitud = aptitudActual;
        end

        % Enfriar temperatura
        temperatura = temperatura * tasaEnfriamiento;
        if temperatura < temperaturaMinima
            temperatura = temperaturaMinima;
        end

        historial.aptitud(iteracion)      = aptitudActual;
        historial.mejorAptitud(iteracion) = mejorAptitud;
        historial.temperatura(iteracion)  = temperatura;

        if mostrarProgreso && mod(iteracion, 200) == 0
            fprintf('SA Iter %4d: T=%.4f Actual=%.3f Mejor=%.3f Equipo=[%s]\n', ...
                iteracion, temperatura, aptitudActual, mejorAptitud, num2str(mejorEquipo));
        end
    end

    if mostrarProgreso
        fprintf('\n=== RESULTADO RECOCIDO SIMULADO ===\n');
        fprintf('Mejor equipo: [%s]\n', num2str(mejorEquipo));
        fprintf('Tasa victorias: %.1f%%\n', 100*mejorAptitud);
    end
end

function val = obtenerOpcion(opciones, campo, porDefecto)
    if isfield(opciones, campo)
        val = opciones.(campo);
    else
        val = porDefecto;
    end
end

function vecino = generarVecino(equipo, presupuesto)
    % Todos los movimientos preservan min(vecino) >= 1 (PDF: entradas positivas).
    vecino = equipo;
    r = rand();
    if r < 0.6
        % Intercambio: mover 1-3 unidades, la fuente siempre queda >= 1
        i = randi(10); j = randi(10);
        while j == i, j = randi(10); end
        maxMovimiento = min(3, vecino(i) - 1);
        if maxMovimiento >= 1
            cantidad   = randi(maxMovimiento);
            vecino(i)  = vecino(i) - cantidad;
            vecino(j)  = vecino(j) + cantidad;
        end
    elseif r < 0.85
        % Doble intercambio: dos movimientos simultáneos, respetando >= 1
        indices = randperm(10, 4);
        maxMov1 = min(2, vecino(indices(1)) - 1);
        maxMov2 = min(2, vecino(indices(3)) - 1);
        if maxMov1 >= 1 && maxMov2 >= 1
            cant1 = randi(maxMov1);
            cant2 = randi(maxMov2);
            vecino(indices(1)) = vecino(indices(1)) - cant1;
            vecino(indices(2)) = vecino(indices(2)) + cant1;
            vecino(indices(3)) = vecino(indices(3)) - cant2;
            vecino(indices(4)) = vecino(indices(4)) + cant2;
        end
    else
        % Perturbación aleatoria + reparación (mínimo 1)
        idx = randi(10);
        vecino(idx) = randi([1, 30]);
        vecino = repararPresupuesto(vecino, presupuesto);
    end
end

function equipo = repararPresupuesto(equipo, presupuesto)
    % Asegura suma = presupuesto exacto con enteros >= 1.
    equipo = max(round(equipo), 1);
    diferencia = sum(equipo) - presupuesto;
    while diferencia ~= 0
        if diferencia > 0
            reducibles = find(equipo > 1);
            if isempty(reducibles), break; end
            idx       = reducibles(randi(length(reducibles)));
            reduccion  = min(equipo(idx) - 1, diferencia);
            equipo(idx) = equipo(idx) - reduccion;
            diferencia  = diferencia  - reduccion;
        else
            idx = randi(10);
            equipo(idx) = equipo(idx) + 1;
            diferencia  = diferencia  + 1;
        end
    end
end
