package com.pollosloscampos;

import com.pollosloscampos.entity.Promocion;
import com.pollosloscampos.repository.PromocionRepository;
import com.pollosloscampos.service.PromocionService;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class PromocionServiceTest {

    @Mock
    PromocionRepository repo;

    PromocionService service;

    @BeforeEach
    void setUp() {
        service = new PromocionService(repo);
    }

    @Test
    void eliminarEsLogicoYNoBorraLaFila() {
        Promocion p = new Promocion();
        p.setActiva(true);
        when(repo.findById(1L)).thenReturn(Optional.of(p));

        service.eliminar(1L);

        assertFalse(p.isActiva(), "La promoción debe quedar marcada como inactiva");
        verify(repo).save(p);
        verify(repo, never()).delete(any(Promocion.class));
        verify(repo, never()).deleteById(any());
    }

    @Test
    void toggleRestauraUnaPromocionEliminada() {
        Promocion p = new Promocion();
        p.setActiva(false);
        when(repo.findById(2L)).thenReturn(Optional.of(p));

        service.toggle(2L);

        assertTrue(p.isActiva(), "Restaurar debe volver a activar la promoción");
    }
}
