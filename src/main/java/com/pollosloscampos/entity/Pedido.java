package com.pollosloscampos.entity;

import jakarta.persistence.*;
import org.hibernate.annotations.JdbcTypeCode;
import org.hibernate.type.SqlTypes;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.*;

@Entity
@Table(name = "pedidos")
public class Pedido {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    Long id;
    @Column(nullable = false, unique = true, length = 40)
    String codigoPedido;
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "usuario_id")
    Usuario usuario;
    @Column(nullable = false, length = 80)
    String nombreCliente;
    @Column(length = 80)
    String apellidosCliente;
    @Column(length = 120)
    String correoCliente;
    @Column(nullable = false, length = 20)
    String telefono;
    @Column(length = 180)
    String direccion;
    @Column(length = 120)
    String referencia;
    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.VARCHAR)
    @Column(nullable = false, length = 20)
    TipoEntrega tipoEntrega;
    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.VARCHAR)
    @Column(nullable = false, length = 20)
    MetodoPago metodoPago;
    @Column(nullable = false, precision = 10, scale = 2)
    BigDecimal subtotal;
    @Column(nullable = false, precision = 10, scale = 2)
    BigDecimal delivery;
    @Column(nullable = false, precision = 10, scale = 2)
    BigDecimal total;
    @Enumerated(EnumType.STRING)
    @JdbcTypeCode(SqlTypes.VARCHAR)
    @Column(nullable = false, length = 25)
    EstadoPedido estado = EstadoPedido.RECIBIDO;
    @Column(nullable = false)
    LocalDateTime fechaCreacion;
    @Column(nullable = false)
    LocalDateTime fechaActualizacion;
    @Column(length = 250)
    String notas;
    @OneToMany(mappedBy = "pedido", cascade = CascadeType.ALL, orphanRemoval = true)
    List<DetallePedido> detalles = new ArrayList<>();

    @PrePersist
    void pre() {
        var n = LocalDateTime.now();
        fechaCreacion = n;
        fechaActualizacion = n;
    }

    @PreUpdate
    void upd() {
        fechaActualizacion = LocalDateTime.now();
    }

    public Long getId() {
        return id;
    }

    public String getCodigoPedido() {
        return codigoPedido;
    }

    public void setCodigoPedido(String x) {
        codigoPedido = x;
    }

    public Usuario getUsuario() {
        return usuario;
    }

    public void setUsuario(Usuario x) {
        usuario = x;
    }

    public String getNombreCliente() {
        return nombreCliente;
    }

    public void setNombreCliente(String x) {
        nombreCliente = x;
    }

    public String getApellidosCliente() {
        return apellidosCliente;
    }

    public void setApellidosCliente(String x) {
        apellidosCliente = x;
    }

    public String getCorreoCliente() {
        return correoCliente;
    }

    public void setCorreoCliente(String x) {
        correoCliente = x;
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

    public TipoEntrega getTipoEntrega() {
        return tipoEntrega;
    }

    public void setTipoEntrega(TipoEntrega x) {
        tipoEntrega = x;
    }

    public MetodoPago getMetodoPago() {
        return metodoPago;
    }

    public void setMetodoPago(MetodoPago x) {
        metodoPago = x;
    }

    public BigDecimal getSubtotal() {
        return subtotal;
    }

    public void setSubtotal(BigDecimal x) {
        subtotal = x;
    }

    public BigDecimal getDelivery() {
        return delivery;
    }

    public void setDelivery(BigDecimal x) {
        delivery = x;
    }

    public BigDecimal getTotal() {
        return total;
    }

    public void setTotal(BigDecimal x) {
        total = x;
    }

    public EstadoPedido getEstado() {
        return estado;
    }

    public void setEstado(EstadoPedido x) {
        estado = x;
    }

    public LocalDateTime getFechaCreacion() {
        return fechaCreacion;
    }

    public LocalDateTime getFechaActualizacion() {
        return fechaActualizacion;
    }

    public String getNotas() {
        return notas;
    }

    public void setNotas(String x) {
        notas = x;
    }

    public List<DetallePedido> getDetalles() {
        return detalles;
    }
}
