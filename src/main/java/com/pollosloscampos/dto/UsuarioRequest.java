package com.pollosloscampos.dto;

import jakarta.validation.constraints.*;

public class UsuarioRequest {
    @NotBlank
    @Size(max = 80)
    String nombres;
    @NotBlank
    @Size(max = 80)
    String apellidos;
    @NotBlank
    @Email
    @Size(max = 120)
    String correo;
    @NotBlank
    @Pattern(regexp = "9\\d{8}", message = "El celular debe tener 9 dígitos y comenzar con 9.")
    String celular;
    @NotBlank
    @Size(min = 6, max = 72)
    String password;
    @NotBlank
    String confirmarPassword;
    @Size(max = 60)
    String codigoAdmin;

    public String getNombres() {
        return nombres;
    }

    public void setNombres(String x) {
        nombres = x;
    }

    public String getApellidos() {
        return apellidos;
    }

    public void setApellidos(String x) {
        apellidos = x;
    }

    public String getCorreo() {
        return correo;
    }

    public void setCorreo(String x) {
        correo = x;
    }

    public String getCelular() {
        return celular;
    }

    public void setCelular(String x) {
        celular = x;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String x) {
        password = x;
    }

    public String getConfirmarPassword() {
        return confirmarPassword;
    }

    public void setConfirmarPassword(String x) {
        confirmarPassword = x;
    }

    public String getCodigoAdmin() {
        return codigoAdmin;
    }

    public void setCodigoAdmin(String x) {
        codigoAdmin = x;
    }

    public boolean passwordsMatch() {
        return password != null && password.equals(confirmarPassword);
    }
}
