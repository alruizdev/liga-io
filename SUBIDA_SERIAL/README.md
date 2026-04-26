# SUBIDA_SERIAL — carpeta de subida pendiente del serial real

Esta carpeta queda **vacía** hasta que el profesor asigne los seriales reales (por ejemplo `42` y `43`). Solo se generan archivos aquí en el momento de la subida, con el serial real.

> **Vectores congelados** (no se vuelven a tocar):
>
>     01 = [6  9  9  11  10  1  6  6  24  18]
>     02 = [8  7  9  10  11  1  2  6  29  17]

## Procedimiento el día de la entrega

Ejecutar desde la raíz del proyecto (`liga-io/`):

```matlab
RAIZ = pwd;                                  % ej. C:\...\liga-io
addpath(fullfile(RAIZ,'PROYECTO'));          % createTeamFile, lector, validateTeam
addpath(fullfile(RAIZ,'Pruebas_Ivan'));      % playMatch.p, binornd.m

% 1. Cargar los vectores congelados (siempre forzar 1x10 double)
S1 = load(fullfile(RAIZ,'ENTREGA_FINAL_CERRADA','01_final.mat'));
S2 = load(fullfile(RAIZ,'ENTREGA_FINAL_CERRADA','02_final.mat'));
v01 = double(S1.equipo(:)');
v02 = double(S2.equipo(:)');

% 2. Crear los archivos con el serial REAL en esta carpeta
SUBIDA = fullfile(RAIZ,'SUBIDA_SERIAL');
prev = pwd; cd(SUBIDA);
createTeamFile(v01, 'XX');                   % XX = primer serial real
createTeamFile(v02, 'YY');                   % YY = segundo serial (opcional)
cd(prev);

% 3. Verificar que lector lee dos vectores 1x10 en esta carpeta
prev = pwd; cd(SUBIDA);
[teams, names] = lector();
cd(prev);

% 4. Test funcional con playMatch oficial
[g1,g2] = playMatch(v01, 10*ones(1,10));
fprintf('test 01: %d-%d\n', g1, g2);
[g1,g2] = playMatch(v02, 10*ones(1,10));
fprintf('test 02: %d-%d\n', g1, g2);
```

## Qué se sube y qué NO

- **Sí**: solo `XX.mat` (y opcionalmente `YY.mat`), generados con el serial real por `createTeamFile`.
- **No**: ZIP del proyecto, código `.m`, archivos `.md`, `playMatch.p`, `lector.m`, ni los `_base.mat` / `_final.mat`.
- **Una sola subida**, coordinada por la persona designada.

## Importante

- Si el enunciado pide `.m` u otro formato distinto a `.mat`, **parar** y revisar antes de subir.
- Antes de subir, confirmar que el `playMatch.p` del Aula Virtual coincide en MD5 con `Pruebas_Ivan/playMatch.p` (`f6e1dce6bd0b71774f0ca15a448ad45b`). Si difiere, reabrir auditoría con `auditoriaCierre(opt)` (4-5 min).
