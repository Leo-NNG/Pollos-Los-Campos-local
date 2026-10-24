package com.pollosloscampos.service;

import com.pollosloscampos.dto.UsuarioRequest;
import com.pollosloscampos.entity.*;
import com.pollosloscampos.exception.*;
import com.pollosloscampos.repository.UsuarioRepository;

import java.util.*;

import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class UsuarioService {
    final UsuarioRepository repo;
    final PasswordEncoder encoder;

    public UsuarioService(UsuarioRepository r, PasswordEncoder e) {
        repo = r;
        encoder = e;
    }

    public Usuario registrarCliente(UsuarioRequest r) {
        return registrar(r, null);
    }

    public Usuario registrar(UsuarioRequest r, String codigoValido) {
        if (!r.passwordsMatch()) throw new ReglaNegocioException("Las contraseñas no coinciden.");
        if (repo.existsByCorreoIgnoreCase(r.getCorreo().trim()))
            throw new ReglaNegocioException("El correo ya está registrado.");
        Usuario u = new Usuario();
        u.setNombres(r.getNombres().trim());
        u.setApellidos(r.getApellidos().trim());
        u.setCorreo(r.getCorreo().trim().toLowerCase());
        u.setCelular(r.getCelular());
        u.setPassword(encoder.encode(r.getPassword()));
        boolean pideAdmin = r.getCodigoAdmin() != null && !r.getCodigoAdmin().isBlank();
        if (pideAdmin) {
            if (codigoValido == null || !codigoValido.equals(r.getCodigoAdmin().trim()))
                throw new ReglaNegocioException("El código de administrador no es válido.");
            u.setRol(Rol.ROLE_ADMIN);
        } else u.setRol(Rol.ROLE_CLIENTE);
        u.setActivo(true);
        return repo.save(u);
    }

    @Transactional(readOnly = true)
    public Usuario porCorreo(String c) {
        return repo.findByCorreoIgnoreCase(c).orElseThrow(() -> new RecursoNoEncontradoException("Usuario no encontrado."));
    }

    @Transactional(readOnly = true)
    public List<Usuario> clientes() {
        return repo.findAll().stream().filter(u -> u.getRol() == Rol.ROLE_CLIENTE).sorted(Comparator.comparing(Usuario::getFechaRegistro).reversed()).toList();
    }

    public void toggle(Long id) {
        Usuario u = repo.findById(id).orElseThrow(() -> new RecursoNoEncontradoException("Usuario no encontrado."));
        u.setActivo(!u.isActivo());
    }
}
