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
