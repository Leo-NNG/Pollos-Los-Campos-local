package com.pollosloscampos.entity;

import jakarta.persistence.*;

import java.math.BigDecimal;
import java.time.*;

@Entity
@Table(name = "promociones")
public class Promocion {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id;
    @Column(nullable = false, length = 120)
    String nombre;
    @Column(length = 255)
    String descripcion;
    @Column(precision = 10, scale = 2)
    BigDecimal precioAnterior;
    @Column(nullable = false, precision = 10, scale = 2)
    BigDecimal precioPromocional;
    @Column(nullable = false)
    LocalDate fechaInicio;
    @Column(nullable = false)
    LocalDate fechaFin;
    @Column(length = 255)
    String imagen;
    @Column(nullable = false)
    int stock = 0;
    @Column(nullable = false)
    boolean activa = true;
    @Column(nullable = false)
    LocalDateTime fechaRegistro;

    @PrePersist
    void pre() {
        fechaRegistro = LocalDateTime.now();
    }

    public Long getId() {
        return id;
    }

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String x) {
        nombre = x;
    }

    public String getDescripcion() {
        return descripcion;
    }

    public void setDescripcion(String x) {
        descripcion = x;
    }

    public BigDecimal getPrecioAnterior() {
        return precioAnterior;
    }

    public void setPrecioAnterior(BigDecimal x) {
        precioAnterior = x;
    }

    public BigDecimal getPrecioPromocional() {
        return precioPromocional;
    }

    public void setPrecioPromocional(BigDecimal x) {
        precioPromocional = x;
    }

    public LocalDate getFechaInicio() {
        return fechaInicio;
    }

    public void setFechaInicio(LocalDate x) {
        fechaInicio = x;
    }

    public LocalDate getFechaFin() {
        return fechaFin;
    }

    public void setFechaFin(LocalDate x) {
        fechaFin = x;
    }

    public String getImagen() {
        return imagen;
    }

    public void setImagen(String x) {
        imagen = x;
    }

    public int getStock() {
        return stock;
    }

    public void setStock(int x) {
        stock = x;
    }

    public boolean isActiva() {
        return activa;
    }

    public void setActiva(boolean x) {
        activa = x;
    }

    public LocalDateTime getFechaRegistro() {
        return fechaRegistro;
    }
}
