package com.pollosloscampos.dto;

import jakarta.validation.constraints.*;

import java.math.BigDecimal;
import java.time.LocalDate;

public class PromocionRequest {
    @NotBlank
    @Size(max = 120)
    String nombre;
    @Size(max = 255)
    String descripcion;
    @PositiveOrZero
    BigDecimal precioAnterior;
    @NotNull
    @Positive
    BigDecimal precioPromocional;
    @NotNull
    LocalDate fechaInicio;
    @NotNull
    LocalDate fechaFin;
    @Size(max = 255)
    String imagen;
    @PositiveOrZero
    Integer stock = 0;
    boolean activa = true;

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

    public Integer getStock() {
        return stock;
    }

    public void setStock(Integer x) {
        stock = x;
    }

    public boolean isActiva() {
        return activa;
    }

    public void setActiva(boolean x) {
        activa = x;
    }
}
