# Actividad: Índices y restricciones en Oracle

**Estudiante:** Juan Diego Zambrano Guerrero (223179011)
**Asignatura:** Bases de Datos Avanzadas – UNIR

Trabajo con los índices y restricciones del esquema **HR** en Oracle Database
21c XE (PDB `XEPDB1`), usando SQL Developer. Continúa sobre el mismo entorno
del Laboratorio 1 (HR instalado con los scripts oficiales de Oracle).

## Ficheros

| Fichero | Conexión | Contenido |
| --- | --- | --- |
| `sql/01_indices_y_restricciones.sql` | HR | Índices y restricciones de EMPLOYEES y DEPARTMENTS; desactivarlas, insertar tuplas inválidas, reactivarlas (VALIDATE / NOVALIDATE) |
| `sql/02_departments2_y_sesion.sql` | HR | Duplicado DEPARTMENTS2, tres inserciones, cierre de sesión y consulta |
| `sql/03_transaccion_bloque_anonimo.sql` | HR | Bloque anónimo que marca inicio y fin de una transacción |
| `sql/04_deshacer_transaccion.sql` | HR | ROLLBACK y SAVEPOINT |
| `sql/05_archivos_redo.sql` | SYSTEM (xepdb1) y SYSTEM_CDB (SID xe) | Redo generado, modo ARCHIVELOG/NOARCHIVELOG, grupos de redo y log switch |


## Conexiones en SQL Developer

| Nombre | Usuario | Conexión |
| --- | --- | --- |
| HR | hr | localhost:1521, Nombre del servicio `xepdb1` |
| SYSTEM | system | localhost:1521, Nombre del servicio `xepdb1` |
| SYSTEM_CDB | system | localhost:1521, SID `xe` |
