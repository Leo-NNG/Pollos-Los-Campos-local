package com.pollosloscampos.controller;

import com.pollosloscampos.dto.ContactoRequest;
import com.pollosloscampos.entity.EstadoContacto;
import com.pollosloscampos.service.ContactoService;
import jakarta.validation.Valid;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

@Controller
public class ContactoController {
    final ContactoService service;

    public ContactoController(ContactoService s) {
        service = s;
    }

    @GetMapping("/contacto")
    String form(Model m) {
        m.addAttribute("contactoForm", new ContactoRequest());
        return "contacto";
    }

    @PostMapping("/contacto/enviar")
    String send(@Valid @ModelAttribute("contactoForm") ContactoRequest r, BindingResult br, Model m) {
        if (br.hasErrors()) return "contacto";
        service.guardar(r);
        m.addAttribute("enviado", true);
        m.addAttribute("contactoForm", new ContactoRequest());
        return "contacto";
    }

    @PostMapping("/admin/mensajes/{id}/estado")
    String estado(@PathVariable Long id, @RequestParam EstadoContacto estado) {
        service.estado(id, estado);
        return "redirect:/admin/mensajes";
    }
}
