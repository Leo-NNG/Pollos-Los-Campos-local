package com.pollosloscampos.entity;

import jakarta.persistence.*;

import java.time.LocalDateTime;
import java.util.*;

@Entity
@Table(name = "usuarios")
public class Usuario {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    @Column(nullable = false, length = 80)
    private String nombres;
    @Column(nullable = false, length = 80)
    private String apellidos;
    @Column(nullable = false, unique = true, length = 120)
    private String correo;
    @Column(nullable = false, length = 100)
    private String password;
    @Column(length = 20)
    private String celular;
    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private Rol rol = Rol.ROLE_CLIENTE;
    @Column(nullable = false)
    private boolean activo = true;
    @Column(nullable = false)
    private LocalDateTime fechaRegistro;
    @OneToMany(mappedBy = "usuario")
    private List<Pedido> pedidos = new ArrayList<>();
    @OneToMany(mappedBy = "usuario")
    private List<Direccion> direcciones = new ArrayList<>();

    @PrePersist
    void pre() {
        fechaRegistro = LocalDateTime.now();
    }

    public Long getId() {
        return id;
    }

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

    public String getPassword() {
        return password;
    }

    public void setPassword(String x) {
        password = x;
    }

    public String getCelular() {
        return celular;
    }

    public void setCelular(String x) {
        celular = x;
    }

    public Rol getRol() {
        return rol;
    }

    public void setRol(Rol x) {
        rol = x;
    }

    public boolean isActivo() {
        return activo;
    }

    public void setActivo(boolean x) {
        activo = x;
    }

    public LocalDateTime getFechaRegistro() {
        return fechaRegistro;
    }

    public List<Pedido> getPedidos() {
        return pedidos;
    }

    public List<Direccion> getDirecciones() {
        return direcciones;
    }
}
