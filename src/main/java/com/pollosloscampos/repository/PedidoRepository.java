package com.pollosloscampos.repository;

import com.pollosloscampos.entity.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;

import org.springframework.data.jpa.repository.*;
import org.springframework.data.repository.query.Param;

public interface PedidoRepository extends JpaRepository<Pedido, Long> {
    @Query("select distinct p from Pedido p left join fetch p.detalles d join fetch d.producto pr where p.id=:id")
    Optional<Pedido> findWithDetails(@Param("id") Long id);

    @Query("select distinct p from Pedido p join fetch p.detalles d join fetch d.producto pr where lower(p.codigoPedido)=lower(:codigo) and p.telefono=:telefono")
    Optional<Pedido> findTracking(@Param("codigo") String codigo, @Param("telefono") String telefono);

    List<Pedido> findAllByOrderByFechaCreacionDesc();

    List<Pedido> findByUsuarioIdOrderByFechaCreacionDesc(Long id);

    long countByEstado(EstadoPedido e);

    long countByEstadoIn(Collection<EstadoPedido> e);

    long countByUsuarioId(Long id);

    @Query("select coalesce(sum(p.total),0) from Pedido p where p.fechaCreacion between :i and :f and p.estado<>com.pollosloscampos.entity.EstadoPedido.CANCELADO")
    BigDecimal ventasEntre(@Param("i") LocalDateTime i, @Param("f") LocalDateTime f);
}
