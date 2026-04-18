# EMPEZAR AQUÍ — Modo niño

Sin tecnicismos. Nadie se agobia.

## Lo primero: ¿qué estamos haciendo?

Vamos a entregarle al profe **una lista de 10 números** (nuestro equipo de fútbol) dentro de un archivo `.mat`. El profe mete ese archivo en su ordenador, simula una liga y nos da puntos según lo bien que juegue nuestro equipo.

Claude ya ha hecho el esqueleto: hay una "lista ganadora" de prueba que saca un 57% de victorias contra equipos al azar. Eso está bien, pero **no es suficiente** para un 9. Para subir nota hay que:

1. Comprobar que la lista va bien en el simulador OFICIAL del profe (no solo en el que hemos reescrito).
2. Dejar el ordenador toda una noche buscando una lista aún mejor.
3. Preparar una presentación de 5 minutos para defenderla el día de la entrega.

Cada uno de los 4 se encarga de una parte. Todos pueden empezar el domingo con 1-2 horas de trabajo y ya sentir que han aportado.

---

## PRIMERO: los 4, juntos (15 minutos)

Poneros en una llamada rápida y:

1. **Elegir roles**. Son 4, uno por persona:
   - **Analista** → entiende y explica "por qué" el equipo es bueno (matemático).
   - **Optimizador** → hace los cálculos largos en MATLAB.
   - **Validador** → prueba que el archivo `.mat` se abra correctamente (para no fallar el día D).
   - **Defensor** → prepara la presentación (slides + guion).

2. **Elegir quién sube el archivo el día 27**. Tiene que ser el Validador (es el que más sabe del formato). NO el Defensor.

3. **Abrir los 4 el [CLAUDE.md](CLAUDE.md) y leer solo la sección "MODO NIÑO"** (5 min). Te cuenta el proyecto como si fuera un FIFA.

Y ya está la reunión. Al curro.

---

## 🧠 Si eres el ANALISTA

**Tu papel en una frase**: explicar al profe POR QUÉ nuestro equipo funciona. Sin esto, la presentación vale 0.15 puntos. Contigo, vale hasta 2.

### Primer día (domingo, 1 hora)

**Paso 1** — Abre MATLAB y pon esto (copia-pega):
```matlab
cd('c:\Users\angee\Downloads\IO - PREPARACION MAYO\PROYECTO LIGA IO\liga-io\PROYECTO')
load('sensitivity_baseline.mat')
disp(results.deltas * 100)
```

Esto te enseña **un ranking**: qué parámetro de los 10 hace ganar más partidos al subirlo. Los números son porcentajes de mejora.

Resultado ya calculado:
1. **Eficacia** → +11.2% (el que más)
2. **Técnico** → +7.3%
3. Juego Directo → +2.6%
4. Posesión → +1.7%
5. Organización Defensiva → +0.7%
- (los otros 5 son negativos — subirlos empeora)

**Paso 2** — Ahora crea un archivo llamado `DEFENSA_BORRADOR.md` en la carpeta raíz del proyecto (al lado del README). Escribe medio folio explicando:

> *"Eficacia y Técnico son los parámetros dominantes. Eficacia entra directamente en la fórmula de probabilidad de gol. Técnico multiplica todos los demás factores del equipo. Por eso un equipo con EF=24 y TE=18 gana más que un equipo balanceado en todo."*

Puedes mirar el archivo `playMatchOpen.m` y buscar "`A(9)`" (es Eficacia) y "`A(10)`" (es Técnico) para ver dónde aparecen. No hace falta entender las fórmulas — solo señalarlo.

**Paso 3** — Comparte tu medio folio con el grupo. Sirve para la slide 3 de la defensa.

### Segundo día (martes, 1 hora)

Recalcula el ranking pero alrededor del mejor equipo actual (no del equipo aburrido `[10 10 10...]`). Copia-pega:
```matlab
cd('c:\Users\angee\Downloads\IO - PREPARACION MAYO\PROYECTO LIGA IO\liga-io\PROYECTO')
load('pipeline_v2.mat','gaTeam')
results_ga = sensitivityAnalysis(gaTeam, 200, 30);
save('sensitivity_ga.mat','results_ga')
```
Tarda 1 minuto. Al final escribe 2 líneas en el chat diciendo si el ranking ha cambiado o no.

**Y ya.** Con eso has hecho tu parte del domingo y martes.

---

## ⚙️ Si eres el OPTIMIZADOR

**Tu papel en una frase**: ejecutas los programas que buscan la mejor lista de 10 números. Tu ordenador es el que trabaja, tú le pones a ejecutar.

### Primer día (domingo, 15 min de trabajo real + 15 min de espera)

**Paso 1** — Abre MATLAB y ejecuta:
```matlab
cd('c:\Users\angee\Downloads\IO - PREPARACION MAYO\PROYECTO LIGA IO\liga-io\PROYECTO')
[team01, team02, stats] = generateFinalTeams('', '', false);
```

Esto es una "tanda de cálculos". El ordenador busca buenos equipos durante ~10-15 minutos. No lo uses para otra cosa pesada mientras.

**Paso 2** — Cuando termine, copia y pega al chat del grupo los 2 equipos que salgan, sus win-rates y sus estadísticas de goles.

### Martes por la noche (10 min de trabajo + toda la noche de espera)

Esto es lo que llamamos "**GA overnight**". Es un inglesismo que suena raro pero significa solo esto: **dejas el ordenador encendido toda la noche ejecutando el algoritmo**.

¿Por qué? El algoritmo genético (GA) prueba miles de combinaciones. Cuantas más pruebe, mejor es el equipo que encuentra. En 10 minutos prueba unas pocas. En 8 horas prueba muchas más y encuentra una lista todavía mejor.

**Paso 1** — Antes de irte a dormir, en MATLAB:
```matlab
cd('c:\Users\angee\Downloads\IO - PREPARACION MAYO\PROYECTO LIGA IO\liga-io\PROYECTO')
rng(2026);
gaOpts.popSize=300; gaOpts.generations=300;
gaOpts.nRivals=150; gaOpts.nMatches=30; gaOpts.verbose=true;
[gaLong, ~, ~] = geneticAlgorithm(gaOpts);

saOpts.maxIter=20000; saOpts.T0=4; saOpts.alpha=0.9995;
saOpts.nRivals=150; saOpts.nMatches=30; saOpts.verbose=true;
[saLong, ~, ~] = simulatedAnnealing(gaLong, saOpts);

[wr,~,~,gf,ga] = evaluateTeam(saLong, 500, 100);
fprintf('LARGO: [%s] Win=%.1f%%\n', num2str(saLong), 100*wr);
save('pipeline_largo.mat','gaLong','saLong','wr')
```

**Paso 2** — Dale a ENTER. Deja el portátil **enchufado a la corriente** y la pantalla **sin apagar** (dentro de la configuración de energía, que no se suspenda). Vete a dormir.

**Paso 3** — Por la mañana, mira el resultado:
```matlab
load('pipeline_largo.mat')
disp(saLong)
fprintf('Win rate: %.1f%%\n', 100*wr)
```

Si sale más de 58%, hemos mejorado. Escríbelo en el chat.

### Jueves (30 min)

Coge todos los candidatos que tengamos (como unos 4-5) y hazlos jugar entre ellos para ver cuál es el mejor. Eso se llama un "mini-torneo". El script está en la guía del equipo. Luego anuncias el ganador.

**Y ya.** Tu papel es básicamente "el que tiene el portátil encendido por las noches".

---

## 🔍 Si eres el VALIDADOR

**Tu papel en una frase**: te aseguras de que el archivo `.mat` que entregamos el día 27 **funcione bien en el ordenador del profe**. Si falla, nos descalifican y vamos a 0. Es el papel más crítico del día D.

### Primer día (domingo, 1 hora)

**Paso 1** — Un ensayo general de subir el archivo. En MATLAB:
```matlab
cd('c:\Users\angee\Downloads\IO - PREPARACION MAYO\PROYECTO LIGA IO\liga-io\PROYECTO')
load('pipeline_v2.mat','gaTeam')
createTeamFile(gaTeam, '99')
```

Esto crea un archivo de prueba llamado `99.mat` (usamos el `99` porque NO es nuestro serial real — el serial real lo da el profe).

**Paso 2** — Simula que eres el profe abriendo ese archivo:
```matlab
[teams, names] = lector();
disp(teams)
disp(names)
```

Si sale una fila de 10 números y el "99", GENIAL. Si no, hay problema. Avísanos.

**Paso 3** — Limpia el archivo de prueba para no ensuciar la carpeta:
```matlab
delete('99.mat')
```

### Segundo día (lunes, 2 horas) — cuando el profe suba `playMatch.p`

El profe va a subir al Aula Virtual un archivo llamado `playMatch.p`. Eso es su **simulador OFICIAL**. Nosotros estuvimos usando una copia nuestra (`playMatchOpen.m`) para optimizar. Ahora hay que comprobar si la copia nuestra da los mismos resultados que el del profe.

**Por qué importa**: si nuestra copia dice "este equipo gana el 57%" pero el del profe dice "gana el 45%", hemos estado optimizando el equipo equivocado.

**Paso 1** — Descargar `playMatch.p` del Aula Virtual y ponerlo en la carpeta `PROYECTO/`.

**Paso 2** — Ejecuta esto en MATLAB:
```matlab
cd('c:\Users\angee\Downloads\IO - PREPARACION MAYO\PROYECTO LIGA IO\liga-io\PROYECTO')
load('pipeline_v2.mat','gaTeam')
rival = [10 10 10 10 10 10 10 10 10 10];

N = 1000;
rng(0); g_oficial = zeros(N,2);
for k=1:N, [g_oficial(k,1), g_oficial(k,2)] = playMatch(gaTeam, rival); end

rng(0); g_nuestro = zeros(N,2);
for k=1:N, [g_nuestro(k,1), g_nuestro(k,2)] = playMatchOpen(gaTeam, rival); end

wr_oficial = 100 * mean(g_oficial(:,1) > g_oficial(:,2));
wr_nuestro = 100 * mean(g_nuestro(:,1) > g_nuestro(:,2));

fprintf('Oficial: %.1f%% de victorias\n', wr_oficial)
fprintf('Nuestro: %.1f%% de victorias\n', wr_nuestro)
fprintf('Diferencia: %.1f puntos\n', abs(wr_oficial - wr_nuestro))
```

**Qué esperar**:
- Si la diferencia es **< 3 puntos** → genial, seguimos como vamos.
- Si la diferencia es **3-5 puntos** → aceptable pero vigilar.
- Si la diferencia es **> 5 puntos** → 🚨 **ALERTA**. Avisa al chat y a Claude. Hay que replantear.

### Viernes (1 hora) — preparar el archivo DEFINITIVO

Cuando el Optimizador tenga el equipo final, lo convertimos en el archivo que entregamos. **Usa el serial REAL que dio el profe** (no `99`, el que te asignó él):
```matlab
cd('c:\Users\angee\Downloads\IO - PREPARACION MAYO\PROYECTO LIGA IO\liga-io\PROYECTO')
load('pipeline_largo.mat','saLong')     % o el mejor equipo que tengamos
createTeamFile(saLong, '01')            % CAMBIA '01' por tu serial REAL
[teams, names] = lector();
disp(teams)
```

**Paso CRÍTICO**: antes de subir, comprueba el checklist del [GUIA_EQUIPO.md](GUIA_EQUIPO.md). **Una sola subida**, no hay reenvíos.

---

## 🎤 Si eres el DEFENSOR

**Tu papel en una frase**: preparar una presentación de **4 slides máximo, 5 minutos máximo** para el día 27. Sin slides, perdemos hasta 2 puntos de la nota.

### Primer día (domingo, 1-2 horas)

**Paso 1** — Lee [PROYECTO/JAVIER QUINTERO.md](PROYECTO/JAVIER%20QUINTERO.md) (es el perfil del profe, media página). Conviértete en la persona del grupo que "conoce" al profe.

**Paso 2** — Crea en la carpeta raíz un archivo llamado `DEFENSA_BORRADOR.md`. Mete solo los **títulos** de las 4 slides:

```markdown
# Defensa — Interóptimo de Lagrange

## Slide 1 — Portada
(Nombre del equipo, logo, los 4 miembros)

## Slide 2 — El problema
(En qué consiste: 10 números positivos, suma 95-100, una fórmula estocástica que simula partidos)

## Slide 3 — Nuestro método
(Sensibilidad → Crashing → Algoritmo Genético → Simulated Annealing → Monte Carlo)

## Slide 4 — El resultado
(Nuestro vector final + el porcentaje de victorias + 1 insight chulo que te llame la atención)
```

**Paso 3** — Guarda el logo en la carpeta raíz. Si lo tenéis en otro sitio, cópialo como `logo.png`.

**Y ya**. Eso es todo el domingo.

### Miércoles tras clase (1 hora)

Cuando volvamos del feedback del profe, actualiza el borrador con lo que él haya dicho.

### Jueves-viernes (2-3 horas)

Rellenar las 4 slides con contenido. Ideas de lo que NO pueden faltar:

**Slide 1 (portada)**:
- "Interóptimo de Lagrange"
- Logo
- Los 4 nombres
- Fecha y asignatura

**Slide 2 (el problema)**:
- "10 variables enteras positivas" (positivas = ≥ 1)
- "Suma entre 95 y 100"
- "Función objetivo estocástica, no lineal, no diferenciable" → esta frase en mates significa "no podemos usar derivadas para resolverla"
- "Espacio de búsqueda ~10¹² combinaciones" (un billón de posibilidades)

**Slide 3 (método)** — la más importante, con esta TABLA:

| Etapa | Técnica | % victoria |
|:---:|---|:---:|
| Punto de partida | Equipo aburrido `[10 10 ... 10]` | 40% |
| Análisis inicial | Sensibilidad numérica | (solo saca ranking) |
| Primera mejora | Crashing (Tema 2 del temario) | 50% |
| Algoritmo Genético | Metaheurística evolutiva | 57% |
| Refinamiento | Simulated Annealing | 58% |
| Validación final | Monte Carlo (500×100) | robustez confirmada |

**Slide 4 (resultado)**:
- Nuestro vector final (los 10 números) con los nombres encima: FI, GO, JD...
- Porcentaje de victoria final
- **UN INSIGHT**: "Descubrimos que subir 'Presión' empeora el win-rate, aunque parezca contraintuitivo — porque aumenta el cansancio del equipo."

### Viernes y sábado

Ensayo cronometrado 2-3 veces. **Si pasa de 5 minutos, corta**. El profe dijo literal: *"a los 5 minutos te digo siéntate, siguiente"*. Sin piedad.

---

## Qué palabras raras vas a oír

Para que no te pierdas cuando alguien las suelte en el chat:

| Palabra rara | Significado simple |
|---|---|
| **GA (Algoritmo Genético)** | Programa que "evoluciona" buenos equipos probando muchos y combinando los mejores. |
| **SA (Simulated Annealing)** | Programa que coge un buen equipo y le hace pequeños retoques para mejorarlo. |
| **Monte Carlo** | Jugar muchísimas veces el mismo partido para que el resultado sea fiable (porque el juego tiene suerte). |
| **Overnight** | Dejar el ordenador trabajando toda la noche. |
| **Calibrar** | Comprobar que dos cosas (nuestra copia del simulador y el oficial del profe) dan los mismos resultados. |
| **Dry-run** | Un ensayo general del día de la entrega, para no meter la pata. |
| **Sensibilidad** | Saber cuál de los 10 parámetros importa más. |
| **Serial** | El código de dos dígitos (ej: `07`) que nos da el profe para nombrar el archivo `.mat`. Si lo ponemos mal → 0. |
| **Descalificación automática** | Si el archivo está mal, nuestro equipo no juega la liga → 0 puntos. |
| **Presupuesto** | La suma total de los 10 números. Tiene que estar entre 95 y 100. |

---

## Flujo simplificado de toda la semana

```
DÍA 1 (sáb 18) → ya hecho por Claude ✅
DÍA 2 (dom 19) → los 4 roles hacen sus primeros pasos (1-2h cada uno)
DÍA 3 (lun 20) → Validador compara simuladores (URGENTE)
DÍA 4 (mar 21) → Optimizador deja GA overnight
DÍA 5 (mié 22) → CLASE con el profe, llevamos preguntas
DÍA 6 (jue 23) → mini-torneo entre candidatos + empezar slides
DÍA 7 (vie 24) → vector final, preparar .mat REAL, ensayos
DÍA 8 (sáb 25) → descanso + 2 ensayos
DÍA 9 (dom 26) → último chequeo
DÍA 10 (lun 27) → SUBIDA del archivo (UNA SOLA VEZ)
DÍA 11 (mar 28) → DEFENSA 5 min en clase
DÍA 12 (mié 29) → resultados
```

## Si te pierdes

- Mira [GUIA_EQUIPO.md](GUIA_EQUIPO.md) para detalles técnicos.
- Mira [CLAUDE.md](CLAUDE.md) sección MODO NIÑO para entender el proyecto de cero.
- Mira [AUDITORIA_HONESTA.md](AUDITORIA_HONESTA.md) para saber exactamente qué está hecho y qué no.
- Pregunta a Claude en el chat: abre terminal en la carpeta del proyecto y escribe `claude`.

**Todos podemos esto. Un 9 está a 9 días y unas pocas horas de trabajo bien repartido.**
