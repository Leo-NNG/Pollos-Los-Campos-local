package com.pollosloscampos;

import com.pollosloscampos.dto.PedidoRequest;
import com.pollosloscampos.entity.EstadoPedido;
import com.pollosloscampos.entity.MetodoPago;
import com.pollosloscampos.entity.Producto;
import com.pollosloscampos.entity.TipoEntrega;
import com.pollosloscampos.exception.ReglaNegocioException;
import com.pollosloscampos.repository.PedidoRepository;
import com.pollosloscampos.repository.ProductoRepository;
import com.pollosloscampos.repository.UsuarioRepository;
import com.pollosloscampos.service.PedidoService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.math.BigDecimal;
import java.util.List;
import java.util.Optional;
import java.time.LocalDateTime;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class PedidoServiceTest {
    @Mock PedidoRepository pedidos;
    @Mock ProductoRepository productos;
    @Mock UsuarioRepository usuarios;

    PedidoService service;

    @BeforeEach
    void setUp() {
        service = new PedidoService(pedidos, productos, usuarios, new BigDecimal("5.00"));
        when(pedidos.save(any())).thenAnswer(inv -> {
            var p = inv.getArgument(0, com.pollosloscampos.entity.Pedido.class);
            try {
                var id = p.getClass().getDeclaredField("id");
                id.setAccessible(true);
                if (id.get(p) == null) id.set(p, 1L);
                var fc = p.getClass().getDeclaredField("fechaCreacion");
                fc.setAccessible(true);
                if (fc.get(p) == null) fc.set(p, LocalDateTime.of(2026, 9, 26, 12, 0));
                var fa = p.getClass().getDeclaredField("fechaActualizacion");
                fa.setAccessible(true);
                if (fa.get(p) == null) fa.set(p, LocalDateTime.of(2026, 9, 26, 12, 0));
            } catch (Exception e) { throw new AssertionError(e); }
            return p;
        });
    }

    @Test
    void calculaTotalConPrecioDelBackendYDelivery() {
        Producto producto = new Producto();
        producto.setNombre("1/4 de Pollo");
        producto.setPrecio(new BigDecimal("18.90"));
        producto.setDisponible(true);
        when(productos.findById(1L)).thenReturn(Optional.of(producto));

        PedidoRequest req = request(TipoEntrega.DELIVERY.name(), MetodoPago.YAPE.name(), List.of(new PedidoRequest.Item(1L, 2)));
        var pedido = service.registrar(req, null);

        assertEquals(new BigDecimal("37.80"), pedido.getSubtotal());
        assertEquals(new BigDecimal("5.00"), pedido.getDelivery());
        assertEquals(new BigDecimal("42.80"), pedido.getTotal());
        verify(productos).findById(1L);
    }

    @Test
    void rechazaProductoInexistente() {
        when(productos.findById(99L)).thenReturn(Optional.empty());
        PedidoRequest req = request(TipoEntrega.RECOJO.name(), MetodoPago.EFECTIVO.name(), List.of(new PedidoRequest.Item(99L, 1)));
        assertThrows(com.pollosloscampos.exception.RecursoNoEncontradoException.class, () -> service.registrar(req, null));
    }

    @Test
    void rechazaProductoNoDisponible() {
        Producto producto = new Producto();
        producto.setNombre("Producto no disponible");
        producto.setPrecio(new BigDecimal("10.00"));
        producto.setDisponible(false);
        when(productos.findById(1L)).thenReturn(Optional.of(producto));
        PedidoRequest req = request(TipoEntrega.RECOJO.name(), MetodoPago.EFECTIVO.name(), List.of(new PedidoRequest.Item(1L, 1)));
        assertThrows(ReglaNegocioException.class, () -> service.registrar(req, null));
    }

    @Test
    void rechazaDeliverySinDireccion() {
        PedidoRequest req = request(TipoEntrega.DELIVERY.name(), MetodoPago.EFECTIVO.name(), List.of(new PedidoRequest.Item(1L, 1)));
        req.setDireccion(" ");
        assertThrows(ReglaNegocioException.class, () -> service.registrar(req, null));
        verifyNoInteractions(productos);
    }

    @Test
    void rechazaTransicionIlogica() {
        var pedido = new com.pollosloscampos.entity.Pedido();
        pedido.setEstado(EstadoPedido.ENTREGADO);
        when(pedidos.findWithDetails(1L)).thenReturn(Optional.of(pedido));
        assertThrows(ReglaNegocioException.class, () -> service.cambiarEstado(1L, EstadoPedido.EN_PREPARACION));
    }

    private PedidoRequest request(String entrega, String pago, List<PedidoRequest.Item> items) {
        PedidoRequest r = new PedidoRequest();
        r.setNombre("Cliente");
        r.setApellidos("Prueba");
        r.setCorreo("cliente@example.com");
        r.setTelefono("999999999");
        r.setDireccion("Av. Principal 123");
        r.setTipoEntrega(entrega);
        r.setMetodoPago(pago);
        r.setItems(items);
        return r;
    }
}
