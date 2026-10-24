-- =====================================================================
--  Archivo 2 de 3: DATOS INICIALES (catálogo, usuarios y casos de prueba)
--  Admin: admin@pollosloscampos.local / Admin123!   (hash BCrypt)
--  Cliente: cliente@correo.com / Cliente123!        (hash BCrypt)
-- =====================================================================
USE pollos_los_campos;

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
