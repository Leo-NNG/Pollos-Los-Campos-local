-- MySQL dump 10.13  Distrib 8.0.46, for Win64 (x86_64)
--
-- Host: localhost    Database: pollos_los_campos
-- ------------------------------------------------------
-- Server version	8.0.46

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Current Database: `pollos_los_campos`
--

/*!40000 DROP DATABASE IF EXISTS `pollos_los_campos`*/;

CREATE DATABASE /*!32312 IF NOT EXISTS*/ `pollos_los_campos` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci */ /*!80016 DEFAULT ENCRYPTION='N' */;

USE `pollos_los_campos`;

--
-- Table structure for table `categorias`
--

DROP TABLE IF EXISTS `categorias`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `categorias` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `nombre` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_categorias_nombre` (`nombre`),
  CONSTRAINT `ck_categorias_nombre` CHECK ((char_length(trim(`nombre`)) > 0))
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `categorias`
--

LOCK TABLES `categorias` WRITE;
/*!40000 ALTER TABLE `categorias` DISABLE KEYS */;
INSERT INTO `categorias` VALUES (1,'Pollo a la Brasa','Especialidad de la casa',1),(2,'Combos','Combos para compartir',1),(3,'Parrillas','Opciones a la parrilla',1),(4,'Acompañamientos','Papas, ensaladas y más',1),(5,'Bebidas','Bebidas frías',1),(6,'Postres','Dulces de la casa',1);
/*!40000 ALTER TABLE `categorias` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `contactos`
--

DROP TABLE IF EXISTS `contactos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `contactos` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `nombre` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `correo` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `telefono` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `motivo` varchar(60) COLLATE utf8mb4_unicode_ci NOT NULL,
  `mensaje` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `estado` varchar(15) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'NUEVO',
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_contactos_estado_fecha` (`estado`,`fecha_creacion`),
  CONSTRAINT `ck_contactos_estado` CHECK ((`estado` in (_utf8mb4'NUEVO',_utf8mb4'LEIDO',_utf8mb4'RESPONDIDO'))),
  CONSTRAINT `ck_contactos_msg` CHECK ((char_length(`mensaje`) >= 10))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `contactos`
--

LOCK TABLES `contactos` WRITE;
/*!40000 ALTER TABLE `contactos` DISABLE KEYS */;
INSERT INTO `contactos` VALUES (1,'Luis Pérez','luis@correo.com','955123456','Consulta','¿Atienden los domingos por la noche?','NUEVO','2026-10-24 19:36:23'),(2,'Ana Ruiz','ana@correo.com','944321987','Reclamo','El pedido llegó frío, deseo que lo revisen.','LEIDO','2026-10-24 19:36:23');
/*!40000 ALTER TABLE `contactos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `detalle_pedidos`
--

DROP TABLE IF EXISTS `detalle_pedidos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `detalle_pedidos` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `pedido_id` bigint NOT NULL,
  `producto_id` bigint NOT NULL,
  `cantidad` int NOT NULL,
  `precio_unitario` decimal(10,2) NOT NULL,
  `subtotal` decimal(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_detalle_pedido_producto` (`pedido_id`,`producto_id`),
  KEY `idx_detalle_producto` (`producto_id`),
  CONSTRAINT `fk_detalle_pedido` FOREIGN KEY (`pedido_id`) REFERENCES `pedidos` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_detalle_producto` FOREIGN KEY (`producto_id`) REFERENCES `productos` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `ck_detalle_cantidad` CHECK ((`cantidad` > 0)),
  CONSTRAINT `ck_detalle_precio` CHECK ((`precio_unitario` > 0)),
  CONSTRAINT `ck_detalle_subtotal` CHECK ((`subtotal` = (`cantidad` * `precio_unitario`)))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `detalle_pedidos`
--

LOCK TABLES `detalle_pedidos` WRITE;
/*!40000 ALTER TABLE `detalle_pedidos` DISABLE KEYS */;
INSERT INTO `detalle_pedidos` VALUES (1,1,12,1,4.00,4.00),(2,1,2,1,34.90,34.90);
/*!40000 ALTER TABLE `detalle_pedidos` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_detalle_bi` BEFORE INSERT ON `detalle_pedidos` FOR EACH ROW BEGIN
  IF (SELECT disponible FROM productos WHERE id = NEW.producto_id) = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El producto no está disponible';
  END IF;
  SET NEW.subtotal = NEW.cantidad * NEW.precio_unitario;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `direcciones`
--

DROP TABLE IF EXISTS `direcciones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `direcciones` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `usuario_id` bigint NOT NULL,
  `direccion` varchar(180) COLLATE utf8mb4_unicode_ci NOT NULL,
  `referencia` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `distrito` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `principal` tinyint(1) NOT NULL DEFAULT '0',
  `activa` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`id`),
  KEY `idx_direcciones_usuario` (`usuario_id`,`principal`),
  CONSTRAINT `fk_direcciones_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `direcciones`
--

LOCK TABLES `direcciones` WRITE;
/*!40000 ALTER TABLE `direcciones` DISABLE KEYS */;
INSERT INTO `direcciones` VALUES (1,2,'Av. Balta 450','Frente al parque','Chiclayo',1,1);
/*!40000 ALTER TABLE `direcciones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `pedidos`
--

DROP TABLE IF EXISTS `pedidos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `pedidos` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `codigo_pedido` varchar(40) COLLATE utf8mb4_unicode_ci NOT NULL,
  `usuario_id` bigint DEFAULT NULL COMMENT 'NULL = pedido de visitante',
  `nombre_cliente` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `apellidos_cliente` varchar(80) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `correo_cliente` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `telefono` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `direccion` varchar(180) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `referencia` varchar(120) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `tipo_entrega` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `metodo_pago` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL,
  `subtotal` decimal(10,2) NOT NULL DEFAULT '0.00',
  `delivery` decimal(10,2) NOT NULL DEFAULT '0.00',
  `total` decimal(10,2) NOT NULL DEFAULT '0.00',
  `estado` varchar(25) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'RECIBIDO',
  `fecha_creacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `fecha_actualizacion` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `notas` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_pedidos_codigo` (`codigo_pedido`),
  KEY `idx_pedidos_usuario` (`usuario_id`),
  KEY `idx_pedidos_estado_fecha` (`estado`,`fecha_creacion`),
  KEY `idx_pedidos_telefono` (`telefono`),
  CONSTRAINT `fk_pedidos_usuario` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `ck_pedidos_direc` CHECK (((`tipo_entrega` <> _utf8mb4'DELIVERY') or ((`direccion` is not null) and (char_length(trim(`direccion`)) > 0)))),
  CONSTRAINT `ck_pedidos_entrega` CHECK ((`tipo_entrega` in (_utf8mb4'DELIVERY',_utf8mb4'RECOJO'))),
  CONSTRAINT `ck_pedidos_estado` CHECK ((`estado` in (_utf8mb4'RECIBIDO',_utf8mb4'CONFIRMADO',_utf8mb4'EN_PREPARACION',_utf8mb4'LISTO',_utf8mb4'EN_CAMINO',_utf8mb4'ENTREGADO',_utf8mb4'CANCELADO'))),
  CONSTRAINT `ck_pedidos_montos` CHECK (((`subtotal` >= 0) and (`delivery` >= 0) and (`total` = (`subtotal` + `delivery`)))),
  CONSTRAINT `ck_pedidos_pago` CHECK ((`metodo_pago` in (_utf8mb4'EFECTIVO',_utf8mb4'YAPE',_utf8mb4'PLIN',_utf8mb4'TARJETA'))),
  CONSTRAINT `ck_pedidos_telef` CHECK (regexp_like(`telefono`,_utf8mb4'^[0-9]{9}$'))
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `pedidos`
--

LOCK TABLES `pedidos` WRITE;
/*!40000 ALTER TABLE `pedidos` DISABLE KEYS */;
INSERT INTO `pedidos` VALUES (1,'PLC-3F5544C6',NULL,'Leonardo','Diaz','leodiazcumpa1234@gmail.com','987654321',NULL,NULL,'RECOJO','EFECTIVO',38.90,0.00,38.90,'RECIBIDO','2026-10-24 19:46:44','2026-10-24 19:46:44',NULL);
/*!40000 ALTER TABLE `pedidos` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_pedidos_bu` BEFORE UPDATE ON `pedidos` FOR EACH ROW BEGIN
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `productos`
--

DROP TABLE IF EXISTS `productos`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `productos` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `nombre` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `precio` decimal(10,2) NOT NULL,
  `imagen` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `categoria_id` bigint NOT NULL,
  `disponible` tinyint(1) NOT NULL DEFAULT '1',
  `destacado` tinyint(1) NOT NULL DEFAULT '0',
  `etiqueta` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fecha_registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_productos_nombre` (`nombre`),
  KEY `idx_productos_disponible` (`disponible`,`destacado`),
  KEY `idx_productos_categoria` (`categoria_id`,`precio`),
  CONSTRAINT `fk_productos_categoria` FOREIGN KEY (`categoria_id`) REFERENCES `categorias` (`id`) ON DELETE RESTRICT ON UPDATE CASCADE,
  CONSTRAINT `ck_productos_precio` CHECK ((`precio` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `productos`
--

LOCK TABLES `productos` WRITE;
/*!40000 ALTER TABLE `productos` DISABLE KEYS */;
INSERT INTO `productos` VALUES (1,'1/4 de Pollo','Cuarto de pollo a la brasa, papas y ensalada',18.90,'/images/productos/quarter.svg',1,1,1,'Más pedido','2026-10-24 19:36:23'),(2,'1/2 Pollo','Medio pollo a la brasa, papas, ensalada y cremas',34.90,'/images/productos/half.svg',1,1,1,'Ideal para 2','2026-10-24 19:36:23'),(3,'Pollo Entero','Pollo entero a la brasa con papas familiares, ensalada y cremas',64.90,'/images/productos/whole.svg',1,1,1,'Para compartir','2026-10-24 19:36:23'),(4,'Combo Familiar','Pollo entero + papas familiares + ensalada + cremas',69.90,'/images/productos/combo.svg',2,1,1,'Familiar','2026-10-24 19:36:23'),(5,'Combo Personal','1/4 de pollo + papas + bebida personal',22.90,'/images/productos/combo.svg',2,1,1,'Personal','2026-10-24 19:36:23'),(6,'Alitas BBQ','8 alitas crocantes con salsa BBQ de la casa',22.90,'/images/productos/wings.svg',3,1,1,'Nuevo','2026-10-24 19:36:23'),(7,'Salchipapa','Papas doradas, hot dog, chorizo y huevo',18.90,'/images/productos/fries.svg',4,1,0,'Favorito','2026-10-24 19:36:23'),(8,'Papas Fritas','Porción de papas doradas',9.90,'/images/productos/fries.svg',4,1,0,'Extra','2026-10-24 19:36:23'),(9,'Ensalada','Ensalada fresca de la casa',7.90,'/images/productos/salad.svg',4,1,0,'Ligero','2026-10-24 19:36:23'),(10,'Inca Kola','Gaseosa familiar bien fría',10.50,'https://images.unsplash.com/photo-1613510506223-55083f3b68a0?auto=format&fit=crop&w=800&q=75',5,1,0,'Clásica','2026-10-24 19:36:23'),(11,'Coca Cola','Gaseosa familiar bien fría',10.50,'https://images.unsplash.com/photo-1514218953589-2d7d37efd2dc?auto=format&fit=crop&w=800&q=75',5,1,0,'Clásica','2026-10-24 19:36:23'),(12,'Agua','Agua embotellada',4.00,'https://images.unsplash.com/photo-1559839914-17aae19cec71?auto=format&fit=crop&w=800&q=75',5,1,0,'Ligera','2026-10-24 19:36:23'),(13,'Postre de la casa','Dulce para cerrar el pedido',8.50,'/images/productos/dessert.svg',6,1,0,'Dulce','2026-10-24 19:36:23');
/*!40000 ALTER TABLE `productos` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `promociones`
--

DROP TABLE IF EXISTS `promociones`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `promociones` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `nombre` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `descripcion` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `precio_anterior` decimal(10,2) DEFAULT NULL,
  `precio_promocional` decimal(10,2) NOT NULL,
  `fecha_inicio` date NOT NULL,
  `fecha_fin` date NOT NULL,
  `imagen` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `stock` int NOT NULL DEFAULT '0',
  `activa` tinyint(1) NOT NULL DEFAULT '1',
  `fecha_registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_promociones_vigencia` (`activa`,`fecha_inicio`,`fecha_fin`),
  CONSTRAINT `ck_promo_fechas` CHECK ((`fecha_fin` >= `fecha_inicio`)),
  CONSTRAINT `ck_promo_precio` CHECK ((`precio_promocional` > 0)),
  CONSTRAINT `ck_promo_precio_ant` CHECK (((`precio_anterior` is null) or (`precio_anterior` >= `precio_promocional`))),
  CONSTRAINT `ck_promo_stock` CHECK ((`stock` >= 0))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `promociones`
--

LOCK TABLES `promociones` WRITE;
/*!40000 ALTER TABLE `promociones` DISABLE KEYS */;
INSERT INTO `promociones` VALUES (1,'Combo Familiar Los Campos','Pollo entero + papas familiares + ensalada + cremas',74.90,69.90,'2026-10-24','2026-12-23',NULL,30,1,'2026-10-24 19:36:23'),(2,'Combo Personal','Cuarto de pollo + papas + bebida personal',26.90,22.90,'2026-10-24','2026-12-08',NULL,50,1,'2026-10-24 19:36:23');
/*!40000 ALTER TABLE `promociones` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `usuarios`
--

DROP TABLE IF EXISTS `usuarios`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `usuarios` (
  `id` bigint NOT NULL AUTO_INCREMENT,
  `nombres` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `apellidos` varchar(80) COLLATE utf8mb4_unicode_ci NOT NULL,
  `correo` varchar(120) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL COMMENT 'Hash BCrypt',
  `celular` varchar(20) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rol` varchar(20) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'ROLE_CLIENTE',
  `activo` tinyint(1) NOT NULL DEFAULT '1',
  `fecha_registro` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_usuarios_correo` (`correo`),
  CONSTRAINT `ck_usuarios_celular` CHECK (((`celular` is null) or regexp_like(`celular`,_utf8mb4'^[0-9]{9}$'))),
  CONSTRAINT `ck_usuarios_correo` CHECK ((`correo` like _utf8mb4'%_@_%._%')),
  CONSTRAINT `ck_usuarios_rol` CHECK ((`rol` in (_utf8mb4'ROLE_ADMIN',_utf8mb4'ROLE_CLIENTE')))
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `usuarios`
--

LOCK TABLES `usuarios` WRITE;
/*!40000 ALTER TABLE `usuarios` DISABLE KEYS */;
INSERT INTO `usuarios` VALUES (1,'Administrador','Los Campos','admin@pollosloscampos.local','$2a$10$dIAGOMkC3IHadzB2VFE1xOJqLuVTf8RkvvTSKEbIVfbtriRBzAj4e','999111222','ROLE_ADMIN',1,'2026-10-24 19:36:22'),(2,'María','Torres Gómez','cliente@correo.com','$2a$10$6UMSPIT/HCQz0yWSXLQeaueJVaIwmeqn8bVpwxLryS.lF8wCtf1Rq','987654321','ROLE_CLIENTE',1,'2026-10-24 19:36:22');
/*!40000 ALTER TABLE `usuarios` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `trg_usuarios_bi` BEFORE INSERT ON `usuarios` FOR EACH ROW BEGIN
  SET NEW.correo = LOWER(TRIM(NEW.correo));
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Temporary view structure for view `vw_menu`
--

DROP TABLE IF EXISTS `vw_menu`;
/*!50001 DROP VIEW IF EXISTS `vw_menu`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_menu` AS SELECT 
 1 AS `id`,
 1 AS `nombre`,
 1 AS `descripcion`,
 1 AS `precio`,
 1 AS `etiqueta`,
 1 AS `destacado`,
 1 AS `categoria`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_pedidos_resumen`
--

DROP TABLE IF EXISTS `vw_pedidos_resumen`;
/*!50001 DROP VIEW IF EXISTS `vw_pedidos_resumen`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_pedidos_resumen` AS SELECT 
 1 AS `id`,
 1 AS `codigo_pedido`,
 1 AS `cliente`,
 1 AS `telefono`,
 1 AS `tipo_entrega`,
 1 AS `metodo_pago`,
 1 AS `estado`,
 1 AS `total`,
 1 AS `fecha_creacion`,
 1 AS `items`,
 1 AS `unidades`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `vw_ventas_por_producto`
--

DROP TABLE IF EXISTS `vw_ventas_por_producto`;
/*!50001 DROP VIEW IF EXISTS `vw_ventas_por_producto`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_ventas_por_producto` AS SELECT 
 1 AS `id`,
 1 AS `nombre`,
 1 AS `categoria`,
 1 AS `unidades_vendidas`,
 1 AS `ingresos`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping events for database 'pollos_los_campos'
--

--
-- Dumping routines for database 'pollos_los_campos'
--
/*!50003 DROP FUNCTION IF EXISTS `fn_codigo_pedido` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` FUNCTION `fn_codigo_pedido`() RETURNS varchar(40) CHARSET utf8mb4 COLLATE utf8mb4_unicode_ci
    NO SQL
BEGIN
  RETURN CONCAT('PLC-', UPPER(SUBSTRING(REPLACE(UUID(),'-',''),1,8)));
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_agregar_detalle` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_agregar_detalle`(IN p_pedido_id BIGINT, IN p_producto_id BIGINT, IN p_cantidad INT)
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_cambiar_estado_pedido` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_cambiar_estado_pedido`(IN p_pedido_id BIGINT, IN p_nuevo_estado VARCHAR(25))
BEGIN
  UPDATE pedidos SET estado = p_nuevo_estado WHERE id = p_pedido_id;
  IF ROW_COUNT() = 0 THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Pedido inexistente o estado sin cambios';
  END IF;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_crear_pedido` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_crear_pedido`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_reporte_ventas` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_reporte_ventas`(IN p_desde DATE, IN p_hasta DATE)
BEGIN
  SELECT DATE(fecha_creacion) AS dia, COUNT(*) AS pedidos, SUM(total) AS ingresos,
         ROUND(AVG(total),2) AS ticket_promedio
  FROM pedidos
  WHERE estado <> 'CANCELADO' AND DATE(fecha_creacion) BETWEEN p_desde AND p_hasta
  GROUP BY DATE(fecha_creacion) ORDER BY dia;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 DROP PROCEDURE IF EXISTS `sp_seguimiento_pedido` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `sp_seguimiento_pedido`(IN p_codigo VARCHAR(40), IN p_telefono VARCHAR(20))
BEGIN
  SELECT codigo_pedido, estado, tipo_entrega, total, fecha_creacion, fecha_actualizacion
  FROM pedidos WHERE codigo_pedido = p_codigo AND telefono = p_telefono;
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Current Database: `pollos_los_campos`
--

USE `pollos_los_campos`;

--
-- Final view structure for view `vw_menu`
--

/*!50001 DROP VIEW IF EXISTS `vw_menu`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_menu` AS select `p`.`id` AS `id`,`p`.`nombre` AS `nombre`,`p`.`descripcion` AS `descripcion`,`p`.`precio` AS `precio`,`p`.`etiqueta` AS `etiqueta`,`p`.`destacado` AS `destacado`,`c`.`nombre` AS `categoria` from (`productos` `p` join `categorias` `c` on((`c`.`id` = `p`.`categoria_id`))) where ((`p`.`disponible` = 1) and (`c`.`activo` = 1)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_pedidos_resumen`
--

/*!50001 DROP VIEW IF EXISTS `vw_pedidos_resumen`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_pedidos_resumen` AS select `pe`.`id` AS `id`,`pe`.`codigo_pedido` AS `codigo_pedido`,concat(`pe`.`nombre_cliente`,' ',coalesce(`pe`.`apellidos_cliente`,'')) AS `cliente`,`pe`.`telefono` AS `telefono`,`pe`.`tipo_entrega` AS `tipo_entrega`,`pe`.`metodo_pago` AS `metodo_pago`,`pe`.`estado` AS `estado`,`pe`.`total` AS `total`,`pe`.`fecha_creacion` AS `fecha_creacion`,count(`d`.`id`) AS `items`,coalesce(sum(`d`.`cantidad`),0) AS `unidades` from (`pedidos` `pe` left join `detalle_pedidos` `d` on((`d`.`pedido_id` = `pe`.`id`))) group by `pe`.`id` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `vw_ventas_por_producto`
--

/*!50001 DROP VIEW IF EXISTS `vw_ventas_por_producto`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_ventas_por_producto` AS select `pr`.`id` AS `id`,`pr`.`nombre` AS `nombre`,`c`.`nombre` AS `categoria`,coalesce(sum(`d`.`cantidad`),0) AS `unidades_vendidas`,coalesce(sum(`d`.`subtotal`),0) AS `ingresos` from (((`productos` `pr` join `categorias` `c` on((`c`.`id` = `pr`.`categoria_id`))) left join `detalle_pedidos` `d` on((`d`.`producto_id` = `pr`.`id`))) left join `pedidos` `pe` on(((`pe`.`id` = `d`.`pedido_id`) and (`pe`.`estado` <> 'CANCELADO')))) group by `pr`.`id`,`pr`.`nombre`,`c`.`nombre` */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-10-24 20:28:52
