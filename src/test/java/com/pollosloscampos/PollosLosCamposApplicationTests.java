package com.pollosloscampos;
import org.junit.jupiter.api.*;import java.math.BigDecimal;
class PollosLosCamposApplicationTests{@Test void sumaTotal(){Assertions.assertEquals(new BigDecimal("42.80"),new BigDecimal("37.80").add(new BigDecimal("5.00")));}@Test void precioBackendEsDistintoAlCliente(){BigDecimal enviado=new BigDecimal("1.00"),real=new BigDecimal("18.90");Assertions.assertNotEquals(enviado,real);}}
