-- =====================================================================
-- Actividad: Índices y restricciones en Oracle
-- Fichero 03: Bloque anónimo que marca el inicio y el fin de una
--             transacción sobre DEPARTMENTS2
-- Autor: Juan Diego Zambrano Guerrero (223179011)
-- Conexión: HR (Nombre del servicio = xepdb1)
--
-- En Oracle no existe BEGIN TRANSACTION: una transacción empieza sola
-- con la primera sentencia DML (o con SET TRANSACTION) y termina con
-- COMMIT o ROLLBACK, o de forma implícita con una sentencia DDL.
-- =====================================================================

ALTER SESSION SET CURRENT_SCHEMA = HR;
-- Columnas con el ancho justo en la Salida de script
SET SQLFORMAT ANSICONSOLE
SET SERVEROUTPUT ON

-- ---------------------------------------------------------------------
-- Bloque anónimo con inicio y fin de la transacción
-- ---------------------------------------------------------------------
DECLARE
  v_id_transaccion VARCHAR2(50);
  v_filas          NUMBER;
BEGIN
  COMMIT;  -- cierra cualquier transacción que hubiera quedado abierta

  -- INICIO de la transacción, con un nombre para identificarla
  SET TRANSACTION NAME 'tx_departments2';
  v_id_transaccion := DBMS_TRANSACTION.LOCAL_TRANSACTION_ID(TRUE);
  DBMS_OUTPUT.PUT_LINE('INICIO de la transaccion ' || v_id_transaccion ||
                       ' a las ' || TO_CHAR(SYSTIMESTAMP, 'HH24:MI:SS'));

  INSERT INTO departments2 (department_id, department_name, manager_id, location_id)
  VALUES (330, 'Analitica de Datos', NULL, 1700);
  DBMS_OUTPUT.PUT_LINE('  Insertado el departamento 330');

  UPDATE departments2
     SET department_name = 'Soporte TI'
   WHERE department_id = 230;
  v_filas := SQL%ROWCOUNT;
  DBMS_OUTPUT.PUT_LINE('  Actualizado(s) ' || v_filas || ' departamento(s)');

  -- FIN de la transacción
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('FIN de la transaccion ' || v_id_transaccion ||
                       ' con COMMIT a las ' || TO_CHAR(SYSTIMESTAMP, 'HH24:MI:SS'));
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('ERROR: ' || SQLERRM || ' -> se hizo ROLLBACK');
END;
/

SELECT department_id, department_name, location_id
  FROM departments2
 WHERE department_id IN (230, 330)
 ORDER BY department_id;
