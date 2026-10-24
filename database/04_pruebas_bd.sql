-- Pruebas de la base de datos (ejecutar después de los 3 scripts).
USE pollos_los_campos;
-- 1. Flujo completo de un pedido con procedimientos almacenados
CALL sp_crear_pedido(2,'María','Torres Gómez','cliente@correo.com','987654321','Av. Balta 450','Frente al parque','DELIVERY','YAPE','Sin ají',@pid,@cod);
CALL sp_agregar_detalle(@pid,(SELECT id FROM productos WHERE nombre='1/2 Pollo'),1);
CALL sp_agregar_detalle(@pid,(SELECT id FROM productos WHERE nombre='Inca Kola'),2);
CALL sp_cambiar_estado_pedido(@pid,'CONFIRMADO');
CALL sp_cambiar_estado_pedido(@pid,'EN_PREPARACION');
SELECT * FROM vw_pedidos_resumen;
CALL sp_seguimiento_pedido(@cod,'987654321');
CALL sp_reporte_ventas(CURDATE(), CURDATE());
SELECT * FROM vw_ventas_por_producto WHERE unidades_vendidas>0;
-- 2. Pruebas negativas (cada una debe fallar):
-- CALL sp_cambiar_estado_pedido(@pid,'RECIBIDO');                    -- retroceso: trigger
-- INSERT INTO productos(nombre,descripcion,precio,categoria_id) VALUES('X','x',-5,1); -- CHECK precio
-- INSERT INTO usuarios(nombres,apellidos,correo,password,rol) VALUES('a','b','admin@pollosloscampos.local','x','ROLE_CLIENTE'); -- UNIQUE
-- INSERT INTO productos(nombre,descripcion,precio,categoria_id) VALUES('Y','y',5,999); -- FK
