package com.pollosloscampos.controller;

import com.pollosloscampos.dto.*;
import com.pollosloscampos.entity.*;
import com.pollosloscampos.service.*;
import jakarta.validation.Valid;

import java.util.*;

import org.springframework.http.*;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api")
public class ApiController {
    final ProductoService products;
    final CategoriaService cats;
    final PromocionService promos;
    final PedidoService pedidos;
    final ReporteService reportes;

    public ApiController(ProductoService p, CategoriaService c, PromocionService pr, PedidoService pe, ReporteService r) {
        products = p;
        cats = c;
        promos = pr;
        pedidos = pe;
        reportes = r;
    }

    @GetMapping("/productos")
    List<Map<String, Object>> ps() {
        return products.listar().stream().map(this::pm).toList();
    }

    @GetMapping("/productos/{id}")
    Map<String, Object> p(@PathVariable Long id) {
        return pm(products.obtener(id));
    }

    @PostMapping("/productos")
    ResponseEntity<Map<String, Object>> cp(@Valid @RequestBody ProductoRequest r) {
        return ResponseEntity.status(201).body(pm(products.crear(r)));
    }

    @PutMapping("/productos/{id}")
    Map<String, Object> up(@PathVariable Long id, @Valid @RequestBody ProductoRequest r) {
        return pm(products.actualizar(id, r));
    }

    @DeleteMapping("/productos/{id}")
    Map<String, Object> dp(@PathVariable Long id) {
        products.toggle(id);
        return Map.of("message", "Producto actualizado.");
    }

    @GetMapping("/categorias")
    List<Map<String, Object>> cs() {
        return cats.activas().stream().map(this::categoryMap).toList();
    }

    @GetMapping("/promociones")
    List<Promocion> ps2() {
        return promos.vigentes();
    }

    @PostMapping("/pedidos")
    ResponseEntity<Map<String, Object>> order(@Valid @RequestBody PedidoRequest r, Authentication a) {
        return ResponseEntity.status(201).body(om(pedidos.registrar(r, a == null ? null : a.getName())));
    }

    @GetMapping("/pedidos/{id}")
    Map<String, Object> order(@PathVariable Long id, Authentication a) {
        boolean admin = a != null && a.getAuthorities().stream().anyMatch(x -> x.getAuthority().equals("ROLE_ADMIN"));
        if (!admin && !pedidos.propietario(id, a.getName()))
            throw new org.springframework.security.access.AccessDeniedException("No autorizado.");
        return om(pedidos.obtener(id));
    }

    @PutMapping("/pedidos/{id}/estado")
    ResponseEntity<Map<String, Object>> state(@PathVariable Long id, @Valid @RequestBody EstadoPedidoRequest r) {
        EstadoPedido nuevo;
        try {
            nuevo = EstadoPedido.valueOf(r.estado().trim().toUpperCase());
        } catch (IllegalArgumentException ex) {
            return ResponseEntity.badRequest().body(Map.<String, Object>of("status", 400,
                    "message", "Estado inválido. Valores permitidos: " + Arrays.toString(EstadoPedido.values())));
        }
        return ResponseEntity.ok(om(pedidos.cambiarEstado(id, nuevo)));
    }

    @GetMapping("/dashboard/resumen")
    Map<String, Object> dash() {
        return reportes.resumen();
    }

    private Map<String, Object> categoryMap(Categoria c) {
        var m = new LinkedHashMap<String, Object>();
        m.put("id", c.getId());
        m.put("nombre", c.getNombre());
        m.put("descripcion", c.getDescripcion() == null ? "" : c.getDescripcion());
        m.put("activo", c.isActivo());
        return m;
    }

    private Map<String, Object> pm(Producto p) {
        var m = new LinkedHashMap<String, Object>();
        m.put("id", p.getId());
        m.put("nombre", p.getNombre());
        m.put("descripcion", p.getDescripcion() == null ? "" : p.getDescripcion());
        m.put("precio", p.getPrecio());
        m.put("imagen", p.getImagen() == null ? "" : p.getImagen());
        m.put("categoria", p.getCategoria() == null ? "" : p.getCategoria().getNombre());
        m.put("disponible", p.isDisponible());
        m.put("destacado", p.isDestacado());
        m.put("etiqueta", p.getEtiqueta() == null ? "" : p.getEtiqueta());
        return m;
    }

    private Map<String, Object> om(Pedido p) {
        var d = new ArrayList<Map<String, Object>>();
        for (var x : p.getDetalles())
            d.add(Map.of("productoId", x.getProducto().getId(), "producto", x.getProducto().getNombre(), "cantidad", x.getCantidad(), "precioUnitario", x.getPrecioUnitario(), "subtotal", x.getSubtotal()));
        var m = new LinkedHashMap<String, Object>();
        m.put("id", p.getId());
        m.put("codigoPedido", p.getCodigoPedido());
        m.put("cliente", p.getNombreCliente());
        m.put("apellidos", p.getApellidosCliente());
        m.put("correo", p.getCorreoCliente());
        m.put("telefono", p.getTelefono());
        m.put("tipoEntrega", p.getTipoEntrega().name());
        m.put("metodoPago", p.getMetodoPago().name());
        m.put("subtotal", p.getSubtotal());
        m.put("delivery", p.getDelivery());
        m.put("total", p.getTotal());
        m.put("estado", p.getEstado().name());
        m.put("fechaCreacion", p.getFechaCreacion());
        m.put("detalles", d);
        return m;
    }
}
