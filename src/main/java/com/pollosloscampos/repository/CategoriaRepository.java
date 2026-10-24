package com.pollosloscampos.repository;

import com.pollosloscampos.entity.Categoria;

import java.util.*;

import org.springframework.data.jpa.repository.JpaRepository;

public interface CategoriaRepository extends JpaRepository<Categoria, Long> {
    Optional<Categoria> findByNombreIgnoreCase(String n);

    boolean existsByNombreIgnoreCase(String n);

    List<Categoria> findAllByOrderByNombreAsc();

    List<Categoria> findByActivoTrueOrderByNombreAsc();
}
