"""
Toma capturas de pantalla de TODA la funcionalidad de Pollos Los Campos.

Requisitos (una sola vez):
    pip install playwright
    playwright install chromium

Uso:
    1) Arrancar la aplicación:  ./mvnw spring-boot:run
    2) En otra terminal:        python docs/capturas/tomar_capturas.py

Las imágenes quedan en docs/capturas/ con nombres numerados (01_inicio.png, ...).
"""
import pathlib, time
from playwright.sync_api import sync_playwright

BASE = "http://localhost:8080"
OUT = pathlib.Path(__file__).parent
ADMIN = ("admin@pollosloscampos.local", "Admin123!")
CLIENTE = {"nombres": "María", "apellidos": "Torres Gómez", "correo": "cliente@correo.com",
           "celular": "987654321", "password": "Cliente123!"}
ORDER = ["inicio", "menu", "menu_busqueda", "producto_detalle", "promociones", "nosotros", "contacto",
         "contacto_validacion", "pedido", "seguimiento", "login", "registro", "error_404", "admin_sin_sesion",
         "cuenta_cliente", "403_cliente_en_admin", "admin_dashboard", "admin_pedidos", "admin_pedido_detalle",
         "admin_productos", "admin_producto_nuevo", "admin_producto_editar", "admin_categorias",
         "admin_categoria_nueva", "admin_promociones", "admin_promocion_nueva", "admin_clientes",
         "admin_mensajes", "admin_reportes", "admin_configuracion"]
n = 0

def shot(page, nombre, url=None, full=True):
    global n
    try:
        if url:
            page.goto(BASE + url, wait_until="networkidle")
        archivo = f"{ORDER.index(nombre) + 1:02d}_{nombre}.png"
        page.screenshot(path=str(OUT / archivo), full_page=full)
        n += 1
        print("OK ", archivo)
    except Exception as e:
        print("ERR", nombre, e)

def login(page, correo, clave):
    page.goto(BASE + "/login", wait_until="networkidle")
    page.fill("input[name=correo]", correo)
    page.fill("input[name=password]", clave)
    page.click("button[type=submit]")
    page.wait_for_load_state("networkidle")

def logout(ctx):
    ctx.clear_cookies()

with sync_playwright() as p:
    b = p.chromium.launch()
    ctx = b.new_context(viewport={"width": 1366, "height": 800})
    page = ctx.new_page()

    # ---------- Sitio público ----------
    shot(page, "inicio", "/")
    shot(page, "menu", "/menu")
    shot(page, "menu_busqueda", "/menu?q=pollo")
    shot(page, "producto_detalle", "/producto/1")
    shot(page, "promociones", "/promociones")
    shot(page, "nosotros", "/nosotros")
    shot(page, "contacto", "/contacto")
    # contacto con error de validación y envío correcto
    try:
        page.fill("#nombre, input[name=nombre]", "")
        page.click('form[action$="/contacto/enviar"] button')
        page.wait_for_load_state("networkidle")
        shot(page, "contacto_validacion")
    except Exception as e:
        print("ERR contacto_validacion", e)
    shot(page, "pedido", "/pedido")
    shot(page, "seguimiento", "/seguimiento")
    shot(page, "login", "/login")
    shot(page, "registro", "/registro")
    shot(page, "error_404", "/ruta-que-no-existe")
    shot(page, "admin_sin_sesion", "/admin")

    # ---------- Registro y cuenta de cliente ----------
    try:
        page.goto(BASE + "/registro", wait_until="networkidle")
        for k, v in CLIENTE.items():
            page.fill(f"input[name={k}]", v)
        page.fill("input[name=confirmarPassword]", CLIENTE["password"])
        page.click("form button[type=submit]")
        page.wait_for_load_state("networkidle")
    except Exception as e:
        print("AVISO registro:", e)
    login(page, CLIENTE["correo"], CLIENTE["password"])
    shot(page, "cuenta_cliente", "/cuenta")
    shot(page, "403_cliente_en_admin", "/admin")
    logout(ctx)

    # ---------- Panel de administración ----------
    login(page, *ADMIN)
    for nombre, ruta in [
        ("admin_dashboard", "/admin"), ("admin_pedidos", "/admin/pedidos"),
        ("admin_pedido_detalle", "/admin/pedidos/1"),
        ("admin_productos", "/admin/productos"), ("admin_producto_nuevo", "/admin/productos/nuevo"),
        ("admin_producto_editar", "/admin/productos/1/editar"),
        ("admin_categorias", "/admin/categorias"), ("admin_categoria_nueva", "/admin/categorias/nueva"),
        ("admin_promociones", "/admin/promociones"), ("admin_promocion_nueva", "/admin/promociones/nueva"),
        ("admin_clientes", "/admin/clientes"), ("admin_mensajes", "/admin/mensajes"),
        ("admin_reportes", "/admin/reportes"), ("admin_configuracion", "/admin/configuracion"),
    ]:
        shot(page, nombre, ruta)
    b.close()
print(f"\nListo: {n} capturas en {OUT}")

print("Capturas manuales pendientes (requieren completar el flujo a mano): "
      "33_pedido_confirmado.png, 34_seguimiento_resultado.png, 31_script_sql_ejecutado.png, "
      "32_backup_generado.png y 35_pruebas_maven.png")
