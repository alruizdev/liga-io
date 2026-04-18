# Auditoría forense — trampas y reglas ocultas

Verificado contra: [PROYECTO/Proyecto_Liga_IO_2026.pdf](PROYECTO/Proyecto_Liga_IO_2026.pdf) (fuente oficial), [PROYECTO/ESPECIFICACIONES.md](PROYECTO/ESPECIFICACIONES.md) (transcripción oral), [PROYECTO/JAVIER QUINTERO.md](PROYECTO/JAVIER%20QUINTERO.md) (perfil profesor), y [PROYECTO/playMatchOpen.m](PROYECTO/playMatchOpen.m) (ecuaciones).

## 🚨 TRAMPA 1 — "Entradas positivas" (NO permite ceros)

**Fuente PDF (texto literal)**:
> *"el modelo exige dos vectores A y B con **entradas enteras positivas** cuya suma esté entre 95 y 100"*

- El PDF dice **positivas**. Un matemático riguroso (y Quintero es Cum Laude en matemáticas) interpreta "positivo" como `> 0`, es decir `≥ 1`.
- Nuestro [validateTeam.m](PROYECTO/validateTeam.m) permitía `A >= 0` → **error de validación**.
- El equipo GA actual `[9 5 10 10 12 0 1 10 21 22]` tiene `PR=0` → **riesgo de descalificación**.
- El profesor dijo en clase (transcripción): *"si te dan un gam, estás haciendo algo mal"* refiriéndose a los `max(0.01,...)` → confirma que los ceros son un signo de mal diseño aunque técnicamente el simulador abierto los tolere.
- El `lector.m` que nos dio no valida ceros, pero el **evaluador oficial sí podría**. Y aunque no lo hiciera, un matemático estricto puede descalificar manualmente.

**Acción**: cambiar validateTeam a `A < 1` y forzar `min(A) >= 1` en todos los reparadores (GA, SA, generateTeam, crashingBaseline). Coste: 10 puntos del budget reservados como mínimos → quedan 90 para distribuir (muy asumible).

## 🚨 TRAMPA 2 — Penaltis de copa usan 4 parámetros específicos

**Fuente PDF**:
> *"la probabilidad favorecerá el equipo con **mejor técnico, finalización, moral y menor cansancio**"*

- Los 4 parámetros del penalti: **TE, FI, moral, cansancio** (los dos últimos derivados de sigma + TE + PR/PO/TR/JD).
- **Trade-off brutal**: la sensibilidad liga dice **FI es negativo (-4.1%)**, pero en copa FI es determinante para penaltis.
- Nuestro equipo liga-óptimo (FI=9) es mediocre para copa. El equipo copa necesita FI alto, TE alto, y moral alta (σ baja = equipo equilibrado).
- **Estrategia**: `01.mat` optimizado para LIGA (expected win-rate), `02.mat` optimizado para COPA (alto FI + TE + baja sigma + baja PR/PO/TR).

## 🚨 TRAMPA 3 — Liga valora goleador y menos-goleado

**Fuente PDF**:
> *"La puntuación se asignará a cada grupo por su **equipo con mejor posicionamiento**"*
> *"Si tu equipo en liga es el que más goles tiene, te doy medio punto"* (transcripción)
> *"Si tu equipo en liga es el que menos goles recibe, te doy medio punto"* (transcripción)

- 0.5 + 0.5 = **1 punto extra** si maximizamos GF o GA.
- Nuestro GA team: GF=1.79, GA=1.00 → decente pero no máximo.
- Oportunidad: `02.mat` hiper-ofensivo con EF=30, FI=15, GO=15 (sacrificando PR/PO) → puede ser goleador.

## 🚨 TRAMPA 4 — "N ligas" desconocido

**Fuente PDF**: *"Se ejecutarán **N ligas** en formato todos contra todos"* — N no se especifica.

**Fuente oral**: *"le voy a hacer creo que 1000 millones de instancias"*

- Con N muy grande, la varianza se promedia y la estrategia "underdog con `sum<100`" (que añade ruido gaussiano a la moral vía `sigma_moral·max(1,100-Σ)·eps`) NO funciona — en media da 0.
- **Conclusión**: optimizar `sum=100` exacto. El margen 95-99 solo tiene sentido si fuéramos un equipo inferior y quisiéramos sorpresas. No es nuestro caso.

## 🚨 TRAMPA 5 — Dispersión castiga doblemente

**Fuente playMatchOpen.m**:
```matlab
sigma_A = (1/10) * sum(abs(A - 10));
MO_A = 10 - alpha*sigma_A + beta*(A(10)/10) + sigma_moral * max(1, 100-sum(A)) * eps_A;
```

- σ mide la dispersión respecto a 10. Cada unidad lejos de 10 resta 0.5 a la moral esperada.
- Nuestro GA team: σ = 5.0 → moral base ≈ 8.6 (vs 10.5 del balanceado).
- Pero moral entra como `F_mor = 0.85 + MO/20` (1.28 vs 1.375, solo 7% menos).
- Trade-off compensado por EF=22 (P_g ≈ 0.59 vs 0.35 del balanceado). Nuestro equipo gana igual.
- **Lección**: no ser extremo. Nunca más allá de 25-30 en ningún parámetro.

## 🚨 TRAMPA 6 — Penalizaciones "Atleti" y "Florentino"

**Fuente oral**:
> *"si tienes un equipo de mucha posesión con poca eficiencia, te hago un Atleti"*
> *"si tienes un equipo como el Madrid, malo en todas partes pero con truco Florentino, eso también tiene su penalización en algún sitio"*

- **Atleti**: PO alto + EF bajo → penalización. En `playMatchOpen.m` aparece como `CA = (0.4·PR + 0.3·PO + 0.3·TR - 0.5·JD)/10` → PO alto sube cansancio directamente.
- **Florentino**: malo en todo + TE alto → "penalización en algún sitio". **Pero NO aparece explícitamente en las ecuaciones abiertas**. Posible penalización oculta en `playMatch.p` que no está en `playMatchOpen.m`.
- Nuestro equipo tiene TE=22 pero no es "malo en todo" (tiene EF=22, JD=10, OR=12). No es Florentino puro. Aun así, **validar con `playMatch.p` oficial es obligatorio**.

## 🚨 TRAMPA 7 — "Errores de lectura = descalificación automática"

**Fuente PDF**:
> *"Errores en los seriales, el formato de los archivos, errores de lectura o equipos inválidos implicarán **descalificación automática**"*

Checklist pre-entrega:
- [ ] Archivo se llama exactamente `XY.mat` con el serial asignado (no `01.mat` de prueba).
- [ ] Una sola variable dentro, tipo `double`, tamaño `1x10`.
- [ ] Todas las entradas enteras positivas (`>= 1`).
- [ ] Suma ∈ [95, 100].
- [ ] `lector.m` en otro directorio con el archivo devuelve el vector correcto.
- [ ] Probado que `playMatch.p(team, rival)` no da error con el archivo cargado.

## 🚨 TRAMPA 8 — Asistencia obligatoria para cobrar premios

**Fuente PDF**:
> *"los premios solo serán tenidos en cuenta a los miembros del grupo que **se presenten el día de la competición**"*

- 5 puntos base se pierden si no vas. Los +2 opcionales de presentación también.
- Solo el que sube y los que asisten cobran. **Todo el grupo tiene que ir el 27 y 29 de abril**.

## 🚨 TRAMPA 9 — Subasta de puesto de Copa

**Fuente PDF**:
> *"Si un grupo no desea presentarse a la Copa puede **subastar su puesto** por un precio **> 0.1 puntos**"*

- Meta-juego: si tenemos un `02.mat` muy copero, podemos comprar puesto extra de otro grupo que renuncie.
- Coste mínimo: 0.1 puntos (se restan al comprador).
- Solo rentable si estamos seguros de ganar ≥1 fase adicional (= ≥0.25 puntos).

## 🚨 TRAMPA 10 — Máximo 2 equipos por grupo, pero solo cuenta el mejor en liga

**Fuente PDF**:
> *"La puntuación se asignará a cada grupo por su **equipo con mejor posicionamiento (solo se considerará el máximo si se presentan dos a liga)**"*

- Entregar 2 equipos en liga NO suma posiciones, solo sirve como seguro si uno falla.
- Pero los 2 equipos compiten en copa por separado → **2 oportunidades de ganar fases**.
- **Estrategia óptima**: `01.mat` = mejor equipo liga (nuestro GA team + fix ceros). `02.mat` = mejor equipo copa (FI+TE+baja σ, para penaltis) O hiper-goleador para +0.5 goleador.

## 🧠 Contexto del profesor (útil para defensa y logo)

- **Dr. Javier Quintero**. Cubano (La Habana), UC3M, doctorado Cum Laude + Premio Extraordinario en Ingeniería Matemática 2023.
- Tesis doctoral: **"Ceros de polinomios ortogonales de Sobolev en el posicionamiento de cargas en equilibrio de sistemas electrostáticos"** — hay minas de inspiración aquí.
- Intereses: **polinomios ortogonales, machine learning, optimización**.
- Hobby: **desarrollo de videojuegos en Godot Engine** (nick: **cabilla**, cabilla.itch.io).
- Email: javier.quintero@urjc.es, Fuenlabrada.

**Implicaciones**:
- ES un experto real en optimización → detectará cualquier uso mal justificado de una técnica.
- Valora el rigor matemático > la complejidad ostentosa. Baseline simple bien explicado > metaheurística sin justificar.

### ✅ Nombre decidido: **Interóptimo de Lagrange**

Juego de palabras: *Inter de Milán* + *óptimo* + *multiplicadores de Lagrange*.

**Defensa académica**: combina el nombre de un club histórico con la técnica matemática más clásica para maximizar una función objetivo sujeta a restricciones (multiplicadores de Lagrange, base de KKT). Justo nuestro problema: maximizar win-rate con restricciones de presupuesto y entradas positivas.

**Por qué le gustará a Quintero**:
- Matemática seria (Lagrange) — él es Dr. Cum Laude en matemáticas aplicadas.
- Humor inteligente sin ser guarrada.
- Encaja con el temario (PNL, KKT, optimización con restricciones).
- Memorable y pronunciable.

**Logo profesional**: ya listo.

### Ideas descartadas (pool original, por si hiciera falta)
- Sobolev FC (tesis del profe) — demasiado directo, casi halago.
- Cabilla FC (nick Godot) — demasiado personal.
- Ortogonales CF — frío.
- Real Godot Deportivo — solo conecta con hobby.
- La Habana 2016 CF — demasiado específico de su biografía.

## Resumen de acciones forenses

| # | Riesgo | Severidad | Corrección |
|---|--------|-----------|------------|
| 1 | Ceros → descalificación | 🔴 Alta | Forzar `min(A) >= 1` en validateTeam + todos los reparadores |
| 2 | Copa ignora el tuning liga | 🟡 Media | Generar `02.mat` optimizado para copa |
| 3 | Gol extra no aprovechado | 🟢 Baja | Considerar `02.mat` hiper-goleador alternativo |
| 4 | Estrategia underdog inútil | 🟡 Media | Fijar `sum(A) = 100` exacto |
| 5 | Dispersión castiga | 🟢 Baja | Ya limitado por cotas de crashingBaseline |
| 6 | Penalizaciones ocultas | 🟡 Media | Validar con `playMatch.p` oficial antes de entregar |
| 7 | Error de formato | 🔴 Alta | Checklist pre-entrega + dry-run con lector |
| 8 | No asistir pierde premios | 🟢 Baja | Recordar a los 4 |
| 9 | Subasta copa | 🟢 Baja | Evaluar si `02.mat` justifica comprar puesto |
| 10 | Solo cuenta mejor equipo liga | 🟡 Media | Diseñar `01` y `02` complementarios |
