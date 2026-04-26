% =========================================================================
% INTERÓPTIMO DE LAGRANGE - EL CAZADOR DE MITOS DEL PROFESOR
% =========================================================================
clear; clc;

rutaProyecto = '..\PROYECTO';
addpath(genpath(rutaProyecto));

fprintf('======================================================\n');
fprintf('🕵️ AUDITORÍA DE LAS REGLAS OCULTAS DEL DR. QUINTERO 🕵️\n');
fprintf('======================================================\n\n');

N = 2000; % Partidos por cada prueba para que la estadística sea irrefutable

% -------------------------------------------------------------------------
% MITO 1: ¿De verdad compensa gastar 95 puntos en lugar de 100?
% -------------------------------------------------------------------------
fprintf('--- MITO 1: LA BONIFICACIÓN DE LOS 95 PUNTOS ("El Underdog") ---\n');
eq_100_puntos = [10, 10, 10, 10, 10, 10, 10, 10, 10, 10]; % Suma 100
eq_95_puntos  = [10,  9, 10,  9, 10,  9, 10,  9, 10,  9]; % Suma 95 (le quitamos 1 a 5 atributos)

vic_100 = 0; vic_95 = 0; empates = 0;
for k = 1:N
    [gf, gc] = playMatch(eq_100_puntos, eq_95_puntos);
    if gf > gc, vic_100 = vic_100 + 1;
    elseif gc > gf, vic_95 = vic_95 + 1;
    else, empates = empates + 1; end
end

fprintf('Equipo 100 ptos (Victorias): %.1f%%\n', (vic_100/N)*100);
fprintf('Equipo  95 ptos (Victorias): %.1f%%\n', (vic_95/N)*100);
if vic_100 > vic_95
    fprintf('💡 CONCLUSIÓN: Jugar con 95 puntos ES UNA TRAMPA para la Liga. Regaláis ventaja.\n\n');
else
    fprintf('🚨 ALERTA: ¡El profe decía la verdad! Jugar con 95 puntos tiene una ventaja oculta enorme.\n\n');
end


% -------------------------------------------------------------------------
% MITO 2: ¿Se penaliza romper la media de 10 (La Dispersión)?
% -------------------------------------------------------------------------
fprintf('--- MITO 2: LA PENALIZACIÓN POR DISPERSIÓN EXTREMA ---\n');
% Ambos suman 100.
eq_balanceado = [10, 10, 10, 10, 10, 10, 10, 10, 10, 10]; % Dispersión = 0
eq_extremo    = [ 2,  2,  2,  2,  2,  2,  2,  2, 42, 42]; % Dispersión = 25.6 (Brutal)

vic_bal = 0; vic_ext = 0; empates2 = 0;
for k = 1:N
    [gf, gc] = playMatch(eq_balanceado, eq_extremo);
    if gf > gc, vic_bal = vic_bal + 1;
    elseif gc > gf, vic_ext = vic_ext + 1;
    else, empates2 = empates2 + 1; end
end

fprintf('Equipo Balanceado  (Victorias): %.1f%%\n', (vic_bal/N)*100);
fprintf('Equipo Extremo 42/42(Victorias): %.1f%%\n', (vic_ext/N)*100);

if vic_bal > vic_ext
    fprintf('💡 CONCLUSIÓN: La penalización por dispersión es REAL y castiga los extremos absurdos.\n');
else
    fprintf('🚨 ALERTA: ¡El simulador está roto! La Eficacia y el Técnico a 42 ganan a pesar de la mala moral.\n');
end
fprintf('======================================================\n');