# VECTOR_FINAL_AUDIT_CERRADO — Liga IO 2026 · Interóptimo de Lagrange

**Fecha y hora del cierre:** 2026-04-26
**Documento de referencia oficial.** Sustituye a `VECTOR_FINAL_AUDIT.md` en lo relativo a la elección de los vectores. La auditoría inicial sigue siendo válida como histórico.

---

## 1. Decisión final

> **Vectores CONGELADOS.** La búsqueda local oficial sobre 317 vecinos a ±2 puntos no encontró mejora estable suficiente para justificar el cambio.

| Slot | Vector | Suma | Min | FI+EF+TE | Estado |
|------|--------|------|-----|----------|--------|
| **01** | `[6  9  9  11  10  1  6  6  24  18]` | 100 | 1 | 48 | **Congelado** (= base01) |
| **02** | `[8  7  9  10  11  1  2  6  29  17]` | 100 | 1 | 54 | **Congelado** (= base02) |

---

## 2. Identificación del simulador usado

- **Archivo:** `Pruebas_Ivan/playMatch.p`
- **Tamaño:** 1029 bytes
- **MD5:** `f6e1dce6bd0b71774f0ca15a448ad45b`
- Una segunda copia idéntica está en `PROYECTO/playMatch.p` (mismo hash).
- `which playMatch` resuelve a la copia de `Pruebas_Ivan/`.
- Requisito técnico: el proyecto provee `PROYECTO/binornd.m` (sustituto sin Statistics Toolbox) que `playMatch.p` necesita.

**Acción obligatoria antes de la subida:** verificar que el `playMatch.p` publicado en el Aula Virtual coincide con este MD5. Si no coincide → reabrir auditoría con `auditoriaCierre(opt)` (4-5 min).

---

## 3. Metodología de la auditoría de cierre

| Fase | Engine | Configuración | Tiempo |
|------|--------|---------------|--------|
| Generación de vecinos | — | base01 ± {1,2}, base02 ± {1,2}, dedupe → 317 candidatos válidos | <1 s |
| Quick sieve | `playMatch.p` oficial | 300 rivales × 30 partidos × 3 seeds (2026, 2027, 2028) | 199 s |
| Robust eval top-10 | `playMatch.p` oficial | 1000 rivales × 50 partidos × 5 seeds (2026-2030) | 63 s |
| Mini-liga round-robin | `playMatch.p` oficial | top-10, 1000 partidos por cruce × 3 seeds | 7 s |

**Total de la auditoría:** 4.5 minutos sobre la máquina del equipo.

Los candidatos se generaron con la fórmula abierta `playMatchOpen.m` solo como punto de partida para localizar el vecindario; **toda la selección se cerró con `playMatch.p` oficial**.

---

## 4. Resultados — eval robusto top-10 (1000×50 × 5 seeds, oficial)

Ordenados como aparecieron en el top-10 del quick sieve:

| Vector | pts/p (mean ± std) | Vic (mean ± std) | DG (mean ± std) |
|--------|-------------------|------------------|-----------------|
| `[8  7  9  10  11  1  3  6  29  16]` | 1.9796 ± 0.0056 | 0.5878 ± 0.0022 | +0.857 ± 0.009 |
| `[6  9  9  11  10  1  5  6  25  18]` | 1.9782 ± 0.0039 | 0.5857 ± 0.0017 | +0.845 ± 0.006 |
| `[8  7  9  10  13  1  2  6  27  17]` | 1.9684 ± 0.0065 | 0.5827 ± 0.0029 | +0.831 ± 0.007 |
| **`[8  6  9  10  11  1  3  6  29  17]` ← mejor robust** | **1.9805 ± 0.0068** | 0.5881 ± 0.0020 | +0.860 ± 0.007 |
| `[6  9  9  11  10  1  6  5  25  18]` | 1.9722 ± 0.0040 | 0.5838 ± 0.0014 | +0.840 ± 0.010 |
| `[6  9  9  11  10  1  6  4  26  18]` | 1.9752 ± 0.0049 | 0.5848 ± 0.0018 | +0.848 ± 0.010 |
| `[6  9  9  11  10  1  6  4  24  20]` | 1.9655 ± 0.0045 | 0.5809 ± 0.0017 | +0.825 ± 0.008 |
| `[8  7  10  10  11  1  2  6  29  16]` | 1.9712 ± 0.0052 | 0.5850 ± 0.0024 | +0.843 ± 0.010 |
| **`[6  9  9  11  10  1  6  6  24  18]` ← base01** | **1.9716 ± 0.0063** | 0.5822 ± 0.0026 | +0.837 ± 0.009 |
| **`[8  7  9  10  11  1  2  6  29  17]` ← base02** | **1.9753 ± 0.0074** | 0.5865 ± 0.0024 | +0.851 ± 0.011 |

---

## 5. Resultados — mini-liga top-10 (round-robin, 1000 partidos × 3 seeds, oficial)

Suma de puntos a lo largo de los 9 rivales × 1000 partidos × 3 seeds = 27 000 partidos por equipo.

| Pos | Vector | Pts (mean ± std) | DG (mean ± std) |
|-----|--------|------------------|-----------------|
| 1   | `[6  9  9  11  10  1  6  4  26  18]` | 12681.7 ± 56.0 | +233.7 ± 40.3 |
| 2   | `[6  9  9  11  10  1  5  6  25  18]` | 12603.0 ± 103.8 | +323.3 ± 220.7 |
| **3** | **`[6  9  9  11  10  1  6  6  24  18]` ← base01** | **12510.7 ± 26.6** | +250.3 ± 52.6 |
| 4   | `[6  9  9  11  10  1  6  4  24  20]` | 12477.0 ± 248.7 | +30.3 ± 357.7 |
| 5   | `[6  9  9  11  10  1  6  5  25  18]` | 12445.3 ± 125.7 | +33.3 ± 178.0 |
| 6   | `[8  7  9  10  13  1  2  6  27  17]` | 12428.0 ± 144.3 | -182.7 ± 135.4 |
| **7** | **`[8  7  9  10  11  1  2  6  29  17]` ← base02** | **12425.0 ± 31.5** | -198.0 ± 86.8 |
| 8   | `[8  7  9  10  11  1  3  6  29  16]` | 12423.7 ± 31.3 | -35.0 ± 25.0 |
| 9   | `[8  6  9  10  11  1  3  6  29  17]` | 12404.3 ± 18.6 | -129.0 ± 71.8 |
| 10  | `[8  7  10  10  11  1  2  6  29  16]` | 12315.7 ± 48.4 | -232.0 ± 76.6 |

---

## 6. Justificación detallada

### 6.1 Por qué se congela el 01

- **Mejor candidato en eval robusto:** `[8 6 9 10 11 1 3 6 29 17]`, con 1.9805 ± 0.0068 pts/p.
- **Diferencia frente a base01:** +0.0089 pts/p (con std combinada ≈ 0.0093). El umbral de cambio era **+0.015 pts/p**. La diferencia observada es ~1.0 σ → no significativa.
- **Mini-liga del candidato:** 12404 ± 18.6 pts (puesto 9 de 10), claramente **peor** que base01 (12511, puesto 3). Eso hace que el criterio AND (mejor en ambas métricas) falle de forma rotunda.
- **El líder de la mini-liga** `[6 9 9 11 10 1 6 4 26 18]` (mover 2 puntos de TR a EF desde base01) saca 12681.7 vs base01 12510.7 → +171 pts ≈ +3 σ. **Solo en mini-liga**. En eval robusto saca 1.9752 vs 1.9716 = +0.0036 → ~0.5 σ, no significativo. La mejora aparente no es estable.
- Conclusión: ningún vector pasa el doble filtro robust + mini-liga. **base01 se queda.**

### 6.2 Por qué se congela el 02

- Criterio para el 02: mejorar el perfil Copa (FI+EF+TE) **y/o** la media de goles a favor (GF), **sin** degradar la mini-liga > 1 σ por debajo de base02.
- base02 tiene FI+EF+TE = 54 (máximo del top-10) y GF = 2.11 ± estimado (de la auditoría inicial).
- Ningún vecino del top-10 supera FI+EF+TE = 54.
- Los vecinos con perfiles ofensivos parecidos (`[8 7 9 10 13 1 2 6 27 17]`, `[8 7 9 10 11 1 3 6 29 16]`) tienen mini-liga 12423-12428, indistinguible de base02 dentro del ruido.
- Conclusión: no hay ganancia ofensiva clara. **base02 se queda.**

---

## 7. Comparación contra "no hacer nada"

| Vector | pts/p oficial robusto | Diferencia |
|--------|----------------------|------------|
| `[10 10 10 10 10 10 10 10 10 10]` (balanceado) | 1.528 (auditoría inicial) | baseline |
| `[3  3  15  3  15  3  15  3  20  20]` (extremo) | 1.762 | +15 % |
| **01 = `[6  9  9  11  10  1  6  6  24  18]`** | **1.972** | **+29 %** |
| **02 = `[8  7  9  10  11  1  2  6  29  17]`** | **1.975** | **+29 %** |

---

## 8. Riesgos residuales

| ID | Riesgo | Estado |
|----|--------|--------|
| R1 | `playMatch.p` del Aula Virtual ≠ del que usamos (`f6e1dce6...`) | Pendiente verificación. Acción: comparar MD5 antes de subir. |
| R2 | Sin Statistics Toolbox; usamos shim casero `binornd.m` | Validado: `playMatch.p` ejecuta sin error y produce distribuciones consistentes con la auditoría inicial. |
| R3 | Búsqueda **local** (vecinos a ±2 puntos), no global | Mitigado parcialmente: 317 vecinos cubren un radio razonable. No descartamos un mínimo global mejor en otra región, pero el coste/beneficio no compensa más exploración. |
| R4 | Aleatoriedad del simulador | Mitigado con 5 seeds para robust y 3 seeds para liga; std reportadas. |
| R5 | Serial real desconocido hasta el día de la entrega | `SUBIDA_SERIAL/` y `CHECKLIST_ENTREGA.md` documentan el procedimiento exacto. |
| R6 | Empate técnico entre los top-4 de mini-liga (~150 pts entre 1.º y 4.º) | Aceptable: los 4 son intercambiables dentro del ruido. Elegir base01 es defendible por estabilidad (std baja: ±26.6 pts) y porque ningún sustituto pasa el doble filtro robust + mini-liga. |

---

## 9. Instrucciones exactas para regenerar la entrega

```matlab
%% Cuando el profesor confirme los seriales (ej. '07', '08'):
addpath('PROYECTO');
addpath('Pruebas_Ivan');

% 1. Cargar los vectores congelados
load('ENTREGA_FINAL_CERRADA/01_final.mat'); v01 = equipo;
load('ENTREGA_FINAL_CERRADA/02_final.mat'); v02 = equipo;

% 2. Crear los archivos en SUBIDA_SERIAL con el serial REAL
cd('SUBIDA_SERIAL');
createTeamFile(v01, 'XX');     % XX = primer serial
createTeamFile(v02, 'YY');     % YY = segundo serial (opcional)
cd('..');

% 3. Verificar
cd('SUBIDA_SERIAL');
[teams, names] = lector();
[g1,g2] = playMatch(v01, 10*ones(1,10)); fprintf('test 01: %d-%d\n', g1, g2);
[g1,g2] = playMatch(v02, 10*ones(1,10)); fprintf('test 02: %d-%d\n', g1, g2);
cd('..');

% 4. Subir SOLO los XX.mat / YY.mat de SUBIDA_SERIAL/
```

---

## 10. Archivos de la entrega

| Carpeta / archivo | Propósito |
|-------------------|-----------|
| `ENTREGA_FINAL_CERRADA/01_base.mat`  | Vector base original (referencia histórica) |
| `ENTREGA_FINAL_CERRADA/02_base.mat`  | Vector base original (referencia histórica) |
| `ENTREGA_FINAL_CERRADA/01_final.mat` | Vector final (congelado = base) |
| `ENTREGA_FINAL_CERRADA/02_final.mat` | Vector final (congelado = base) |
| `SUBIDA_SERIAL/`                     | Vacío. Aquí se generan `XX.mat`/`YY.mat` con el serial real. |
| `cierre_resumen.mat`                 | Estructura `res` con todas las métricas y decisiones. |
| `PRESENTACION_PARTE_VECTOR.md`       | Guion de la defensa oral (referencia). |
| `SLIDES_PARTE_VECTOR.md`             | 4 slides para la presentación. |
| `CHECKLIST_ENTREGA.md`               | Lista operativa día de entrega. |

---

## 11. Frases que SÍ y NO se pueden decir en la defensa

| ✗ Prohibido | ✓ Correcto |
|-------------|------------|
| "óptimo absoluto" | "mejor solución encontrada en el vecindario explorado" |
| "global" | "robusto en 5 seeds independientes y mini-liga round-robin" |
| "resultado oficial" (si vino de `playMatchOpen`) | "Generamos candidatos con una versión abierta basada en las ecuaciones del PDF §5 y cerramos la selección con `playMatch.p` oficial" |
| "100 % seguro" | "validado mediante simulación Monte Carlo con `playMatch.p`" |
