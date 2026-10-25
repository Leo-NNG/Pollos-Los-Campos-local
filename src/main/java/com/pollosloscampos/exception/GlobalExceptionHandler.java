package com.pollosloscampos.exception;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.util.*;

import org.slf4j.*;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.http.*;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.ui.Model;
import org.springframework.web.HttpRequestMethodNotSupportedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;
import org.springframework.web.servlet.resource.NoResourceFoundException;

@ControllerAdvice
public class GlobalExceptionHandler {
    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    /** Respuesta JSON para /api/** o página de error (con su código HTTP real) para el sitio web. */
    private Object responder(HttpServletRequest r, HttpServletResponse resp, Model m, int status, String vista, String mensaje) {
        if (r.getRequestURI().startsWith("/api/"))
            return ResponseEntity.status(status).body(Map.of("status", status, "message", mensaje));
        resp.setStatus(status);
        m.addAttribute("detalle", mensaje);
        return vista;
    }

    @ExceptionHandler(RecursoNoEncontradoException.class)
    public Object nf(RecursoNoEncontradoException e, HttpServletRequest r, HttpServletResponse resp, Model m) {
        return responder(r, resp, m, 404, "error/404", e.getMessage());
    }

    /** Ruta o recurso estático inexistente: 404 (antes caía en el manejador genérico y daba 500). */
    @ExceptionHandler(NoResourceFoundException.class)
    public Object noResource(NoResourceFoundException e, HttpServletRequest r, HttpServletResponse resp, Model m) {
        return responder(r, resp, m, 404, "error/404", "La página que buscas no existe.");
    }

    @ExceptionHandler(ReglaNegocioException.class)
    public Object business(ReglaNegocioException e, HttpServletRequest r, HttpServletResponse resp, Model m) {
        log.warn("Regla de negocio en {}: {}", r.getRequestURI(), e.getMessage());
        return responder(r, resp, m, 409, "error/500", e.getMessage());
    }

    /** Una restricción de la BD (UNIQUE, CHECK, FK) rechazó el dato: conflicto, no error interno. */
    @ExceptionHandler(DataIntegrityViolationException.class)
    public Object integrity(DataIntegrityViolationException e, HttpServletRequest r, HttpServletResponse resp, Model m) {
        log.warn("Restricción de base de datos en {}: {}", r.getRequestURI(), e.getMostSpecificCause().getMessage());
        return responder(r, resp, m, 409, "error/500", "Los datos entran en conflicto con una restricción de la base de datos.");
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public Object validation(MethodArgumentNotValidException e, HttpServletRequest r, HttpServletResponse resp, Model m) {
        var errors = new LinkedHashMap<String, String>();
        e.getBindingResult().getFieldErrors().forEach(x -> errors.put(x.getField(), x.getDefaultMessage()));
        if (r.getRequestURI().startsWith("/api/"))
            return ResponseEntity.badRequest().body(Map.of("status", 400, "message", "Datos inválidos", "errors", errors));
        return responder(r, resp, m, 400, "error/500", errors.toString());
    }

    @ExceptionHandler({HttpMessageNotReadableException.class, MethodArgumentTypeMismatchException.class})
    public Object badRequest(Exception e, HttpServletRequest r, HttpServletResponse resp, Model m) {
        return responder(r, resp, m, 400, "error/500", "La solicitud no es válida: revisa el formato de los datos.");
    }

    @ExceptionHandler(HttpRequestMethodNotSupportedException.class)
    public Object methodNotAllowed(HttpRequestMethodNotSupportedException e, HttpServletRequest r, HttpServletResponse resp, Model m) {
        return responder(r, resp, m, 405, "error/500", "Método no permitido para esta ruta.");
    }

    /** Para /api/** responde JSON 403; para el sitio web se relanza y Spring Security muestra la página /403. */
    @ExceptionHandler(AccessDeniedException.class)
    public Object denied(AccessDeniedException e, HttpServletRequest r) {
        if (r.getRequestURI().startsWith("/api/"))
            return ResponseEntity.status(403).body(Map.of("status", 403, "message", "Acceso denegado."));
        throw e;
    }

    @ExceptionHandler(Exception.class)
    public Object other(Exception e, HttpServletRequest r, HttpServletResponse resp, Model m) {
        log.error("Error no controlado en {}", r.getRequestURI(), e);
        return responder(r, resp, m, 500, "error/500", "Ocurrió un error inesperado. Intenta nuevamente.");
    }
}
