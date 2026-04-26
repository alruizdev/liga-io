% =========================================================================
% INTERÓPTIMO DE LAGRANGE - PARTICLE SWARM OPTIMIZATION (PSO)
% =========================================================================
clear; clc;

% --- 1. CONFIGURACIÓN DE RUTAS ---
rutaProyecto = '..\PROYECTO';
addpath(genpath(rutaProyecto));

fprintf('Iniciando Enjambre de Partículas (PSO)...\n');
t_inicio = tic;

% --- 2. PARÁMETROS DEL PSO ---
numParticulas = 200;  % Número de equipos simultáneos explorando
maxIter       = 100;  % Cuántos "vuelos" van a dar
numRivales    = 150;  % Para evaluar rápido la aptitud
numPartidos   = 50;

w  = 0.7;  % Inercia (tendencia a seguir su propio camino)
c1 = 1.5;  % Factor cognitivo (tendencia a volver a su mejor marca personal)
c2 = 1.5;  % Factor social (tendencia a ir hacia el líder global)

% --- 3. INICIALIZACIÓN DEL ENJAMBRE ---
posicion = zeros(numParticulas, 10);
velocidad = zeros(numParticulas, 10);
pbest_pos = zeros(numParticulas, 10);
pbest_val = zeros(numParticulas, 1);

gbest_pos = zeros(1, 10);
gbest_val = 0;

fprintf('Inicializando el enjambre de %d partículas...\n', numParticulas);
for i = 1:numParticulas
    % Generamos posiciones iniciales válidas
    posicion(i, :) = generar_equipo_valido();
    velocidad(i, :) = randn(1, 10) * 2; % Velocidad inicial aleatoria
    
    % Evaluamos
    [wr, ~, ~] = evaluateTeam(posicion(i, :), numRivales, numPartidos);
    
    pbest_pos(i, :) = posicion(i, :);
    pbest_val(i) = wr;
    
    if wr > gbest_val
        gbest_val = wr;
        gbest_pos = posicion(i, :);
    end
end

% --- 4. BUCLE PRINCIPAL PSO ---
for iter = 1:maxIter
    fprintf('Iteración %d/%d - Mejor Win-Rate Global: %.1f%%\n', iter, maxIter, 100*gbest_val);
    
    for i = 1:numParticulas
        % Actualizar velocidad
        r1 = rand(1, 10);
        r2 = rand(1, 10);
        velocidad(i, :) = w * velocidad(i, :) ...
                        + c1 * r1 .* (pbest_pos(i, :) - posicion(i, :)) ...
                        + c2 * r2 .* (gbest_pos - posicion(i, :));
        
        % Actualizar posición
        posicion(i, :) = posicion(i, :) + velocidad(i, :);
        
        % REPARACIÓN CRÍTICA: Asegurar min=1 y suma=100
        posicion(i, :) = reparar_particula(posicion(i, :), 100);
        
        % Evaluar nueva posición
        [wr, ~, ~] = evaluateTeam(posicion(i, :), numRivales, numPartidos);
        
        % Actualizar memoria personal (pbest)
        if wr > pbest_val(i)
            pbest_val(i) = wr;
            pbest_pos(i, :) = posicion(i, :);
        end
        
        % Actualizar memoria global (gbest)
        if wr > gbest_val
            gbest_val = wr;
            gbest_pos = posicion(i, :);
        end
    end
end

% --- 5. EVALUACIÓN FINAL ROBUSTA ---
fprintf('\nConvergencia alcanzada. Realizando Monte Carlo final (500x100)...\n');
[wr_final, ~, ~, gf, gc] = evaluateTeam(gbest_pos, 500, 100);

tiempo_minutos = toc(t_inicio) / 60;

% Guardado del resultado
v_pso = gbest_pos; 
nombre_archivo = 'resultado_pso.mat';
save(nombre_archivo, 'v_pso');

% --- 6. SALIDA DE RESULTADOS ---
fprintf('\n======================================================\n');
fprintf('⭐ LÍDER DEL ENJAMBRE ENCONTRADO (PSO) ⭐\n\n');
fprintf('Vector: [%2d  %2d  %2d  %2d  %2d  %2d  %2d  %2d  %2d  %2d]\n\n', gbest_pos);
fprintf('Win-Rate Final: %.1f%%\n\n', 100 * wr_final);
fprintf('Media Goles Favor: %.2f | Contra: %.2f\n\n', gf, gc);
fprintf('Tiempo total: %.1f minutos\n', tiempo_minutos);
fprintf('======================================================\n\n');
fprintf('Resultado guardado en %s (variable "v_pso")\n', nombre_archivo);


% =========================================================================
% FUNCIONES AUXILIARES DE REPARACIÓN (Vitales para no ser descalificados)
% =========================================================================
function eq = generar_equipo_valido()
    eq = ones(1, 10);
    puntos_restantes = 100 - 10;
    for p = 1:puntos_restantes
        idx = randi(10);
        eq(idx) = eq(idx) + 1;
    end
end

function eq = reparar_particula(pos, presupuesto)
    % 1. Forzar enteros positivos (min >= 1)
    eq = max(round(pos), 1);
    
    % 2. Ajustar la suma para que sea exactamente el presupuesto
    diferencia = sum(eq) - presupuesto;
    while diferencia ~= 0
        if diferencia > 0
            % Quitar un punto al azar a un atributo que sea mayor a 1
            reducibles = find(eq > 1);
            if isempty(reducibles), break; end
            idx = reducibles(randi(length(reducibles)));
            eq(idx) = eq(idx) - 1;
            diferencia = diferencia - 1;
        else
            % Añadir un punto al azar
            idx = randi(10);
            eq(idx) = eq(idx) + 1;
            diferencia = diferencia + 1;
        end
    end
end