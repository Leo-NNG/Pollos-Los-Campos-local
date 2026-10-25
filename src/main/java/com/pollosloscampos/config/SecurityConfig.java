package com.pollosloscampos.config;

import com.pollosloscampos.entity.Usuario;
import com.pollosloscampos.repository.UsuarioRepository;
import org.springframework.context.annotation.*;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.core.userdetails.*;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.config.Customizer;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.util.matcher.RequestMatcher;

@Configuration
public class SecurityConfig {
    @Bean
    PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    UserDetailsService userDetailsService(UsuarioRepository repo) {
        return name -> {
            Usuario u = repo.findByCorreoIgnoreCase(name).orElseThrow(() -> new UsernameNotFoundException("Usuario no encontrado."));
            return User.withUsername(u.getCorreo()).password(u.getPassword()).roles(u.getRol().name().replace("ROLE_", "")).disabled(!u.isActivo()).build();
        };
    }

    @Bean
    DaoAuthenticationProvider authenticationProvider(UserDetailsService uds, PasswordEncoder pe) {
        var p = new DaoAuthenticationProvider(uds);
        p.setPasswordEncoder(pe);
        return p;
    }

    @Bean
    SecurityFilterChain securityFilterChain(HttpSecurity http, DaoAuthenticationProvider provider) throws Exception {
        http.authenticationProvider(provider).csrf(c -> c.ignoringRequestMatchers(csrfExento()))
                .authorizeHttpRequests(a -> a
                        .requestMatchers("/css/**", "/js/**", "/images/**", "/", "/menu", "/producto/**", "/promociones", "/nosotros", "/contacto", "/contacto/enviar", "/seguimiento", "/seguimiento/buscar", "/pedido", "/pedido/crear", "/login", "/registro", "/registro/crear", "/error/**", "/403").permitAll()
                        .requestMatchers(HttpMethod.GET, "/api/productos", "/api/productos/**", "/api/categorias", "/api/promociones").permitAll()
                        .requestMatchers(HttpMethod.POST, "/api/pedidos").permitAll()
                        .requestMatchers("/admin/**", "/api/dashboard/**", "/api/pedidos/*/estado").hasRole("ADMIN")
                        .requestMatchers(HttpMethod.POST, "/api/productos/**").hasRole("ADMIN").requestMatchers(HttpMethod.PUT, "/api/productos/**").hasRole("ADMIN").requestMatchers(HttpMethod.DELETE, "/api/productos/**").hasRole("ADMIN")
                        .requestMatchers("/cuenta/**", "/api/pedidos/*").authenticated().anyRequest().permitAll())
                .formLogin(f -> f.loginPage("/login").usernameParameter("correo").passwordParameter("password").defaultSuccessUrl("/post-login", true).failureUrl("/login?error=true").permitAll())
                .httpBasic(Customizer.withDefaults()).logout(l -> l.logoutSuccessUrl("/?logout=true").permitAll()).exceptionHandling(e -> e.accessDeniedPage("/403"));
        return http.build();
    }

    /**
     * CSRF protege las sesiones con cookie del navegador. Solo se exceptúa:
     *  - POST /api/pedidos (pedido público, sin sesión), y
     *  - peticiones que se autentican con cabecera "Authorization: Basic ..." (Postman, scripts),
     *    que no usan cookie de sesión y por tanto no son vulnerables a CSRF.
     * El resto de /api/** (POST/PUT/DELETE con sesión del navegador) exige token CSRF.
     */
    private RequestMatcher csrfExento() {
        return req -> {
            String auth = req.getHeader("Authorization");
            boolean basic = auth != null && auth.regionMatches(true, 0, "Basic ", 0, 6);
            boolean pedidoPublico = "POST".equalsIgnoreCase(req.getMethod()) && "/api/pedidos".equals(req.getRequestURI());
            return basic || pedidoPublico;
        };
    }
}
