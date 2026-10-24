package com.pollosloscampos.dto;

import jakarta.validation.constraints.*;

import java.math.BigDecimal;

public class ProductoRequest {
    @NotBlank
    @Size(max = 100)
    String nombre;
    @NotBlank
    @Size(max = 255)
    String descripcion;
    @NotNull
    @Positive
    BigDecimal precio;
    @NotNull
    Long categoriaId;
    @Size(max = 255)
    String imagen;
    @Size(max = 50)
    String etiqueta;
    boolean disponible = true;
    boolean destacado;

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

    public BigDecimal getPrecio() {
        return precio;
    }

    public void setPrecio(BigDecimal x) {
        precio = x;
    }

    public Long getCategoriaId() {
        return categoriaId;
    }

    public void setCategoriaId(Long x) {
        categoriaId = x;
    }

    public String getImagen() {
        return imagen;
    }

    public void setImagen(String x) {
        imagen = x;
    }

    public String getEtiqueta() {
        return etiqueta;
    }

    public void setEtiqueta(String x) {
        etiqueta = x;
    }

    public boolean isDisponible() {
        return disponible;
    }

    public void setDisponible(boolean x) {
        disponible = x;
    }

    public boolean isDestacado() {
        return destacado;
    }

    public void setDestacado(boolean x) {
        destacado = x;
    }
}
