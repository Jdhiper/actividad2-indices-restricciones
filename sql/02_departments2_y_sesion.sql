-- =====================================================================
-- Actividad: Índices y restricciones en Oracle
-- Fichero 02: Tabla DEPARTMENTS2, inserciones y cierre de sesión
-- Autor: Juan Diego Zambrano Guerrero (223179011)
-- Conexión: HR (Nombre del servicio = xepdb1)
-- =====================================================================

ALTER SESSION SET CURRENT_SCHEMA = HR;
-- Columnas con el ancho justo en la Salida de script
SET SQLFORMAT ANSICONSOLE

-- Limpieza (permite repetir el ejercicio)
BEGIN
  EXECUTE IMMEDIATE 'DROP TABLE departments2 PURGE';
EXCEPTION WHEN OTHERS THEN NULL;
END;
/

-- ---------------------------------------------------------------------
-- Crear el duplicado DEPARTMENTS2
--   CREATE TABLE ... AS SELECT copia la estructura y los datos, pero
--   solo las restricciones NOT NULL: ni la clave primaria, ni las
--   foráneas, ni los índices.
-- ---------------------------------------------------------------------
CREATE TABLE departments2 AS SELECT * FROM departments;

SELECT COUNT(*) AS filas_departments2 FROM departments2;

SELECT table_name AS tabla, constraint_name AS restriccion,
       constraint_type AS tipo, search_condition_vc AS condicion
  FROM user_constraints
 WHERE table_name IN ('DEPARTMENTS','DEPARTMENTS2')
 ORDER BY table_name, constraint_type;

SELECT table_name AS tabla, index_name AS indice
  FROM user_indexes
 WHERE table_name IN ('DEPARTMENTS','DEPARTMENTS2')
 ORDER BY table_name;

-- ---------------------------------------------------------------------
-- Insertar tres tuplas (SIN hacer COMMIT)
-- ---------------------------------------------------------------------
INSERT INTO departments2 (department_id, department_name, manager_id, location_id)
VALUES (300, 'Inteligencia de Negocios', NULL, 1700);
INSERT INTO departments2 (department_id, department_name, manager_id, location_id)
VALUES (310, 'Ciberseguridad', NULL, 1700);
INSERT INTO departments2 (department_id, department_name, manager_id, location_id)
VALUES (320, 'Transformacion Digital', NULL, 2500);

SELECT COUNT(*) AS filas_en_mi_sesion FROM departments2;
SELECT * FROM departments2 WHERE department_id >= 300 ORDER BY department_id;

-- ---------------------------------------------------------------------
-- Otra sesión NO ve las tuplas sin confirmar
--   Consulta ejecutada desde una hoja no compartida, que abre una
--   sesión distinta de HR.
-- ---------------------------------------------------------------------
SELECT COUNT(*) AS filas_vistas_desde_otra_sesion FROM hr.departments2;

-- ---------------------------------------------------------------------
-- Cierre de sesión (Desconectar) sin confirmar los cambios y nueva
--   conexión de HR para consultar la tabla.
-- ---------------------------------------------------------------------
ALTER SESSION SET CURRENT_SCHEMA = HR;
SELECT COUNT(*) AS filas_despues_de_reconectar FROM departments2;
SELECT * FROM departments2 WHERE department_id >= 300;
