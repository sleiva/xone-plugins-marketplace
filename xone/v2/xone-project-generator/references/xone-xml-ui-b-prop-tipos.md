# XML/UI Referencia — Nodo <prop> y tipos

Sub-archivo de [xone-xml-ui-reference.md](xone-xml-ui-reference.md). Cubre el nodo `<prop>`: todos los atributos por categoría (esenciales, dimensiones, layout, label, visuales, borde, comportamiento, tooltip, eventos inline, mapeo, visibilidad, IMG y animaciones Lottie, B, X, NC, DR, contents) y la tabla autoritativa de tipos validos.

## Tabla de Contenidos

- [3. Nodo prop - Referencia Completa](#3-nodo-prop---referencia-completa)
- [4. Tipos de Propiedades (type) - Tabla Completa](#4-tipos-de-propiedades-type---tabla-completa)

---

## 3. Nodo prop - Referencia Completa

El nodo `<prop>` es el elemento fundamental. Define campos de datos y controles de UI.

### Atributos Esenciales

| Atributo | Tipo | Obligatorio | Descripción | Ejemplo |
|----------|------|-------------|-------------|---------|
| `name` | string | **Si** | Identificador único del campo. **El ambito de unicidad es la `<coll>` ENTERA**, no el `<group>` o `<frame>` que lo contiene: no pueden existir dos props con el mismo `name` en cualquier parte de la misma coll, ni siquiera en `<group>` o `<frame>` distintos | `name="MAP_NOMBRE"` |
| `type` | string | **Si** | Tipo de dato/control (ver sección 4) | `type="T"` |
| `visible` | int | **Si** | Mapa de bits de visibilidad (0-7) | `visible="7"` |
| `title` | string | No | Etiqueta visible del campo | `title="Nombre"` |
| `class` | string | No | Clase CSS a aplicar | `class="btnPrimario"` |

### Atributos de Dimensiones

| Atributo | Tipo | Descripción | Ejemplo |
|----------|------|-------------|---------|
| `width` | dim | Ancho del control (en `p` o `%`) | `width="80%"`, `width="200p"` |
| `height` | dim | Alto del control (en `p` o `%`) | `height="50p"`, `height="10%"` |
| `fieldsize` | int | Tamaño de campo visual, es la cantidad de espacio que ocupa calculado ancho de carácter x valor de fieldsize | `fieldsize="150"` |
| `size` | int | Tamaño máximo de caracteres también es el tamaño máximo en la base de datos | `size="50"` |

### Atributos de Layout

| Atributo | Tipo | Descripción | Ejemplo |
|----------|------|-------------|---------|
| `newline` | bool | Forzar salto de linea antes del campo | `newline="false"` |
| `align` | string | Alineacion: `left`, `center`, `right`, combinaciones con pipe | `align="center"` |
| `tmargin` | dim | Margen superior | `tmargin="10p"` |
| `bmargin` | dim | Margen inferior | `bmargin="5p"` |
| `lmargin` | dim | Margen izquierdo | `lmargin="15p"` |
| `rmargin` | dim | Margen derecho | `rmargin="10p"` |
| `tpadding` | dim | Padding superior | `tpadding="10p"` |
| `bpadding` | dim | Padding inferior | `bpadding="10p"` |
| `lpadding` | dim | Padding izquierdo | `lpadding="20p"` |
| `rpadding` | dim | Padding derecho | `rpadding="20p"` |

### Atributos de Etiqueta (Label)

| Atributo | Tipo | Descripción | Ejemplo |
|----------|------|-------------|---------|
| `labelwidth` | int | Proporcion del ancho para la etiqueta (0=sin etiqueta) | `labelwidth="6"`, `labelwidth="0"` |
| `labelbox` | bool | Mostrar caja contenedora de etiqueta | `labelbox="false"` |
| `label-align` | string | Alineacion de la etiqueta | `label-align="left"` |
| `label-wrap` | bool | Permitir wrap del texto de etiqueta | `label-wrap="true"` |

### Atributos Visuales

| Atributo | Tipo | Descripción | Ejemplo |
|----------|------|-------------|---------|
| `bgcolor` | color | Color de fondo | `bgcolor="#FF0000"` |
| `forecolor` | color | Color de texto | `forecolor="#FFFFFF"` |
| `fontsize` | int | Tamaño de fuente | `fontsize="14"` |
| `fontname` | string | Archivo de fuente .ttf | `fontname="Roboto-Bold.ttf"` |
| `fontbold` | bool | Texto en negrita | `fontbold="true"` |
| `text-align` | string | Alineacion del texto: `left`, `center`, `right` | `text-align="center"` |
| `text-forecolor` | color | Color del texto editable | `text-forecolor="#333333"` |

### Atributos de Borde

| Atributo | Tipo | Descripción | Ejemplo |
|----------|------|-------------|---------|
| `border` | bool | Mostrar borde general | `border="false"` |
| `border-corner-radius` | int | Radio de esquinas redondeadas | `border-corner-radius="10"` |
| `border-corner-radius-top-left` | int | Radio esquina superior izquierda | `border-corner-radius-top-left="50"` |
| `border-corner-radius-top-right` | int | Radio esquina superior derecha | `border-corner-radius-top-right="50"` |
| `border-corner-radius-bottom-left` | int | Radio esquina inferior izquierda | `border-corner-radius-bottom-left="50"` |
| `border-corner-radius-bottom-right` | int | Radio esquina inferior derecha | `border-corner-radius-bottom-right="50"` |
| `text-border` | bool | Borde en campo de texto | `text-border="true"` |
| `text-border-bottom` | bool | Solo borde inferior (estilo Material) | `text-border-bottom="true"` |
| `text-border-left` | bool | Borde izquierdo | `text-border-left="false"` |
| `text-border-right` | bool | Borde derecho | `text-border-right="false"` |
| `text-border-top` | bool | Borde superior | `text-border-top="false"` |
| `text-border-color` | color | Color del borde de texto | `text-border-color="#BDBDBD"` |
| `border-color` | color | Color del borde general | `border-color="#0066CC"` |

### Atributos de Comportamiento

| Atributo | Tipo | Descripción | Ejemplo |
|----------|------|-------------|---------|
| `locked` | bool | **Bloquea la UI de edición** del control (no editable visualmente). Versión estática de `disableedit` (fórmula). **No** afecta a la persistencia: si el valor cambia desde JS, sí se graba. Para impedir que el campo se grabe en BD usar `readonly="true"` (ver `xone-xml-attributes-reference.md` §4.3). | `locked="true"` |
| `readonly` | bool | **Excluye el campo del UPDATE en BD**. NO bloquea la UI (los controles T/N/NC/spinner no lo leen). Excepción: en `type="VD"` actúa como flag UI (`true`=reproducir, `false`=capturar). Para bloquear edición visual usar `locked`. | `readonly="true"` |
| `autosave` | bool | Guardar automáticamente al cambiar | `autosave="false"` |
| `lines` | int | Número de lineas visibles (para texto multilinea) | `lines="3"` |
| `fixed-lines` | bool | Altura fija basada en número de lineas | `fixed-lines="true"` |
| `fixed-text` | bool | Texto fijo (no editable pero no bloqueado visualmente) | `fixed-text="true"` |
| `mask` | string | Mascara de formato | `mask="0"` |
| `min` | number | Valor mínimo permitido | `min="0"` |
| `max` | number | Valor máximo permitido | `max="100"` |
| `phone` | bool | Indica que el campo es un número de telefono (abre marcador al pulsar) | `phone="true"` |
| `input-type` | string | Tipo de teclado (valores exactos): `text`, `numeric`, `numeric_unsigned`, `decimal`, `phone`, `datetime`, `email`, `username`, `uri`, `password`, `none`. `number`/`url` NO existen → usar `numeric`/`uri` | `input-type="email"` |
| `scale-type` | string | Tipo de escalado para imágenes (snake_case): `center_crop`, `fit_center`, `center_inside`, `fit_xy` | `scale-type="center_crop"` |

### Atributos de Tooltip / Placeholder

| Atributo | Tipo | Descripción | Ejemplo |
|----------|------|-------------|---------|
| `tooltip` | string | Texto hint/placeholder dentro del campo. Se ve cuando el campo está vacío y **desaparece al empezar a escribir** | `tooltip="Ingrese su nombre..."` |
| `floating-tooltip` | bool | Convierte el `tooltip` en **floating label** Material Design: al recibir foco se desplaza arriba del campo y permanece visible mientras escribes | `floating-tooltip="true"` |
| `show-counter` | bool | Mostrar contador de caracteres junto al tooltip flotante | `show-counter="true"` |
| `tooltip-forecolor` | color | Color del texto del tooltip | `tooltip-forecolor="#FF0000"` |
| `expanded-hint-color` | color | Color del hint expandido (Material Design) | `expanded-hint-color="#FF0000"` |

> **Regla `title` vs `tooltip`:** El atributo `title` se pinta como **etiqueta a la izquierda** del valor, dentro del ancho reservado por `labelwidth`. Si pones `labelwidth="0"` para que el campo ocupe todo el ancho, la etiqueta no tiene sitio donde dibujarse y el `title` **no se ve por ningún sitio**. En ese caso, usar `tooltip="..."` en lugar de `title="..."` — se renderiza como hint dentro del propio campo. Si quieres que la etiqueta permanezca visible mientras el usuario escribe (estilo Material), añadir `floating-tooltip="true"`.
>
> **Caso `type="L"`/`TL` (label):** el texto del label es su `title`; si **no** declaras `title`, el label usa como fallback el **valor del campo** al que apunta el `<prop>` (útil para datos dinámicos: asigna el valor por JS y refréscalo con `refreshValue`, o muestra una URL con `autolink="true"` para que quede pulsable). Como un label no tiene placeholder, la solución a una etiqueta oculta NO es `tooltip`. **Nunca pongas `labelwidth="0"` en un label**: dejaría el control vacío. Deja `labelwidth` por defecto y, para alinear el texto, usa `label-align="left|center|right"`. Lo mismo aplica si el estilo viene por clase CSS: una clase de título/subtítulo no debe llevar `labelwidth: 0`.

### Atributos de Eventos Inline

| Atributo | Tipo | Descripción | Ejemplo |
|----------|------|-------------|---------|
| `onclick` | string | Código JS al hacer click | `onclick="doClick();"` |
| `onlongclick` | string | Código JS al click prolongado | `onlongclick="startDrag();"` |
| `onchange` | string | Al cambiar valor (inline simple) | `onchange="Refresh"` |
| `onvaluechanged` | string | JS al cambiar el valor, en la capa de datos (también sin UI) | `onvaluechanged="self.TOTAL = e.value*self.PRECIO;"` |
| `method` | string | Método a ejecutar (para botones) | `method="executenode(aceptar)"` |

> **`onvaluechanged`:** JavaScript inline normal que se dispara desde la capa de datos, así que salta siempre que el valor cambie aunque no haya ventana (scripts de fondo, réplica…). Recibe `e` con `e.value`, `e.oldValue`, `e.target`, `e.objItem` y `e.data`. Solo JavaScript. Útil para lógica que debe ejecutarse siempre que el dato cambie, haya o no pantalla abierta.

### Atributos de Mapeo de Datos (Combos/Lookups)

| Atributo | Tipo | Descripción | Ejemplo |
|----------|------|-------------|---------|
| `mapcol` | string | Coleccion mapeada (lookup/combo) | `mapcol="Usuarios"` |
| `mapfld` | string | Campo de la coleccion mapeada | `mapfld="ID"` |
| `linkedto` | string | Campo al que esta enlazado | `linkedto="MAP_COMBO"` |
| `linkedfield` | string | Campo de enlace en la coleccion destino | `linkedfield="DATA"` |
| `mapcol-values` | string | Valores separados por coma (combo estático) | `mapcol-values="Opción1,Opción2,Opción3"` |
| `showinline` | bool | Abre las opciones en un panel de selección inferior | `showinline="true"` |
| `showinline-keyboard` | bool | Añade buscador en la cabecera del panel `showinline` | `showinline-keyboard="true"` |
| `bgcolor-dialog` / `forecolor-dialog` / `fontsize-dialog` | color/int | Fondo, color de texto/acento y tamaño del panel `showinline` y de los pickers `D`/`DT`/`TT` | `forecolor-dialog="#007AFF"` |

### Atributos de Visibilidad Condicional

| Atributo | Tipo | Descripción | Ejemplo |
|----------|------|-------------|---------|
| `disablevisible` | string | Condición para ocultar el campo | `disablevisible="MAP_TIPO=0"` |
| `updates` | string | Campo que se actualiza cuando este cambia | `updates="MAP_SLIDER_NUM"` |

### Atributos para Imágenes (type="IMG")

| Atributo | Tipo | Descripción | Ejemplo |
|----------|------|-------------|---------|
| `path` | string | Ruta de imagen estática | `path="logo.png"` |
| `img` | string | Imagen del botón/control | `img="ic_menu.png"` |
| `keep-aspect-ratio` | bool | Mantener proporción de la imagen | `keep-aspect-ratio="true"` |
| `abort-on-error` | bool | No mostrar error si falta la imagen | `abort-on-error="true"` |
| `error-image` | string | Imagen alternativa si la principal falla | `error-image="avatar_error.png"` |
| `repeat-mode` | enum | Solo animaciones: `restart` o `reverse` | `repeat-mode="reverse"` |
| `clip-text-to-bounds` | bool | Solo animaciones con texto de párrafo: lo recorta a su caja | `clip-text-to-bounds="true"` |

**Formatos.** `path` (igual que `img` e `imgbk`) acepta PNG, JPG y **SVG** —que se renderiza de forma nativa, sin envolverlo en un `type="WEB"`—, **GIF animado** y **animaciones Lottie**. El formato se decide por la extensión del fichero.

### Animaciones Lottie en un `IMG`

Un `IMG` cuyo fichero sea `.json`, `.lottie` o `.tgs` se renderiza como animación Lottie (las de After Effects/Bodymovin o las de LottieFiles) y **arranca sola en bucle infinito**, sin llamar a nada:

```xml
<!-- Animación de carga, ida y vuelta -->
<prop name="MAP_LOADER" type="IMG" visible="1"
      path="loader.json"
      labelwidth="0"
      width="120p" height="120p"
      repeat-mode="reverse" />
```

| Extensión | Qué es |
|---|---|
| `.json` | La animación en texto plano; sus imágenes pueden ir embebidas dentro o aparte |
| `.lottie` | Paquete comprimido con la animación y sus imágenes. Un `.json` renombrado también se acepta |
| `.tgs` | Sticker de Telegram: un `.json` comprimido con gzip |

- **Fuentes:** si la animación lleva texto, la fuente se busca **solo** en `fonts/` con el nombre de la familia que declara el fichero (una animación que pide `Roboto` necesita `fonts/Roboto.ttf` o `.otf`). Si falta, se usa la del dispositivo: el texto se ve, pero con otras medidas. Nunca se toman fuentes del sistema por nombre, para que se vea igual en todos los terminales.
- **Imágenes:** embebidas en el fichero, dentro del `.lottie`, o sueltas junto a él respetando la subcarpeta que declare el diseño (normalmente `images/`). Una que no se encuentre deja su capa sin pintar, sin romper nada.
- La reproducción se controla desde JavaScript con `playAnimation`, `pauseAnimation`, `resumeAnimation`, `stopAnimation`, `setAnimationFrame` y `getMaxFrameCount` (ver métodos de controles).

### Atributos para Botones (type="B")

| Atributo | Tipo | Descripción | Ejemplo |
|----------|------|-------------|---------|
| `img` | string | Icono del botón (PNG) | `img="ic_guardar.png"` |
| `floating` | bool | Botón flotante (FAB) | `floating="true"` |
| `top` | dim | Posición vertical (para FAB) | `top="1550p"` |
| `left` | dim | Posición horizontal (para FAB) | `left="850p"` |
| `behavior` | string | Comportamiento del botón | `behavior="move"` |
| `behavior-target` | string | Objetivo del comportamiento | `behavior-target="snackbar"` |
| `ripple-effect` | bool | Efecto ripple Material Design al pulsar | `ripple-effect="true"` |
| `button-option` | int | Valor numérico que devuelve `ui.msgBox(dataObject)` cuando se pulsa este botón. Permite diferenciar que botón pulsó el usuario en dialogos personalizados | `button-option="2"` |
| `hide-softinput` | bool | Ocultar el teclado virtual al pulsar el botón | `hide-softinput="false"` |

> **Botón de solo texto (sin caja).** Para un botón estilo `TextButton` de Material (solo texto/icono, sin fondo ni borde — "saltar", "atrás", "cancelar"), pon **`border-width="0"`** y un `bgcolor` igual al color de fondo de la pantalla. El botón se funde con el fondo y solo se ve el texto, manteniendo el área de toque. No hace falta envolverlo en un `<frame>` ni sustituirlo por un `type="L"`.

### Atributos para Password (type="X")

El tipo `X` es visualmente similar a `type="T"` pero los caracteres introducidos se muestran como asteriscos. Por defecto la clave se almacena codificada en **BASE64**, aunque su comportamiento puede modificarse con los siguientes atributos:

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `show-password-visibility-toggle` | `true` / `false` | Mostrar botón para ver/ocultar la clave |
| `hash-type` | `MD5` / `SHA256` | Algoritmo de hash para almacenar la clave. Si no se especifica, se usa BASE64 |
| `encode` | `HEX` / `hex` | Formato hexadecimal de la clave entrante. `HEX` (mayusculas) si la clave llega con letras en mayusculas; `hex` (minusculas) si llega con letras en minusculas. No se admite mezcla de mayusculas y minusculas en la misma clave |

```xml
<!-- Password básico con toggle de visibilidad (codificacion BASE64 por defecto) -->
<!-- En la coll Usuarios el nombre del campo DEBE ser "PWD". -->
<prop name="PWD" type="X" visible="0" fieldsize="100"
      show-password-visibility-toggle="true" />

<!-- Password con hash MD5, clave en hexadecimal mayusculas -->
<prop name="PWD" type="X" visible="0" fieldsize="100"
      hash-type="MD5" encode="HEX" />

<!-- Password con hash SHA256, clave en hexadecimal minusculas -->
<prop name="PWD" type="X" visible="0" fieldsize="100"
      hash-type="SHA256" encode="hex" />
```

### Atributos para Checkbox/Toggle (type="NC")

El tipo `NC` es un campo booleano (valor `0` o `1`) que puede presentarse con varios aspectos visuales según el atributo `check-type`. Almacena `1` cuando está marcado y `0` cuando no lo está.

```xml
<!-- Checkbox básico -->
<prop name="BAJA" type="NC" visible="1" labelwidth="8" fieldsize="6" />
```

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `check-type` | `toggle` / `radio` / `switch` | Aspecto visual del control. Si se omite o se pasa cualquier otro valor, se usa el CheckBox estándar (no hay un valor `check`/`checkbox` explicito, es el default). |
| `radio-group` | Número entero | Agrupa varios `NC` en un grupo de selección exclusiva. El framework se encarga de marcar/desmarcar automáticamente: solo puede estar marcado uno a la vez dentro del mismo grupo |
| `allow-radio-group-uncheck` | `true` / `false` | Permite desmarcar el elemento activo pulsando sobre el ya marcado. Sin este atributo, una vez marcado uno del grupo no puede desmarcarse |
| `track-color` | `#RRGGBB` | Color de la pista (barra de fondo) del toggle o switch |
| `thumb-color` | `#RRGGBB` | Color del pulgar (elemento deslizable) del toggle o switch |
| `check-color-checked` | `#RRGGBB` | Color del control cuando esta marcado |
| `track-color-checked` | `#RRGGBB` | Color de la pista cuando el control esta marcado |
| `thumb-color-checked` | `#RRGGBB` | Color del pulgar cuando el control esta marcado |
| `check-color-unchecked` | `#RRGGBB` | Color del control cuando no esta marcado |

#### Valores de check-type

| Valor | Descripción |
|-------|-------------|
| `checkbox` | Casilla de verificación clasica |
| `toggle` | Interruptor deslizable estilo Material Design |
| `switch` | Interruptor on/off |
| `radio` | Botón de opción circular. Usar con `radio-group` para selección exclusiva |

#### Uso como Radio Button

Todos los `NC` con el mismo `radio-group` forman un grupo de selección exclusiva. El framework marca y desmarca automáticamente los elementos del grupo. Distintos `radio-group` son independientes entre si. Un `NC` sin `radio-group` funciona de forma individual.

```xml
<!-- Grupo 1: tres opciones radio (solo una puede estar marcada) -->
<prop name="MAP_OPCION1" type="NC" check-type="radio" radio-group="1"
      title="Opción 1" labelwidth="20" width="100%" height="10%" lmargin="5p" />
<prop name="MAP_OPCION2" type="NC" check-type="radio" radio-group="1"
      title="Opción 2" labelwidth="20" width="100%" height="10%" lmargin="5p" />
<prop name="MAP_OPCION3" type="NC" check-type="radio" radio-group="1"
      title="Opción 3" labelwidth="20" width="100%" height="10%" lmargin="5p" />

<!-- Grupo 2: independiente del grupo 1 -->
<prop name="MAP_OPCION4" type="NC" check-type="radio" radio-group="2"
      title="Opción A" labelwidth="20" width="100%" height="10%" lmargin="5p" />
<prop name="MAP_OPCION5" type="NC" check-type="radio" radio-group="2"
      title="Opción B" labelwidth="20" width="100%" height="10%" lmargin="5p" />

<!-- Permite desmarcar el elemento ya seleccionado -->
<prop name="MAP_OPCION6" type="NC" check-type="radio" radio-group="1"
      allow-radio-group-uncheck="true"
      title="Opción con uncheck" labelwidth="20" width="100%" height="10%" lmargin="5p" />

<!-- NC individual sin grupo (switch) -->
<prop name="MAP_ACTIVO" type="NC" check-type="switch"
      title="Activo" labelwidth="20" width="100%" height="10%" lmargin="5p" />
```

> **Nota:** `check-type` puede mezclarse con `radio-group`. En el ejemplo anterior es valido tener un `toggle` y varios `radio` dentro del mismo `radio-group` — el framework los trata como grupo independientemente del aspecto visual.

### Atributos para Dibujo/Firma (type="DR")

El tipo `DR` (DRaw) permite dibujar en pantalla con el dedo. Es la forma recomendada para campos de tipo **firma** en XOne, mucho más personalizable que la firma antigua a pantalla completa que se realizaba con `type="IMG"` combinado con `readonly="false"`.

| Atributo | Valores | Descripción |
|----------|---------|-------------|
| `stroke-color` | `#RRGGBB` | Color de la linea del trazo |
| `stroke-width` | Número | Grosor en puntos de la linea del trazo |
| `apply-format-to-file` | `true` / `false` | `true`: la imagen guardada incluye los colores de fondo y trazo aplicados. `false`: la imagen guardada usa siempre trazo negro sobre fondo blanco |
| `bgcolor` | `#RRGGBB` | Color de fondo del control |
| `img` | `nombre.jpg` | Imagen de fondo del área de dibujo |
| `file-maxwidth` | Número | Ancho máximo en pixels de la imagen guardada |
| `file-maxheight` | Número | Alto máximo en pixels de la imagen guardada |
| `zoom-enable` | `true` / `false` | Permite hacer zoom con los dedos sobre el área de dibujo |
| `max-zoom` | Número | Factor de zoom máximo permitido (ej: `3` = hasta 3x) |

Los atributos `stroke-color`, `stroke-width` y `bgcolor` aceptan macros `##FLD_CAMPO##` para hacerlos dinámicos según datos del registro.

```xml
<!-- Firma básica -->
<prop name="FIRMACLIENTE" type="DR"
      stroke-width="4" stroke-color="#333333"
      bgcolor="#FFFFFF" img="FondoFirma.jpg"
      apply-format-to-file="true"
      file-maxwidth="800" file-maxheight="600"
      width="95%" height="30%"
      visible="1" />

<!-- Firma con parametros dinamicos desde campos MAP_ -->
<prop name="DIBUJO" type="DR"
      img="xone.png"
      stroke-width="##FLD_MAP_TAMANO_TRAZO##"
      stroke-color="##FLD_MAP_COLOR_TRAZO##"
      bgcolor="##FLD_MAP_COLOR_FONDO##"
      apply-format-to-file="true"
      width="90%" height="90%"
      zoom-enable="true" max-zoom="3" />
```

#### Funciones JavaScript para gestionar el dibujo

XOne proporciona métodos `ui` especificos para controlar el campo `DR`:

```javascript
// Guardar el dibujo/firma como fichero
ui.saveDrawing("FIRMACLIENTE");
// Guardar con nombre de fichero específico
ui.saveDrawing("MAP_FIRMA", "firma.png");

// Limpiar el área de dibujo en pantalla y vaciar el campo
ui.clearDrawing("FIRMACLIENTE");
self.FIRMACLIENTE = "";   // Vaciar también el campo que guarda la ruta del fichero

// Abrir el fichero guardado
ui.openFile("firma.png");
```

#### Handler para borrar la firma

```xml
<delfirma show-wait-dialog="false">
    <action name="runscript">
        <script language="javascript">
            ui.clearDrawing("FIRMACLIENTE");
            self.FIRMACLIENTE = "";
        </script>
    </action>
</delfirma>
```

| Atributo | Tipo | Descripción | Ejemplo |
|----------|------|-------------|---------|
#### Slider (viewmode="slider")

| Atributo | Tipo | Descripción | Ejemplo |
|----------|------|-------------|---------|
| `viewmode` | string | Tipo de slider: `slider`, `rounded-slider`, `range-slider` | `viewmode="slider"` |
| `orientation` | string | Orientación: `horizontal`, `vertical` | `orientation="horizontal"` |
| `min` | num | Valor mínimo | `min="0"` |
| `max` | num | Valor máximo | `max="100"` |
| `thumb-color` | color | Color del deslizador (pulgar) | `thumb-color="#FF00FF"` |
| `bar-color` | color | Color de la barra activa | `bar-color="#FF0000"` |
| `track-color` | color | Color de la pista (barra inactiva) | `track-color="#00FF00"` |
| `img-thumb` | string | Imagen personalizada para el pulgar | `img-thumb="ic_thumb.png"` |
| `notify-only-when-dropped` | bool | Solo notificar al soltar el pulgar | `notify-only-when-dropped="false"` |
| `updates` | string | Campo que se actualiza al cambiar el valor | `updates="MAP_VALOR"` |

#### Range Slider (viewmode="range-slider")

Permite seleccionar un rango entre dos valores. Requiere dos campos separados para el extremo inferior y superior.

| Atributo | Tipo | Descripción | Ejemplo |
|----------|------|-------------|---------|
| `from` | string | Nombre del campo donde se guarda el valor inferior del rango | `from="MAP_DESDE"` |
| `to` | string | Nombre del campo donde se guarda el valor superior del rango | `to="MAP_HASTA"` |
| `label-format` | string | Formato de la etiqueta del valor. Usar `##VALUE##` como placeholder | `label-format="##VALUE## €"` |
| `label-value-decimals` | int | Número de decimales en la etiqueta | `label-value-decimals="2"` |
| `step-size` | num | Incremento mínimo al mover el slider | `step-size="5"` |
| `img-thumb` | string | Imagen personalizada para el pulgar | `img-thumb="ic_thumb.png"` |

```xml
<!-- Range slider de precio -->
<prop name="MAP_PRECIO_RANGE" type="N"
      viewmode="range-slider"
      from="MAP_PRECIO_DESDE" to="MAP_PRECIO_HASTA"
      min="0" max="1000"
      step-size="10"
      label-format="##VALUE## €"
      label-value-decimals="0"
      thumb-color="#FF00FF" track-color="#FF0000" bar-color="#00FF00"
      width="80%" height="120p" />
<prop name="MAP_PRECIO_DESDE" type="N2" visible="0" />
<prop name="MAP_PRECIO_HASTA" type="N2" visible="0" />
```

#### Rounded Slider (viewmode="rounded-slider")

Slider circular (tipo dial).

| Atributo | Tipo | Descripción | Ejemplo |
|----------|------|-------------|---------|
| `bar-width` | num | Grosor de la barra | `bar-width="1"` |
| `img-thumb` | string | Imagen personalizada para el pulgar | `img-thumb="ic_thumb.png"` |

#### Progress Bar (viewmode="progress-bar" / viewmode="circular-progress-bar")

| Atributo | Tipo | Descripción | Ejemplo |
|----------|------|-------------|---------|
| `viewmode` | string | `progress-bar` (lineal) o `circular-progress-bar` (circular) | `viewmode="progress-bar"` |
| `min` | num | Valor mínimo | `min="0"` |
| `max` | num | Valor máximo | `max="100"` |
| `bar-color` | color o lista | Color de la barra activa. Acepta varios colores separados por coma para gradiente | `bar-color="#FF0000,#00FF00"` |
| `track-color` | color | Color de la pista | `track-color="#CCCCCC"` |
| `track-thickness` | dim | Grosor de la pista | `track-thickness="20p"` |
| `indeterminate` | bool | Modo indeterminado (animación continua sin valor concreto) | `indeterminate="true"` |
| `indeterminate-animation` | string | Tipo de animación indeterminada: `contiguous` | `indeterminate-animation="contiguous"` |
| `clockwise` | bool | Sentido del progreso circular (solo `circular-progress-bar`) | `clockwise="false"` |

```xml
<!-- Barra de progreso con gradiente e indeterminado -->
<prop name="MAP_PROGRESO" type="N"
      viewmode="progress-bar"
      min="0" max="100"
      indeterminate="true"
      indeterminate-animation="contiguous"
      bar-color="#FF0000,#00FFFF,#0000FF"
      track-color="#CCCCCC"
      track-thickness="20p"
      width="90%" />

<!-- Progreso circular -->
<prop name="MAP_PROGRESO_CIRC" type="N"
      viewmode="circular-progress-bar"
      min="0" max="100"
      indeterminate="true"
      bar-color="#FF0000"
      track-color="#CCCCCC"
      width="200p" lmargin="33%" />
```

### Atributos para Contents (type="Z")

| Atributo | Tipo | Descripción | Ejemplo |
|----------|------|-------------|---------|
| `contents` | string | Nombre del content (con @) | `contents="@MiContenido"` |
| `viewmode` | string | Modo de visualizacion (ver tabla abajo) | `viewmode="recyclerview"` |
| `edit-inrow` | bool | Edición en linea dentro de la lista | `edit-inrow="true"` |
| `show-no-data` | bool | Mostrar mensaje cuando no hay datos | `show-no-data="true"` |
| `show-loading` | bool | Mostrar indicador de carga | `show-loading="true"` |
| `start-from-bottom` | bool | Scroll anclado al final de la lista, estilo chat. Tiene preferencia sobre el mismo atributo en la `<coll>` | `start-from-bottom="true"` |
| `divider-height` | int | Alto (grosor) del separador entre ítems de la lista. En listas expandibles el default es `4` | `divider-height="2"` |
| `divider-color` | color | Color del separador entre ítems de la lista | `divider-color="#DDDDDD"` |
| `divider-background` | string | Imagen (ruta de recurso) usada como separador; tiene prioridad sobre `divider-color` | `divider-background="linea.png"` |
| `classid` | string | Clase del control (para charts) | `classid="XOneCharts"` |
| `show-user-location` | bool | Mostrar ubicación del usuario (mapas) | `show-user-location="true"` |
| `zoom-to-pois` | bool | Hacer zoom a marcadores (mapas) | `zoom-to-pois="true"` |
| `onmapclicked` | string | Evento click en mapa | `onmapclicked="onMapClicked(e);"` |
| `onmapready` | string | Evento mapa listo | `onmapready="onMapReady(e);"` |
| `gallery-columns` | int | Columnas en modo gridview | `gallery-columns="3"` |

---

## 4. Tipos de Propiedades (type) - Tabla Completa

### Tipos de Datos Básicos

| Type | Nombre | Descripción | SQLite | Ejemplo de Uso |
|------|--------|-------------|--------|----------------|
| `T` | Texto | Texto simple editable | TEXT | Nombres, descripciones, direcciones |
| `L` | Texto Label | Texto solo lectura (label), NO genera columna en BD — forma preferida. Muestra el `title`; sin `title`, usa el valor del campo como fallback | - | Títulos, etiquetas, valores calculados mostrados |
| `TL` | Texto Label (alias legacy) | Alias legacy de `L`: mismo control, NO genera columna en BD | - | Equivalente a `type="L"` |
| `O` | Objeto JS | Campo para almacenar cualquier objeto JavaScript (función, array, objeto). NO genera columna en BD ni persiste. Se usa para pasar callbacks entre colecciones | - | Callbacks en diálogos asíncronos (`type="O"`) |
| `N` | Numérico | Número entero | INTEGER | IDs, cantidades, contadores |
| `N2` | Numérico 2 dec | Número con 2 decimales | REAL | Precios, importes, medidas |
| `N3` | Numérico 3 dec | Número con 3 decimales | REAL | Pesos, medidas de precisión |
| `N4` | Numérico 4 dec | Número con 4 decimales | REAL | Valores cientificos, tasas de cambio |
| `N5` | Numérico 5 dec | Número con 5 decimales | REAL | Coordenadas GPS, valores de alta precisión |
| `N6` | Numérico 6 dec | Número con 6 decimales | REAL | Coordenadas geograficas de precisión |
| `X` | Password | Campo de contrasena (oculto) | TEXT | Login, PIN |
| `D` | Fecha | Selector de fecha | TEXT | Fechas de nacimiento, vencimientos |
| `DT` | Fecha y Hora | Selector de fecha + hora | TEXT | Timestamps, registros de eventos |
| `TT` | Hora | Selector de hora (solo HH:MM). **Requiere `mask="Hh#:#Mm"`** | TEXT | Horas de cita, hora de inicio/fin |
| `B` | Botón | Botón de acción, NO genera columna en BD | - | Botones de navegación, acciones |
| `IMG` | Imagen | Campo de imagen | TEXT | Fotos, logos, iconos |
| `NC` | Checkbox | Casilla de verificación / toggle | INTEGER | Opciones si/no, estados activo/inactivo |
| `Z` | Content Zone | Contenedor de colecciones embebidas, NO genera columna en BD | - | Listas, gráficos, mapas |
| `PH` | Foto | Campo de fotografía (camara) | TEXT | Capturas de camara |
| `VD` | Video | Campo de video | TEXT | Grabaciones de video |
| `DR` | Dibujo/Firma | Control para capturar firmas manuscritas o dibujos a mano alzada | TEXT | Firmas, anotaciones, dibujos |
| `THTML` | Texto HTML | Campo que muestra contenido HTML enriquecido formateado, NO genera columna en BD | - | Descripciones ricas, contenido web formateado |

### Tipos que NO se Persisten en Base de Datos

Los siguientes tipos son puramente de UI y NO generan columna en la tabla SQLite:

- `B` — Botón
- `Z` — Content Zone
- `L` — Texto Label (etiqueta de solo lectura) — forma preferida
- `TL` — alias legacy de `L` (mismo control, no genera columna en BD)
- `THTML` — Texto HTML enriquecido

### Tipos con ViewModes Especiales

| Type Base | ViewMode | Resultado |
|-----------|----------|-----------|
| `N` | `slider` | Slider numérico horizontal/vertical |
| `N` | `progress-bar` | Barra de progreso |
| `N` | `circular-progress-bar` | Progreso circular |
| `N` | `range-slider` | Selector de rango numérico |
| `N` | `seekbar` | Barra deslizante tipo seekbar |
| `N` | `stepper` | Control compacto `−` / `+` para valores enteros (atributos `min`/`max`/`step-size`/`wrap`/`bar-color`/`forecolor`; auto-repeat 80 ms en long-press; API JS `getValue`/`setValue`/`setMin`/`setMax`/`setStepSize`) |
| `N` | `navbar` | Barra de navegación Material 3 con indicador "pill" deslizante; el valor `N` es el índice del destino activo (toque → escribe y dispara `onchange`; cambio por código + refresco → desliza). Destinos inline: `nav-titles`/`nav-icons` separados por barra vertical. Atributos `pill-color`, `pill-text-color`/`forecolor`, `nav-text-color`, `bar-color`/`bgcolor`, `label-visibility` (always/selected/never), `animation-duration`, `pill-corner-radius`, `nav-icon-size`, `disableedit`/`locked` (deja de ser tocable, queda como indicador). Índice acotado a `[0, nº−1]`. API JS `getValue`/`setValue`/`getItemCount` |
| `T` | `html` | Texto con formato HTML |
| `T` | `markdown` | Renderiza el contenido del campo como Markdown CommonMark base (cabeceras, enfasis, listas, enlaces, imágenes, blockquotes, código inline/bloque, reglas horizontales). NO soporta tablas/strikethrough/task lists/HTML embebido. Sin atributos propios. |
| `T` / `N` | `otp` | Entrada de códigos OTP con cajas individuales, auto-avance, backspace inverso y paste distribuido. Atributos `digits` (default 6), `secret`, `auto-submit`, `allow-letters`, `box-size`, `box-spacing`, `box-color`, `box-color-focus`, `forecolor`. API JS `getOtpValue`/`clearOtp`/`focusOtp`. Valor concatenado sin separadores. |
| `Z` | `recyclerview` | Lista con reciclaje de vistas (recomendado) |
| `Z` | `gridview` | Cuadricula de elementos |
| `Z` | `slideview` | Carrusel deslizable |
| `Z` | `coverflow` | Variante de `slideview` con efecto Cover Flow estilo iTunes (atributos `cover-flow-min-scale` default 0.75, `cover-flow-min-alpha` default 0.6, `cover-flow-rotation` grados — para 3D real usar 25–45) |
| `Z` | `kanban` | Tablero estilo Trello/Jira con drag&drop entre columnas (atributos obligatorios `kanban-column-field`, `kanban-columns`; opcionales `kanban-column-titles`, `kanban-column-colors`, `kanban-column-width`, `kanban-card-title-field`, `kanban-card-subtitle-field`, `kanban-card-bgcolor`, `draggable`). Al soltar una card, el framework asigna `kanban-column-field` al valor de la columna destino y persiste. |
| `Z` | `chipsview` | Conjunto de chips Material (pastillas) con wrap. Cada fila de un `<contents>` es un chip; en la colección del contents, la prop con `chip-value="true"` da el texto (opcional `chip-close-enabled`). Para chips al vuelo: colección `volatile`+`manual-load`+`loadall` rellenada por JS con `createObject`+`addItem` (no `save`). **Todos los chips son seleccionables (toggle)** → sirven como *filter chips*: `onitemschanged="h(e)"` entrega los marcados en `e.values` (textos) y `e.ids`; `onitemremoved="h(e)"` al cerrar uno (con `chip-close-enabled`), `e.value`/`e.id`; o `ui.getView(self).getControl("NOMBRE").getCheckedValues()` → `[{id,value}]`. |
| `Z` | `expanview` | Acordeon expandible |
| `Z` | `mapview` | Mapa Google Maps |
| `Z` | `openstreetmap` | Mapa OpenStreetMap |
| `Z` | `maplibre` | Mapa MapLibre (estilos vectoriales) |
| `Z` | `barchart` | Gráfico de barras |
| `Z` | `linechart` | Gráfico de lineas |
| `Z` | `piechart` | Gráfico circular/pastel |
| `Z` | `areachart` | Gráfico de áreas |
| `Z` | `picturemap` | Mapa con imágenes / mosaico de fotos |
| `Z` | `calendarview` | Vista de calendario (semanal/mensual) |
| `Z` | `3dbarchart` | Gráfico de barras 3D |
| `Z` | `piechart2` | Gráfico circular diseño alternativo |
| `Z` | `timeserieschart` | Gráfico de series temporales |
| `Z` | `slidingbarchart` | Gráfico de barras con navegación horizontal |
| `Z` | `xylinechart` | Gráfico de lineas XY (dos ejes) |

---


### Tipos D / DT / TT — Detalle, atributos y pickers

| Tipo | Formato visualizado | Pickers asociados | Notas |
|------|---------------------|-------------------|-------|
| `D`  | Fecha tradicional `DD/MM/AAAA` | DatePicker (icono de calendario) | El más común |
| `DT` | Fecha + hora `DD/MM/AAAA HH:MM` | DatePicker + TimePicker | Para timestamps con hora |
| `TT` | Solo hora `HH:MM` | TimePicker (icono de reloj) | **`mask="Hh#:#Mm"` es obligatoria** o el campo no se ve |

**Ejemplos:**

```xml
<!-- type=D -->
<prop name="FECHA" type="D" visible="1" title="FECHA"
      labelwidth="6" fieldsize="7" onchange="Refresh255" />

<!-- type=DT con icono custom y formato -->
<prop name="MAP_TYPEDT" type="DT" title="Fecha y hora"
      date-format="dd/MM/yyyy"
      time-format="HH:mm"
      locale="esES"
      time-interval="2"
      img-date="logo.png"
      width="100%" height="10%"
      img-date-width="96p"  img-date-height="96p"
      img-time-width="96p"  img-time-height="96p" />

<!-- type=TT — la mask es OBLIGATORIA -->
<prop name="MAP_TYPETT" type="TT" title="Hora"
      mask="Hh#:#Mm"
      time-interval="2"
      width="100%"
      img-time-width="96p" img-time-height="96p" />
```

**Atributos relacionados:**

| Atributo | Descripción |
|----------|-------------|
| `title` | Etiqueta visible del campo |
| `date-format` | Formato visualizado de fecha (ej. `dd/MM/yyyy`). Modifica el formato por defecto |
| `time-format` | Formato visualizado de hora (ej. `HH:mm`). Solo en DT/TT |
| `mask` | Mascara de entrada. **Obligatoria en TT**: `mask="Hh#:#Mm"` |
| `locale` | Locale para nombres de mes/día (`esES`, `enUS`, ...) |
| `time-interval` | Intervalo de minutos en TimePicker (ej. `2` = saltos de 2 min) |
| `img-date` | Imagen del icono del DatePicker |
| `img-date-width` / `img-date-height` | Tamaño del icono de fecha |
| `img-time-width` / `img-time-height` | Tamaño del icono de hora |
| `ios-datepicker-mode` | Modo iOS: `inline` / `wheels` / `compact` |
| `bgcolor` / `forecolor` | Colores de fondo / texto |
| `width` / `height` | Dimensiones |
| `lmargin`, `rmargin`, `tmargin`, `bmargin` | Margenes |
| `newline` | `true`/`false`. Salto de linea |
| `fontsize` | Tamaño de fuente |
| `labelwidth` | Ancho de la etiqueta. `0` = sin etiqueta |
| `locked` | Bloquear el campo |

**Funciones JS asociadas (`ui.showDatePicker`, `ui.showTimePicker`):**

```javascript
// Inicializar valores en before-edit
function doBeforeEdit() {
    self.MAP_TYPEDT = new Date();
    self.MAP_TYPED  = "2023-07-14 00:00:00";
}

// DatePicker que escribe en un prop (modo target)
function showDatePicker() {
    ui.showDatePicker({
        targetProperty: "MAP_TYPED"
    });
}

// DatePicker con callback (sin targetProperty)
function showDatePickerCallback() {
    ui.showDatePicker({
        onDateSet: function(nYear, nMonth, nDay) {
            ui.showToast("Dia: " + nDay + " Mes: " + nMonth + " Anio: " + nYear);
        }
    });
}

// TimePicker pre-rellenado con la hora del prop
function showTimePicker() {
    var horaSpliteada = self.MAP_TYPETT.split(":");
    ui.showTimePicker({
        targetProperty: "MAP_TYPETT",
        initialHour:    horaSpliteada[0],
        initialMinute:  horaSpliteada[1],
        is24HoursMode:  true,
        title:          "Seleccione el tiempo"
    });
}

// Fecha actual
function getCurrentDate() {
    ui.showToast(new Date().toUTCString());
}
```

> **No confundir con cronometros.** Los pickers son para SELECCIONAR una fecha/hora. Para mostrar un reloj/cronometro continuo en pantalla la API es `control.startChronometer({fromDate, dateFormat})` y `control.stopChronometer()`. Ver `xone-javascript-patterns.md` sección 8.6.


**Anterior:** [a - Estructura](xone-xml-ui-a-estructura.md) · **Siguiente:** [c - Contents y eventos](xone-xml-ui-c-contents-eventos.md) · **Índice:** [xone-xml-ui-reference.md](xone-xml-ui-reference.md)