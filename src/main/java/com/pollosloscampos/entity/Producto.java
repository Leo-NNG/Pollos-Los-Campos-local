package com.pollosloscampos.entity;

import jakarta.persistence.*;

import java.math.BigDecimal;
import java.time.LocalDateTime;

@Entity
@Table(name = "productos")
public class Producto {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id;
    @Column(nullable = false, length = 100)
    String nombre;
    @Column(nullable = false, length = 255)
    String descripcion;
    @Column(nullable = false, precision = 10, scale = 2)
    BigDecimal precio;
    @Column(length = 255)
    String imagen;
    @ManyToOne(fetch = FetchType.EAGER, optional = false)
    @JoinColumn(name = "categoria_id", nullable = false)
    Categoria categoria;
    @Column(nullable = false)
    boolean disponible = true;
    @Column(nullable = false)
    boolean destacado = false;
    @Column(length = 50)
    String etiqueta;
    @Column(nullable = false)
    LocalDateTime fechaRegistro;

    @PrePersist
    void pre() {
        fechaRegistro = LocalDateTime.now();
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

    public String getImagen() {
        return imagen;
    }

    public void setImagen(String x) {
        imagen = x;
    }

    public Categoria getCategoria() {
        return categoria;
    }

    public void setCategoria(Categoria x) {
        categoria = x;
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

    public String getEtiqueta() {
        return etiqueta;
    }

    public void setEtiqueta(String x) {
        etiqueta = x;
    }

    public LocalDateTime getFechaRegistro() {
        return fechaRegistro;
    }
}
