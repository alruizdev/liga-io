% =========================================================================
% SIMULADOR DE FUERZA BRUTA - LIGA IO 2026 (Usando playMatch oficial)
% =========================================================================
clear; clc;

% --- 1. CONFIGURACIÓN ---
% He puesto 10.000 para que la prueba sea rápida, puedes subirlo a 100.000 luego
num_candidatos = 1000000; 
num_rivales = 30;     
partidos_por_rival = 15; 

% Matrices para guardar los equipos
candidatos = zeros(num_candidatos, 10);
rivales = zeros(num_rivales, 10);

fprintf('Generando %d equipos candidatos y %d rivales...\n', num_candidatos, num_rivales);

% --- 2. GENERACIÓN DE EQUIPOS VÁLIDOS ---
% Función anónima para generar un equipo válido (suma entre 95 y 100)
generar_equipo = @() repartir_puntos(randi([95, 100]));

for i = 1:num_candidatos
    candidatos(i, :) = generar_equipo();
end
for i = 1:num_rivales
    rivales(i, :) = generar_equipo();
end

% --- 3. SIMULACIÓN DE LA LIGA ---
% Estadísticas: [Puntos, Goles a Favor, Goles en Contra, Diferencia de Goles]
estadisticas = zeros(num_candidatos, 4); 
fprintf('Iniciando simulación de partidos con playMatch oficial... Esto puede tardar.\n');

for i = 1:num_candidatos
    equipo_A = candidatos(i, :);
    
    puntos_liga = 0;
    goles_favor = 0;
    goles_contra = 0;
    
    for j = 1:num_rivales
        equipo_B = rivales(j, :);
        
        % Jugar varios partidos contra el mismo rival para sacar una media justa
        for k = 1:partidos_por_rival
            
            % -------------------------------------------------------------
            % LLAMADA A LA FUNCIÓN ORIGINAL DEL PROFESOR
            % -------------------------------------------------------------
            [GA_vec, GB_vec] = playMatch(equipo_A, equipo_B);
            
            % playMatch puede devolver medias o vectores, aseguramos un número entero
            goles_A = round(mean(GA_vec)); 
            goles_B = round(mean(GB_vec));
            
            % Acumular goles
            goles_favor = goles_favor + goles_A;
            goles_contra = goles_contra + goles_B;
            
            % Asignar puntos de liga (3 por victoria, 1 por empate)
            if goles_A > goles_B
                puntos_liga = puntos_liga + 3;
            elseif goles_A == goles_B
                puntos_liga = puntos_liga + 1;
            end
        end
    end
    
    % Guardar estadísticas del candidato i
    estadisticas(i, 1) = puntos_liga;
    estadisticas(i, 2) = goles_favor;
    estadisticas(i, 3) = goles_contra;
    estadisticas(i, 4) = goles_favor - goles_contra; % Diferencia de goles
end

% --- 4. RESULTADOS Y SELECCIÓN DEL MEJOR ---
% Ordenar por puntos (columna 1) de mayor a menor. 
% En caso de empate, sortrows usará la diferencia de goles (columna 4)
[~, idx_ordenados] = sortrows(estadisticas, [1, 4], 'descend');

fprintf('\n=== RESULTADOS DE LA BÚSQUEDA ===\n');
mejor_equipo = candidatos(idx_ordenados(1), :);
mejores_estadisticas = estadisticas(idx_ordenados(1), :);

fprintf('MEJOR EQUIPO ENCONTRADO:\n');
fprintf('A = [%d, %d, %d, %d, %d, %d, %d, %d, %d, %d]\n', mejor_equipo);
fprintf('Puntos: %d | Goles a Favor: %d | Goles en Contra: %d | Diferencia: %d\n', ...
    mejores_estadisticas(1), mejores_estadisticas(2), mejores_estadisticas(3), mejores_estadisticas(4));
fprintf('Gasto total de presupuesto: %d\n', sum(mejor_equipo));

% Guardar el mejor equipo en el formato requerido (.mat)
serial = '01'; % Cámbialo por tu serial asignado
nombre_archivo = sprintf('%s.mat', serial);
v = mejor_equipo; 
save(nombre_archivo, 'v');
fprintf('\nEquipo guardado exitosamente en %s (variable v)\n', nombre_archivo);


% =========================================================================
% FUNCIÓN AUXILIAR PARA REPARTIR PUNTOS
% =========================================================================
function eq = repartir_puntos(presupuesto)
    eq = zeros(1, 10);
    for p = 1:presupuesto
        idx = randi(10); % Elegir un atributo al azar (del 1 al 10)
        eq(idx) = eq(idx) + 1; % Sumarle 1 punto
    end
end