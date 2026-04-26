% =========================================================================
% INTERÓPTIMO DE LAGRANGE - MAPEO DE SENSIBILIDAD 3D (EF vs TE)
% =========================================================================
clear; clc;

% --- 1. CONFIGURACIÓN ---
rutaProyecto = '..\PROYECTO';
addpath(genpath(rutaProyecto));

fprintf('Generando Mapa 3D de Sensibilidad...\n');
fprintf('Esto simulará miles de partidos para trazar la montaña matemática.\n');

% Rangos a explorar (Eficacia y Técnico)
rango_EF = 10:2:32; % De 10 a 32, de dos en dos
rango_TE = 10:2:32;
[X_EF, Y_TE] = meshgrid(rango_EF, rango_TE);
Z_WinRate = zeros(size(X_EF));

% Rival de prueba (Balanceado)
rival = [10 10 10 10 10 10 10 10 10 10];
partidos_prueba = 50; % Partidos por cada punto de la gráfica

% --- 2. BÚSQUEDA EN MALLA (GRID SEARCH) ---
for i = 1:size(X_EF, 1)
    for j = 1:size(X_EF, 2)
        ef_val = X_EF(i, j);
        te_val = Y_TE(i, j);
        
        % Restricción dura: La suma debe ser 100 y mínimo 1.
        % Si gastamos ef_val y te_val, nos quedan P puntos para 8 atributos.
        puntos_restantes = 100 - ef_val - te_val;
        
        if puntos_restantes < 8
            % Imposible cumplir min=1, le ponemos Win-Rate 0
            Z_WinRate(i, j) = 0; 
            continue;
        end
        
        % Distribuimos el resto uniformemente (y los picos aleatorios)
        eq_base = ones(1, 10);
        eq_base(9) = ef_val;
        eq_base(10) = te_val;
        
        p_repartir = puntos_restantes - 8;
        for p = 1:p_repartir
            idx = randi(8); % Solo suma a los primeros 8 atributos
            eq_base(idx) = eq_base(idx) + 1;
        end
        
        % Evaluamos este punto exacto del mapa
        victorias = 0;
        for k = 1:partidos_prueba
            % Usamos playMatchOpen para que la gráfica no tarde horas en generarse
            [gf, gc] = playMatchOpen(eq_base, rival);
            if gf > gc
                victorias = victorias + 1;
            end
        end
        
        Z_WinRate(i, j) = (victorias / partidos_prueba) * 100;
    end
end

% --- 3. DIBUJAR GRÁFICA 3D ---
figure('Name', 'Interóptimo de Lagrange - Paisaje de Sensibilidad', 'Position', [100 100 800 600]);
surf(X_EF, Y_TE, Z_WinRate);
colormap jet; % Colores desde azul (frío/malo) hasta rojo (caliente/bueno)
colorbar;
shading interp; % Suavizado de la malla

% Etiquetas profesionales
title('\bfTopografía de Victorias: Eficacia vs Técnico', 'FontSize', 14);
xlabel('\bfEficacia (A9)', 'FontSize', 12);
ylabel('\bfTécnico (A10)', 'FontSize', 12);
zlabel('\bfTasa de Victorias (%)', 'FontSize', 12);

% Marcar el punto más alto
[max_wr, max_idx] = max(Z_WinRate(:));
[max_row, max_col] = ind2sub(size(Z_WinRate), max_idx);
hold on;
plot3(X_EF(max_row, max_col), Y_TE(max_row, max_col), max_wr + 2, 'ko', 'MarkerSize', 10, 'MarkerFaceColor', 'white');
text(X_EF(max_row, max_col), Y_TE(max_row, max_col), max_wr + 5, ...
    sprintf(' Óptimo Local\\n WR: %.1f%%', max_wr), 'FontSize', 10, 'FontWeight', 'bold');
hold off;

% Ajustar vista para que se vea la montaña de lado
view(-45, 45);
grid on;

fprintf('\n✅ Gráfica 3D generada. Guárdala como imagen para la presentación.\n');