-- =====================================================================
-- Actividad: Índices y restricciones en Oracle
-- Fichero 01: Índices y restricciones de EMPLOYEES y DEPARTMENTS
-- Autor: Juan Diego Zambrano Guerrero (223179011)
-- Conexión: HR (Nombre del servicio = xepdb1)
--
-- =====================================================================

ALTER SESSION SET CURRENT_SCHEMA = HR;
-- Columnas con el ancho justo en la Salida de script
SET SQLFORMAT ANSICONSOLE
SET SERVEROUTPUT ON

-- ---------------------------------------------------------------------
-- Sesión iniciada con el usuario HR
-- ---------------------------------------------------------------------
SELECT USER AS usuario,
       SYS_CONTEXT('USERENV','CON_NAME') AS base_de_datos,
       TO_CHAR(SYSDATE,'DD/MM/YYYY HH24:MI') AS fecha
  FROM dual;

-- ---------------------------------------------------------------------
-- Índices de EMPLOYEES y DEPARTMENTS
-- ---------------------------------------------------------------------
SELECT i.table_name   AS tabla,
       i.index_name   AS indice,
       i.uniqueness   AS unicidad,
       LISTAGG(c.column_name, ', ') WITHIN GROUP (ORDER BY c.column_position) AS columnas,
       i.status       AS estado
  FROM user_indexes i
  JOIN user_ind_columns c ON c.index_name = i.index_name
 WHERE i.table_name IN ('EMPLOYEES','DEPARTMENTS')
 GROUP BY i.table_name, i.index_name, i.uniqueness, i.status
 ORDER BY i.table_name, i.index_name;

-- ---------------------------------------------------------------------
-- Restricciones de EMPLOYEES y DEPARTMENTS (antes)
--   P = clave primaria, U = única, R = clave foránea, C = check / NOT NULL
-- ---------------------------------------------------------------------
SELECT table_name        AS tabla,
       constraint_name   AS restriccion,
       constraint_type   AS tipo,
       status            AS estado,
       validated         AS validada,
       r_constraint_name AS referencia
  FROM user_constraints
 WHERE table_name IN ('EMPLOYEES','DEPARTMENTS')
 ORDER BY table_name, constraint_type, constraint_name;

-- ---------------------------------------------------------------------
-- Desactivar las restricciones
--   Primero las claves foráneas, después checks/NOT NULL/únicas y al
--   final las claves primarias con CASCADE (también desactiva las FK de
--   otras tablas que apuntan a ellas, como las de JOB_HISTORY).
-- ---------------------------------------------------------------------
ALTER TABLE employees   DISABLE CONSTRAINT emp_dept_fk;
ALTER TABLE employees   DISABLE CONSTRAINT emp_job_fk;
ALTER TABLE employees   DISABLE CONSTRAINT emp_manager_fk;
ALTER TABLE departments DISABLE CONSTRAINT dept_loc_fk;
ALTER TABLE departments DISABLE CONSTRAINT dept_mgr_fk;

ALTER TABLE employees   DISABLE CONSTRAINT emp_salary_min;
ALTER TABLE employees   DISABLE CONSTRAINT emp_email_uk;
ALTER TABLE employees   DISABLE CONSTRAINT emp_last_name_nn;
ALTER TABLE employees   DISABLE CONSTRAINT emp_email_nn;
ALTER TABLE employees   DISABLE CONSTRAINT emp_hire_date_nn;
ALTER TABLE employees   DISABLE CONSTRAINT emp_job_nn;
ALTER TABLE departments DISABLE CONSTRAINT dept_name_nn;

ALTER TABLE employees   DISABLE CONSTRAINT emp_emp_id_pk CASCADE;
ALTER TABLE departments DISABLE CONSTRAINT dept_id_pk    CASCADE;

-- ---------------------------------------------------------------------
-- Estado después de desactivar: restricciones e índices
--   El índice EMP_EMAIL_UK desaparece (lo había creado la
--   restricción UNIQUE), pero EMP_EMP_ID_PK y DEPT_ID_PK siguen,
--   porque en HR esos índices se crearon aparte con CREATE UNIQUE INDEX.
-- ---------------------------------------------------------------------
SELECT table_name AS tabla, constraint_name AS restriccion,
       constraint_type AS tipo, status AS estado
  FROM user_constraints
 WHERE table_name IN ('EMPLOYEES','DEPARTMENTS','JOB_HISTORY')
 ORDER BY table_name, constraint_type, constraint_name;

SELECT table_name AS tabla, index_name AS indice, uniqueness AS unicidad
  FROM user_indexes
 WHERE table_name IN ('EMPLOYEES','DEPARTMENTS')
 ORDER BY table_name, index_name;

-- ---------------------------------------------------------------------
-- Insertar tuplas que NO cumplen las restricciones
--   (se aceptan porque las restricciones están desactivadas)
-- ---------------------------------------------------------------------
-- Departamento 9001: sin nombre (dept_name_nn), jefe 9999 y ubicación
-- 9999 que no existen (dept_mgr_fk, dept_loc_fk)
INSERT INTO departments (department_id, department_name, manager_id, location_id)
VALUES (9001, NULL, 9999, 9999);

-- Departamento 9002: ubicación 8888 que no existe (dept_loc_fk)
INSERT INTO departments (department_id, department_name, manager_id, location_id)
VALUES (9002, 'Departamento fantasma', NULL, 8888);

-- Empleado 9001: sin apellido (emp_last_name_nn), salario negativo
-- (emp_salary_min), jefe 9999 y departamento 9999 que no existen
-- (emp_manager_fk, emp_dept_fk)
INSERT INTO employees (employee_id, first_name, last_name, email, phone_number,
                       hire_date, job_id, salary, commission_pct, manager_id, department_id)
VALUES (9001, 'Juan', NULL, 'JPRUEBA', NULL,
        DATE '2026-11-22', 'IT_PROG', -500, NULL, 9999, 9999);

-- Empleado 9002: sin fecha de contratación (emp_hire_date_nn) y con un
-- puesto que no existe (emp_job_fk)
INSERT INTO employees (employee_id, first_name, last_name, email, phone_number,
                       hire_date, job_id, salary, commission_pct, manager_id, department_id)
VALUES (9002, 'Ana', 'Prueba', 'APRUEBA', NULL,
        NULL, 'NO_EXISTE', 1000, NULL, 100, 9001);

COMMIT;

SELECT department_id, department_name, manager_id, location_id
  FROM departments WHERE department_id >= 9000;

SELECT employee_id, first_name, last_name, email, hire_date, job_id,
       salary, manager_id, department_id
  FROM employees WHERE employee_id >= 9000;

-- ---------------------------------------------------------------------
-- Clave primaria duplicada (ORA-00001)
--   Aunque DEPT_ID_PK está desactivada, el índice único DEPT_ID_PK sigue
--   existiendo y es el que impide repetir el department_id 10.
-- ---------------------------------------------------------------------
INSERT INTO departments (department_id, department_name, manager_id, location_id)
VALUES (10, 'Departamento duplicado', NULL, 1700);

-- ---------------------------------------------------------------------
-- Volver a activar las restricciones (ENABLE = VALIDATE)
--   Las PK se activan sin problema. Las demás fallan porque Oracle
--   revisa los datos que ya existen y encuentra las tuplas inválidas:
--   ORA-02293 (check / NOT NULL) y ORA-02298 (clave foránea).
-- ---------------------------------------------------------------------
ALTER TABLE employees   ENABLE CONSTRAINT emp_emp_id_pk;
ALTER TABLE departments ENABLE CONSTRAINT dept_id_pk;

ALTER TABLE employees   ENABLE CONSTRAINT emp_salary_min;
ALTER TABLE employees   ENABLE CONSTRAINT emp_last_name_nn;
ALTER TABLE employees   ENABLE CONSTRAINT emp_hire_date_nn;
ALTER TABLE employees   ENABLE CONSTRAINT emp_dept_fk;
ALTER TABLE departments ENABLE CONSTRAINT dept_loc_fk;

-- ---------------------------------------------------------------------
-- Activar con ENABLE NOVALIDATE
--   La restricción queda activa para los datos NUEVOS, pero no revisa
--   los que ya existen. Así se restablecen todas aunque haya tuplas
--   inválidas guardadas.
-- ---------------------------------------------------------------------
ALTER TABLE employees   ENABLE NOVALIDATE CONSTRAINT emp_salary_min;
ALTER TABLE employees   ENABLE NOVALIDATE CONSTRAINT emp_last_name_nn;
ALTER TABLE employees   ENABLE NOVALIDATE CONSTRAINT emp_email_nn;
ALTER TABLE employees   ENABLE NOVALIDATE CONSTRAINT emp_hire_date_nn;
ALTER TABLE employees   ENABLE NOVALIDATE CONSTRAINT emp_job_nn;
ALTER TABLE employees   ENABLE            CONSTRAINT emp_email_uk;
ALTER TABLE employees   ENABLE NOVALIDATE CONSTRAINT emp_dept_fk;
ALTER TABLE employees   ENABLE NOVALIDATE CONSTRAINT emp_job_fk;
ALTER TABLE employees   ENABLE NOVALIDATE CONSTRAINT emp_manager_fk;
ALTER TABLE departments ENABLE NOVALIDATE CONSTRAINT dept_name_nn;
ALTER TABLE departments ENABLE NOVALIDATE CONSTRAINT dept_loc_fk;
ALTER TABLE departments ENABLE NOVALIDATE CONSTRAINT dept_mgr_fk;
ALTER TABLE job_history ENABLE            CONSTRAINT jhist_emp_fk;
ALTER TABLE job_history ENABLE            CONSTRAINT jhist_dept_fk;

SELECT table_name AS tabla, constraint_name AS restriccion,
       constraint_type AS tipo, status AS estado, validated AS validada
  FROM user_constraints
 WHERE table_name IN ('EMPLOYEES','DEPARTMENTS','JOB_HISTORY')
 ORDER BY table_name, constraint_type, constraint_name;

-- ---------------------------------------------------------------------
-- Comprobar que ya están activas (ORA-02290)
--   Un salario negativo nuevo ya no se acepta.
-- ---------------------------------------------------------------------
INSERT INTO employees (employee_id, first_name, last_name, email, phone_number,
                       hire_date, job_id, salary, commission_pct, manager_id, department_id)
VALUES (9003, 'Luis', 'Prueba', 'LPRUEBA', NULL,
        DATE '2026-11-22', 'IT_PROG', -1, NULL, 100, 60);

-- ---------------------------------------------------------------------
-- Dejar HR como estaba: borrar las tuplas inválidas y
--   validar todas las restricciones (ENABLE VALIDATE)
-- ---------------------------------------------------------------------
DELETE FROM employees   WHERE employee_id   IN (9001, 9002);
DELETE FROM departments WHERE department_id IN (9001, 9002);
COMMIT;

ALTER TABLE employees   ENABLE VALIDATE CONSTRAINT emp_salary_min;
ALTER TABLE employees   ENABLE VALIDATE CONSTRAINT emp_last_name_nn;
ALTER TABLE employees   ENABLE VALIDATE CONSTRAINT emp_email_nn;
ALTER TABLE employees   ENABLE VALIDATE CONSTRAINT emp_hire_date_nn;
ALTER TABLE employees   ENABLE VALIDATE CONSTRAINT emp_job_nn;
ALTER TABLE employees   ENABLE VALIDATE CONSTRAINT emp_dept_fk;
ALTER TABLE employees   ENABLE VALIDATE CONSTRAINT emp_job_fk;
ALTER TABLE employees   ENABLE VALIDATE CONSTRAINT emp_manager_fk;
ALTER TABLE departments ENABLE VALIDATE CONSTRAINT dept_name_nn;
ALTER TABLE departments ENABLE VALIDATE CONSTRAINT dept_loc_fk;
ALTER TABLE departments ENABLE VALIDATE CONSTRAINT dept_mgr_fk;

SELECT table_name AS tabla, constraint_name AS restriccion,
       constraint_type AS tipo, status AS estado, validated AS validada
  FROM user_constraints
 WHERE table_name IN ('EMPLOYEES','DEPARTMENTS','JOB_HISTORY')
 ORDER BY table_name, constraint_type, constraint_name;
