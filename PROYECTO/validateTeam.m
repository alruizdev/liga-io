function [valido, mensaje] = validateTeam(equipo)
% VALIDAR EQUIPO - Comprueba que el vector cumple TODAS las reglas del PDF
%
% ⚠️  IMPORTANTE: el PDF §4.1 dice "entradas enteras positivas"
%     Un matemático riguroso (como Quintero) interpreta positivo como >= 1.
%     Un cero puede provocar DESCALIFICACIÓN AUTOMÁTICA.
%
% PARÁMETROS:
%   equipo  - vector 1x10 a validar
%
% SALIDAS:
%   valido  - true si el equipo cumple todas las reglas
%   mensaje - descripción del problema (vacío si es válido)

    valido  = true;
    mensaje = '';

    % Regla 1: exactamente 10 parámetros
    if length(equipo) ~= 10
        valido  = false;
        mensaje = sprintf('El equipo debe tener 10 parámetros, tiene %d', length(equipo));
        return;
    end

    % Regla 2: todos >= 1 (PDF: "enteras positivas" — cero PROHIBIDO)
    if any(equipo < 1)
        valido  = false;
        mensaje = 'Todos los parámetros deben ser enteros positivos (>= 1). ¡Cero prohibido!';
        return;
    end

    % Regla 3: todos números enteros (sin decimales)
    if any(equipo ~= floor(equipo))
        valido  = false;
        mensaje = 'Todos los parámetros deben ser enteros (sin decimales)';
        return;
    end

    % Regla 4: suma entre 95 y 100
    suma = sum(equipo);
    if suma < 95 || suma > 100
        valido  = false;
        mensaje = sprintf('La suma debe estar entre 95 y 100, tiene %d', suma);
        return;
    end
end
