> **⚠️ DOCUMENTO HISTÓRICO — SUPERADO**
> El documento de referencia oficial es **[VECTOR_FINAL_AUDIT_CERRADO.md](VECTOR_FINAL_AUDIT_CERRADO.md)**.
> Este archivo se mantiene solo como histórico de la auditoría inicial.

# VECTOR_FINAL_AUDIT — Liga IO 2026 · Interóptimo de Lagrange

**Fecha:** 2026-04-26
**Engine:** `playMatch.p` oficial (con shim casero `binornd.m` porque MATLAB R2024b del equipo no tiene Statistics Toolbox)
**Seed:** 2026

---

## 1. Vectores finales

| Slot | Vector                              | Suma | min | FI+EF+TE |
|------|-------------------------------------|------|-----|----------|
| 01   | `[6  9  9 11 10  1  6  6 24 18]`    | 100  |  1  | 48       |
| 02   | `[8  7  9 10 11  1  2  6 29 17]`    | 100  |  1  | 54       |

Ambos cumplen las reglas duras del PDF §4.1 (10 enteros, todos ≥1, suma en [95,100]).

Lectura compatible con `lector.m` confirmada en carpeta limpia `ENTREGA_FINAL/` y `playMatch(vector, [10 10 …])` ejecuta sin error.

---

## 2. Por qué EF y TE pesan

Sensibilidades locales (Día 1, Monte Carlo 100×20 sobre `playMatchOpen`):
EF = +11.2 %, TE = +7.3 %, JD = +2.1 %, PO = +1.1 %, OR ≈ 0.
PR = -7.6 %, GO = -7.4 %, FI = -4.1 % (en liga; FI suma en copa).

En las ecuaciones del PDF §5:
- **EF (índice 9)** entra directamente en `prob_gol = 0.15 + 0.20·(EF/10) + …`
- **TE (índice 10)** es multiplicador global vía `factor_tecnico = 0.9 + TE/50`, afectando control efectivo, ataque relativo y posesión.

Por eso ambos vectores cargan EF (24, 29) y TE (17, 18) por encima de la media.
Mantenemos PR=1, mínimo legal — el PDF prohíbe ceros.

---

## 3. Resultados oficiales (engine = playMatch.p, 1000 rivales × 50 partidos)

| Vector                              | Pts/p   | Vic    | Emp    | Der    | GF    | GC    | DG     |
|-------------------------------------|---------|--------|--------|--------|-------|-------|--------|
| 01 = [6 9 9 11 10 1 6 6 24 18]      | 1.9667  | 58.1%  | 22.3%  | 19.6%  | 1.995 | 1.161 | +0.835 |
| 02 = [8 7 9 10 11 1 2 6 29 17]      | 1.9825  | 58.9%  | 21.5%  | 19.6%  | 2.114 | 1.256 | +0.858 |

Pts/p = (3·V + 1·E) / total partidos.
Diferencia de goles (DG) es desempate en liga.

---

## 4. Mini-liga top-10 (round-robin, 1000 partidos por cruce)

| Pos | Vector                              | Puntos | DG     | GF     |
|-----|-------------------------------------|--------|--------|--------|
| 1   | `[6 9 9 11 10 1 6 6 24 18]` ← 01    | 13462  | +1525  | 18762  |
| 2   | `[5 8 9 9 13 1 3 9 28 15]`          | 13423  | +1340  | 19489  |
| 3   | `[8 7 9 10 11 1 2 6 29 17]` ← 02    | 13411  | +1236  | 19662  |
| 4   | `[6 7 10 10 11 1 7 7 26 15]`        | 13312  | +1308  | 18974  |
| 5   | `[4 13 8 11 10 1 4 6 24 19]`        | 13070  | +667   | 18268  |
| 6   | `[12 9 6 10 11 1 3 5 28 15]`        | 12889  | +699   | 19217  |
| 7   | `[11 5 9 13 5 1 7 1 30 18]`         | 12182  | -620   | 18977  |
| 8   | `[3 3 15 3 15 3 15 3 20 20]`        | 11296  | -1618  | 15924  |
| 9   | `[9 10 11 10 13 5 7 8 15 11]`       | 10674  | -2525  | 14225  |
| 10  | `[14 6 12 8 10 6 7 8 14 15]`        | 10432  | -2646  | 14087  |

Top 4 en pañuelo (≤150 pts entre 1.º y 4.º sobre 13.500). Empate técnico entre los 4 mejores.

---

## 5. Justificación de la elección 01 / 02

**01 = [6 9 9 11 10 1 6 6 24 18]** — campeón de mini-liga con DG dominante (+1525). Reparto equilibrado (sigma=4.0 sobre la media 10), no extremo, robusto frente a rivales fuertes.

**02 = [8 7 9 10 11 1 2 6 29 17]** — elegido por el filtro de **perfil Copa** (FI+EF+TE = 54, máximo del top-10). 3.º en mini-liga (51 pts por debajo del 1.º, ~0.4 %): no es un sacrificio en liga. Mayor GF/partido (2.114 vs 1.995) y EF más alto (29 vs 24) — favorable para tandas de penaltis donde el PDF §2 dice que cuentan "técnico, finalización, moral, menor cansancio".

El 2.º clasificado en mini-liga `[5 8 9 9 13 1 3 9 28 15]` se descartó porque su FI+EF+TE = 48 (igual que 01) — habrían sido demasiado parecidos.

---

## 6. Comparación contra candidatos anteriores

| Candidato                          | Pts/p   | Vs 01      |
|------------------------------------|---------|------------|
| `[10 10 10 …]` balanceado          | 1.528   | -22%       |
| `[3 3 15 3 15 3 15 3 20 20]`       | 1.762   | -10%       |
| `[14 6 12 8 10 6 7 8 14 15]`       | 1.700   | -14%       |
| `[6 9 9 11 10 1 6 6 24 18]` (01)   | 1.967   | baseline   |
| `[8 7 9 10 11 1 2 6 29 17]` (02)   | 1.983   | +0.8 %     |

01 y 02 quedan claramente en el clúster de cabeza. El team balanceado clásico pierde por 22 %.

---

## 7. Riesgo residual

| ID | Riesgo | Mitigación |
|----|--------|------------|
| R1 | El `playMatch.p` que tenemos viene de Ivan, no del profe oficial | Misma versión usada para todo el tuning. Confirmar con Quintero que el .p del Aula Virtual coincide con el de Ivan. |
| R2 | Falta Statistics Toolbox → usamos `binornd.m` casero | El shim implementa Bernoulli sumadas (`sum(rand(1,n)<p)`), idéntico a lo que el toolbox haría. Validado: `playMatch` ejecuta sin error. |
| R3 | Sensibilidades **locales** alrededor de [10..10], no de [29 EF, 18 TE] | Mini-liga round-robin entre top-10 confirma el ranking en el régimen real, no en linealización. |
| R4 | Empate estadístico top-4 en mini-liga | DG (+1525) y posición sólida en quick-eval rompen el empate a favor de 01. |
| R5 | El All-Stars del profe es desconocido | No optamos por enfrentarlo (riesgo binario: -0 si pierdes). |
| R6 | Asistencia 27 y 29 obligatoria para cobrar premios | Confirmar con los 4 miembros. |

---

## 8. Instrucciones exactas de entrega

```matlab
%% Cuando el profe asigne los seriales (ej. '07' y '08'):
addpath('PROYECTO');
addpath('Pruebas_Ivan');                 % para playMatch.p y binornd.m
load('ENTREGA_FINAL\01.mat');  v01 = equipo;
load('ENTREGA_FINAL\02.mat');  v02 = equipo;

%% Renombrar con el serial REAL en una carpeta limpia separada:
mkdir('SUBIDA');
cd('SUBIDA');
createTeamFile(v01, '07');               % crea 07.mat
createTeamFile(v02, '08');               % crea 08.mat (opcional)

%% Dry-run obligatorio antes de subir:
[teams, names] = lector();               % debe imprimir 2 vectores 1x10
[g1, g2] = playMatch(v01, 10*ones(1,10)); fprintf('test 01: %d-%d\n', g1, g2);
[g1, g2] = playMatch(v02, 10*ones(1,10)); fprintf('test 02: %d-%d\n', g1, g2);
```

**Reglas que NO se rompen:**
- Solo el archivo `XY.mat` se sube al Aula Virtual.
- No se entrega código, ni PDF, ni informe.
- Una única subida por el responsable designado.
- Los 4 miembros presentes el 27 y el 29.

---

## 9. Archivos generados por la auditoría

| Archivo                               | Contenido                            |
|---------------------------------------|--------------------------------------|
| `ENTREGA_FINAL/01.mat`                | Vector 1 (campeón mini-liga)         |
| `ENTREGA_FINAL/02.mat`                | Vector 2 (perfil Copa, top-3 liga)   |
| `RESULTADOS_CANDIDATOS_OFICIAL.md`    | Tabla 16 candidatos, quick eval 200×30 |
| `RESULTADOS_TOP10_OFICIAL.md`         | Top-10 robusto 1000×50               |
| `RESULTADOS_MINILIGA_TOP10.md`        | Round-robin 1000 partidos por cruce  |
| `top10_oficial.mat`                   | Top-10 + métricas para reproducir    |
| `auditoria_resumen.mat`               | Estructura `resumen` con todo        |
| `PROYECTO/auditoriaFinal.m`           | Pipeline reproducible                |
| `PROYECTO/evaluateTeamOfficial.m`     | Evaluador con engine='official'/'open' |
| `PROYECTO/binornd.m`                  | Shim para playMatch.p sin toolbox    |

Para regenerar todo:
```matlab
addpath('PROYECTO'); addpath('Pruebas_Ivan');
opt.rivalesQuick=200; opt.partidosQuick=30;
opt.rivalesTop10=1000; opt.partidosTop10=50;
opt.partidosLiga=1000; opt.engine='official'; opt.seed=2026;
resumen = auditoriaFinal(opt);
```

Tiempo total medido en la máquina del equipo: **12 segundos** (Pipeline completo, engine oficial).
