# RESULTADOS — Día 1 (2026-04-18) · v3

**Equipo**: Interóptimo de Lagrange ✅. Logo profesional ✅.

Progreso de Claude en sesión inicial. Material listo para que el equipo arranque el domingo.
**v2**: auditoría forense del PDF (ver [TRAMPAS_DETECTADAS.md](TRAMPAS_DETECTADAS.md)) y re-ejecución con `min(A) >= 1` forzado.
**v3**: auditoría honesta crítica (ver [AUDITORIA_HONESTA.md](AUDITORIA_HONESTA.md)) con 7 debilidades reconocidas y nombre de equipo fijado.

## Tabla de progreso actualizada

| Estrategia | Vector | Suma | min | Win-rate (300×50) | GF | GA |
|------------|--------|:---:|:---:|:---:|:---:|:---:|
| Balanced `[10..10]` | `10 10 10 10 10 10 10 10 10 10` | 100 | 10 | 39.6% | 1.16 | 0.98 |
| Crashing linear **puro** (sin cotas) | `0 0 30 0 0 0 10 0 30 30` | 100 | 0 | 0.0% ❌ | 0.04 | 4.31 |
| Crashing con cotas (min=3) | `3 3 15 3 15 3 15 3 20 20` | 100 | 3 | **50.1%** ✅ | 1.56 | 1.03 |
| **GA (min>=1 enforced)** | `6 9 9 11 10 1 6 6 24 18` | 100 | **1** | **57.6%** 🚀 | 1.83 | 1.04 |
| SA refinement | `4 13 8 11 10 1 4 6 24 19` | 100 | 1 | 56.3% | 1.82 | 1.08 |

**Mejor actual**: `[6 9 9 11 10 1 6 6 24 18]` — 57.6%. Guardado en [PROYECTO/pipeline_v2.mat](PROYECTO/pipeline_v2.mat).

## Ranking de sensibilidad

Guardado en [PROYECTO/sensitivity_baseline.mat](PROYECTO/sensitivity_baseline.mat).

| # | Parámetro | δ (Δwin-rate ±5) | Interpretación |
|---|-----------|:----------------:|----------------|
| 1 | **Eficacia (EF)** | **+11.2%** | 🔥 Palanca principal. Entra directo en `P_g`. |
| 2 | **Técnico (TE)** | **+7.3%** | 🔥 Multiplicador global `F_tec`. |
| 3 | Juego Directo (JD) | +2.6% | Ataque + rompe presión. |
| 4 | Posesión (PO) | +1.7% | Efecto moderado. |
| 5 | Org. Def. (OR) | +0.7% | Casi neutro. |
| 6 | Transición (TR) | -1.4% | Perjudica levemente. |
| 7 | Marcaje (MA) | -2.1% | Perjudica. |
| 8 | Finalización (FI) | -4.1% | ❗ Aumenta σ, baja moral. |
| 9 | Gen. Ofensiva (GO) | -7.4% | ❗ Similar a FI. |
| 10 | Presión (PR) | -7.6% | ❗ Sube cansancio, baja `F_fat`. |

## 🚨 Trampas detectadas en PDF oficial (ver [TRAMPAS_DETECTADAS.md](TRAMPAS_DETECTADAS.md))

1. **"Entradas enteras positivas"** → `min(A) >= 1`. NO PUEDE haber ceros. Todo el código parcheado.
2. **Penaltis copa** usan TE+FI+moral+(1/cansancio). Si llegamos a penaltis, necesitamos FI alto (contraintuitivo vs liga).
3. **Liga premia** más goles a favor (+0.5) y menos recibidos (+0.5). Oportunidad de diseñar `02.mat` hiper-ofensivo.
4. **N ligas desconocido** pero grande (dicho "1000M instancias"). Varianza se promedia → fijar `sum = 100`.
5. **Penalizaciones "Atleti"/"Florentino"** mencionadas pero NO aparecen en fórmulas abiertas — validar con `playMatch.p` oficial obligatorio.
6. **Errores de formato = descalificación automática**. Checklist pre-entrega en TRAMPAS_DETECTADAS.md.
7. **Solo cuenta el MEJOR de los 2 equipos en liga**, pero ambos compiten en copa → diseñar complementarios.
8. **Asistencia obligatoria** 27 y 29 de abril para cobrar premios.

## Parches aplicados hoy

| Archivo | Cambio | Motivo |
|---------|--------|--------|
| [PROYECTO/validateTeam.m](PROYECTO/validateTeam.m) | `A < 0` → `A < 1` | PDF dice "positivas" estricto |
| [PROYECTO/geneticAlgorithm.m](PROYECTO/geneticAlgorithm.m) | `repairBudget`, mutate, crossover: `max(...,0)` → `max(...,1)` | Evitar ceros |
| [PROYECTO/simulatedAnnealing.m](PROYECTO/simulatedAnnealing.m) | neighbor: `randi([0,30])` → `randi([1,30])`; `repairBudget` con piso 1 | Evitar ceros |
| [PROYECTO/crashingBaseline.m](PROYECTO/crashingBaseline.m) | Reducción en fallback: `team(i) > 1` | Evitar ceros |
| [PROYECTO/generateFinalTeams.m](PROYECTO/generateFinalTeams.m) | **Nuevo** | Genera `01` y `02` con dos semillas GA distintas |

## Qué está hecho (cierre día 1)

- [x] Permisos de sesión: [.claude/settings.local.json](.claude/settings.local.json)
- [x] Instrucciones Claude actualizadas: [CLAUDE.md](CLAUDE.md) (modo niño + 13 lecciones)
- [x] Plan para el equipo: [GUIA_EQUIPO.md](GUIA_EQUIPO.md) (roles + calendario)
- [x] Auditoría del PDF: [TRAMPAS_DETECTADAS.md](TRAMPAS_DETECTADAS.md)
- [x] Sensibilidad ejecutada y guardada
- [x] Crashing greedy baseline implementado (50.1% win)
- [x] GA + SA con `min>=1` enforced (57.6% win)
- [x] Experimento con equipos copa-manual (46% max; EF+TE sigue siendo dominante)
- [x] Script de generación final [generateFinalTeams.m](PROYECTO/generateFinalTeams.m)

## Qué toca el equipo (domingo, día 2)

**Todos (30 min)**: leer CLAUDE.md, GUIA_EQUIPO.md y TRAMPAS_DETECTADAS.md. Asignar roles.

### Analista — 1h
Entender POR QUÉ la sensibilidad sale así. Abrir MATLAB:
```matlab
cd('c:\Users\angee\Downloads\IO - PREPARACION MAYO\PROYECTO LIGA IO\liga-io\PROYECTO')
load('sensitivity_baseline.mat')
disp(results)
```
Escribir medio folio explicando:
- Por qué EF domina (aparece en `P_g = 0.15 + 0.20·(A(9)/10) + ...`).
- Por qué TE domina (multiplica en `F_tec = 0.9 + A(10)/50` todo).
- Por qué PR, GO, FI tienen delta negativo (aumentan σ de moral + cansancio).
- Va directo a la slide 3.

### Optimizador — 30 min
Ejecutar el pipeline largo final:
```matlab
cd('c:\Users\angee\Downloads\IO - PREPARACION MAYO\PROYECTO LIGA IO\liga-io\PROYECTO')
[team01, team02, stats] = generateFinalTeams('', '', false);   % sin serial, solo calcular
```
Tarda ~5-10 min. Guarda los vectores finales. Compartirlos en el chat del grupo.

### Validador — 1h
Cuando el profe habilite `playMatch.p` (desde mañana):
```matlab
cd('c:\Users\angee\Downloads\IO - PREPARACION MAYO\PROYECTO LIGA IO\liga-io\PROYECTO')
load('pipeline_v2.mat','gaTeam');
rng(0);
N=1000; g1=zeros(N,2); g2=zeros(N,2);
rival = [10 10 10 10 10 10 10 10 10 10];
for k=1:N, [g1(k,1),g1(k,2)] = playMatch(gaTeam, rival); end
rng(0);
for k=1:N, [g2(k,1),g2(k,2)] = playMatchOpen(gaTeam, rival); end
fprintf('Oficial: GF=%.3f GA=%.3f WR=%.2f%%\n', mean(g1(:,1)), mean(g1(:,2)), 100*mean(g1(:,1)>g1(:,2)));
fprintf('Abierto: GF=%.3f GA=%.3f WR=%.2f%%\n', mean(g2(:,1)), mean(g2(:,2)), 100*mean(g2(:,1)>g2(:,2)));
```
Si difieren > 5 puntos porcentuales en WR, ALERTA.

Sanity del `.mat`:
```matlab
load('pipeline_v2.mat','gaTeam');
createTeamFile(gaTeam, '99');    % serial de prueba, NO el real
[teams, names] = lector();
disp(teams); disp(names);
delete('99.mat');
```

### Defensor — 1h
Leer [PROYECTO/JAVIER QUINTERO.md](PROYECTO/JAVIER%20QUINTERO.md) y [TRAMPAS_DETECTADAS.md](TRAMPAS_DETECTADAS.md) sección final (ideas de nombre).

**Propuestas para votar en el grupo** (todas ligadas al profe):
- **Sobolev FC** (su tesis)
- **Cabilla FC** (su nick Godot)
- **Ortogonales CF**
- **Real Godot Deportivo**
- **La Habana 2016 CF** (año licenciatura)

Crear `DEFENSA_BORRADOR.md` en la raíz con 4 slides:
1. **Portada**: nombre + logo + escudo grupo.
2. **Problema**: "10 enteros positivos, Σ=95-100, objetivo estocástico no lineal no diferenciable. Espacio ~10¹²."
3. **Método**:
   - Sensibilidad numérica (tema 6 PNL).
   - Crashing linealizado (tema P2 diap 155) → baseline 50.1%.
   - GA + SA + Monte Carlo (justificado porque no hay gradiente) → 57.6%.
   - Validación cruzada con `playMatch.p` oficial.
4. **Resultado**: vector final + win-rate + insight contraintuitivo ("subir presión empeora, porque sube cansancio").

## Preguntas al profe (miércoles 22 abr)

1. *"¿Los ceros están permitidos técnicamente? El PDF dice 'positivas' pero el simulador abierto tolera ceros."* (Si dice "sí", podemos aflojar el piso y ganar algo más.)
2. *"¿Cuál es N (el número de ligas) aproximado? Eso nos cambia la estrategia de varianza."*
3. *"¿Podemos usar metaheurísticas (GA/SA) en la defensa, o prefiere que justifiquemos solo con Crashing y Monte Carlo del temario?"*
4. *"¿La copa usa el mismo `playMatch.p` o una variante?"*

## 🔴 Debilidades reconocidas (ver [AUDITORIA_HONESTA.md](AUDITORIA_HONESTA.md))

Este trabajo **NO garantiza un 9+**. Lo que falta, con responsable:

| # | Debilidad | Responsable | Día |
|---|-----------|-------------|----:|
| D1 | Todo tuneado contra `playMatchOpen`, no el oficial `playMatch.p` | Validador | 20/04 |
| D2 | GA/SA ligero — falta pasada larga overnight (popSize=300, gen=300) | Optimizador | 21/04 |
| D3 | Sensibilidad solo local a `[10..10]` — recalcular alrededor del GA actual | Analista | 21/04 |
| D4 | `playMatchOpen.m` no auditado línea a línea contra PDF §5 | Analista | 20/04 |
| D5 | 57.6% es vs rivales aleatorios — vs optimizados será más bajo | Optimizador | 23/04 |
| D6 | Flujo end-to-end `.mat` → `lector` → `playMatch` sin probar | Validador | 20/04 |
| D7 | Defensa oral aún no estructurada | Defensor | 23-24/04 |

**Veredicto honesto con lo que tenemos hoy**: ~6.5-7.5/10. Para el 9+ hay que cerrar las 7 debilidades.

## Comandos de emergencia

```matlab
% Recuperar el mejor vector actual
load('pipeline_v2.mat','gaTeam'); disp(gaTeam)

% Validar antes de submit
[ok, msg] = validateTeam(gaTeam); disp(ok); disp(msg)

% Regenerar todo
[team01, team02, stats] = generateFinalTeams();

% Ranking sensibilidad
load('sensitivity_baseline.mat'); disp(100*results.deltas)

% Limpiar y empezar de cero
clear all; clc; rehash;
```
