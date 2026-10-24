package com.pollosloscampos.service;

import com.pollosloscampos.dto.CategoriaRequest;
import com.pollosloscampos.entity.Categoria;
import com.pollosloscampos.exception.*;
import com.pollosloscampos.repository.CategoriaRepository;

import java.util.*;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class CategoriaService {
    final CategoriaRepository repo;

    public CategoriaService(CategoriaRepository r) {
        repo = r;
    }

    @Transactional(readOnly = true)
    public List<Categoria> listar() {
        return repo.findAllByOrderByNombreAsc();
    }

    @Transactional(readOnly = true)
    public List<Categoria> activas() {
        return repo.findByActivoTrueOrderByNombreAsc();
    }

    public Categoria obtener(Long id) {
        return repo.findById(id).orElseThrow(() -> new RecursoNoEncontradoException("Categoría no encontrada."));
    }

    public Categoria crear(CategoriaRequest r) {
        String n = r.getNombre().trim();
        if (repo.existsByNombreIgnoreCase(n)) throw new ReglaNegocioException("La categoría ya existe.");
        Categoria c = new Categoria();
        c.setNombre(n);
        c.setDescripcion(r.getDescripcion());
        return repo.save(c);
    }

    public Categoria actualizar(Long id, CategoriaRequest r) {
        Categoria c = obtener(id);
        String n = r.getNombre().trim();
        var x = repo.findByNombreIgnoreCase(n);
        if (x.isPresent() && !x.get().getId().equals(id)) throw new ReglaNegocioException("La categoría ya existe.");
        c.setNombre(n);
        c.setDescripcion(r.getDescripcion());
        return c;
    }

    public void toggle(Long id) {
        Categoria c = obtener(id);
        c.setActivo(!c.isActivo());
    }
}
