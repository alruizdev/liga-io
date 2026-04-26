# Parte del Vector — Guion de presentación

**Equipo:** Interóptimo de Lagrange
**Documento de referencia para la defensa oral.** Pareja de los slides en `SLIDES_PARTE_VECTOR.md`.

---

## 1. El problema

La Liga IO 2026 nos pide entregar un **vector de 10 enteros positivos** que representan los atributos de un equipo de fútbol simulado:

```
[FI  GO  JD  MA  OR  PR  PO  TR  EF  TE]
 1   2   3   4   5   6   7   8   9   10
```

| Idx | Sigla | Atributo |
|-----|-------|----------|
| 1   | FI    | Finalización |
| 2   | GO    | Generación Ofensiva |
| 3   | JD    | Juego Directo |
| 4   | MA    | Marcaje |
| 5   | OR    | Organización Defensiva |
| 6   | PR    | Presión |
| 7   | PO    | Posesión |
| 8   | TR    | Transición |
| 9   | EF    | Eficacia |
| 10  | TE    | Técnico |

**Restricciones (PDF §4.1):** vector 1×10, valores enteros, todos `>= 1`, suma en `[95, 100]`.

**Por qué es de optimización discreta y estocástica.** El simulador `playMatch.p` produce un resultado aleatorio en cada partido (binomiales y `randn` en moral). La tasa de victorias es una variable aleatoria que solo se estima por Monte Carlo. Las variables son enteras y la suma está acotada — eso convierte el problema en un programa entero estocástico no diferenciable. No se puede aplicar gradiente clásico ni KKT.

---

## 2. Metodología (en 5 pasos)

1. **Análisis de sensibilidad local** alrededor del punto equilibrado `[10..10]`. Variando ±5 unidades en cada parámetro y midiendo el cambio de tasa de victorias con el simulador. Resultado: EF y TE son los multiplicadores dominantes (+11.2 % y +7.3 %). PR, GO, FI son negativos en liga.

2. **Generación de candidatos.** Combinamos:
   - 10 vectores diseñados por el grupo guiados por la sensibilidad.
   - Vectores almacenados en sesiones previas (`PROYECTO/*.mat`, `Pruebas_Ivan/*.mat`).
   - **Búsqueda local de 317 vecinos** a ±1 y ±2 puntos alrededor de los dos mejores candidatos.

3. **Cierre con `playMatch.p` oficial.** Generamos candidatos con una versión abierta basada en las ecuaciones del PDF y **cerramos la selección usando `playMatch.p` oficial** en tres pasadas:
   - Quick sieve: 300 rivales × 30 partidos × 3 seeds (2026, 2027, 2028).
   - Robust top-10: 1000 rivales × 50 partidos × 5 seeds (2026-2030).
   - Mini-liga round-robin: 1000 partidos por cruce × 3 seeds.

4. **Mini-liga round-robin.** Estima el ranking real cuando se enfrentan equipos optimizados (no rivales aleatorios). Controla el sesgo de medir solo contra rivales aleatorios, que tiende a sobreestimar el rendimiento real en liga.

5. **Criterio estricto de cambio.** Solo se sustituye un vector si un vecino mejora `>= +0.015 pts/p` en evaluación robusta **y** queda por encima en mini-liga más allá de 1 σ. Si ningún vecino pasa el doble filtro, los vectores se congelan.

---

## 3. Vectores finales (congelados)

| Slot | Vector | Suma | Min | FI+EF+TE |
|------|--------|------|-----|----------|
| **01** | `[6  9  9  11  10  1  6  6  24  18]` | 100 | 1 | 48 |
| **02** | `[8  7  9  10  11  1  2  6  29  17]` | 100 | 1 | 54 |

**01 — perfil principal robusto.** Reparto equilibrado, 3.º en mini-liga y estable en evaluación robusta. Ningún sustituto supera el doble criterio (robust + mini-liga simultáneamente).

**02 — perfil complementario ofensivo.** Mantiene buen rendimiento contra rivales aleatorios y concentra **FI + EF + TE = 54** (máximo del top-10). Útil para escenarios de Copa y penaltis donde el PDF §2 pondera "técnico, finalización, moral y menor cansancio".

**Por qué se congelan.** Los vectores se congelan porque ninguna variante local mejora de forma robusta en evaluación aleatoria y mini-liga simultáneamente.

---

## 4. Resultados clave para enseñar

**Eval robusto (1000 × 50 × 5 seeds, `playMatch.p`):**

| Vector | pts/p (mean ± std) | Vic | DG |
|--------|-------------------|-----|-----|
| 01 = `[6 9 9 11 10 1 6 6 24 18]` | 1.9716 ± 0.0063 | 0.5822 ± 0.0026 | +0.837 ± 0.009 |
| 02 = `[8 7 9 10 11 1 2 6 29 17]` | 1.9753 ± 0.0074 | 0.5865 ± 0.0024 | +0.851 ± 0.011 |
| Mejor vecino encontrado          | 1.9805 ± 0.0068 | 0.5881 ± 0.0020 | +0.860 ± 0.007 |

Diferencia mejor-vecino vs 01 = **+0.0089 pts/p**, ~1.0 σ. **No supera el umbral exigido +0.015** → no se cambia.

**Mini-liga top-10 (round-robin, 1000 partidos × 3 seeds, `playMatch.p`):**

| Posición | Vector | Pts (mean ± std) |
|----------|--------|------------------|
| 3.º | **01 = `[6 9 9 11 10 1 6 6 24 18]`** | **12 510.7 ± 26.6** |
| 7.º | **02 = `[8 7 9 10 11 1 2 6 29 17]`** | **12 425.0 ± 31.5** |
| 1.º (vecino) | `[6 9 9 11 10 1 6 4 26 18]` | 12 681.7 ± 56.0 |

El líder absoluto de mini-liga es un vecino de 01 (mover 2 puntos TR→EF), pero queda 9.º en eval robusto → mejora **no estable**.

**Comparación honesta:** el equipo balanceado `[10..10]` saca 1.528 pts/p. Nuestros 01 y 02 sacan 1.97. Mejora del **+29 %** sobre el reparto neutro.

---

## 5. Riesgos residuales (no se ocultan)

1. El `playMatch.p` que usamos viene de `Pruebas_Ivan/`, MD5 `f6e1dce6bd0b71774f0ca15a448ad45b`. **Hay que verificar que coincide con el del Aula Virtual el día de la entrega.** Si difiere, reabrir auditoría.
2. La aleatoriedad del simulador. Por eso reportamos media ± std sobre 5 seeds, no un solo número.
3. El **serial real** lo da el profesor el día de la entrega. Cualquier error de nombre = descalificación. Procedimiento documentado en `CHECKLIST_ENTREGA.md`.
4. La búsqueda fue **local** (vecinos a ±2 puntos). No descartamos que exista un mínimo mejor en otra región — pero la mini-liga oficial confirma que en el vecindario explorado los vectores actuales son robustos.

---

## 6. Lenguaje permitido

| ✗ NO decir | ✓ SÍ decir |
|------------|------------|
| "óptimo absoluto" | "mejor solución encontrada en el vecindario explorado" |
| "solución óptima global" | "validada mediante simulación Monte Carlo con `playMatch.p` oficial" |
| "campeón de mini-liga" (para 01) | "01 es el perfil principal robusto: 3.º en mini-liga, estable en evaluación robusta" |
| "el 02 es el mejor de Copa demostrado" | "02 es el perfil complementario ofensivo orientado a Copa (FI+EF+TE=54)" |
| "el resultado oficial dice…" (si vino de `playMatchOpen`) | "Generamos candidatos con una versión abierta basada en las ecuaciones del PDF y cerramos la selección usando `playMatch.p` oficial" |
| "DG dominante" (para 01) | "01 con DG positivo (+0.84) y std baja, ningún sustituto pasa el doble filtro" |
