-- =====================================================================
-- Actividad: Índices y restricciones en Oracle
-- Fichero 05: Archivos de Redo
-- Autor: Juan Diego Zambrano Guerrero (223179011)
--
-- Conexiones de administrador:
--   Parte A -> SYSTEM, servicio xepdb1
--   Parte B -> SYSTEM_CDB, SID xe (raíz del contenedor; los archivos
--              redo pertenecen a toda la base de datos)
-- =====================================================================

-- Columnas con el ancho justo en la Salida de script
SET SQLFORMAT ANSICONSOLE

-- =====================================================================
-- PARTE A (conexión SYSTEM, servicio xepdb1)
-- ---------------------------------------------------------------------
-- Cada cambio genera redo: "redo size" antes y después de una
--   transacción. Oracle guarda el redo en una zona privada de la sesión
--   y lo pasa al log buffer (y a la estadística) al confirmar, por eso
--   se mide después del COMMIT. El UPDATE asigna a cada nombre su mismo
--   valor: los datos no cambian, pero Oracle registra el cambio igual.
-- ---------------------------------------------------------------------
SELECT n.name, s.value AS bytes_redo
  FROM v$mystat s JOIN v$statname n ON n.statistic# = s.statistic#
 WHERE n.name = 'redo size';

UPDATE hr.departments2 SET department_name = department_name;
COMMIT;

SELECT n.name, s.value AS bytes_redo
  FROM v$mystat s JOIN v$statname n ON n.statistic# = s.statistic#
 WHERE n.name = 'redo size';

-- =====================================================================
-- PARTE B (conexión SYSTEM_CDB, SID xe)
-- ---------------------------------------------------------------------
-- Modo de funcionamiento de la base de datos
--   NOARCHIVELOG: los grupos de redo se reutilizan en círculo y no se
--   guarda copia. ARCHIVELOG: antes de reutilizar un grupo se archiva.
-- ---------------------------------------------------------------------
SELECT name AS base_de_datos, log_mode AS modo, open_mode AS estado
  FROM v$database;

-- ---------------------------------------------------------------------
-- Grupos y archivos de redo
-- ---------------------------------------------------------------------
SELECT group#, sequence#, ROUND(bytes/1024/1024) AS mb, members,
       archived, status
  FROM v$log
 ORDER BY group#;

SELECT group#, type, member AS archivo
  FROM v$logfile
 ORDER BY group#;

-- ---------------------------------------------------------------------
-- Cambio de grupo (log switch)
--   El grupo CURRENT pasa al siguiente y la secuencia aumenta en 1.
-- ---------------------------------------------------------------------
ALTER SYSTEM SWITCH LOGFILE;

SELECT group#, sequence#, archived, status
  FROM v$log
 ORDER BY group#;

SELECT sequence#, TO_CHAR(first_time, 'DD/MM/YYYY HH24:MI:SS') AS inicio
  FROM v$log_history
 ORDER BY sequence# DESC
 FETCH FIRST 5 ROWS ONLY;
