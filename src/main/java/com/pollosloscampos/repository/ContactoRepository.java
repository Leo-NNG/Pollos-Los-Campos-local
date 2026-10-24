package com.pollosloscampos.repository;

import com.pollosloscampos.entity.*;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ContactoRepository extends JpaRepository<Contacto, Long> {
    long countByEstado(EstadoContacto e);
}
