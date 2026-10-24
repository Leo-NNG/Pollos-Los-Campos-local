package com.pollosloscampos.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "direcciones")
public class Direccion {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id;
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "usuario_id", nullable = false)
    Usuario usuario;
    @Column(nullable = false, length = 180)
    String direccion;
    @Column(length = 120)
    String referencia;
    @Column(nullable = false, length = 80)
    String distrito;
    @Column(nullable = false)
    boolean principal;
    @Column(nullable = false)
    boolean activa = true;

    public Long getId() {
        return id;
    }

    public Usuario getUsuario() {
        return usuario;
    }

    public void setUsuario(Usuario x) {
        usuario = x;
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

    public String getDistrito() {
        return distrito;
    }

    public void setDistrito(String x) {
        distrito = x;
    }

    public boolean isPrincipal() {
        return principal;
    }

    public void setPrincipal(boolean x) {
        principal = x;
    }

    public boolean isActiva() {
        return activa;
    }

    public void setActiva(boolean x) {
        activa = x;
    }
}
