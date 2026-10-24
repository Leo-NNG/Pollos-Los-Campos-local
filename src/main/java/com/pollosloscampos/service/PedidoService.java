package com.pollosloscampos.service;

import com.pollosloscampos.dto.PedidoRequest;
import com.pollosloscampos.entity.*;
import com.pollosloscampos.exception.*;
import com.pollosloscampos.repository.*;

import java.math.*;
import java.time.*;
import java.time.format.DateTimeFormatter;
import java.util.*;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class PedidoService {
    final PedidoRepository pedidos;
    final ProductoRepository productos;
    final UsuarioRepository usuarios;
    final BigDecimal deliveryFee;

    public PedidoService(PedidoRepository p, ProductoRepository pr, UsuarioRepository u, @Value("${app.delivery.fee:5.00}") BigDecimal fee) {
        pedidos = p;
        productos = pr;
        usuarios = u;
        deliveryFee = fee;
    }

    public Pedido registrar(PedidoRequest r, String correo) {
        TipoEntrega tipo = parseTipo(r.getTipoEntrega());
        MetodoPago pago = parsePago(r.getMetodoPago());
        if (tipo == TipoEntrega.DELIVERY && (r.getDireccion() == null || r.getDireccion().isBlank()))
            throw new ReglaNegocioException("Para delivery debes indicar una dirección.");
        if (r.getItems() == null || r.getItems().isEmpty()) throw new ReglaNegocioException("El carrito está vacío.");
        Pedido p = new Pedido();
        p.setNombreCliente(r.getNombre().trim());
        p.setApellidosCliente(blank(r.getApellidos()) ? null : r.getApellidos().trim());
        p.setCorreoCliente(blank(r.getCorreo()) ? null : r.getCorreo().trim().toLowerCase());
        p.setTelefono(r.getTelefono());
        p.setDireccion(blank(r.getDireccion()) ? null : r.getDireccion().trim());
        p.setReferencia(blank(r.getReferencia()) ? null : r.getReferencia().trim());
        p.setTipoEntrega(tipo);
        p.setMetodoPago(pago);
        p.setNotas(blank(r.getNotas()) ? null : r.getNotas().trim());
        if (correo != null && !correo.isBlank()) usuarios.findByCorreoIgnoreCase(correo).ifPresent(p::setUsuario);
        BigDecimal sub = BigDecimal.ZERO;
        for (var i : r.getItems()) {
            if (i == null || i.productoId() == null || i.cantidad() < 1 || i.cantidad() > 20)
                throw new ReglaNegocioException("Cantidad o producto inválido.");
            Producto prod = productos.findById(i.productoId()).orElseThrow(() -> new RecursoNoEncontradoException("Producto no encontrado: " + i.productoId()));
            if (!prod.isDisponible())
                throw new ReglaNegocioException("El producto \"" + prod.getNombre() + "\" ya no está disponible.");
            BigDecimal line = prod.getPrecio().multiply(BigDecimal.valueOf(i.cantidad())).setScale(2, RoundingMode.HALF_UP);
            DetallePedido d = new DetallePedido();
            d.setPedido(p);
            d.setProducto(prod);
            d.setCantidad(i.cantidad());
            d.setPrecioUnitario(prod.getPrecio());
            d.setSubtotal(line);
            p.getDetalles().add(d);
            sub = sub.add(line);
        }
        sub = sub.setScale(2, RoundingMode.HALF_UP);
        BigDecimal del = tipo == TipoEntrega.DELIVERY ? deliveryFee.setScale(2) : BigDecimal.ZERO.setScale(2);
        p.setSubtotal(sub);
        p.setDelivery(del);
        p.setTotal(sub.add(del).setScale(2, RoundingMode.HALF_UP));
        p.setEstado(EstadoPedido.RECIBIDO);
        p.setCodigoPedido("PLC-" + java.util.UUID.randomUUID().toString().substring(0, 8).toUpperCase());
        return pedidos.save(p);
    }

    @Transactional(readOnly = true)
    public Pedido obtener(Long id) {
        return pedidos.findWithDetails(id).orElseThrow(() -> new RecursoNoEncontradoException("Pedido no encontrado."));
    }

    @Transactional(readOnly = true)
    public Pedido seguimiento(String c, String t) {
        return pedidos.findTracking(c.trim(), t.trim()).orElseThrow(() -> new RecursoNoEncontradoException("No encontramos un pedido con ese código y teléfono."));
    }

    @Transactional(readOnly = true)
    public List<Pedido> listar() {
        return pedidos.findAllByOrderByFechaCreacionDesc();
    }

    @Transactional(readOnly = true)
    public List<Pedido> deUsuario(String c) {
        var u = usuarios.findByCorreoIgnoreCase(c).orElseThrow(() -> new RecursoNoEncontradoException("Usuario no encontrado."));
        return pedidos.findByUsuarioIdOrderByFechaCreacionDesc(u.getId());
    }

    @Transactional(readOnly = true)
    public long totalDeUsuario(Long id) {
        return pedidos.countByUsuarioId(id);
    }

    @Transactional(readOnly = true)
    public boolean propietario(Long id, String c) {
        var p = obtener(id);
        return p.getUsuario() != null && p.getUsuario().getCorreo().equalsIgnoreCase(c);
    }

    public Pedido cambiarEstado(Long id, EstadoPedido nuevo) {
        Pedido p = obtener(id);
        EstadoPedido a = p.getEstado();
        if (a == nuevo) return p;
        if (a == EstadoPedido.CANCELADO || a == EstadoPedido.ENTREGADO)
            throw new ReglaNegocioException("El pedido ya se encuentra en un estado final.");
        if (nuevo == EstadoPedido.CANCELADO) {
            p.setEstado(nuevo);
            return p;
        }
        List<EstadoPedido> flujo = List.of(EstadoPedido.RECIBIDO, EstadoPedido.CONFIRMADO, EstadoPedido.EN_PREPARACION, EstadoPedido.LISTO, EstadoPedido.EN_CAMINO, EstadoPedido.ENTREGADO);
        if (flujo.indexOf(nuevo) != flujo.indexOf(a) + 1)
            throw new ReglaNegocioException("Transición no permitida: " + a + " → " + nuevo + ".");
        p.setEstado(nuevo);
        return p;
    }

    @Transactional(readOnly = true)
    public long countByEstado(EstadoPedido estado) {
        return pedidos.countByEstado(estado);
    }

    public Map<String, Object> dashboard() {
        var now = LocalDateTime.now();
        var d = new LinkedHashMap<String, Object>();
        var ini = now.toLocalDate().atStartOfDay();
        var mes = now.toLocalDate().withDayOfMonth(1).atStartOfDay();
        d.put("ventasHoy", pedidos.ventasEntre(ini, now));
        d.put("ventasMes", pedidos.ventasEntre(mes, now));
        d.put("pendientes", pedidos.countByEstadoIn(List.of(EstadoPedido.RECIBIDO, EstadoPedido.CONFIRMADO, EstadoPedido.EN_PREPARACION, EstadoPedido.LISTO, EstadoPedido.EN_CAMINO)));
        d.put("completados", pedidos.countByEstado(EstadoPedido.ENTREGADO));
        return d;
    }

    private TipoEntrega parseTipo(String s) {
        try {
            return TipoEntrega.valueOf(s.trim().toUpperCase());
        } catch (Exception e) {
            throw new ReglaNegocioException("Tipo de entrega inválido.");
        }
    }

    private MetodoPago parsePago(String s) {
        try {
            return MetodoPago.valueOf(s.trim().toUpperCase().replace("YAPE / PLIN", "YAPE"));
        } catch (Exception e) {
            throw new ReglaNegocioException("Método de pago inválido.");
        }
    }

    boolean blank(String s) {
        return s == null || s.isBlank();
    }
}
