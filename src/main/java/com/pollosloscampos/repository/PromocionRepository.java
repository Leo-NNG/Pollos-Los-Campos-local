package com.pollosloscampos.repository;

import com.pollosloscampos.entity.Promocion;

import java.time.LocalDate;
import java.util.*;

import org.springframework.data.jpa.repository.*;
import org.springframework.data.repository.query.Param;

public interface PromocionRepository extends JpaRepository<Promocion, Long> {
    @Query("select p from Promocion p where p.activa=true and :f between p.fechaInicio and p.fechaFin order by p.fechaFin asc")
    List<Promocion> vigentes(@Param("f") LocalDate f);

    List<Promocion> findAllByOrderByFechaInicioDesc();
}
