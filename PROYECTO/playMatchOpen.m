function [GA, GB] = playMatchOpen(A, B)
% PLAYMATCHOPEN - Open reimplementation of playMatch.p
% Simulates a match between teams A and B using the documented formulas.
%
% Inputs:
%   A - 1x10 vector (integers >= 0, sum between 95 and 100)
%   B - 1x10 vector (integers >= 0, sum between 95 and 100)
%
% Outputs:
%   GA - Goals scored by team A
%   GB - Goals scored by team B
%
% Parameters: A(1)=FI, A(2)=GO, A(3)=JD, A(4)=MA, A(5)=OR,
%             A(6)=PR, A(7)=PO, A(8)=TR, A(9)=EF, A(10)=TE

    % === 5.1 Global parameters ===
    gamma1 = 0.4;
    gamma2 = 0.4;
    gamma3 = 0.4;
    alpha  = 0.5;
    beta   = 0.5;
    sigma_moral = 1.5;

    % === 5.2 Moral ===
    sigma_A = (1/10) * sum(abs(A - 10));
    sigma_B = (1/10) * sum(abs(B - 10));

    eps_A = randn();
    eps_B = randn();

    MO_A = 10 - alpha*sigma_A + beta*(A(10)/10) ...
         + sigma_moral * max(1, 100 - sum(A)) * eps_A;
    MO_B = 10 - alpha*sigma_B + beta*(B(10)/10) ...
         + sigma_moral * max(1, 100 - sum(B)) * eps_B;

    MO_A = max(0, MO_A);
    MO_B = max(0, MO_B);

    % === 5.3 Fatigue ===
    CA = max(0, (0.4*A(6) + 0.3*A(7) + 0.3*A(8) - 0.5*A(3)) ...
         / 10 * (1 - MO_A/12));
    CB = max(0, (0.4*B(6) + 0.3*B(7) + 0.3*B(8) - 0.5*B(3)) ...
         / 10 * (1 - MO_B/12));

    % === 5.4 Base parameters ===
    AT_A = max(0.01, 0.35*A(1) + 0.35*A(2) + 0.3*A(3));
    AT_B = max(0.01, 0.35*B(1) + 0.35*B(2) + 0.3*B(3));

    DF_A = max(0.05, 0.4*A(4) + 0.4*A(5) + 0.2*A(6));
    DF_B = max(0.05, 0.4*B(4) + 0.4*B(5) + 0.2*B(6));

    CT_A = max(0.01, 0.4*A(7) + 0.4*A(8) + 0.2*A(9));
    CT_B = max(0.01, 0.4*B(7) + 0.4*B(8) + 0.2*B(9));

    % === 5.5 Factors ===
    F_mor_A = 0.85 + MO_A / 20;
    F_mor_B = 0.85 + MO_B / 20;

    F_tec_A = 0.9 + A(10) / 50;
    F_tec_B = 0.9 + B(10) / 50;

    F_fat_A = max(0.1, 1 - 0.6*CA);
    F_fat_B = max(0.1, 1 - 0.6*CB);

    % === 5.6 Effective control ===
    CT_eff_A = CT_A * F_mor_A * F_tec_A * F_fat_A;
    CT_eff_B = CT_B * F_mor_B * F_tec_B * F_fat_B;

    % === 5.7 Possession ===
    Pos_A = CT_eff_A / (CT_eff_A + CT_eff_B);
    Pos_B = 1 - Pos_A;

    % === 5.8 Tactical interaction ===
    T1_A = 1 + gamma1 * (A(6) - B(7)) / 100;
    T2_A = 1 + gamma2 * (A(3) - B(5)) / 100;
    T3_A = 1 + gamma3 * (A(8) - B(6)) / 100;

    T1_B = 1 + gamma1 * (B(6) - A(7)) / 100;
    T2_B = 1 + gamma2 * (B(3) - A(5)) / 100;
    T3_B = 1 + gamma3 * (B(8) - A(6)) / 100;

    T_A = T1_A * T2_A * T3_A;
    T_B = T1_B * T2_B * T3_B;

    % === 5.9 Relative attack ===
    AT_rel_A = (AT_A * F_mor_A * F_tec_A * F_fat_A * T_A) / (DF_B * F_tec_B);
    AT_rel_B = (AT_B * F_mor_B * F_tec_B * F_fat_B * T_B) / (DF_A * F_tec_A);

    % === 5.10 Occasions ===
    U = rand();
    O_tot = 12 * (0.75 + 0.5 * U);
    O_A = O_tot * Pos_A;
    O_B = O_tot * Pos_B;

    % === 5.11 Clear occasion probability ===
    P_d_A = AT_rel_A / (AT_rel_A + AT_rel_B);
    P_d_B = 1 - P_d_A;

    % === 5.12 Clear occasions (Binomial) ===
    n_A = floor(O_A);
    n_B = floor(O_B);
    OC_A = myBinornd(n_A, P_d_A);
    OC_B = myBinornd(n_B, P_d_B);

    % === 5.13 Goal probability ===
    P_g_A = 0.15 + 0.20*(A(9)/10) + 0.10*(AT_rel_A/DF_B) + 0.05*Pos_A;
    P_g_B = 0.15 + 0.20*(B(9)/10) + 0.10*(AT_rel_B/DF_A) + 0.05*Pos_B;

    P_g_A = min(max(P_g_A, 0), 0.9);
    P_g_B = min(max(P_g_B, 0), 0.9);

    % === 5.14 Goals (Binomial) ===
    GA = myBinornd(OC_A, P_g_A);
    GB = myBinornd(OC_B, P_g_B);
end

function r = myBinornd(n, p)
% Binomial random variable without Statistics Toolbox
    if n <= 0 || p <= 0
        r = 0;
    elseif p >= 1
        r = n;
    else
        r = sum(rand(1, n) < p);
    end
end
