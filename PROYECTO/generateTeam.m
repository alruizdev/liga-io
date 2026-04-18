function equipo = generateTeam(presupuesto)
% GENERAR EQUIPO - Genera un equipo aleatorio válido
%
% Empieza todos los parámetros a 1 (garantiza min >= 1) y
% distribuye el presupuesto restante al azar entre los 10 parámetros.
%
% PARÁMETROS:
%   presupuesto - suma total del equipo (por defecto 100)
%
% SALIDAS:
%   equipo - vector 1x10 de enteros positivos con suma = presupuesto

    if nargin < 1
        presupuesto = 100;
    end

    % Arrancar con todo a 1 → garantiza que ningún parámetro sea 0
    equipo   = ones(1, 10);
    restante = presupuesto - 10;

    % Repartir el resto aleatoriamente entre los 10 parámetros
    for i = 1:restante
        idx         = randi(10);
        equipo(idx) = equipo(idx) + 1;
    end
end
