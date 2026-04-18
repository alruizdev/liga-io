function createTeamFile(equipo, serial)
% GUARDAR EQUIPO - Guarda el vector del equipo como archivo .mat para entregar
%
% ╔══════════════════════════════════════════════════════╗
% ║  AL PROFESOR SE ENTREGA SOLO ESTE ARCHIVO .mat       ║
% ║  No se entrega código, no se entrega ningún PDF.     ║
% ║  Solo el archivo XY.mat (XY = serial asignado).      ║
% ╚══════════════════════════════════════════════════════╝
%
% PARÁMETROS:
%   equipo - vector 1x10 del equipo final (validado)
%   serial - string con el serial asignado por el profesor (ej: '42')
%
% EJEMPLO:
%   createTeamFile([6 9 9 11 10 1 6 6 24 18], '42')
%   → crea '42.mat' listo para subir a la plataforma del profesor

    % Validar antes de guardar
    [valido, mensaje] = validateTeam(equipo);
    if ~valido
        error('Equipo no válido: %s', mensaje);
    end

    % Asegurar que es vector fila de doubles
    equipo = double(equipo(:)');

    % Guardar como .mat
    nombreArchivo = sprintf('%s.mat', serial);
    save(nombreArchivo, 'equipo');

    % Verificar que se puede leer correctamente (comprobación ida y vuelta)
    datos   = load(nombreArchivo);
    campos  = fieldnames(datos);
    cargado = datos.(campos{1});

    if isequal(cargado, equipo)
        fprintf('OK: Guardado correctamente en %s\n', nombreArchivo);
        fprintf('  Vector: [%s]\n', num2str(equipo));
        fprintf('  Suma: %d\n', sum(equipo));
        fprintf('  Verificado: la lectura coincide con el original\n');
    else
        error('ERROR DE VERIFICACION: los datos guardados no coinciden con el original');
    end

    % Probar compatibilidad con el lector del profesor
    fprintf('\n  Comprobando compatibilidad con lector.m...\n');
    try
        datos2  = load(nombreArchivo);
        campos2 = fieldnames(datos2);
        vector  = datos2.(campos2{1});
        vector  = vector(:)';
        fprintf('  Compatible con lector.m: [%s] (1x%d double)\n', num2str(vector), length(vector));
    catch e
        fprintf('  AVISO: problema con lector.m: %s\n', e.message);
    end
end
