function [equipo, objetivoAprox, deltas] = crashingBaseline(deltas, opciones)
% CRASHING BASELINE - PL entero linealizado (estilo Crashing) via greedy óptimo.
%
% Reinterpreta el diseño del equipo como un PL de Crashing PERT/CPM:
%   cada parámetro i es una "actividad" con beneficio marginal delta_i
%   (de sensitivityAnalysis) y coste unitario 1 (un punto de presupuesto).
%   Maximiza sum(delta_i * x_i) sujeto a restricción de presupuesto y
%   cotas enteras por parámetro. Con una sola restricción presupuestaria
%   y cotas superiores finitas, el PL tiene óptimo greedy analítico.
%
% Parámetros de entrada:
%   deltas   - vector 10x1 de marginales de tasa de victorias (por defecto:
%              carga desde sensitivity_baseline.mat via sensitivityAnalysis.m)
%   opciones - struct con campos opcionales:
%              .presupuesto          suma objetivo del equipo (por defecto 100)
%              .minimoBase           mínimo por parámetro (por defecto 3)
%              .maximoAltaPositivo   cota sup. para delta > 5% (por defecto 20)
%              .maximoPositivo       cota sup. para 0 < delta <= 5% (por defecto 15)
%              .maximoNeutro         cota sup. para |delta| ~= 0 (por defecto 10)
%              .maximoNegativo       cota sup. para delta < 0 (por defecto 6)
%
% Salidas:
%   equipo        - vector 1x10 entero, válido según validateTeam
%   objetivoAprox - valor del objetivo linealizado (sum delta_i * x_i)
%   deltas        - vector de sensibilidades realmente usado

    if nargin < 1 || isempty(deltas)
        if exist('sensitivity_baseline.mat','file')
            S = load('sensitivity_baseline.mat');
            deltas = S.results.deltas(:);
        else
            error(['No se proporcionaron deltas y no se encuentra sensitivity_baseline.mat. ' ...
                   'Ejecuta: resultados = sensitivityAnalysis(10*ones(1,10), 100, 20); ' ...
                   'save(''sensitivity_baseline.mat'',''resultados'')']);
        end
    end
    if nargin < 2, opciones = struct(); end
    presupuesto        = obtenerOpcion(opciones, 'presupuesto',        100);
    minimoBase         = obtenerOpcion(opciones, 'minimoBase',           3);
    maximoAltaPositivo = obtenerOpcion(opciones, 'maximoAltaPositivo',  20);
    maximoPositivo     = obtenerOpcion(opciones, 'maximoPositivo',      15);
    maximoNeutro       = obtenerOpcion(opciones, 'maximoNeutro',        10);
    maximoNegativo     = obtenerOpcion(opciones, 'maximoNegativo',       6);

    deltas = deltas(:);
    assert(numel(deltas) == 10, 'deltas debe ser un vector de 10 elementos');

    % --- 1. Cotas por parámetro según magnitud y signo del delta ---
    % La sensibilidad local solo vale cerca del punto base. Las cotas evitan
    % extrapolar a donde la linealización rompe (FI=GO=0 destruye el ataque).
    cotaInferior = minimoBase * ones(10,1);
    cotaSuperior = zeros(10,1);
    for i = 1:10
        d = 100 * deltas(i);         % delta en puntos porcentuales
        if d > 5
            cotaSuperior(i) = maximoAltaPositivo;
        elseif d > 0
            cotaSuperior(i) = maximoPositivo;
        elseif d > -2
            cotaSuperior(i) = maximoNeutro;
        else
            cotaSuperior(i) = maximoNegativo;
        end
    end

    % Comprobación de factibilidad
    if sum(cotaInferior) > presupuesto
        error('Suma de cotas inferiores (%d) supera el presupuesto (%d)', sum(cotaInferior), presupuesto);
    end
    if sum(cotaSuperior) < 95
        error('Suma de cotas superiores (%d) menor que 95 — inviable', sum(cotaSuperior));
    end

    % --- 2. Partir de cotas inferiores, distribuir el resto con greedy ---
    [~, orden] = sort(deltas, 'descend');
    x        = cotaInferior;
    restante = presupuesto - sum(x);
    for k = 1:10
        i         = orden(k);
        capacidad = cotaSuperior(i) - x(i);
        anadir    = min(capacidad, restante);
        if anadir > 0
            x(i)     = x(i) + anadir;
            restante = restante - anadir;
        end
        if restante <= 0, break; end
    end

    equipo = round(x(:))';

    % --- 3. Asegurar suma en [95, 100] ---
    suma = sum(equipo);
    if suma < 95
        for k = 1:10
            i = orden(k);
            while equipo(i) < cotaSuperior(i) + 5 && suma < 95
                equipo(i) = equipo(i) + 1; suma = suma + 1;
            end
            if suma >= 95, break; end
        end
    elseif suma > 100
        for k = 10:-1:1
            i = orden(k);
            while equipo(i) > 1 && suma > 100
                equipo(i) = equipo(i) - 1; suma = suma - 1;
            end
            if suma <= 100, break; end
        end
    end

    objetivoAprox = deltas' * equipo(:);

    % --- 4. Validar contra reglas de entrega ---
    [ok, msg] = validateTeam(equipo);
    if ~ok
        error('crashingBaseline produjo un equipo inválido: %s', msg);
    end

    % --- 5. Informe ---
    nombresParam = {'FI','GO','JD','MA','OR','PR','PO','TR','EF','TE'};
    fprintf('\n=== CRASHING BASELINE (greedy PL) ===\n');
    fprintf('%-5s  delta(%%)   cota   x\n', 'Param');
    fprintf('%s\n', repmat('-', 1, 35));
    for k = 1:10
        i = orden(k);
        fprintf('%-5s  %+6.2f    %3d  %3d\n', ...
                nombresParam{i}, 100*deltas(i), cotaSuperior(i), equipo(i));
    end
    fprintf('\nEquipo: [%s]  suma=%d\n', num2str(equipo), sum(equipo));
    fprintf('z_aprox = sum(delta_i * x_i) = %+.4f (proxy linealizado de tasa victorias)\n', objetivoAprox);
end

function v = obtenerOpcion(s, campo, porDefecto)
    if isfield(s, campo)
        v = s.(campo);
    else
        v = porDefecto;
    end
end
