package com.pollosloscampos.exception;

import jakarta.servlet.http.HttpServletRequest;

import java.util.*;

import org.slf4j.*;
import org.springframework.http.*;
import org.springframework.ui.Model;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.*;

@ControllerAdvice
public class GlobalExceptionHandler {
    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(RecursoNoEncontradoException.class)
    public Object nf(RecursoNoEncontradoException e, HttpServletRequest r) {
        if (r.getRequestURI().startsWith("/api/"))
            return ResponseEntity.status(404).body(Map.of("status", 404, "message", e.getMessage()));
        return "error/404";
    }

    @ExceptionHandler(ReglaNegocioException.class)
    public Object business(ReglaNegocioException e, HttpServletRequest r, Model m) {
        log.warn("Regla de negocio en {}: {}", r.getRequestURI(), e.getMessage());
        if (r.getRequestURI().startsWith("/api/"))
            return ResponseEntity.status(409).body(Map.of("status", 409, "message", e.getMessage()));
        m.addAttribute("detalle", e.getMessage());
        return "error/500";
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public Object validation(MethodArgumentNotValidException e, HttpServletRequest r, Model m) {
        var errors = new LinkedHashMap<String, String>();
        e.getBindingResult().getFieldErrors().forEach(x -> errors.put(x.getField(), x.getDefaultMessage()));
        if (r.getRequestURI().startsWith("/api/"))
            return ResponseEntity.badRequest().body(Map.of("status", 400, "message", "Datos inválidos", "errors", errors));
        m.addAttribute("detalle", errors.toString());
        return "error/500";
    }

    @ExceptionHandler(Exception.class)
    public Object other(Exception e, HttpServletRequest r, Model m) {
        log.error("Error no controlado en {}", r.getRequestURI(), e);
        if (r.getRequestURI().startsWith("/api/"))
            return ResponseEntity.status(500).body(Map.of("status", 500, "message", "Ocurrió un error interno."));
        m.addAttribute("detalle", e.getClass().getSimpleName() + ": " + e.getMessage());
        return "error/500";
    }
}
