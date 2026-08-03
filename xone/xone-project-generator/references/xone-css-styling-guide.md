# Guía Completa de Estilos CSS para XOne

## Documento de referencia para agentes AI que generan proyectos XOne

> **IMPORTANTE:** El sistema CSS de XOne NO es CSS web estándar. Utiliza una sintaxis similar pero con atributos propietarios especificos para aplicaciones móviles nativas. Este documento cubre TODAS las capacidades documentadas del sistema CSS de XOne.

---

## Tabla de Contenidos

1. [Introduccion y Conceptos Fundamentales](#1-introduccion-y-conceptos-fundamentales)
2. [Tipos de Archivos CSS y Sistema de Cascada](#2-tipos-de-archivos-css-y-sistema-de-cascada)
3. [Selectores CSS de XOne](#3-selectores-css-de-xone)
4. [Atributos CSS - Tipografía](#4-atributos-css---tipografia)
5. [Atributos CSS - Dimensiones y Unidades](#5-atributos-css---dimensiones-y-unidades)
6. [Atributos CSS - Margenes y Padding](#6-atributos-css---margenes-y-padding)
7. [Atributos CSS - Colores y Fondos](#7-atributos-css---colores-y-fondos)
8. [Atributos CSS - Alineacion y Layout](#8-atributos-css---alineacion-y-layout)
9. [Atributos CSS - Etiquetas (Labels)](#9-atributos-css---etiquetas-labels)
10. [Atributos CSS - Bordes](#10-atributos-css---bordes)
11. [Atributos CSS - Texto y Campos](#11-atributos-css---texto-y-campos)
12. [Atributos CSS - Imágenes e Iconos](#12-atributos-css---imagenes-e-iconos)
13. [Atributos CSS - Checkbox y Controles Toggle](#13-atributos-css---checkbox-y-controles-toggle)
14. [Atributos CSS - Visibilidad y Estado](#14-atributos-css---visibilidad-y-estado)
15. [Atributos CSS - Elevacion y Sombras](#15-atributos-css---elevacion-y-sombras)
16. [Atributos de Coleccion (coll)](#16-atributos-de-coleccion-coll)
17. [Animaciones](#17-animaciones)
18. [Gráficos (Charts)](#18-graficos-charts)
19. [Calendario](#19-calendario)
20. [Mapas (MapView)](#20-mapas-mapview)
21. [Machine Learning](#21-machine-learning)
22. [Referencias Dinámicas a Campos ##FLD_CAMPO##](#22-referencias-dinamicas-a-campos-fld_campo)
23. [Patrones de Diseño Completos](#23-patrones-de-diseno-completos)
24. [Temas Claro y Oscuro](#24-temas-claro-y-oscuro)
25. [CSS Responsivo y Adaptativo](#25-css-responsivo-y-adaptativo)
26. [Referencia de Transparencia Alpha (ARGB)](#26-referencia-de-transparencia-alpha-argb)
27. [Buenas Prácticas](#27-buenas-practicas)
28. [Errores Comunes](#28-errores-comunes)
29. [Funciones del parser CSS](#29-funciones-del-parser-css)

---

## 1. Introduccion y Conceptos Fundamentales

### Que es el CSS de XOne

El sistema CSS de XOne permite controlar la apariencia visual de aplicaciones móviles nativas generadas para Android e iOS. Aunque su sintaxis es similar a CSS web, tiene diferencias fundamentales:

- **Atributos propietarios**: Los nombres de atributos son especificos de XOne (ej: `fontsize` en vez de `font-size`)
- **Sin guiones en nombres**: La mayoría de atributos usan camelCase o nombres sin guion
- **Unidades propias**: Solo soporta `p` (puntos XOne: 1p = 1px en la resolución de referencia; NO es el `dp` de Android) y `%` (porcentaje)
- **Colores ARGB**: El formato con alpha es `#AARRGGBB` (alpha primero), no RGBA
- **Herencia explicita**: Usa el atributo `extends` para heredar estilos, no la cascada CSS

### Diferencias críticas con CSS web

| Concepto | CSS Web | CSS XOne |
|----------|---------|----------|
| Unidades de medida | px, em, rem, vw, vh | `p` (puntos), `%` (porcentaje) |
| Color con alpha | rgba(0,0,0,0.5) | `#80000000` (ARGB) |
| Tamaño de fuente | font-size: 14px | `fontsize: 14` (sin unidad) |
| Margen superior | margin-top: 10px | `tmargin: 10p` |
| Variables CSS | var(--color) | `:root { --color: red; }` + `var(--color)` (con fallback y anidamiento) |
| Media queries | @media (max-width) | NO SOPORTADO (usar archivos separados) |
| Flexbox/Grid | display: flex | NO SOPORTADO (usar frames) |
| Pseudo-elementos | ::before, ::after | NO SOPORTADO |
| Pseudo-clases | :hover, :focus | NO SOPORTADO |
| calc() | calc(100% - 20px) | `calc(8 * 2)` sobre números puros (sin unidades) |
| Importación | `@import url("a.css")` | `@import "a.css";` (solo al inicio del archivo) |
| Herencia | Cascada automática | `extends:.nombreClase` o `@extend .nombreClase;` |

### Funcionalidades del parser SÍ soportadas

- **Variables CSS**: declaración en `:root` (globales) o dentro de cualquier bloque (locales). `var(--nombre)` y `var(--nombre, fallback)`. Una variable puede referenciar a otra (anidamiento).
- **`calc()`**: aritmética con `+`, `-`, `*`, `/`, paréntesis y `-` unario sobre números puros.
- **`@import "ruta";`**: composición de hojas. Solo al inicio del archivo.
- **`@extend selector;`**: at-rule moderna alternativa al atributo `extends:`. Detecta ciclos en parseo y permite referencias adelantadas.
- **`!important`**: una declaración normal no sobreescribe a una `!important` previa.
- **`!default`**: la declaración solo se aplica si la clave no estaba ya definida (útil para hojas base sobre-escribibles).
- **Comentarios** `/* */` (multilínea) y `//` (una línea).
- **Selectores múltiples**: `a, b, c { ... }`.

### Funcionalidades NO soportadas en XOne CSS

- Funciones `min()`, `max()`, `clamp()` (solo `calc()`)
- Media queries `@media`
- Pseudo-clases (`:hover`, `:focus`, `:active`, `:nth-child`)
- Pseudo-elementos (`::before`, `::after`)
- Selectores de atributo (`[data-attr]`)
- Selectores combinadores (`>`, `+`, `~`, espacio descendiente)
- Transiciones CSS (`transition`)
- Transformaciones CSS (`transform`)
- Flexbox (`display: flex`)
- CSS Grid (`display: grid`)
- Sombras (`box-shadow`, `text-shadow`)
- Gradientes (`linear-gradient`, `radial-gradient`)
- Unidades `px`, `em`, `rem`, `vw`, `vh`, `vmin`, `vmax`

---

## 2. Tipos de Archivos CSS y Sistema de Cascada

### Archivos CSS reconocidos por XOne

| Archivo | Proposito | Obligatorio |
|---------|-----------|-------------|
| `default.css` | Estilos base globales | SI |
| `default_night.css` | Variante tema oscuro | No |
| `default_day.css` | Variante tema claro | No |
| `default_portrait.css` | Estilos orientación vertical | No |
| `default_landscape.css` | Estilos orientación horizontal | No |
| `default_ios.css` | Estilos especificos iOS | No |
| `default_wear.css` | Estilos para wearables | No |
| `default-colors.css` | Separación de colores (modularidad) | No |
| `básico.css` | Estilos básicos reutilizables | No |

### Orden de Cascada de Condiciones de Dispositivo (menor a mayor prioridad)

El sistema de cascada de XOne sigue un orden estricto. Cada nivel sobreescribe las propiedades del anterior:

```
1. default.css                    (Estilos base - MENOR prioridad)
2. default.ios.css / default.android.css    (Plataforma)
3. default.portrait.css / default.landscape.css  (Orientacion)
4. default.night.css              (Modo oscuro / tema)
5. default.ios.portrait.css       (Condiciones combinadas)
6. Atributos inline XML           (MAYOR prioridad)
```

**Condiciones combinadas:** Se pueden combinar plataforma + orientación + tema en un solo archivo. El nombre sigue el patron `default.<plataforma>.<orientación>.css`. Ejemplos:
- `default.ios.portrait.css` — Solo iOS en vertical
- `default.android.landscape.css` — Solo Android en horizontal

> **NOTA:** También se acepta la convencion con guion bajo (`default_ios.css`, `default_portrait.css`, `default_night.css`). Ambas convenciones son validas.

### Declaración en app.xml

```xml
<app ...>
    <style url="default.css" encoding="UTF-8" />
</app>
```

Solo se declara `default.css` en `app.xml`. Los archivos variantes se cargan automáticamente por convencion de nombres.

### Declaración con condiciones explicitas

También se pueden declarar archivos CSS con condiciones explicitas usando el atributo `conditions`:

```xml
<app ...>
    <style url="default.css" strict-mode="true" />
    <style url="default-ios.css" conditions="ios" strict-mode="true" />
    <style url="default_hor.css" conditions="phone:horizontal" strict-mode="true" />
    <style url="tablet_ver.css" conditions="tablet:vertical" />
    <style url="tablet_hor.css" conditions="tablet:horizontal" />
</app>
```

### strict-mode

```xml
<style url="default.css" strict-mode="true" />
```

Cuando `strict-mode="true"`, XOne valida errores en el CSS y reporta propiedades no reconocidas o valores invalidos. Útil durante el desarrollo.

---

## 3. Selectores CSS de XOne

XOne soporta los siguientes tipos de selectores:

### 3.1 Selector de Coleccion (`coll`)

```css
coll {
    notab: true;
    show-toolbar: false;
    group-swipe: false;
    editmask: 0;
    bgcolor: #FFFFFF;
}
```

### 3.2 Selector de Propiedad (`prop`)

```css
prop {
    fontname: Roboto-Regular.ttf;
    fontsize: 11;
    labelbox: false;
    label-wrap: true;
    text-border: false;
    forecolor: #212121;
}
```

### 3.3 Selector de Tipo (`prop:TYPE`)

Aplica estilos según el tipo de campo (`type` en XML). Tabla completa de selectores por tipo:

| Selector | Tipo | Descripción |
|----------|------|-------------|
| `prop:T` | Texto | Campo de texto simple |
| `prop:L` | Label | Etiqueta de texto de solo lectura (forma preferida; coincide con `type="L"`) |
| `prop:TL` | Label (alias legacy) | Selector legacy que coincide con `type="TL"`. El selector debe coincidir literalmente con el `type` declarado en el XML. |
| `prop:N` | Numérico | Campo numérico entero |
| `prop:N2` | Numérico decimal | Campo numérico con 2 decimales |
| `prop:NC` | Checkbox | Casilla de verificación / switch |
| `prop:B` | Botón | Botón de acción |
| `prop:Z` | Zona/Área | Contents, mapas, calendarios, gráficos |
| `prop:IMG` | Imagen | Campo de imagen estática/dinámica |
| `prop:AT` | Adjunto | Campo de archivo adjunto |
| `prop:PH` | Foto | Campo de fotografía |
| `prop:VD` | Video | Campo de video |
| `prop:D` | Fecha | Campo de fecha |
| `prop:DT` | Fecha-Hora | Campo de fecha y hora |
| `prop:X` | Password | Campo de contrasena |
| `prop:DR` | Dibujo/Firma | Campo de firma digital |
| `prop:WEB` | Web | Navegador web embebido |

```css
prop:B {
    forecolor: #000000;
    bgcolor: #CCCCCC;
    img-sel: ;
}

prop:NC {
    extends: prop;
    apply-css: true;
    labelwidth: 1;
    img-width: 50p;
    text-bgcolor: #00000000;
}

prop:IMG {
    labelwidth: 0;
    img-sign: bt_Firma.png;
    img-sign-sel: bt_Firma_sel.png;
}

prop:Z {
    extends: prop;
    bgcolor: #F2F2F2;
    width: 96%;
    lmargin: 2%;
    tmargin: 2%;
}

prop:AT {
    img-att: bt_attach.png;
    img-att-sel: bt_attach_sel.png;
}
```

### 3.4 Selector de Frame (`frame`)

Aplica estilos a **todos los elementos `<frame>`** del proyecto.

```css
frame {
    bgcolor: #FFFFFF;
    framebox: false;
}
```

### 3.5 Selector de Grupo (`group`)

Aplica estilos a **todos los elementos `<group>`** del proyecto.

```css
group {
    tab-visible: false;
}
```

### 3.6 Selector de Clase (`.className`)

```css
.miEstilo {
    width: 100%;
    height: 50p;
    bgcolor: #FF0000;
}
```

Uso en XML:
```xml
<frame name="frmEjemplo" class="miEstilo">
<prop name="txtCampo" class="miEstilo">
<!-- Multiples clases separadas por espacio -->
<frame name="frmHeader" class="frameHeader animSlideRight">
```

### 3.7 Herencia con `extends`

```css
.botonBase {
    width: 90%;
    height: 56p;
    bgcolor: #0066CC;
    forecolor: #FFFFFF;
    border-corner-radius: 28;
    text-align: center;
    fontsize: 16;
    fontname: Roboto-Bold.ttf;
}

.botonSecundario {
    extends: .botonBase;
    bgcolor: #666666;
}

.botonPeligro {
    extends: .botonBase;
    bgcolor: #F44336;
}
```

**Reglas de herencia:**
- Solo herencia simple (una clase padre por clase)
- La clase referenciada debe usar el prefijo `.`
- Atributos hijos sobreescriben heredados
- Se puede heredar en cadena: A extiende B que extiende C
- `extends: prop` hereda de la configuración global `prop`
- `extends: prop:TYPE` hereda del selector de tipo especifico

#### Herencia encadenada (cadena de extends)

```css
/* Nivel 1: hereda del global prop */
.classprop {
    extends: prop;
    lmargin: 2%;
    text-border: true;
}

/* Nivel 2: hereda de .classprop (que a su vez hereda de prop) */
.classtl {
    extends: .classprop;
    labelbox: true;
    width: 96%;
    align: center;
    bgcolor: #00000000;
    border: true;
    border-color: DarkBlue;
    border-width: 1p;
    elevation: 7;
}

/* Nivel 3: hereda de .classtl */
.classtlDestacada {
    extends: .classtl;
    bgcolor: #E3F2FD;
    border-color: #1565C0;
}
```

#### Herencia desde selector de tipo (`extends: prop:TYPE`)

Se puede heredar directamente de un selector de tipo para crear variantes de un tipo de control:

```css
/* Hereda todos los estilos de prop:B (boton) */
.btnButton {
    extends: prop:B;
    visible: 1;
    align: center;
    width: 300p;
    height: 100p;
    fontsize: 9;
    labelwidth: 1;
    fontbold: true;
    label-wrap: true;
    tmargin: 20p;
    lmargin: 30p;
}

/* Hereda de prop:NC (checkbox) para crear variante personalizada */
.xnCheckbox {
    extends: prop:NC;
    apply-css: true;
    labelwidth: 1;
    img-width: 50p;
    text-bgcolor: #00000000;
}
```

#### Herencia desde selector global (`extends: prop`)

```css
.classprop {
    extends: prop;
    lmargin: 2%;
    tmargin: 0p;
    text-border: true;
    text-border-width: 1p;
}
```

**Ejemplo de herencia en cadena (proyecto real):**
```css
.xnDarkBgcolor {
    bgcolor: #1565C0;
    forecolor: #FFFFFF;
}

.xnHeaderBar {
    extends: .xnDarkBgcolor;
    width: 100%;
    height: 10%;
    align: left|center;
}
```

---

## 4. Atributos CSS - Tipografía

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `fontname` | `NombreFuente.ttf` | Fuente personalizada (archivo .ttf en carpeta fonts/) |
| `fontsize` | Número (1-50) | Tamaño fuente (sin unidad) |
| `fontbold` | `true` / `false` | Negrita |
| `fontitalic` | `true` / `false` | Cursiva |
| `forecolor` | `#RRGGBB` / `#AARRGGBB` | Color texto y etiqueta |
| `forecolor-disabled` | `#RRGGBB` | Color fuente cuando deshabilitado |
| `text-forecolor` | `#RRGGBB` | Color texto editable |
| `text-forecolor-disabled` | `#RRGGBB` | Color texto deshabilitado |
| `text-fontsize` | Número | Tamaño fuente del texto editable |
| `labelfont-size` / `labelfontsize` | Número | Tamaño fuente etiqueta |
| `textfont-size` / `textfontsize` / `text-font-size` | Número | Tamaño fuente texto editable |
| `labelfont-bold` | `true` / `false` | Etiqueta negrita |
| `textfont-bold` | `true` / `false` | Texto editable negrita |
| `textfont-italic` | `true` / `false` | Texto editable cursiva |
| `labelshadow` | `true` / `false` | Sombra en etiqueta |

```css
.tituloSeccion {
    fontname: Roboto-Bold.ttf;
    fontsize: 20;
    forecolor: #212121;
}
```

---

## 5. Atributos CSS - Dimensiones y Unidades

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `width` | `Np` / `N%` | Ancho del elemento |
| `height` | `Np` / `N%` / `-2` | Alto del elemento. `-2` = alto definido por contenido |
| `size` | Número | Tamaño máximo de caracteres también es el tamaño máximo en la base de datos |
| `fieldsize` | Número | Tamaño de campo visual, es la cantidad de espacio que ocupa calculado ancho de carácter x valor de fieldsize |

| Unidad | Recomendado | Descripción |
|--------|-------------|-------------|
| `p` | SI | Puntos XOne: 1p = 1px en la resolución de referencia (NO equivale al `dp` de Android) |
| `%` | SI | Porcentaje del contenedor padre |
| `px` | NO | Pixeles físicos (no escala) |

> **REGLA:** Siempre usar `p` para fijos y `%` para responsivos. NUNCA `px`, `em`, `rem`.

---

## 6. Atributos CSS - Margenes y Padding

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `tmargin` | `Np` / `N%` | Margen superior |
| `bmargin` | `Np` / `N%` | Margen inferior |
| `lmargin` | `Np` / `N%` | Margen izquierdo |
| `rmargin` | `Np` / `N%` | Margen derecho |
| `tpadding` | `Np` | Padding superior |
| `bpadding` | `Np` | Padding inferior |
| `lpadding` | `Np` | Padding izquierdo |
| `rpadding` | `Np` | Padding derecho |

No existe atributo abreviado `margin` o `padding`.

---

## 7. Atributos CSS - Colores y Fondos

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `bgcolor` | `#RRGGBB` / `#AARRGGBB` | Color de fondo |
| `bgcolor-disabled` | `#RRGGBB` | Color de fondo cuando deshabilitado |
| `bgcolor-focus` | `#RRGGBB` | Color de fondo al recibir foco |
| `forecolor` | `#RRGGBB` / `#AARRGGBB` | Color primer plano |
| `text-bgcolor` | `#RRGGBB` | Fondo texto editable |
| `text-bgcolor-focus` | `#RRGGBB` | Fondo texto al recibir foco |
| `text-bgcolor-disabled` | `#RRGGBB` | Fondo texto deshabilitado |
| `border-color` | `#RRGGBB` | Color borde |
| `text-border-color` | `#RRGGBB` | Color borde texto |
| `imgbk` | `nombre.png` / `nombre.svg` | Imagen de fondo (PNG, JPG o SVG) |

> **ATENCION:** El formato alpha en XOne es `#AARRGGBB` (alpha PRIMERO), NO `#RRGGBBAA`.

---

## 8. Atributos CSS - Alineacion y Layout

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `align` | Combinacion con `\|` | Alineacion combinada |
| `text-align` | `left` / `center` / `right` | Alineacion texto |
| `newline` | `true` / `false` | Nueva linea |
| `scroll` | `true` / `false` | Scroll |
| `fixed` | `true` / `false` | Elemento fijo |
| `orientation` | `top` / `bottom` | Ancla del fijo |
| `floating` | `true` / `false` | Frame flotante |
| `top` | `Np` | Posición vertical de frame flotante |
| `left` | `Np` | Posición horizontal de frame flotante |
| `framebox` | `true` / `false` | Estilo de caja del frame (dibuja borde visual alrededor del frame) |

Valores de align: `left`, `center`, `right`, `top`, `bottom`. Combinar con `|`: `top|left`, `bottom|center`.

```css
/* Footer fijo anclado abajo */
.frameFooter {
    width: 100%;
    height: 120p;
    bgcolor: #FFFFFF;
    fixed: true;
    orientation: bottom;
}

/* FAB flotante posicionado */
.btnFAB {
    width: 112p;
    height: 112p;
    bgcolor: #FFC107;
    border-corner-radius: 56;
    labelwidth: 0;
    img-width: 48p;
    img-height: 48p;
    floating: true;
}
```

---

## 9. Atributos CSS - Etiquetas (Labels)

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `labelwidth` | 0-100 | Proporcion ancho etiqueta (0=sin etiqueta) |
| `labelbox` | `true` / `false` | Caja contenedora |
| `label-wrap` | `true` / `false` | Wrap del texto |
| `title` | `"texto"` | Texto etiqueta |
| `tooltip` | `"texto"` | Placeholder |

---

## 10. Atributos CSS - Bordes

### Bordes de texto

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `text-border` | `true` / `false` | Borde alrededor texto |
| `text-border-left` | `true` / `false` | Borde izquierdo del texto |
| `text-border-right` | `true` / `false` | Borde derecho del texto |
| `text-border-top` | `true` / `false` | Borde superior del texto |
| `text-border-bottom` | `true` / `false` | Borde inferior del texto |
| `text-border-color` | `#RRGGBB` | Color borde texto |
| `text-border-width` | `Np` | Grosor del borde de texto |

### Bordes de contenedor

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `border` | `true` / `false` | Borde general |
| `border-width` | Número | Grosor borde |
| `border-color` | `#RRGGBB` | Color borde |
| `border-corner-radius` | Número | Radio de todas las esquinas |
| `border-corner-radius-top-left` | Número | Radio esquina superior izquierda |
| `border-corner-radius-top-right` | Número | Radio esquina superior derecha |
| `border-corner-radius-bottom-left` | Número | Radio esquina inferior izquierda |
| `border-corner-radius-bottom-right` | Número | Radio esquina inferior derecha |
| `border-top` | `true` / `false` | Borde superior |
| `border-top-color` | `#RRGGBB` | Color borde sup |
| `border-bottom` | `true` / `false` | Borde inferior |
| `border-bottom-color` | `#RRGGBB` | Color borde inf |
| `framebox` | `true` / `false` | Borde frame |
| `grid-framebox` | `true` / `false` | Borde frame grid |
| `grid-text-border` | `true` / `false` | Borde texto grid |

### Patron Material Design (borde inferior)

```css
.inputMaterial {
    text-border: true;
    text-border-left: false;
    text-border-right: false;
    text-border-top: false;
    text-border-bottom: true;
    text-border-color: #BDBDBD;
}

.inputMaterialEnfocado {
    extends: .inputMaterial;
    text-border-color: #1565C0;
}
```

### Patron: Panel con esquinas superiores

```css
.panelInferior {
    width: 100%;
    bgcolor: #FFFFFF;
    border-corner-radius-top-left: 24;
    border-corner-radius-top-right: 24;
}
```

---

## 11. Atributos CSS - Texto y Campos

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `lines` | Número | Lineas visibles |
| `fixed-lines` | `true` / `false` | Altura fija por lineas |
| `locked` | `true` / `false` | Solo lectura |
| `locking` | `true` / `false` | Bloqueo persistente |
| `mask` | `"formato"` | Mascara formato |
| `zoom-controls` | `true` / `false` | Zoom en webviews |

---

## 12. Atributos CSS - Imágenes e Iconos

### Generales

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `img` | `nombre.png` | Imagen principal |
| `imgbk` | `nombre.png` | Imagen fondo |
| `imgsel` / `img-sel` | `nombre.png` | Imagen seleccionada |
| `img-width` | Número | Ancho icono |
| `img-height` | Número | Alto icono |

### Iconos del sistema

| Normal | Seleccionado | Descripción |
|--------|-------------|-------------|
| `img-spinner` | `img-spinner-sel` | Combo/selector |
| `img-search` | `img-search-sel` | Busqueda |
| `img-delete` | `img-delete-sel` | Eliminar |
| `img-undo` | `img-undo-sel` | Deshacer |
| `img-phone` | `img-phone-sel` | Telefono |
| `img-date` | `img-date-sel` | Fecha |
| `img-time` | `img-time-sel` | Hora |
| `img-checked` | `img-checked-disabled` | Checkbox marcado |
| `img-unchecked` | `img-unchecked-disabled` | Checkbox desmarcado |
| `img-camera` | `img-camera-sel` | Camara |
| `img-video` | `img-video-sel` | Video |
| `img-sign` | `img-sign-sel` | Firma |
| `img-att` | `img-att-sel` | Adjuntos |

### Configuración completa (proyecto real)

```css
prop {
    img-spinner: bt_Arrow_down.png;
    img-spinner-sel: bt_Arrow_down_Sel.png;
    img-search: bt_Lupa.png;
    img-search-sel: bt_Lupa_sel.png;
    img-delete: bt_Delete.png;
    img-delete-sel: bt_Delete_sel.png;
    img-undo: undo.png;
    img-undo-sel: undo_click.png;
    img-phone: bt_Phone.png;
    img-phone-sel: bt_Phone_sel.png;
    img-date: bt_Date.png;
    img-date-sel: bt_Date_sel.png;
    img-time: bt_Time.png;
    img-time-sel: bt_Time_sel.png;
    img-checked: bt_check.png;
    img-checked-disabled: bt_check_disabled.png;
    img-unchecked: bt_uncheck.png;
    img-unchecked-disabled: bt_uncheck_disabled.png;
    img-att: bt_attach.png;
    img-att-sel: bt_attach_sel.png;
    img-camera: bt_camera.png;
    img-camera-sel: bt_camera_sel.png;
    img-video: bt_camera.png;
    img-video-sel: bt_camera_sel.png;
    img-height: 28;
    img-width: 28;
}
```

---

## 13. Atributos CSS - Checkbox y Controles Toggle

### Checkbox

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `check-color-checked` | `#RRGGBB` | Color del checkbox cuando esta marcado |
| `check-color-unchecked` | `#RRGGBB` | Color del checkbox cuando esta desmarcado |
| `check-color-checked-disabled` | `#RRGGBB` | Color marcado deshabilitado |
| `check-color-unchecked-disabled` | `#RRGGBB` | Color desmarcado deshabilitado |
| `apply-css` | `true` / `false` | Aplicar estilos CSS al componente |

```css
.xnCheckbox {
    extends: prop;
    apply-css: true;
    labelwidth: 1;
    img-width: 50p;
    text-bgcolor: #00000000;
}

/* Checkbox con colores personalizados */
prop:NC {
    extends: prop;
    apply-css: true;
    check-color-checked: #1565C0;
    check-color-unchecked: #9E9E9E;
    check-color-checked-disabled: #BBDEFB;
    check-color-unchecked-disabled: #E0E0E0;
}
```

### Controles Slider y Switch

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `track-color` | `#RRGGBB` | Color de la pista (barra) del slider o switch |
| `thumb-color` | `#RRGGBB` | Color del pulgar (control deslizable) del slider o switch |

```css
.switchPersonalizado {
    track-color: #BBDEFB;
    thumb-color: #1565C0;
}
```

---

## 14. Atributos CSS - Visibilidad y Estado

| Valor | Edición | Lista | Contents |
|-------|:-------:|:-----:|:--------:|
| `0` | Oculto | Oculto | Oculto |
| `1` | Visible | Oculto | Oculto |
| `2` | Oculto | Visible | Oculto |
| `4` | Oculto | Oculto | Visible |
| `7` | Visible | Visible | Visible |

Otros atributos de estado:

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `ripple-effect` | `true` / `false` | Efecto ripple Material Design al pulsar el elemento |
| `undo-button` | `true` / `false` | Mostrar botón deshacer |
| `apply-css` | `true` / `false` | Aplicar estilos CSS al componente |
| `locked` | `true` / `false` | Campo de solo lectura |
| `locking` | `true` / `false` | Comportamiento de bloqueo persistente |

---

## 15. Atributos CSS - Elevacion y Sombras

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `elevation` | Número (0-24) | Elevacion del elemento (genera sombra en Android, estilo Material Design) |
| `shadow-color` | `#RRGGBB` | Color de la sombra |

```css
.tarjetaElevada {
    bgcolor: #FFFFFF;
    border-corner-radius: 12;
    elevation: 5;
}

.tarjetaFlotante {
    bgcolor: #FFFFFF;
    border-corner-radius: 16;
    elevation: 12;
    shadow-color: #1A000000;
}
```

> **NOTA:** La elevacion funciona principalmente en Android. En iOS el efecto puede variar. Como alternativa se pueden usar bordes sutiles para simular profundidad en iOS.

---

## 16. Atributos de Coleccion (`coll`)

### General

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `notab` | `true`/`false` | Sin pestanas |
| `group-swipe` | `true`/`false` | Swipe entre grupos |
| `show-toolbar` | `true`/`false` | Mostrar toolbar |
| `editmask` | Número | Mascara de edición (0 = sin mascara) |
| `nomenmask` | Número | Mascara de nomenclatura |
| `dependent` | `true`/`false` | Coleccion dependiente |
| `check-owner` | `true`/`false` | Verificar propietario |
| `show-selected-item` | `true`/`false` | Mostrar item seleccionado |
| `selected-item-start-index` | Número | Índice inicial de selección (-1=ninguno) |
| `viewmode` | `gridview`/`mapview`/`listview` | Modo de visualizacion |
| `gallery-columns` | Número | Columnas en modo galería |
| `drawer-orientation` | `left`/`right` | Orientación del drawer |

### Celdas Grid

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `cell-bgcolor` | `#RRGGBB` | Fondo celda |
| `cell-forecolor` | `#RRGGBB` | Texto celda |
| `cell-odd-color` | `#RRGGBB` | Color celdas impares (alternancia) |
| `cell-even-color` | `#RRGGBB` | Color celdas pares (alternancia) |
| `cell-border` | `true`/`false` | Borde celdas |
| `cell-border-color` | `#RRGGBB` | Color borde celda |
| `cell-border-width` | Número | Grosor borde |
| `cell-tpadding` / `cell-bpadding` | `Np` | Padding celda |
| `cell-align` | `left`/`center`/`right` | Alineacion celda |
| `cell-selected-bgcolor` | `#RRGGBB`/`#AARRGGBB` | Fondo selección |
| `cell-selected-forecolor` | `#RRGGBB` | Texto selección |

### Tabs

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `tab-visible` | `true`/`false` | Mostrar tabs |
| `tab-height` | `Np` | Altura tabs |
| `tab-fontsize` | Número | Tamaño fuente |
| `tab-bgcolor` | `#RRGGBB` | Fondo tabs |
| `tab-forecolor` | `#RRGGBB` | Texto tabs |
| `tab-selected-forecolor` | `#RRGGBB` | Texto seleccionado |
| `tab-indicator-color` | `#RRGGBB` | Indicador |

### Animaciones de coleccion

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `animation-in` | Token animación | Animación de entrada |
| `animation-out` | Token animación | Animación de salida |

```css
coll {
    notab: true;
    group-swipe: false;
    show-toolbar: false;
    editmask: 0;
    cell-bgcolor: #F2F2F2;
    cell-border-color: #00000000;
    cell-border-width: 0;
    cell-selected-bgcolor: #00000000;
    show-selected-item: false;
    selected-item-start-index: -1;
    animation-in: "##RIGHT_IN##";
    animation-out: "##RIGHT_OUT##";
}
```

---

## 17. Animaciones

### Atributos de animación

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `animation-in` | Token de animación | Animación de entrada |
| `animation-out` | Token de animación | Animación de salida |
| `animation-in-delay` | Milisegundos | Retardo animación entrada |
| `animation-out-delay` | Milisegundos | Retardo animación salida |

### Tokens de animación

| Token | Descripción |
|-------|-------------|
| `##RIGHT_IN##` | Entra desde la derecha |
| `##LEFT_IN##` | Entra desde la izquierda |
| `##RIGHT_OUT##` | Sale hacia la derecha |
| `##LEFT_OUT##` | Sale hacia la izquierda |
| `##PUSH_IN##` | Entra desde abajo |
| `##PUSH_OUT##` | Sale hacia arriba |
| `##PUSH_DOWN_IN##` | Entra desde arriba |
| `##PUSH_DOWN_OUT##` | Sale hacia abajo |
| `##ALPHA_IN##` | Fade in |
| `##ALPHA_OUT##` | Fade out |
| `##ZOOM_IN##` | Zoom de entrada |
| `##ZOOM_OUT##` | Zoom de salida |
| `##ROTATE3D_IN##` | Rotación 3D entrada |
| `##ROTATE3D_OUT##` | Rotación 3D salida |

### Clases de animación predefinidas

```css
.FrameAnimateFromTop {
    animation-in-delay: 500;
    animation-out-delay: 500;
    animation-in: ##PUSH_DOWN_IN##;
    animation-out: ##PUSH_OUT##;
}

.FrameAnimateFromBottom {
    animation-in-delay: 500;
    animation-out-delay: 500;
    animation-in: ##PUSH_IN##;
    animation-out: ##PUSH_DOWN_OUT##;
}

.FrameAnimateFromRight {
    animation-in-delay: 500;
    animation-out-delay: 500;
    animation-in: ##RIGHT_IN##;
    animation-out: ##LEFT_OUT##;
}

.FrameAnimateFromLeft {
    animation-in-delay: 500;
    animation-out-delay: 500;
    animation-in: ##LEFT_IN##;
    animation-out: ##RIGHT_OUT##;
}

.FrameAnimateAlpha {
    animation-in-delay: 500;
    animation-out-delay: 500;
    animation-in: ##ALPHA_IN##;
    animation-out: ##ALPHA_OUT##;
}

.FrameAnimateZoom {
    animation-in-delay: 500;
    animation-out-delay: 500;
    animation-in: ##ZOOM_IN##;
    animation-out: ##ZOOM_OUT##;
}
```

### Configuración del delay

El delay se expresa en milisegundos. Valores recomendados:
- 200ms: transiciones rápidas
- 300ms: transiciones estándar
- 500ms: transiciones lentas/dramaticas

```css
.animRapida {
    animation-in: ##RIGHT_IN##;
    animation-in-delay: 200;
    animation-out: ##LEFT_OUT##;
    animation-out-delay: 200;
}
```

---

## 18. Gráficos (Charts)

Los gráficos se usan con `type="Z"` y viewmode de gráfico (`barchart`, `piechart`, `timeserieschart`, `linechart`, `3dbarchart`, `slidingbarchart`, `piechart2`).

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `chart-serie-color` | `#COLOR1,#COLOR2,...` | Colores de las series |
| `chart-color-template` | `#COLOR1,#COLOR2,...` | Plantilla de colores |
| `chart-lock-x-axis` | `true`/`false` | Bloquear eje X |
| `chart-lock-y-axis` | `true`/`false` | Bloquear eje Y |
| `chart-show-series-item-labels` | `true`/`false` | Mostrar etiquetas de valores |
| `chart-series-item-label-format` | `##VALUE##` | Formato de etiquetas |
| `chart-category-label-rotation` | `up_45`/`up_90`/`down_45`/`down_90` | Rotación de etiquetas del eje X |
| `chart-category-max-value` | Número | Valor máximo de categoría |
| `chart-category-step-size` | Número | Tamaño del paso entre valores |
| `chart-max-visible-series` | Número | Máximo de series visibles |
| `show-legend` | `true`/`false` | Mostrar leyenda |
| `fontsize-legend` | Número | Tamaño fuente de la leyenda |

Los campos de datos del gráfico se definen en XML con atributos especiales:

```xml
<prop name="CATEGORIA" chart-category="true" />
<prop name="VALOR" chart-value="true" />
<prop name="COLOR" chart-color="true" />
```

```css
.clsCharts {
    width: 80%;
    height: 75%;
    chart-serie-color: #FF0000,#00FF00,#0000FF;
    chart-lock-x-axis: true;
    chart-lock-y-axis: true;
    show-legend: true;
    chart-show-series-item-labels: true;
    chart-series-item-label-format: ##VALUE##;
    chart-category-label-rotation: up_45;
}
```

---

## 19. Calendario

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `weekdays-bgcolor` | `#RRGGBB` | Color fondo fila días semana |
| `weekdays-forecolor` | `#RRGGBB` | Color texto días semana |
| `weekdays-fontsize` | Número | Tamaño fuente días semana |
| `weekdays-longname` | `true`/`false` | Nombres largos vs cortos |
| `weekdays-align` | `top`/`center`/`bottom` + `left`/`right` | Alineacion días |
| `page-swipe` | `true`/`false` | Permitir swipe entre meses |
| `cell-bgcolor` | `#RRGGBB`/`#AARRGGBB` | Color fondo celdas día |
| `cell-forecolor` | `#RRGGBB` | Color texto días |
| `cell-border-width` | Número | Grosor borde celda |
| `cell-align` | `left`/`center`/`right` | Alineacion contenido celda |
| `cell-selected-bgcolor` | `#RRGGBB`/`#AARRGGBB` | Fondo día seleccionado |
| `cell-selected-forecolor` | `#RRGGBB` | Texto día seleccionado |
| `cell-selected-border-color` | `#RRGGBB` | Borde día seleccionado |
| `cell-other-month-bgcolor` | `#RRGGBB`/`#AARRGGBB` | Fondo días otros meses |

```css
.z_calendario {
    extends: prop;
    forecolor: #FFFFFF;
    bgcolor: #00000000;
    cell-bgcolor: #68008CFF;
    cell-forecolor: #000000;
    cell-border-width: 2;
    cell-align: center;
    cell-selected-bgcolor: #00000000;
    cell-selected-forecolor: #0000CC;
    cell-selected-border-color: #0000CC;
    cell-other-month-bgcolor: #39767676;
    weekdays-bgcolor: #00000000;
    weekdays-forecolor: #000000;
    weekdays-fontsize: 4;
    weekdays-longname: true;
    page-swipe: true;
}
```

---

## 20. Mapas (MapView)

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `viewmode` | `mapview` / `openstreetmap` | Modo de mapa |
| `mapview-embedded` | `true`/`false` | Mapa embebido en el layout |
| `zoom-to-my-location` | `true`/`false` | Centrar en ubicación actual |
| `show-pois` | `true`/`false` | Mostrar puntos de interes |
| `clear-lines-on-refresh` | `true`/`false` | Limpiar lineas al refrescar |
| `clear-markers-on-refresh` | `true`/`false` | Limpiar marcadores al refrescar |
| `show-compass` | `true`/`false` | Mostrar brujula |
| `show-minimap` | `true`/`false` | Mostrar minimapa |
| `show-scale` | `true`/`false` | Mostrar escala |
| `follow-location-on-background` | `true`/`false` | Seguir ubicación en background |
| `zoom-buttons-visibility` | `always`/`never` | Visibilidad botones zoom |
| `show-google-buttons` | `true`/`false` | Mostrar botones Google |
| `zoom-to-pois` | `true`/`false` | Zoom a puntos de interes |

```css
.clsmapview {
    viewmode: mapview;
    mapview-embedded: true;
    clear-lines-on-refresh: false;
    clear-markers-on-refresh: false;
    show-pois: false;
    zoom-to-my-location: true;
}
```

---

## 21. Machine Learning

`ml-model-descriptor: modelo.json` - Separar por plataforma con `default_ios.css`.

---

## 22. Referencias Dinámicas a Campos `##FLD_CAMPO##`

XOne permite referenciar valores de propiedades del objeto actual directamente en CSS usando la sintaxis `##FLD_NOMBRE_CAMPO##`. Esto permite cambiar colores y estilos en tiempo de ejecución basandose en datos del registro actual.

### En CSS (clases)

```css
.frmDynamic {
    bgcolor: ##FLD_MAP_COLOR##;
}

.frmsuperior {
    width: 100%;
    height: 120p;
    bgcolor: ##FLD_MAP_COLORACTIVO##;
    align: left|center;
}
```

### En XML (atributos inline)

```xml
<prop name="MAP_LABEL" type="L"
      bgcolor="##FLD_MAP_COLOR1##"
      forecolor="##FLD_MAP_COLOR2##" />
```

### Funcionamiento

- `##FLD_MAP_COLOR##` obtiene el valor dinámico de la propiedad `MAP_COLOR` del objeto actual
- El valor debe ser un color valido en formato `#RRGGBB` o `#AARRGGBB`
- Los cambios se aplican cuando se carga o refresca el objeto
- Útil para indicadores de estado, colores por categoría, codificación visual de datos
- Funciona tanto en CSS como en atributos inline de XML

### Ejemplo práctico: Tarjeta con color dinámico por estado

```css
.tarjetaEstado {
    width: 95%;
    bgcolor: #FFFFFF;
    border-corner-radius: 12;
    border-top: true;
    border-top-color: ##FLD_COLOR_ESTADO##;
}
```

```xml
<!-- El campo COLOR_ESTADO contiene #4CAF50 para activo, #F44336 para inactivo, etc. -->
<prop name="COLOR_ESTADO" type="T" visible="0" />
<frame name="frmTarjeta" class="tarjetaEstado">
    <prop name="NOMBRE" type="L" />
    <prop name="ESTADO" type="L" forecolor="##FLD_COLOR_ESTADO##" />
</frame>
```

---

## 23. Patrones de Diseño Completos

### 23.1 Plantilla Base

```css
prop {
    fontname: Roboto-Regular.ttf;
    fontsize: 11;
    labelbox: false;
    label-wrap: true;
    text-border: false;
    forecolor: #212121;
}

coll {
    notab: true;
    show-toolbar: false;
    group-swipe: false;
    editmask: 0;
    bgcolor: #FFFFFF;
}

.frameHeader { width: 100%; height: 140p; bgcolor: #1565C0; align: center; }
.frameBody { width: 100%; height: 100%; scroll: true; bgcolor: #F5F5F5; }
.frameFooter { width: 100%; height: 120p; bgcolor: #FFFFFF; align: center; border-top: true; border-top-color: #E0E0E0; }

.tarjeta { width: 95%; bgcolor: #FFFFFF; border-corner-radius: 12; tmargin: 10p; bmargin: 5p; lmargin: 10p; rmargin: 10p; }

.btnPrimario { width: 90%; height: 56p; bgcolor: #1565C0; forecolor: #FFFFFF; border-corner-radius: 28; text-align: center; fontsize: 16; fontname: Roboto-Bold.ttf; }
.btnSecundario { width: 90%; height: 56p; bgcolor: #FFFFFF; forecolor: #1565C0; border: true; border-color: #1565C0; border-corner-radius: 28; text-align: center; fontsize: 16; }
.btnPeligro { width: 90%; height: 56p; bgcolor: #F44336; forecolor: #FFFFFF; border-corner-radius: 28; text-align: center; fontsize: 16; }
.btnExito { width: 90%; height: 56p; bgcolor: #4CAF50; forecolor: #FFFFFF; border-corner-radius: 28; text-align: center; fontsize: 16; fontname: Roboto-Bold.ttf; }

.inputTextoLinea { width: 95%; height: 56p; bgcolor: #FFFFFF; text-border: true; text-border-bottom: true; text-border-left: false; text-border-right: false; text-border-top: false; text-border-color: #BDBDBD; fontsize: 14; }

.textoTitulo { fontsize: 20; fontname: Roboto-Bold.ttf; forecolor: #212121; }
.textoSecundario { fontsize: 14; forecolor: #9E9E9E; }

.avatar { width: 64p; height: 64p; border-corner-radius: 32; }
.itemLista { width: 100%; height: 72p; bgcolor: #FFFFFF; border-bottom: true; border-bottom-color: #EEEEEE; }
.separador { width: 100%; height: 1p; bgcolor: #EEEEEE; }
.groupNoTab { tab-visible: false; }
```

### 23.2 Paleta Material Design

```
Azul:    #0D47A1 (oscuro), #1565C0 (medio), #1976D2 (claro), #E3F2FD (fondo)
Rojo:    #B71C1C (oscuro), #C62828 (medio), #D32F2F (claro), #FFEBEE (fondo)
Verde:   #1B5E20 (oscuro), #2E7D32 (medio), #388E3C (claro), #E8F5E9 (fondo)
Naranja: #E65100 (oscuro), #EF6C00 (medio), #F57C00 (claro), #FFF3E0 (fondo)
Morado:  #4A148C (oscuro), #6A1B9A (medio), #7B1FA2 (claro), #F3E5F5 (fondo)

Textos: #212121 (primario), #616161 (secundario), #9E9E9E (gris), #FFFFFF (sobre color)
Fondos: #FFFFFF, #F5F5F5, #E0E0E0, #EEEEEE
Estados: #4CAF50 (exito), #FFC107 (warning), #FF9800 (progreso), #F44336 (error), #2196F3 (info)
```

### 23.3 Badges con Herencia

```css
.badgeEstado { height: 28p; fontsize: 12; fontname: Roboto-Bold.ttf; forecolor: #FFFFFF; text-align: center; border-corner-radius: 14; }
.badgePendiente { extends: .badgeEstado; bgcolor: #FFC107; forecolor: #212121; }
.badgeAsignado { extends: .badgeEstado; bgcolor: #2196F3; }
.badgeEntregado { extends: .badgeEstado; bgcolor: #4CAF50; }
.badgeCancelado { extends: .badgeEstado; bgcolor: #9E9E9E; }
.badgeError { extends: .badgeEstado; bgcolor: #F44336; }
```

### 23.4 Chips

```css
.btnChip { height: 40p; bgcolor: #E3F2FD; forecolor: #1565C0; border-corner-radius: 20; text-align: center; fontsize: 14; }
.btnChipSeleccionado { height: 40p; bgcolor: #1565C0; forecolor: #FFFFFF; border-corner-radius: 20; text-align: center; fontsize: 14; }
```

### 23.5 FAB

```css
.btnFlotante { width: 64p; height: 64p; bgcolor: #1565C0; border-corner-radius: 32; }
```

### 23.6 Firma y Foto

```css
.areaFirma { width: 100%; height: 200p; bgcolor: #FAFAFA; border: true; border-color: #E0E0E0; border-corner-radius: 8; }
.fotoPreview { width: 100%; height: 200p; border-corner-radius: 8; }
```

---

## 24. Temas Claro y Oscuro

### default_night.css

```css
coll { bgcolor: #121212; }
prop { forecolor: #E0E0E0; }
.frameHeader { bgcolor: #1E1E1E; }
.frameBody { bgcolor: #121212; }
.tarjeta { bgcolor: #1E1E1E; }
.inputTexto { bgcolor: #2C2C2C; text-forecolor: #E0E0E0; }
```

### Separación de colores

```css
/* default-colors.css */
.xnDarkBgcolor { bgcolor: #1565C0; forecolor: #FFFFFF; }
.xnLightBgcolor { bgcolor: #F5F5F5; forecolor: #212121; }
.xnTransparentBgcolor { bgcolor: #00000000; }
```

---

## 25. CSS Responsivo y Adaptativo

XOne NO soporta media queries. En su lugar, se usan archivos CSS separados por condición de dispositivo:

| Archivo | Condición |
|---------|-----------|
| `default.css` | Base para todas las plataformas |
| `default_portrait.css` / `default.portrait.css` | Solo orientación vertical |
| `default_landscape.css` / `default.landscape.css` | Solo orientación horizontal |
| `default_ios.css` / `default.ios.css` | Solo iOS |
| `default_android.css` / `default.android.css` | Solo Android |
| `default_night.css` / `default.night.css` | Modo oscuro |
| `default_wear.css` | Wearables |
| `default.ios.portrait.css` | Condición combinada: iOS + vertical |

### Condiciones explicitas en app.xml

```xml
<style url="default.css" strict-mode="true" />
<style url="default-ios.css" conditions="ios" strict-mode="true" />
<style url="default_hor.css" conditions="phone:horizontal" strict-mode="true" />
<style url="tablet_ver.css" conditions="tablet:vertical" />
<style url="tablet_hor.css" conditions="tablet:horizontal" />
```

### Wearables

Para wearables se usa `default_wear.css`. En el CSS para wearable los tamaños deben ser más compactos y adaptados a pantallas circulares o pequeñas

---

## 26. Referencia de Transparencia Alpha (ARGB)

| % | Hex | Negro | Blanco |
|:-:|:---:|:-----:|:------:|
| 100% | FF | #FF000000 | #FFFFFFFF |
| 90% | E6 | #E6000000 | #E6FFFFFF |
| 80% | CC | #CC000000 | #CCFFFFFF |
| 70% | B3 | #B3000000 | #B3FFFFFF |
| 60% | 99 | #99000000 | #99FFFFFF |
| 50% | 80 | #80000000 | #80FFFFFF |
| 40% | 66 | #66000000 | #66FFFFFF |
| 30% | 4D | #4D000000 | #4DFFFFFF |
| 20% | 33 | #33000000 | #33FFFFFF |
| 10% | 1A | #1A000000 | #1AFFFFFF |
| 0% | 00 | #00000000 | #00FFFFFF |

Intermedios: 95%=F2, 85%=D9, 75%=BF, 65%=A6, 55%=8C, 45%=73, 35%=59, 25%=40, 15%=26, 5%=0D

---

## 27. Buenas Prácticas

1. **Organización**: `default.css` (base), `default-colors.css` (colores), `default_night.css` (oscuro)
2. **Nomenclatura**: Prefijos consistentes (`frame`, `btn`, `input`, `texto`, `tarjeta`, `item`, `badge`, `group`)
3. **Herencia**: Usar `extends` para variantes, no duplicar
4. **Unidades**: `p` para fijos, `%` para responsivos, `fontsize` sin unidad
5. **Comentarios**: Secciones con `/* ====== SECCION ====== */`

---

## 28. Errores Comunes

| Error | Incorrecto | Correcto |
|-------|-----------|----------|
| Unidades web | `font-size: 14px` | `fontsize: 14` |
| Guiones básicos | `bg-color: #FFF` | `bgcolor: #FFFFFF` |
| Alpha RGBA | `#00000080` | `#80000000` (ARGB) |
| Abreviados | `margin: 10p` | `tmargin: 10p; bmargin: 10p; ...` |
| Selectores web | `div.header {}` | `.header {}` |
| Sin extends | Duplicar atributos | `extends: .base; bgcolor: #NEW;` |

---

## 29. Funciones del parser CSS

El parser CSS de XOne soporta features de sintaxis que se procesan antes de que el motor de render aplique los estilos. Son transparentes para el consumidor: ve el valor final ya calculado/sustituido.

### Comentarios

```css
/* Comentario multilínea
   válido en cualquier posición fuera de un valor */

// Comentario de una sola línea hasta fin de línea

.tarjeta {
    bgcolor: #FFFFFF;     // pendiente: revisar contraste
}
```

> Los comentarios NO se reconocen dentro del valor de una declaración: `bgcolor: red /* nota */;` acumularía `red /* nota */` como valor.

### `@import` — composición de hojas

Solo al inicio del archivo. Las reglas, variables `:root` y declaraciones de la hoja importada se mergean.

```css
@import "colors.css";
@import url("base.css");

.frameHeader {
    bgcolor: var(--color-primario);   /* var declarada en colors.css */
}
```

Ciclos detectados (A→B→A). Sintaxis admitida: `@import "x";`, `@import 'x';`, `@import url("x");`, `@import url(x);`.

### Variables CSS

**Globales** (`:root`), orden de declaración irrelevante:

```css
:root {
    --color-primario: #1565C0;
    --espaciado-base: 8;
    --radio-tarjeta:  12;
    --color-acento:   var(--color-primario);   /* anidamiento permitido */
}

.tarjeta {
    bgcolor:              var(--color-primario);
    border-corner-radius: var(--radio-tarjeta);
    tmargin:              var(--espaciado-base);
    /* fallback si --color-error no existe */
    forecolor:            var(--color-error, #F44336);
}
```

**Locales** (cualquier otro bloque), scope sintáctico:

```css
.btnAccion {
    --pad: 16;
    lpadding: var(--pad);
    rpadding: var(--pad);
    tpadding: calc(var(--pad) / 2);
}
```

Case-sensitive (`--Color` ≠ `--color`). Si una local y una global tienen el mismo nombre, gana la local dentro de su bloque.

### `calc()` aritmético

`+`, `-`, `*`, `/`, paréntesis y `-` unario sobre **números puros** (sin unidades):

```css
:root {
    --base:  8;
    --doble: calc(var(--base) * 2);
}

.frameHeader {
    height:               calc(var(--base) * 20);
    border-corner-radius: calc(var(--doble) - 4);
    fontsize:             calc(14 + 2);
}
```

Entero exacto → entero (`calc(4 * 3)` → `12`, no `12.0`). División por cero / sintaxis inválida: en modo no estricto se preserva el `calc(...)` literal; en estricto se lanza error.

### `!important` y `!default`

Sufijos de declaración:

```css
.alerta {
    bgcolor: #FFF3CD !important;   /* no se sobreescribe por declaraciones normales */
}

/* Patrón de hoja base sobre-escribible */
boton {
    bgcolor:  gray !default;       /* solo aplica si no había declaración previa */
    fontsize: 14   !default;
    lmargin:  8    !default;
}

boton {
    bgcolor: #1565C0;              /* sobreescribe; fontsize y lmargin conservan default */
}
```

### `@extend selector;` — herencia vía at-rule

Alternativa moderna a `extends:`. Resuelve en post-pasada del parser, permite referencias adelantadas y detecta ciclos.

```css
.btnBase {
    width:  90%;
    height: 144p;
    border-corner-radius: 28;
    fontsize: 16;
}

.btnPrimario {
    @extend .btnBase;
    bgcolor:   #1565C0;
    forecolor: #FFFFFF;
}

.btnPeligro {
    @extend .btnPrimario;          /* encadenado */
    bgcolor: #F44336 !important;
}
```

**Hijo gana**: las declaraciones propias del bloque vencen sobre las heredadas, salvo cuando el padre es `!important` y el hijo no.

`@extend` y el atributo `extends:` conviven sin conflicto:
- `extends:` lo resuelve el motor de render (xonecss_lib) en cascada.
- `@extend` lo resuelve el parser antes; el bloque resultante ya contiene las declaraciones inline.

### Modo estricto

El framework puede arrancar el parser en modo estricto. En ese modo se convierten en error: variables `var(--x)` sin declarar ni fallback, `calc()` inválido o división por cero, target de `@extend` inexistente, declaraciones sin `;` o que cierran con `}` antes de tiempo. Recomendado durante desarrollo.

---

### Tabla Equivalencias CSS Web vs XOne

| CSS Web | XOne CSS |
|---------|----------|
| `font-size: 14px` | `fontsize: 14` |
| `font-family: Roboto` | `fontname: Roboto-Regular.ttf` |
| `font-weight: bold` | `fontbold: true` |
| `color: #333` | `forecolor: #333333` |
| `background-color: #fff` | `bgcolor: #FFFFFF` |
| `margin-top: 10px` | `tmargin: 10p` |
| `padding-left: 20px` | `lpadding: 20p` |
| `border-radius: 8px` | `border-corner-radius: 8` |
| `text-align: center` | `text-align: center` |
| `height: 50px` | `height: 50p` |
| `display: none` | `visible: 0` |
| `opacity: 0.5` | `bgcolor: #80...` (ARGB) |
| `overflow: scroll` | `scroll: true` |
| `position: fixed` | `fixed: true` |
| `var(--color)` | `var(--color)` (declarar en `:root`) |
| `calc(8px * 2)` | `calc(8 * 2)` (sobre números puros) |
| `@import url("a.css")` | `@import "a.css";` (solo al inicio) |
| `// comentario` o `/* */` | `// comentario` o `/* */` (no en valores) |

---

*Documento de referencia generado a partir de la knowledgebase oficial de XOne (docs/kb/css/), la guía de nuevos proyectos, y el análisis de proyectos reales y sinteticos en templates/. Incluye contenido de 01-fundamentos-css.md, 02-propiedades-css.md, 03-selectores-especiales.md, y 04-componentes-material.md.*
