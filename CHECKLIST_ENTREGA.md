# Checklist de entrega — Liga IO 2026 (Interóptimo de Lagrange)

Lista única operativa para el día de la entrega. Ir paso a paso. Cada `[ ]` se marca cuando la persona designada confirma por el grupo.

> **Vectores congelados** (NO se vuelven a tocar):
>
>     01 = [6  9  9  11  10  1  6  6  24  18]
>     02 = [8  7  9  10  11  1  2  6  29  17]

---

## Pre-entrega (T-24 h)

- [ ] **Asistencia confirmada** de los 4 miembros para el 27 y el 29 de abril (sin ello no se cobran premios — PDF literal).
- [ ] Persona designada para subir el archivo: ____________________
- [ ] Confirmar que **NO se ha subido nada todavía**.

## Verificación del simulador (T-12 h)

- [ ] Descargar la última versión de `playMatch.p` del **Aula Virtual** y guardarla en una carpeta independiente, p.ej. `playMatch_aulavirtual\playMatch.p`.
- [ ] Calcular MD5 y compararlo con el que usamos en la auditoría (`f6e1dce6bd0b71774f0ca15a448ad45b`):
  ```matlab
  fid = fopen('playMatch_aulavirtual\playMatch.p','r');
  B = fread(fid,inf,'uint8=>uint8'); fclose(fid);
  md = java.security.MessageDigest.getInstance('MD5'); md.update(B);
  fprintf('MD5 = %s\n', sprintf('%02x', typecast(md.digest(),'uint8')));
  ```
- [ ] Si el MD5 coincide → seguir. Si **no** coincide:
  - [ ] Re-ejecutar `auditoriaCierre(opt)` con la nueva copia del `.p` (4-5 min).
  - [ ] Anotar cualquier desviación significativa en `VECTOR_FINAL_AUDIT_CERRADO.md`.

## Confirmación del serial real (T-1 h)

- [ ] Profesor ha publicado/enviado los seriales del grupo: serial 1 = ____ , serial 2 = ____.
- [ ] El nombre del archivo que acepta el profesor es: `XY.mat` (XY = serial, **archivo `.mat`, NO `.m`**). Confirmar formato exacto en el enunciado.
- [ ] **Si el enunciado pide `.m` u otro formato, parar y reabrir hilo con el grupo.** No asumir.

## Generación de los archivos finales (`SUBIDA_SERIAL/`)

Ejecutar exactamente este bloque desde la raíz del proyecto (`liga-io/`):

```matlab
%% Variables raíz
RAIZ = pwd;                                          % ej. C:\...\liga-io
PROYECTO = fullfile(RAIZ,'PROYECTO');
IVAN     = fullfile(RAIZ,'Pruebas_Ivan');
addpath(PROYECTO); addpath(IVAN);

%% Cargar los vectores congelados (siempre forzar 1x10 double)
S1 = load(fullfile(RAIZ,'ENTREGA_FINAL_CERRADA','01_final.mat'));
S2 = load(fullfile(RAIZ,'ENTREGA_FINAL_CERRADA','02_final.mat'));
v01 = double(S1.equipo(:)');
v02 = double(S2.equipo(:)');

%% Validar antes de generar
[ok1,m1] = validateTeam(v01); assert(ok1, ['v01 invalido: ' m1]);
[ok2,m2] = validateTeam(v02); assert(ok2, ['v02 invalido: ' m2]);

%% Crear los archivos en SUBIDA_SERIAL con el serial REAL
SUBIDA = fullfile(RAIZ,'SUBIDA_SERIAL');
prev = pwd; cd(SUBIDA);
createTeamFile(v01, 'XX');     % XX = primer serial
createTeamFile(v02, 'YY');     % YY = segundo serial (opcional)
cd(prev);
```

- [ ] Verificar que los archivos creados se llaman exactamente `XX.mat` y `YY.mat` (con los seriales reales) — sin sufijos ni extensiones distintas a `.mat`.
- [ ] Verificar contenido:
  ```matlab
  for n = ["XX","YY"]
      S = load(fullfile(SUBIDA, n + ".mat"));
      f = fieldnames(S); v = double(S.(f{1})(:)');
      [ok,msg] = validateTeam(v);
      fprintf('%s.mat ok=%d sum=%d min=%d %s\n', n, ok, sum(v), min(v), msg);
  end
  ```
  Debe imprimir `ok=1 sum=100 min=1` para los dos.

## Dry-run en carpeta limpia

- [ ] Ejecutar `lector` dentro de `SUBIDA_SERIAL/`:
  ```matlab
  prev = pwd; cd(SUBIDA);
  [teams, names] = lector();
  cd(prev);
  ```
  Debe leer **2 vectores 1×10** sin error. Si lector se queja, parar.

- [ ] Ejecutar dos partidos de prueba con el `playMatch` del Aula Virtual:
  ```matlab
  [g1,g2] = playMatch(v01, 10*ones(1,10)); fprintf('test 01: %d-%d\n', g1, g2);
  [g1,g2] = playMatch(v02, 10*ones(1,10)); fprintf('test 02: %d-%d\n', g1, g2);
  ```
  Debe devolver enteros sin error.

## Subida (qué SÍ y qué NO)

- [ ] Solo la persona designada sube los archivos.
- [ ] **Una única subida.** No reenvíos.
- [ ] **Solo se suben** los archivos `XX.mat` (y `YY.mat` si procede) generados por `createTeamFile` con el serial real.

> **Qué NO se sube** (dejarlo claro a todo el grupo):
>
> - **NO** se sube ZIP del proyecto.
> - **NO** se sube código `.m`.
> - **NO** se suben los archivos `.md` (auditoría, presentación, slides, checklist).
> - **NO** se sube `playMatch.p` ni `lector.m`.
> - **NO** se suben los `.mat` con sufijo `_base` o `_final`; solo el de serial real.

- [ ] Captura de pantalla del upload al grupo de WhatsApp/Telegram para confirmación.

## Post-entrega

- [ ] Los 4 miembros presentes el 27 y el 29.
- [ ] Defensa preparada con `SLIDES_PARTE_VECTOR.md` (4 slides, 5 minutos).
- [ ] Llevar impresa una hoja con los dos vectores y los resultados clave por si el profesor pregunta números concretos.

---

## Reglas duras (incumplir = 0 puntos en esa parte)

- Vector debe ser 1×10 entero, todos `>= 1`, suma en `[95, 100]`. Cualquier 0 = riesgo de descalificación silenciosa.
- Nombre del archivo debe ser **exactamente** el serial con extensión `.mat`. Errores de mayúsculas/extensión → fallo.
- Una sola subida. El profesor dijo literalmente *"no me escribas diciendo que te mandé el que no era"*.
