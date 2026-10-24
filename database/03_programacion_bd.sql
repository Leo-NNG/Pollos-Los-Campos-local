-- =====================================================================
--  Archivo 3 de 3: PROGRAMACIÓN EN BASE DE DATOS
--  Vistas, triggers, función y procedimientos almacenados
-- =====================================================================
USE pollos_los_campos;

-- ------------------------------ VISTAS --------------------------------
CREATE OR REPLACE VIEW vw_menu AS
SELECT p.id, p.nombre, p.descripcion, p.precio, p.etiqueta, p.destacado,
       c.nombre AS categoria
FROM productos p
JOIN categorias c ON c.id = p.categoria_id
WHERE p.disponible = 1 AND c.activo = 1;

CREATE OR REPLACE VIEW vw_pedidos_resumen AS
SELECT pe.id, pe.codigo_pedido, CONCAT(pe.nombre_cliente,' ',COALESCE(pe.apellidos_cliente,'')) AS cliente,
       pe.telefono, pe.tipo_entrega, pe.metodo_pago, pe.estado, pe.total, pe.fecha_creacion,
       COUNT(d.id) AS items, COALESCE(SUM(d.cantidad),0) AS unidades
FROM pedidos pe
LEFT JOIN detalle_pedidos d ON d.pedido_id = pe.id
GROUP BY pe.id;

CREATE OR REPLACE VIEW vw_ventas_por_producto AS
SELECT pr.id, pr.nombre, c.nombre AS categoria,
       COALESCE(SUM(d.cantidad),0) AS unidades_vendidas,
       COALESCE(SUM(d.subtotal),0) AS ingresos
FROM productos pr
JOIN categorias c ON c.id = pr.categoria_id
LEFT JOIN detalle_pedidos d ON d.producto_id = pr.id
LEFT JOIN pedidos pe ON pe.id = d.pedido_id AND pe.estado <> 'CANCELADO'
GROUP BY pr.id, pr.nombre, c.nombre;

-- ------------------------------ FUNCIÓN -------------------------------
DROP FUNCTION IF EXISTS fn_codigo_pedido;
DELIMITER $$
CREATE FUNCTION fn_codigo_pedido() RETURNS VARCHAR(40) NOT DETERMINISTIC
BEGIN
  RETURN CONCAT('PLC-', UPPER(SUBSTRING(REPLACE(UUID(),'-',''),1,8)));
END$$
DELIMITER ;

-- ------------------------------ TRIGGERS ------------------------------
DROP TRIGGER IF EXISTS trg_usuarios_bi;
DROP TRIGGER IF EXISTS trg_detalle_bi;
DROP TRIGGER IF EXISTS trg_pedidos_bu;
DELIMITER $$

-- Normaliza el correo (minúsculas, sin espacios) antes de insertar.
CREATE TRIGGER trg_usuarios_bi BEFORE INSERT ON usuarios
FOR EACH ROW
BEGIN
  SET NEW.correo = LOWER(TRIM(NEW.correo));
END$$

-- Impide vender productos no disponibles y fija el subtotal de la línea.
CREATE TRIGGER trg_detalle_bi BEFORE INSERT ON detalle_pedidos
FOR EACH ROW
BEGIN
  IF (SELECT disponible FROM productos WHERE id = NEW.producto_id) = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El producto no está disponible';
  END IF;
  SET NEW.subtotal = NEW.cantidad * NEW.precio_unitario;
END$$

-- Controla el flujo de estados del pedido (sin retrocesos) y fecha de actualización.
CREATE TRIGGER trg_pedidos_bu BEFORE UPDATE ON pedidos
FOR EACH ROW
BEGIN
  DECLARE v_old INT; DECLARE v_new INT;
  IF NEW.estado <> OLD.estado THEN
    IF OLD.estado IN ('ENTREGADO','CANCELADO') THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El pedido ya está finalizado y no puede cambiar de estado';
    END IF;
    SET v_old = FIELD(OLD.estado,'RECIBIDO','CONFIRMADO','EN_PREPARACION','LISTO','EN_CAMINO','ENTREGADO');
    SET v_new = FIELD(NEW.estado,'RECIBIDO','CONFIRMADO','EN_PREPARACION','LISTO','EN_CAMINO','ENTREGADO');
    IF NEW.estado <> 'CANCELADO' AND v_new < v_old THEN
      SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No se permite retroceder el estado del pedido';
    END IF;
  END IF;
  SET NEW.fecha_actualizacion = NOW();
END$$
DELIMITER ;

-- ------------------------ PROCEDIMIENTOS ALMACENADOS ------------------
DROP PROCEDURE IF EXISTS sp_crear_pedido;
DROP PROCEDURE IF EXISTS sp_agregar_detalle;
DROP PROCEDURE IF EXISTS sp_cambiar_estado_pedido;
DROP PROCEDURE IF EXISTS sp_reporte_ventas;
DROP PROCEDURE IF EXISTS sp_seguimiento_pedido;
DELIMITER $$

-- Crea la cabecera de un pedido (delivery S/ 5.00 si corresponde).
CREATE PROCEDURE sp_crear_pedido(
  IN  p_usuario_id BIGINT, IN p_nombre VARCHAR(80), IN p_apellidos VARCHAR(80),
  IN  p_correo VARCHAR(120), IN p_telefono VARCHAR(20), IN p_direccion VARCHAR(180),
  IN  p_referencia VARCHAR(120), IN p_tipo_entrega VARCHAR(20), IN p_metodo_pago VARCHAR(20),
  IN  p_notas VARCHAR(250),
  OUT p_pedido_id BIGINT, OUT p_codigo VARCHAR(40))
BEGIN
  DECLARE v_delivery DECIMAL(10,2) DEFAULT 0;
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN ROLLBACK; RESIGNAL; END;
  IF p_tipo_entrega = 'DELIVERY' THEN SET v_delivery = 5.00; END IF;
  SET p_codigo = fn_codigo_pedido();
  START TRANSACTION;
  INSERT INTO pedidos (codigo_pedido, usuario_id, nombre_cliente, apellidos_cliente, correo_cliente,
                       telefono, direccion, referencia, tipo_entrega, metodo_pago,
                       subtotal, delivery, total, notas)
  VALUES (p_codigo, p_usuario_id, p_nombre, p_apellidos, p_correo, p_telefono, p_direccion,
          p_referencia, p_tipo_entrega, p_metodo_pago, 0, v_delivery, v_delivery, p_notas);
  SET p_pedido_id = LAST_INSERT_ID();
  COMMIT;
END$$

-- Agrega (o acumula) un producto al pedido con el precio vigente y recalcula totales.
CREATE PROCEDURE sp_agregar_detalle(IN p_pedido_id BIGINT, IN p_producto_id BIGINT, IN p_cantidad INT)
BEGIN
  DECLARE v_precio DECIMAL(10,2);
  DECLARE v_estado VARCHAR(25);
  DECLARE EXIT HANDLER FOR SQLEXCEPTION
  BEGIN ROLLBACK; RESIGNAL; END;
  SELECT precio INTO v_precio FROM productos WHERE id = p_producto_id;
  SELECT estado INTO v_estado FROM pedidos WHERE id = p_pedido_id;
  IF v_precio IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Producto inexistente'; END IF;
  IF v_estado IS NULL THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pedido inexistente'; END IF;
  IF v_estado <> 'RECIBIDO' THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Solo se editan pedidos en estado RECIBIDO'; END IF;
  START TRANSACTION;
  INSERT INTO detalle_pedidos (pedido_id, producto_id, cantidad, precio_unitario, subtotal)
  VALUES (p_pedido_id, p_producto_id, p_cantidad, v_precio, p_cantidad * v_precio)
  ON DUPLICATE KEY UPDATE cantidad = cantidad + VALUES(cantidad),
                          subtotal = (cantidad + VALUES(cantidad)) * precio_unitario;
  UPDATE detalle_pedidos SET subtotal = cantidad * precio_unitario
   WHERE pedido_id = p_pedido_id AND producto_id = p_producto_id;
  UPDATE pedidos
     SET subtotal = (SELECT SUM(subtotal) FROM detalle_pedidos WHERE pedido_id = p_pedido_id),
         total    = (SELECT SUM(subtotal) FROM detalle_pedidos WHERE pedido_id = p_pedido_id) + delivery
   WHERE id = p_pedido_id;
  COMMIT;
END$$

-- Cambia el estado de un pedido (las reglas las valida el trigger trg_pedidos_bu).
CREATE PROCEDURE sp_cambiar_estado_pedido(IN p_pedido_id BIGINT, IN p_nuevo_estado VARCHAR(25))
BEGIN
  UPDATE pedidos SET estado = p_nuevo_estado WHERE id = p_pedido_id;
  IF ROW_COUNT() = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pedido inexistente o estado sin cambios';
  END IF;
END$$

-- Reporte de ventas por rango de fechas (excluye pedidos cancelados).
CREATE PROCEDURE sp_reporte_ventas(IN p_desde DATE, IN p_hasta DATE)
BEGIN
  SELECT DATE(fecha_creacion) AS dia, COUNT(*) AS pedidos, SUM(total) AS ingresos,
         ROUND(AVG(total),2) AS ticket_promedio
  FROM pedidos
  WHERE estado <> 'CANCELADO' AND DATE(fecha_creacion) BETWEEN p_desde AND p_hasta
  GROUP BY DATE(fecha_creacion) ORDER BY dia;
END$$

-- Seguimiento por código + teléfono (igual que la pantalla /seguimiento).
CREATE PROCEDURE sp_seguimiento_pedido(IN p_codigo VARCHAR(40), IN p_telefono VARCHAR(20))
BEGIN
  SELECT codigo_pedido, estado, tipo_entrega, total, fecha_creacion, fecha_actualizacion
  FROM pedidos WHERE codigo_pedido = p_codigo AND telefono = p_telefono;
END$$
DELIMITER ;
