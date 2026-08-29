# Guía Completa de CSS en XOne

> **Tópico 04** del skill de ayuda XOne. Este documento cubre el sistema CSS propietario completo de la plataforma XOne para aplicaciones móviles nativas.

---

## Tabla de Contenidos

1. [Introduccion al CSS de XOne](#1-introduccion-al-css-de-xone)
2. [Selectores](#2-selectores)
3. [Unidades de Medida](#3-unidades-de-medida)
4. [Colores](#4-colores)
5. [Propiedades CSS Disponibles](#5-propiedades-css-disponibles)
6. [Sistema de Herencia `extends:`](#6-sistema-de-herencia-extends)
7. [Selectores Condicionales y Dinámicos](#7-selectores-condicionales-y-dinamicos)
8. [Referencias Dinámicas a Campos en CSS](#8-referencias-dinamicas-a-campos-en-css)
9. [Cascada de Condiciones de Dispositivo](#9-cascada-de-condiciones-de-dispositivo)
10. [Animaciones](#10-animaciones)
11. [Gráficos (Charts)](#11-graficos-charts)
12. [Calendario](#12-calendario)
13. [Mapa](#13-mapa)
14. [Patrones de Diseño Material Design](#14-patrones-de-diseno-material-design)
15. [Temas (Light y Dark)](#15-temas-light-y-dark)
16. [CSS Completo de Ejemplo](#16-css-completo-de-ejemplo)
17. [Best Practices](#17-best-practices)
18. [Funciones del parser CSS](#18-funciones-del-parser-css)

---

## 1. Introduccion al CSS de XOne

### 1.1 Que es y que NO es

El sistema CSS de XOne es un **sistema de estilos propietario** inspirado en la sintaxis de CSS web, pero disenado especificamente para controlar la apariencia y el comportamiento de aplicaciones móviles nativas generadas para Android e iOS.

**Lo que ES:**

- Un lenguaje de estilos con sintaxis similar a CSS web (selectores, llaves, atributos con valor)
- Un sistema con atributos propietarios especificos para componentes UI móviles
- Un mecanismo de cascada con archivos por plataforma, orientación y tema
- Un sistema con herencia explicita mediante el atributo `extends`

**Lo que NO es:**

- **NO es CSS web estándar.** Aunque se parece, las reglas son distintas.
- **NO soporta** Flexbox, Grid, media queries, pseudo-clases, pseudo-elementos, transiciones, transformaciones, gradientes, ni selectores combinadores (`>`, `+`, `~`, espacio descendiente).
- **NO usa** las unidades `px`, `em`, `rem`, `vh`, `vw`, `vmin`, `vmax`.
- **NO permite** `@media`, `@keyframes`, `@font-face` (las fuentes se referencian directamente por nombre de archivo).

**Lo que SÍ es (subconjunto admitido por el parser):**

- **Variables CSS**: `:root { --color: #FF0000; }` + `var(--color)` con fallback. Globales en `:root` y locales con scope de bloque. Una variable puede referenciar a otra.
- **`calc(...)`**: aritmética con `+`, `-`, `*`, `/` y paréntesis sobre números puros (sin unidades).
- **`@import`**: para componer una hoja a partir de otras. Solo al inicio del archivo.
- **`@extend selector;`**: at-rule alternativa al atributo `extends:` tradicional. Copia las declaraciones en post-pasada del parser.
- **`!important` y `!default`**: control de cascada por declaración.
- **Comentarios** `/* */` y `//` (este último, de una sola línea).
- **Selectores múltiples**: `a, b, c { ... }` aplica el bloque a cada selector como instancia independiente.

**Diferencias clave con CSS web:**

| Concepto | CSS Web | CSS XOne |
|----------|---------|----------|
| Unidades de medida | `px`, `em`, `rem`, `vw`, `vh` | `p` (puntos), `%` (porcentaje) |
| Color con alpha | `rgba(0,0,0,0.5)` o `#00000080` | `#80000000` (formato **ARGB**, alpha primero) |
| Tamaño de fuente | `font-size: 14px` | `fontsize: 14` (sin unidad) |
| Margen superior | `margin-top: 10px` | `tmargin: 10p` |
| Negrita | `font-weight: bold` | `fontbold: true` |
| Nombre de fuente | `font-family: 'Roboto'` | `fontname: Roboto-Regular.ttf` |
| Color de fondo | `background-color: #fff` | `bgcolor: #FFFFFF` |
| Padding izquierdo | `padding-left: 20px` | `lpadding: 20p` |
| Bordes redondeados | `border-radius: 8px` | `border-corner-radius: 8` (sin unidad) |
| Ocultar elemento | `display: none` | `visible: 0` |
| Scroll | `overflow: scroll` | `scroll: true` |
| Posición fija | `position: fixed` | `fixed: true` |
| Herencia de estilos | Cascada automática | `extends: .nombreClase` o `@extend .nombreClase;` |
| Variables | `var(--mi-color)` | `:root { --mi-color: red; }` + `var(--mi-color)` (admite fallback y anidamiento) |
| Aritmética | `calc(8px * 2)` | `calc(8 * 2)` (sobre números puros, sin unidades) |
| Importación | `@import url("base.css")` | `@import "base.css";` (solo al inicio del archivo) |
| Responsive | `@media (max-width: 600px)` | NO SOPORTADO (archivos separados por plataforma) |
| Layout flexible | `display: flex` | NO SOPORTADO (usar `frame` y `group` en XML) |

> **Referencia cruzada:** Para entender como se aplican las clases CSS en el XML de XOne, consultar el tópico [02 - Estructura XML](./02-xml-ui-complete-guide.md). Para la estructura general de archivos del proyecto, consultar el tópico [01 - Fundamentos](./01-xone-fundamentals.md).

### 1.2 Donde se define

Los estilos se definen en archivos `.css` ubicados en la **raiz del proyecto** XOne.

**Archivo obligatorio:**

| Archivo | Descripción | Obligatorio |
|---------|-------------|:-----------:|
| `default.css` | Estilos base globales de la aplicación | SI |

**Archivos opcionales (reconocidos automáticamente por convencion de nombre):**

| Archivo | Descripción |
|---------|-------------|
| `default-colors.css` / `colors.css` | Paleta de colores separada (facilita tematizacion) |
| `default_night.css` | Variante tema oscuro |
| `default_day.css` | Variante tema claro |
| `default_portrait.css` | Estilos para orientación vertical |
| `default_landscape.css` | Estilos para orientación horizontal |
| `default_ios.css` | Estilos especificos para iOS |
| `default_wear.css` | Estilos para wearables (smartwatch) |
| `básico.css` | Estilos básicos reutilizables |

**Declaración en `app.xml`:**

Solo se declara el archivo `default.css` en la configuración de la aplicación. Los archivos variantes se cargan automáticamente por convencion de nombres.

```xml
<app ...>
    <style url="default.css" encoding="UTF-8" />
</app>
```

> **Referencia cruzada:** Para conocer la configuración completa de `app.xml`, consultar el tópico [01 - Fundamentos](./01-xone-fundamentals.md).

### 1.3 Como se aplica

Los estilos CSS se aplican a los elementos XML mediante el atributo `class`:

```xml
<!-- Clase simple -->
<frame name="frmHeader" class="frameHeader">

<!-- Multiples clases separadas por espacio -->
<prop name="txtNombre" class="textoEditable inputTextoLinea">
```

**Sistema de cascada (de menor a mayor prioridad):**

```
1. default.css              (Estilos base - MENOR prioridad)
2. default_ios.css          (Especifico de plataforma)
3. default_portrait.css     (Especifico de orientacion)
4. default_night.css        (Especifico de tema)
5. Atributos inline en XML  (MAYOR prioridad)
```

Esto significa que un atributo definido directamente en el nodo XML siempre gana sobre cualquier clase CSS, y un estilo de tema (`default_night.css`) gana sobre un estilo de plataforma (`default_ios.css`).

---

## 2. Selectores

XOne soporta un conjunto limitado pero funcional de selectores CSS. A diferencia de CSS web, **no existen** selectores de etiqueta HTML, selectores de ID (`#`), selectores combinadores (`>`, `+`, `~`), selectores de atributo (`[attr]`), ni pseudo-clases/pseudo-elementos.

### 2.1 Selector de coleccion: `coll`

Aplica estilos a **todas las colecciones** del proyecto. Una coleccion equivale a una pantalla o vista en la aplicación.

```css
coll {
    notab: true;
    show-toolbar: false;
    group-swipe: false;
    editmask: 0;
    bgcolor: #FFFFFF;
    cell-bgcolor: #F2F2F2;
    cell-border: false;
    cell-tpadding: 2p;
    cell-bpadding: 2p;
    show-selected-item: false;
}
```

**Atributos aplicables al selector `coll`:**

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `notab` | `true`/`false` | Ocultar pestanas de navegación |
| `show-toolbar` | `true`/`false` | Mostrar barra de herramientas |
| `group-swipe` | `true`/`false` | Permitir swipe entre grupos |
| `editmask` | Número | Mascara de edición |
| `nomenmask` | Número | Mascara de nomenclatura |
| `dependent` | `true`/`false` | Coleccion dependiente |
| `check-owner` | `true`/`false` | Verificar propietario |
| `bgcolor` | `#RRGGBB` | Color de fondo de la coleccion |
| `viewmode` | `gridview`/`mapview`/`listview` | Modo de visualizacion |
| `gallery-columns` | Número | Columnas en modo galería |
| `cell-bgcolor` | `#RRGGBB` | Color de fondo de las celdas de lista |
| `cell-odd-color` | `#RRGGBB` | Color de celdas impares (alternancia) |
| `cell-even-color` | `#RRGGBB` | Color de celdas pares (alternancia) |
| `cell-border-color` | `#RRGGBB` | Color del borde de celda |
| `cell-border-width` | Número | Grosor del borde de celda |
| `cell-selected-bgcolor` | `#RRGGBB` / `#AARRGGBB` | Fondo de celda seleccionada |
| `cell-tpadding` | `Np` | Padding superior de celda |
| `cell-bpadding` | `Np` | Padding inferior de celda |
| `show-selected-item` | `true`/`false` | Mostrar item seleccionado |
| `selected-item-start-index` | Número | Índice inicial de selección (-1=ninguno) |
| `animation-in` | Token animación | Animación de entrada |
| `animation-out` | Token animación | Animación de salida |

**Ejemplo real (proyecto UseCars):**

```css
coll {
    notab: true;
    show-toolbar: false;
    group-swipe: false;
    editmask: 0;
    bgcolor: #FFFFFF;
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

### 2.2 Selector de propiedad: `prop`

Aplica estilos por defecto a **todas las propiedades** (campos/controles) de la aplicación. Este selector es fundamental para establecer la tipografía base y el comportamiento visual de todos los campos.

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

**Ejemplo real (proyecto MiMensajeria) con fontsize diferente y más propiedades base:**

```css
prop {
    fontname: Roboto-Regular.ttf;
    fontsize: 14;
    labelbox: false;
    label-wrap: true;
    text-border: false;
    forecolor: #212121;
    text-forecolor: #333333;
    text-forecolor-disabled: #909090;
    visible: 1;
    lmargin: 0;
    tmargin: 0;
    width: 96%;
    labelwidth: 7;
    imgsel: ;
}
```

> **IMPORTANTE:** Los valores definidos en el selector `prop` sirven como base que todas las propiedades heredan. Es la forma de establecer una tipografía y comportamiento coherente en toda la aplicación.

### 2.3 Selector por tipo: `prop:TYPE`

Permite definir estilos especificos según el tipo de campo. Solo aplica a las propiedades (`<prop>`) que tengan el atributo `type` correspondiente.

**Tabla de todos los tipos soportados:**

| Selector | Tipo | Descripción |
|----------|------|-------------|
| `prop:T` | Texto | Campo de texto simple |
| `prop:L` | Label | Etiqueta de texto de solo lectura (forma preferida; coincide con `type="L"`) |
| `prop:TL` | Label (alias legacy) | Selector legacy que coincide con `type="TL"`. El selector debe coincidir literalmente con el `type` declarado en el XML. |
| `prop:N` | Numérico | Campo numérico entero |
| `prop:N2` | Numérico decimal | Campo numérico con 2 decimales |
| `prop:NC` | Checkbox | Campo de selección / casilla de verificación |
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
| `prop:WEB` | Web | Navegador embebido |

**Ejemplo - Configurar botones globalmente:**

```css
prop:B {
    forecolor: #000000;
    bgcolor: #CCCCCC;
    img-sel: ;
}
```

**Ejemplo - Configurar campos de imagen:**

```css
prop:IMG {
    labelwidth: 0;
    img-sign: bt_Firma.png;
    img-sign-sel: bt_Firma_sel.png;
}
```

**Ejemplo - Configurar campos tipo Zona (contents, mapas, gráficos):**

```css
prop:Z {
    extends: prop;
    bgcolor: #F2F2F2;
    width: 96%;
    lmargin: 2%;
    tmargin: 2%;
}
```

**Ejemplo - Configurar campos tipo Checkbox:**

```css
prop:NC {
    extends: prop;
    apply-css: true;
    labelwidth: 1;
    img-width: 50p;
    text-bgcolor: #00000000;
}
```

**Ejemplo - Configurar campos tipo Adjunto:**

```css
prop:AT {
    img-att: bt_attach.png;
    img-att-sel: bt_attach_sel.png;
}
```

> **IMPORTANTE:** Los selectores `prop:TYPE` permiten establecer estilos globales por tipo de control. Esto es especialmente útil para configurar iconos del sistema (como los de adjunto, firma, camara) una sola vez, en lugar de repetirlos en cada campo individual.

### 2.4 Selector de clase: `.nombreClase`

Define estilos reutilizables que se aplican mediante el atributo `class` en los nodos XML. Este es el selector más utilizado para crear componentes visuales personalizados.

**Sintaxis:**

```css
.miClase {
    width: 100%;
    height: 50p;
    bgcolor: #FF0000;
    forecolor: #FFFFFF;
}
```

**Uso en XML:**

```xml
<frame name="frmEjemplo" class="miClase">
<prop name="txtCampo" class="miClase">
```

**Convenciones de nomenclatura recomendadas:**

| Prefijo | Proposito | Ejemplo |
|---------|-----------|---------|
| `frame` | Contenedores de layout | `.frameHeader`, `.frameBody`, `.frameFooter` |
| `btn` | Botones | `.btnPrimario`, `.btnSecundario`, `.btnPeligro` |
| `input` | Campos de texto editables | `.inputTexto`, `.inputBusqueda` |
| `texto` | Etiquetas y textos no editables | `.textoTitulo`, `.textoSecundario` |
| `tarjeta` | Tarjetas/cards | `.tarjeta`, `.tarjetaViaje` |
| `item` | Items de lista | `.itemLista`, `.itemEnvio` |
| `badge` | Badges de estado | `.badgeEstado`, `.badgePendiente` |
| `avatar` | Imágenes circulares de usuario | `.avatar`, `.avatarGrande` |
| `icono` | Iconos | `.iconoAccion`, `.iconoPequeno` |
| `group` | Grupos y tabs | `.groupNoTab`, `.groupConTab` |
| `separador` | Separadores de lista | `.separador`, `.separadorConMargen` |
| `color` | Definiciones de color (en colors.css) | `.colorPrimario`, `.colorExito` |
| `anim` | Clases de animación | `.animFadeIn`, `.animSlideRight` |

### 2.5 Selector de grupo: `group`

Aplica estilos a todos los elementos `<group>` de la aplicación. También se pueden aplicar estilos a grupos individuales mediante clases CSS (`.nombreClase`) asignadas con el atributo `class` en el XML del grupo.

```css
group {
    tab-visible: false;
}
```

**Atributos de grupo más comunes:**

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `tab-visible` | `true`/`false` | Mostrar pestanas |
| `tab-height` | `Np` | Altura de pestanas |
| `tab-fontsize` | Número | Tamaño fuente de pestanas |
| `tab-bgcolor` | `#RRGGBB` | Color de fondo de pestanas |
| `tab-forecolor` | `#RRGGBB` | Color de texto de pestanas |
| `tab-selected-forecolor` | `#RRGGBB` | Color texto pestana seleccionada |
| `tab-indicator-color` | `#RRGGBB` | Color del indicador de pestana |

**Ejemplo real - Grupo con tabs azules (proyecto UseCars):**

```css
.groupConTab {
    tab-visible: true;
    tab-height: 56p;
    tab-fontsize: 14;
    tab-bgcolor: #0D47A1;
    tab-forecolor: #BBDEFB;
    tab-selected-forecolor: #FFFFFF;
    tab-indicator-color: #FFFFFF;
}
```

**Ejemplo real - Grupo sin tabs (todos los proyectos):**

```css
.groupNoTab {
    tab-visible: false;
}
```

**Ejemplo - Grupos fijos como Header/Footer:**

```css
.groupfixed_header {
    fixed: true;
    orientation: top;
    width: 100%;
    height: 120p;
}

.groupfixed_footer {
    fixed: true;
    orientation: bottom;
    width: 100%;
    height: 120p;
}
```

```xml
<group name="HEADER" id="10" class="groupfixed_header">
    <frame name="frmtitulo" class="frmsuperior">
        <!-- contenido header -->
    </frame>
</group>

<group name="FOOTER" id="0" class="groupfixed_footer">
    <frame name="frmFooter" class="frmsuperior">
        <!-- contenido footer -->
    </frame>
</group>
```

### 2.6 Selector de frame: `frame`

Aplica estilos a todos los elementos `<frame>` de la aplicación. Al igual que con los grupos, se pueden aplicar estilos a frames individuales mediante clases CSS asignadas con el atributo `class`.

```css
frame {
    bgcolor: #FFFFFF;
    framebox: false;
}
```

**Ejemplo - Estilos por clase para frames especificos:**

```css
/* Frame principal con contenido dinamico */
.frmPrincipal {
    width: 100%;
    height: 100%;
    bgcolor: #333333;
    scroll: true;
}

/* Frame superior con color dinamico */
.frmsuperior {
    width: 100%;
    height: 120p;
    bgcolor: ##FLD_MAP_COLORACTIVO##;
    align: left|center;
}

/* Frame contenido con elevacion */
.frameContenido {
    width: 100%;
    bgcolor: #FFFFFF;
    framebox: true;
    border-corner-radius: 10;
    elevation: 5;
}
```

> **NOTA:** En la práctica es más común usar clases (`.frameHeader`, `.frameBody`, `.frameFooter`) que el selector global `frame`, ya que cada frame suele tener estilos muy diferentes.

### 2.7 Resumen de selectores

| Selector | Aplica a | Ejemplo |
|----------|----------|---------|
| `coll` | Todas las colecciones (pantallas) | `coll { bgcolor: #FFFFFF; }` |
| `prop` | Todas las propiedades (campos/controles) | `prop { fontsize: 11; }` |
| `prop:T` | Todas las propiedades tipo Texto | `prop:T { text-border: true; }` |
| `prop:N` | Todas las propiedades tipo Numérico | `prop:N { text-align: right; }` |
| `prop:B` | Todas las propiedades tipo Botón | `prop:B { bgcolor: #CCCCCC; }` |
| `prop:NC` | Todas las propiedades tipo Checkbox | `prop:NC { apply-css: true; }` |
| `prop:Z` | Todas las propiedades tipo Zona | `prop:Z { bgcolor: #F2F2F2; }` |
| `prop:IMG` | Todas las propiedades tipo Imagen | `prop:IMG { labelwidth: 0; }` |
| `prop:D` | Todas las propiedades tipo Fecha | `prop:D { img-date: ic_date.png; }` |
| `group` | Todos los grupos | `group { tab-visible: false; }` |
| `frame` | Todos los frames | `frame { framebox: false; }` |
| `.clase` | Elementos con `class="clase"` | `.miClase { width: 100%; }` |

---

## 3. Unidades de Medida

### 3.1 `p` (puntos) - Unidad absoluta

La unidad `p` representa **pixels en el dispositivo de referencia** definido por `resolution-width` y `resolution-height` en `app.xml`. En el dispositivo de referencia, `1p = 1px` real. En cualquier otro dispositivo, XOne escala automáticamente con la fórmula `tamaño_real_px = valor_p × (resolucion_real / resolution-width)`.

> **CRÍTICO: `p` ≠ Material `dp`.** Es un error común asumir que `p` equivale a `dp` (density-independent pixels) de Android. **NO lo es.** Para el dispositivo de referencia por defecto de XOne (1080×1920, xxhdpi, density 3×), Material `56dp` ≈ `168p`, NO `56p`. Aplicar valores Material directamente como `p` produce barras/botones ~3× más pequeños de lo necesario.

| Material | `dp` | XOne `p` (1080×1920) |
|---|---|---|
| Toolbar | 56 | **164p**–`168p` (workflow: 164p) |
| Botón estándar | 48 | **144p** |
| Botón CTA pill | — | **124p** (workflow) |
| Icono toolbar | 24 | **72p** |
| Avatar lista | 40 | **120p** |
| Item lista | 48 | **144p** |
| FAB | 56 | **168p** |
| Touch target mínimo | 48 | **144p** |

```css
/* CORRECTO — calibrado para 1080×1920 */
.frameHeader {
    width: 100%;
    height: 164p;        /* Material 56dp × 3 = ~168p; workflow estándar 164p */
}

.btnPrimario {
    width: 90%;
    height: 124p;        /* Workflow "pill" CTA */
    border-corner-radius: 62;
}
```

**Cuando usar `p`:**

- Alturas fijas de headers, footers, botones
- Tamaños de iconos y avatares
- Margenes y paddings fijos
- Radios de bordes (aunque estos van sin unidad)
- Dimensiones de componentes que no deben cambiar con el tamaño de pantalla

### 3.2 `%` (porcentaje) - Unidad relativa

El porcentaje es relativo al **contenedor padre** (frame o grupo). Es la unidad recomendada para anchos y alturas que deben adaptarse al tamaño de pantalla.

```css
/* CORRECTO */
.frameBody {
    width: 100%;
    height: 100%;
}

.tarjeta {
    width: 95%;
    lmargin: 2.5%;
}
```

**Cuando usar `%`:**

- Anchos de contenedores principales (body, cards)
- Layouts responsivos
- Margenes laterales proporcionales
- Alturas de áreas que deben ocupar el espacio disponible

### 3.3 Sin unidad (numéricos)

Algunos atributos aceptan valores numéricos sin unidad:

| Atributo | Ejemplo | Nota |
|----------|---------|------|
| `fontsize` | `fontsize: 14` | Tamaño de fuente relativo |
| `border-corner-radius` | `border-corner-radius: 28` | Radio de esquinas |
| `border-width` | `border-width: 2` | Grosor de borde |
| `labelwidth` | `labelwidth: 30` | Proporcion etiqueta (0-100) |
| `lines` | `lines: 3` | Número de lineas visibles |
| `visible` | `visible: 7` | Mascara de visibilidad |
| `gallery-columns` | `gallery-columns: 3` | Columnas de galería |
| `img-width` / `img-height` | `img-width: 28` | Tamaño de iconos del sistema |

### 3.4 PROHIBIDO: px, em, rem, vh, vw

Las siguientes unidades **NO están soportadas** en XOne CSS y su uso producira comportamiento inesperado o sera ignorado:

| Unidad prohibida | Alternativa correcta en XOne |
|------------------|------------------------------|
| `px` | `p` (pixel en el dispositivo de referencia). **NO usar `dp`** — XOne lo ignora o lo trata como `p`. Material `56dp` no es `56p`: en 1080×1920 son `~168p` |
| `em` | Valor numérico sin unidad para `fontsize` |
| `rem` | Valor numérico sin unidad para `fontsize` |
| `vh` | `%` (porcentaje del contenedor padre) |
| `vw` | `%` (porcentaje del contenedor padre) |
| `vmin` / `vmax` | No tiene equivalente directo |
| `pt` | `p` (puntos XOne) |
| `cm` / `mm` / `in` | `p` (puntos XOne) |

**Ejemplo de errores frecuentes:**

```css
/* INCORRECTO - Unidades web no soportadas */
.miClase {
    height: 56px;         /* MAL: px no soportado */
    fontsize: 1.2em;      /* MAL: em no soportado */
    width: 100vw;         /* MAL: vw no soportado */
    margin-top: 10rem;    /* MAL: rem no soportado, y el atributo es tmargin */
}

/* CORRECTO - Unidades XOne */
.miClase {
    height: 56p;          /* BIEN: puntos */
    fontsize: 14;         /* BIEN: sin unidad */
    width: 100%;          /* BIEN: porcentaje */
    tmargin: 10p;         /* BIEN: puntos con nombre correcto */
}
```

> **Nota técnica:** La knowledgebase menciona `px` como opción disponible (`width: Npx`), pero **no es recomendado** porque no escala entre dispositivos con diferentes densidades de pantalla. Usar siempre `p` en su lugar.

---

## 4. Colores

### 4.1 Formato #RRGGBB

El formato más común para definir colores en XOne. Usa 6 digitos hexadecimales que representan los componentes Rojo, Verde y Azul.

```css
.miClase {
    bgcolor: #FFFFFF;     /* Blanco */
    forecolor: #212121;   /* Gris casi negro */
    border-color: #E0E0E0; /* Gris claro */
}
```

**IMPORTANTE:** Siempre usar los 6 digitos completos. Las abreviaturas de 3 digitos (`#FFF`, `#333`) **no están garantizadas**. Usar siempre la forma completa:

```css
/* INCORRECTO - Abreviatura potencialmente no soportada */
.error {
    bgcolor: #FFF;
    forecolor: #333;
}

/* CORRECTO - Forma completa */
.correcto {
    bgcolor: #FFFFFF;
    forecolor: #333333;
}
```

### 4.2 Formato #AARRGGBB (con alpha)

XOne soporta transparencia en los colores mediante el formato **ARGB** (Alpha, Red, Green, Blue). **ATENCION:** a diferencia del formato CSS web `#RRGGBBAA` donde el alpha va al final, en XOne el componente **alpha va PRIMERO**.

```css
.elementoTransparente {
    bgcolor: #80000000;   /* Negro con 50% de opacidad */
}

.fondoSemiTransparente {
    bgcolor: #CC1565C0;   /* Azul con 80% de opacidad */
}

.totalmenteTransparente {
    bgcolor: #00000000;   /* Completamente transparente */
}

.totalmenteOpaco {
    bgcolor: #FFFFFFFF;   /* Blanco completamente opaco */
}
```

**Tabla de valores alpha comunes:**

| Opacidad | Hex Alpha | Negro con alpha | Blanco con alpha |
|:--------:|:---------:|:---------------:|:----------------:|
| 100% | `FF` | `#FF000000` | `#FFFFFFFF` |
| 95% | `F2` | `#F2000000` | `#F2FFFFFF` |
| 90% | `E6` | `#E6000000` | `#E6FFFFFF` |
| 85% | `D9` | `#D9000000` | `#D9FFFFFF` |
| 80% | `CC` | `#CC000000` | `#CCFFFFFF` |
| 75% | `BF` | `#BF000000` | `#BFFFFFFF` |
| 70% | `B3` | `#B3000000` | `#B3FFFFFF` |
| 65% | `A6` | `#A6000000` | `#A6FFFFFF` |
| 60% | `99` | `#99000000` | `#99FFFFFF` |
| 55% | `8C` | `#8C000000` | `#8CFFFFFF` |
| 50% | `80` | `#80000000` | `#80FFFFFF` |
| 45% | `73` | `#73000000` | `#73FFFFFF` |
| 40% | `66` | `#66000000` | `#66FFFFFF` |
| 35% | `59` | `#59000000` | `#59FFFFFF` |
| 30% | `4D` | `#4D000000` | `#4DFFFFFF` |
| 25% | `40` | `#40000000` | `#40FFFFFF` |
| 20% | `33` | `#33000000` | `#33FFFFFF` |
| 15% | `26` | `#26000000` | `#26FFFFFF` |
| 10% | `1A` | `#1A000000` | `#1AFFFFFF` |
| 5% | `0D` | `#0D000000` | `#0DFFFFFF` |
| 0% | `00` | `#00000000` | `#00FFFFFF` |

**Error frecuente - Orden del alpha:**

```css
/* INCORRECTO - Alpha al final (formato CSS web) */
.error {
    bgcolor: #00000080;   /* ESTO NO DA 50% transparencia en XOne */
}

/* CORRECTO - Alpha al principio (formato XOne ARGB) */
.correcto {
    bgcolor: #80000000;   /* ESTO SI da 50% transparencia */
}
```

### 4.3 Colores con nombre

XOne tiene soporte limitado para la palabra clave `transparent`:

```css
.elementoTransparente {
    bgcolor: transparent;
}
```

Sin embargo, es más fiable usar el formato hexadecimal `#00000000` para transparencia total. **No se garantiza** el soporte de otros nombres de color web como `red`, `blue`, `green`, etc.

```css
/* INCORRECTO - Nombres de color no garantizados */
.error {
    bgcolor: red;
    forecolor: white;
}

/* CORRECTO - Usar hexadecimal siempre */
.correcto {
    bgcolor: #F44336;
    forecolor: #FFFFFF;
}
```

### 4.4 Patrones de paleta de colores

Se recomienda crear un archivo `colors.css` separado del `default.css` para centralizar la paleta de colores. Esto facilita el cambio de tema o de identidad visual.

**Estructura recomendada de `colors.css`:**

```css
/* ============================================
   NOMBRE_PROYECTO - Paleta de Colores
   Tema basado en tonos de AZUL
   ============================================ */

/* ============================================
   COLORES PRIMARIOS
   ============================================ */

/* Color principal de marca - Mas oscuro */
.colorPrimario {
    bgcolor: #0D47A1;
}

/* Botones principales */
.colorPrimarioAccion {
    bgcolor: #1565C0;
}

/* Headers y elementos destacados */
.colorPrimarioMedio {
    bgcolor: #1976D2;
}

/* Elementos secundarios */
.colorPrimarioClaro {
    bgcolor: #1E88E5;
}

/* Fondos de tarjetas activas */
.colorPrimarioSuave {
    bgcolor: #42A5F5;
}

/* Fondos sutiles */
.colorPrimarioPastel {
    bgcolor: #64B5F6;
}

/* Fondos de pantalla */
.colorPrimarioHielo {
    bgcolor: #BBDEFB;
}

/* Fondos muy sutiles */
.colorPrimarioNieve {
    bgcolor: #E3F2FD;
}

/* ============================================
   COLORES DE ESTADO
   ============================================ */

.colorExito {
    bgcolor: #4CAF50;
}

.colorAdvertencia {
    bgcolor: #FFC107;
}

.colorError {
    bgcolor: #F44336;
}

.colorProgreso {
    bgcolor: #FF9800;
}

/* ============================================
   COLORES NEUTROS
   ============================================ */

.colorFondoBlanco {
    bgcolor: #FFFFFF;
}

.colorFondoGrisClaro {
    bgcolor: #F5F5F5;
}

.colorTextoOscuro {
    forecolor: #212121;
}

.colorTextoMedio {
    forecolor: #616161;
}

.colorTextoClaro {
    forecolor: #9E9E9E;
}

.colorTextoBlanco {
    forecolor: #FFFFFF;
}

.colorBorde {
    border-color: #E0E0E0;
}
```

**Ejemplo real de paleta temática por colores (proyecto XOneDelivery - rojo, proyecto UseCars - azul, proyecto SocialNetwork - amarillo):**

Los tres proyectos usan la misma estructura de clases (`.colorPrimario`, `.colorPrimarioAccion`, etc.) pero con colores diferentes, lo que demuestra la utilidad de separar la paleta en un archivo independiente.

---

## 5. Propiedades CSS Disponibles

### 5.1 Dimensiones

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `width` | `Np` / `N%` | Ancho del elemento |
| `height` | `Np` / `N%` | Alto del elemento |
| `size` | Número | Tamaño de la columna en BD (en caracteres). Con `fixed-text="true"` también limita la entrada en UI |
| `fieldsize` | Número | Ancho visual de la caja del campo (ancho de carácter x valor). Usar `width` en proyectos nuevos — tiene prioridad sobre `fieldsize` |

**Ejemplo correcto vs incorrecto:**

```css
/* INCORRECTO */
.error {
    width: 100px;         /* MAL: px */
    height: 56rem;        /* MAL: rem */
    min-width: 200px;     /* MAL: atributo web no soportado */
    max-height: 500px;    /* MAL: atributo web no soportado */
}

/* CORRECTO */
.correcto {
    width: 100%;
    height: 56p;
}
```

**Ejemplo real - Dimensiones de frames (proyecto UseCars):**

```css
.frameHeader {
    width: 100%;
    height: 140p;
}

.frameBody {
    width: 100%;
    height: 100%;
}

.frameFooter {
    width: 100%;
    height: 120p;
}
```

**Ejemplo real - Dimensiones de botones:**

```css
.btnPrimario {
    width: 90%;
    height: 56p;
}

.btnFlotante {
    width: 64p;
    height: 64p;
}
```

### 5.2 Margenes

XOne usa atributos individuales para cada lado del margen. **NO existe** un atributo abreviado `margin`.

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `tmargin` | `Np` / `N%` | Margen superior (top) |
| `bmargin` | `Np` / `N%` | Margen inferior (bottom) |
| `lmargin` | `Np` / `N%` | Margen izquierdo (left) |
| `rmargin` | `Np` / `N%` | Margen derecho (right) |

**Ejemplo correcto vs incorrecto:**

```css
/* INCORRECTO */
.error {
    margin: 10p;              /* MAL: atributo abreviado no existe */
    margin-top: 10p;          /* MAL: nombre CSS web */
    margin-left: 20px;        /* MAL: nombre y unidad incorrectos */
}

/* CORRECTO */
.correcto {
    tmargin: 10p;
    bmargin: 10p;
    lmargin: 20p;
    rmargin: 20p;
}
```

**Ejemplo real - Tarjeta con margenes (proyecto UseCars):**

```css
.tarjeta {
    width: 95%;
    bgcolor: #FFFFFF;
    border-corner-radius: 12;
    tmargin: 10p;
    bmargin: 5p;
    lmargin: 10p;
    rmargin: 10p;
}
```

### 5.3 Padding

Similar a los margenes, el padding usa atributos individuales. **NO existe** un atributo abreviado `padding`.

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `tpadding` | `Np` | Padding superior (top) |
| `bpadding` | `Np` | Padding inferior (bottom) |
| `lpadding` | `Np` | Padding izquierdo (left) |
| `rpadding` | `Np` | Padding derecho (right) |

**Ejemplo correcto vs incorrecto:**

```css
/* INCORRECTO */
.error {
    padding: 10p;             /* MAL: atributo abreviado no garantizado */
    padding-top: 10px;        /* MAL: nombre y unidad CSS web */
}

/* CORRECTO */
.correcto {
    tpadding: 10p;
    bpadding: 10p;
    lpadding: 15p;
    rpadding: 15p;
}
```

**Ejemplo real - Card con padding (proyecto SocialNetwork):**

```css
.framePost {
    width: 100%;
    bgcolor: #FFFFFF;
    tmargin: 2p;
    tpadding: 15p;
    bpadding: 15p;
    lpadding: 15p;
    rpadding: 15p;
}
```

### 5.4 Fuentes

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `fontname` | `NombreFuente.ttf` | Fuente personalizada (archivo .ttf en carpeta `fonts/`) |
| `fontsize` | Número (1-50) | Tamaño de fuente (sin unidad) |
| `fontbold` | `true`/`false` | Texto en negrita |
| `fontitalic` | `true`/`false` | Texto en cursiva |
| `text-fontsize` | Número | Tamaño de fuente del texto editable |
| `labelfont-size` / `labelfontsize` | Número | Tamaño de fuente de la etiqueta |
| `textfont-size` / `textfontsize` / `text-font-size` | Número | Tamaño de fuente del texto editable (alternativa) |
| `labelfont-bold` | `true`/`false` | Etiqueta en negrita |
| `textfont-bold` | `true`/`false` | Texto editable en negrita |
| `textfont-italic` | `true`/`false` | Texto editable en cursiva |
| `labelshadow` | `true`/`false` | Sombra en etiqueta |

**Ejemplo correcto vs incorrecto:**

```css
/* INCORRECTO */
.error {
    font-size: 14px;          /* MAL: nombre y unidad CSS web */
    font-family: 'Roboto';    /* MAL: nombre CSS web */
    font-weight: bold;        /* MAL: nombre CSS web */
    font-style: italic;       /* MAL: nombre CSS web */
}

/* CORRECTO */
.correcto {
    fontsize: 14;
    fontname: Roboto-Regular.ttf;
    fontbold: true;
    fontitalic: true;
}
```

**Ejemplo real - Diferentes estilos de fuente (proyecto UseCars):**

```css
/* Titulo grande */
.textoTituloGrande {
    fontsize: 28;
    fontname: Roboto-Bold.ttf;
    forecolor: #FFFFFF;
    text-align: center;
}

/* Texto normal */
.textoNormal {
    fontsize: 14;
    forecolor: #212121;
}

/* Texto secundario */
.textoSecundario {
    fontsize: 14;
    forecolor: #9E9E9E;
}

/* Texto pequeno */
.textoPequeno {
    fontsize: 12;
    forecolor: #9E9E9E;
}
```

> **Referencia cruzada:** Las fuentes personalizadas deben colocarse en la carpeta `fonts/` del proyecto. Consultar el tópico [01 - Fundamentos](./01-xone-fundamentals.md).

### 5.5 Texto

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `forecolor` | `#RRGGBB` / `#AARRGGBB` | Color del texto principal y etiqueta |
| `forecolor-disabled` | `#RRGGBB` | Color de la fuente cuando deshabilitado |
| `text-forecolor` | `#RRGGBB` | Color del texto editable |
| `text-forecolor-disabled` | `#RRGGBB` | Color del texto editable cuando deshabilitado |
| `text-align` | `left`/`center`/`right` | Alineacion horizontal del texto |
| `align` | Combinacion con `\|` | Alineacion combinada del contenedor |
| `lines` | Número | Número de lineas visibles |
| `fixed-lines` | `true`/`false` | Altura fija basada en lineas |
| `locked` | `true`/`false` | Campo de solo lectura |
| `locking` | `true`/`false` | Comportamiento de bloqueo |
| `mask` | `"formato"` | Mascara de formato |

**Combinaciones de `align`:**

```css
.centradoTotal {
    align: center;              /* Centro horizontal y vertical */
}

.arribaIzquierda {
    align: top|left;            /* Esquina superior izquierda */
}

.abajoCentro {
    align: bottom|center;       /* Abajo centrado horizontalmente */
}

.derechaCentro {
    align: right|center;        /* Derecha centrado verticalmente */
}
```

**Ejemplo real - Diferentes alineaciones:**

```css
/* Header centrado (proyecto UseCars) */
.frameHeader {
    width: 100%;
    height: 140p;
    bgcolor: #0D47A1;
    align: center;
}

/* Header alineado a izquierda (proyecto MiMensajeria) */
.frameHeader {
    width: 100%;
    height: 56p;
    bgcolor: #1565C0;
    align: left;
}
```

### 5.6 Fondo

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `bgcolor` | `#RRGGBB` / `#AARRGGBB` | Color de fondo del elemento |
| `bgcolor-disabled` | `#RRGGBB` | Color de fondo cuando deshabilitado |
| `bgcolor-focus` | `#RRGGBB` | Color de fondo al recibir foco |
| `text-bgcolor` | `#RRGGBB` | Color de fondo del texto editable |
| `text-bgcolor-focus` | `#RRGGBB` | Color de fondo del texto al recibir foco |
| `text-bgcolor-disabled` | `#RRGGBB` | Color de fondo del texto cuando deshabilitado |
| `imgbk` | `nombre.png` / `nombre.svg` | Imagen de fondo del elemento. Acepta PNG, JPG y SVG (el SVG se renderiza nativo, no requiere WebView ni conversion) |

**Ejemplo correcto vs incorrecto:**

```css
/* INCORRECTO */
.error {
    background-color: #FFF;        /* MAL: nombre CSS web */
    background: url(fondo.png);    /* MAL: sintaxis CSS web */
    background-image: linear-gradient(...); /* MAL: gradientes no soportados */
}

/* CORRECTO */
.correcto {
    bgcolor: #FFFFFF;
    imgbk: fondo.png;
}
```

**Ejemplo real - Fondos con transparencia (proyecto UseCars):**

```css
/* Header transparente para mapas */
.frameHeaderTransparente {
    width: 100%;
    height: 100p;
    bgcolor: #00FFFFFF;  /* Completamente transparente */
    align: center;
}
```

### 5.7 Bordes

XOne distingue entre **bordes de texto** (área editable del campo) y **bordes de contenedor** (frame o prop completo).

#### Bordes de texto

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `text-border` | `true`/`false` | Mostrar borde alrededor del texto |
| `text-border-left` | `true`/`false` | Borde izquierdo del texto |
| `text-border-right` | `true`/`false` | Borde derecho del texto |
| `text-border-top` | `true`/`false` | Borde superior del texto |
| `text-border-bottom` | `true`/`false` | Borde inferior del texto |
| `text-border-color` | `#RRGGBB` | Color del borde de texto |
| `text-border-width` | `Np` | Grosor del borde de texto |

#### Bordes de contenedor

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `border` | `true`/`false` | Borde general del contenedor |
| `border-width` | Número (sin unidad) | Grosor del borde |
| `border-color` | `#RRGGBB` | Color del borde |
| `border-corner-radius` | Número (sin unidad) | Radio de todas las esquinas redondeadas |
| `border-corner-radius-top-left` | Número | Radio esquina superior izquierda |
| `border-corner-radius-top-right` | Número | Radio esquina superior derecha |
| `border-corner-radius-bottom-left` | Número | Radio esquina inferior izquierda |
| `border-corner-radius-bottom-right` | Número | Radio esquina inferior derecha |
| `border-top` | `true`/`false` | Borde superior |
| `border-top-color` | `#RRGGBB` | Color borde superior |
| `border-bottom` | `true`/`false` | Borde inferior |
| `border-bottom-color` | `#RRGGBB` | Color borde inferior |
| `framebox` | `true`/`false` | Estilo de caja del frame (muestra un borde/contenedor alrededor del frame) |
| `grid-framebox` | `true`/`false` | Borde de frame en modo grid/lista |
| `grid-text-border` | `true`/`false` | Borde de texto en modo grid/lista |

**Patron Material Design - Solo borde inferior:**

Este es el patron más común para campos de texto en aplicaciones Material Design. Se usa extensivamente en todos los proyectos de ejemplo:

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

**Patron - Panel con esquinas superiores redondeadas:**

Usado para paneles inferiores deslizables que tapan parte del contenido:

```css
.panelInferior {
    width: 100%;
    bgcolor: #FFFFFF;
    border-corner-radius-top-left: 24;
    border-corner-radius-top-right: 24;
}
```

**Ejemplo correcto vs incorrecto:**

```css
/* INCORRECTO */
.error {
    border-radius: 8px;           /* MAL: nombre y unidad CSS web */
    border: 1px solid #ccc;       /* MAL: sintaxis abreviada CSS web */
    box-shadow: 0 2px 4px #000;   /* MAL: box-shadow no soportado */
}

/* CORRECTO */
.correcto {
    border-corner-radius: 8;
    border: true;
    border-width: 1;
    border-color: #CCCCCC;
}
```

### 5.8 Sombras y Elevacion

XOne no soporta `box-shadow` ni `text-shadow` de CSS web. Sin embargo, algunos atributos de elevacion están disponibles:

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `elevation` | Número | Elevacion del elemento (sombra en Android) |
| `shadow-color` | `#RRGGBB` | Color de la sombra |

> **NOTA:** La elevacion funciona principalmente en Android. En iOS el efecto puede variar. No todos los proyectos la usan; la alternativa más común es usar bordes sutiles (`border: true; border-color: #E0E0E0;`) para dar sensacion de profundidad.

### 5.9 Visibilidad

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `visible` | Número (bitmask 0-7) | Mascara de visibilidad |
| `labelbox` | `true`/`false` | Mostrar caja contenedora de etiqueta |

**Sistema de visibilidad por bitmask:**

El atributo `visible` usa un sistema de mascara de bits que controla en que modos de visualizacion aparece el campo:

| Valor | Edición | Lista | Contents | Descripción |
|:-----:|:-------:|:-----:|:--------:|-------------|
| `0` | Oculto | Oculto | Oculto | Campo completamente oculto |
| `1` | Visible | Oculto | Oculto | Solo en modo edición |
| `2` | Oculto | Visible | Oculto | Solo en modo lista |
| `3` | Visible | Visible | Oculto | En edición y lista |
| `4` | Oculto | Oculto | Visible | Solo en contents (listas embebidas) |
| `5` | Visible | Oculto | Visible | En edición y contents |
| `6` | Oculto | Visible | Visible | En lista y contents |
| `7` | Visible | Visible | Visible | Visible en todos los modos |

> **Referencia cruzada:** Para comprender los modos de visualizacion (edición, lista, contents), consultar el tópico [02 - Estructura XML](./02-xml-ui-complete-guide.md).

### 5.10 Otros

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `newline` | `true`/`false` | Forzar nueva linea (salto de linea) |
| `scroll` | `true`/`false` | Habilitar scroll en el contenedor |
| `fixed` | `true`/`false` | Elemento fijo (no se desplaza con scroll) |
| `orientation` | `top`/`bottom` | Posición del elemento fijo |
| `floating` | `true`/`false` | Frame flotante |
| `top` | `Np` | Posición vertical de frame flotante |
| `left` | `Np` | Posición horizontal de frame flotante |
| `ripple-effect` | `true`/`false` | Efecto ripple Material Design al pulsar (solo Android) |
| `elevation` | Número | Elevacion/sombra Material Design (principalmente Android) |
| `imgbk` | `nombre.png` | Imagen de fondo del elemento |
| `undo-button` | `true`/`false` | Mostrar botón deshacer |
| `apply-css` | `true`/`false` | Aplicar estilos CSS al componente |
| `locked` | `true`/`false` | Campo de solo lectura |
| `zoom-controls` | `true`/`false` | Controles de zoom en webviews |
| `img` | `nombre.png` | Imagen del botón/control |
| `imgsel` | `nombre_sel.png` | Imagen al seleccionar/pulsar |
| `img-width` | Número | Ancho de iconos del sistema |
| `img-height` | Número | Alto de iconos del sistema |

### 5.11 Propiedades Material Design y Componentes Especiales

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `ripple-effect` | `true`/`false` | Efecto de onda al tocar (Material Design, solo Android) |
| `elevation` | Número (0-24) | Nivel de elevacion que genera sombra bajo el elemento |
| `shadow-color` | `#RRGGBB` | Color de la sombra generada por elevation |
| `track-color` | `#RRGGBB` | Color de la pista para controles tipo slider o switch |
| `thumb-color` | `#RRGGBB` | Color del pulgar/indicador para controles tipo slider o switch |
| `check-color-checked` | `#RRGGBB` | Color del checkbox cuando esta marcado/activo |

**Ejemplo - Botón con efecto ripple y elevacion:**

```css
.btnMaterial {
    width: 90%;
    height: 56p;
    bgcolor: #1565C0;
    forecolor: #FFFFFF;
    border-corner-radius: 28;
    ripple-effect: true;
    elevation: 4;
}
```

**Ejemplo - Switch/Slider personalizado:**

```css
.switchPersonalizado {
    track-color: #BBDEFB;
    thumb-color: #1565C0;
    check-color-checked: #4CAF50;
}
```

> **NOTA:** La propiedad `elevation` funciona principalmente en Android, donde genera una sombra real bajo el elemento. En iOS, el efecto puede variar o no ser visible. Como alternativa multiplataforma, se pueden usar bordes sutiles (`border: true; border-color: #E0E0E0;`) para dar sensacion de profundidad.

**Ejemplo - Footer fijo en la parte inferior (proyecto SocialNetwork):**

```css
.frameFooter {
    width: 100%;
    height: 120p;
    bgcolor: #FFFFFF;
    align: center;
    fixed: true;
    orientation: bottom;
}
```

**Ejemplo - FAB flotante (proyecto SocialNetwork):**

```css
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

## 6. Sistema de Herencia `extends:`

### 6.1 Sintaxis: extends:.claseBase

El atributo `extends` permite que una clase CSS herede todos los atributos de otra clase base. La clase referenciada debe incluir el prefijo de punto (`.`).

```css
.claseHija {
    extends: .claseBase;
    /* Solo sobreescribir lo que cambia */
}
```

### 6.2 Herencia simple

El caso más común: una clase hereda de otra y sobreescribe algunos atributos.

```css
/* Clase base */
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

/* Clase hija - Solo cambia el color de fondo */
.btnPeligro {
    extends: .btnPrimario;
    bgcolor: #F44336;
}
```

La clase `.btnPeligro` tendra TODOS los atributos de `.btnPrimario` (width, height, forecolor, border-corner-radius, text-align, fontsize, fontname) pero con `bgcolor: #F44336` en lugar de `#1565C0`.

### 6.3 Herencia multiple (en cadena)

Se puede crear una cadena de herencia donde A extiende B, que a su vez extiende C.

```css
/* Nivel 1: Base generica */
.badgeEstado {
    height: 28p;
    fontsize: 12;
    fontname: Roboto-Bold.ttf;
    forecolor: #FFFFFF;
    text-align: center;
    border-corner-radius: 14;
    lmargin: 10p;
    rmargin: 10p;
}

/* Nivel 2: Variantes que heredan de la base */
.badgePendiente {
    extends: .badgeEstado;
    bgcolor: #FFC107;
    forecolor: #212121;
}

.badgeAsignado {
    extends: .badgeEstado;
    bgcolor: #2196F3;
}

.badgeEntregado {
    extends: .badgeEstado;
    bgcolor: #4CAF50;
}

.badgeCancelado {
    extends: .badgeEstado;
    bgcolor: #9E9E9E;
}
```

### 6.4 Sobreescritura de propiedades

Los atributos definidos en la clase hija siempre **sobreescriben** los heredados de la clase base:

```css
.botonBase {
    width: 90%;
    height: 56p;
    bgcolor: #0066CC;
    forecolor: #FFFFFF;
}

.botonSecundario {
    extends: .botonBase;
    bgcolor: #FFFFFF;         /* Sobreescribe bgcolor */
    forecolor: #0066CC;       /* Sobreescribe forecolor */
    border: true;             /* Anade nuevo atributo */
    border-color: #0066CC;    /* Anade nuevo atributo */
}
```

Resultado de `.botonSecundario`:
- `width: 90%` (heredado)
- `height: 56p` (heredado)
- `bgcolor: #FFFFFF` (sobreescrito)
- `forecolor: #0066CC` (sobreescrito)
- `border: true` (nuevo)
- `border-color: #0066CC` (nuevo)

### 6.5 Herencia desde selectores globales y de tipo

Es posible usar `extends` para heredar no solo de clases (`.nombreClase`) sino también de selectores globales (`prop`, `coll`) y selectores de tipo (`prop:T`, `prop:B`, etc.).

**Extends desde `prop` (selector global):**

```css
.classprop {
    extends: prop;
    lmargin: 2%;
    tmargin: 0p;
    text-border: true;
    text-border-width: 1p;
}
```

La clase `.classprop` hereda todos los atributos definidos en el selector global `prop` (fontname, fontsize, forecolor, etc.) y anade o sobreescribe los indicados.

**Extends desde `prop:B` (selector de tipo):**

```css
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
```

La clase `.btnButton` hereda los estilos base definidos para todos los botones (`prop:B`) y los extiende con posicionamiento y tamaño especificos.

**Extends desde `prop:T` (crear un input personalizado basado en campos de texto):**

```css
.myInputCustom {
    extends: prop:T;
    text-border: true;
    text-border-bottom: true;
    text-border-left: false;
    text-border-right: false;
    text-border-top: false;
    text-border-color: #1565C0;
    fontsize: 16;
}
```

### 6.6 Herencia encadenada (multiples niveles)

Se puede crear una cadena de herencia de multiples niveles donde A extiende B, y B extiende C. XOne resuelve toda la cadena de herencia, de modo que A recibe los atributos de C + B + los suyos propios.

```css
/* Nivel 1: Hereda del selector global prop */
.classprop {
    extends: prop;
    lmargin: 2%;
    text-border: true;
}

/* Nivel 2: Hereda de .classprop (que a su vez hereda de prop) */
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

/* Nivel 3: Hereda de .classtl */
.classtlResaltado {
    extends: .classtl;
    bgcolor: #E3F2FD;
    border-color: #1565C0;
}
```

En este ejemplo, `.classtlResaltado` recibe:
- De `prop`: fontname, fontsize, forecolor, etc.
- De `.classprop`: lmargin, text-border
- De `.classtl`: labelbox, width, align, border, elevation
- Propios: bgcolor y border-color sobreescritos

> **IMPORTANTE:** No hay limite técnico para la cantidad de niveles de herencia encadenada, pero se recomienda no superar 3-4 niveles para mantener la legibilidad y facilidad de depuracion. Además, **no se permite la herencia circular** (A extends B extends A), ya que provocaria un bucle infinito.

### 6.7 Patrones de herencia recomendados

**Patron 1: Variantes de botón (el más común):**

```css
/* Base */
.btnBase {
    width: 90%;
    height: 56p;
    border-corner-radius: 28;
    text-align: center;
    fontsize: 16;
    fontname: Roboto-Bold.ttf;
}

/* Variantes */
.btnPrimario {
    extends: .btnBase;
    bgcolor: #1565C0;
    forecolor: #FFFFFF;
}

.btnSecundario {
    extends: .btnBase;
    bgcolor: #FFFFFF;
    forecolor: #1565C0;
    border: true;
    border-color: #1565C0;
}

.btnPeligro {
    extends: .btnBase;
    bgcolor: #F44336;
    forecolor: #FFFFFF;
}

.btnExito {
    extends: .btnBase;
    bgcolor: #4CAF50;
    forecolor: #FFFFFF;
}
```

**Patron 2: Variantes de input:**

```css
.inputBase {
    width: 95%;
    height: 56p;
    text-border: true;
    text-border-bottom: true;
    text-border-left: false;
    text-border-right: false;
    text-border-top: false;
    text-border-color: #BDBDBD;
    fontsize: 14;
}

.inputEnfocado {
    extends: .inputBase;
    text-border-color: #1565C0;
}

.inputError {
    extends: .inputBase;
    text-border-color: #F44336;
}
```

**Patron 3: Variantes de texto:**

```css
.textoBase {
    fontname: Roboto-Regular.ttf;
    labelwidth: 0;
}

.textoTitulo {
    extends: .textoBase;
    fontsize: 20;
    fontname: Roboto-Bold.ttf;
    forecolor: #212121;
}

.textoSubtitulo {
    extends: .textoBase;
    fontsize: 16;
    forecolor: #616161;
}

.textoSecundario {
    extends: .textoBase;
    fontsize: 14;
    forecolor: #9E9E9E;
}
```

**Patron 4: Herencia desde selector global con `extends: prop`:**

```css
.xnCheckbox {
    extends: prop;
    apply-css: true;
    labelwidth: 1;
    img-width: 50p;
    text-bgcolor: #00000000;
}
```

### 6.8 Cuando usar extends vs clases multiples

| Situación | Usar `extends` | Usar multiples clases |
|-----------|:--------------:|:---------------------:|
| Variantes de color de un mismo componente | SI | No |
| Combinar layout con color | No | SI |
| Badges de estado (misma forma, distinto color) | SI | No |
| Frame con animación | No | SI |
| Botones con diferente acción (mismo estilo base) | SI | No |

**Ejemplo - Multiples clases en XML:**

```xml
<frame name="frmEncabezado" class="frameHeader animSlideRight">
```

**Ejemplo - Extends en CSS:**

```css
.btnDanger {
    extends: .btnPrimary;
    bgcolor: #F44336;
}
```

---

## 7. Selectores Condicionales y Dinámicos

### 7.1 Estilos por estado/valor de campo

XOne permite aplicar clases CSS dinámicamente desde JavaScript usando la API `self` para cambiar el aspecto de elementos en función del estado de la aplicación. Aunque no existe un selector condicional CSS puro como `:hover` o `[data-attr]`, los estilos pueden cambiarse en tiempo de ejecución.

**Desde JavaScript, cambiar la clase de un campo:**

```javascript
// En el evento onchange de un campo ESTADO
var estado = self.ESTADO;
var propEstado = ui.getView("badgeEstado");

if (estado == "PENDIENTE") {
    propEstado.className = "badgePendiente";
} else if (estado == "EN_RUTA") {
    propEstado.className = "badgeEnRuta";
} else if (estado == "ENTREGADO") {
    propEstado.className = "badgeEntregado";
}
```

### 7.2 Ejemplo práctico - Colores por estado

En los proyectos reales se definen clases CSS para cada estado posible y se asignan desde JavaScript:

**CSS (proyecto XOneDelivery):**

```css
/* Badge base */
.badgeEstado {
    height: 28p;
    fontsize: 12;
    fontname: Roboto-Bold.ttf;
    forecolor: #FFFFFF;
    text-align: center;
    border-corner-radius: 14;
    lmargin: 10p;
    rmargin: 10p;
}

.badgePendiente {
    extends: .badgeEstado;
    bgcolor: #FFC107;
    forecolor: #212121;
}

.badgeAsignado {
    extends: .badgeEstado;
    bgcolor: #2196F3;
}

.badgeEnRuta {
    extends: .badgeEstado;
    bgcolor: #FF9800;
}

.badgeEnDestino {
    extends: .badgeEstado;
    bgcolor: #9C27B0;
}

.badgeEntregado {
    extends: .badgeEstado;
    bgcolor: #4CAF50;
}

.badgeNoEntregado {
    extends: .badgeEstado;
    bgcolor: #F44336;
}

.badgeCancelado {
    extends: .badgeEstado;
    bgcolor: #9E9E9E;
}
```

**CSS para prioridades (proyecto GestionTareas):**

```css
.prioridadBaja {
    forecolor: #4CAF50;
}

.prioridadMedia {
    forecolor: #FF9800;
}

.prioridadAlta {
    forecolor: #F44336;
}

.prioridadUrgente {
    forecolor: #D32F2F;
    fontbold: true;
}
```

> **Referencia cruzada:** Para ver como manipular clases CSS desde JavaScript, consultar el tópico [03 - API JavaScript](./03-javascript-api-guide.md).

---

## 8. Referencias Dinámicas a Campos en CSS

### 8.1 Sintaxis `##FLD_NOMBRE_CAMPO##`

XOne permite referenciar valores de propiedades del objeto actual directamente en el CSS mediante la sintaxis `##FLD_NOMBRE_CAMPO##`. Esto permite que los estilos se calculen dinámicamente en función de los datos del registro actual.

**Sintaxis:**

```
##FLD_NOMBRE_DEL_CAMPO##
```

Donde `NOMBRE_DEL_CAMPO` es el nombre de una propiedad (campo) definida en la coleccion. El valor de esa propiedad en el registro actual reemplazara el token en tiempo de ejecución.

### 8.2 Uso en CSS

```css
.frmsuperior {
    width: 100%;
    height: 120p;
    bgcolor: ##FLD_MAP_COLORACTIVO##;
    align: left|center;
}
```

En este ejemplo, el color de fondo del frame se obtiene dinámicamente del valor del campo `MAP_COLORACTIVO` del objeto actual. Si el campo contiene `#1565C0`, el frame tendra ese color de fondo.

### 8.3 Uso en atributos inline XML

La misma sintaxis funciona en los atributos inline de los nodos XML:

```xml
<prop name="MAP_LABEL" type="L"
      bgcolor="##FLD_MAP_COLOR1##"
      forecolor="##FLD_MAP_COLOR2##" />
```

Esto obtiene los valores dinámicos de las propiedades `MAP_COLOR1` y `MAP_COLOR2` del objeto actual, permitiendo cambiar colores en tiempo de ejecución sin necesidad de JavaScript.

### 8.4 Casos de uso

Las referencias dinámicas son útiles para:

- **Colores por estado:** Un campo `COLOR_ESTADO` que cambia según el estado del registro
- **Temas por usuario/empresa:** Un campo `COLOR_EMPRESA` que define la paleta de colores corporativa
- **Indicadores visuales:** Cambiar el fondo de un frame según un valor calculado
- **Personalizacion:** Permitir que el usuario elija colores que se aplican directamente

**Ejemplo completo - Frame con color dinámico por estado:**

```css
/* El color del frame depende del campo MAP_COLOR del registro */
.frameEstadoDinamico {
    width: 100%;
    height: 80p;
    bgcolor: ##FLD_MAP_COLOR##;
    forecolor: #FFFFFF;
    align: center;
}
```

```xml
<!-- En la coleccion, MAP_COLOR contiene valores como #4CAF50, #F44336, etc. -->
<prop name="MAP_COLOR" type="T" visible="0" />
<frame name="frmEstado" class="frameEstadoDinamico">
    <prop name="ESTADO" type="L" forecolor="#FFFFFF" />
</frame>
```

> **NOTA:** Los valores de los campos referenciados deben contener valores CSS validos (colores en formato `#RRGGBB`, nombres de imágenes, etc.). Si el campo esta vacio o contiene un valor no valido, el comportamiento puede ser inesperado.

---

## 9. Cascada de Condiciones de Dispositivo

### 9.1 Orden de cascada

XOne aplica los archivos CSS en un orden especifico de cascada, donde los archivos más especificos sobrescriben a los menos especificos. Este es el orden de prioridad de menor a mayor:

```
1. default.css                        (Base - MENOR prioridad)
2. default.ios.css / default.android.css  (Plataforma)
3. default.portrait.css / default.landscape.css  (Orientacion)
4. default.night.css                  (Modo oscuro/tema)
5. default.ios.portrait.css           (Condiciones combinadas)
6. Atributos inline en XML           (MAYOR prioridad)
```

### 9.2 Archivos por convencion de nombre

XOne reconoce automáticamente los archivos CSS según su nombre. No es necesario declararlos explicitamente en `app.xml` (excepto el archivo base `default.css`):

| Archivo | Condición | Prioridad |
|---------|-----------|:---------:|
| `default.css` | Siempre se carga (base) | 1 (menor) |
| `default.android.css` | Solo en dispositivos Android | 2 |
| `default.ios.css` | Solo en dispositivos iOS | 2 |
| `default.portrait.css` | Solo en orientación vertical | 3 |
| `default.landscape.css` | Solo en orientación horizontal | 3 |
| `default.night.css` | Solo en modo oscuro/nocturno | 4 |
| `default.day.css` | Solo en modo claro/diurno | 4 |
| `default.ios.portrait.css` | iOS + orientación vertical | 5 |
| `default.android.landscape.css` | Android + orientación horizontal | 5 |

### 9.3 Estilos condicionales explicitos en app.xml

Además de la convencion de nombres, se pueden declarar archivos CSS condicionales de forma explicita usando el atributo `conditions` en el nodo `<style>`:

```xml
<app ...>
    <style url="default.css" strict-mode="true" />
    <style url="default-ios.css" conditions="ios" strict-mode="true" />
    <style url="default_hor.css" conditions="phone:horizontal" strict-mode="true" />
    <style url="tablet_ver.css" conditions="tablet:vertical" />
    <style url="tablet_hor.css" conditions="tablet:horizontal" />
</app>
```

**Valores del atributo `conditions`:**

| Condición | Descripción |
|-----------|-------------|
| `ios` | Solo en iOS |
| `android` | Solo en Android |
| `phone:horizontal` | Telefono en orientación horizontal |
| `phone:vertical` | Telefono en orientación vertical |
| `tablet:horizontal` | Tablet en orientación horizontal |
| `tablet:vertical` | Tablet en orientación vertical |

### 9.4 Regla de sobrescritura

Las condiciones más especificas **siempre ganan** sobre las menos especificas. Si un atributo se define en multiples archivos CSS, el valor del archivo más especifico es el que se aplica:

```css
/* default.css */
.frameHeader {
    bgcolor: #1565C0;       /* Base: azul */
    height: 140p;
}

/* default.ios.css */
.frameHeader {
    bgcolor: #007AFF;       /* iOS: azul de Apple */
    height: 120p;            /* iOS: header mas bajo */
}

/* default.night.css */
.frameHeader {
    bgcolor: #1E1E1E;       /* Modo oscuro: gris oscuro */
}
```

En este ejemplo:
- En **Android modo claro**: `bgcolor: #1565C0`, `height: 140p` (base)
- En **iOS modo claro**: `bgcolor: #007AFF`, `height: 120p` (plataforma sobrescribe)
- En **Android modo oscuro**: `bgcolor: #1E1E1E`, `height: 140p` (tema sobrescribe color, pero no altura)
- En **iOS modo oscuro**: `bgcolor: #1E1E1E`, `height: 120p` (tema sobrescribe color del de plataforma)

### 9.5 strict-mode

El atributo `strict-mode` en el nodo `<style>` permite validar el CSS durante la carga:

```xml
<style url="default.css" strict-mode="true" />
```

Cuando `strict-mode="true"`, XOne valida errores en el CSS y reporta propiedades no reconocidas o valores invalidos. Es recomendable activarlo durante el desarrollo para detectar errores de sintaxis.

> **IMPORTANTE:** Solo es necesario declarar `default.css` en `app.xml`. Los archivos variantes (`default.ios.css`, `default.night.css`, etc.) se cargan automáticamente por convencion de nombre. Sin embargo, para archivos con nombres personalizados, es necesario declararlos explicitamente con el atributo `conditions`.

---

## 10. Animaciones

### 10.1 Atributos de animación

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `animation-in` | Token de animación | Animación de entrada de la pantalla/frame |
| `animation-out` | Token de animación | Animación de salida de la pantalla/frame |
| `animation-in-delay` | Milisegundos (número) | Retardo de la animación de entrada |
| `animation-out-delay` | Milisegundos (número) | Retardo de la animación de salida |

### 10.2 Tipos de animación disponibles

XOne proporciona tokens predefinidos para animaciones. Estos tokens se encierran entre dobles almohadillas (`##`):

| Token | Descripción | Uso típico |
|-------|-------------|------------|
| `##RIGHT_IN##` | Entra desde la derecha | Navegación hacia adelante |
| `##LEFT_IN##` | Entra desde la izquierda | Navegación hacia atrás |
| `##RIGHT_OUT##` | Sale hacia la derecha | Salida al volver atrás |
| `##LEFT_OUT##` | Sale hacia la izquierda | Salida al avanzar |
| `##PUSH_IN##` | Entra desde abajo (push up) | Modales, paneles inferiores |
| `##PUSH_OUT##` | Sale hacia arriba (push up) | Cerrar modales |
| `##PUSH_DOWN_IN##` | Entra desde arriba | Notificaciones, dropdowns |
| `##PUSH_DOWN_OUT##` | Sale hacia abajo | Cerrar notificaciones |
| `##ALPHA_IN##` | Aparece con fade in | Transiciones suaves |
| `##ALPHA_OUT##` | Desaparece con fade out | Transiciones suaves |
| `##ZOOM_IN##` | Zoom de entrada (crece) | Detalle, ampliacion |
| `##ZOOM_OUT##` | Zoom de salida (encoge) | Cerrar detalle |
| `##ROTATE3D_IN##` | Rotación 3D de entrada | Efectos especiales |
| `##ROTATE3D_OUT##` | Rotación 3D de salida | Efectos especiales |

### 10.3 Cuando usar animaciones

- **Navegación entre pantallas:** `##RIGHT_IN##` / `##LEFT_OUT##` para avanzar, `##LEFT_IN##` / `##RIGHT_OUT##` para retroceder
- **Modales o paneles:** `##PUSH_IN##` / `##PUSH_OUT##` o `##PUSH_DOWN_IN##` / `##PUSH_DOWN_OUT##`
- **Transiciones suaves:** `##ALPHA_IN##` / `##ALPHA_OUT##`
- **Evitar en elementos repetitivos:** No aplicar animaciones a items de lista o elementos que se repintan frecuentemente

### 10.4 Ejemplo práctico

**Clases de animación reutilizables (proyecto SocialNetwork):**

```css
/* Fade in suave */
.animFadeIn {
    animation-in: ##ALPHA_IN##;
    animation-in-delay: 300;
}

/* Slide desde abajo */
.animSlideUp {
    animation-in: ##PUSH_IN##;
    animation-in-delay: 200;
}

/* Slide lateral (navegacion) */
.animSlideRight {
    animation-in: ##RIGHT_IN##;
    animation-in-delay: 200;
    animation-out: ##LEFT_OUT##;
    animation-out-delay: 200;
}
```

**Clases de animación con diferentes efectos (de la knowledgebase):**

```css
.FrameAnimateFromRight {
    animation-in-delay: 500;
    animation-out-delay: 500;
    animation-in: ##RIGHT_IN##;
    animation-out: ##LEFT_OUT##;
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

**Uso en el selector `coll` para animar toda la coleccion:**

```css
coll {
    animation-in: "##RIGHT_IN##";
}
```

---

## 11. Gráficos (Charts)

### 11.1 Tipos de gráfico disponibles

Los gráficos se definen mediante el atributo `type="Z"` en la propiedad XML y se configuran con atributos CSS. Los tipos de gráfico se especifican en el atributo XML `viewmode` o como viewmode de la coleccion:

- `barchart` - Gráfico de barras
- `3dbarchart` - Gráfico de barras 3D
- `slidingbarchart` - Gráfico de barras deslizable
- `piechart` - Gráfico circular (tarta)
- `piechart2` - Variante de gráfico circular
- `linechart` - Gráfico de lineas
- `areachart` - Gráfico de área
- `timeserieschart` - Gráfico de series temporales

**Atributos XML para datos del gráfico:**

| Atributo XML | Descripción |
|-------------|-------------|
| `chart-category="true"` | Define el campo como categoría (eje X) |
| `chart-value="true"` | Define el campo como valor (eje Y) |
| `chart-color="true"` | Define el campo como color de la serie |

### 11.2 Atributos de gráficos

| Atributo CSS | Valores | Descripción |
|--------------|---------|-------------|
| `chart-serie-color` | `#COLOR1,#COLOR2,...` | Colores de las series |
| `chart-color-template` | `#COLOR1,#COLOR2,...` | Plantilla de colores |
| `chart-lock-x-axis` | `true`/`false` | Bloquear eje X (sin zoom/pan) |
| `chart-lock-y-axis` | `true`/`false` | Bloquear eje Y (sin zoom/pan) |
| `chart-show-series-item-labels` | `true`/`false` | Mostrar etiquetas de valores |
| `chart-series-item-label-format` | `##VALUE##` | Formato de las etiquetas |
| `chart-category-label-rotation` | `up_45`/`up_90`/`down_45`/`down_90` | Rotación de etiquetas de categoría |
| `chart-category-max-value` | Número | Valor máximo de la categoría |
| `chart-category-step-size` | Número | Tamaño del paso entre valores |
| `chart-max-visible-series` | Número | Máximo de series visibles simultaneamente |
| `show-legend` | `true`/`false` | Mostrar leyenda del gráfico |
| `fontsize-legend` | Número | Tamaño de fuente de la leyenda |

### 11.3 Ejemplo completo

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

**Uso en XML:**

```xml
<prop name="MAP_BARCHART" type="Z" class="clsCharts" viewmode="barchart" visible="1" />
```

**Ejemplo XML con campos de datos para el gráfico:**

```xml
<!-- En la coleccion de datos del gráfico -->
<prop name="CATEGORIA" chart-category="true" />
<prop name="VALOR" chart-value="true" />
<prop name="COLOR" chart-color="true" />
```

> **Referencia cruzada:** Para la definición XML completa de gráficos, consultar el tópico [02 - Estructura XML](./02-xml-ui-complete-guide.md).

---

## 12. Calendario

### 12.1 Atributos de calendario

Los calendarios se definen con `type="Z"` y `viewmode="calendarview"` y se configuran con atributos CSS especificos para personalizar la apariencia de días, semanas y selección:

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `weekdays-bgcolor` | `#RRGGBB` | Color de fondo de la fila de días de semana |
| `weekdays-forecolor` | `#RRGGBB` | Color de texto de los días de semana |
| `weekdays-fontsize` | Número | Tamaño de fuente de los días de semana |
| `weekdays-longname` | `true`/`false` | Nombres largos (Lunes) vs cortos (Lun) |
| `weekdays-align` | `top`/`center`/`bottom` + `left`/`right` | Alineacion de los días |
| `page-swipe` | `true`/`false` | Permitir swipe entre meses |
| `cell-bgcolor` | `#RRGGBB`/`#AARRGGBB` | Color de fondo de las celdas de día |
| `cell-forecolor` | `#RRGGBB` | Color de texto de los días |
| `cell-border-width` | Número | Grosor del borde de celda |
| `cell-align` | `left`/`center`/`right` | Alineacion del contenido de celda |
| `cell-selected-bgcolor` | `#RRGGBB`/`#AARRGGBB` | Fondo del día seleccionado |
| `cell-selected-forecolor` | `#RRGGBB` | Texto del día seleccionado |
| `cell-selected-border-color` | `#RRGGBB` | Borde del día seleccionado |
| `cell-other-month-bgcolor` | `#RRGGBB`/`#AARRGGBB` | Fondo de los días de otros meses |

### 12.2 Ejemplo completo

```css
.z_calendario {
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

**Nota:** Los colores con alpha como `#68008CFF` y `#39767676` usan el formato ARGB. Por ejemplo, `#39767676` es un gris con 22% de opacidad (0x39 = 57 de 255 = ~22%).

---

## 13. Mapa

### 13.1 Atributos de mapa

Los mapas se configuran estableciendo `viewmode: mapview` en la coleccion o en una clase aplicada a la coleccion. XOne soporta tanto Google Maps (`mapview`) como OpenStreetMap (`openstreetmap`):

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `viewmode` | `mapview` / `openstreetmap` | Activar modo mapa en la coleccion |
| `mapview-embedded` | `true`/`false` | Mapa embebido dentro del layout |
| `zoom-to-my-location` | `true`/`false` | Centrar automáticamente en la ubicación actual |
| `show-pois` | `true`/`false` | Mostrar puntos de interes |
| `clear-lines-on-refresh` | `true`/`false` | Limpiar lineas al refrescar datos |
| `clear-markers-on-refresh` | `true`/`false` | Limpiar marcadores al refrescar datos |
| `show-compass` | `true`/`false` | Mostrar brujula en el mapa |
| `show-minimap` | `true`/`false` | Mostrar minimapa de referencia |
| `show-scale` | `true`/`false` | Mostrar escala del mapa |
| `follow-location-on-background` | `true`/`false` | Seguir ubicación en segundo plano |
| `zoom-buttons-visibility` | `always`/`never` | Visibilidad de botones de zoom |
| `show-google-buttons` | `true`/`false` | Mostrar botones de Google Maps |
| `zoom-to-pois` | `true`/`false` | Ajustar zoom para mostrar todos los POIs |

### 13.2 Ejemplo completo

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

**Uso en XML:**

```xml
<coll name="MapaEntregas" class="clsmapview">
    <!-- Propiedades del mapa -->
</coll>
```

> **Referencia cruzada:** Para la API JavaScript de mapas (anadir marcadores, dibujar rutas), consultar el tópico [03 - API JavaScript](./03-javascript-api-guide.md).

---

## 14. Patrones de Diseño Material Design

Esta sección presenta los patrones de diseño más comunes utilizados en los proyectos XOne reales, siguiendo los principios de Material Design.

### 14.1 Esqueleto base (coll + prop globales)

Todo proyecto XOne debe definir los selectores globales `coll` y `prop` como base. Este es el esqueleto mínimo presente en **todos** los proyectos de ejemplo:

```css
/* Configuración global de propiedades */
prop {
    fontname: Roboto-Regular.ttf;
    fontsize: 11;
    labelbox: false;
    label-wrap: true;
    text-border: false;
    forecolor: #212121;
}

/* Configuración global de colecciones */
coll {
    notab: true;
    show-toolbar: false;
    group-swipe: false;
    editmask: 0;
    bgcolor: #FFFFFF;
}
```

### 14.2 Clase de header (.frameHeader)

El header es el frame superior de cada pantalla. Suele contener el título, botones de navegación y acciones.

```css
/* Header estandar */
.frameHeader {
    width: 100%;
    height: 140p;
    bgcolor: #1565C0;      /* Color primario de marca */
    align: center;
}

/* Header secundario (mas bajo) */
.frameHeaderSecundario {
    width: 100%;
    height: 120p;
    bgcolor: #1976D2;
    align: center;
}

/* Header transparente (para pantallas con mapa) */
.frameHeaderTransparente {
    width: 100%;
    height: 100p;
    bgcolor: #00FFFFFF;
    align: center;
}
```

### 14.3 Clase de body (.frameBody con scroll)

El body es el área principal de contenido, normalmente con scroll habilitado.

```css
/* Body con scroll (el mas comun) */
.frameBody {
    width: 100%;
    height: 100%;
    scroll: true;
    bgcolor: #F5F5F5;
}

/* Body sin scroll */
.frameBodyFijo {
    width: 100%;
    height: 100%;
    scroll: false;
    bgcolor: #FFFFFF;
}

/* Body para pantallas con mapa */
.frameBodyMapa {
    width: 100%;
    height: 100%;
    scroll: false;
    bgcolor: #E3F2FD;
}
```

### 14.4 Clase de footer (.frameFooter)

El footer es el frame inferior, normalmente con botones de acción.

```css
/* Footer estandar con borde superior */
.frameFooter {
    width: 100%;
    height: 120p;
    bgcolor: #FFFFFF;
    align: center;
    border-top: true;
    border-top-color: #E0E0E0;
}

/* Footer fijo (no se mueve con el scroll) */
.frameFooterFijo {
    width: 100%;
    height: 120p;
    bgcolor: #FFFFFF;
    align: center;
    fixed: true;
    orientation: bottom;
}
```

### 14.5 Botones (.btnPrimario, .btnSecundario, .btnPeligro)

Los botones siguen el patron de Material Design con esquinas redondeadas y colores por estado:

```css
/* Boton primario - Accion principal */
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

/* Boton secundario - Outline */
.btnSecundario {
    width: 90%;
    height: 56p;
    bgcolor: #FFFFFF;
    forecolor: #1565C0;
    border: true;
    border-color: #1565C0;
    border-corner-radius: 28;
    text-align: center;
    fontsize: 16;
}

/* Boton de peligro - Accion destructiva */
.btnPeligro {
    width: 90%;
    height: 56p;
    bgcolor: #F44336;
    forecolor: #FFFFFF;
    border-corner-radius: 28;
    text-align: center;
    fontsize: 16;
}

/* Boton de exito - Confirmacion */
.btnExito {
    width: 90%;
    height: 56p;
    bgcolor: #4CAF50;
    forecolor: #FFFFFF;
    border-corner-radius: 28;
    text-align: center;
    fontsize: 16;
    fontname: Roboto-Bold.ttf;
}

/* Boton de acento */
.btnAcento {
    width: 90%;
    height: 56p;
    bgcolor: #00BCD4;
    forecolor: #FFFFFF;
    border-corner-radius: 28;
    text-align: center;
    fontsize: 16;
    fontname: Roboto-Bold.ttf;
}
```

### 14.6 Campos de texto (.textoEditable)

```css
/* Campo con borde inferior (Material Design) */
.textoEditable {
    width: 95%;
    height: 56p;
    labelwidth: 0;
    text-border: true;
    text-border-bottom: true;
    text-border-left: false;
    text-border-right: false;
    text-border-top: false;
    text-border-color: #BDBDBD;
    fontsize: 14;
}

/* Campo enfocado - Color del borde cambia */
.textoEditableEnfocado {
    extends: .textoEditable;
    text-border-color: #1565C0;
}

/* Campo con fondo gris (sin borde) */
.inputTexto {
    width: 95%;
    height: 56p;
    bgcolor: #F5F5F5;
    border-corner-radius: 8;
    text-border: false;
    fontsize: 14;
    lmargin: 15p;
}

/* Campo de busqueda redondeado */
.inputBusqueda {
    width: 95%;
    height: 56p;
    bgcolor: #FFFFFF;
    border-corner-radius: 28;
    border: true;
    border-color: #E0E0E0;
    lmargin: 15p;
    fontsize: 14;
}

/* Campo multilinea */
.textoEditableMulti {
    extends: .textoEditable;
    lines: 5;
    fixed-lines: false;
    text-border: true;
    text-border-bottom: true;
    text-border-left: true;
    text-border-right: true;
    text-border-top: true;
    border-corner-radius: 8;
}
```

### 14.7 Tarjetas (.frameCard)

Las tarjetas son contenedores blancos elevados que agrupan información relacionada:

```css
/* Tarjeta estandar */
.tarjeta {
    width: 95%;
    bgcolor: #FFFFFF;
    border-corner-radius: 12;
    tmargin: 10p;
    bmargin: 5p;
    lmargin: 10p;
    rmargin: 10p;
}

/* Tarjeta con borde */
.tarjetaConBorde {
    width: 95%;
    bgcolor: #FFFFFF;
    border-corner-radius: 16;
    border: true;
    border-color: #E0E0E0;
    tmargin: 10p;
}

/* Tarjeta seleccionada */
.tarjetaSeleccionada {
    width: 95%;
    bgcolor: #E3F2FD;
    border-corner-radius: 12;
    border: true;
    border-color: #1565C0;
}

/* Tarjeta con padding interno (proyecto SocialNetwork) */
.frameCard {
    width: 96%;
    lmargin: 2%;
    bgcolor: #FFFFFF;
    border-corner-radius: 12;
    tmargin: 10p;
    tpadding: 15p;
    bpadding: 15p;
    lpadding: 15p;
    rpadding: 15p;
}
```

### 14.8 FAB (Floating Action Button)

El FAB es un botón circular flotante que representa la acción principal de la pantalla:

```css
/* FAB estandar (56p) */
.btnFAB {
    width: 56p;
    height: 56p;
    bgcolor: #1565C0;
    border-corner-radius: 28;
}

/* FAB grande (64p) */
.btnFlotante {
    width: 64p;
    height: 64p;
    bgcolor: #1565C0;
    border-corner-radius: 32;
}

/* FAB extragrande con floating (proyecto SocialNetwork - 112p) */
.btnFABGrande {
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

### 14.9 Toolbar / Tab Bar

```css
/* Grupo sin tabs (el mas comun) */
.groupNoTab {
    tab-visible: false;
}

/* Grupo con tabs de navegacion */
.groupConTab {
    tab-visible: true;
    tab-height: 56p;
    tab-fontsize: 14;
    tab-bgcolor: #0D47A1;
    tab-forecolor: #BBDEFB;
    tab-selected-forecolor: #FFFFFF;
    tab-indicator-color: #FFFFFF;
}

/* Barra de navegacion inferior (proyecto SocialNetwork) */
.frameNavBar {
    width: 100%;
    height: 100p;
    bgcolor: #FFFFFF;
    align: center;
    fixed: true;
    orientation: bottom;
}

/* Item de navegacion */
.btnNavItem {
    width: 25%;
    height: 100%;
    bgcolor: #FFFFFF;
    labelwidth: 0;
    img-width: 48p;
    img-height: 48p;
    newline: false;
}

.btnNavItemActive {
    extends: .btnNavItem;
    bgcolor: #FFECB3;
}
```

### 14.10 Item de lista

```css
/* Item de lista estandar */
.itemLista {
    width: 100%;
    height: 72p;
    bgcolor: #FFFFFF;
    border-bottom: true;
    border-bottom-color: #EEEEEE;
}

/* Item de lista seleccionado */
.itemListaSeleccionado {
    width: 100%;
    height: 72p;
    bgcolor: #E3F2FD;
}

/* Separador de lista */
.separador {
    width: 100%;
    height: 1p;
    bgcolor: #EEEEEE;
}

/* Separador con margen lateral */
.separadorConMargen {
    width: 90%;
    height: 1p;
    bgcolor: #E0E0E0;
    align: center;
}

/* Separador con indentacion (estilo MiMensajeria) */
.frameDivider {
    width: 100%;
    height: 1p;
    bgcolor: #E0E0E0;
    lmargin: 72p;
}
```

---

## 15. Temas (Light y Dark)

### 15.1 Como estructurar temas

XOne soporta cambio de tema mediante archivos CSS separados que se cargan automáticamente según el tema activo del dispositivo:

- `default.css` - Tema base (normalmente light)
- `default_night.css` - Sobreescrituras para tema oscuro
- `default_day.css` - Sobreescrituras para tema claro (si el base es oscuro)

El sistema de cascada de XOne aplica automáticamente el archivo de tema sobre los estilos base. Solo es necesario sobreescribir los atributos de color que cambian.

### 15.2 Variables de color centralizadas

XOne admite variables CSS reales (`:root { --color: red; }` + `var(--color)`). Para temas el patrón recomendado es declarar la paleta en `:root` dentro de `colors.css` y referenciarla con `var(--...)` en el resto de hojas. Como alternativa equivalente — más antigua pero todavía válida — se pueden usar clases de color que encapsulan el valor:

**Patrón con variables CSS (recomendado):**

```css
/* default-colors.css */
:root {
    --color-primario: #1565C0;
    --color-fondo:    #FFFFFF;
    --color-texto:    #212121;
}

/* default.css */
.frameHeader {
    bgcolor:   var(--color-primario);
    forecolor: var(--color-fondo);
}

/* default_night.css — solo redefine las variables */
:root {
    --color-primario: #0D47A1;
    --color-fondo:    #121212;
    --color-texto:    #E0E0E0;
}
```

**Patrón clásico con clases (sigue funcionando):**

```css
/* default-colors.css - Tema Light */
.xnDarkBgcolor {
    bgcolor: #1565C0;
    forecolor: #FFFFFF;
}

.xnLightBgcolor {
    bgcolor: #F5F5F5;
    forecolor: #212121;
}

.xnTransparentBgcolor {
    bgcolor: #00000000;
}
```

### 15.3 Ejemplo de tema oscuro

**`default_night.css`:**

```css
/* Sobreescribir coleccion */
coll {
    bgcolor: #121212;
}

/* Sobreescribir propiedades globales */
prop {
    forecolor: #E0E0E0;
}

/* Sobreescribir layout */
.frameHeader {
    bgcolor: #1E1E1E;
}

.frameBody {
    bgcolor: #121212;
}

.frameFooter {
    bgcolor: #1E1E1E;
    border-top-color: #333333;
}

/* Sobreescribir tarjetas */
.tarjeta {
    bgcolor: #1E1E1E;
}

/* Sobreescribir inputs */
.inputTexto {
    bgcolor: #2C2C2C;
    text-forecolor: #E0E0E0;
}

/* Sobreescribir textos */
.textoTitulo {
    forecolor: #FFFFFF;
}

.textoSecundario {
    forecolor: #9E9E9E;
}
```

**`default_day.css` (ejemplo de la knowledgebase):**

```css
.cssDemo {
    bgcolor: #F8C471;
    forecolor: #000000;
    title: Modo dia;
}
```

**`default_night.css` (ejemplo de la knowledgebase):**

```css
.cssDemo {
    bgcolor: #000000;
    forecolor: #FFFFFF;
    title: Modo noche;
}
```

### 15.4 Cambio dinámico de CSS

Desde JavaScript se puede cargar un archivo CSS diferente en tiempo de ejecución, lo que permite implementar un cambio de tema manual por el usuario. Consultar la API JavaScript para los métodos disponibles.

> **Referencia cruzada:** Para los métodos JavaScript de cambio de CSS, consultar el tópico [03 - API JavaScript](./03-javascript-api-guide.md).

---

## 16. CSS Completo de Ejemplo

### Archivo `default.css` completo comentado

El siguiente ejemplo es un `default.css` completo para un proyecto XOne generico, basado en los patrones reales encontrados en los proyectos UseCars, XOneDelivery, MiMensajeria, SocialNetwork y GestionTareas:

```css
/* ============================================
   PROYECTO EJEMPLO - Estilos Globales
   Paleta: Azul #1565C0
   ============================================ */

/* ============================================
   CONFIGURACION GLOBAL
   Estos selectores aplican a TODOS los elementos
   ============================================ */

/* Tipografia y estilo base de todos los campos */
prop {
    fontname: Roboto-Regular.ttf;
    fontsize: 11;
    labelbox: false;
    label-wrap: true;
    text-border: false;
    forecolor: #212121;
}

/* Configuración base de todas las colecciones */
coll {
    notab: true;
    show-toolbar: false;
    group-swipe: false;
    editmask: 0;
    bgcolor: #FFFFFF;
}

/* ============================================
   ICONOS DEL SISTEMA
   Iconos para combos, busquedas, etc.
   ============================================ */

prop {
    img-spinner: ic_arrow_drop_down.png;
    img-spinner-sel: ic_arrow_drop_down.png;
    img-search: ic_search.png;
    img-search-sel: ic_search.png;
    img-delete: ic_delete.png;
    img-delete-sel: ic_delete.png;
    img-checked: ic_check_box.png;
    img-unchecked: ic_check_box_outline_blank.png;
    img-camera: ic_photo_camera.png;
    img-camera-sel: ic_photo_camera.png;
    img-date: ic_date_range.png;
    img-date-sel: ic_date_range.png;
    img-time: ic_access_time.png;
    img-time-sel: ic_access_time.png;
    img-att: ic_attach_file.png;
    img-att-sel: ic_attach_file.png;
    img-height: 28;
    img-width: 28;
}

/* ============================================
   FRAMES DE LAYOUT
   Estructura Header / Body / Footer
   ============================================ */

/* Header principal */
.frameHeader {
    width: 100%;
    height: 140p;
    bgcolor: #1565C0;
    align: center;
}

/* Body con scroll */
.frameBody {
    width: 100%;
    height: 100%;
    scroll: true;
    bgcolor: #F5F5F5;
}

/* Body sin scroll */
.frameBodyFijo {
    width: 100%;
    height: 100%;
    scroll: false;
    bgcolor: #FFFFFF;
}

/* Footer fijo */
.frameFooter {
    width: 100%;
    height: 120p;
    bgcolor: #FFFFFF;
    align: center;
    border-top: true;
    border-top-color: #E0E0E0;
}

/* ============================================
   TARJETAS
   ============================================ */

.tarjeta {
    width: 95%;
    bgcolor: #FFFFFF;
    border-corner-radius: 12;
    tmargin: 10p;
    bmargin: 5p;
    lmargin: 10p;
    rmargin: 10p;
}

.tarjetaSeleccionada {
    width: 95%;
    bgcolor: #E3F2FD;
    border-corner-radius: 12;
    border: true;
    border-color: #1565C0;
}

/* Panel inferior (modal) */
.panelInferior {
    width: 100%;
    bgcolor: #FFFFFF;
    border-corner-radius-top-left: 24;
    border-corner-radius-top-right: 24;
}

/* ============================================
   BOTONES
   ============================================ */

/* Primario */
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

/* Secundario (outline) */
.btnSecundario {
    width: 90%;
    height: 56p;
    bgcolor: #FFFFFF;
    forecolor: #1565C0;
    border: true;
    border-color: #1565C0;
    border-corner-radius: 28;
    text-align: center;
    fontsize: 16;
}

/* Peligro */
.btnPeligro {
    width: 90%;
    height: 56p;
    bgcolor: #F44336;
    forecolor: #FFFFFF;
    border-corner-radius: 28;
    text-align: center;
    fontsize: 16;
}

/* Exito */
.btnExito {
    width: 90%;
    height: 56p;
    bgcolor: #4CAF50;
    forecolor: #FFFFFF;
    border-corner-radius: 28;
    text-align: center;
    fontsize: 16;
    fontname: Roboto-Bold.ttf;
}

/* Icono circular */
.btnIcono {
    width: 56p;
    height: 56p;
    bgcolor: #FFFFFF;
    border-corner-radius: 28;
}

/* FAB */
.btnFlotante {
    width: 64p;
    height: 64p;
    bgcolor: #1565C0;
    border-corner-radius: 32;
}

/* Chip */
.btnChip {
    height: 40p;
    bgcolor: #E3F2FD;
    forecolor: #1565C0;
    border-corner-radius: 20;
    text-align: center;
    fontsize: 14;
    lmargin: 5p;
    rmargin: 5p;
}

.btnChipSeleccionado {
    height: 40p;
    bgcolor: #1565C0;
    forecolor: #FFFFFF;
    border-corner-radius: 20;
    text-align: center;
    fontsize: 14;
}

/* ============================================
   CAMPOS DE TEXTO
   ============================================ */

/* Con borde inferior (Material Design) */
.inputTextoLinea {
    width: 95%;
    height: 56p;
    bgcolor: #FFFFFF;
    text-border: true;
    text-border-bottom: true;
    text-border-left: false;
    text-border-right: false;
    text-border-top: false;
    text-border-color: #BDBDBD;
    fontsize: 14;
}

/* Enfocado */
.inputTextoLineaEnfocado {
    extends: .inputTextoLinea;
    text-border-color: #1565C0;
}

/* Con fondo gris */
.inputTexto {
    width: 95%;
    height: 56p;
    bgcolor: #F5F5F5;
    border-corner-radius: 8;
    text-border: false;
    fontsize: 14;
    lmargin: 15p;
}

/* Busqueda redondeada */
.inputBusqueda {
    width: 95%;
    height: 56p;
    bgcolor: #FFFFFF;
    border-corner-radius: 28;
    border: true;
    border-color: #E0E0E0;
    lmargin: 15p;
    fontsize: 14;
}

/* ============================================
   TEXTOS Y ETIQUETAS
   ============================================ */

.textoTituloGrande {
    fontsize: 28;
    fontname: Roboto-Bold.ttf;
    forecolor: #FFFFFF;
    text-align: center;
}

.textoTitulo {
    fontsize: 20;
    fontname: Roboto-Bold.ttf;
    forecolor: #212121;
    text-align: left;
}

.textoSubtitulo {
    fontsize: 16;
    forecolor: #616161;
}

.textoNormal {
    fontsize: 14;
    forecolor: #212121;
}

.textoSecundario {
    fontsize: 14;
    forecolor: #9E9E9E;
}

.textoPequeno {
    fontsize: 12;
    forecolor: #9E9E9E;
}

/* ============================================
   BADGES DE ESTADO
   ============================================ */

.badgeEstado {
    height: 28p;
    fontsize: 12;
    fontname: Roboto-Bold.ttf;
    forecolor: #FFFFFF;
    text-align: center;
    border-corner-radius: 14;
    lmargin: 10p;
    rmargin: 10p;
}

.badgePendiente {
    extends: .badgeEstado;
    bgcolor: #FFC107;
    forecolor: #212121;
}

.badgeAsignado {
    extends: .badgeEstado;
    bgcolor: #2196F3;
}

.badgeEntregado {
    extends: .badgeEstado;
    bgcolor: #4CAF50;
}

.badgeCancelado {
    extends: .badgeEstado;
    bgcolor: #9E9E9E;
}

.badgeError {
    extends: .badgeEstado;
    bgcolor: #F44336;
}

/* ============================================
   AVATARES
   ============================================ */

.avatar {
    width: 64p;
    height: 64p;
    border-corner-radius: 32;
}

.avatarGrande {
    width: 96p;
    height: 96p;
    border-corner-radius: 48;
}

.avatarPequeno {
    width: 48p;
    height: 48p;
    border-corner-radius: 24;
}

/* ============================================
   ICONOS
   ============================================ */

.iconoAccion {
    width: 48p;
    height: 48p;
}

.iconoPequeno {
    width: 24p;
    height: 24p;
}

/* ============================================
   LISTAS
   ============================================ */

.itemLista {
    width: 100%;
    height: 72p;
    bgcolor: #FFFFFF;
    border-bottom: true;
    border-bottom-color: #EEEEEE;
}

.separador {
    width: 100%;
    height: 1p;
    bgcolor: #EEEEEE;
}

/* ============================================
   GRUPOS Y TABS
   ============================================ */

.groupNoTab {
    tab-visible: false;
}

.groupConTab {
    tab-visible: true;
    tab-height: 56p;
    tab-fontsize: 14;
    tab-bgcolor: #1565C0;
    tab-forecolor: #BBDEFB;
    tab-selected-forecolor: #FFFFFF;
    tab-indicator-color: #FFFFFF;
}

/* ============================================
   FIRMA Y FOTO
   ============================================ */

.areaFirma {
    width: 100%;
    height: 200p;
    bgcolor: #FAFAFA;
    border: true;
    border-color: #E0E0E0;
    border-corner-radius: 8;
}

.fotoPreview {
    width: 100%;
    height: 200p;
    border-corner-radius: 8;
}

/* ============================================
   ANIMACIONES
   ============================================ */

.animSlideRight {
    animation-in: ##RIGHT_IN##;
    animation-in-delay: 200;
    animation-out: ##LEFT_OUT##;
    animation-out-delay: 200;
}

.animFadeIn {
    animation-in: ##ALPHA_IN##;
    animation-in-delay: 300;
}

.animSlideUp {
    animation-in: ##PUSH_IN##;
    animation-in-delay: 200;
}
```

### Archivo `colors.css` completo

```css
/* ============================================
   PROYECTO EJEMPLO - Paleta de Colores
   Tema basado en tonos de azul
   ============================================ */

/* ============================================
   COLORES PRIMARIOS
   ============================================ */

.colorPrimario {
    bgcolor: #0D47A1;
}

.colorPrimarioAccion {
    bgcolor: #1565C0;
}

.colorPrimarioMedio {
    bgcolor: #1976D2;
}

.colorPrimarioClaro {
    bgcolor: #1E88E5;
}

.colorPrimarioSuave {
    bgcolor: #42A5F5;
}

.colorPrimarioPastel {
    bgcolor: #64B5F6;
}

.colorPrimarioHielo {
    bgcolor: #BBDEFB;
}

.colorPrimarioNieve {
    bgcolor: #E3F2FD;
}

/* ============================================
   COLORES DE ACENTO
   ============================================ */

.colorAcento {
    bgcolor: #00BCD4;
}

.colorAcentoClaro {
    bgcolor: #4DD0E1;
}

/* ============================================
   COLORES DE ESTADO
   ============================================ */

.colorExito {
    bgcolor: #4CAF50;
}

.colorAdvertencia {
    bgcolor: #FFC107;
}

.colorError {
    bgcolor: #F44336;
}

.colorProgreso {
    bgcolor: #FF9800;
}

.colorInfo {
    bgcolor: #2196F3;
}

/* ============================================
   COLORES NEUTROS
   ============================================ */

.colorFondoBlanco {
    bgcolor: #FFFFFF;
}

.colorFondoGrisClaro {
    bgcolor: #F5F5F5;
}

.colorFondoGris {
    bgcolor: #EEEEEE;
}

.colorTextoOscuro {
    forecolor: #212121;
}

.colorTextoMedio {
    forecolor: #616161;
}

.colorTextoClaro {
    forecolor: #9E9E9E;
}

.colorTextoBlanco {
    forecolor: #FFFFFF;
}

.colorBorde {
    border-color: #E0E0E0;
}

.colorSeparador {
    bgcolor: #BDBDBD;
}
```

---

## 17. Best Practices

### 17.1 Top 15 buenas prácticas CSS en XOne

1. **Usar siempre `default.css` como archivo base** - Es el único archivo CSS obligatorio y debe contener los selectores `coll` y `prop` globales.

2. **Separar colores en `colors.css`** - Facilita el cambio de tema y mantiene el `default.css` más legible.

3. **Usar unidad `p` para dimensiones fijas y `%` para responsivas** - Nunca usar `px`, `em`, `rem`.

4. **Definir `fontsize` sin unidad** - El valor numérico es suficiente: `fontsize: 14`, no `fontsize: 14p`.

5. **Usar `extends` para variantes** - No duplicar atributos cuando solo cambia el color o un detalle.

6. **Comentar las secciones del CSS** - Usar bloques de comentarios con `/* ====== SECCION ====== */` para separar categorías.

7. **Seguir nomenclatura consistente** - Usar prefijos descriptivos (`frame`, `btn`, `input`, `texto`, `tarjeta`, `badge`, `avatar`, `icono`, `group`).

8. **Definir los iconos del sistema en el selector `prop`** - Configurar `img-spinner`, `img-search`, `img-checked`, etc. una sola vez.

9. **Usar `labelwidth: 0` cuando no hay etiqueta** - Evita desperdiciar espacio horizontal.

10. **Preferir `text-border-bottom: true` para inputs** - Es el patron Material Design más limpio y común.

11. **Usar `border-corner-radius` como mitad del `height` para botones pill** - Ejemplo: `height: 56p; border-corner-radius: 28;`.

12. **Recordar que alpha va PRIMERO en ARGB** - `#80FFFFFF` = blanco 50%, no `#FFFFFF80`.

13. **No abusar de animaciones** - Reservarlas para transiciones de pantalla, no para cada elemento.

14. **Definir siempre los tres frames básicos** - `.frameHeader`, `.frameBody` (con `scroll: true`), `.frameFooter`.

15. **Organizar el CSS en el mismo orden** - Globales, layout, tarjetas, botones, inputs, textos, badges, avatares, iconos, listas, grupos, componentes especiales, animaciones.

### 17.2 Anti-patrones comunes

| Anti-patron | Por que es malo | Solución correcta |
|-------------|----------------|-------------------|
| Usar `font-size: 14px` | Nombre y unidad CSS web | `fontsize: 14` |
| Usar `background-color` | Nombre CSS web | `bgcolor: #FFFFFF` |
| Usar `margin: 10p` | Abreviatura no existe en XOne | `tmargin: 10p; bmargin: 10p; lmargin: 10p; rmargin: 10p;` |
| Usar `#RRGGBBAA` para transparencia | Formato web, alpha al final | `#AARRGGBB` (alpha al inicio) |
| Usar `#FFF` abreviado | Abreviatura no garantizada | `#FFFFFF` (6 digitos completos) |
| Duplicar todos los atributos en variantes | Código duplicado, difícil de mantener | `extends: .claseBase;` con sobreescritura |
| Usar `display: none` | Atributo CSS web | `visible: 0` |
| Usar `display: flex` | Flexbox no soportado | Usar `frame` y `group` en XML |
| Mezclar `px` y `p` | `px` no escala entre dispositivos | Usar siempre `p` |
| Poner gradientes | `linear-gradient` no soportado | Usar colores solidos o imágenes de fondo |
| Usar selectores CSS complejos | `div > .header`, `p:first-child` no soportados | Usar clases simples `.miClase` |
| No definir `coll` y `prop` globales | Comportamiento inconsistente | Siempre definir ambos selectores base |

### 17.3 Checklist de validación CSS

Antes de entregar un archivo CSS XOne, verificar:

**Selectores:**
- [ ] Se usa `coll`, `prop`, `prop:TYPE`, `.clase`, `group`, o `frame` - no otros selectores
- [ ] Los nombres de clase son descriptivos y siguen la nomenclatura del proyecto
- [ ] No hay selectores de ID (`#id`) ni selectores combinadores (`>`, `+`, `~`)

**Unidades:**
- [ ] Todas las dimensiones usan `p` (puntos) o `%` (porcentaje)
- [ ] `fontsize` se define sin unidad (solo número)
- [ ] `border-corner-radius` se define sin unidad (solo número)
- [ ] `border-width` se define sin unidad (solo número)
- [ ] No se usa `px`, `em`, `rem`, `vh`, `vw`

**Colores:**
- [ ] Formato `#RRGGBB` para colores sin transparencia
- [ ] Formato `#AARRGGBB` para colores con alpha (alpha PRIMERO)
- [ ] Colores siempre con 6 u 8 digitos hexadecimales completos
- [ ] No se usan nombres de color (excepto `transparent` con precaucion)

**Atributos:**
- [ ] Todos los atributos usados existen en la knowledgebase CSS de XOne
- [ ] No se mezclan atributos CSS web (`font-size`, `background-color`, `margin-top`)
- [ ] Los valores booleanos son `true`/`false` (no 0/1 para booleanos)
- [ ] Los valores de `visible` usan el bitmask correcto (0-7)

**Herencia:**
- [ ] `extends` referencia clases con el prefijo `.` (ej: `extends: .claseBase`)
- [ ] No hay herencia circular (A extends B extends A)
- [ ] Las sobreescrituras son intencionales

**Estructura:**
- [ ] Existe el selector `coll` con configuración global
- [ ] Existe el selector `prop` con tipografía base
- [ ] Las secciones están comentadas y organizadas
- [ ] Los iconos del sistema están configurados en `prop`

> **Referencia cruzada:** Para la validación completa del proyecto (XML, JS, CSS, estructura de carpetas), consultar el tópico [01 - Fundamentos](./01-xone-fundamentals.md).

### 17.4 Organización recomendada del archivo CSS

El siguiente es el orden recomendado para las secciones del archivo `default.css`, basado en el análisis de todos los proyectos de ejemplo:

```
1.  Comentario de cabecera (nombre del proyecto, paleta de colores)
2.  Configuración global: prop { }
3.  Configuración global: coll { }
4.  Iconos del sistema (img-spinner, img-search, etc.)
5.  Frames de layout (.frameHeader, .frameBody, .frameFooter)
6.  Tarjetas y contenedores (.tarjeta, .panelInferior)
7.  Botones (.btnPrimario, .btnSecundario, .btnPeligro, .btnFlotante)
8.  Campos de texto (.inputTexto, .inputBusqueda, .textoEditable)
9.  Textos y etiquetas (.textoTitulo, .textoSubtitulo, .textoSecundario)
10. Badges de estado (.badgeEstado, .badgePendiente, etc.)
11. Imagenes y avatares (.avatar, .avatarGrande, .iconoAccion)
12. Listas e items (.itemLista, .separador)
13. Grupos y tabs (.groupNoTab, .groupConTab)
14. Componentes especiales (.areaFirma, .fotoPreview, .barraProgreso)
15. Animaciones (.animSlideRight, .animFadeIn)
```

---

## 18. Funciones del parser CSS

Esta sección documenta las **funciones de sintaxis del parser CSS** de XOne. Son features procesadas antes de que el motor de render reciba las reglas, por lo que el consumidor (los controles de la UI) no ve diferencia con un valor literal: ve el resultado ya calculado o sustituido.

### 18.1 Comentarios

XOne acepta dos formas de comentario, válidas en cualquier posición fuera de un valor (entre reglas, entre selector y `{`, dentro del cuerpo de un bloque entre declaraciones):

```css
/* Comentario multilínea
   tan largo como haga falta */

// Comentario de una sola línea (hasta el final del renglón)

.tarjeta {
    // pendiente: revisar contraste con el tema oscuro
    bgcolor: #FFFFFF;
    /* color de marca */
    forecolor: #1565C0;
}
```

> **Limitación:** los comentarios NO se reconocen dentro del valor de una declaración. `bgcolor: red /* nota */;` acumularía `red /* nota */` literal como valor.

### 18.2 `@import` — composición de hojas

Permite cargar otra hoja CSS y mergear sus reglas como si estuvieran inline en el archivo actual. La hoja importada puede a su vez tener sus propios `@import` al inicio.

```css
@import "colors.css";
@import url("base.css");

/* Aquí ya están disponibles todas las reglas y variables de las dos hojas */
.frameHeader {
    bgcolor: var(--color-primario);
}
```

**Reglas:**

- **Posición**: solo al inicio del archivo, antes de cualquier regla. Si aparece después → error de parseo.
- **Sintaxis admitida**: `@import "ruta";`, `@import 'ruta';`, `@import url("ruta");`, `@import url(ruta);`.
- **Ciclos detectados**: si A importa B y B importa A, el parser lanza error con el path en conflicto.
- **Variables globales** declaradas en la hoja importada (`:root`) son visibles en la principal. Reglas y `!default` también se mergean.
- **Patrón típico**: una hoja `colors.css` con la paleta + una `base.css` con valores `!default` + tu `default.css` que solo sobreescribe lo que cambia.

### 18.3 Variables CSS (`:root`, `var()`)

#### Variables globales

Se declaran en un bloque `:root { ... }`. Se referencian con `var(--nombre)` o `var(--nombre, fallback)` en cualquier valor. La resolución es post-pasada: el orden de declaración no importa, `:root` puede aparecer al final del archivo o en una hoja importada.

```css
:root {
    --color-primario:   #1565C0;
    --color-acento:     #FFC107;
    --espaciado-base:   8;
    --radio-tarjeta:    12;
}

.tarjeta {
    bgcolor:              var(--color-primario);
    border-corner-radius: var(--radio-tarjeta);
    tmargin:              var(--espaciado-base);
    bmargin:              var(--espaciado-base);
}

.alerta {
    /* fallback usado cuando --color-error no está declarada */
    bgcolor: var(--color-error, #F44336);
}
```

**Características:**

- **Case-sensitive**: `--Color` ≠ `--color`.
- **Múltiples por valor**: `caption: pad var(--p1) var(--p2) fin;` se sustituye pieza a pieza.
- **Anidamiento**: una variable puede referenciar a otra. `--acento: var(--primario);` funciona aunque `--primario` aparezca más adelante.
- **Variable sin declarar y sin fallback**: el `var(...)` queda literal en el valor (no rompe la regla).

#### Variables locales (scope de bloque)

Una declaración `--nombre: valor;` dentro de un bloque que NO sea `:root` puro queda confinada al bloque. Se sustituyen al cerrar `}`. Útil para valores derivados que solo aplican a una clase concreta.

```css
.tarjeta {
    --pad: 16;
    --pad-doble: calc(var(--pad) * 2);

    lpadding: var(--pad);
    rpadding: var(--pad);
    tpadding: var(--pad-doble);
    bpadding: var(--pad-doble);
}
```

- **Sombreado**: si una local y una global tienen el mismo nombre, gana la local dentro de su bloque.
- **No visibles fuera** del bloque sintáctico.
- **Multi-selector**: en `a, b { --c: red; ... }` la local aplica a las reglas generadas para `a` y para `b`.

### 18.4 `calc()` — aritmética en valores

Evalúa expresiones aritméticas con `+`, `-`, `*`, `/`, paréntesis y operador unario `-` sobre números puros. Se ejecuta tras la resolución de variables, así que puedes combinarlas libremente.

```css
:root {
    --base:  8;
    --doble: calc(var(--base) * 2);  /* 16 */
}

.frameHeader {
    height:               calc(var(--base) * 20);     /* 160 */
    border-corner-radius: calc(var(--doble) - 4);     /* 12 */
}

.btnPrimario {
    fontsize: calc(14 + 2);
    lmargin:  calc((100 - 90) / 2);   /* 5 */
}
```

**Características:**

- **Operandos sin unidades**: `calc(8 * 2)` → `16`. NO interpreta `p`, `dp`, `%`, etc. Para tamaños en `p` o `%`, escribe el número solo y deja el ajuste de unidad fuera del `calc()`.
- **Precedencia estándar**: `*` y `/` antes que `+` y `-`. Paréntesis para sobreescribir.
- **Resultado entero exacto** → se emite como entero (`calc(4*3)` → `12`, no `12.0`). Si no es entero, se redondea a 6 dígitos y se eliminan ceros al final.
- **Múltiples calc en un mismo valor**: `caption: pad calc(8+8) fin;` se procesa pieza a pieza.
- **Errores** (división por cero, paréntesis sin balancear, sintaxis inválida): en parseo silencioso el `calc(...)` se preserva literal; en modo estricto el parser lanza.

### 18.5 `!important` y `!default`

Sufijos al final del valor que controlan la cascada **dentro del propio parser**, antes de que el motor de render aplique nada.

```css
.alerta {
    bgcolor: #FFF3CD !important;     /* no se sobreescribe por declaraciones normales */
    fontsize: 14;
}

/* Otra hoja u otro bloque NO cambia el bgcolor anterior: */
.alerta {
    bgcolor: lime;   /* ignorado: la previa es !important */
}
```

**`!important`**: una declaración normal posterior NO sobreescribe a una `!important` previa del mismo atributo (ni dentro del mismo bloque, ni entre bloques separados del mismo selector). Solo otra `!important` produce sobreescritura.

**`!default`**: opuesto a `!important`. La declaración solo se aplica si el atributo no estaba ya definido. Pensado para hojas base sobre-escribibles.

```css
/* base.css importada por default.css */
boton {
    bgcolor:  gray   !default;
    fontsize: 14     !default;
    lmargin:  8      !default;
}

/* default.css — solo cambia lo que toca; el resto conserva los defaults */
boton {
    bgcolor: #1565C0;
}
```

Resultado: `boton` queda con `bgcolor: #1565C0`, `fontsize: 14`, `lmargin: 8`.

**Combinación**: `!important !default` aplicado en cualquier orden significa "si no había declaración previa, aplica con `!important`". Si la había, se descarta.

### 18.6 `@extend selector;` — herencia vía at-rule

Alternativa moderna al atributo `extends:` tradicional. La at-rule `@extend selector;` dentro de un bloque copia las declaraciones del selector referenciado **antes** de que el motor de render reciba nada.

```css
/* Base reutilizable */
.btnBase {
    width: 90%;
    height: 144p;
    border-corner-radius: 28;
    fontsize: 16;
}

/* Variantes via at-rule */
.btnPrimario {
    @extend .btnBase;
    bgcolor:   #1565C0;
    forecolor: #FFFFFF;
}

.btnPeligro {
    @extend .btnPrimario;          /* encadenado: hereda de primario que hereda de base */
    bgcolor: #F44336 !important;
}

/* Multi-extend: combina varios padres */
.btnExitoGrande {
    @extend .btnBase;
    @extend .colorExito;
    height: 168p;
}
```

**Características:**

- **Referencias adelantadas permitidas**: el target del `@extend` puede declararse en cualquier punto de la hoja, incluso posterior al uso (se resuelve en post-pasada).
- **Hijo gana**: las declaraciones propias del bloque vencen sobre las heredadas, salvo cuando el padre es `!important` y el hijo no.
- **Encadenamiento transitivo**: `c → b → a` funciona; cada nivel se expande antes de aplicarse al siguiente.
- **Múltiples `@extend` por bloque**: entre los padres aplica "último gana".
- **Ciclos detectados**: auto-referencia (`a` → `a`), 2-vías (`a` ↔ `b`) y N-vías → error de parseo.
- **Multi-selector**: en `a, b { @extend base; }` el extend se aplica a `a` y a `b` independientemente.

#### `@extend` vs atributo `extends:`

Conviven sin conflicto. Diferencias:

| Aspecto | `extends: .clase;` (atributo) | `@extend .clase;` (at-rule) |
|---|---|---|
| Sintaxis | Declaración dentro del bloque | At-rule dentro del bloque |
| Quién lo resuelve | El motor de render (xonecss_lib) en cascada | El parser, en post-pasada |
| Cuándo se resuelve | Al aplicar la regla a una vista | Al parsear la hoja |
| Visibilidad del resultado | El atributo `extends` queda en la regla | Las declaraciones aparecen "in-line" en la regla |
| Detección de ciclos | NO automática | SÍ (en parseo) |
| Estado de adopción | Establecido en proyectos existentes | Nuevo, alternativa moderna |

**Recomendación**: usa el que prefieras según el estilo del proyecto. Si vas a empezar de cero o quieres validación temprana de ciclos, prefiere `@extend`. Si tu proyecto ya usa `extends:`, mantenlo por consistencia.

### 18.7 Selectores múltiples

Un bloque puede aplicarse a varios selectores separados por comas. Internamente se crea una regla independiente por cada uno (no compartida).

```css
.btnPrimario, .btnSecundario, .btnPeligro {
    width: 90%;
    height: 144p;
    border-corner-radius: 28;
    fontsize: 16;
}

/* Equivalente a haberlas escrito una a una con los mismos valores */
```

Variantes de espaciado válidas: `a,b`, `a, b`, `a ,b`, `a , b`.

### 18.8 Modo estricto del parser

El framework puede arrancar el parser en **modo estricto** (`bStrictMode = true`). En ese modo, varios casos que en modo permisivo se ignoran silenciosamente se convierten en errores:

- Declaración sin `;` final o que cierra con `}` antes que con `;`.
- Variable sin declarar y sin fallback en `var(...)`.
- Expresión `calc(...)` inválida o división por cero.
- Target de `@extend` que no existe.

Recomendado durante el desarrollo para detectar typos y referencias rotas; opcional en producción si la hoja ya está validada.

---

**Tabla de equivalencias rápida CSS Web a XOne:**

| CSS Web | XOne CSS |
|---------|----------|
| `font-size: 14px` | `fontsize: 14` |
| `font-family: Roboto` | `fontname: Roboto-Regular.ttf` |
| `font-weight: bold` | `fontbold: true` |
| `font-style: italic` | `fontitalic: true` |
| `color: #333` | `forecolor: #333333` |
| `background-color: #fff` | `bgcolor: #FFFFFF` |
| `background-image: url(img.png)` | `imgbk: img.png` |
| `margin-top: 10px` | `tmargin: 10p` |
| `margin-bottom: 10px` | `bmargin: 10p` |
| `margin-left: 20px` | `lmargin: 20p` |
| `margin-right: 20px` | `rmargin: 20p` |
| `padding-top: 10px` | `tpadding: 10p` |
| `padding-left: 20px` | `lpadding: 20p` |
| `border-radius: 8px` | `border-corner-radius: 8` |
| `border: 1px solid #ccc` | `border: true; border-width: 1; border-color: #CCCCCC;` |
| `text-align: center` | `text-align: center` |
| `height: 50px` | `height: 50p` |
| `width: 100%` | `width: 100%` |
| `display: none` | `visible: 0` |
| `overflow: scroll` | `scroll: true` |
| `position: fixed` | `fixed: true` |
| `opacity: 0.5` | Usar alpha ARGB: `bgcolor: #80...` |
| `cursor: pointer` | No necesario (es móvil) |
| `box-shadow: ...` | No soportado (usar `border` como alternativa) |
| `transition: ...` | No soportado (usar `animation-in`/`animation-out`) |
| `transform: ...` | No soportado |
| `display: flex` | No soportado (usar `frame` y `group`) |
| `display: grid` | No soportado (usar `gallery-columns`) |
| `var(--color)` | `var(--color)` (declarar en `:root`) |
| `calc(8px * 2)` | `calc(8 * 2)` (sobre números puros) |
| `@import url("a.css")` | `@import "a.css";` (solo al inicio) |
| `// comentario` o `/* */` | `// comentario` o `/* */` (no dentro de valores) |

---

> **Documento generado a partir de:** `xone-css-knowledgebase.md` (knowledgebase oficial), `xone-css-styling-guide.md` (guía de referencia del generador), y el análisis de los archivos CSS de los proyectos UseCars, MiMensajeria, SocialNetwork, XOneDelivery y GestionTareas ubicados en `templates/synthetic_samples/` y `knowledgebase/examples/`.
