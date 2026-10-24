package com.pollosloscampos.entity;

import jakarta.persistence.*;

import java.math.BigDecimal;

@Entity
@Table(name = "detalle_pedidos")
public class DetallePedido {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id;
    @ManyToOne(fetch = FetchType.EAGER, optional = false)
    @JoinColumn(name = "pedido_id", nullable = false)
    Pedido pedido;
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "producto_id", nullable = false)
    Producto producto;
    @Column(nullable = false)
    Integer cantidad;
    @Column(nullable = false, precision = 10, scale = 2)
    BigDecimal precioUnitario;
    @Column(nullable = false, precision = 10, scale = 2)
    BigDecimal subtotal;

    public Long getId() {
        return id;
    }

    public Pedido getPedido() {
        return pedido;
    }

    public void setPedido(Pedido x) {
        pedido = x;
    }

    public Producto getProducto() {
        return producto;
    }

    public void setProducto(Producto x) {
        producto = x;
    }

    public Integer getCantidad() {
        return cantidad;
    }

    public void setCantidad(Integer x) {
        cantidad = x;
    }

    public BigDecimal getPrecioUnitario() {
        return precioUnitario;
    }

    public void setPrecioUnitario(BigDecimal x) {
        precioUnitario = x;
    }

    public BigDecimal getSubtotal() {
        return subtotal;
    }

    public void setSubtotal(BigDecimal x) {
        subtotal = x;
    }
}
