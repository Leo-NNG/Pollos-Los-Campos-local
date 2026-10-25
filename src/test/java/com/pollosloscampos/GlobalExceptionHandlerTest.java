package com.pollosloscampos;

import com.pollosloscampos.exception.GlobalExceptionHandler;
import com.pollosloscampos.exception.ReglaNegocioException;
import org.junit.jupiter.api.Test;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.ResponseEntity;
import org.springframework.mock.web.MockHttpServletRequest;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.ui.ExtendedModelMap;
import org.springframework.ui.Model;

import static org.junit.jupiter.api.Assertions.*;

class GlobalExceptionHandlerTest {

    final GlobalExceptionHandler handler = new GlobalExceptionHandler();

    private MockHttpServletRequest req(String uri) {
        MockHttpServletRequest r = new MockHttpServletRequest("GET", uri);
        r.setRequestURI(uri);
        return r;
    }

    @Test
    void accesoDenegadoEnApiResponde403Json() {
        Object res = handler.denied(new AccessDeniedException("no"), req("/api/pedidos/1"));
        assertEquals(403, ((ResponseEntity<?>) res).getStatusCode().value());
    }

    @Test
    void accesoDenegadoEnWebSeRelanzaParaQueSecurityMuestreLa403() {
        assertThrows(AccessDeniedException.class,
                () -> handler.denied(new AccessDeniedException("no"), req("/admin/productos")));
    }

    @Test
    void errorInesperadoNoFiltraDetallesInternos() {
        Model m = new ExtendedModelMap();
        MockHttpServletResponse resp = new MockHttpServletResponse();

        Object vista = handler.other(new NullPointerException("clave-secreta"), req("/menu"), resp, m);

        assertEquals("error/500", vista);
        assertEquals(500, resp.getStatus());
        String detalle = String.valueOf(m.getAttribute("detalle"));
        assertFalse(detalle.contains("NullPointer"));
        assertFalse(detalle.contains("clave-secreta"));
    }

    @Test
    void reglaDeNegocioEnWebUsaCodigo409() {
        Model m = new ExtendedModelMap();
        MockHttpServletResponse resp = new MockHttpServletResponse();

        Object vista = handler.business(new ReglaNegocioException("Producto no disponible."), req("/pedido/crear"), resp, m);

        assertEquals("error/500", vista);
        assertEquals(409, resp.getStatus());
        assertEquals("Producto no disponible.", m.getAttribute("detalle"));
    }

    @Test
    void violacionDeRestriccionEnApiResponde409() {
        Object res = handler.integrity(new DataIntegrityViolationException("uq_productos_nombre"),
                req("/api/productos"), new MockHttpServletResponse(), new ExtendedModelMap());
        assertEquals(409, ((ResponseEntity<?>) res).getStatusCode().value());
    }
}
