package com.pollosloscampos.controller;

import com.pollosloscampos.dto.PedidoRequest;
import com.pollosloscampos.service.PedidoService;
import jakarta.validation.Valid;
import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.ObjectMapper;

import java.util.List;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

@Controller
public class PedidoController {
    final PedidoService service;
    final ObjectMapper mapper;

    public PedidoController(PedidoService s, ObjectMapper m) {
        service = s;
        mapper = m;
    }

    @GetMapping("/pedido")
    String form(Model m) {
        m.addAttribute("pedidoForm", new PedidoRequest());
        return "pedido";
    }

    @PostMapping("/pedido/crear")
    String create(@Valid @ModelAttribute("pedidoForm") PedidoRequest r, BindingResult br, Model m, org.springframework.security.core.Authentication a) {
        if (br.hasErrors()) return "pedido";
        if (r.getTipoEntrega() != null && r.getTipoEntrega().toUpperCase().contains("DELIVERY") && (r.getDireccion() == null || r.getDireccion().isBlank())) {
            br.rejectValue("direccion", "direccion.required", "Para delivery debes indicar una dirección.");
            return "pedido";
        }
        try {
            r.setItems(mapper.readValue(r.getCarrito(), new TypeReference<List<PedidoRequest.Item>>() {
            }));
            var p = service.registrar(r, a == null || "anonymousUser".equals(a.getName()) ? null : a.getName());
            m.addAttribute("pedido", p);
            return "pedido-confirmado";
        } catch (Exception e) {
            m.addAttribute("errorGeneral", e.getMessage());
            return "pedido";
        }
    }

    @PostMapping("/seguimiento/buscar")
    String track(@RequestParam String codigo, @RequestParam String telefono, Model m) {
        try {
            m.addAttribute("pedido", service.seguimiento(codigo, telefono));
        } catch (Exception e) {
            m.addAttribute("errorGeneral", e.getMessage());
        }
        return "seguimiento";
    }
}
