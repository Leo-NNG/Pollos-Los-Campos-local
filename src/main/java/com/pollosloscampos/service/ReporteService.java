package com.pollosloscampos.service;

import com.pollosloscampos.entity.*;
import com.pollosloscampos.repository.*;

import java.util.*;

import org.springframework.stereotype.Service;

@Service
public class ReporteService {
    final PedidoService pedidos;
    final UsuarioRepository users;
    final ProductoRepository products;
    final ContactoRepository contacts;

    public ReporteService(PedidoService p, UsuarioRepository u, ProductoRepository pr, ContactoRepository c) {
        pedidos = p;
        users = u;
        products = pr;
        contacts = c;
    }

    public Map<String, Object> resumen() {
        var m = new LinkedHashMap<String, Object>();
        m.putAll(pedidos.dashboard());
        m.put("clientes", users.findAll().stream().filter(u -> u.getRol() == Rol.ROLE_CLIENTE).count());
        m.put("productosDisponibles", products.findByDisponibleTrueOrderByNombreAsc().size());
        m.put("mensajesNuevos", contacts.countByEstado(EstadoContacto.NUEVO));
        return m;
    }

    public Map<EstadoPedido, Long> pedidosPorEstado() {
        var m = new LinkedHashMap<EstadoPedido, Long>();
        for (var e : EstadoPedido.values()) m.put(e, pedidos.countByEstado(e));
        return m;
    }
}
