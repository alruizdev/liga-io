% =========================================================================
% INTERÓPTIMO DE LAGRANGE - ANÁLISIS DE VARIANZA Y RIESGO (VaR)
% =========================================================================
clear; clc;
addpath(genpath('..\PROYECTO'));

mi_equipo = [6, 9, 9, 11, 10, 1, 6, 6, 24, 18];

num_ligas = 100; % Simulamos 100 LIGAS completas distintas
partidos_por_liga = 200; % Cada liga son 200 partidos
resultados_ligas = zeros(num_ligas, 1);

fprintf('Simulando %d universos paralelos de la Liga...\n', num_ligas);

for i = 1:num_ligas
    victorias_esta_liga = 0;
    for j = 1:partidos_por_liga
        % Generamos un rival distinto cada partido
        rival = ones(1,10); 
        for p=1:90, idx=randi(10); rival(idx)=rival(idx)+1; end
        
        [gf, gc] = playMatch(mi_equipo, rival);
        if gf > gc, victorias_esta_liga = victorias_esta_liga + 1; end
    end
    resultados_ligas(i) = (victorias_esta_liga / partidos_por_liga) * 100;
end

% Cálculos estadísticos de IO
media_wr = mean(resultados_ligas);
desviacion = std(resultados_ligas);
peor_escenario = prctile(resultados_ligas, 5); % El percentil 5 (Si tenemos muy mala suerte)
mejor_escenario = prctile(resultados_ligas, 95); % El percentil 95 (Si tenemos mucha suerte)

fprintf('\n=== ANÁLISIS ESTADÍSTICO DE RIESGO ===\n');
fprintf('Win-Rate Medio (Esperanza): %.1f%%\n', media_wr);
fprintf('Volatilidad (Desviación Típica): ±%.1f%%\n', desviacion);
fprintf('Peor Escenario (Día de muy mala suerte): %.1f%%\n', peor_escenario);
fprintf('Mejor Escenario (Día de muchísima suerte): %.1f%%\n', mejor_escenario);

% Gráfico de Campana de Gauss para la presentación
figure('Name', 'Distribución del Rendimiento');
histogram(resultados_ligas, 15, 'Normalization', 'pdf', 'FaceColor', [0.2 0.6 0.8]);
title('\bfCampana de Gauss: Probabilidad de Victoria de nuestro Equipo');
xlabel('Win-Rate en la Liga (%)'); ylabel('Probabilidad');
grid on;