package com.pollosloscampos.dto;

import jakarta.validation.constraints.NotBlank;

public record EstadoPedidoRequest(@NotBlank String estado) {
}
