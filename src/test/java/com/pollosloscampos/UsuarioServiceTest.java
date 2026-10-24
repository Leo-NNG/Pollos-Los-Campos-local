package com.pollosloscampos;

import com.pollosloscampos.dto.UsuarioRequest;
import com.pollosloscampos.entity.Usuario;
import com.pollosloscampos.exception.ReglaNegocioException;
import com.pollosloscampos.repository.UsuarioRepository;
import com.pollosloscampos.service.UsuarioService;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.crypto.password.PasswordEncoder;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.*;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UsuarioServiceTest {
    @Mock UsuarioRepository repo;
    @Mock PasswordEncoder encoder;
    UsuarioService service;

    @BeforeEach
    void setUp(){ service = new UsuarioService(repo, encoder); }

    @Test
    void rechazaCorreoDuplicado(){
        when(repo.existsByCorreoIgnoreCase("cliente@example.com")).thenReturn(true);
        var r = new UsuarioRequest(); r.setNombres("Cliente");r.setApellidos("Prueba");r.setCorreo("cliente@example.com");r.setCelular("999999999");r.setPassword("Secret123");r.setConfirmarPassword("Secret123");
        assertThrows(ReglaNegocioException.class, () -> service.registrarCliente(r));
        verify(encoder, never()).encode(anyString());
    }

    @Test
    void almacenaPasswordCodificada(){
        when(repo.existsByCorreoIgnoreCase(anyString())).thenReturn(false);
        when(encoder.encode("Secret123")).thenReturn("{bcrypt}hash");
        when(repo.save(any(Usuario.class))).thenAnswer(inv -> inv.getArgument(0));
        var r = new UsuarioRequest(); r.setNombres("Cliente");r.setApellidos("Prueba");r.setCorreo("Cliente@Example.com");r.setCelular("999999999");r.setPassword("Secret123");r.setConfirmarPassword("Secret123");
        var u = service.registrarCliente(r);
        assertEquals("{bcrypt}hash", u.getPassword());
        assertNotEquals("Secret123", u.getPassword());
        verify(encoder).encode("Secret123");
    }
}
