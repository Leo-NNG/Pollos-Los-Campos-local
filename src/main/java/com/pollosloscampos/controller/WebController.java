package com.pollosloscampos.controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestParam;

import com.pollosloscampos.entity.EstadoPedido;
import com.pollosloscampos.service.CategoriaService;
import com.pollosloscampos.service.PedidoService;
import com.pollosloscampos.service.ProductoService;
import com.pollosloscampos.service.PromocionService;
import com.pollosloscampos.service.UsuarioService;

@Controller
public class WebController {
    final ProductoService products;
    final CategoriaService cats;
    final PromocionService promos;
    final PedidoService pedidos;
    final UsuarioService users;

    public WebController(ProductoService p, CategoriaService c, PromocionService pr, PedidoService pe,
                         UsuarioService u) {
        products = p;
        cats = c;
        promos = pr;
        pedidos = pe;
        users = u;
    }

    @GetMapping("/")
    String home(Model m) {
        m.addAttribute("destacados", products.destacados());
        m.addAttribute("promociones", promos.vigentes());
        return "index";
    }

    @GetMapping("/menu")
    String menu(@RequestParam(required = false) String q, @RequestParam(required = false) Long categoria,
                @RequestParam(required = false) Boolean disponible, @RequestParam(required = false) Boolean destacado,
                @RequestParam(defaultValue = "nombre") String ordenar, Model m) {
        m.addAttribute("productos", products.buscar(q, categoria, disponible, destacado,
                "precioMenor".equals(ordenar) ? "precioAsc" : "precioMayor".equals(ordenar) ? "precioDesc" : "nombre"));
        m.addAttribute("categorias", cats.activas());
        m.addAttribute("categoriaActual", categoria);
        m.addAttribute("qActual", q);
        m.addAttribute("disponibleActual", disponible);
        m.addAttribute("destacadoActual", destacado);
        m.addAttribute("ordenarActual", ordenar);
        return "menu";
    }

    @GetMapping("/producto/{id}")
    String producto(@PathVariable Long id, Model m) {
        m.addAttribute("producto", products.obtener(id));
        return "producto";
    }

    @GetMapping("/promociones")
    String promociones(Model m) {
        m.addAttribute("promociones", promos.vigentes());
        return "promociones";
    }

    @GetMapping("/nosotros")
    String nosotros() {
        return "nosotros";
    }

    @GetMapping("/seguimiento")
    String seguimiento() {
        return "seguimiento";
    }

    @GetMapping("/login")
    String login(@RequestParam(required = false) String error, @RequestParam(required = false) String registro,
                 Model m) {
        m.addAttribute("loginError", error != null);
        return "login";
    }

    @GetMapping("/post-login")
    String post(org.springframework.security.core.Authentication a) {
        return a.getAuthorities().stream().anyMatch(x -> x.getAuthority().equals("ROLE_ADMIN")) ? "redirect:/admin"
                : "redirect:/cuenta";
    }

    @GetMapping("/cuenta")
    String cuenta(org.springframework.security.core.Authentication a, Model m) {
        m.addAttribute("usuario", users.porCorreo(a.getName()));
        m.addAttribute("pedidos", pedidos.deUsuario(a.getName()));
        return "cuenta";
    }

    @GetMapping("/403")
    String denied() {
        return "error/403";
    }

    @ModelAttribute("estadosPedido")
    EstadoPedido[] estados() {
        return EstadoPedido.values();
    }
}
