-- =====================================================================
--  POLLOS LOS CAMPOS - Script 5: DEMOSTRACIÓN DE ELIMINACIÓN LÓGICA
--  Uso en la exposición:
--    1) Ejecutar este script  (ANTES)
--    2) En la web (/admin/promociones) pulsar "Eliminar" en una promoción
--    3) Ejecutar este script de nuevo (DESPUÉS) y comparar
--  La fila NO desaparece: solo cambia la bandera (activa / disponible / activo).
-- =====================================================================
USE pollos_los_campos;

-- 1. Resumen: las filas totales no cambian, las "activas" disminuyen
SELECT 'promociones' AS tabla, COUNT(*) AS filas_totales, SUM(activa)     AS activas, COUNT(*) - SUM(activa)     AS eliminadas_logicamente FROM promociones
UNION ALL
SELECT 'productos',            COUNT(*),                  SUM(disponible), COUNT(*) - SUM(disponible)                                      FROM productos
UNION ALL
SELECT 'categorias',           COUNT(*),                  SUM(activo),     COUNT(*) - SUM(activo)                                          FROM categorias
UNION ALL
SELECT 'usuarios',             COUNT(*),                  SUM(activo),     COUNT(*) - SUM(activo)                                          FROM usuarios;

-- 2. Detalle de promociones (activa = 0 significa eliminada lógicamente)
SELECT id, nombre, activa, stock, fecha_inicio, fecha_fin
FROM promociones
ORDER BY id;

-- 3. Lo que ve el cliente en el sitio (misma condición que PromocionRepository.vigentes)
SELECT id, nombre, precio_promocional
FROM promociones
WHERE activa = TRUE AND CURDATE() BETWEEN fecha_inicio AND fecha_fin
ORDER BY fecha_fin;

-- 4. (Opcional) Equivalente SQL de lo que hace el botón "Eliminar" / "Restaurar":
-- UPDATE promociones SET activa = FALSE WHERE id = 1;   -- eliminar (lógico)
-- UPDATE promociones SET activa = TRUE  WHERE id = 1;   -- restaurar
-- Un DELETE físico NO se usa en este proyecto para promociones, productos, categorías ni usuarios.
