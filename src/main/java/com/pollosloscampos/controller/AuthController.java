package com.pollosloscampos.controller;

import com.pollosloscampos.dto.UsuarioRequest;
import com.pollosloscampos.service.UsuarioService;
import jakarta.validation.Valid;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.validation.BindingResult;
import org.springframework.web.bind.annotation.*;

@Controller
public class AuthController {
    final UsuarioService users;
    final String adminCode;

    public AuthController(UsuarioService u, @org.springframework.beans.factory.annotation.Value("${app.admin.code:LOSCAMPOS-ADMIN-2026}") String code) {
        users = u;
        adminCode = code;
    }

    @GetMapping("/registro")
    String form(Model m) {
        m.addAttribute("usuarioRequest", new UsuarioRequest());
        return "registro";
    }

    @PostMapping("/registro/crear")
    String crear(@Valid @ModelAttribute("usuarioRequest") UsuarioRequest r, BindingResult br, Model m) {
        if (!r.passwordsMatch()) br.rejectValue("confirmarPassword", "password.match", "Las contraseñas no coinciden.");
        if (br.hasErrors()) return "registro";
        try {
            users.registrar(r, adminCode);
            return "redirect:/login?registro=true";
        } catch (Exception e) {
            m.addAttribute("errorGeneral", e.getMessage());
            return "registro";
        }
    }
}
