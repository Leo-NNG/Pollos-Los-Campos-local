package com.pollosloscampos.dto;

import jakarta.validation.constraints.*;

public class ContactoRequest {
    @NotBlank
    @Size(max = 80)
    String nombre;
    @Email
    @Size(max = 120)
    String correo;
    @Size(max = 20)
    String telefono;
    @NotBlank
    @Size(max = 60)
    String motivo;
    @NotBlank
    @Size(min = 10, max = 500)
    String mensaje;

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String x) {
        nombre = x;
    }

    public String getCorreo() {
        return correo;
    }

    public void setCorreo(String x) {
        correo = x;
    }

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String x) {
        telefono = x;
    }

    public String getMotivo() {
        return motivo;
    }

    public void setMotivo(String x) {
        motivo = x;
    }

    public String getMensaje() {
        return mensaje;
    }

    public void setMensaje(String x) {
        mensaje = x;
    }
}
