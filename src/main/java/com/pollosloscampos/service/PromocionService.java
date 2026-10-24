package com.pollosloscampos.service;

import com.pollosloscampos.dto.PromocionRequest;
import com.pollosloscampos.entity.Promocion;
import com.pollosloscampos.exception.*;
import com.pollosloscampos.repository.PromocionRepository;

import java.time.LocalDate;
import java.util.*;

import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@Transactional
public class PromocionService {
    final PromocionRepository repo;

    public PromocionService(PromocionRepository r) {
        repo = r;
    }

    @Transactional(readOnly = true)
    public List<Promocion> listar() {
        return repo.findAllByOrderByFechaInicioDesc();
    }

    @Transactional(readOnly = true)
    public List<Promocion> vigentes() {
        return repo.vigentes(LocalDate.now());
    }

    public Promocion obtener(Long id) {
        return repo.findById(id).orElseThrow(() -> new RecursoNoEncontradoException("Promoción no encontrada."));
    }

    public Promocion crear(PromocionRequest r) {
        return save(new Promocion(), r);
    }

    public Promocion actualizar(Long id, PromocionRequest r) {
        return save(obtener(id), r);
    }

    private Promocion save(Promocion p, PromocionRequest r) {
        if (r.getFechaFin().isBefore(r.getFechaInicio()))
            throw new ReglaNegocioException("La fecha fin no puede ser anterior a la fecha inicio.");
        if (r.getPrecioAnterior() != null && r.getPrecioPromocional().compareTo(r.getPrecioAnterior()) > 0)
            throw new ReglaNegocioException("El precio promocional no puede superar el precio anterior.");
        p.setNombre(r.getNombre().trim());
        p.setDescripcion(r.getDescripcion());
        p.setPrecioAnterior(r.getPrecioAnterior());
        p.setPrecioPromocional(r.getPrecioPromocional());
        p.setFechaInicio(r.getFechaInicio());
        p.setFechaFin(r.getFechaFin());
        p.setImagen(r.getImagen());
        p.setStock(r.getStock() == null ? 0 : r.getStock());
        p.setActiva(r.isActiva());
        return repo.save(p);
    }

    public void ajustarStock(Long id, int delta) {
        Promocion p = obtener(id);
        int nuevo = p.getStock() + delta;
        if (nuevo < 0) nuevo = 0;
        p.setStock(nuevo);
    }

    public void toggle(Long id) {
        Promocion p = obtener(id);
        p.setActiva(!p.isActiva());
    }

    /**
     * Eliminación LÓGICA: no se borra la fila de la tabla promociones, solo se marca activa = false.
     * La promoción deja de mostrarse en el sitio y en las consultas de vigentes, pero el registro
     * (y su historial) se conserva en la base de datos y puede restaurarse con {@link #toggle(Long)}.
     */
    public void eliminar(Long id) {
        Promocion p = obtener(id);
        p.setActiva(false);
        repo.save(p);
    }
}
