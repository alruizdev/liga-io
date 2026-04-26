% =========================================================================
% TEST DE CALIBRACIÓN: playMatchOpen vs playMatch.p
% =========================================================================
clear; clc;

% --- CONFIGURACIÓN DE RUTAS ---
% Añadimos tu carpeta de proyecto para que MATLAB encuentre playMatchOpen.m
rutaProyecto = '..\PROYECTO';
addpath(rutaProyecto);

% --- PARÁMETROS DEL TEST ---
% Usamos vuestro mejor equipo actual según la auditoría
nuestroEquipo = [6, 9, 9, 11, 10, 1, 6, 6, 24, 18]; %
rival = [10, 10, 10, 10, 10, 10, 10, 10, 10, 10];
N = 1000; 

fprintf('Iniciando comparación con playMatch oficial en: \n%s\n', rutaProyecto);

% 1. Simulación con playMatch.p (Oficial)
victoriasOficial = 0;
for k = 1:N
    [gf, gc] = playMatch(nuestroEquipo, rival); % Asumiendo que .p está en la carpeta actual
    if gf > gc, victoriasOficial = victoriasOficial + 1; end
end
wrOficial = (victoriasOficial / N) * 100;

% 2. Simulación con tu playMatchOpen.m (Abierto)
victoriasAbierto = 0;
for k = 1:N
    [gf, gc] = playMatchOpen(nuestroEquipo, rival);
    if gf > gc, victoriasAbierto = victoriasAbierto + 1; end
end
wrAbierto = (victoriasAbierto / N) * 100;

% --- RESULTADO ---
fprintf('\n=== AUDITORÍA DE SIMULACIÓN ===\n');
fprintf('Win-Rate playMatchOpen (Tu archivo): %.1f%%\n', wrAbierto);
fprintf('Win-Rate playMatch.p (Profe): %.1f%%\n', wrOficial);
fprintf('Diferencia: %.1f puntos\n', abs(wrAbierto - wrOficial));

if abs(wrAbierto - wrOficial) > 5
    fprintf('🚨 ALERTA: Hay discrepancia. El profe podría tener penalizaciones ocultas.\n');
else
    fprintf('✅ CALIBRACIÓN OK: Tu playMatchOpen es una base fiable para optimizar.\n');
end