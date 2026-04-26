# Slides — Parte del Vector (4 slides, 5 min)

Equipo: **Interóptimo de Lagrange**

---

## Slide 1 — Problema y restricciones

**Título:** Diseño de un equipo bajo presupuesto entero estocástico

- Vector `[FI GO JD MA OR PR PO TR EF TE]` de **10 enteros positivos**.
- Restricciones duras (PDF §4.1): cada componente `>= 1`, suma en **[95, 100]**.
- Función objetivo: maximizar el rendimiento esperado en liga (puntos por partido) y aportar un perfil complementario para Copa.
- El simulador `playMatch.p` es **estocástico** (binomiales + `randn`). La tasa de victorias es una variable aleatoria estimada por Monte Carlo.

> **Notas del presentador.** Es un problema de optimización **discreta**, **acotada** y **estocástica**, no diferenciable. Por eso descartamos KKT/Lagrangiano clásico y combinamos sensibilidad local, generación de candidatos y validación oficial.

---

## Slide 2 — Metodología

**Título:** Sensibilidad → Candidatos → Validación oficial → Congelación

1. **Sensibilidad local** alrededor de `[10..10]` para identificar palancas (EF y TE dominan; PR, GO, FI son negativos en liga).
2. **Generación de candidatos**: vectores diseñados por el grupo + extracción de `.mat` previos.
3. **Búsqueda local** de **317 vecinos** alrededor de los dos mejores candidatos, moviendo ±1 y ±2 puntos entre cualquier par de variables.
4. **Validación con `playMatch.p` oficial** en tres pasadas:
   - Quick sieve (300 rivales × 30 partidos × 3 seeds).
   - Robust top-10 (1000 rivales × 50 partidos × 5 seeds).
   - Mini-liga round-robin (1000 partidos por cruce × 3 seeds).
5. **Criterio de congelación**: solo se sustituye si un vecino mejora `>= +0.015 pts/p` en evaluación robusta **y** queda por encima en mini-liga más allá de 1 σ.

> **Notas del presentador.** Generamos candidatos con una versión abierta basada en las ecuaciones del PDF y cerramos la selección usando `playMatch.p` oficial. Las 5 seeds nos dan media + desviación típica para distinguir señal de ruido.

---

## Slide 3 — Resultados de auditoría

**Título:** Búsqueda local oficial — datos numéricos

**Eval robusto (1000 × 50 × 5 seeds, `playMatch.p`):**

- **01**: 1.9716 ± 0.0063 pts/p
- **02**: 1.9753 ± 0.0074 pts/p
- **Mejor vecino encontrado**: 1.9805 ± 0.0068 pts/p → ganancia frente a 01 = **+0.0089 pts/p**
- Umbral exigido para sustituir: **+0.015 pts/p** → la ganancia observada **NO** supera el umbral (~1.0 σ).

**Mini-liga top-10 (round-robin 1000 × 3 seeds, `playMatch.p`):**

- **01 queda 3.º** (12 510.7 ± 26.6 pts).
- **02 queda 7.º** (12 425.0 ± 31.5 pts).
- El líder de mini-liga es un vecino de 01 (`[6 9 9 11 10 1 6 4 26 18]`) con 12 681.7 pts, pero queda 9.º en eval robusto → **no estable**.

**Decisión:** los vectores se congelan porque ninguna variante local mejora de forma robusta en evaluación aleatoria y mini-liga simultáneamente.

> **Notas del presentador.** El doble filtro (robust + mini-liga) es justo lo que evita que persigamos ruido. Una mejora aparente en una sola métrica no justifica el cambio. Por eso el 01 y el 02 quedan firmes.

---

## Slide 4 — Vectores finales

**Título:** Dos perfiles complementarios congelados

```
01 = [6  9  9  11  10  1  6  6  24  18]
02 = [8  7  9  10  11  1  2  6  29  17]
```

- **01 — perfil principal robusto.** Reparto equilibrado, 3.º en mini-liga y estable en evaluación robusta sin sustituto que supere el doble criterio.
- **02 — perfil complementario ofensivo.** Concentra **FI + EF + TE = 54** (FI=8, EF=29, TE=17), útil para escenarios de Copa y penaltis donde el PDF §2 pondera "técnico, finalización, moral y menor cansancio".

**Pendiente antes de subir:**

1. Recibir el **serial real** del profesor.
2. Verificar **MD5** de `playMatch.p` del Aula Virtual (`f6e1dce6bd0b71774f0ca15a448ad45b`).
3. Generar `XX.mat` / `YY.mat` con `createTeamFile`, ejecutar `lector` y `playMatch` de prueba.

> **Notas del presentador.** No vendemos óptimo absoluto. Decimos *"mejor solución encontrada y validada mediante simulación Monte Carlo con `playMatch.p` oficial sobre 5 seeds"*. La búsqueda fue local; existen regiones del espacio no exploradas, pero el coste/beneficio de seguir buscando ya no compensa.
