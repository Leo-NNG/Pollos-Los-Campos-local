package com.pollosloscampos;

import com.pollosloscampos.dto.ProductoRequest;
import com.pollosloscampos.entity.Categoria;
import com.pollosloscampos.entity.Producto;
import com.pollosloscampos.exception.ReglaNegocioException;
import com.pollosloscampos.repository.CategoriaRepository;
import com.pollosloscampos.repository.ProductoRepository;
import com.pollosloscampos.service.ProductoService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.test.util.ReflectionTestUtils;

import java.math.BigDecimal;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class ProductoServiceTest {

    @Mock ProductoRepository repo;
    @Mock CategoriaRepository cats;

    ProductoService service;

    @BeforeEach
    void setUp() {
        service = new ProductoService(repo, cats);
    }

    @Test
    void crearRechazaNombreDuplicadoSinGuardar() {
        when(cats.findById(1L)).thenReturn(Optional.of(new Categoria()));
        when(repo.existsByNombreIgnoreCase("1/4 de Pollo")).thenReturn(true);

        var ex = assertThrows(ReglaNegocioException.class, () -> service.crear(request("  1/4 de Pollo  ")));

        assertEquals("Ya existe un producto con ese nombre.", ex.getMessage());
        verify(repo, never()).save(any());
    }

    @Test
    void crearGuardaCuandoElNombreEsNuevo() {
        when(cats.findById(1L)).thenReturn(Optional.of(new Categoria()));
        when(repo.existsByNombreIgnoreCase("Pollo Nuevo")).thenReturn(false);

        service.crear(request("Pollo Nuevo"));

        verify(repo).save(any(Producto.class));
    }

    @Test
    void actualizarPermiteConservarSuPropioNombre() {
        Producto existente = new Producto();
        ReflectionTestUtils.setField(existente, "id", 5L);
        when(repo.findById(5L)).thenReturn(Optional.of(existente));
        when(cats.findById(1L)).thenReturn(Optional.of(new Categoria()));
        when(repo.existsByNombreIgnoreCaseAndIdNot("Pollo Nuevo", 5L)).thenReturn(false);

        service.actualizar(5L, request("Pollo Nuevo"));

        verify(repo).save(existente);
    }

    @Test
    void nombreEnUsoDistingueCrearDeActualizar() {
        when(repo.existsByNombreIgnoreCase("Chicha")).thenReturn(true);
        when(repo.existsByNombreIgnoreCaseAndIdNot("Chicha", 7L)).thenReturn(false);

        assertTrue(service.nombreEnUso("Chicha", null));
        assertFalse(service.nombreEnUso(" Chicha ", 7L));
    }

    private ProductoRequest request(String nombre) {
        ProductoRequest r = new ProductoRequest();
        r.setNombre(nombre);
        r.setDescripcion("Descripción de prueba");
        r.setPrecio(new BigDecimal("18.90"));
        r.setCategoriaId(1L);
        r.setDisponible(true);
        return r;
    }
}
