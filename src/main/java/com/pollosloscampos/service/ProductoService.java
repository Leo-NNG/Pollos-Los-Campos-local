package com.pollosloscampos.service;

import com.pollosloscampos.dto.ProductoRequest;
import com.pollosloscampos.entity.*;
import com.pollosloscampos.exception.*;
import com.pollosloscampos.repository.*;

import java.util.*;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class ProductoService {
    final ProductoRepository repo;
    final CategoriaRepository cats;

    public ProductoService(ProductoRepository r, CategoriaRepository c) {
        repo = r;
        cats = c;
    }

    @Transactional(readOnly = true)
    public List<Producto> listar() {
        return repo.findAllByOrderByNombreAsc();
    }

    @Transactional(readOnly = true)
    public List<Producto> destacados() {
        return repo.findByDisponibleTrueAndDestacadoTrueOrderByNombreAsc();
    }

    @Transactional(readOnly = true)
    public List<Producto> buscar(String q, Long cat, Boolean disp, Boolean dest, String sort) {
        var l = new ArrayList<>(repo.buscar(blank(q) ? null : q.trim(), cat, disp, dest));
        Comparator<Producto> cmp = Comparator.comparing(Producto::getNombre, String.CASE_INSENSITIVE_ORDER);
        if ("precioAsc".equals(sort)) cmp = Comparator.comparing(Producto::getPrecio);
        if ("precioDesc".equals(sort)) cmp = Comparator.comparing(Producto::getPrecio).reversed();
        return l.stream().sorted(cmp).toList();
    }

    @Transactional(readOnly = true)
    public Producto obtener(Long id) {
        return repo.findById(id).orElseThrow(() -> new RecursoNoEncontradoException("Producto no encontrado."));
    }

    public Producto crear(ProductoRequest r) {
        return fill(new Producto(), r);
    }

    public Producto actualizar(Long id, ProductoRequest r) {
        return fill(obtener(id), r);
    }

    private Producto fill(Producto p, ProductoRequest r) {
        Categoria c = cats.findById(r.getCategoriaId()).orElseThrow(() -> new RecursoNoEncontradoException("Categoría no encontrada."));
        if (!c.isActivo()) throw new ReglaNegocioException("La categoría está inactiva.");
        String nombre = r.getNombre().trim();
        if (nombreEnUso(nombre, p.getId()))
            throw new ReglaNegocioException("Ya existe un producto con ese nombre.");
        p.setNombre(nombre);
        p.setDescripcion(r.getDescripcion().trim());
        p.setPrecio(r.getPrecio());
        p.setCategoria(c);
        p.setImagen(blank(r.getImagen()) ? "/images/productos/quarter.svg" : r.getImagen().trim());
        p.setEtiqueta(r.getEtiqueta());
        p.setDisponible(r.isDisponible());
        p.setDestacado(r.isDestacado());
        return repo.save(p);
    }

    /** true si otro producto (distinto de idActual) ya usa ese nombre; coincide con la restricción UNIQUE de la BD. */
    @Transactional(readOnly = true)
    public boolean nombreEnUso(String nombre, Long idActual) {
        String n = nombre.trim();
        return idActual == null ? repo.existsByNombreIgnoreCase(n) : repo.existsByNombreIgnoreCaseAndIdNot(n, idActual);
    }

    public void toggle(Long id) {
        Producto p = obtener(id);
        p.setDisponible(!p.isDisponible());
    }

    boolean blank(String s) {
        return s == null || s.isBlank();
    }
}
