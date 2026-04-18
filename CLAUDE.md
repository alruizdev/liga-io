# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

---

## MODO NIÑO — ¿Qué es este proyecto? (léelo primero)

Es un **videojuego de fútbol hecho con matemáticas**.

- Cada grupo inventa un equipo. Un equipo es **una lista de 10 números** (nada de jugadores individuales, solo stats). Ejemplo: `[9 4 10 10 12 0 11 0 27 17]`.
- Esos 10 números son cosas como "Finalización", "Posesión", "Moral del técnico", etc.
- Tenemos un **presupuesto de 100 puntos** para repartir entre los 10 números. Podemos gastar entre **95 y 100** (si gastas menos de 100 hay una pequeña ventaja — pero también añade ruido).
- El profesor mete tu equipo contra los equipos de todos los demás grupos (y contra el suyo, el "All Stars"). Usa una función llamada `playMatch.p` que simula partidos con dados (no es determinista: jugar 2 veces da resultados distintos).
- El profesor corre la liga **muchísimas veces** (habla de "1000 millones de instancias") para que el resultado sea robusto estadísticamente.
- Entregamos **un archivo `.mat`** (formato MATLAB) con la lista de 10 números dentro, con el nombre `XX.mat` donde XX es el serial que nos asigna el profe.

**Nuestro objetivo real**: encontrar los 10 números mágicos que hacen que ganemos más partidos que los demás.

**Qué PUNTÚA (hasta 10)**:
- Presentar equipo válido → 5 puntos gratis
- Ganar la liga → +2 (proporcional al puesto; media tabla +1)
- Campeón de copa → +puntos por fase
- Más goles a favor → +0.5
- Menos goles en contra → +0.5
- Ganar al equipo del profe → +1.5 (opcional, riesgoso)
- Mejor nombre → +0.5 (votación)
- Mejor logo → +0.5 (votación)
- Presentación (máx 4 slides, 5 min) → hasta +2 (depende de la metodología)

→ **Presentarse a la defensa y explicar bien cómo hemos optimizado vale el 20% de la nota total del proyecto**. No saltarla.

### Los "algoritmos" en modo niño

Imagina que tienes que encontrar la mejor combinación de ingredientes para una pizza, pero probar cada pizza cuesta tiempo (hay que cocinarla y comerla).

1. **Crashing (del temario)** — "Dime en qué ingrediente me conviene más gastar cada euro". Decides dónde invertir según rentabilidad por unidad. Lineal, clásico.
2. **Algoritmo Genético (GA)** — "Evolución". Empiezas con 100 pizzas aleatorias, las haces competir, las que ganan "tienen hijos" mezclando sus ingredientes, a veces metes mutaciones raras. Tras 100 generaciones sale la mejor pizza.
3. **Simulated Annealing (SA)** — "Bajada suave por la montaña". Coges una pizza buena, le cambias un poco un ingrediente, si mejora la tomas. Si empeora, a veces también la aceptas (al principio sí, al final casi nunca). Te quedas con la mejor que has visto.
4. **Monte Carlo** — "Juega muchas veces para fiarte del resultado". Como tu pizza no siempre sabe igual, pruebas con 500 catadores y 100 bocados cada uno.

---

## Project context

Academic Operations Research project (Prof. Javier Quintero, delivery 2026-04-27). 4-person team. Submits a 1x10 integer vector; `playMatch.p` simulates matches stochastically; grading rewards win rate and — slightly — lower budget usage.

Source code lives in [PROYECTO/](PROYECTO/). No build system; runs inside MATLAB.

## Nuestro pipeline (cómo vamos a ganar esto)

Cuatro capas. Cada una tiene justificación desde el temario del profesor — así la defensa queda blindada.

1. **Capa 1 — Análisis matemático (Tema 6 PNL + P2 KKT)**. Estudiamos `playMatchOpen.m` y demostramos que el problema es **no lineal, no diferenciable, estocástico**. Conclusión: KKT/Lagrangiano no aplican. Calculamos **sensibilidades `δᵢ`** por diferencias finitas (el "gradiente aproximado" que menciona el profe).
2. **Capa 2 — Baseline Crashing linealizado (P2 diap 155)**. Reinterpretamos el problema como Crashing: cada parámetro es una "actividad" con coste (puntos de presupuesto) y beneficio (Δwin_rate). Maximizamos `Σ δᵢ·xᵢ` sujeto a `Σxᵢ ≤ 100`, cotas por parámetro. Como es 1 sola restricción de suma con cotas → **greedy por ratio es óptimo** (no necesitamos Optimization Toolbox).
3. **Capa 3 — GA + SA + Monte Carlo**. El baseline de la capa 2 se mete como semilla en el GA. SA refina. Monte Carlo con 500×100 valida.
4. **Capa 4 — Diferenciadores**. Cadenas de Markov (posición final en liga como proceso estocástico, P2) y minimax contra All-Stars (opcional, para la copa).

## Key commands (MATLAB)

Run from `PROYECTO/`:

- Pipeline completo: abre y ejecuta [PROYECTO/main.m](PROYECTO/main.m). Edita `SERIAL_1`/`SERIAL_2`.
- Baseline Crashing: `[team, z, delta] = crashingBaseline()` — ILP linealizado por greedy óptimo (ver Capa 2).
- Evaluación puntual: `evaluateTeam(team, 500, 100)`.
- Partido único (engine abierto): `playMatchOpen(teamA, teamB)`.
- Partido único (engine oficial, ofuscado — grading): `playMatch(teamA, teamB)`.
- Validar vector: `validateTeam(team)`.
- Empaquetar entrega: `createTeamFile(team, '01')` → `01.mat`.
- Lector del profe (sanity check): `[teams, names] = lector()` en el directorio con `XX.mat`.
- Sensibilidad: `sensitivityAnalysis(baseTeam, 200, 30)`.

**Antes de subir**: (1) `validateTeam`, (2) `createTeamFile`, (3) `lector` en el mismo directorio.

## Reglas duras de entrega (incumplirlas = descalificación)

Enforced en [validateTeam.m](PROYECTO/validateTeam.m) y [createTeamFile.m](PROYECTO/createTeamFile.m):

- 10 enteros no negativos, `sum ∈ [95, 100]`.
- Archivo `XY.mat` con **solo una variable** (1x10 `double`). `lector.m` lee `fieldnames` sin nombre concreto.
- Nombre del archivo = serial asignado por el profe. Error de serial/formato = 0 puntos.
- **Una sola subida**, sin reenvíos. Solo la persona designada sube.

## Arquitectura

### Representación del equipo

Vector `double` 1x10. El **orden importa** (playMatch.p lo espera así):

| Idx | Código | Nombre           |
|-----|--------|------------------|
| 1   | FI     | Finalización     |
| 2   | GO     | Generación Of.   |
| 3   | JD     | Juego Directo    |
| 4   | MA     | Marcaje          |
| 5   | OR     | Org. Defensiva   |
| 6   | PR     | Presión          |
| 7   | PO     | Posesión         |
| 8   | TR     | Transición       |
| 9   | EF     | Eficacia         |
| 10  | TE     | Técnico          |

### playMatch.p vs playMatchOpen.m

- [playMatch.p](PROYECTO/playMatch.p): **ofuscado, oficial del profesor**, es lo que usa para calificar. Read-only.
- [playMatchOpen.m](PROYECTO/playMatchOpen.m): **reimplementación nuestra** de las fórmulas documentadas (secciones 5.1–5.14). Todo el optimizador usa esto porque podemos inspeccionarlo.
- Verificar que ambos coinciden estadísticamente es **crítico** antes de cerrar entrega.

### Pipeline de optimización (orquestado en `main.m`)

`generateTeam` → `crashingBaseline` (semilla) → `geneticAlgorithm` → `simulatedAnnealing` → `evaluateTeam` (final 500×100) → `createTeamFile`.

Las tres rutinas de reparación de presupuesto (en generateTeam, GA y SA) DEBEN mantener `sum ∈ [95, 100]` y enteros ≥ 0. Si tocas una, toca las otras.

## Toolboxes disponibles (MATLAB R2024b)

**Solo MATLAB base + Communications + DSP + Signal Processing**. NO tenemos:

- ❌ Optimization Toolbox (`intlinprog`, `linprog`, `fmincon`) → resolvemos el ILP de Crashing por **greedy analítico**.
- ❌ Global Optimization Toolbox (`ga`, `simulannealbnd`) → tenemos nuestras implementaciones manuales.
- ❌ Statistics Toolbox (`binornd`) → `playMatchOpen.m` tiene `myBinornd` casero.

Esto no es un problema: todo el pipeline está escrito desde cero sin dependencias y es MÁS defendible en la presentación (demuestras que entiendes los algoritmos).

---

## Lecciones aprendidas

- **[2026-04-18] 🚨 El PDF dice "entradas enteras positivas" → `min(A) >= 1`, NO permitimos ceros** — Contexto: PDF sección 4.1 literal. Un matemático riguroso (y Quintero es Cum Laude) interpreta positivo como `> 0`. El profe dijo en clase *"si te dan un gam, estás haciendo algo mal"* sobre los `max(0.01, ...)`. Forzado en validateTeam, GA repair, SA neighbor/repair, Crashing. Coste: 10 puntos reservados como mínimos → queda margen para optimizar. Ver [TRAMPAS_DETECTADAS.md](TRAMPAS_DETECTADAS.md).
- **[2026-04-18] El profesor es Dr. Cum Laude + Premio Extraordinario en Optimización Matemática** — Contexto: perfil en [PROYECTO/JAVIER QUINTERO.md](PROYECTO/JAVIER%20QUINTERO.md). Tesis sobre polinomios ortogonales de Sobolev y equilibrios electrostáticos (UC3M 2023). Experto REAL en optimización — detectará cualquier mal uso de técnica. Valora rigor matemático > complejidad ostentosa. Hobby: Godot Engine (nick **cabilla**, cabilla.itch.io). Origen cubano (La Habana). Defensa debe ser sólida, no pirotécnica.
- **[2026-04-18] La "ligera bonificación" por `sum<100` es SOLO varianza de moral, no bonus esperado** — Contexto: en `playMatchOpen` aparece como `σ_moral · max(1, 100-Σ) · randn()`. E[randn]=0 → en media no aporta. Con N grande (profesor dijo "1000M instancias") se promedia a cero. **Optimizar `sum = 100` exacto**.
- **[2026-04-18] Penaltis de copa favorecen TE, FI, moral alta, cansancio bajo** — Contexto: PDF sección copa literal. El segundo equipo (`02.mat`) idealmente cubre un perfil distinto al del `01` (boost en FI y moral alta vía baja σ). Validado empíricamente: equipos balanceados dan ~46%, GA tech da 57%. La estrategia dominante en **liga** sigue siendo EF+TE altos — pero `02.mat` sirve como seguro por si `playMatch.p` tiene penalización oculta contra "Florentino" (alto técnico + malo en todo).
- **[2026-04-18] El profesor permite cualquier método, dentro o fuera del temario** — Contexto: transcripción dice *"algoritmo que tenéis que investigar por vuestra cuenta"*, *"te buscas 3-4, los tiras"*. Metaheurísticas (GA/SA) son válidas y probablemente suman en la defensa. Clave: **defenderlo bien con matemáticas**.
- **[2026-04-18] NO enfrentar al All-Stars salvo >60% win-rate contra él** — Contexto: *"Si le ganas, +1.5. Si pierdes, cero en un juego."* Pérdida binaria. Default: no arriesgar.
- **[2026-04-18] Una sola subida, sin reenvíos** — Contexto: *"no me escribas diciendo que te mandé el que no era"*. Congelar 48h antes. Dry-run con `lector.m` en directorio limpio.
- **[2026-04-18] No hay Optimization Toolbox en MATLAB R2024b del equipo** — Contexto: solo Communications/DSP/Signal. Todo pipeline con MATLAB base. Crashing-ILP resuelto por greedy analítico (óptimo para 1 restricción de presupuesto con cotas).
- **[2026-04-18] `playMatch.p` es la verdad; `playMatchOpen.m` es aproximación** — Contexto: optimizar solo contra el abierto puede divergir. El PDF menciona "penalizaciones Atleti" y "penalizaciones Florentino" que **NO aparecen en las fórmulas abiertas**. Obligatorio validar con `playMatch.p` ≥1000 partidos antes de cerrar.
- **[2026-04-18] Asistencia obligatoria los días 27 y 29 para cobrar premios** — Contexto: PDF dice *"los premios solo serán tenidos en cuenta a los miembros del grupo que se presenten el día de la competición"*. Los 4 tienen que ir. Los 5 puntos base se pierden sin asistencia.
- **[2026-04-18] Solo cuenta el mejor de los 2 equipos en liga; ambos compiten en copa** — Contexto: PDF explícito. Entregar 2 equipos en liga = seguro. En copa = doble oportunidad. Por eso `02.mat` debe ser complementario, no duplicado.
- **[2026-04-18] Nombre del equipo FIJADO: "Interóptimo de Lagrange"** — Contexto: decisión del grupo, 2026-04-18. Juego de palabras *Inter de Milán + óptimo + multiplicadores de Lagrange*. Defensa académica: combina club histórico con la técnica matemática clásica para maximizar con restricciones (KKT), que es justo nuestro problema. Ligado al perfil Quintero (IO, optimización). Logo profesional ya listo. NO cambiar salvo consenso.
- **[2026-04-18] La defensa oral vale hasta +2 puntos (4 slides, 5 min)** — Contexto: diferencia entre 0.15 y 2.0. Hay que explicar *por qué* cada método y enseñar la narrativa Sensibilidad → Crashing → GA → SA → MC robusto.

## Working conventions específicas

- Comentarios y código en inglés; defensa y docs de estrategia en español.
- Nunca editar `playMatch.p` ni `lector.m` (son del profe).
- No seedear aleatoriedad en las funciones de librería; usar `rng(<seed>)` solo al debuggear.
- Al tocar fórmulas en `playMatchOpen.m`, cruzar con la leyenda de índices FI..TE al principio del fichero.
- MCPs disponibles en esta sesión: `matlab` (evaluar código, detectar toolboxes), `context7` (docs actualizadas de MATLAB R2024b si hace falta).

## Archivos de referencia en el repo

- [PROYECTO/ESPECIFICACIONES.md](PROYECTO/ESPECIFICACIONES.md) — transcripción clase del profe con fórmulas oficiales y rúbrica.
- [PROYECTO/Proyecto_Liga_IO_2026.pdf](PROYECTO/Proyecto_Liga_IO_2026.pdf) / [.txt](PROYECTO/Proyecto_Liga_IO_2026.txt) — enunciado oficial.
- [PROYECTO/JAVIER QUINTERO.md](PROYECTO/JAVIER%20QUINTERO.md) — perfil del profe (para nombre/logo).
- [PROYECTO/TEMARIO- PARCIAL 1.txt](PROYECTO/TEMARIO-%20PARCIAL%201.txt) / [PARCIAL 2.txt](PROYECTO/TEMARIO-%20PARCIAL%202.txt) — temario (Simplex, PE, PNL, colas, Crashing, KKT, Markov).
- [GUIA_EQUIPO.md](GUIA_EQUIPO.md) — plan paso a paso para las 4 personas hasta el 27-abr.
