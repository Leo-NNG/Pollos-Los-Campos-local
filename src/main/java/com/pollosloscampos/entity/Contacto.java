package com.pollosloscampos.entity;

import jakarta.persistence.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "contactos")
public class Contacto {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id;
    @Column(nullable = false, length = 80)
    String nombre;
    @Column(length = 120)
    String correo;
    @Column(length = 20)
    String telefono;
    @Column(nullable = false, length = 60)
    String motivo;
    @Column(nullable = false, length = 500)
    String mensaje;
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 15)
    EstadoContacto estado = EstadoContacto.NUEVO;
    @Column(nullable = false)
    LocalDateTime fechaCreacion;

    @PrePersist
    void pre() {
        fechaCreacion = LocalDateTime.now();
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

    public EstadoContacto getEstado() {
        return estado;
    }

    public void setEstado(EstadoContacto x) {
        estado = x;
    }

    public LocalDateTime getFechaCreacion() {
        return fechaCreacion;
    }
}
