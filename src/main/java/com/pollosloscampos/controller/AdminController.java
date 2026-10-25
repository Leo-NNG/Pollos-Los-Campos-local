package com.pollosloscampos.controller;

import com.pollosloscampos.dto.*;
import com.pollosloscampos.entity.*;
import com.pollosloscampos.service.*;
import jakarta.validation.Valid;

import java.util.stream.Collectors;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/admin")
public class AdminController {
    final ReporteService reportes;
    final PedidoService pedidos;
    final ProductoService products;
    final CategoriaService cats;
    final PromocionService promos;
    final UsuarioService users;
    final ContactoService contacts;

    public AdminController(ReporteService r, PedidoService p, ProductoService pr, CategoriaService c, PromocionService pm, UsuarioService u, ContactoService ct) {
        reportes = r;
        pedidos = p;
        products = pr;
        cats = c;
        promos = pm;
        users = u;
        contacts = ct;
    }

    @GetMapping
    String dash(Model m) {
        m.addAttribute("resumen", reportes.resumen());
        m.addAttribute("pedidos", pedidos.listar().stream().limit(8).toList());
        return "admin/dashboard";
    }

    @GetMapping("/pedidos")
    String orders(Model m) {
        m.addAttribute("pedidos", pedidos.listar());
        return "admin/pedidos";
    }

    @GetMapping("/pedidos/{id}")
    String od(@PathVariable Long id, Model m) {
        m.addAttribute("pedido", pedidos.obtener(id));
        m.addAttribute("estados", EstadoPedido.values());
        return "admin/pedido-detalle";
    }

    @PostMapping("/pedidos/{id}/estado")
    String os(@PathVariable Long id, @RequestParam EstadoPedido estado) {
        pedidos.cambiarEstado(id, estado);
        return "redirect:/admin/pedidos/" + id;
    }

    @GetMapping("/productos")
    String products(Model m) {
        m.addAttribute("productos", products.listar());
        return "admin/productos";
    }

    @GetMapping("/productos/nuevo")
    String pn(Model m) {
        m.addAttribute("productoForm", new ProductoRequest());
        m.addAttribute("categorias", cats.activas());
        return "admin/producto-form";
    }

    @GetMapping("/productos/{id}/editar")
    String pe(@PathVariable Long id, Model m) {
        var p = products.obtener(id);
        var f = new ProductoRequest();
        f.setNombre(p.getNombre());
        f.setDescripcion(p.getDescripcion());
        f.setPrecio(p.getPrecio());
        f.setCategoriaId(p.getCategoria().getId());
        f.setImagen(p.getImagen());
        f.setEtiqueta(p.getEtiqueta());
        f.setDisponible(p.isDisponible());
        f.setDestacado(p.isDestacado());
        m.addAttribute("productoForm", f);
        m.addAttribute("categorias", cats.activas());
        m.addAttribute("productoId", id);
        return "admin/producto-form";
    }

    @PostMapping("/productos/guardar")
    String pg(@Valid @ModelAttribute("productoForm") ProductoRequest r, BindingResult b, @RequestParam(required = false) Long id, Model m) {
        if (!b.hasFieldErrors("nombre") && products.nombreEnUso(r.getNombre(), id))
            b.rejectValue("nombre", "producto.nombre.duplicado", "Ya existe un producto con ese nombre.");
        if (b.hasErrors()) {
            m.addAttribute("categorias", cats.activas());
            if (id != null) m.addAttribute("productoId", id);
            return "admin/producto-form";
        }
        if (id == null) products.crear(r);
        else products.actualizar(id, r);
        return "redirect:/admin/productos";
    }

    @PostMapping("/productos/{id}/toggle")
    String pt(@PathVariable Long id) {
        products.toggle(id);
        return "redirect:/admin/productos";
    }

    @GetMapping("/categorias")
    String categories(Model m) {
        m.addAttribute("categorias", cats.listar());
        return "admin/categorias";
    }

    @GetMapping("/categorias/nueva")
    String cn(Model m) {
        m.addAttribute("categoriaForm", new CategoriaRequest());
        return "admin/categoria-form";
    }

    @GetMapping("/categorias/{id}/editar")
    String ce(@PathVariable Long id, Model m) {
        var c = cats.obtener(id);
        var f = new CategoriaRequest();
        f.setNombre(c.getNombre());
        f.setDescripcion(c.getDescripcion());
        m.addAttribute("categoriaForm", f);
        m.addAttribute("categoriaId", id);
        return "admin/categoria-form";
    }

    @PostMapping("/categorias/guardar")
    String cg(@Valid @ModelAttribute("categoriaForm") CategoriaRequest r, BindingResult b, @RequestParam(required = false) Long id, Model m) {
        if (!b.hasFieldErrors("nombre") && cats.nombreEnUso(r.getNombre(), id))
            b.rejectValue("nombre", "categoria.nombre.duplicado", "Ya existe una categoría con ese nombre.");
        if (b.hasErrors()) {
            if (id != null) m.addAttribute("categoriaId", id);
            return "admin/categoria-form";
        }
        if (id == null) cats.crear(r);
        else cats.actualizar(id, r);
        return "redirect:/admin/categorias";
    }

    @PostMapping("/categorias/{id}/toggle")
    String ct(@PathVariable Long id) {
        cats.toggle(id);
        return "redirect:/admin/categorias";
    }

    @GetMapping("/promociones")
    String proms(Model m) {
        m.addAttribute("promociones", promos.listar());
        return "admin/promociones";
    }

    @GetMapping("/promociones/nueva")
    String prn(Model m) {
        m.addAttribute("promoForm", new PromocionRequest());
        return "admin/promocion-form";
    }

    @GetMapping("/promociones/{id}/editar")
    String pre(@PathVariable Long id, Model m) {
        var p = promos.obtener(id);
        var f = new PromocionRequest();
        f.setNombre(p.getNombre());
        f.setDescripcion(p.getDescripcion());
        f.setPrecioAnterior(p.getPrecioAnterior());
        f.setPrecioPromocional(p.getPrecioPromocional());
        f.setFechaInicio(p.getFechaInicio());
        f.setFechaFin(p.getFechaFin());
        f.setImagen(p.getImagen());
        f.setStock(p.getStock());
        f.setActiva(p.isActiva());
        m.addAttribute("promoForm", f);
        m.addAttribute("promoId", id);
        return "admin/promocion-form";
    }

    @PostMapping("/promociones/guardar")
    String prg(@Valid @ModelAttribute("promoForm") PromocionRequest r, BindingResult b, @RequestParam(required = false) Long id, Model m) {
        if (b.hasErrors()) {
            if (id != null) m.addAttribute("promoId", id);
            return "admin/promocion-form";
        }
        if (id == null) promos.crear(r);
        else promos.actualizar(id, r);
        return "redirect:/admin/promociones";
    }

    @PostMapping("/promociones/{id}/toggle")
    String prt(@PathVariable Long id) {
        promos.toggle(id);
        return "redirect:/admin/promociones";
    }

    @PostMapping("/promociones/{id}/stock")
    String prs(@PathVariable Long id, @RequestParam int delta) {
        promos.ajustarStock(id, delta);
        return "redirect:/admin/promociones";
    }

    @PostMapping("/promociones/{id}/eliminar")
    String prd(@PathVariable Long id) {
        promos.eliminar(id);
        return "redirect:/admin/promociones";
    }

    @GetMapping("/clientes")
    String clients(Model m) {
        var cs = users.clientes();
        var counts = cs.stream().collect(Collectors.toMap(Usuario::getId, u -> pedidos.totalDeUsuario(u.getId())));
        m.addAttribute("clientes", cs);
        m.addAttribute("pedidoCounts", counts);
        return "admin/clientes";
    }

    @PostMapping("/clientes/{id}/toggle")
    String clt(@PathVariable Long id) {
        users.toggle(id);
        return "redirect:/admin/clientes";
    }

    @GetMapping("/mensajes")
    String msg(Model m) {
        m.addAttribute("mensajes", contacts.listar());
        return "admin/mensajes";
    }

    @GetMapping("/reportes")
    String reports(Model m) {
        m.addAttribute("resumen", reportes.resumen());
        m.addAttribute("pedidos", pedidos.listar());
        return "admin/reportes";
    }

    @GetMapping("/configuracion")
    String config() {
        return "admin/configuracion";
    }

    @ModelAttribute("estadosPedido")
    EstadoPedido[] estados() {
        return EstadoPedido.values();
    }
}
