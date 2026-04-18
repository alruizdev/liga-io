function [golesA, golesB] = playMatchOpen(A, B)
% SIMULAR PARTIDO - Reimplementación abierta de playMatch.p del profesor
% Reproduce las fórmulas del PDF §5. SOBRE ESTO optimizamos.
%
% MAPA DE PARÁMETROS (posición en el vector del equipo):
%   A(1)=FI  Finalización       A(2)=GO  Generación Ofensiva
%   A(3)=JD  Juego Directo      A(4)=MA  Marcaje
%   A(5)=OR  Organización Def.  A(6)=PR  Presión
%   A(7)=PO  Posesión           A(8)=TR  Transición
%   A(9)=EF  Eficacia           A(10)=TE Técnico
%
% SALIDAS:
%   golesA - goles marcados por equipo A
%   golesB - goles marcados por equipo B

    % === §5.1 Parámetros globales (valores fijos del PDF) ===
    gamma1 = 0.4;
    gamma2 = 0.4;
    gamma3 = 0.4;
    alfa         = 0.5;
    beta         = 0.5;
    sigma_moral  = 1.5;

    % === §5.2 Moral ===
    % dispersion mide cuánto se aleja el equipo del equilibrio (todos=10)
    % Cuanto más disperso el vector, peor la moral base
    dispersion_A = (1/10) * sum(abs(A - 10));
    dispersion_B = (1/10) * sum(abs(B - 10));

    ruido_A = randn();
    ruido_B = randn();

    moral_A = 10 - alfa*dispersion_A + beta*(A(10)/10) ...
            + sigma_moral * max(1, 100 - sum(A)) * ruido_A;
    moral_B = 10 - alfa*dispersion_B + beta*(B(10)/10) ...
            + sigma_moral * max(1, 100 - sum(B)) * ruido_B;

    moral_A = max(0, moral_A);
    moral_B = max(0, moral_B);

    % === §5.3 Cansancio ===
    % PR, PO, TR suben el cansancio; JD lo reduce
    cansancio_A = max(0, (0.4*A(6) + 0.3*A(7) + 0.3*A(8) - 0.5*A(3)) ...
                  / 10 * (1 - moral_A/12));
    cansancio_B = max(0, (0.4*B(6) + 0.3*B(7) + 0.3*B(8) - 0.5*B(3)) ...
                  / 10 * (1 - moral_B/12));

    % === §5.4 Parámetros base ===
    ataque_A  = max(0.01, 0.35*A(1) + 0.35*A(2) + 0.3*A(3));
    ataque_B  = max(0.01, 0.35*B(1) + 0.35*B(2) + 0.3*B(3));

    defensa_A = max(0.05, 0.4*A(4) + 0.4*A(5) + 0.2*A(6));
    defensa_B = max(0.05, 0.4*B(4) + 0.4*B(5) + 0.2*B(6));

    control_A = max(0.01, 0.4*A(7) + 0.4*A(8) + 0.2*A(9));
    control_B = max(0.01, 0.4*B(7) + 0.4*B(8) + 0.2*B(9));

    % === §5.5 Factores multiplicadores ===
    factor_moral_A = 0.85 + moral_A / 20;
    factor_moral_B = 0.85 + moral_B / 20;

    % TE es el multiplicador global más potente (sensibilidad +7.3%)
    factor_tecnico_A = 0.9 + A(10) / 50;
    factor_tecnico_B = 0.9 + B(10) / 50;

    factor_cansancio_A = max(0.1, 1 - 0.6*cansancio_A);
    factor_cansancio_B = max(0.1, 1 - 0.6*cansancio_B);

    % === §5.6 Control efectivo ===
    control_efectivo_A = control_A * factor_moral_A * factor_tecnico_A * factor_cansancio_A;
    control_efectivo_B = control_B * factor_moral_B * factor_tecnico_B * factor_cansancio_B;

    % === §5.7 Posesión ===
    posesion_A = control_efectivo_A / (control_efectivo_A + control_efectivo_B);
    posesion_B = 1 - posesion_A;

    % === §5.8 Interacción táctica ===
    tactica1_A = 1 + gamma1 * (A(6) - B(7)) / 100;
    tactica2_A = 1 + gamma2 * (A(3) - B(5)) / 100;
    tactica3_A = 1 + gamma3 * (A(8) - B(6)) / 100;

    tactica1_B = 1 + gamma1 * (B(6) - A(7)) / 100;
    tactica2_B = 1 + gamma2 * (B(3) - A(5)) / 100;
    tactica3_B = 1 + gamma3 * (B(8) - A(6)) / 100;

    tactica_A = tactica1_A * tactica2_A * tactica3_A;
    tactica_B = tactica1_B * tactica2_B * tactica3_B;

    % === §5.9 Ataque relativo ===
    ataque_relativo_A = (ataque_A * factor_moral_A * factor_tecnico_A * factor_cansancio_A * tactica_A) ...
                        / (defensa_B * factor_tecnico_B);
    ataque_relativo_B = (ataque_B * factor_moral_B * factor_tecnico_B * factor_cansancio_B * tactica_B) ...
                        / (defensa_A * factor_tecnico_A);

    % === §5.10 Ocasiones totales en el partido ===
    aleatorio        = rand();
    ocasiones_total  = 12 * (0.75 + 0.5 * aleatorio);
    ocasiones_A      = ocasiones_total * posesion_A;
    ocasiones_B      = ocasiones_total * posesion_B;

    % === §5.11 Probabilidad de ocasión clara ===
    prob_clara_A = ataque_relativo_A / (ataque_relativo_A + ataque_relativo_B);
    prob_clara_B = 1 - prob_clara_A;

    % === §5.12 Ocasiones claras (Binomial) ===
    num_A    = floor(ocasiones_A);
    num_B    = floor(ocasiones_B);
    claras_A = binomialAleatoria(num_A, prob_clara_A);
    claras_B = binomialAleatoria(num_B, prob_clara_B);

    % === §5.13 Probabilidad de gol ===
    % EF es la palanca principal aquí (sensibilidad +11.2%)
    prob_gol_A = 0.15 + 0.20*(A(9)/10) + 0.10*(ataque_relativo_A/defensa_B) + 0.05*posesion_A;
    prob_gol_B = 0.15 + 0.20*(B(9)/10) + 0.10*(ataque_relativo_B/defensa_A) + 0.05*posesion_B;

    prob_gol_A = min(max(prob_gol_A, 0), 0.9);
    prob_gol_B = min(max(prob_gol_B, 0), 0.9);

    % === §5.14 Goles finales (Binomial) ===
    golesA = binomialAleatoria(claras_A, prob_gol_A);
    golesB = binomialAleatoria(claras_B, prob_gol_B);
end

function resultado = binomialAleatoria(n, p)
% Genera una variable aleatoria Binomial sin necesitar el Statistics Toolbox
    if n <= 0 || p <= 0
        resultado = 0;
    elseif p >= 1
        resultado = n;
    else
        resultado = sum(rand(1, n) < p);
    end
end
