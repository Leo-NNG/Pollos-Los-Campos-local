package com.pollosloscampos.service;

import com.pollosloscampos.dto.ContactoRequest;
import com.pollosloscampos.entity.*;
import com.pollosloscampos.exception.RecursoNoEncontradoException;
import com.pollosloscampos.repository.ContactoRepository;

import java.util.*;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class ContactoService {
    final ContactoRepository repo;

    public ContactoService(ContactoRepository r) {
        repo = r;
    }

    public Contacto guardar(ContactoRequest r) {
        Contacto c = new Contacto();
        c.setNombre(r.getNombre().trim());
        c.setCorreo(r.getCorreo());
        c.setTelefono(r.getTelefono());
        c.setMotivo(r.getMotivo());
        c.setMensaje(r.getMensaje().trim());
        return repo.save(c);
    }

    @Transactional(readOnly = true)
    public List<Contacto> listar() {
        return repo.findAll().stream().sorted(Comparator.comparing(Contacto::getFechaCreacion).reversed()).toList();
    }

    public void estado(Long id, EstadoContacto e) {
        Contacto c = repo.findById(id).orElseThrow(() -> new RecursoNoEncontradoException("Mensaje no encontrado."));
        c.setEstado(e);
    }
}
