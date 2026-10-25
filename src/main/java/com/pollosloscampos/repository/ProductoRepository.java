package com.pollosloscampos.repository;

import com.pollosloscampos.entity.Producto;

import java.util.*;

import org.springframework.data.jpa.repository.*;
import org.springframework.data.repository.query.Param;

public interface ProductoRepository extends JpaRepository<Producto, Long> {
    List<Producto> findAllByOrderByNombreAsc();

    boolean existsByNombreIgnoreCase(String nombre);

    boolean existsByNombreIgnoreCaseAndIdNot(String nombre, Long id);

    List<Producto> findByDisponibleTrueAndDestacadoTrueOrderByNombreAsc();

    List<Producto> findByDisponibleTrueOrderByNombreAsc();

    @Query("select p from Producto p join fetch p.categoria c where (:categoriaId is null or c.id=:categoriaId) and (:q is null or lower(p.nombre) like lower(concat('%',:q,'%')) or lower(p.descripcion) like lower(concat('%',:q,'%'))) and (:disponible is null or p.disponible=:disponible) and (:destacado is null or p.destacado=:destacado)")
    List<Producto> buscar(@Param("q") String q, @Param("categoriaId") Long categoriaId, @Param("disponible") Boolean disponible, @Param("destacado") Boolean destacado);
}
