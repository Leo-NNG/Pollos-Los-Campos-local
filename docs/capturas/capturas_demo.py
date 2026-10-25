"""
Capturas EXTRA para la exposición: eliminación lógica y validaciones nuevas.
(Complementa a tomar_capturas.py; no lo reemplaza.)

Requisitos: los mismos que tomar_capturas.py (pip install playwright && playwright install chromium)
Uso:
    1) Aplicación en marcha:  ./mvnw spring-boot:run   (o desde IntelliJ)
    2) En otra terminal:      python docs/capturas/capturas_demo.py

Genera en docs/capturas/:
    36_promociones_antes.png          lista de promociones antes de eliminar
    37_promociones_despues.png        la promoción queda INACTIVA y aparece "Restaurar" (la fila sigue en la BD)
    38_promocion_restaurada.png       tras pulsar "Restaurar" (solo si RESTAURAR = True)
    39_producto_nombre_duplicado.png  aviso de nombre repetido bajo el campo
    40_categoria_nombre_duplicado.png aviso de categoría repetida

IMPORTANTE: para la evidencia en base de datos, ejecute database/05_demo_eliminacion_logica.sql
ANTES y DESPUÉS del paso "eliminar" y capture ambos resultados a mano.
Ponga RESTAURAR = False si quiere dejar la promoción eliminada para mostrarla en vivo.
"""
import pathlib
from playwright.sync_api import sync_playwright

BASE = "http://localhost:8080"
OUT = pathlib.Path(__file__).parent
ADMIN = ("admin@pollosloscampos.local", "Admin123!")
RESTAURAR = True


def shot(page, archivo):
    page.screenshot(path=str(OUT / archivo), full_page=True)
    print("OK ", archivo)


def paso(nombre, fn):
    try:
        fn()
    except Exception as e:  # un paso fallido no detiene los demás
        print("ERR", nombre, "->", e)


with sync_playwright() as p:
    b = p.chromium.launch()
    ctx = b.new_context(viewport={"width": 1366, "height": 800})
    page = ctx.new_page()
    page.on("dialog", lambda d: d.accept())  # acepta el confirm() de "Eliminar"

    page.goto(BASE + "/login", wait_until="networkidle")
    page.fill("input[name=correo]", ADMIN[0])
    page.fill("input[name=password]", ADMIN[1])
    page.click("button[type=submit]")
    page.wait_for_load_state("networkidle")

    def eliminacion_logica():
        page.goto(BASE + "/admin/promociones", wait_until="networkidle")
        shot(page, "36_promociones_antes.png")
        page.locator('form[action$="/eliminar"] button').first.click()
        page.wait_for_load_state("networkidle")
        shot(page, "37_promociones_despues.png")
        if RESTAURAR:
            page.locator('form[action$="/toggle"] button:has-text("Restaurar")').first.click()
            page.wait_for_load_state("networkidle")
            shot(page, "38_promocion_restaurada.png")

    def producto_duplicado():
        page.goto(BASE + "/admin/productos/1/editar", wait_until="networkidle")
        nombre = page.input_value("input[name=nombre]")
        page.goto(BASE + "/admin/productos/nuevo", wait_until="networkidle")
        page.fill("input[name=nombre]", nombre)
        page.fill("input[name=precio]", "10.00")
        page.fill("textarea[name=descripcion]", "Producto de prueba para validar nombre repetido")
        page.select_option("select[name=categoriaId]", index=1)
        page.locator("main form button.btn-primary").first.click()
        page.wait_for_load_state("networkidle")
        shot(page, "39_producto_nombre_duplicado.png")

    def categoria_duplicada():
        page.goto(BASE + "/admin/categorias/1/editar", wait_until="networkidle")
        nombre = page.input_value("input[name=nombre]")
        page.goto(BASE + "/admin/categorias/nueva", wait_until="networkidle")
        page.fill("input[name=nombre]", nombre)
        if page.locator("textarea[name=descripcion]").count():
            page.fill("textarea[name=descripcion]", "Categoría de prueba")
        elif page.locator("input[name=descripcion]").count():
            page.fill("input[name=descripcion]", "Categoría de prueba")
        page.locator("main form button.btn-primary").first.click()
        page.wait_for_load_state("networkidle")
        shot(page, "40_categoria_nombre_duplicado.png")

    paso("eliminación lógica", eliminacion_logica)
    paso("producto duplicado", producto_duplicado)
    paso("categoría duplicada", categoria_duplicada)
    b.close()
print("Listo.")
