function r = binornd(n, p, varargin)
% BINORND - Sustituto sin Statistics Toolbox para playMatch.p
%
% Reemplaza la función oficial binornd usando suma de Bernoulli:
%   r = sum(rand(1,n) < p)
% Soporta:
%   - n y p escalares
%   - n escalar, p escalar, tamaño explícito en varargin
%   - n vector y p escalar (o viceversa)
% Devuelve enteros >= 0 con la misma forma que el caller espera.

    if nargin >= 3
        if numel(varargin) == 1 && numel(varargin{1}) > 1
            sz = varargin{1};
        else
            sz = [varargin{:}];
        end
    elseif ~isscalar(n)
        sz = size(n);
    elseif ~isscalar(p)
        sz = size(p);
    else
        sz = [1 1];
    end

    n = double(n);
    p = double(p);
    r = zeros(sz);
    total = numel(r);

    for i = 1:total
        if isscalar(n), ni = n; else, ni = n(i); end
        if isscalar(p), pi = p; else, pi = p(i); end

        ni = floor(ni);
        if ni <= 0 || pi <= 0 || ~isfinite(ni) || ~isfinite(pi)
            r(i) = 0;
        elseif pi >= 1
            r(i) = ni;
        else
            r(i) = sum(rand(1, ni) < pi);
        end
    end
end
