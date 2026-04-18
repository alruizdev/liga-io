# GUÍA DEL EQUIPO — Interóptimo de Lagrange

**Entrega**: miércoles 27 de abril 2026.
**Hoy**: sábado 18 de abril → **9 días**.
**Clase con el profe (probar y pedir feedback)**: miércoles 22 de abril.
**Nombre del equipo**: **Interóptimo de Lagrange** ✅ fijado. Logo profesional ✅ listo.

## Objetivo en una frase

Entregar un vector de 10 enteros **positivos** (≥ 1) con suma entre 95 y 100, que gane muchos partidos contra equipos aleatorios, y presentarlo el 27 con 4 slides explicando **por qué** es un buen equipo.

---

## Lo mínimo que hay que entender (los 4)

1. **Un equipo = 10 números**. Cada número es una estadística (Finalización, Posesión, Técnico…). La suma de los 10 tiene que estar entre **95 y 100**. **Ningún número puede ser 0** (el PDF dice "entradas enteras positivas").
2. **El profe simula partidos con una fórmula que tiene dados** (estocástica). Los mismos equipos dan resultados distintos cada vez.
3. **El profe NO nos da el código de su simulador**, solo las fórmulas. Nosotros hemos reescrito esas fórmulas en [PROYECTO/playMatchOpen.m](PROYECTO/playMatchOpen.m) para poder optimizar.
4. **Entregamos UN archivo `.mat`** con nombre `XY.mat` (serial del profe) con la lista de 10 números dentro. Una sola subida, sin reenvíos.
5. **Asistencia OBLIGATORIA** los días 27 y 29 de abril para cobrar los premios.

---

## Roles del equipo

Poned nombres aquí cuando los decidáis.

| Rol | Persona | Qué hace | Nivel técnico |
|-----|---------|----------|---------------|
| **1. Analista** | _______ | Análisis matemático de `playMatch`, sensibilidad, explicación por qué EF+TE dominan | Medio |
| **2. Optimizador** | _______ | Tunear GA y SA, correr pipeline largo overnight, generar candidatos finales | Medio-alto |
| **3. Validador** | _______ | Calibrar `playMatchOpen` vs `playMatch.p`, Monte Carlo final, dry-run de entrega | Medio |
| **4. Defensor** | _______ | Slides, guion de 5 min, defensa académica del pipeline | Bajo |

**La persona designada por el profe para subir el fichero**: debe ser Validador (es quien más está con el código). No el Defensor.

---

## Pipeline actual y su rendimiento

| Capa | Técnica | Fuente académica | Win-rate (contra rivales aleatorios) |
|:---:|---------|-------------------|:--------------------------------:|
| 0 | Vector balanceado `[10..10]` | — | 39.6% |
| 1 | Análisis de sensibilidad (∇ numérico) | Tema 6 PNL | — (ranking) |
| 2 | Baseline Crashing-LP greedy | P2 diap 155 | 50.1% |
| 3 | GA (metaheurística) | Fuera de temario, permitido | 57.6% |
| 4 | SA refinamiento | Fuera de temario, permitido | 56.3% |

**Mejor vector hoy**: `[6 9 9 11 10 1 6 6 24 18]` sum=100, min=1, win-rate=57.6%.

---

## 🔴 Debilidades reconocidas (ver [AUDITORIA_HONESTA.md](AUDITORIA_HONESTA.md))

Estas 7 cosas NO están hechas y son las que marcan la diferencia entre un 7.5 y un 9+. Cada una tiene responsable y día.

| # | Debilidad | Responsable | Día |
|---|-----------|-------------|----:|
| D1 | Todo tuneado contra `playMatchOpen`, no contra `playMatch.p` oficial | Validador | 20/04 |
| D2 | GA/SA con hiperparámetros ligeros — falta pasada larga overnight | Optimizador | 21/04 |
| D3 | Sensibilidad solo calculada alrededor de `[10..10]`, no del GA actual | Analista | 21/04 |
| D4 | `playMatchOpen.m` no auditado línea a línea contra PDF §5 | Analista | 20/04 |
| D5 | 57.6% es vs rivales aleatorios — vs optimizados será más bajo | Optimizador | 23/04 |
| D6 | Flujo end-to-end `.mat` → `lector` → `playMatch` sin probar | Validador | 20/04 |
| D7 | Defensa oral aún no estructurada | Defensor | 23–24/04 |

---

## Calendario (9 días) — qué hace cada uno cada día

### Día 1 (hoy, sábado 18) — ✅ HECHO por Claude
- Auditoría PDF + transcripción → [TRAMPAS_DETECTADAS.md](TRAMPAS_DETECTADAS.md)
- Pipeline técnico base → [RESULTADOS_DIA1.md](RESULTADOS_DIA1.md)
- Parches `min(A) >= 1` en validateTeam, GA, SA, Crashing
- Nombre y logo ✅

### Día 2 (domingo 19) — arrancar todos

**Todos (30 min)**:
- Leer [CLAUDE.md](CLAUDE.md) sección MODO NIÑO + [AUDITORIA_HONESTA.md](AUDITORIA_HONESTA.md) completa.
- Asignar roles en la tabla arriba.

**Analista (1h)**:
```matlab
cd('c:\Users\angee\Downloads\IO - PREPARACION MAYO\PROYECTO LIGA IO\liga-io\PROYECTO')
load('sensitivity_baseline.mat'); disp(results)
```
Escribir medio folio en [DEFENSA_BORRADOR.md](DEFENSA_BORRADOR.md) (crearlo en la raíz) explicando:
- Por qué **Eficacia (EF)** domina: aparece directa en `P_g = 0.15 + 0.20·(A(9)/10) + ...`.
- Por qué **Técnico (TE)** domina: multiplica todo por `F_tec = 0.9 + A(10)/50`.
- Por qué Presión/Gen.Of./Finalización tienen delta **negativo**: suben σ de moral + cansancio.
Este texto va a la slide 3.

**Optimizador (2h)**:
Correr pipeline completo con semilla Crashing. Tarda ~10-20 min:
```matlab
cd('c:\Users\angee\Downloads\IO - PREPARACION MAYO\PROYECTO LIGA IO\liga-io\PROYECTO')
[team01, team02, stats] = generateFinalTeams('', '', false);
```
Compartir los 2 vectores y sus win-rates en el chat del grupo.

**Validador (1h)**:
- Sanity `.mat`:
  ```matlab
  load('pipeline_v2.mat','gaTeam')
  createTeamFile(gaTeam, '99')      % serial de prueba '99'
  [teams, names] = lector(); disp(teams)
  delete('99.mat')
  ```
- Pedir al profe que habilite `playMatch.p` lo antes posible (el profe dijo "a partir de mañana").

**Defensor (1h)**:
- Crear [DEFENSA_BORRADOR.md](DEFENSA_BORRADOR.md) en la raíz con estructura de 4 slides (solo titulares, luego lo rellenamos).
- Guardar logo en [logo.png](logo.png) o similar en la raíz.

### Día 3 (lunes 20) — **debilidades D1, D4, D6**

**Validador (2h)** — D1 + D6:
Cuando `playMatch.p` esté en la carpeta, corre:
```matlab
cd('c:\Users\angee\Downloads\IO - PREPARACION MAYO\PROYECTO LIGA IO\liga-io\PROYECTO')
load('pipeline_v2.mat','gaTeam')
rival = [10 10 10 10 10 10 10 10 10 10];

rng(0); N=1000;
gaOff = zeros(N,2); gaOpen = zeros(N,2);
for k=1:N, [gaOff(k,1), gaOff(k,2)] = playMatch(gaTeam, rival); end
rng(0);
for k=1:N, [gaOpen(k,1), gaOpen(k,2)] = playMatchOpen(gaTeam, rival); end

fprintf('Oficial: GF=%.3f GA=%.3f WR=%.2f%%\n', mean(gaOff(:,1)), mean(gaOff(:,2)), 100*mean(gaOff(:,1) > gaOff(:,2)));
fprintf('Abierto: GF=%.3f GA=%.3f WR=%.2f%%\n', mean(gaOpen(:,1)), mean(gaOpen(:,2)), 100*mean(gaOpen(:,1) > gaOpen(:,2)));
```
Si la diferencia de WR es **> 5 puntos porcentuales**, ALERTA → hay penalizaciones ocultas en el oficial. Avisa al grupo y a Claude.

Dry-run completo:
```matlab
mkdir('C:\temp_entrega')
cd('C:\temp_entrega')
copyfile('..\..\PROYECTO\pipeline_v2.mat','.')
load('pipeline_v2.mat','gaTeam')
save('99.mat','gaTeam')       % formato que usa el profesor
[teams, names] = lector();
disp(teams); disp(names)
```
Si `teams` es 1x10 double y `names` contiene 99, ok.

**Analista (2h)** — D4:
Abrir [PROYECTO/playMatchOpen.m](PROYECTO/playMatchOpen.m) y [PROYECTO/Proyecto_Liga_IO_2026.pdf](PROYECTO/Proyecto_Liga_IO_2026.pdf) (sección 5). Verificar línea a línea que las ecuaciones coinciden. Si hay alguna discrepancia (un signo, un índice), ANOTARLO.

### Día 4 (martes 21) — **debilidades D2, D3**

**Analista (1h)** — D3:
Recalcular sensibilidad alrededor del GA actual (no del balanceado):
```matlab
cd('c:\Users\angee\Downloads\IO - PREPARACION MAYO\PROYECTO LIGA IO\liga-io\PROYECTO')
load('pipeline_v2.mat','gaTeam')
results_ga = sensitivityAnalysis(gaTeam, 200, 30);
save('sensitivity_ga.mat','results_ga')
```
Comparar con el ranking original: ¿siguen EF+TE dominando o hay señal nueva?

**Optimizador (overnight)** — D2:
Antes de dormir, lanzar pipeline MUY largo:
```matlab
cd('c:\Users\angee\Downloads\IO - PREPARACION MAYO\PROYECTO LIGA IO\liga-io\PROYECTO')
rng(2026);
gaOpts.popSize=300; gaOpts.generations=300;
gaOpts.nRivals=150; gaOpts.nMatches=30; gaOpts.verbose=true;
tic; [gaLong, ~, ~] = geneticAlgorithm(gaOpts); toc
saOpts.maxIter=20000; saOpts.T0=4; saOpts.alpha=0.9995;
saOpts.nRivals=150; saOpts.nMatches=30; saOpts.verbose=true;
tic; [saLong, ~, ~] = simulatedAnnealing(gaLong, saOpts); toc
[wr,~,~,gf,ga] = evaluateTeam(saLong, 500, 100);
fprintf('LARGO: [%s] Win=%.1f%%\n', num2str(saLong), 100*wr);
save('pipeline_largo.mat','gaLong','saLong','wr')
```
Tarda ~1-2 horas. Deja el ordenador encendido.

### Día 5 (**miércoles 22**) — CLASE CON EL PROFE ⭐

**Llevad**:
- El mejor vector del día 4 en `.mat` (serial provisional `99.mat`).
- Tabla comparativa `playMatchOpen` vs `playMatch.p` (de D1).
- Lista de 3 preguntas concretas (ver abajo).

**Preguntas**:
1. *"¿Los ceros están permitidos técnicamente? El PDF dice 'positivas' pero el simulador abierto los tolera."* (Si dice sí, aflojamos el piso.)
2. *"¿Cuál es N de ligas aproximado?"* (Nos orienta sobre si optimizar por expected value o por varianza.)
3. *"¿Podemos usar metaheurísticas (GA, SA) en la defensa, o prefiere que justifiquemos solo con Crashing y Monte Carlo del temario?"*
4. *"¿La copa usa el mismo `playMatch.p` o variante?"*
5. *"En los penaltis, ¿qué pesos exactos tiene cada parámetro?"*

**Al volver**: ajustar estrategia según feedback. Si dice "ceros permitidos" recalcular GA con piso 0. Si dice "todos contra todos una vez" → estrategia varianza sí puede ayudar.

### Día 6 (jueves 23) — **D5, D7**

**Optimizador (2h)** — D5:
Mini-torneo entre los mejores 5 candidatos actuales (GA v2, SA v2, GA largo, Crashing, variante):
```matlab
candidates = {gaTeam, saTeam, saLong, teamCR, saCopa};
names = {'GAv2','SAv2','GALargo','Crashing','Copa'};
nC = length(candidates);
scores = zeros(nC, nC);
for i=1:nC
    for j=1:nC
        if i==j, continue; end
        wr = 0; N=50;
        for k=1:N, [a,b]=playMatchOpen(candidates{i},candidates{j}); wr=wr+(a>b); end
        scores(i,j) = wr/N;
    end
end
% Ranking por promedio
mean_wr = mean(scores,2);
[~,order] = sort(mean_wr,'descend');
for k=1:nC
    fprintf('%d. %s WR media=%.1f%%\n', k, names{order(k)}, 100*mean_wr(order(k)));
end
```

**Defensor (2h)** — D7:
Rellenar [DEFENSA_BORRADOR.md](DEFENSA_BORRADOR.md) con contenido real:
- Slide 1: "Interóptimo de Lagrange" + logo + 4 miembros.
- Slide 2: "10 variables enteras positivas, Σ=95-100, objetivo estocástico no lineal no diferenciable."
- Slide 3: El pipeline de 4 capas con la tabla de win-rates.
- Slide 4: Vector final + insight ("subir presión empeora el win-rate porque sube el cansancio").

### Día 7 (viernes 24) — consolidación

**Todos (30 min)**: reunión online/presencial. Decisión final del vector `01.mat` y `02.mat`. Votación 4/4.

**Validador (1h)**:
- Congelar los 2 vectores. Nadie los toca desde este punto.
- Generar los `.mat` finales **con los seriales REALES** (los que dio el profe).
- Directorio limpio, `lector()`, confirmar.

**Defensor (1h)**:
- Slides terminadas y maquetadas.
- Ensayo 1: cronometrado. Recortar si pasa de 5 min.

### Día 8 (sábado 25) — reposo y ensayo

- Nadie toca el código ni los vectores.
- 2 ensayos de defensa, uno por la mañana, otro por la noche.
- Validador hace un **segundo** dry-run del `.mat`. Tamaño correcto, nombre correcto, `lector()` OK.

### Día 9 (**domingo 26**) — check final, ensayo final

- Revisar el checklist de entrega completo (abajo).
- Último ensayo de defensa por la tarde.

### Día 10 (**lunes 27**) — ENTREGA

- La persona designada **sube `01.mat` (y opcionalmente `02.mat`) UNA SOLA VEZ**.
- Captura de pantalla de la subida al chat del grupo.
- Confirmación escrita de los 4 miembros.

### Días 11-12 (martes 28 / miércoles 29) — LIGA y DEFENSA

- Todos presentes en clase.
- Defensa de 5 min.
- Participación en votaciones de nombre/logo.
- Observar la Copa (emparejamientos aleatorios).
- Decisión opcional de enfrentarse al All-Stars (default: NO salvo que tengamos >60% WR contra él en simulación).

---

## ✅ Checklist de entrega (24-26 abril, antes de subir)

- [ ] Vector final pasa `validateTeam(team)` con `ok=1`
- [ ] `min(team) >= 1` (todos los parámetros positivos estrictos)
- [ ] `sum(team) == 100` exacto
- [ ] Archivo nombrado con el **serial REAL** que dio el profe (no `99.mat`)
- [ ] Creado con `createTeamFile(team, '<serial>')`
- [ ] En directorio limpio (solo ese `.mat`), `lector()` devuelve `1x10 double` correcto
- [ ] `playMatch(team, [10 10 10 10 10 10 10 10 10 10])` devuelve 2 enteros sin error
- [ ] 4 miembros del grupo confirman el vector por escrito en el chat
- [ ] Una sola subida, captura al grupo
- [ ] Los 4 asisten los días 27 y 29

---

## Comandos MATLAB de emergencia

```matlab
% Recuperar el mejor vector actual
load('pipeline_v2.mat','gaTeam'); disp(gaTeam)

% Regenerar todo el pipeline
[team01, team02, stats] = generateFinalTeams();

% Validar ANTES de subir (obligatorio)
[ok, msg] = validateTeam(team); disp(ok); disp(msg)

% Ver la sensibilidad
load('sensitivity_baseline.mat'); disp(100*results.deltas)

% Limpiar y empezar de cero
clear all; clc; rehash;
```

## Contacto de dudas

- Dudas técnicas de MATLAB / IO: preguntar a Claude (escribir en la carpeta del proyecto con el CLI `claude`).
- Dudas del enunciado: martes 15 h en despacho del profe O miércoles 15 min finales de clase.
- **NO preguntar por correo** (el profe dijo expresamente que no responde).

## Enlaces clave

- [README.md](README.md) — índice general del repo
- [CLAUDE.md](CLAUDE.md) — instrucciones Claude + modo niño + 13 lecciones aprendidas
- [RESULTADOS_DIA1.md](RESULTADOS_DIA1.md) — tabla de progreso
- [TRAMPAS_DETECTADAS.md](TRAMPAS_DETECTADAS.md) — 10 trampas del PDF
- [AUDITORIA_HONESTA.md](AUDITORIA_HONESTA.md) — qué sabemos / suponemos / ignoramos
