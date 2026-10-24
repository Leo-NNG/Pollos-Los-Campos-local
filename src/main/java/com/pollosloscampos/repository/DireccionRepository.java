package com.pollosloscampos.repository;

import com.pollosloscampos.entity.Direccion;

import java.util.*;

import org.springframework.data.jpa.repository.JpaRepository;

public interface DireccionRepository extends JpaRepository<Direccion, Long> {
    List<Direccion> findByUsuarioIdAndActivaTrue(Long id);
}
