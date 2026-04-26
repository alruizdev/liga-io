% =========================================================================
% SIMULADOR DE FUERZA BRUTA / MONTECARLO - LIGA IO 2026 (CON FORMATO FINAL)
% =========================================================================
clear; clc;

% --- 0. CONFIGURACIÓN DE RUTAS ---
rutaProyecto = 'C:\Users\ivanl\OneDrive - Universidad Rey Juan Carlos\4º de carrera\2º Cuatrimestre\Investigacion_Operativa\Proyecto\liga-io\PROYECTO';
addpath(genpath(rutaProyecto));

% Empezamos a cronometrar el tiempo total
t_inicio = tic;

% --- 1. CONFIGURACIÓN ---
num_candidatos = 10000; % 10k para que no tarde una eternidad
num_rivales = 20;     
partidos_por_rival = 5; 

candidatos = zeros(num_candidatos, 10);
rivales = zeros(num_rivales, 10);

fprintf('Generando %d equipos candidatos (Suma=100, Mínimo=1)...\n', num_candidatos);

% --- 2. GENERACIÓN DE EQUIPOS VÁLIDOS ---
% CORRECCIÓN: Fijamos el presupuesto exactamente a 100
generar_equipo = @() repartir_puntos(100);

for i = 1:num_candidatos
    candidatos(i, :) = generar_equipo();
end
for i = 1:num_rivales
    rivales(i, :) = generar_equipo();
end

% --- 3. SIMULACIÓN DE LA LIGA ---
estadisticas = zeros(num_candidatos, 4); 
fprintf('Iniciando simulación con playMatch oficial... Esto tardará un poco.\n');

for i = 1:num_candidatos
    equipo_A = candidatos(i, :);
    puntos_liga = 0; goles_favor = 0; goles_contra = 0;
    
    for j = 1:num_rivales
        equipo_B = rivales(j, :);
        for k = 1:partidos_por_rival
            % Usamos el simulador oficial del profesor
            [goles_A, goles_B] = playMatch(equipo_A, equipo_B);
            
            goles_favor = goles_favor + goles_A;
            goles_contra = goles_contra + goles_B;
            
            if goles_A > goles_B
                puntos_liga = puntos_liga + 3;
            elseif goles_A == goles_B
                puntos_liga = puntos_liga + 1;
            end
        end
    end
    estadisticas(i, 1) = puntos_liga;
    estadisticas(i, 2) = goles_favor;
    estadisticas(i, 3) = goles_contra;
    estadisticas(i, 4) = goles_favor - goles_contra;
end

% --- 4. SELECCIÓN DEL MEJOR ---
[~, idx_ordenados] = sortrows(estadisticas, [1, 4], 'descend');
mejor_equipo = candidatos(idx_ordenados(1), :);

% --- 5. EVALUACIÓN ROBUSTA Y SALIDA FINAL ---
fprintf('\nRealizando Monte Carlo final (500 rivales x 100 partidos) para calcular Win-Rate real...\n');
[wr, ~, ~, gf, gc] = evaluateTeam(mejor_equipo, 500, 100);

tiempo_minutos = toc(t_inicio) / 60;

% Guardado con variable independiente para que la tengas localizada
v_fuerza_bruta = mejor_equipo; 
nombre_archivo = 'resultado_fuerza_bruta.mat';
save(nombre_archivo, 'v_fuerza_bruta');

% Formato exacto que has pedido
fprintf('\n======================================================\n');
fprintf('⭐ EQUIPO PERFECTO ENCONTRADO ⭐\n\n');
fprintf('Vector: [%2d  %2d  %2d  %2d  %2d  %2d  %2d  %2d  %2d  %2d]\n\n', mejor_equipo);
fprintf('Win-Rate Final: %.1f%%\n\n', 100 * wr);
fprintf('Media Goles Favor: %.2f | Contra: %.2f\n\n', gf, gc);
fprintf('Tiempo total: %.1f minutos\n', tiempo_minutos);
fprintf('======================================================\n\n');
fprintf('Resultado guardado en %s (variable "v_fuerza_bruta")\n', nombre_archivo);

% =========================================================================
% FUNCIÓN AUXILIAR CORREGIDA (Evita ceros)
% =========================================================================
function eq = repartir_puntos(presupuesto)
    % CORRECCIÓN: Empezamos todos en 1 para evitar descalificación
    eq = ones(1, 10); 
    puntos_restantes = presupuesto - 10;
    
    for p = 1:puntos_restantes
        idx = randi(10); 
        eq(idx) = eq(idx) + 1; 
    end
end