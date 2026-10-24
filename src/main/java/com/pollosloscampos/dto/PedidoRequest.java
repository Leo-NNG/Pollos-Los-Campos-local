package com.pollosloscampos.dto;

import jakarta.validation.constraints.*;

import java.util.*;

public class PedidoRequest {
    @NotBlank
    @Size(max = 80)
    String nombre;
    @NotBlank
    @Size(max = 80)
    String apellidos;
    @NotBlank
    @Email
    @Size(max = 120)
    String correo;
    @NotBlank
    @Pattern(regexp = "9\\d{8}", message = "El celular debe tener 9 dígitos y comenzar con 9.")
    String telefono;
    @Size(max = 180)
    String direccion;
    @Size(max = 120)
    String referencia;
    @NotBlank
    String tipoEntrega;
    @NotBlank
    String metodoPago;
    @Size(max = 250)
    String notas;
    String carrito;
    List<Item> items = new ArrayList<>();

    public String getNombre() {
        return nombre;
    }

    public void setNombre(String x) {
        nombre = x;
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

    public String getTelefono() {
        return telefono;
    }

    public void setTelefono(String x) {
        telefono = x;
    }

    public String getDireccion() {
        return direccion;
    }

    public void setDireccion(String x) {
        direccion = x;
    }

    public String getReferencia() {
        return referencia;
    }

    public void setReferencia(String x) {
        referencia = x;
    }

    public String getTipoEntrega() {
        return tipoEntrega;
    }

    public void setTipoEntrega(String x) {
        tipoEntrega = x;
    }

    public String getMetodoPago() {
        return metodoPago;
    }

    public void setMetodoPago(String x) {
        metodoPago = x;
    }

    public String getNotas() {
        return notas;
    }

    public void setNotas(String x) {
        notas = x;
    }

    public String getCarrito() {
        return carrito;
    }

    public void setCarrito(String x) {
        carrito = x;
    }

    public List<Item> getItems() {
        return items;
    }

    public void setItems(List<Item> x) {
        items = x;
    }

    public record Item(Long productoId, @Min(1) @Max(20) int cantidad) {
    }
}
