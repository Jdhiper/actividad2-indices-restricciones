-- =====================================================================
-- Actividad: Índices y restricciones en Oracle
-- Fichero 04: Cómo deshacer una transacción (ROLLBACK y SAVEPOINT)
-- Autor: Juan Diego Zambrano Guerrero (223179011)
-- Conexión: HR (Nombre del servicio = xepdb1)
-- =====================================================================

ALTER SESSION SET CURRENT_SCHEMA = HR;
-- Columnas con el ancho justo en la Salida de script
SET SQLFORMAT ANSICONSOLE

-- ---------------------------------------------------------------------
-- ROLLBACK: deshace toda la transacción
-- ---------------------------------------------------------------------
SELECT COUNT(*) AS filas_antes FROM departments2;

DELETE FROM departments2 WHERE department_id > 100;
UPDATE departments2 SET location_id = 9999;

SELECT COUNT(*) AS filas_despues_del_delete FROM departments2;

ROLLBACK;

SELECT COUNT(*) AS filas_despues_del_rollback FROM departments2;
SELECT DISTINCT location_id FROM departments2 ORDER BY location_id;

-- ---------------------------------------------------------------------
-- SAVEPOINT + ROLLBACK TO: deshace solo una parte
-- ---------------------------------------------------------------------
INSERT INTO departments2 (department_id, department_name, manager_id, location_id)
VALUES (340, 'Calidad de Software', NULL, 1700);

SAVEPOINT despues_de_340;

INSERT INTO departments2 (department_id, department_name, manager_id, location_id)
VALUES (350, 'Departamento por error', NULL, 1700);

SELECT department_id, department_name FROM departments2
 WHERE department_id IN (340, 350) ORDER BY department_id;

ROLLBACK TO SAVEPOINT despues_de_340;
COMMIT;

SELECT department_id, department_name FROM departments2
 WHERE department_id IN (340, 350) ORDER BY department_id;
