package com.pollosloscampos.config;

import com.pollosloscampos.entity.*;
import com.pollosloscampos.repository.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.*;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.math.BigDecimal;
import java.time.LocalDate;

@Configuration
public class DataInitializer {
    @Bean
    CommandLineRunner seed(@Value("${app.seed.enabled:true}") boolean on, @Value("${app.admin.email:admin@pollosloscampos.local}") String email, @Value("${app.admin.password:Admin123!}") String pass, UsuarioRepository users, CategoriaRepository cats, ProductoRepository products, PromocionRepository promos, PasswordEncoder encoder) {
        return args -> {
            if (!on) return;
            if (users.findByCorreoIgnoreCase(email).isEmpty()) {
                Usuario u = new Usuario();
                u.setNombres("Administrador");
                u.setApellidos("Los Campos");
                u.setCorreo(email);
                u.setCelular("999888777");
                u.setPassword(encoder.encode(pass));
                u.setRol(Rol.ROLE_ADMIN);
                u.setActivo(true);
                users.save(u);
            }
            if (cats.count() == 0) {
                for (String[] x : new String[][]{{"Pollo a la Brasa", "Especialidad de la casa"}, {"Combos", "Combos para compartir"}, {"Parrillas", "Opciones a la parrilla"}, {"Acompañamientos", "Papas, ensaladas y más"}, {"Bebidas", "Bebidas frías"}, {"Postres", "Dulces de la casa"}}) {
                    var c = new Categoria();
                    c.setNombre(x[0]);
                    c.setDescripcion(x[1]);
                    cats.save(c);
                }
            }
            if (products.count() == 0) {
                add(products, cats, "1/4 de Pollo", "Cuarto de pollo a la brasa, papas y ensalada.", "18.90", "Pollo a la Brasa", "🍗", "Más pedido", true, "https://images.unsplash.com/photo-1781334266250-a7e72fdf539f?auto=format&fit=crop&w=800&q=75");
                add(products, cats, "1/2 Pollo", "Medio pollo a la brasa, papas, ensalada y cremas.", "34.90", "Pollo a la Brasa", "🍗", "Ideal para 2", true, "https://images.unsplash.com/photo-1501200291289-c5a76c232e5f?auto=format&fit=crop&w=800&q=75");
                add(products, cats, "Pollo Entero", "Pollo entero a la brasa con papas familiares, ensalada y cremas.", "64.90", "Pollo a la Brasa", "🔥", "Para compartir", true, "https://images.unsplash.com/photo-1630564510761-a560db92a09b?auto=format&fit=crop&w=800&q=75");
                add(products, cats, "Combo Familiar", "Pollo entero + papas familiares + ensalada + cremas.", "69.90", "Combos", "👨‍👩‍👧‍👦", "Familiar", true, "https://images.unsplash.com/photo-1712579733874-c3a79f0f9d12?auto=format&fit=crop&w=800&q=75");
                add(products, cats, "Combo Personal", "1/4 de pollo + papas + bebida personal.", "22.90", "Combos", "🍗", "Personal", true, "https://images.unsplash.com/photo-1712579733874-c3a79f0f9d12?auto=format&fit=crop&w=800&q=75");
                add(products, cats, "Alitas BBQ", "8 alitas crocantes con salsa BBQ de la casa.", "22.90", "Parrillas", "🍖", "Nuevo", true, "https://images.unsplash.com/photo-1736952332338-44dc07283462?auto=format&fit=crop&w=800&q=75");
                add(products, cats, "Salchipapa", "Papas doradas, hot dog, chorizo y huevo.", "18.90", "Acompañamientos", "🍟", "Favorito", false, "https://images.unsplash.com/photo-1707773726979-4b87cd1c838a?auto=format&fit=crop&w=800&q=75");
                add(products, cats, "Papas Fritas", "Porción de papas doradas.", "9.90", "Acompañamientos", "🍟", "Extra", false, "https://images.unsplash.com/photo-1707773726979-4b87cd1c838a?auto=format&fit=crop&w=800&q=75");
                add(products, cats, "Ensalada", "Ensalada fresca de la casa.", "7.90", "Acompañamientos", "🥗", "Ligero", false, "https://images.unsplash.com/photo-1612488261779-be3483951c46?auto=format&fit=crop&w=800&q=75");
                add(products, cats, "Inca Kola", "Gaseosa familiar bien fría.", "10.50", "Bebidas", "🥤", "Clásica", false, "https://images.unsplash.com/photo-1613510506223-55083f3b68a0?auto=format&fit=crop&w=800&q=75");
                add(products, cats, "Coca Cola", "Gaseosa familiar bien fría.", "10.50", "Bebidas", "🥤", "Clásica", false, "https://images.unsplash.com/photo-1514218953589-2d7d37efd2dc?auto=format&fit=crop&w=800&q=75");
                add(products, cats, "Agua", "Agua embotellada.", "4.00", "Bebidas", "💧", "Ligera", false, "https://images.unsplash.com/photo-1559839914-17aae19cec71?auto=format&fit=crop&w=800&q=75");
                add(products, cats, "Postre de la casa", "Dulce para cerrar el pedido.", "8.50", "Postres", "🍰", "Dulce", false, "/images/productos/dessert.svg");
            }
            if (promos.count() == 0) {
                promo(promos, "Combo Familiar Los Campos", "Pollo entero + papas familiares + ensalada + cremas.", "74.90", "69.90", "https://images.unsplash.com/photo-1712579733874-c3a79f0f9d12?auto=format&fit=crop&w=800&q=75", 18);
                promo(promos, "Combo Personal", "Cuarto de pollo + papas + bebida personal.", "26.90", "22.90", "https://images.unsplash.com/photo-1781334266250-a7e72fdf539f?auto=format&fit=crop&w=800&q=75", 25);
            }
            var fotos = java.util.Map.of(
                    "inca kola", "https://images.unsplash.com/photo-1613510506223-55083f3b68a0?auto=format&fit=crop&w=800&q=75",
                    "coca cola", "https://images.unsplash.com/photo-1514218953589-2d7d37efd2dc?auto=format&fit=crop&w=800&q=75",
                    "agua", "https://images.unsplash.com/photo-1559839914-17aae19cec71?auto=format&fit=crop&w=800&q=75");
            for (var pr : products.findAll()) {
                var f = fotos.get(pr.getNombre().trim().toLowerCase());
                if (f != null && !f.equals(pr.getImagen())) { pr.setImagen(f); products.save(pr); }
            }
        };
    }

    private void add(ProductoRepository r, CategoriaRepository c, String n, String d, String price, String cat, String emoji, String tag, boolean dest, String img) {
        var p = new Producto();
        p.setNombre(n);
        p.setDescripcion(d);
        p.setPrecio(new BigDecimal(price));
        p.setCategoria(c.findByNombreIgnoreCase(cat).orElseThrow());
        p.setImagen(img);
        p.setEtiqueta(tag);
        p.setDestacado(dest);
        p.setDisponible(true);
        r.save(p);
    }

    private void promo(PromocionRepository r, String n, String d, String old, String now, String img, int stock) {
        var p = new Promocion();
        p.setNombre(n);
        p.setDescripcion(d);
        p.setPrecioAnterior(new BigDecimal(old));
        p.setPrecioPromocional(new BigDecimal(now));
        p.setFechaInicio(LocalDate.now().minusDays(3));
        p.setFechaFin(LocalDate.now().plusDays(60));
        p.setImagen(img);
        p.setStock(stock);
        p.setActiva(true);
        r.save(p);
    }
}
