"""Genera solo 08_contacto_validacion.png (formulario de contacto enviado vacío).
Uso (con la aplicación en marcha):  py docs\\capturas\\captura_08.py
"""
import pathlib
from playwright.sync_api import sync_playwright

BASE = "http://localhost:8080"
OUT = pathlib.Path(__file__).parent

with sync_playwright() as p:
    b = p.chromium.launch()
    page = b.new_context(viewport={"width": 1366, "height": 800}).new_page()
    page.goto(BASE + "/contacto", wait_until="networkidle")
    page.fill("input[name=nombre]", "")
    page.click('form[action$="/contacto/enviar"] button')  # el botón no tiene type="submit" y la página no usa <main>
    page.wait_for_load_state("networkidle")
    page.screenshot(path=str(OUT / "08_contacto_validacion.png"), full_page=True)
    print("OK  08_contacto_validacion.png")
    b.close()
