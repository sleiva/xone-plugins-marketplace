---
description: Estilos CSS en XOne. Usar al crear o modificar default.css y variantes, clases CSS, selectores coll/prop/prop:TYPE/group/frame, unidades p y %, colores #AARRGGBB, herencia con extends, animaciones, temas light/dark o estilos dinámicos por campo.
---

# XOne CSS

Sistema de estilos propietario de XOne, inspirado en CSS web pero con reglas distintas. NO es CSS web: no soporta Flexbox, Grid, media queries, variables CSS, pseudo-clases, pseudo-elementos, transiciones, transformaciones, gradientes, `calc()`, ni selectores combinadores. El archivo obligatorio es `default.css` en la raíz del proyecto, declarado en `app.xml` con `<style url="default.css" encoding="UTF-8" />`.

## Selectores soportados

Solo existen: `coll`, `prop`, `prop:TYPE`, `.clase`, `group`, `frame`. NO hay selectores de ID (`#id`), de etiqueta HTML, de atributo (`[attr]`), ni combinadores (`>`, `+`, `~`).

| Selector | Aplica a |
|----------|----------|
| `coll` | Todas las colecciones (pantallas) |
| `prop` | Todas las propiedades (campos/controles) |
| `prop:T` / `prop:N` / `prop:B` / `prop:NC` / `prop:Z` / `prop:IMG` / `prop:D` | Campos de un tipo concreto |
| `.miClase` | Elementos con `class="miClase"` en el XML |
| `group` | Todos los grupos |
| `frame` | Todos los frames |

Los estilos se aplican con el atributo `class` (varias clases separadas por espacio):

```xml
<frame name="frmHeader" class="frameHeader">
<prop name="txtNombre" class="textoEditable inputTextoLinea">
```

### Selectores globales obligatorios

`coll` y `prop` deben existir siempre como base de la aplicación:

```css
coll {
    notab: true;
    show-toolbar: false;
    bgcolor: #FFFFFF;
    cell-bgcolor: #F2F2F2;
    cell-tpadding: 2p;
    cell-bpadding: 2p;
    show-selected-item: false;
    selected-item-start-index: -1;
}

prop {
    fontname: Roboto-Regular.ttf;
    fontsize: 14;
    labelbox: false;
    label-wrap: true;
    text-border: false;
    forecolor: #212121;
}
```

### Por tipo

```css
prop:B { forecolor: #000000; bgcolor: #CCCCCC; }
prop:IMG { labelwidth: 0; img-sign: bt_Firma.png; }
prop:NC { extends: prop; apply-css: true; labelwidth: 1; }
```

## Unidades de medida

- `p` (puntos independientes de densidad, ~dp de Android) para dimensiones fijas: `height: 56p`.
- `%` (relativo al contenedor padre) para layouts responsivos: `width: 100%`.
- Sin unidad para `fontsize`, `border-corner-radius`, `border-width`, `labelwidth`, `lines`, `visible`, `gallery-columns`, `img-width`/`img-height`.

**PROHIBIDO**: `px`, `em`, `rem`, `vh`, `vw`, `vmin`, `vmax`, `pt`, `cm`, `mm`, `in`. Su uso se ignora o produce comportamiento inesperado.

```css
/* INCORRECTO */
.miClase { height: 56px; fontsize: 1.2em; width: 100vw; margin-top: 10rem; }

/* CORRECTO */
.miClase { height: 56p; fontsize: 14; width: 100%; tmargin: 10p; }
```

## Colores

- Formato `#RRGGBB` (siempre los 6 dígitos; `#FFF`/`#333` no están garantizados).
- Transparencia con formato **ARGB**: alpha PRIMERO. `#80FFFFFF` = blanco 50%. `#FFFFFF80` (formato web) NO funciona en XOne.
- Solo se garantiza la palabra clave `transparent`; prefiere `#00000000` para transparencia total. No usar nombres (`red`, `blue`).

```css
/* INCORRECTO */
.error { bgcolor: #00000080; }   /* alpha al final, no da 50% */
.bad   { bgcolor: red; }

/* CORRECTO */
.ok    { bgcolor: #80000000; }   /* negro 50% */
.bien  { bgcolor: #F44336; }
```

Paleta centralizada en `colors.css` con clases de color (`.colorPrimario`, `.colorPrimarioAccion`, ...) para facilitar el tema.

## Atributos principales

### Dimensiones, márgenes y padding

`width`, `height` (`Np`/`N%`). Márgenes y padding usan atributos individuales; NO existe abreviado `margin`/`padding`:

`tmargin`, `bmargin`, `lmargin`, `rmargin` · `tpadding`, `bpadding`, `lpadding`, `rpadding`

```css
.tarjeta {
    width: 95%;
    tmargin: 10p;
    bmargin: 5p;
    lmargin: 10p;
    rmargin: 10p;
    tpadding: 15p;
    border-corner-radius: 12;
}
```

### Fuentes

`fontname` (archivo `.ttf` en `fonts/`), `fontsize` (número, sin unidad), `fontbold`, `fontitalic`, `text-fontsize`, `labelfontsize`, `labelfont-bold`, `textfont-bold`.

```css
/* INCORRECTO */
.error { font-size: 14px; font-family: 'Roboto'; font-weight: bold; }

/* CORRECTO */
.ok    { fontsize: 14; fontname: Roboto-Regular.ttf; fontbold: true; }
```

### Texto

`forecolor`, `forecolor-disabled`, `text-forecolor`, `text-forecolor-disabled`, `text-align` (`left`/`center`/`right`), `align` (combinado con `|`: `top|left`, `bottom|center`), `lines`, `fixed-lines`, `locked`, `mask`.

### Fondo

`bgcolor`, `bgcolor-disabled`, `bgcolor-focus`, `text-bgcolor`, `text-bgcolor-focus`, `text-bgcolor-disabled`, `imgbk` (imagen de fondo PNG).

### Bordes

Bordes de texto (área editable): `text-border`, `text-border-left/right/top/bottom`, `text-border-color`, `text-border-width`.

Bordes de contenedor: `border`, `border-width` (sin unidad), `border-color`, `border-corner-radius` (sin unidad) y por esquina (`-top-left`, `-top-right`, `-bottom-left`, `-bottom-right`), `border-top`/`border-bottom` (+color), `framebox`, `grid-framebox`, `grid-text-border`.

Patrón Material Design de input con solo borde inferior:

```css
.inputMaterial {
    text-border: true;
    text-border-left: false;
    text-border-right: false;
    text-border-top: false;
    text-border-bottom: true;
    text-border-color: #BDBDBD;
}
```

Bordes redondeados: `border-corner-radius: 28` (sin unidad), no `border-radius: 8px`.

### Sombras y elevación

`elevation` (número, sombra real sobre todo en Android) y `shadow-color`. NO existe `box-shadow`/`text-shadow`. Alternativa multiplataforma: bordes sutiles.

### Visibilidad

`visible` bitmask (0-7): `0` oculto · `1` solo edición · `2` solo lista · `3` edición+lista · `4` solo contents · `5` edición+contents · `6` lista+contents · `7` todos.

### Otros

`newline`, `scroll`, `fixed` (+ `orientation` top/bottom), `floating` (+ `top`/`left`), `ripple-effect` (Android), `elevation`, `imgbk`, `undo-button`, `apply-css`, `locked`, `zoom-controls`, `img`/`imgsel`, `img-width`/`img-height`.

### Grupos y tabs

`tab-visible`, `tab-height`, `tab-fontsize`, `tab-bgcolor`, `tab-forecolor`, `tab-selected-forecolor`, `tab-indicator-color`.

```css
.groupConTab {
    tab-visible: true;
    tab-height: 56p;
    tab-fontsize: 14;
    tab-bgcolor: #0D47A1;
    tab-selected-forecolor: #FFFFFF;
}
```

Headers/footers fijos:

```css
.groupfixed_header { fixed: true; orientation: top; width: 100%; height: 120p; }
.groupfixed_footer { fixed: true; orientation: bottom; width: 100%; height: 120p; }
```

## Herencia `extends:`

Permite heredar atributos de otra clase (o selector global/tipado). La clase base se referencia con prefijo `.`.

```css
.btnPrimario {
    width: 90%;
    height: 56p;
    bgcolor: #1565C0;
    forecolor: #FFFFFF;
    border-corner-radius: 28;
    text-align: center;
    fontsize: 16;
    fontname: Roboto-Bold.ttf;
}

.btnPeligro {
    extends: .btnPrimario;   /* hereda todo */
    bgcolor: #F44336;        /* solo cambia el color */
}
```

- Cadenas de herencia: `.badgeEntregado { extends: .badgeEstado; bgcolor: #4CAF50; }`.
- Sobreescritura: los atributos de la clase hija ganan a los heredados.
- También se puede heredar de `prop`, `prop:B`, `prop:T`, etc.: `extends: prop:B;`.
- Evitar herencia circular (A extends B extends A).

Usar `extends` en lugar de duplicar atributos en variantes que solo cambian un detalle.

## Estilos dinámicos

- **Referencias de campo** `##FLD_NOMBRE_CAMPO##` en CSS y en atributos inline XML; el valor del campo del registro actual reemplaza el token en runtime:

```css
.frmsuperior { bgcolor: ##FLD_MAP_COLORACTIVO##; }
```

```xml
<prop name="MAP_LABEL" bgcolor="##FLD_MAP_COLOR1##" />
```

- **Cambiar clase desde JavaScript** según estado (no hay selector condicional CSS puro):

```javascript
if (self.MAP_ESTADO == "PENDIENTE") {
    ui.getView(self)["badgeEstado"].className = "badgePendiente";
} else if (self.MAP_ESTADO == "ENTREGADO") {
    ui.getView(self)["badgeEstado"].className = "badgeEntregado";
}
```

## Cascada de archivos

Prioridad de menor a mayor:

```
1. default.css          (base - MENOR prioridad)
2. default_ios.css      (plataforma)
3. default_portrait.css (orientación)
4. default_night.css    (tema)
5. Atributos inline XML (MAYOR prioridad)
```

Los atributos inline del XML siempre ganan a cualquier clase CSS. Los archivos variantes se cargan por convención de nombre (`default_night.css`, `default_day.css`, `default_portrait.css`, `default_landscape.css`, `default_ios.css`, `default_wear.css`), no se declaran en `app.xml`.

## Temas light/dark

Separar colores en `colors.css` y variar con `default_night.css`/`default_day.css`. Centralizar los colores en clases de color para poder cambiar el tema sin tocar las clases de layout.

## Animaciones

Atributos: `animation-in`, `animation-out`, `animation-in-delay`, `animation-out-delay` (retardo en ms).

Tokens predefinidos (entre `##`):

| Token | Descripción |
|-------|-------------|
| `##RIGHT_IN##` / `##RIGHT_OUT##` | Entra/sale por la derecha |
| `##LEFT_IN##` / `##LEFT_OUT##` | Entra/sale por la izquierda |
| `##PUSH_IN##` / `##PUSH_OUT##` | Desde abajo (modales, paneles) |
| `##PUSH_DOWN_IN##` / `##PUSH_DOWN_OUT##` | Desde arriba (notificaciones) |
| `##ALPHA_IN##` / `##ALPHA_OUT##` | Fundido |
| `##ZOOM_IN##` / `##ZOOM_OUT##` | Zoom |
| `##ROTATE3D_IN##` / `##ROTATE3D_OUT##` | Rotación 3D |

```css
.animSlideRight {
    animation-in: ##RIGHT_IN##;
    animation-in-delay: 200;
    animation-out: ##LEFT_OUT##;
    animation-out-delay: 200;
}
```

Usar para transiciones de pantalla, no en items de lista ni elementos que se repintan.

## Errores frecuentes

| Error CSS web | Correcto en XOne |
|---------------|------------------|
| `font-size: 14px` | `fontsize: 14` |
| `background-color: #fff` | `bgcolor: #FFFFFF` |
| `margin: 10p` (abreviado) | `tmargin/bmargin/lmargin/rmargin` |
| `margin-top: 10px` | `tmargin: 10p` |
| `border-radius: 8px` | `border-corner-radius: 8` |
| `display: none` | `visible: 0` |
| `overflow: scroll` | `scroll: true` |
| `#RRGGBBAA` (alpha al final) | `#AARRGGBB` (alpha al inicio) |
| `#FFF` / `#333` | `#FFFFFF` / `#333333` |
| `font-weight: bold` | `fontbold: true` |
| `box-shadow` | `elevation: N` (+ `shadow-color`) |
| Gradientes / Flexbox / media queries | No soportados |

## Buenas prácticas

1. `default.css` es el único archivo obligatorio; siempre definir `coll` y `prop` globales.
2. Separar la paleta en `colors.css`.
3. `p` para fijas, `%` para responsivas; nunca `px`/`em`/`rem`.
4. `fontsize`, `border-corner-radius`, `border-width` sin unidad.
5. Usar `extends` para variantes; no duplicar atributos.
6. Comentar secciones con `/* ====== SECCION ====== */`.
7. Nomenclatura con prefijos: `frame`, `btn`, `input`, `texto`, `tarjeta`, `badge`, `avatar`, `icono`, `group`.
8. `labelwidth: 0` cuando no hay etiqueta.
9. `text-border-bottom: true` para inputs Material.
10. Botones pill: `height: 56p; border-corner-radius: 28;`.
11. Alpha primero en ARGB.
12. No abusar de animaciones.
13. Definir `.frameHeader`, `.frameBody` (con `scroll: true`) y `.frameFooter`.
14. Organizar el archivo: cabecera, `prop`, `coll`, iconos del sistema, frames de layout, tarjetas, botones, inputs, textos, badges, avatares, listas, grupos, especiales, animaciones.
