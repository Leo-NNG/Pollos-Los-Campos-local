# Base de datos – Pollos Los Campos

La aplicación puede ejecutarse con **H2 embebido** (por defecto, sin instalar nada) o con **MySQL/MariaDB**
(perfil `mysql`) usando los scripts de esta carpeta.

| Archivo | Contenido |
|---|---|
| `pollos_los_campos.sql` | Script completo (esquema + datos + programación) en un solo archivo. |
| `01_esquema.sql` | Tablas, claves primarias, claves foráneas, únicos, CHECK e índices. |
| `02_datos_iniciales.sql` | Catálogo, usuarios (admin y cliente de prueba), promociones, dirección y contactos. |
| `03_programacion_bd.sql` | 3 vistas, 1 función, 3 triggers y 5 procedimientos almacenados. |
| `04_pruebas_bd.sql` | Pruebas del flujo de pedido y casos negativos de restricciones. |
| `backup/backup_pollos_los_campos.sql` | **Backup lógico** (mysqldump con datos, rutinas y triggers). |
| `backup/backup_h2_pollos_los_campos.mv.db` | Copia del archivo de la base H2 embebida. |

## Inventario de objetos
- 8 tablas · 8 claves primarias · 5 claves foráneas · 5 restricciones UNIQUE · 20 CHECK · 9 índices adicionales
- 3 vistas: `vw_menu`, `vw_pedidos_resumen`, `vw_ventas_por_producto`
- 3 triggers: `trg_usuarios_bi`, `trg_detalle_bi`, `trg_pedidos_bu`
- 1 función: `fn_codigo_pedido`
- 5 procedimientos: `sp_crear_pedido`, `sp_agregar_detalle`, `sp_cambiar_estado_pedido`, `sp_reporte_ventas`, `sp_seguimiento_pedido`

## Crear la base desde cero
```bash
mysql -u root -p < database/01_esquema.sql
mysql -u root -p < database/02_datos_iniciales.sql
mysql -u root -p < database/03_programacion_bd.sql
mysql -u root -p < database/04_pruebas_bd.sql      # opcional
```

## Restaurar el backup
```bash
mysql -u root -p < database/backup/backup_pollos_los_campos.sql
```

## Generar un nuevo backup
```bash
mysqldump -u root -p --databases pollos_los_campos --routines --triggers --events \
          --single-transaction --add-drop-database > database/backup/backup_pollos_los_campos.sql
```

## Usar la aplicación con MySQL
1. Restaurar o crear la base con los scripts.
2. Ajustar usuario/clave en `src/main/resources/application-mysql.properties`.
3. Ejecutar: `./mvnw spring-boot:run -Dspring-boot.run.profiles=mysql`

## Credenciales de prueba
- Administrador: `admin@pollosloscampos.local` / `Admin123!`
- Cliente: `cliente@correo.com` / `Cliente123!`
