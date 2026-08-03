---
name: xone-css
description: Estilos CSS en XOne. Usar al crear o modificar default.css y variantes, clases CSS, selectores coll/prop/prop:TYPE/group/frame, unidades p y %, colores #AARRGGBB, herencia con extends, animaciones, temas light/dark o estilos dinámicos por campo.
---

# XOne CSS

XOne CSS es propietario y solo se parece a CSS web. El archivo base obligatorio es `default.css` en la raíz, declarado en `app.xml`. No soporta Flexbox, Grid, media queries, variables CSS, pseudo-selectores, combinadores, `calc`, gradientes, transiciones ni transformaciones.

## Reglas esenciales

- Selectores válidos: `coll`, `prop`, `prop:TYPE`, `.clase`, `group` y `frame`; no uses IDs, etiquetas HTML, atributos ni combinadores.
- Define siempre `coll` y `prop` globales. Aplica clases desde `class="..."` en XML.
- Usa `p` para dimensiones fijas y `%` para el contenedor. `fontsize`, `border-width`, `border-corner-radius`, `labelwidth`, `lines` y `visible` no llevan unidad.
- No uses `px`, `em`, `rem`, `vh`, `vw`, `pt` ni unidades físicas.
- Los colores son `#RRGGBB` o ARGB `#AARRGGBB`: el alpha va primero. Usa seis dígitos y evita nombres de color.
- No existen abreviados `margin`/`padding`: usa `tmargin`, `bmargin`, `lmargin`, `rmargin` y sus equivalentes de padding.
- `extends: .claseBase` reutiliza estilos; evita ciclos. Los atributos inline XML ganan a CSS.

## Layout y estilos dinámicos

Las propiedades más usadas son `width`, `height`, márgenes/padding individuales, `fontname`, `fontsize`, `fontbold`, `forecolor`, `text-align`, `align`, `bgcolor`, `text-border`, `border`, `border-width`, `border-color`, `border-corner-radius`, `elevation`, `visible`, `newline`, `scroll`, `fixed`, `floating`, `ripple-effect`, `locked` y `apply-css`. Tabs usan `tab-*`; `visible` es bitmask 0-7.

Los tokens `##FLD_CAMPO##` permiten color/atributos dependientes del registro. Para estados dinámicos cambia la clase desde JavaScript; no hay selector condicional CSS puro. Separa colores en `colors.css` y temas en `default_day.css`/`default_night.css`.

## Anti-patrones

| Evitar | Usar |
|---|---|
| `height: 56px` | `height: 56p` |
| `#RRGGBBAA` | `#AARRGGBB` |
| `margin`/`padding` abreviados | lados individuales |
| `font-size`, `font-family`, `font-weight` | `fontsize`, `fontname`, `fontbold` |
| `display: none`, `box-shadow` | `visible`, `elevation` |
| Flexbox, Grid, media queries | layout XOne con `%`, frames y grupos |
| animar filas que se repintan | animar transiciones de pantalla |

## Recursos adicionales

- Atributos, cascada, grupos, tabs, temas y animaciones: [references/reference.md](references/reference.md)
- Errores frecuentes y diagnóstico: [references/troubleshooting.md](references/troubleshooting.md)
