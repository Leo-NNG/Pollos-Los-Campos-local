package com.pollosloscampos.dto;

import jakarta.validation.constraints.*;

public class CategoriaRequest {
    @NotBlank
    @Size(max = 80)
    String nombre;
    @Size(max = 255)
    String descripcion;

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
}
