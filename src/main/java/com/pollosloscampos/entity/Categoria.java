package com.pollosloscampos.entity;

import jakarta.persistence.*;

import java.util.*;

@Entity
@Table(name = "categorias")
public class Categoria {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id;
    @Column(nullable = false, unique = true, length = 80)
    String nombre;
    @Column(length = 255)
    String descripcion;
    @Column(nullable = false)
    boolean activo = true;
    @OneToMany(mappedBy = "categoria")
    List<Producto> productos = new ArrayList<>();

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

    public boolean isActivo() {
        return activo;
    }

    public void setActivo(boolean x) {
        activo = x;
    }

    public List<Producto> getProductos() {
        return productos;
    }
}
