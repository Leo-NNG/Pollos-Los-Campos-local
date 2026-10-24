-- =====================================================================
--  POLLOS LOS CAMPOS - Script de base de datos (MySQL 8 / MariaDB 10.5+)
--  Archivo 1 de 3: ESQUEMA (tablas, claves, índices, restricciones)
--  Curso: Marcos de Desarrollo Web - Avance 3 (APF3)
-- =====================================================================
DROP DATABASE IF EXISTS pollos_los_campos;
CREATE DATABASE pollos_los_campos CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE pollos_los_campos;

-- ---------------------------------------------------------------------
-- 1. USUARIOS  (clientes y administradores)
-- ---------------------------------------------------------------------
CREATE TABLE usuarios (
  id              BIGINT       NOT NULL AUTO_INCREMENT,
  nombres         VARCHAR(80)  NOT NULL,
  apellidos       VARCHAR(80)  NOT NULL,
  correo          VARCHAR(120) NOT NULL,
  password        VARCHAR(100) NOT NULL COMMENT 'Hash BCrypt',
  celular         VARCHAR(20)  NULL,
  rol             VARCHAR(20)  NOT NULL DEFAULT 'ROLE_CLIENTE',
  activo          BOOLEAN      NOT NULL DEFAULT TRUE,
  fecha_registro  DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_usuarios        PRIMARY KEY (id),
  CONSTRAINT uq_usuarios_correo UNIQUE (correo),
  CONSTRAINT ck_usuarios_rol    CHECK (rol IN ('ROLE_ADMIN','ROLE_CLIENTE')),
  CONSTRAINT ck_usuarios_correo CHECK (correo LIKE '%_@_%._%'),
  CONSTRAINT ck_usuarios_celular CHECK (celular IS NULL OR celular REGEXP '^[0-9]{9}$')
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 2. CATEGORIAS
-- ---------------------------------------------------------------------
CREATE TABLE categorias (
  id          BIGINT       NOT NULL AUTO_INCREMENT,
  nombre      VARCHAR(80)  NOT NULL,
  descripcion VARCHAR(255) NULL,
  activo      BOOLEAN      NOT NULL DEFAULT TRUE,
  CONSTRAINT pk_categorias        PRIMARY KEY (id),
  CONSTRAINT uq_categorias_nombre UNIQUE (nombre),
  CONSTRAINT ck_categorias_nombre CHECK (CHAR_LENGTH(TRIM(nombre)) > 0)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 3. PRODUCTOS
-- ---------------------------------------------------------------------
CREATE TABLE productos (
  id             BIGINT        NOT NULL AUTO_INCREMENT,
  nombre         VARCHAR(100)  NOT NULL,
  descripcion    VARCHAR(255)  NOT NULL,
  precio         DECIMAL(10,2) NOT NULL,
  imagen         VARCHAR(255)  NULL,
  categoria_id   BIGINT        NOT NULL,
  disponible     BOOLEAN       NOT NULL DEFAULT TRUE,
  destacado      BOOLEAN       NOT NULL DEFAULT FALSE,
  etiqueta       VARCHAR(50)   NULL,
  fecha_registro DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_productos           PRIMARY KEY (id),
  CONSTRAINT uq_productos_nombre    UNIQUE (nombre),
  CONSTRAINT fk_productos_categoria FOREIGN KEY (categoria_id) REFERENCES categorias (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT ck_productos_precio    CHECK (precio > 0)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 4. PROMOCIONES
-- ---------------------------------------------------------------------
CREATE TABLE promociones (
  id                 BIGINT        NOT NULL AUTO_INCREMENT,
  nombre             VARCHAR(120)  NOT NULL,
  descripcion        VARCHAR(255)  NULL,
  precio_anterior    DECIMAL(10,2) NULL,
  precio_promocional DECIMAL(10,2) NOT NULL,
  fecha_inicio       DATE          NOT NULL,
  fecha_fin          DATE          NOT NULL,
  imagen             VARCHAR(255)  NULL,
  stock              INT           NOT NULL DEFAULT 0,
  activa             BOOLEAN       NOT NULL DEFAULT TRUE,
  fecha_registro     DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_promociones        PRIMARY KEY (id),
  CONSTRAINT ck_promo_precio       CHECK (precio_promocional > 0),
  CONSTRAINT ck_promo_precio_ant   CHECK (precio_anterior IS NULL OR precio_anterior >= precio_promocional),
  CONSTRAINT ck_promo_fechas       CHECK (fecha_fin >= fecha_inicio),
  CONSTRAINT ck_promo_stock        CHECK (stock >= 0)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 5. PEDIDOS
-- ---------------------------------------------------------------------
CREATE TABLE pedidos (
  id                  BIGINT        NOT NULL AUTO_INCREMENT,
  codigo_pedido       VARCHAR(40)   NOT NULL,
  usuario_id          BIGINT        NULL COMMENT 'NULL = pedido de visitante',
  nombre_cliente      VARCHAR(80)   NOT NULL,
  apellidos_cliente   VARCHAR(80)   NULL,
  correo_cliente      VARCHAR(120)  NULL,
  telefono            VARCHAR(20)   NOT NULL,
  direccion           VARCHAR(180)  NULL,
  referencia          VARCHAR(120)  NULL,
  tipo_entrega        VARCHAR(20)   NOT NULL,
  metodo_pago         VARCHAR(20)   NOT NULL,
  subtotal            DECIMAL(10,2) NOT NULL DEFAULT 0,
  delivery            DECIMAL(10,2) NOT NULL DEFAULT 0,
  total               DECIMAL(10,2) NOT NULL DEFAULT 0,
  estado              VARCHAR(25)   NOT NULL DEFAULT 'RECIBIDO',
  fecha_creacion      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  fecha_actualizacion DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
  notas               VARCHAR(250)  NULL,
  CONSTRAINT pk_pedidos         PRIMARY KEY (id),
  CONSTRAINT uq_pedidos_codigo  UNIQUE (codigo_pedido),
  CONSTRAINT fk_pedidos_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios (id)
        ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT ck_pedidos_entrega CHECK (tipo_entrega IN ('DELIVERY','RECOJO')),
  CONSTRAINT ck_pedidos_pago    CHECK (metodo_pago IN ('EFECTIVO','YAPE','PLIN','TARJETA')),
  CONSTRAINT ck_pedidos_estado  CHECK (estado IN ('RECIBIDO','CONFIRMADO','EN_PREPARACION','LISTO','EN_CAMINO','ENTREGADO','CANCELADO')),
  CONSTRAINT ck_pedidos_montos  CHECK (subtotal >= 0 AND delivery >= 0 AND total = subtotal + delivery),
  CONSTRAINT ck_pedidos_telef   CHECK (telefono REGEXP '^[0-9]{9}$'),
  CONSTRAINT ck_pedidos_direc   CHECK (tipo_entrega <> 'DELIVERY' OR (direccion IS NOT NULL AND CHAR_LENGTH(TRIM(direccion)) > 0))
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 6. DETALLE_PEDIDOS
-- ---------------------------------------------------------------------
CREATE TABLE detalle_pedidos (
  id              BIGINT        NOT NULL AUTO_INCREMENT,
  pedido_id       BIGINT        NOT NULL,
  producto_id     BIGINT        NOT NULL,
  cantidad        INT           NOT NULL,
  precio_unitario DECIMAL(10,2) NOT NULL,
  subtotal        DECIMAL(10,2) NOT NULL,
  CONSTRAINT pk_detalle_pedidos   PRIMARY KEY (id),
  CONSTRAINT uq_detalle_pedido_producto UNIQUE (pedido_id, producto_id),
  CONSTRAINT fk_detalle_pedido    FOREIGN KEY (pedido_id)   REFERENCES pedidos (id)
        ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_detalle_producto  FOREIGN KEY (producto_id) REFERENCES productos (id)
        ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT ck_detalle_cantidad  CHECK (cantidad > 0),
  CONSTRAINT ck_detalle_precio    CHECK (precio_unitario > 0),
  CONSTRAINT ck_detalle_subtotal  CHECK (subtotal = cantidad * precio_unitario)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 7. DIRECCIONES
-- ---------------------------------------------------------------------
CREATE TABLE direcciones (
  id         BIGINT       NOT NULL AUTO_INCREMENT,
  usuario_id BIGINT       NOT NULL,
  direccion  VARCHAR(180) NOT NULL,
  referencia VARCHAR(120) NULL,
  distrito   VARCHAR(80)  NOT NULL,
  principal  BOOLEAN      NOT NULL DEFAULT FALSE,
  activa     BOOLEAN      NOT NULL DEFAULT TRUE,
  CONSTRAINT pk_direcciones         PRIMARY KEY (id),
  CONSTRAINT fk_direcciones_usuario FOREIGN KEY (usuario_id) REFERENCES usuarios (id)
        ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 8. CONTACTOS
-- ---------------------------------------------------------------------
CREATE TABLE contactos (
  id             BIGINT       NOT NULL AUTO_INCREMENT,
  nombre         VARCHAR(80)  NOT NULL,
  correo         VARCHAR(120) NULL,
  telefono       VARCHAR(20)  NULL,
  motivo         VARCHAR(60)  NOT NULL,
  mensaje        VARCHAR(500) NOT NULL,
  estado         VARCHAR(15)  NOT NULL DEFAULT 'NUEVO',
  fecha_creacion DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT pk_contactos        PRIMARY KEY (id),
  CONSTRAINT ck_contactos_estado CHECK (estado IN ('NUEVO','LEIDO','RESPONDIDO')),
  CONSTRAINT ck_contactos_msg    CHECK (CHAR_LENGTH(mensaje) >= 10)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- ÍNDICES (además de los generados por PK, UNIQUE y FK)
-- ---------------------------------------------------------------------
CREATE INDEX idx_productos_disponible   ON productos (disponible, destacado);
CREATE INDEX idx_productos_categoria    ON productos (categoria_id, precio);
CREATE INDEX idx_promociones_vigencia   ON promociones (activa, fecha_inicio, fecha_fin);
CREATE INDEX idx_pedidos_usuario        ON pedidos (usuario_id);
CREATE INDEX idx_pedidos_estado_fecha   ON pedidos (estado, fecha_creacion);
CREATE INDEX idx_pedidos_telefono       ON pedidos (telefono);
CREATE INDEX idx_detalle_producto       ON detalle_pedidos (producto_id);
CREATE INDEX idx_direcciones_usuario    ON direcciones (usuario_id, principal);
CREATE INDEX idx_contactos_estado_fecha ON contactos (estado, fecha_creacion);

--  Archivo 2 de 3: DATOS INICIALES (catálogo, usuarios y casos de prueba)
--  Admin: admin@pollosloscampos.local / Admin123!   (hash BCrypt)
--  Cliente: cliente@correo.com / Cliente123!        (hash BCrypt)

INSERT INTO usuarios (nombres, apellidos, correo, password, celular, rol) VALUES
('Administrador','Los Campos','admin@pollosloscampos.local','$2a$10$dIAGOMkC3IHadzB2VFE1xOJqLuVTf8RkvvTSKEbIVfbtriRBzAj4e','999111222','ROLE_ADMIN'),
('María','Torres Gómez','cliente@correo.com','$2a$10$6UMSPIT/HCQz0yWSXLQeaueJVaIwmeqn8bVpwxLryS.lF8wCtf1Rq','987654321','ROLE_CLIENTE');

INSERT INTO categorias (nombre, descripcion) VALUES
('Pollo a la Brasa','Especialidad de la casa'),
('Combos','Combos para compartir'),
('Parrillas','Opciones a la parrilla'),
('Acompañamientos','Papas, ensaladas y más'),
('Bebidas','Bebidas frías'),
('Postres','Dulces de la casa');

INSERT INTO productos (nombre, descripcion, precio, imagen, categoria_id, disponible, destacado, etiqueta) VALUES
('1/4 de Pollo','Cuarto de pollo a la brasa, papas y ensalada',18.90,'/images/productos/quarter.svg',(SELECT id FROM categorias WHERE nombre='Pollo a la Brasa'),1,1,'Más pedido'),
('1/2 Pollo','Medio pollo a la brasa, papas, ensalada y cremas',34.90,'/images/productos/half.svg',(SELECT id FROM categorias WHERE nombre='Pollo a la Brasa'),1,1,'Ideal para 2'),
('Pollo Entero','Pollo entero a la brasa con papas familiares, ensalada y cremas',64.90,'/images/productos/whole.svg',(SELECT id FROM categorias WHERE nombre='Pollo a la Brasa'),1,1,'Para compartir'),
('Combo Familiar','Pollo entero + papas familiares + ensalada + cremas',69.90,'/images/productos/combo.svg',(SELECT id FROM categorias WHERE nombre='Combos'),1,1,'Familiar'),
('Combo Personal','1/4 de pollo + papas + bebida personal',22.90,'/images/productos/combo.svg',(SELECT id FROM categorias WHERE nombre='Combos'),1,1,'Personal'),
('Alitas BBQ','8 alitas crocantes con salsa BBQ de la casa',22.90,'/images/productos/wings.svg',(SELECT id FROM categorias WHERE nombre='Parrillas'),1,1,'Nuevo'),
('Salchipapa','Papas doradas, hot dog, chorizo y huevo',18.90,'/images/productos/fries.svg',(SELECT id FROM categorias WHERE nombre='Acompañamientos'),1,0,'Favorito'),
('Papas Fritas','Porción de papas doradas',9.90,'/images/productos/fries.svg',(SELECT id FROM categorias WHERE nombre='Acompañamientos'),1,0,'Extra'),
('Ensalada','Ensalada fresca de la casa',7.90,'/images/productos/salad.svg',(SELECT id FROM categorias WHERE nombre='Acompañamientos'),1,0,'Ligero'),
('Inca Kola','Gaseosa familiar bien fría',10.50,'/images/productos/drink.svg',(SELECT id FROM categorias WHERE nombre='Bebidas'),1,0,'Clásica'),
('Coca Cola','Gaseosa familiar bien fría',10.50,'/images/productos/drink.svg',(SELECT id FROM categorias WHERE nombre='Bebidas'),1,0,'Clásica'),
('Agua','Agua embotellada',4.00,'/images/productos/drink.svg',(SELECT id FROM categorias WHERE nombre='Bebidas'),1,0,'Ligera'),
('Postre de la casa','Dulce para cerrar el pedido',8.50,'/images/productos/dessert.svg',(SELECT id FROM categorias WHERE nombre='Postres'),1,0,'Dulce');

INSERT INTO promociones (nombre, descripcion, precio_anterior, precio_promocional, fecha_inicio, fecha_fin, stock, activa) VALUES
('Combo Familiar Los Campos','Pollo entero + papas familiares + ensalada + cremas',74.90,69.90,CURDATE(),DATE_ADD(CURDATE(),INTERVAL 60 DAY),30,1),
('Combo Personal','Cuarto de pollo + papas + bebida personal',26.90,22.90,CURDATE(),DATE_ADD(CURDATE(),INTERVAL 45 DAY),50,1);

INSERT INTO direcciones (usuario_id, direccion, referencia, distrito, principal)
VALUES ((SELECT id FROM usuarios WHERE correo='cliente@correo.com'),'Av. Balta 450','Frente al parque','Chiclayo',1);

INSERT INTO contactos (nombre, correo, telefono, motivo, mensaje, estado) VALUES
('Luis Pérez','luis@correo.com','955123456','Consulta','¿Atienden los domingos por la noche?','NUEVO'),
('Ana Ruiz','ana@correo.com','944321987','Reclamo','El pedido llegó frío, deseo que lo revisen.','LEIDO');

-- =====================================================================
--  Archivo 3 de 3: PROGRAMACIÓN EN BASE DE DATOS
--  Vistas, triggers, función y procedimientos almacenados
-- =====================================================================

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
