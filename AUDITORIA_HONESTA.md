# Auditoría honesta — qué sé, qué supongo, qué ignoro

**Equipo**: Interóptimo de Lagrange. Logo profesional ya listo.
**Fecha**: 2026-04-18, Día 1.

Este documento es crítico con nuestro propio trabajo. Separa evidencia de suposición, y dice explícitamente dónde fallaríamos si el profesor aprieta.

---

## ✅ Lo que SÉ con certeza (verificado contra PDF y/o transcripción)

| # | Hecho | Fuente |
|---|-------|--------|
| 1 | Vector de 10 enteros, `min(A) >= 1` (PDF dice "enteras positivas") | PDF §4.1 |
| 2 | `sum(A) ∈ [95, 100]` | PDF §4.1 + transcripción |
| 3 | Formato `XY.mat`, una variable `1x10 double` dentro | PDF §3.1 + `lector.m` |
| 4 | Error de formato/serial/lectura = **descalificación automática** | PDF §3.1 literal |
| 5 | Máximo 2 equipos por grupo. `01.mat` obligatorio, `02.mat` opcional | PDF §3.1 |
| 6 | Una sola subida, sin reenvíos | Transcripción literal |
| 7 | Presentación opcional, 4 slides, 5 min → hasta +2 pts según calidad metodológica | PDF §3.2 + transcripción |
| 8 | Simulador `playMatch.p` es **estocástico** (no determinista, usa binomiales y `randn`) | PDF §4.2 + §5 |
| 9 | Liga = N rondas todos-contra-todos; copa = eliminación con reintento hasta victoria, max 10 intentos, luego penaltis | PDF §1+§2 |
| 10 | Penaltis ponderan **TE, FI, moral, 1/cansancio** (según PDF literal "técnico, finalización, moral y menor cansancio") | PDF §2 |
| 11 | Empates liga se rompen por: diferencia de goles → goles a favor → reparto equitativo | PDF §1 + transcripción |
| 12 | Asistencia obligatoria el día de competición para cobrar premios | PDF literal "solo serán tenidos en cuenta a los miembros del grupo que se presenten" |
| 13 | Nuestro MATLAB R2024b NO tiene Optimization Toolbox ni Global Optimization Toolbox | `mcp__matlab__detect_matlab_toolboxes` |
| 14 | `validateTeam`, reparadores GA/SA y `crashingBaseline` ahora fuerzan `min(A) >= 1` | Parches aplicados hoy + test unitario en MATLAB |

---

## ⚠️ Lo que SUPONGO (hipótesis educada, no verificada al 100%)

| # | Hipótesis | Por qué creo que es verdad | Por qué podría estar equivocado |
|---|-----------|---------------------------|---------------------------------|
| A | `playMatch.p` implementa exactamente las ecuaciones §5.1–§5.14 | El profesor dice "las ecuaciones son estas" | Dice también "penalizaciones Atleti/Florentino en algún sitio". Puede haber código adicional no documentado. |
| B | `min(A) >= 1` es estrictamente necesario | PDF dice "positivas" y Quintero es matemático riguroso | `lector.m` no valida ceros. El simulador abierto los tolera con `max(0.01,...)`. Podría permitir ceros en silencio. |
| C | `sum = 100` es óptimo; bajar a 95 solo añade varianza | Fórmula abierta: `σ_moral·max(1,100-Σ)·randn()`, E=0 | El profesor dice "ligera bonificación". Puede haber bonus determinista oculto en `playMatch.p`. |
| D | EF y TE dominan (sensibilidades +11.2% y +7.3%) | Verificado con Monte Carlo 100×20 sobre `playMatchOpen` | Solo mide sensibilidad **local** alrededor de `[10..10]`. Puede cambiar en otras regiones. |
| E | N (rondas liga) es grande (dicho "1000M instancias") | Transcripción literal del profesor | Puede exagerar; N efectivo quizás 10⁴-10⁶. Con N pequeño, la varianza sí importa. |
| F | Rivales contra los que mediremos sensibilidad ≈ rivales aleatorios `generateTeam(100)` | Simulación Monte Carlo estándar | Los rivales reales son equipos de otros estudiantes, probablemente sesgados hacia EF+TE también. Sensibilidades pueden diferir. |

---

## ❌ Lo que IGNORO completamente

1. **El equipo "All-Stars" del profesor**. No sabemos su vector. Solo "es muy bueno" y "todos pierden contra él".
2. **Equipos de los otros ~20 grupos**. Hasta el día 27/29 no los vemos.
3. **N exacto** (número de rondas de liga). Crítico para decidir estrategia de varianza.
4. **Si `playMatch.p == playMatchOpen.m`**. Solo sabremos cuando el profe suba el .p y podamos comparar.
5. **Si el profe aplica validación estricta de ceros** o solo lector estándar.
6. **Fórmula exacta de los penaltis** — dice "técnico, finalización, moral, cansancio" pero no los pesos.
7. **Qué entiende el profe por "original" para nombre/logo**. "Interóptimo de Lagrange" es defendible pero depende de su gusto.

---

## 🔴 Debilidades serias de nuestro trabajo actual

Sin adornar:

### D1. Todo el tuning está hecho contra `playMatchOpen.m`, NO contra `playMatch.p`
- Si el oficial tiene penalizaciones ocultas (Atleti/Florentino dichas en clase), nuestro 57.6% puede caer al 45% en la liga real.
- **Acción obligatoria**: el día que el profe suba `playMatch.p`, correr 1000+ partidos del mejor vector en AMBOS y comparar.

### D2. El GA/SA se ha corrido con hiperparámetros ligeros
- `popSize=150, gen=120`, `saIter=3000`. Tarda ~5-10 min. Con `popSize=500, gen=500, saIter=20000` probablemente subamos 1-3 puntos porcentuales. No lo hemos hecho aún.
- **Acción**: dejar corriendo overnight entre martes y miércoles.

### D3. La sensibilidad es LOCAL
- Calculada alrededor de `[10..10]`. Los deltas `δᵢ` solo valen ±5 unidades. Extrapolar a EF=25, TE=20 es arriesgado.
- **Evidencia empírica**: el Crashing puro extremo colapsa a 0%. Nuestros cotas conservadoras lo resuelven pero son heurísticas, no demostración.
- **Acción sugerida**: recalcular sensibilidades alrededor del GA actual `[6 9 9 11 10 1 6 6 24 18]` para ver si aún hay márgenes de mejora local.

### D4. Nadie ha auditado `playMatchOpen.m` línea a línea contra las ecuaciones del PDF §5
- Podría tener bugs de transcripción (un signo equivocado, un índice cambiado). Si hay, optimizamos contra un modelo mal.
- **Acción**: que el Validador compare cada ecuación del PDF con cada línea de `playMatchOpen.m`.

### D5. Nuestra win-rate del 57.6% es contra rivales ALEATORIOS
- En la liga real competimos contra ~20 equipos OPTIMIZADOS. Contra rivales fuertes, WR real probablemente 40-50%, no 57%.
- Eso NO quiere decir que perdamos la liga — si los demás sacan 35-45%, seguimos arriba.
- **Acción**: cuando tengamos 5-10 candidatos fuertes, jugar un mini-torneo entre ellos para estimar ranking relativo.

### D6. No hemos probado el flujo de entrega end-to-end
- Crear `99.mat` de prueba → pasarlo por `lector.m` en otro directorio → cargar en `playMatch.p` y simular un partido. Todo el path desde vector a simulación real no se ha validado.
- **Acción**: el Validador hace dry-run completo cuando el profe suba `playMatch.p`.

### D7. La defensa oral aún no está estructurada
- Tenemos datos (tabla, sensibilidades, baseline, mejora GA) pero no el discurso de 5 minutos.
- **Acción**: el Defensor prepara 4 slides esta semana.

---

## 📋 Checklist de entrega (el 27 de abril NO quiero sorpresas)

Antes de que la persona designada suba `01.mat`:

- [ ] Vector final pasa `validateTeam(team)` con `ok=1`
- [ ] `min(team) >= 1` (todos los parámetros positivos estrictos)
- [ ] `sum(team) == 100` exacto
- [ ] Archivo creado con `createTeamFile(team, '<serial>')` usando el serial REAL
- [ ] En un directorio LIMPIO (solo con ese `.mat`), ejecutar `lector()` y confirmar salida `1x10 double` correcta
- [ ] Ejecutar `playMatch(team, [10 10 10 10 10 10 10 10 10 10])` → devuelve 2 enteros sin error
- [ ] Los 4 miembros del grupo confirman por escrito el vector final
- [ ] Sólo una subida. Captura de pantalla del upload al grupo
- [ ] Los 4 presentes el 27 y el 29 de abril

---

## 🎯 Nombre y logo — estado

- **Nombre**: **Interóptimo de Lagrange** ✅ LISTO
  - Juego de palabras: *Inter de Milán* + *óptimo* + *multiplicadores de Lagrange*.
  - Conexión con Quintero: Lagrangianos son base de la teoría de optimización con restricciones (KKT). Quintero enseña IO.
  - Defensa académica: "Combina el nombre de un club histórico con la técnica matemática más clásica para maximizar función objetivo sujeta a restricciones — justo nuestro problema."
  - Sin guarradas ✅.
- **Logo**: profesional, ya listo ✅.

---

## 📅 Qué falta (y prioridad)

| # | Tarea | Responsable | Día | Prioridad |
|---|-------|-------------|----:|:---------:|
| 1 | Descargar `playMatch.p` del Aula Virtual (lunes 20) | Validador | 20/04 | 🔴 Alta |
| 2 | Calibrar `playMatchOpen` vs `playMatch.p` (1000+ partidos) | Validador | 20/04 | 🔴 Alta |
| 3 | Auditoría línea-a-línea `playMatchOpen.m` contra PDF §5 | Analista | 20/04 | 🟡 Media |
| 4 | Re-sensibilidad alrededor del GA actual, no de `[10..10]` | Analista | 21/04 | 🟡 Media |
| 5 | GA largo overnight (popSize=300, gen=300) | Optimizador | 21-22/04 | 🟡 Media |
| 6 | Llevar el vector al profe el miércoles 22 para feedback | Todos | 22/04 | 🟢 Alta |
| 7 | Redactar guion de 5 min + 4 slides | Defensor | 23-24/04 | 🔴 Alta |
| 8 | Congelación de vector + dry-run completo | Validador | 25/04 | 🔴 Alta |
| 9 | Ensayo de defensa (3 veces mínimo) | Defensor + grupo | 26/04 | 🟡 Media |
| 10 | Subida del `.mat` (solo la persona designada) | Designado | 27/04 | 🔴 Alta |

---

## 💬 Una última honestidad

Con lo que tenemos hoy:
- Un baseline sólido (57.6% WR contra rivales aleatorios)
- Un nombre y logo profesionales
- Documentación clara para defender
- Todas las trampas del PDF identificadas y parcheadas

Nos basta para cobrar los **5 puntos base + algo de presentación + nombre/logo** = probablemente **6.5–7.5 sobre 10**. Con un poco de suerte en la liga (top 5–8 de 20 equipos) llegamos a **8–8.5**. Para el **9–10** hace falta:

1. Calibrar contra `playMatch.p` oficial (no lo hemos hecho).
2. GA largo overnight (no lo hemos hecho).
3. Defensa bien ensayada (no la hemos preparado).

No miento ni adorno: si el domingo y lunes hacemos los 3 puntos anteriores, vamos con todo. Si no los hacemos, nos quedamos en el 7.5.
