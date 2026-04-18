# Liga IO 2026 — Equipo: Interóptimo de Lagrange

Proyecto de Investigación Operativa (Universidad Rey Juan Carlos, Prof. Dr. Javier Quintero).
**Entrega**: 27 de abril de 2026. **Grupo de 4 personas**.

## Qué es este repo

Diseñamos un vector de 10 enteros positivos con suma ∈ [95, 100] que representa un equipo de fútbol. El profesor simula partidos con su script ofuscado `playMatch.p` contra los equipos de los otros grupos (y contra su "All-Stars"). Nuestro objetivo: maximizar la tasa de victoria esperada.

## Índice de documentos (léelos en este orden)

| # | Documento | Para qué sirve |
|:--|-----------|----------------|
| 0 | **[EMPEZAR_AQUI.md](EMPEZAR_AQUI.md)** | **Primera lectura del equipo**. Explicado en modo niño, paso a paso por rol. Sin tecnicismos |
| 1 | [CLAUDE.md](CLAUDE.md) | Instrucciones para Claude + "modo niño" + 13 lecciones aprendidas + pipeline |
| 2 | [GUIA_EQUIPO.md](GUIA_EQUIPO.md) | Plan diario detallado para las 4 personas hasta el 27 de abril |
| 3 | [RESULTADOS_DIA1.md](RESULTADOS_DIA1.md) | Tabla de progreso, ranking de sensibilidad, tareas concretas |
| 4 | [TRAMPAS_DETECTADAS.md](TRAMPAS_DETECTADAS.md) | Auditoría forense del PDF: 10 riesgos con corrección |
| 5 | [AUDITORIA_HONESTA.md](AUDITORIA_HONESTA.md) | Qué sé vs qué supongo vs qué ignoro, debilidades D1-D7 |

## Carpeta de código — [PROYECTO/](PROYECTO/)

| Archivo | Rol |
|---------|-----|
| [PROYECTO/main.m](PROYECTO/main.m) | Pipeline orquestado (generar → GA → SA → eval → guardar) |
| [PROYECTO/playMatch.p](PROYECTO/playMatch.p) | Simulador **oficial del profesor** (ofuscado, read-only). Es la verdad que usa para calificar |
| [PROYECTO/playMatchOpen.m](PROYECTO/playMatchOpen.m) | Reimplementación abierta de las fórmulas §5 del PDF. Sobre esta optimizamos |
| [PROYECTO/evaluateTeam.m](PROYECTO/evaluateTeam.m) | Monte Carlo de un equipo contra rivales aleatorios |
| [PROYECTO/sensitivityAnalysis.m](PROYECTO/sensitivityAnalysis.m) | Ranking de parámetros por Δwin-rate ±5 |
| [PROYECTO/crashingBaseline.m](PROYECTO/crashingBaseline.m) | Baseline ILP tipo Crashing resuelto por greedy óptimo |
| [PROYECTO/geneticAlgorithm.m](PROYECTO/geneticAlgorithm.m) | GA con elitismo, cruce uniforme y 3 mutaciones |
| [PROYECTO/simulatedAnnealing.m](PROYECTO/simulatedAnnealing.m) | SA con cooling geométrico para refinar el GA |
| [PROYECTO/generateFinalTeams.m](PROYECTO/generateFinalTeams.m) | Produce `01.mat` y `02.mat` con dos semillas distintas |
| [PROYECTO/validateTeam.m](PROYECTO/validateTeam.m) | Validación de las reglas de entrega. Enforce `min(A) >= 1` |
| [PROYECTO/createTeamFile.m](PROYECTO/createTeamFile.m) | Guarda un vector como `.mat` con round-trip check |
| [PROYECTO/lector.m](PROYECTO/lector.m) | Lector del profesor (cortesía, read-only) |

## Documentos fuente del profesor (no modificar)

| Archivo | Contenido |
|---------|-----------|
| [PROYECTO/Proyecto_Liga_IO_2026.pdf](PROYECTO/Proyecto_Liga_IO_2026.pdf) | Enunciado oficial (fuente de verdad sobre reglas) |
| [PROYECTO/Proyecto_Liga_IO_2026.txt](PROYECTO/Proyecto_Liga_IO_2026.txt) | Extracción de texto del PDF |
| [PROYECTO/ESPECIFICACIONES.md](PROYECTO/ESPECIFICACIONES.md) | Transcripción oral de la clase (informal, a veces ambigua) |
| [PROYECTO/JAVIER QUINTERO.md](PROYECTO/JAVIER%20QUINTERO.md) | Perfil académico del profesor (para la defensa y nombre/logo) |
| [PROYECTO/TEMARIO- PARCIAL 1.txt](PROYECTO/TEMARIO-%20PARCIAL%201.txt) | Temario P1 (Simplex, PE, PNL, colas) |
| [PROYECTO/TEMARIO- PARCIAL 2.txt](PROYECTO/TEMARIO-%20PARCIAL%202.txt) | Temario P2 (Crashing, KKT, Markov, simulación) |

## Estado actual (2026-04-18, fin día 1)

- Baseline sólido: **57.6% win-rate** contra rivales aleatorios (GA + SA sobre `playMatchOpen.m`).
- Nombre **Interóptimo de Lagrange** + logo profesional LISTOS.
- 10 trampas del PDF detectadas y corregidas.
- `validateTeam` + reparadores GA/SA forzando `min(A) >= 1`.
- Pipeline defendible: Sensibilidad → Crashing → GA → SA → Monte Carlo.

## Estado pendiente (próximos 9 días)

Ver [AUDITORIA_HONESTA.md](AUDITORIA_HONESTA.md) y [GUIA_EQUIPO.md](GUIA_EQUIPO.md) para el detalle.
Resumen: calibrar `playMatchOpen` vs `playMatch.p` oficial (cuando el profe lo suba), GA largo overnight, defensa de 5 min ensayada.

## Cómo usar este repo si te incorporas nuevo

1. Lee [CLAUDE.md](CLAUDE.md) sección "MODO NIÑO" (5 min).
2. Mira la tabla de progreso en [RESULTADOS_DIA1.md](RESULTADOS_DIA1.md).
3. Mira tu rol en [GUIA_EQUIPO.md](GUIA_EQUIPO.md) (Analista / Optimizador / Validador / Defensor).
4. Ejecuta en MATLAB:
   ```matlab
   cd('c:\Users\angee\Downloads\IO - PREPARACION MAYO\PROYECTO LIGA IO\liga-io\PROYECTO')
   load('pipeline_v2.mat','gaTeam'); disp(gaTeam)   % el mejor vector actual
   [ok, msg] = validateTeam(gaTeam); disp(ok)
   ```
