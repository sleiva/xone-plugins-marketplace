# XML/UI — Nodo `<prop>` y tipos de propiedad

Sub-archivo del [Tópico 02 - Guía Completa de XML/UI](02-xml-ui-complete-guide.md). Cubre el nodo `<prop>`: tabla autoritativa de tipos, atributos comunes, sistema de visibilidad, comportamiento, bordes, condiciones (`disablevisible`/`disableedit`) y especificación detallada de cada tipo en §5.9.

## Tabla de Contenidos

- [5.1 Tabla completa de tipos](#51-tabla-completa-de-tipos)
- [5.2 Atributos comunes](#52-atributos-comunes)
- [5.3 Sistema de visibilidad (`visible`)](#53-sistema-de-visibilidad-visible)
- [5.4 Dimensiones y margenes](#54-dimensiones-y-margenes)
- [5.5 Estilos inline](#55-estilos-inline)
- [5.6 Comportamiento](#56-comportamiento)
- [5.7 Bordes](#57-bordes)
- [5.8 Condiciones (`disablevisible`, `disableedit`)](#58-condiciones-disablevisible-disableedit)
- [5.9 Props por tipo (T, L, N, B, NC, D/DT/TT, IMG, PH, VD, Z, viewmodes, combo, WEB, slider, stepper, OTP, navbar, Markdown, X, AT, THTML, DR, mapcol, contextual-search, onchange, updates, formula)](#59-props-por-tipo)
- [5.10 Buenas prácticas](#510-buenas-practicas)
- [5.11 Errores comunes](#511-errores-comunes)

---

## 5. Nodo prop - Propiedades/Campos

El nodo `<prop>` es el elemento más versátil de XOne. Un `<prop>` puede representar un campo de texto, un botón, una imagen, un mapa, una lista, un checkbox y muchos otros controles.

### 5.1 Tabla completa de tipos

Lista autoritativa de tipos de `<prop>` reconocidos por XOne (constantes `PROP_TYPE_*` en `Utils.java`). El sufijo numérico en `N` y `TN` indica los decimales visibles en el control (`N2` = 2 decimales, ..., `N6` = 6 decimales).

| Tipo | Nombre | Descripción | Equivalente web |
|------|--------|-------------|-----------------|
| `T` | Texto | Campo de texto editable | `<input type="text">` |
| `L` | Label | Texto de solo lectura (etiqueta) — forma preferida | `<span>`, `<label>` |
| `TL` | Label (alias legacy) | Alias legacy de `L`: se renderiza como label. | `<span>`, `<label>` |
| `THTML` | Texto HTML enriquecido | Muestra contenido HTML formateado con etiquetas | - |
| `N` | Numérico | Número entero | `<input type="number">` |
| `N2` | Numérico 2 decimales | Número con 2 decimales (precios) | - |
| `N3` | Numérico 3 decimales | Número con 3 decimales | - |
| `N4` | Numérico 4 decimales | Número con 4 decimales | - |
| `N5` | Numérico 5 decimales | Número con 5 decimales (coordenadas) | - |
| `N6` | Numérico 6 decimales | Número con 6 decimales | - |
| `TN` | Número-Texto | Número almacenado como texto (entero) | - |
| `TN2` | Número-Texto 2 decimales | Número almacenado como texto con 2 decimales | - |
| `TN3` | Número-Texto 3 decimales | Número almacenado como texto con 3 decimales | - |
| `TN4` | Número-Texto 4 decimales | Número almacenado como texto con 4 decimales | - |
| `TN5` | Número-Texto 5 decimales | Número almacenado como texto con 5 decimales | - |
| `TN6` | Número-Texto 6 decimales | Número almacenado como texto con 6 decimales | - |
| `B` | Botón | Botón de acción | `<button>` |
| `NC` | Checkbox/Toggle/Radio/Switch | Booleano con varias apariencias según `check-type` (`toggle`/`radio`/`switch` o default checkbox) | `<input type="checkbox">` / `<input type="radio">` |
| `D` | Fecha | Selector de fecha | `<input type="date">` |
| `DT` | Fecha y hora | Selector de fecha y hora | `<input type="datetime-local">` |
| `TT` | Hora | Selector de hora | `<input type="time">` |
| `X` | Password | Campo de contrasena enmascarado | `<input type="password">` |
| `IMG` | Imagen | Visualizador de imagen referenciada | `<img>` |
| `PH` | Foto | Captura de foto con camara | - |
| `VD` | Video/Camara/Escaner | Camara, video o escaner QR/barcode | `<video>` |
| `DR` | Dibujo/Firma | Control para capturar firmas o dibujos a mano alzada | - |
| `Z` | Contenedor de lista | Lista embebida / grid / mapa (`viewmode="mapview"`) / kanban / slider / etc. según `viewmode` | `<table>`, `<ul>` |
| `WEB` | WebView | Contenido web embebido | `<iframe>` |
| `AT` | Adjunto | Campo de archivo adjunto | `<input type="file">` |
| `O` | DataObject | Sub-objeto JavaScript (no persiste en BD) | - |

> **Combos/selectores**: NO tienen un type propio. Se implementan con `type="T"` (o `type="N"`) más los atributos `mapcol` y `mapfld` que apuntan a la coleccion de origen y al campo de enlace.
>
> **Mapas**: se implementan con `type="Z" viewmode="mapview"` (Google Maps), `"maplibre"` u `"openstreetmap"`. No existe un `type="M"`.
>
> **Sliders, progress bars, stepper, OTP, navbar, kanban, coverflow, markdown**: son **viewmodes** sobre los tipos `T`, `N` o `Z`. No son types propios. Ver §5.9 (atributos por tipo) y la guía de atributos del tópico 07.

### 5.2 Atributos comunes

Estos atributos aplican a todos los tipos de `<prop>`:

| Atributo | Tipo | Requerido | Descripción |
|----------|------|-----------|-------------|
| `name` | string | **Si** | Nombre único del campo. **El ambito de unicidad es la `<coll>` ENTERA**, no el `<group>` o `<frame>` que lo contiene: no pueden existir dos props con el mismo `name` en cualquier parte de la misma coll, ni siquiera en `<group>` o `<frame>` distintos. Convencion: `MAP_NOMBRE` para campos de UI, `NOMBRE` para campos de BD. |
| `type` | string | **Si** | Tipo del control (ver tabla anterior). |
| `title` | string | No | Etiqueta/texto mostrado junto al campo. |
| `visible` | integer | No | Mascara de bits de visibilidad (ver sección 5.3). Default: `0`. |
| `width` | dimensión | No | Ancho del control (`"100%"`, `"200p"`, etc). |
| `height` | dimensión | No | Alto del control. |
| `class` | string | No | Clase CSS para estilizar (ver [Tópico 04](./04-css-styling-guide.md)). |

### 5.3 Sistema de visibilidad (`visible`)

El atributo `visible` define **en que contextos de la UI se pinta el campo**. Es una decisión estática tomada en tiempo de diseño — **no se puede cambiar en tiempo de ejecución**, ni por script, ni por eventos, ni por condiciones. Si un campo tiene `visible="0"`, no existe en pantalla en ningun momento.

Funciona como un bitmask donde cada bit representa un contexto de visualizacion:

| Bit | Valor decimal | Contexto |
|-----|---------------|----------|
| Bit 0 | 1 | Visible en modo **edición** (formulario individual) |
| Bit 1 | 2 | Visible en modo **lista** (vista de registros) |
| Bit 2 | 4 | Visible en **content** (lista embebida `type="Z"`) |
| Bit 3 | 8 | Visible en **combo** (desplegable) |

Cualquier combinacion de bits es valida. Las más usadas:

| Valor | Contextos | Uso típico |
|-------|-----------|------------|
| `0` | Ninguno | Campo puramente interno — solo existe para lógica |
| `1` | Edición | Solo en formulario individual |
| `2` | Lista | Solo en vista de registros |
| `3` | Edición + Lista | En formulario y en lista |
| `4` | Content | Solo en listas embebidas |
| `7` | Edición + Lista + Content | **El más habitual** |
| `8` | Combo | Solo visible en desplegables |
| `15` | Todos | Edición + Lista + Content + Combo |

```xml
<!-- Campo ID oculto, solo para lógica -->

<!-- Nombre visible en todos los contextos principales -->
<prop name="NOMBRE" type="T" visible="7" title="Nombre" />

<!-- Descripción solo en el formulario de detalle -->
<prop name="DESCRIPCION" type="T" visible="1" title="Descripción detallada" />

<!-- Resumen solo en la vista de lista -->
<prop name="MAP_RESUMEN" type="L" visible="2" />

<!-- Campo para filas de content embebido -->
<prop name="MAP_NOMBRE_GRID" type="T" visible="4" />

<!-- Campo que también debe aparecer en un combo -->
<prop name="NOMBRE" type="T" visible="15" />
```

> **Diferencia con `disablevisible`:** `visible` es estático — decide si el campo existe en pantalla en ese contexto. `disablevisible` es dinámico — el campo existe pero se muestra u oculta según el valor de otro campo en tiempo de ejecución. Ver sección 5.8.

### 5.4 Dimensiones y margenes

```xml
<prop name="CAMPO" type="T"
      width="90%"           <!-- Ancho -->
      height="56p"          <!-- Alto -->
      tmargin="20p"         <!-- Margen superior -->
      bmargin="10p"         <!-- Margen inferior -->
      lmargin="5%"          <!-- Margen izquierdo -->
      rmargin="5%"          <!-- Margen derecho -->
      tpadding="10p"        <!-- Padding superior -->
      bpadding="10p"        <!-- Padding inferior -->
      lpadding="10p"        <!-- Padding izquierdo -->
      rpadding="10p"        <!-- Padding derecho -->
/>
```

### 5.5 Estilos inline

| Atributo | Tipo | Descripción | Ejemplo |
|----------|------|-------------|---------|
| `class` | string | Clase CSS (pueden ser multiples separadas por espacio) | `class="mClassT alineacion color"` |
| `forecolor` | color | Color del texto | `forecolor="#333333"` |
| `bgcolor` | color | Color de fondo | `bgcolor="#FFFFFF"` |
| `fontsize` | integer | Tamaño de fuente | `fontsize="14"` |
| `fontbold` | boolean | Texto en negrita | `fontbold="true"` |
| `fontname` | string | Archivo de fuente (.ttf) | `fontname="Roboto-Bold.ttf"` |
| `align` | string | Posición del prop dentro del frame contenedor. Mismos valores que en `<frame>` y `<group>`. Ver sección 4.2 del sub-archivo 02a | `align="center\|center"` |
| `text-align` | string | Alineacion del texto **dentro** del campo editable | `text-align="center"` |
| `label-align` | string | Alineacion de la etiqueta del prop | `label-align="left"` |

Ejemplo con multiples clases CSS (del wiki, EspecialBasicos.xne):

```xml
<prop name="MAP_EJEMPLO3" class="mClassT alineacion color"
      type="T" title="TRES CSS" />
```

### 5.6 Comportamiento

| Atributo | Tipo | Descripción | Ejemplo |
|----------|------|-------------|---------|
| `locked` | boolean | **Bloquea la UI de edición** del control (no editable visualmente). Versión estática de `disableedit` (fórmula). **No** afecta a la persistencia: si el valor cambia desde JS, sí se graba. Para impedir que el campo se grabe en BD usar `readonly="true"` (ver tópico 07 §4.3). | `locked="true"` |
| `readonly` | boolean | **Excluye el campo del UPDATE en BD**. NO bloquea la UI (los controles T/N/NC/spinner no lo leen). Excepción: en `type="VD"` actúa como flag UI (`true`=reproducir, `false`=capturar). Para bloquear edición visual usar `locked`. | `readonly="true"` |
| `newline` | boolean | Por defecto `true` (nueva línea). Si es `false`, el prop se coloca a la derecha del anterior en la misma línea. Ver sección 4.3b del sub-archivo 02a para detalle completo | `newline="false"` |
| `tooltip` | string | Texto de ayuda (placeholder) | `tooltip="Escriba aquí..."` |
| `floating-tooltip` | boolean | El tooltip flota sobre el campo al escribir | `floating-tooltip="true"` |
| `labelwidth` | integer | Ancho de la etiqueta. `0` = sin etiqueta | `labelwidth="0"` |
| `labelbox` | boolean | Muestra caja alrededor de la etiqueta | `labelbox="false"` |
| `label-wrap` | boolean | La etiqueta puede ocupar varias lineas | `label-wrap="true"` |
| `lines` | integer | Número de lineas de texto | `lines="3"` |
| `fixed-lines` | boolean | Fija el número de lineas (no crece) | `fixed-lines="true"` |
| `size` | integer | Tamaño de la columna en la base de datos (en caracteres). XOneStudio lo usa para crear la columna con ese tamaño. Si se combina con `fixed-text="true"`, además impide escribir más caracteres de los indicados en UI | `size="150"` |
| `fieldsize` | integer | Ancho visual de la caja del campo, calculado como: ancho de carácter x valor. **En proyectos nuevos no es necesario — usar `width` en su lugar**, ya que `width` tiene prioridad sobre `fieldsize` cuando ambos están presentes | `fieldsize="100"` |
| `phone` | boolean | Indica que el campo es un número de telefono (activa enlace telefonico) | `phone="true"` |
| `input-type` | string | Tipo de teclado en dispositivo (valores exactos): `text`, `numeric`, `numeric_unsigned`, `decimal`, `phone`, `datetime`, `email`, `username`, `uri`, `password`, `none`. `number`/`url` NO existen → usar `numeric`/`uri` (un valor no reconocido lanza error) | `input-type="numeric"` |
| `scale-type` | string | Tipo de escalado para imágenes: `center_crop`, `fit_center`, `center_inside`, `fit_xy` | `scale-type="center_crop"` |
| `edit-inrow` | boolean | Permite la edición directa dentro de las filas de una lista (type="Z") | `edit-inrow="true"` |
| `show-no-data` | string/boolean | Texto o indicador a mostrar cuando no hay datos en la lista | `show-no-data="true"` |
| `start-from-bottom` | boolean | El scroll de la lista (`type="Z"`) arranca y se mantiene anclado al último elemento (estilo chat). Declarado aquí tiene preferencia sobre el mismo atributo en la `<coll>` | `start-from-bottom="true"` |
| `divider-height` | integer | Alto (grosor) del separador entre ítems de la lista (`type="Z"`). En listas expandibles el default es `4` | `divider-height="2"` |
| `divider-color` | color | Color del separador entre ítems de la lista (`type="Z"`) | `divider-color="#DDDDDD"` |
| `divider-background` | string | Imagen (ruta de recurso) usada como separador entre ítems; tiene prioridad sobre `divider-color` | `divider-background="linea.png"` |
| `floating` | boolean | El prop se superpone sobre el layout, similar al frame flotante. Se posiciona con `top` y `left` | `floating="true"` |
| `keep-aspect-ratio` | boolean | Mantiene la proporcion original de la imagen al redimensionar | `keep-aspect-ratio="true"` |
| `updates` | string | Al cambiar este campo, propaga el cambio al campo indicado en otra coleccion contents | `updates="DESCRIPCION"` |
| `fixed-text` | boolean | Si es `true`, combinado con `size`, impide introducir más caracteres del limite indicado en UI | `fixed-text="true"` |
| `min-height` | dimensión | Alto mínimo del control. Útil para campos de texto multilinea | `min-height="120p"` |
| `ripple-effect` | boolean | Activa el efecto ripple de Material Design al pulsar | `ripple-effect="true"` |

**Atributos de imagen en botones:**

| Atributo | Descripción |
|----------|-------------|
| `img` | Imagen del botón en estado normal |
| `img-sel` | Imagen del botón al pulsarlo |
| `img-disabled` | Imagen cuando el botón esta deshabilitado |
| `img-delete` | Imagen del botón de borrar/limpiar en campos editables |
| `img-search` | Imagen del botón de busqueda (lupa) en campos mapeados |
| `img-spinner` | Imagen del desplegable combo con `showinline="true"` |
| `img-width` | Ancho del icono de imagen |
| `img-height` | Alto del icono de imagen |
| `img-date` | Imagen del selector de fecha |
| `img-time` | Imagen del selector de hora |
| `img-att` | Imagen del botón de adjuntar archivos |

### 5.7 Bordes

| Atributo | Tipo | Descripción | Ejemplo |
|----------|------|-------------|---------|
| `border` | boolean | Muestra borde | `border="false"` |
| `border-width` | integer | Ancho del borde | `border-width="2"` |
| `border-corner-radius` | integer | Radio de esquinas redondeadas | `border-corner-radius="10"` |
| `border-corner-radius-top-left` | integer | Radio esquina superior izquierda | `border-corner-radius-top-left="50"` |
| `text-border` | boolean | Borde solo en la zona de texto | `text-border="true"` |
| `text-border-bottom` | boolean | Solo borde inferior en el texto | `text-border-bottom="true"` |

### 5.8 Condiciones (`disablevisible`, `disableedit`)

#### disablevisible — Visibilidad condicional en tiempo de ejecución

El atributo `disablevisible` oculta el elemento en tiempo de ejecución cuando se cumple la condición especificada. A diferencia de `visible`, este si responde a los valores del objeto en pantalla. El campo referenciado en la condición debe existir en la misma coleccion.

Funciona en `<group>`, `<frame>` y `<prop>`.

**Formato de la condición:** `CAMPO=VALOR`, `CAMPO>VALOR`, `CAMPO<VALOR`

```xml
<!-- Oculta el prop cuando MAP_TIPO vale 0 -->
<prop name="MAP_DETALLE" type="T" visible="1"
      disablevisible="MAP_TIPO=0" />

<!-- Oculta el frame entero cuando ESTADO vale 2 -->
<frame name="frmExtra"
       disablevisible="ESTADO=2" />

<!-- Oculta el grupo entero cuando un campo es 0 -->
<group name="GrpOpciones" id="3"
       disablevisible="MAP_MOSTRAR=0" />
```

**Refresco del disablevisible por script:**

Cuando el campo referenciado en la condición cambia por código, hay que refrescar para que `disablevisible` se reevalúe. Hay dos formas:

```javascript
// Refrescar un prop específico
ui.refresh("MAP_DETALLE");

// Refrescar varios props — refresh()/refreshValue() aceptan varargs:
// argumentos sueltos, un string con comas, o un array (equivalentes)
ui.refresh("MAP_DETALLE", "MAP_EXTRA");     // varios argumentos
ui.refresh("MAP_DETALLE,MAP_EXTRA");        // string separado por comas
ui.refresh(["MAP_DETALLE", "MAP_EXTRA"]);   // array — útil para listas dinámicas

// Refrescar toda la pantalla (sin argumentos)
ui.refresh();

// Con referencia explicita a la vista — util en callbacks o eventos
var view = ui.getView(self);
view.refresh("MAP_DETALLE");   // prop específico
view.refresh();                // toda la pantalla
```

> **Listas dinámicas:** como `refresh`/`refreshValue` aceptan un **array**, cuando los campos a refrescar son condicionales conviene acumularlos y refrescar una sola vez — `let a=[]; if (cond) a.push("MAP_X"); if (a.length) ui.refresh(a);`.

> El `disablevisible` también se reevalua automáticamente si el campo referenciado tiene `onchange="refresh"` en el XML — en ese caso no hace falta llamar a `ui.refresh()` por script.

#### disableedit — Deshabilitacion condicional

El atributo `disableedit` deshabilita la edición del elemento si se cumple la condición. El campo sigue siendo visible pero el usuario no puede modificarlo.

```xml
<!-- Campo que se deshabilita condicionalmente -->
<prop name="MAP_TEXT3" type="T"
      title="Campo bloqueado condicionalmente"
      disableedit="MAP_CHECK1=1" />
```

| Atributo | Aplica en | Descripción |
|----------|-----------|-------------|
| `disablevisible` | `<group>`, `<frame>`, `<prop>` | Oculta el elemento si se cumple la condición |
| `disableedit` | `<group>`, `<prop>` | Deshabilita la edición si se cumple la condición |

### 5.9 Props por tipo

#### 5.9.1 Texto (T)

Campo de texto editable. El control más básico de XOne.

```xml
<!-- Texto simple -->
<prop name="NOMBRE" type="T" visible="7"
      title="Nombre Completo"
      size="100" width="100%"
      tooltip="Ingrese su nombre" />

<!-- Texto multilinea -->
<prop name="MAP_TEXTAREA" type="T" visible="1"
      title="Descripción"
      class="classTMultiline"
      lines="5" fixed-lines="true" />

<!-- Texto con tooltip flotante -->
<prop name="MAP_USUARIO" type="T" visible="1"
      floating-tooltip="true"
      tooltip="Usuario"
      tmargin="94p"
      class="xnTextoEditable" />

<!-- Texto con teclado personalizado -->
<prop name="MAP_TEXT" type="T" visible="1"
      title="Texto"
      fixed-lines="true"
      keyboard-bar="false"
      show-keyboard="false" />

<!-- Texto con evento de cambio en tiempo real -->
<prop name="MAP_BUSCAR" type="T" visible="1"
      ontextchanged="javascript:buscarTexto(e);"
      labelwidth="0"
      tooltip="Texto a buscar" />
```

**Atributos especificos de T**:

| Atributo | Descripción |
|----------|-------------|
| `size` | Tamaño de la columna en BD. Con `fixed-text="true"` también limita la entrada en UI |
| `lines` | Número de lineas visibles |
| `fixed-lines` | Si es `true`, el campo no crece en altura |
| `fixed-text` | Si es `true`, el texto no se puede editar |
| `keyboard-bar` | Muestra/oculta la barra sobre el teclado |
| `show-keyboard` | Muestra/oculta el teclado al entrar al campo |
| `ontextchanged` | Evento que se dispara con cada carácter escrito |

#### 5.9.2 Label (L / TL)

Texto de solo lectura. Ideal para títulos, etiquetas y textos informativos.

```xml
<!-- Label como título -->
<prop name="lblTitulo" type="L" visible="7"
      title="Bienvenido de nuevo"
      fontbold="true" fontsize="18"
      forecolor="#212121" />

<!-- Label como subtitulo -->
<prop name="lblSubtitulo" type="L" visible="7"
      title="Inicia sesion para continuar"
      fontsize="14" forecolor="#9E9E9E" />

<!-- Label como separador con fondo -->
<prop name="MAP_SPACE" type="L" visible="7"
      width="100%" height="3p"
      bgcolor="#cccccc" title=" " />
```

> **No pongas `labelwidth="0"` en un label.** En un `L`/`TL` el texto es el propio `title`, que se pinta dentro del ancho reservado para la etiqueta; con `labelwidth="0"` no hay sitio y el texto desaparece (queda un control vacío). Deja `labelwidth` por defecto y, si necesitas centrar o alinear el texto, usa `label-align="left|center|right"`. El `labelwidth="0"` solo es correcto en campos cuyo contenido va en el *valor* (`T`, `N`…) o que no tienen texto (`IMG`, botón de icono).

#### 5.9.3 Numérico (N, N2..N6, TN, TN2..TN6)

```xml
<!-- Número entero -->
<prop name="CANTIDAD" type="N" visible="7"
      title="Cantidad" input-type="numeric" />

<!-- Precio con 2 decimales -->
<prop name="PRECIO" type="N2" visible="7"
      title="Precio" width="50%" align="right" />

<!-- Coordenada con 6 decimales -->
<prop name="LATITUD" type="N6" visible="1"
      title="Latitud" locked="true" />

<!-- Teléfono (número con enlace telefonico) -->
<prop name="MAP_TELEFONO" type="N" visible="1"
      title="Teléfono" phone="true" />
```

#### 5.9.4 Botón (B)

Los botones son uno de los elementos más usados. Pueden ejecutar acciones de dos formas: `method` (invoca un nodo) u `onclick` (ejecuta JavaScript directo).

> **CRÍTICO: `onclick` SIEMPRE es JavaScript inline, NO el nombre de un nodo.** Es un error común poner `onclick="nombreNodo"` (sin paréntesis) esperando que XOne invoque el nodo `<nombreNodo>`. XOne lo evalúa como variable JS global, queda `undefined`, y **el botón no hace nada silenciosamente** (no falla, no logea). Formas válidas de `onclick`:
>
> - `onclick="ui.openEditView('X');"` — JS inline simple
> - `onclick="appData.getCollection('X').setMacro('##F##',''); ui.openEditView('X');"` — JS inline multi-sentencia (escapar `<`, `>`, `&` con entidades XML)
> - `onclick="miFuncion();"` — llamada a función global declarada en `functions.js` (con paréntesis)
> - `onclick="self.executeNode('miNodo');"` — invocar un nodo handler XML explícitamente
> - `onclick="refresh"` o `onclick="refresh(MAP_CAMPO)"` — comandos internos especiales del framework
>
> Para invocar un nodo XML, el atributo idiomático es **`method="executenode(nombreNodo)"`**, no `onclick`.

```xml
<!-- Botón con method (invoca nodo XML) -->
<prop name="BTN_GUARDAR" type="B" visible="1"
      title="Guardar"
      method="executenode(guardar)"
      class="btnPrimario"
      img="icon_save.png" />

<!-- Botón con onclick (JavaScript directo) -->
<prop name="BTN_BUSCAR" type="B" visible="1"
      title="Buscar"
      onclick="buscarDatos();"
      width="100%" height="80p" />

<!-- Botón con method y parametros -->
<prop name="BTN_IR" type="B" visible="1"
      method="ExecuteNode(irGrupo(2))" />

<!-- Botón con imagen y sin texto (solo icono) -->
<prop name="BTN_VOLVER" type="B" visible="1"
      img="icon_back.png"
      labelwidth="0"
      width="48p" height="48p" />

<!-- Botón con imagen seleccionada (estado pressed) -->
<prop name="BTN_ADD" type="B" visible="1"
      img="add.png"
      imgsel="add_click.png"
      labelwidth="0" width="75p" />

<!-- Botón con imagen deshabilitada -->
<prop name="BEdit" type="B" visible="1"
      img="editar.png"
      img-disabled="editarlocked.png"
      disableedit="MAP_IDSELECTED=0"
      method="ExecuteNode(editar)" />

<!-- Botón con ripple effect y colores -->
<prop name="BTN_ACCION" type="B" visible="1"
      title="Acción"
      bgcolor="#1565C0"
      forecolor="#FFFFFF"
      border-corner-radius="28"
      ripple-effect="true" />

<!-- Botón con postonchange (ejecuta algo al volver) -->
<prop name="BNew" type="B" visible="1"
      img="nuevo.png"
      method="ExecuteNode(nuevo)"
      postonchange="refresh" />

<!-- Botón de texto plano (TextButton Material): SIN caja ni borde -->
<prop name="BTN_SALTAR" type="B" visible="1"
      title="saltar"
      bgcolor="#F4EFFB"        <!-- = color de fondo de la pantalla -->
      forecolor="#7C3AED"
      border-width="0"
      onclick="omitir();" />
```

> **Botón de solo texto (sin caja).** Para emular un `TextButton` de Material (solo texto/icono, sin fondo ni borde — p. ej. "saltar", "atrás", "cancelar"), pon **`border-width="0"`** y un `bgcolor` igual al color de fondo de la pantalla. El botón se funde con el fondo y solo queda visible el texto, conservando toda su área de toque. No hace falta envolverlo en un `<frame>` ni usar un `type="L"`.

**Atributos especificos de B**:

| Atributo | Descripción |
|----------|-------------|
| `method` | Método a ejecutar. Formato: `executenode(nombreNodo)` o `ExecuteNode(nodo(param))` |
| `onclick` | Código JavaScript a ejecutar directamente |
| `img` | Imagen del botón (ruta relativa a `icons/`) |
| `imgsel` | Imagen en estado pulsado |
| `img-disabled` | Imagen cuando el botón esta deshabilitado |
| `caption` | Texto alternativo (similar a `title`) |
| `ripple-effect` | Efecto de onda al pulsar (Material Design) |
| `postonchange` | Acción a ejecutar al volver de la vista invocada |
| `labelwidth` | Si es `0`, no muestra etiqueta (botón solo icono) |

#### 5.9.5 Checkbox (NC)

```xml
<!-- Checkbox básico -->
<prop name="MAP_CHECK" type="NC" visible="1"
      title="Acepto los terminos" />

<!-- Toggle / Switch -->
<prop name="MAP_TOGGLE" type="NC" visible="1"
      check-type="toggle"
      track-color="#FF0000"
      thumb-color="#00FF00" />

<!-- Radio button con grupo -->
<prop name="MAP_RADIO1" type="NC" visible="1"
      check-type="radio"
      radio-group="1"
      title="Opción A" />
<prop name="MAP_RADIO2" type="NC" visible="1"
      check-type="radio"
      radio-group="1"
      title="Opción B" />

<!-- Switch con colores dinamicos -->
<prop name="MAP_CHECK_COLOR" type="NC" visible="1"
      check-color-checked="##FLD_MAP_COLOR##"
      bgcolor="##FLD_MAP_COLOR##" />
```

| Atributo | Descripción |
|----------|-------------|
| `check-type` | Tipo: `toggle`, `radio`, `switch` |
| `radio-group` | ID del grupo de radio buttons |
| `allow-radio-group-uncheck` | Permite deseleccionar un radio |
| `track-color` | Color de la pista (toggle/switch) |
| `thumb-color` | Color del circulo (toggle/switch) |
| `check-color-checked` | Color cuando esta marcado |

#### 5.9.6 Tipos de fecha y hora: D, DT, TT

XOne tiene tres tipos de prop para mostrar y editar fechas/horas:

| Tipo | Formato | Pickers asociados | Notas |
|------|---------|-------------------|-------|
| `D`  | Fecha tradicional `DD/MM/AAAA` | DatePicker (icono de calendario) | Más común |
| `DT` | Fecha + hora `DD/MM/AAAA HH:MM` | DatePicker + TimePicker (calendario + reloj) | Para timestamps con hora |
| `TT` | Solo hora `HH:MM` | TimePicker (icono de reloj) | **Siempre asociar `mask="Hh#:#Mm"`** o el campo no se ve |

> **Selector por defecto (nuevo diseño).** Por defecto, al pulsar un campo `D`/`DT`/`TT` se abre un selector moderno: el de fecha es un calendario con **deslizamiento lateral entre meses** (además de los botones `‹ ›`) y el de hora son **ruedas** de hora y minuto. Para volver al selector nativo del sistema, fijar `date-mode`/`time-mode` a `0`. El selector admite `bgcolor-dialog`, `forecolor-dialog` (color de acento) y `fontsize-dialog`.

**Ejemplos:**

```xml
<!-- type=D: fecha tradicional -->
<prop name="FECHA" type="D" visible="1" title="FECHA"
      labelwidth="6" fieldsize="7" onchange="Refresh255" />

<!-- type=DT: fecha + hora con icono custom y formato controlado -->
<prop name="MAP_TYPEDT" type="DT" title="Fecha y hora"
      date-format="dd/MM/yyyy"
      time-format="HH:mm"
      locale="esES"
      time-interval="2"
      img-date="logo.png"
      width="100%" height="10%"
      img-date-width="96p"  img-date-height="96p"
      img-time-width="96p"  img-time-height="96p" />

<!-- type=TT: solo hora — la mask es OBLIGATORIA -->
<prop name="MAP_TYPETT" type="TT" title="Hora"
      mask="Hh#:#Mm"
      time-interval="2"
      width="100%"
      img-time-width="96p" img-time-height="96p" />
```

**Atributos relacionados (D / DT / TT):**

| Atributo | Descripción |
|----------|-------------|
| `title` | Texto/etiqueta visible de la propiedad en edición |
| `date-format` | Formato de visualizacion de la fecha (ej. `dd/MM/yyyy`). Modifica el formato por defecto |
| `time-format` | Formato de visualizacion de la hora (ej. `HH:mm`). Solo en DT/TT |
| `mask` | Mascara de entrada. **Obligatoria en TT**: `mask="Hh#:#Mm"` |
| `locale` | Locale para nombres de mes/día (ej. `esES`, `enUS`) |
| `time-interval` | Intervalo de minutos en el TimePicker (ej. `2` = saltos de 2 minutos) |
| `date-mode` | Estilo del selector de fecha. Ausente o `4` = nuevo diseño moderno (calendario con swipe lateral de meses); `0`–`3` = selectores nativos del sistema (0 dispositivo, 1 oscuro, 2 claro, 3 oscuro) |
| `time-mode` | Estilo del selector de hora. Ausente o `4` = nuevo diseño moderno (ruedas de hora/minuto); `0`–`3` = selectores nativos del sistema |
| `bgcolor-dialog` | Color de fondo del selector (nuevo diseño) |
| `forecolor-dialog` | Color de acento del selector (día/hora seleccionados, botones) |
| `fontsize-dialog` | Tamaño de los números del selector |
| `img-date` | Imagen para el icono del DatePicker |
| `img-date-width` / `img-date-height` | Tamaño del icono del calendario |
| `img-time-width` / `img-time-height` | Tamaño del icono del reloj |
| `ios-datepicker-mode` | Modo del selector en iOS: `inline`, `wheels`, `compact` |
| `bgcolor` / `forecolor` | Colores de fondo y texto |
| `width` / `height` | Dimensiones |
| `lmargin` / `rmargin` / `tmargin` / `bmargin` | Margenes |
| `newline` | `true`/`false`. Forzar salto de linea |
| `fontsize` | Tamaño de fuente |
| `labelwidth` | Ancho de la etiqueta. `0` para que no aparezca |
| `locked` | Bloquear el campo según finalidad |

**Funciones JS asociadas (`ui.showDatePicker`, `ui.showTimePicker`):**

```javascript
// Inicializar valores en before-edit
function doBeforeEdit() {
    self.MAP_TYPEDT = new Date();
    self.MAP_TYPED  = "2023-07-14 00:00:00";
}

// Abrir DatePicker que escribe directamente en un prop
function showDatePicker() {
    ui.showDatePicker({
        targetProperty: "MAP_TYPED"
    });
}

// Abrir DatePicker con callback (sin targetProperty)
function showDatePickerCallback() {
    ui.showDatePicker({
        onDateSet: function(nYear, nMonth, nDay) {
            ui.showToast("Dia: " + nDay + " Mes: " + nMonth + " Anio: " + nYear);
        }
    });
}

// Abrir TimePicker — pre-rellena con la hora actual del prop
function showTimePicker() {
    var horaSpliteada = self.MAP_TYPETT.split(":");
    ui.showTimePicker({
        targetProperty: "MAP_TYPETT",
        initialHour:    horaSpliteada[0],
        initialMinute:  horaSpliteada[1],
        is24HoursMode:  true,
        title:          "Seleccione el tiempo"
        // theme: "holo_light"  // opcional
    });
}

// Obtener fecha/hora actual como string
function getCurrentDate() {
    ui.showToast(new Date().toUTCString());
}
```

> **Diseño del picker.** Sin `theme`, `ui.showDatePicker`/`ui.showTimePicker` usan el nuevo selector moderno (calendario con swipe lateral de meses / ruedas de hora). Pasar `theme` fuerza el selector nativo del sistema con ese tema; `ui.showTimePicker` con `is24HoursMode: false` también usa el nativo (el nuevo diseño es 24 h).

> **Tip:** En `type="DT"` y `type="TT"`, `time-interval` es útil para forzar saltos de N minutos (ej. citas de 15 en 15 min se haria con `time-interval="15"`).

> **Para temporizadores continuos / cronometros**, NO usar pickers. La API correcta es `control.startChronometer({fromDate, dateFormat})` y `control.stopChronometer()`. Ver tópico 03 sección `startChronometer / stopChronometer`.

#### 5.9.8 Imagen (IMG)

```xml
<!-- Imagen estática con ruta -->
<prop name="MAP_LOGO" type="IMG" visible="1"
      path="logo.png"
      width="100p" height="100p"
      keep-aspect-ratio="true" />

<!-- Imagen con ruta del sistema -->
<prop name="MAP_IMAGE" type="IMG" visible="1"
      path="##APP##\icons\xone.png"
      labelwidth="0"
      height="40%" lmargin="2%" />

<!-- Imagen como dato (valor almacenado en campo) -->
<prop name="FOTO" type="IMG" visible="1"
      width="100p" height="100p"
      keep-aspect-ratio="true"
      scale-type="center_crop"
      border-corner-radius="50" />

<!-- Imagen con error fallback -->
<prop name="AVATAR" type="IMG" visible="7"
      path="avatar_default.png"
      error-image="avatar_error.png"
      keep-aspect-ratio="true" />
```

| Atributo | Descripción |
|----------|-------------|
| `path` | Ruta de la imagen (relativa a `icons/` o con `##APP##`) |
| `keep-aspect-ratio` | Mantiene la proporcion de la imagen |
| `scale-type` | Tipo de escalado: `center_crop`, `fit_center`, `fit_xy` |
| `error-image` | Imagen a mostrar si la principal falla |
| `abort-on-error` | Si es `true`, no intenta cargar si hay error |

> **Formatos:** `path` (igual que los atributos `img`/`imgbk`) acepta **PNG, JPG y SVG indistintamente**. El SVG se renderiza de forma nativa y escala sin perder calidad — **no** envuelvas un SVG en un `type="WEB"` ni lo conviertas previamente; basta con apuntar `path="dibujo.svg"`. Además acepta **GIF animado** y **animaciones Lottie** (ver abajo), decidiendo por la extensión del fichero.

##### Animaciones Lottie en un `IMG`

Un `IMG` cuyo fichero sea `.json`, `.lottie` o `.tgs` se renderiza como animación Lottie (las exportadas de After Effects con Bodymovin, o las descargadas de LottieFiles) y **arranca sola en bucle infinito**, sin necesidad de llamar a nada:

```xml
<!-- Animación en bucle, ida y vuelta -->
<prop name="MAP_LOADER" type="IMG" visible="1"
      path="loader.json"
      labelwidth="0"
      width="120p" height="120p"
      repeat-mode="reverse" />

<!-- Animación con texto de párrafo recortado a su caja -->
<prop name="MAP_CARTEL" type="IMG" visible="1"
      path="cartel.lottie"
      labelwidth="0"
      width="100%" height="200p"
      clip-text-to-bounds="true" />
```

| Atributo | Descripción |
|----------|-------------|
| `repeat-mode` | `restart` (vuelve a empezar) o `reverse` (va y vuelve). Sin declararlo, se repite desde el inicio |
| `clip-text-to-bounds` | Solo para animaciones con texto de párrafo: recorta el texto a la caja definida en el diseño en vez de dejar que las líneas que no caben se salgan. Apagado por omisión, y con motivo: una línea que desborde la altura **no se dibuja en absoluto**, así que si la fuente no es la del diseño y el texto se reparte en más líneas, desaparece contenido |

**Formatos y qué lleva cada uno:**

| Extensión | Qué es |
|---|---|
| `.json` | La animación exportada, en texto plano. Las imágenes pueden ir embebidas en el propio fichero (base64) o aparte |
| `.lottie` | Paquete comprimido con la animación y sus imágenes dentro. Un `.json` renombrado a `.lottie` también se acepta |
| `.tgs` | Sticker de Telegram: un `.json` comprimido con gzip. Se reconoce y reproduce igual |

**Fuentes de la animación.** Si la animación lleva texto, la fuente se busca **solo** en la carpeta `fonts/` del proyecto, con el nombre de la familia que declara el propio fichero: si la animación pide `Roboto`, hace falta `fonts/Roboto.ttf` (o `.otf`). Si no está, el texto se pinta con la fuente por defecto del dispositivo, de modo que se ve pero con otras medidas — que es justo lo que puede descolocar el reparto de líneas. Nunca se toman fuentes del sistema por nombre, para que la animación se vea igual en todos los terminales.

**Imágenes de la animación.** Se resuelven de tres maneras, por este orden: embebidas en el propio fichero, dentro del `.lottie`, o como ficheros sueltos junto al fichero de animación, respetando la subcarpeta que declare el diseño (lo habitual es `images/`, de modo que un `loader.json` que pida `images/img_0.png` lo busca en `images/img_0.png` junto a él y, si no está, al lado del propio `loader.json`). Una imagen que no se encuentre deja su capa sin pintar: no rompe la animación ni la app.

> **Los atributos `img` e `imgbk` de cualquier control usan el mismo cargador**, así que también aceptan estas extensiones. Lo que solo existe en el `type="IMG"` es el control de la reproducción: los atributos de arriba y los métodos de animación desde JavaScript (`playAnimation`, `stopAnimation`, `setAnimationFrame`…, ver la guía de métodos de controles).

#### 5.9.9 Foto (PH)

Captura de foto con la camara del dispositivo:

```xml
<!-- Capturar foto -->
<prop name="MAP_FOTO" type="PH" visible="1"
      title="Foto"
      height="40%"
      img-width="48p" img-height="48p"
      lmargin="2%" />

<!-- Ver foto (solo lectura) -->
<prop name="MAP_FOTOVER" type="PH" visible="1"
      locked="true"
      height="40%"
      title="Foto capturada" />

<!-- Foto en movimiento, con la cámara del propio framework -->
<prop name="MAP_FOTOMOV" type="PH" visible="1"
      title="Foto"
      height="40%"
      use-internal-camera="true"
      motion-photo="true" />
```

| Atributo | Descripción |
|----------|-------------|
| `use-internal-camera` | Captura con la cámara que trae el framework en vez de abrir la app de cámara del dispositivo. Da una pantalla de captura igual en todos los terminales (disparador, temporizador, flash, zoom, brillo y previsualización antes de aceptar) |
| `motion-photo` | Captura una **foto en movimiento**: un JPG que lleva embebido detrás un clip de vídeo corto con el instante del disparo. Para cualquier visor sigue siendo una foto normal, y las galerías que entienden el formato (Google Fotos) reproducen el movimiento al abrirla |
| `file-maxsize`, `file-maxwidth`, `file-maxheight`, `file-quality` | Límites de tamaño y calidad de la foto guardada |
| `analyze-exif-metadata` | Gira el fichero según la orientación con la que se hizo la foto, de modo que se vea derecho en cualquier visor |

##### Fotos en movimiento (`motion-photo`)

> **Úsalo junto a `use-internal-camera="true"`.** Así funciona en cualquier versión de Android, porque la captura y el montaje del fichero los hace el propio framework. Sin `use-internal-camera` se delega en la app de cámara del dispositivo, que solo puede atender la petición a partir de **Android 16** y únicamente si la implementa: a día de hoy no lo hace ninguna, ni siquiera la de los Pixel, con lo que se obtiene una foto normal sin más aviso.

Al capturar una foto en movimiento se **ignoran** `file-maxsize`, `file-maxwidth`, `file-maxheight` y `file-quality`: redimensionar o recomprimir la imagen se llevaría por delante el vídeo embebido. Si necesitas fotos ligeras, no uses `motion-photo`. El fichero resultante pesa lo que la foto más el clip, del orden de varios megas.

`analyze-exif-metadata="true"` sí es compatible: al girar la foto se conserva el vídeo.

#### 5.9.10 Video/Camara (VD) y escaner QR

```xml
<!-- Grabar video -->
<prop name="MAP_VIDEO" type="VD" visible="1"
      readonly="false"
      width="50%" height="40%"
      title="Video"
      onchange="refresh(MAP_VIDEO)" />

<!-- Reproducir video local -->
<prop name="MAP_VIDEOVER" type="VD" visible="1"
      readonly="true"
      width="50%" height="40%" />

<!-- Escaner QR -->
<prop name="SCANNER" type="VD" visible="1"
      viewmode="camerapreview"
      width="100%" height="300p"
      code-type="qr"
      oncodescanned="procesarCodigo(e);" />
```

| Atributo | Descripción |
|----------|-------------|
| `code-type` | Tipo de código a escanear: `qr`, `datamatrix`, `barcode` |
| `oncodescanned` | Evento al leer un código |
| `readonly` | Si es `true`, solo reproduce; si es `false`, captura |

#### 5.9.11 Mapa (`type="Z" viewmode="mapview"`)

Los mapas en XOne son **contenedores** (`type="Z"`) con `viewmode="mapview"` (Google Maps), `maplibre` (MapLibre) u `openstreetmap`. **No existe un `type="M"` propio para mapas.**

```xml
<!-- Mapa básico (Google Maps) -->
<prop name="MAP_MAPA" type="Z" viewmode="mapview" visible="7"
      width="100%" height="100%"
      show-user-location="true"
      zoom="15" />

<!-- Mapa con eventos -->
<prop name="MAP_MAPA" type="Z" viewmode="mapview" visible="7"
      width="100%" height="70%"
      show-user-location="true"
      onmapclicked="onMapClick(e);"
      onmapready="onMapReady(e);" />

<!-- Alternativas open source -->
<prop name="MAP_MAPA" type="Z" viewmode="maplibre" visible="7" width="100%" height="100%" />
<prop name="MAP_MAPA" type="Z" viewmode="openstreetmap" visible="7" width="100%" height="100%" />
```

**Atributos:**

| Atributo | Descripción |
|----------|-------------|
| `show-user-location` | Muestra la posición del usuario |
| `zoom` | Nivel de zoom inicial |
| `max-zoom` | Zoom máximo permitido |

**Eventos** (atributos XML inline en el prop):

| Atributo | Cuándo se dispara | Parámetros del evento |
|----------|-------------------|----------------------|
| `onmapready` | Mapa inicializado y listo | `e.target` |
| `onmapclicked` | Click en el mapa (no sobre un marcador) | `e.latitude`, `e.longitude`, `e.target` |
| `onmaplongclicked` | Click largo en el mapa | `e.latitude`, `e.longitude`, `e.target` |
| `onmapzoomchanged` | Cambio de nivel de zoom | `e.zoom` (nuevo nivel); `e.bounds` = `Object[]` de 2 elementos `[noreste, suroeste]`, cada uno objeto location con `latitude`, `longitude`, `altitude`, `accuracy`, `bearing`, `speed`, `time` (los 5 últimos siempre a 0) |
| `onmarkerdragend` | Fin de arrastre de un marcador | `e.latitude`, `e.longitude`, `e.tag`, `e.marker` |
| `ondrop` | Objeto soltado sobre el mapa (drag & drop) | `e.latitude`, `e.longitude`, `e.target` |
| `onlocationready` | Primera localización GPS obtenida | `e.latitude`, `e.longitude` |
| `onlocationchanged` | Cambio de posición GPS | `e.latitude`, `e.longitude` |
| `onstreetviewenabled` | StreetView activado | `e.latitude`, `e.longitude`, `e.target` (coordenadas del punto donde se activó) |
| `onstreetviewunavailable` | StreetView no disponible en la zona | `e.latitude`, `e.longitude`, `e.target` (coordenadas del punto consultado) |
| `ondistancemeter` | Resultado del medidor de distancia | `e.distance` (metros), `e.location1`, `e.location2` — ver sección siguiente |

##### Medidor de distancia interactivo

Sólo está implementado en **Google Maps** (`viewmode="mapview"`). En `openstreetmap`, `maplibre` y `picturemap` las llamadas a `startDistanceMeter` / `stopDistanceMeter` lanzan `UnsupportedOperationException("Not implemented yet")`.

```javascript
let mapControl = getControl("MAP_MAPA");

// Forma 1: objeto JS (recomendada). Crea dos marcadores arrastrables
mapControl.startDistanceMeter({
    latitude       : 38.886546,
    longitude      : -7.0043193,
    startMarkerIcon: "ic_start.png",   // opcional, ruta relativa a la carpeta de recursos de la app
    endMarkerIcon  : "ic_end.png"      // opcional
});

// Forma 2: parámetros posicionales — location + iconos (máx. 2 iconos)
mapControl.startDistanceMeter("38.886546,-7.0043193", "ic_start.png", "ic_end.png");

// Forma 3: sin parámetros → usa el centro actual de la cámara como punto de partida
mapControl.startDistanceMeter();

// Detener: elimina marcadores y línea
mapControl.stopDistanceMeter();
```

El evento `ondistancemeter` declarado en el prop se dispara **al terminar de arrastrar cualquiera de los dos marcadores** (no solo el final). Parámetros del evento:

| Campo | Tipo | Descripción |
|-------|------|-------------|
| `e.distance` | `double` | Distancia en **metros** entre los dos marcadores (geodésica, vía `SphericalUtil.computeDistanceBetween`) |
| `e.location1` | objeto | Posición del marcador de inicio. Campos: `latitude`, `longitude`, `altitude` (0), `accuracy` (0), `bearing` (0), `speed` (0), `time` (0) |
| `e.location2` | objeto | Posición del marcador final, con los mismos campos |

```javascript
function onDistanceMeter(e) {
    self.MAP_DISTANCIA = e.distance.toFixed(1) + " m";
    self.MAP_LAT_FIN   = e.location2.latitude;
    self.MAP_LON_FIN   = e.location2.longitude;
    ui.refreshValue("MAP_DISTANCIA", "MAP_LAT_FIN", "MAP_LON_FIN");
}
```

##### Operaciones sobre marcadores (MarkerScriptWrapper)

Cada llamada a `mapControl.addMarker(...)` devuelve un wrapper del marcador con métodos para modificarlo en runtime. Cuidado: algunos métodos están **implementados solo en Google Maps**; en MapLibre devuelven el wrapper sin hacer nada (no-op silencioso, sin excepción).

```javascript
marker.setVisible(true);
marker.setDraggable(true);          // MapLibre: no-op
marker.setRotation(180);            // Rotación en grados; animado por defecto
marker.setRotation(180, false);     // Rotación instantánea (sin animación). MapLibre: no-op
marker.setAlpha(0.5);               // MapLibre: no-op
marker.setAnchor("top");            // top / bottom / center. MapLibre: no-op
marker.setIcon("ic_nuevo.png");
marker.setPosition({
    latitude : 38.8685452,
    longitude: -6.8170906,
    animate  : true,
    duration : 500                  // ms de animación
});
let pos = marker.getPosition();     // [latitude, longitude]
marker.showInfo();
marker.hideInfo();
marker.remove();
```

Resumen de soporte por backend:

| Método | Google Maps (`mapview`) | MapLibre (`maplibre`) |
|--------|-------------------------|------------------------|
| `setVisible` / `setIcon` / `setPosition` / `remove` / `showInfo` / `hideInfo` | OK | OK |
| `setDraggable` / `setRotation` / `setAlpha` / `setAnchor` | OK | No-op silencioso |

> **Nota**: Los mapas también pueden mostrarse mediante `type="Z"` con `viewmode="mapview"` para mostrar multiples marcadores. Ver sección 5.9.12.

#### 5.9.12 Grid/Lista (Z)

El tipo `Z` es el más potente para mostrar listas de datos. Se vincula a un nodo `<contents>` que define la fuente de datos.

```xml
<!-- Lista con RecyclerView -->
<prop name="MAP_LISTA" type="Z" visible="1"
      contents="@MiContenido"
      viewmode="recyclerview"
      width="100%" height="80%"
      edit-inrow="true"
      show-no-data="true"
      show-loading="true" />
<contents name="@MiContenido" src="ColeccionDatos" />

<!-- Mapa con marcadores -->
<prop name="MAP_MAPA" type="Z" visible="1"
      viewmode="mapview"
      mapview-embedded="true"
      contents="mapaDatos"
      width="100%" height="80%"
      show-user-location="true"
      zoom-to-pois="true" />
<contents name="mapaDatos" src="ContentMapa" />

<!-- Gráfico de barras -->
<prop name="@ChartBarras" type="Z" visible="1"
      classid="XOneCharts"
      viewmode="barchart"
      contents="GraficosBarrasDatos"
      width="100%" height="300p" />
<contents name="GraficosBarrasDatos" src="ContentGraficosBarras" />

<!-- Calendario -->
<prop name="Calendario" type="Z" visible="1"
      calendar-viewmode="week"
      contents="calendario"
      viewmode="calendarview"
      width="100%" height="100%" />
<contents name="calendario" src="ContentCalendario" />
```

**ViewModes disponibles para type="Z"**:

**Listas y Grids:**

| ViewMode | Descripción |
|----------|-------------|
| `recyclerview` | Lista con reciclaje de vistas (**recomendado** para listas largas) |
| `gridview` | Vista de cuadricula |
| `slideview` | Vista deslizable tipo carrusel (swipe tabs) |
| `coverflow` | Variante de `slideview` con efecto Cover Flow estilo iTunes (cards laterales escaladas/atenuadas/rotadas en 3D). Ver sección 5.9.12d |
| `kanban` | Tablero estilo Trello/Jira: items agrupados en columnas verticales con drag&drop entre columnas. Ver sección 5.9.12c |
| `chipsview` | Conjunto de **chips Material** (pastillas redondeadas) con *wrap* automático a varias filas. Cada fila de un `<contents>` es un chip. Ver sección 5.9.12e |
| `expanview` | Vista expandible / colapsable (acordeón) |

**Mapas:**

| ViewMode | Descripción |
|----------|-------------|
| `mapview` | Mapa con marcadores (Google Maps) |
| `openstreetmap` | Mapa OpenStreetMap |
| `picturemap` | Mapa con imágenes / catálogo visual de marcadores |

**Gráficos:**

| ViewMode | Descripción |
|----------|-------------|
| `barchart` | Gráfico de barras |
| `3dbarchart` | Gráfico de barras 3D |
| `linechart` | Gráfico de lineas |
| `xylinechart` | Gráfico de lineas XY |
| `areachart` | Gráfico de áreas |
| `timeserieschart` | Gráfico de series temporales |
| `slidingbarchart` | Gráfico de barras con navegación horizontal |
| `piechart` | Gráfico circular |
| `piechart2` | Gráfico circular (variante alternativa) |

**Otros:**

| ViewMode | Descripción |
|----------|-------------|
| `calendarview` | Vista de calendario |

**Atributos especificos de Z**:

| Atributo | Descripción |
|----------|-------------|
| `contents` | Nombre del content vinculado (con prefijo `@`) |
| `viewmode` | Modo de visualizacion (ver tabla) |
| `versión` | Versión del grid (`"v2"` para versión mejorada) |
| `edit-inrow` | Editar directamente en la fila |
| `show-no-data` | Mostrar mensaje cuando no hay datos |
| `show-loading` | Mostrar indicador de carga |
| `classid` | Para gráficos: `"XOneCharts"` |
| `mask` | Mascara de opciones |
| `calendar-viewmode` | Para calendarios: `week`, `month` |

#### 5.9.12e Chips (viewmode="chipsview")

Muestra una colección de etiquetas como **chips Material** (pastillas redondeadas) con *wrap* automático a varias filas — el equivalente a un `Wrap(children: [Chip(...)])`. Es un `<prop type="Z" viewmode="chipsview">` alimentado por un `<contents>`: **cada fila del contents es un chip**.

La colección del `<contents>` debe declarar:
- una prop con **`chip-value="true"`** → su valor es el texto que se pinta en el chip (obligatoria).
- opcionalmente una prop con **`chip-close-enabled="true"`** → si su valor es verdadero, el chip muestra una "x" para cerrarse.

```xml
<!-- En la pantalla -->
<prop name="MAP_TAGS" type="Z" viewmode="chipsview" contents="@tagsContent"
      width="100%" height="-2" />
<contents name="@tagsContent" src="Etiqueta" />

<!-- Colección de las etiquetas. Puede vivir en memoria (volatile) si los chips
     se generan al vuelo (p. ej. partiendo un campo de texto): -->
<coll name="Etiqueta" volatile="true" loadall="true" manual-load="true" progid="ASData.CASBasicDataObj">
    <prop name="VALUE" type="T" chip-value="true" size="120" />
</coll>
```

**Rellenar los chips desde JS** (típico: trocear un campo CSV en el `before-edit` del detalle). Hay que **añadir** cada objeto al contents y refrescar el control:

```javascript
var c = self.getContents("@tagsContent");
c.unlock();
c.clear();
var tags = String(self.TAGS || "").split(",");
for (var i = 0; i < tags.length; i++) {
    var t = tags[i].replace(/^\s+|\s+$/g, "");
    if (t.length === 0) continue;
    var o = c.createObject();
    o.VALUE = t;
    c.addItem(o);          // addItem, NO save
}
c.lock();
var v = ui.getView(self);
if (v !== null) v.refresh("MAP_TAGS");   // refrescar el control type=Z
```

> **Importante (colección en memoria):** con `volatile="true"` añade también **`manual-load="true"`** y **`loadall="true"`** en la `<coll>`. Si no, el control intenta recargar la colección desde la base de datos al pintarse y la deja vacía. Para llenarla usa `createObject()` + **`addItem()`** (NO `save()`, que fallaría al no existir tabla), luego `lock()` y refresca el control con `ui.refresh("NOMBRE_DEL_Z")`.

**Selección / cierre (todos los chips son *checkable* / toggle):** cada chip se puede marcar y desmarcar; no existe un modo "solo lectura" — un chip sin handler simplemente no hace nada al marcarse. Esto los hace ideales como *filter chips* (seleccionar para filtrar).

- **`onitemschanged="onTags(e);"`** — se dispara en cada marca/desmarca y `e` trae **todos** los chips marcados en ese momento: **`e.values`** (array con los textos) y **`e.ids`** (array con sus ids). Es el camino recomendado para reaccionar a la selección.
- **`onitemremoved="onQuita(e);"`** — se dispara al pulsar la "x" de un chip (requiere que esa fila tenga `chip-close-enabled` con valor verdadero); `e.value` / `e.id` identifican el chip cerrado.
- Alternativa imperativa: `ui.getView(self).getControl("MAP_TAGS").getCheckedValues()` devuelve los marcados como `[{id, value}]`.

```javascript
// filter chips: al cambiar la selección, relanzar una búsqueda con los tags activos
function onTags(e) {
    var tags = [];
    if (e && e.values) {
        for (var i = 0; i < e.values.length; i++) tags.push(String(e.values[i]));
    }
    buscarConTags(tags);   // tu lógica de filtrado
}
```

#### 5.9.12c Tablero Kanban (viewmode="kanban")

Tablero estilo Trello / Jira para `<prop type="Z">`: los items de un `<contents>` se agrupan en columnas verticales según el valor de un campo, con **drag&drop entre columnas**. Al soltar una card en otra columna, el framework asigna al campo declarado en `kanban-column-field` el valor de la columna destino y persiste el cambio automáticamente (sin código JS adicional).

**Modo simple — card con título + subtítulo (sin frame propio):**

```xml
<prop name="MAP_TABLERO" type="Z" visible="1"
      viewmode="kanban"
      contents="@tareasContent"
      kanban-column-field="ESTADO"
      kanban-columns="TODO|DOING|DONE"
      kanban-column-titles="Pendiente|En curso|Hecho"
      kanban-column-colors="#FFE0E0|#FFF4D0|#D0F0D0"
      kanban-column-width="280p"
      kanban-card-title-field="TITULO"
      kanban-card-subtitle-field="DESCRIPCION"
      kanban-card-bgcolor="#FFFFFF"
      draggable="true"
      width="100%" height="100%" />
<contents name="@tareasContent" src="Tareas" />
```

**Modo objeto XOne completo — la card usa el `<frame>` declarado en la coll del contents:**

```xml
<prop name="MAP_TABLERO" type="Z" visible="1"
      viewmode="kanban"
      contents="@tareasContent"
      kanban-column-field="ESTADO"
      kanban-columns="TODO|DOING|DONE"
      width="100%" height="100%" />
```

**Atributos obligatorios:**

| Atributo | Descripción |
|----------|-------------|
| `contents` | Nombre del `<contents>` vinculado |
| `kanban-column-field` | Nombre del campo del item cuyo valor determina la columna |
| `kanban-columns` | Valores posibles del campo separados por `\|` (ej. `TODO\|DOING\|DONE`). Define orden y número de columnas |

**Atributos opcionales:**

| Atributo | Default | Descripción |
|----------|---------|-------------|
| `kanban-column-titles` | usa los valores | Títulos visibles de las columnas separados por `\|`. Si no se da, se muestra el valor crudo |
| `kanban-column-colors` | gris claro | Colores de fondo de la cabecera de cada columna separados por `\|`. Acepta `#RRGGBB` y `#AARRGGBB` |
| `kanban-column-width` | `280p` | Ancho de cada columna. Acepta `p`, `%`, etc. |
| `kanban-card-title-field` | — | Campo a mostrar como título de la card (modo simple) |
| `kanban-card-subtitle-field` | — | Campo a mostrar como subtítulo (modo simple) |
| `kanban-card-bgcolor` | blanco | Color de fondo de las cards |
| `draggable` | `true` | Si `false`, deshabilita drag&drop (tablero solo lectura) |
| `disableedit` | `false` | Formula o literal; si evalua a `true`, las cards no son arrastrables aunque `draggable="true"` |

**Modos de renderizado de las cards:**

- **Modo simple:** activo cuando esta presente al menos uno de `kanban-card-title-field` / `kanban-card-subtitle-field`. La card muestra título + subtítulo sobre `kanban-card-bgcolor`. Útil para tableros ligeros.
- **Modo objeto XOne completo:** activo cuando ninguno de esos atributos esta presente. Cada card se renderiza con el `<frame>` declarado en la coll del contents (mismo patron que `recyclerview` / `slideview`). Permite layouts complejos.

**Eventos:**

| Evento | Cuando se dispara |
|--------|--------------------|
| `<selecteditem>` / `onselecteditem` | Clic corto sobre una card (mismo patron que `recyclerview`) |
| Drag&drop entre columnas | Long-press sobre la card inicia el drag. Al soltar en otra columna, el framework asigna `kanban-column-field = valor de la columna destino` y guarda |

**Casos de uso típicos:** gestion de tareas (TODO/DOING/DONE), pipeline comercial (LEAD/QUOTE/WON/LOST), tableros de proyecto, workflows de aprobacion.

**Notas:**

- El campo `kanban-column-field` debe existir en la coll del contents y aceptar como valor cualquiera de los strings declarados en `kanban-columns` (mismo formato, sin transformación).
- Cards cuyo valor del campo no coincida con ninguna columna declarada **no se muestran**.
- Si el ancho total de las columnas supera la pantalla, el tablero se desplaza horizontalmente.

#### 5.9.12d Carrusel Cover Flow (viewmode="coverflow")

Variante de `slideview` para `<prop type="Z">` con efecto **Cover Flow** estilo iTunes: las cards laterales se reducen, se atenuan y opcionalmente rotan en 3D respecto a la card central, creando sensacion de profundidad. La card del centro se ve a tamaño y opacidad plenos; las que se alejan a izquierda o derecha se interpolan linealmente hacia los mínimos definidos.

Internamente comparte motor con `slideview` (mismo `<contents>`, misma navegación por swipe, mismos eventos: `onselecteditem`, `autoslide-delay`, indicadores de página). Solo cambia la animación de transición.

```xml
<!-- Cover Flow básico (escala 75%, alpha 60%, sin rotacion 3D) -->
<prop name="MAP_CARRUSEL" type="Z" visible="1"
      viewmode="coverflow"
      contents="@productosContent"
      width="100%" height="320p" />
<contents name="@productosContent" src="Productos" />

<!-- Cover Flow con rotacion 3D en Y -->
<prop name="MAP_CARRUSEL" type="Z" visible="1"
      viewmode="coverflow"
      contents="@productosContent"
      cover-flow-min-scale="0.7"
      cover-flow-min-alpha="0.5"
      cover-flow-rotation="35"
      width="100%" height="320p" />
```

**Atributos especificos:**

| Atributo | Default | Rango | Descripción |
|----------|---------|-------|-------------|
| `cover-flow-min-scale` | `0.75` | `0.0` – `1.0` | Escala mínima de las cards laterales. La central se ve a `1.0`; las pegadas al borde se reducen hasta este valor |
| `cover-flow-min-alpha` | `0.6` | `0.0` – `1.0` | Opacidad mínima de las cards laterales. La central a `1.0`; las laterales se atenuan linealmente |
| `cover-flow-rotation` | `0` | grados | Rotación 3D sobre el eje Y de las cards laterales. Si distinto de `0`, se aplica perspectiva 3D real. Valores típicos: `25`–`45` |

Todos los atributos heredados de `slideview` (`autoslide-delay`, `onselecteditem`, etc.) siguen funcionando.

**Comportamiento:**

- **Card central:** escala `1.0`, alpha `1.0`, rotación `0` (siempre se ve al máximo).
- **Cards laterales:** se interpolan linealmente entre el centro y los mínimos según la distancia. Una card pegada al borde (posición ±1) se ve exactamente a `cover-flow-min-scale` de escala, `cover-flow-min-alpha` de alpha y `±cover-flow-rotation` grados.
- **Cards fuera del viewport:** invisibles (alpha 0) — no se renderizan visualmente.
- **Layout de la card:** el contenido es el `<frame>` declarado en la coll del contents, igual que `slideview`. El transformer solo modifica escala/alpha/rotación.

**Casos de uso típicos:** galerías de productos destacados en home, onboarding ilustrado, selectores visuales (plan, avatar), showcases donde se quiere foco en una card y peek de las adyacentes.

**Notas:**

- Valores de `cover-flow-min-scale` / `cover-flow-min-alpha` se recortan al rango `[0, 1]`; valores fuera se ajustan automáticamente.
- Con `cover-flow-rotation="0"` (default), el efecto es puramente plano (escala + opacidad). Para Cover Flow clasico estilo iTunes, usar entre 30 y 45 grados.
- Suele dejarse el `width` de cada card algo menor que el viewport para ver "peeking" de las adyacentes.
- No combinable con `viewmode="slideview"`: o uno o el otro.

#### 5.9.13 Combo (`type="T"` + `mapcol`/`mapfld`) - Selector desplegable

> **No existe un `type="C"` propio en XOne.** Los combos/selectores se implementan con `type="T"` (o `type="N"`) más los atributos `mapcol` y `mapfld` que apuntan a la coleccion de origen y al campo de enlace.

El combo en XOne funciona con dos props vinculados: uno oculto que almacena el ID (con `mapcol`/`mapfld`) y otro visible que muestra la descripción (con `linkedto`/`linkedfield`).

```xml
<!-- Campo oculto que almacena el valor -->
<prop name="ID_TIPO" type="N" visible="0"
      mapcol="TiposProducto"
      mapfld="ID" />

<!-- Campo visible que muestra la descripción -->
<prop name="TIPO_DESC" type="T" visible="1"
      title="Tipo de producto"
      linkedto="ID_TIPO"
      linkedfield="DESCRIPCION"
      showinline="true" />
```

| Atributo | En prop oculto | Descripción |
|----------|---------------|-------------|
| `mapcol` | Si | Coleccion de donde obtener las opciones |
| `mapfld` | Si | Campo clave de la coleccion mapeada |
| `linkedto` | No (en visible) | Nombre del prop oculto vinculado |
| `linkedfield` | No (en visible) | Campo a mostrar de la coleccion mapeada |
| `showinline` | No (en visible) | Muestra las opciones en un panel de selección inferior |
| `showinline-keyboard` | No (en visible) | Añade una caja de búsqueda en la cabecera del panel para filtrar las opciones |
| `viewmode` | No (en visible) | `spinner` (desplegable) o `dialog` (dialogo) |
| `bgcolor-dialog` / `forecolor-dialog` / `fontsize-dialog` | No (en visible) | Color de fondo, color del texto de las opciones y tamaño del texto del panel |

> **Panel de selección (`showinline`).** Al pulsar el campo se abre un panel inferior con la lista de opciones. Con `showinline-keyboard="true"` la cabecera incluye una caja de búsqueda que filtra las opciones según se escribe. Se puede personalizar con `bgcolor-dialog`, `forecolor-dialog` (color del texto) y `fontsize-dialog`.

> **Nota sobre el prefijo `MAP_`:** por defecto, el prop visible de un combo (el que tiene `linkedto`) se nombra con prefijo `MAP_` (por ejemplo `MAP_TIPO_DESC`), porque su valor proviene del lookup y NO se persiste en la tabla de la coll. El prop oculto con el ID (el que tiene `mapcol`/`mapfld`) NO lleva `MAP_` cuando ese ID SI es columna de la tabla (es la FK). Ver concepto completo de campos `MAP_` en [01-xone-fundamentals.md](01-xone-fundamentals.md#concepto-de-campos-map_).

#### 5.9.14 Combo con valores inline (mapcol-values)

Para combos simples con valores predefinidos (sin tabla de BD):

```xml
<!-- Campo oculto con valores inline -->
<prop name="MAP_IDTIPOIDEN" type="T" visible="0"
      mapcol-values="CC, TI, CE, Otro, Varios"
      mapfld="DATA" />

<!-- Campo visible -->
<prop name="TIPOIDENTIFICADOR" type="T" visible="1"
      title="Tipo Documento"
      showinline="true"
      linkedto="MAP_IDTIPOIDEN"
      linkedfield="DATA" />
```

Con `mapcol-values`, los valores se definen separados por comas directamente en el XML, sin necesidad de una coleccion en la BD.

> **Nota sobre el prefijo `MAP_`:** en combos con `mapcol-values`, el prop oculto lleva `MAP_` porque no existe ninguna tabla de la que leer/guardar sus opciones — solo existen en el XML. El prop visible lleva `MAP_` si el código seleccionado no se persiste como columna, o va sin `MAP_` si el código SI es columna propia de la tabla.

#### 5.9.15 Web (WEB)

> **⚠️ El control `WEB` es SOLO para contenido web remoto:** URLs `http://`/`https://`, vídeos embebidos, HTML servido. **NUNCA lo uses para mostrar una imagen local en formato SVG, PNG o JPG.** XOne renderiza SVG de forma nativa, exactamente igual que PNG y JPG. Para mostrar una imagen (incluida una `.svg`) usa `type="IMG"` con `path="dibujo.svg"`, o el atributo `img`/`imgbk` en cualquier control. No hace falta WebView ni convertir el SVG a otro formato.

```xml
<!-- Contenido web -->
<prop name="MAP_WEB" type="WEB" visible="1"
      height="40%"
      title="Página Web"
      onconsolemessage="handleError(e);" />

<!-- Video de YouTube -->
<prop name="MAP_VIDEO_ONLINE" type="WEB" visible="1"
      readonly="true"
      height="40%" />
```

Se establece la URL programaticamente:
```javascript
self.MAP_WEB = "http://ejemplo.com";
self.MAP_VIDEO_ONLINE = "https://www.youtube.com/watch?v=VIDEO_ID";
```

**Evento `onconsolemessage`** (atributo del `<prop type="WEB">`). Se dispara con cada mensaje de la consola del WebView (errores JS, `console.log`, etc.). Recibe un objeto `e` con:

| Propiedad | Tipo | Descripción |
|-----------|------|-------------|
| `e.target` | string | Nombre del prop que disparo el evento |
| `e.objItem` | object | DataObject que contiene el prop |
| `e.messageLevel` | string | Nivel del mensaje: `"LOG"`, `"DEBUG"`, `"WARNING"`, `"ERROR"`, `"TIP"` |
| `e.message` | string | Texto del mensaje |
| `e.lineNumber` | number | Linea del fuente donde se origino el mensaje |
| `e.sourceId` | string | URL/identificador del fuente que origino el mensaje |

```javascript
function handleError(e) {
    if (e.messageLevel === "ERROR") {
        ui.msgBox("Nivel: " + e.messageLevel +
            "\nMensaje: " + e.message +
            "\nLinea: " + e.lineNumber +
            "\nFuente: " + e.sourceId, "Error WebView", 0);
    }
}
```

#### 5.9.16 Firma con `type="IMG" readonly="false"` — OBSOLETO

> **OBSOLETO.** Este patron de firma (imagen editable con `readonly="false"`) esta deprecado. Para captura de firmas o dibujos a mano alzada usar siempre `type="DR"` (ver §5.9.22). Esta sección se mantiene solo para reconocer código legacy en proyectos antiguos.

#### 5.9.17 Slider (N con viewmode) y Progress

Los campos numéricos (`type="N"`) pueden mostrar controles visuales especiales mediante `viewmode`:

**ViewModes numéricos disponibles:**

| ViewMode | Descripción |
|----------|-------------|
| `seekbar` | Barra deslizante clasica con pulgar arrastrabe |
| `slider` | Control deslizante (variante moderna del seekbar) |
| `progress-bar` | Barra de progreso horizontal (solo lectura o indeterminada) |
| `circular-progress-bar` | Indicador de progreso circular |
| `range-slider` | Selector de rango con dos pulgares (valor mínimo y máximo) |
| `stepper` | Control compacto con dos botones `−` / `+` a los lados de un valor entero central (auto-repite al mantener pulsado). Ver sección 5.9.17b |
| `navbar` | Barra de navegación Material 3 con indicador "pill" deslizante; el valor es el índice del destino activo. Ver sección 5.9.17e |

```xml
<!-- Slider horizontal -->
<prop name="MAP_SLIDER" type="N" visible="1"
      viewmode="slider"
      orientation="horizontal"
      min="0" max="100"
      thumb-color="#FF00FF"
      bar-color="#FF0000"
      track-color="#00FF00"
      notify-only-when-dropped="false" />

<!-- Barra de progreso -->
<prop name="MAP_PROGRESS" type="N" visible="1"
      viewmode="progress-bar"
      indeterminate="true"
      bar-color="#FF0000"
      track-color="#00FF00" />

<!-- Progreso circular -->
<prop name="MAP_CIRCULAR" type="N" visible="1"
      viewmode="circular-progress-bar"
      bar-color="#1565C0" />

<!-- Rango (Range Slider) -->
<prop name="MAP_RANGE" type="N" visible="1"
      viewmode="range-slider"
      min="0" max="100" />

<!-- Seekbar con imagenes personalizadas -->
<prop name="MAP_SEEK" type="N" visible="1"
      viewmode="seekbar"
      min="0" max="100"
      img-thumb="thumb.png"
      img-progress-left="progress_left.png"
      notify-only-when-dropped="true" />
```

#### 5.9.17b Stepper numérico (viewmode="stepper")

Control numérico compacto con dos botones `−` / `+` a los lados de un valor central. Aplica a `<prop type="N">` y maneja **valores enteros**. Cada pulsacion aplica `±step-size`; al mantener pulsado un botón, se aplica el primer paso al instante y luego **auto-repite cada 80 ms** hasta soltar o alcanzar el limite.

```xml
<!-- Stepper básico de cantidad (0..99, paso 1) -->
<prop name="CANTIDAD" type="N" visible="1"
      viewmode="stepper"
      min="0" max="99"
      step-size="1"
      title="Cantidad" />

<!-- Stepper con colores personalizados -->
<prop name="PERSONAS" type="N" visible="1"
      viewmode="stepper"
      min="1" max="20"
      step-size="1"
      bar-color="#2196F3"
      forecolor="#212121"
      title="Personas" />

<!-- Stepper ciclico (al llegar al max, vuelve al min) -->
<prop name="HORA" type="N" visible="1"
      viewmode="stepper"
      min="0" max="23"
      step-size="1"
      wrap="true"
      title="Hora" />
```

**Atributos:**

| Atributo | Default | Descripción |
|----------|---------|-------------|
| `min` | `0` | Valor mínimo (entero). Si el valor actual es menor, se clampa al cargar |
| `max` | `100` | Valor máximo (entero). Debe ser `>= min` (si no, lanza `IllegalArgumentException`) |
| `step-size` | `1` | Incremento por pulsacion. Debe ser `> 0` |
| `wrap` | `false` | Si `true`, al sobrepasar `max` vuelve a `min` y viceversa (selector ciclico). Si `false`, se queda fijo en el limite |
| `bar-color` | — | Color de fondo de los botones `−` / `+`. Acepta `#RRGGBB` y `#AARRGGBB` |
| `forecolor` | — | Color del número del centro |
| `disableedit` | `false` | Formula o literal; si evalua a `true`, los botones quedan deshabilitados |

**Comportamiento:**

- **Pulsacion corta:** aplica una vez `±step-size`.
- **Pulsacion larga (long-press):** aplica el primer paso al instante y luego auto-repite cada **80 ms** hasta soltar (`ACTION_UP` / `ACTION_CANCEL` / `ACTION_OUTSIDE`).
- **Sin `wrap`:** el valor se clampa al rango `[min, max]`. Los botones quedan clicables aunque se llegue al limite (no producen cambio).
- **Con `wrap="true"`:** wrap ciclico — útil para hora (0–23), día de la semana (0–6).
- **Propagacion:** cada cambio dispara `dataObject.put(sProp, nValue)` y re-evalua los triggers (`<onchange>` y propagaciones).

**API JavaScript:**

| Método | Efecto |
|--------|--------|
| `control.getValue()` | Devuelve el valor actual como entero |
| `control.setValue(n)` | Asigna el valor (se clampa al rango). Si cambia, dispara callback de cambio |
| `control.setMin(n)` | Cambia el mínimo en runtime. Si `max` queda por debajo, también se ajusta; si el valor actual queda por debajo del nuevo `min`, se sube |
| `control.setMax(n)` | Cambia el máximo en runtime. Misma lógica de ajuste cruzado |
| `control.setStepSize(n)` | Cambia el incremento. Debe ser `> 0` (si no, lanza error) |

```javascript
// Ajustar el rango dinamicamente según otro campo
function onTipoChange() {
    var ctrl = getControl("CANTIDAD");
    if (self.TIPO === "PACK_GRANDE") {
        ctrl.setMin(10);
        ctrl.setMax(500);
        ctrl.setStepSize(10);
    } else {
        ctrl.setMin(1);
        ctrl.setMax(99);
        ctrl.setStepSize(1);
    }
}
```

**Casos de uso típicos:** cantidades en carritos, spinners de configuración (zoom, volumen discreto), selectores ciclicos (hora, día semana), pasos de wizard.

**Notas:**

- Solo maneja **valores enteros**. Para incrementos decimales, usar `slider` o `seekbar`.
- El valor se persiste como entero en el campo del prop.
- Si `max < min`, el framework lanza `IllegalArgumentException`. Si `step-size <= 0`, igualmente.
- Los botones se renderizan con caracteres Unicode (`−` U+2212 para el menos, `+` para el más) sobre fondos coloreados con `bar-color`.

#### 5.9.17c OTP — Entrada de códigos (viewmode="otp")

Campo de introduccion de códigos de un solo uso (One-Time Password) con **cajas individuales por digito**, auto-avance al escribir, backspace inverso y soporte de paste. Aplica a `<prop type="T">` (alfanumerico) o `<prop type="N">` (solo numérico). El valor combinado de todas las cajas se persiste en el campo del prop como un **string concatenado sin separadores**.

```xml
<!-- OTP numerico de 6 digitos (SMS) -->
<prop name="CODIGO_VERIFICACION" type="N" visible="1"
      viewmode="otp"
      digits="6"
      box-size="44p"
      box-spacing="8p"
      box-color="#FFFFFF"
      box-color-focus="#E3F2FD"
      forecolor="#000000"
      auto-submit="true"
      title="Introduce el código" />

<!-- OTP alfanumerico de 4 caracteres con caracteres ocultos -->
<prop name="MAP_PIN" type="T" visible="1"
      viewmode="otp"
      digits="4"
      allow-letters="true"
      secret="true"
      auto-submit="true" />
```

**Atributos:**

| Atributo | Default | Descripción |
|----------|---------|-------------|
| `digits` | `6` | Número de cajas (debe ser positivo). Cada caja contiene un único carácter |
| `secret` | `false` | Si `true`, muestra los caracteres ocultos (modo password). Útil para PINs |
| `auto-submit` | `true` | Si `true`, al rellenar la última caja se oculta el teclado automáticamente |
| `allow-letters` | `false` | Si `true`, acepta letras además de digitos. Si `false`, solo digitos numéricos |
| `box-size` | `44p` | Tamaño (ancho y alto) de cada caja |
| `box-spacing` | `8p` | Separación horizontal entre cajas |
| `box-color` | — | Color de fondo de las cajas en estado normal |
| `box-color-focus` | usa `box-color` | Color de fondo de la caja con foco |
| `forecolor` | — | Color del texto dentro de las cajas |
| `disableedit` | `false` | Formula o literal; si evalua a `true`, el control queda en solo lectura |

**Comportamiento:**

- **Auto-avance:** al escribir un carácter, el foco salta automáticamente a la caja siguiente.
- **Backspace inverso:** al pulsar borrar sobre una caja **vacia**, el foco retrocede a la anterior y la borra. Funciona incluso con teclados virtuales que no envian `KEYCODE_DEL` cuando no hay texto que borrar.
- **Paste distribuido:** si se pega texto, los caracteres se reparten entre las cajas siguientes (filtrando los no permitidos según `allow-letters`). El foco queda en la última caja rellenada.
- **Filtro de caracteres:** los no permitidos (letras cuando `allow-letters="false"`, símbolos, etc.) se descartan sin escribirse.
- **Auto-submit:** al rellenar la última caja, el teclado se oculta. El framework re-evalua los triggers del campo (por ejemplo, un `<onchange>` que llame al servidor).

**API JavaScript:**

| Método | Efecto |
|--------|--------|
| `control.getOtpValue()` | Devuelve el valor combinado de todas las cajas como string |
| `control.clearOtp()` | Limpia todas las cajas y pone el foco en la primera |
| `control.focusOtp()` | Pone el foco en la primera caja vacia. Si todas están llenas, enfoca la última |

```javascript
// Validar el OTP desde el onchange del prop
function onOtpChange() {
    var sCode = getControl("CODIGO_VERIFICACION").getOtpValue();
    if (sCode.length !== 6) {
        return;
    }
    if (sCode === self.CODIGO_ESPERADO) {
        ui.showToast("Código correcto");
        ui.openEditView("PantallaPrincipal");
    } else {
        ui.showToast("Código incorrecto");
        getControl("CODIGO_VERIFICACION").clearOtp();
    }
}
```

**Casos de uso típicos:** verificación SMS, 2FA con apps de autenticación, PIN de aplicación (con `secret="true"`), códigos de invitacion / cupones (con `allow-letters="true"`).

**Notas:**

- El valor en el `dataObject` se persiste como **string concatenado sin separadores** (ej. `"123456"` para 6 digitos).
- Si el campo tenía un valor previo, las cajas se rellenan al cargar mostrando carácter a carácter.
- El `title` del prop se sigue mostrando como label encima de las cajas.
- Para validar el código sin esperar a `auto-submit`, usar `<onchange>` y comprobar `getOtpValue().length === digits`.

#### 5.9.17d Texto Markdown (viewmode="markdown")

Renderiza el contenido del campo como **Markdown formateado** en lugar de texto plano. Aplica a `<prop type="T">` (texto editable / readonly). El framework parsea el valor del campo cada vez que se refresca la vista y aplica el formato visual (negritas, cabeceras, listas, etc.).

Soporta el dialecto **CommonMark base** (sin extensiones): cabeceras, enfasis, listas, enlaces, imágenes, blockquotes, código inline / en bloque y reglas horizontales. **No soportado por defecto:** tablas, strikethrough (`~~tachado~~`), task lists (`- [x]`), HTML embebido, syntax highlighting.

```xml
<!-- Campo readonly con contenido Markdown -->
<prop name="MAP_DESCRIPCION" type="T" visible="1"
      viewmode="markdown"
      readonly="true"
      width="100%" />

<!-- Campo de texto editable con render Markdown -->
<prop name="NOTAS" type="T" visible="1"
      viewmode="markdown"
      width="100%" height="200p" />
```

Asignacion desde JavaScript:

```javascript
self.MAP_DESCRIPCION =
    "## Bienvenido\n\n" +
    "Este es un texto **importante** con _enfasis_ y un [enlace](https://xone.es).\n\n" +
    "### Pasos:\n" +
    "1. Iniciar sesion\n" +
    "2. Seleccionar proyecto\n" +
    "3. Confirmar\n\n" +
    "> Nota: revisa tus credenciales antes de continuar.";
```

**Atributos:** el viewmode `markdown` **no introduce atributos propios**. Aplican los atributos comunes de `type="T"` (`fontsize`, `forecolor`, `align`, `width`, `height`, margenes, etc.).

**Sintaxis Markdown soportada (CommonMark base):**

| Elemento | Sintaxis |
|----------|----------|
| Cabeceras | `# H1`, `## H2` ... `###### H6` |
| Negrita | `**texto**` o `__texto__` |
| Cursiva | `*texto*` o `_texto_` |
| Negrita + cursiva | `***texto***` |
| Listas no ordenadas | `-`, `*` o `+` al inicio de linea |
| Listas ordenadas | `1.`, `2.`, `3.` ... |
| Enlaces | `[texto](url)` |
| Imágenes | `![alt](url)` |
| Blockquotes | `> texto` |
| Código inline | `` `código` `` |
| Bloques de código | Tres backticks abriendo y cerrando |
| Salto de linea | Doble espacio al final o linea en blanco |
| Regla horizontal | `---`, `***` o `___` |

**Comportamiento:**

- **Refresco:** cada vez que la vista se refresca desde el `dataObject` (carga, `Refresh`, `refreshValue`, asignacion desde JS), el contenido se reparsea y se vuelve a renderizar.
- **Edición:** mientras el usuario edita el campo, las plantillas Android muestran el texto en su forma cruda (markdown sin renderizar); al perder el foco y refrescar, vuelve al estado renderizado. Si el campo debe ser decorativo, usar `readonly="true"` o `locked="true"` para evitar el modo edición accidental.
- **Encoding de saltos de linea:** los saltos en el string Markdown deben ser `\n` reales (no `<br>` ni `\\n` escapado). En XML, usar `&#10;` si el valor esta embebido como atributo.
- **Imágenes:** los URLs deben ser accesibles desde el dispositivo (HTTP/HTTPS o ruta local). Carga sincrona por defecto.

**Casos de uso típicos:** mensajes formateados (instrucciones, avisos, FAQ), descripciones de productos servidas desde backend en Markdown, plantillas dinámicas, cabeceras ricas en pantallas de detalle, renderizado de respuestas de IA / chatbots.

**Notas:**

- Si el contenido viene de una API y puede contener sintaxis desconocida, los caracteres no reconocidos por el parser CommonMark se muestran tal cual (no rompen el render).
- El campo se persiste y se lee como **texto Markdown crudo** (no como HTML ni texto plano sin marcas). Solo cambia la presentación visual.
- Combinable con `autolink`: si Markdown no detecta un URL como link explicito (`[]()`), `autolink="url"` lo puede capturar; aunque normalmente la sintaxis Markdown estándar es suficiente.

#### 5.9.17e NavigationBar pill animada (viewmode="navbar")

Barra de navegación estilo **Material 3** con un indicador **"pill" deslizante** que marca el destino activo. Aplica a `<prop type="N">`: el valor numérico del campo es el **índice del destino seleccionado** (0..N−1). Al tocar un destino se escribe su índice en el campo (dispara el `<onchange>` del prop) y la pill se desliza animadamente hasta él; si el valor cambia por código y se refresca la vista, la pill también se desliza sola.

Los destinos se declaran **inline** en el propio `<prop>` (no desde un `<contents>`): títulos e iconos separados por el carácter barra vertical (`|`).

```xml
<!-- Barra de 3 destinos con icono y texto -->
<prop name="SECCION" type="N" visible="1"
      viewmode="navbar"
      nav-titles="Inicio|Buscar|Perfil"
      nav-icons="ic_home.png|ic_search.png|ic_user.png"
      pill-color="#6750A4"
      pill-text-color="#FFFFFF"
      nav-text-color="#49454F"
      bgcolor="#FEF7FF"
      width="100%" height="80p" />

<!-- Solo texto, con la etiqueta visible únicamente en el destino activo -->
<prop name="PASO" type="N" visible="1"
      viewmode="navbar"
      nav-titles="Datos|Pago|Resumen"
      label-visibility="selected"
      animation-duration="350" />
```

**Atributos:**

| Atributo | Default | Descripción |
|----------|---------|-------------|
| `nav-titles` | — | Títulos de los destinos separados por barra vertical. Determina el número de destinos |
| `nav-icons` | — | Iconos (nombre de recurso, igual que los `img` de un botón) separados por barra vertical, emparejados por posición con los títulos. Conviene que sean monocromos: se tiñen con el color activo / inactivo |
| `pill-color` | `#E8DEF8` | Color de la pill deslizante |
| `pill-text-color` (o `forecolor`) | `#1D192B` | Color de icono + texto del destino activo |
| `nav-text-color` | `#49454F` | Color de icono + texto de los destinos inactivos |
| `bar-color` / `bgcolor` | transparente | Color de fondo de la barra |
| `label-visibility` | `always` | `always` (siempre), `selected` (solo el activo) o `never` (sin etiquetas) |
| `animation-duration` | `300` | Duración del deslizamiento en milisegundos |
| `pill-corner-radius` | mitad de la altura | Radio de las esquinas de la pill (totalmente redondeada si se omite) |
| `nav-icon-size` | `24` | Tamaño del icono en dp |
| `disableedit` / `locked` | `false` | Fórmula o literal; si evalúa a `true`, la barra deja de ser tocable y no muestra efecto al pulsar (queda como indicador) |

**Comportamiento:**

- **Valor = índice:** `0` selecciona el primer destino, `1` el segundo, etc.
- **Toque:** escribe el índice en el campo y desliza la pill; dispara el `<onchange>` del prop.
- **Cambio por código:** asignar el campo y refrescar la vista desliza la pill al nuevo destino.
- **Guarda de rango:** un valor negativo se ajusta a `0` y uno mayor que el último destino al máximo; si el valor guardado estaba fuera de rango, se corrige también en el campo (sin disparar `onchange` en datos válidos).
- **`disableedit` / `locked`:** la barra ignora los toques y no muestra efecto al pulsar, pero sigue animando ante cambios de valor por código (indicador puro).

**API JavaScript:**

| Método | Efecto |
|--------|--------|
| `control.getValue()` | Devuelve el índice del destino seleccionado |
| `control.setValue(n)` | Selecciona el destino `n` (se ajusta al rango), anima y persiste el valor |
| `control.getItemCount()` | Número de destinos |

```javascript
// Reaccionar al cambio de seccion desde el onchange del prop SECCION
function onSeccionChange() {
    var idx = self.SECCION;          // indice del destino activo
    if (idx === 0) { /* mostrar inicio */ }
    else if (idx === 1) { /* mostrar busqueda */ }
    else { /* mostrar perfil */ }
}

// Mover la barra por codigo (la pill se desliza al refrescar)
function irAPerfil() {
    var ctrl = getControl("SECCION");
    ctrl.setValue(2);
}
```

**Casos de uso típicos:** barra de navegación inferior entre secciones de la app, indicador de paso en asistentes (wizard), conmutador de pestañas con feedback animado.

**Notas:**

- El campo se persiste como **entero** (el índice del destino).
- Los iconos deben existir en los recursos del proyecto (misma resolución que los `img` de botón).
- Si solo se indican `nav-icons` sin `nav-titles` (o al revés), los destinos se muestran solo con icono o solo con texto.
- Por defecto la barra ocupa todo el ancho disponible; ajusta `width` / `height` si necesitas otro tamaño.

#### 5.9.18 Password (X)

```xml
<prop name="MAP_PASSWORD" type="X" visible="1"
      floating-tooltip="true"
      tooltip="Contraseña"
      show-password-visibility-toggle="true"
      text-border-bottom="true" />
```

| Atributo | Descripción |
|----------|-------------|
| `show-password-visibility-toggle` | Muestra botón para ver/ocultar la contrasena |

#### 5.9.19 Selector con lookup (`type="T"` + `mapcol`/`mapfld`)

> **No existe un `type="A"` (autocomplete) propio en XOne.** Los selectores con autocompletado/lookup se implementan con `type="T"` (o `type="N"`) y los atributos `mapcol`/`mapfld`/`linkedfield`. Es la misma mecanica que el combo de §5.9.13.

```xml
<prop name="CIUDAD" type="T" visible="1"
      title="Ciudad"
      mapcol="Ciudades"
      mapfld="ID"
      linkedfield="NOMBRE" />
```

#### 5.9.20 Adjunto (AT)

```xml
<prop name="MAP_ADJUNTO" type="AT" visible="1"
      title="Adjuntar archivo"
      img-width="48p" img-height="48p" />
```

#### 5.9.21 THTML (Texto HTML enriquecido)

Muestra contenido HTML formateado directamente en el prop. Útil para mostrar textos con negrita, colores, enlaces, etc.

```xml
<prop name="MAP_TEXTO_RICH" type="THTML" visible="1"
      locked="true"
      width="100%" height="-2"
      labelwidth="0" />
```

```javascript
// Asignar contenido HTML por código
self.MAP_TEXTO_RICH = "<b>Importante:</b> El plazo vence el <span style='color:red'>31/12</span>";
```

#### 5.9.22 DR — Firma / Dibujo moderno

El tipo `DR` es el modo moderno para capturar firmas y dibujos a mano alzada. Sustituye al método antiguo (`type="IMG"` con `readonly="false"`).

```xml
<prop name="FIRMA" type="DR" visible="1"
      width="90%"
      height="300p"
      labelwidth="0" />
```

> **Nota:** El tipo `DR` guarda la firma como imagen en la BD (campo `Varchar(100)` con ruta al fichero).

#### 5.9.23 Enlace a coleccion (mapcol / mapfld)

Para crear un desplegable vinculado a una coleccion de la BD se usan dos props: uno oculto que almacena la clave foranea, y uno visible que muestra la descripción.

```xml
<!-- Prop oculto: almacena el ID del cliente seleccionado -->
<prop name="IDCLIENTE" type="N" visible="0"
      mapcol="Clientes"
      mapfld="ID" />

<!-- Prop visible: muestra el nombre del cliente -->
<prop name="MAP_NOMBRE_CLIENTE" type="T" visible="1"
      title="Cliente"
      linkedto="IDCLIENTE"
      linkedfield="NOMBRE"
      showinline="true" />
```

| Atributo | Donde va | Descripción |
|----------|----------|-------------|
| `mapcol` | Prop oculto | Nombre de la coleccion de donde se obtienen las opciones |
| `mapfld` | Prop oculto | Campo clave de esa coleccion (normalmente `ID`) |
| `filter` | Prop oculto | Filtro opcional para las opciones del combo |
| `linkedto` | Prop visible | Nombre del prop oculto al que esta vinculado |
| `linkedfield` | Prop visible | Campo de la coleccion a mostrar como texto |
| `showinline` | Prop visible | `true` abre las opciones en un panel de selección inferior (con `showinline-keyboard="true"` incluye buscador); `false` abre un diálogo |

#### 5.9.24 Busqueda contextual (contextual-search)

Permite filtrar un contents en tiempo real mientras el usuario escribe en un campo de texto.

```xml
<!-- Campo de busqueda -->
<prop name="MAP_BUSCAR" type="T" visible="1"
      tooltip="Escriba para buscar..."
      contextual-search="true"
      contextual-target="MAP_LISTADO"
      contextual-filter="NOMBRE LIKE '%##VAL##%' OR CODIGO LIKE '%##VAL##%'"
      labelwidth="0" width="100%" height="100p" />

<!-- Contents que se filtra automaticamente -->
<prop name="MAP_LISTADO" type="Z" visible="1"
      contents="@ListadoClientes"
      width="100%" height="600p" />
<contents name="@ListadoClientes" src="Clientes" />
```

| Atributo | Descripción |
|----------|-------------|
| `contextual-search` | `"true"` activa la busqueda contextual |
| `contextual-target` | Nombre del prop `type="Z"` que se va a filtrar |
| `contextual-filter` | Clausula WHERE que se aplica al contents. `##VAL##` se sustituye por el texto introducido |

#### 5.9.25 onchange y refresco

El atributo `onchange` indica que debe ocurrir cuando el valor del campo cambia. En proyectos modernos (Android/iOS) basta con `onchange="refresh"` para refrescar toda la pantalla.

```xml
<!-- Refresco simple al cambiar -->
<prop name="ESTADO" type="N" visible="1"
      onchange="refresh" />

<!-- Refresco de un prop específico -->
<prop name="FECHA" type="D" visible="1"
      onchange="refresh(MAP_DIAS_RESTANTES)" />

<!-- Ejecutar un nodo custom al cambiar -->
<prop name="TIPO" type="T" visible="1"
      onchange="ExecuteNode(calcularTotal)" />
```

> **Nota historica:** En versiones antiguas (PDA/PocketPC) se usaban valores numéricos como `onchange="refresh255"` (bitmask que indicaba que partes refrescar). En proyectos modernos siempre usar `onchange="refresh"`.

**`onvaluechanged`** — evento para **lógica de datos**. Su valor es **JavaScript inline normal** (como `onclick`) y se dispara desde la capa de datos, por lo que se ejecuta siempre que el campo cambie de valor **aunque no haya pantalla abierta** (cambios por script de fondo, réplica, etc.). Recibe un objeto `e` con `e.value`, `e.oldValue`, `e.target` (campo), `e.objItem` (objeto) y `e.data`. Solo JavaScript.

```xml
<prop name="CANTIDAD" type="N" visible="1"
      onvaluechanged="self.TOTAL = e.value * self.PRECIO;" />
```

> Útil para lógica que debe ejecutarse siempre que el dato cambie, haya o no pantalla abierta. Detalle completo en [topics/05-events-patterns-faq.md §3.2](05-events-patterns-faq.md).

#### 5.9.26 Propagacion de cambios (updates) y formula

**`updates`** — propaga el valor de este campo hacia un campo de una coleccion contents cuando cambia:

```xml
<!-- Al cambiar MAP_ARTICULO, su valor se copia al campo DESCRIPCION del objeto padre -->
<prop name="MAP_ARTICULO" type="T" visible="7"
      linkedto="IDARTICULO"
      linkedfield="ETIQUETA"
      updates="DESCRIPCION" />
```

**`formula`** — calcula el valor del prop mediante una consulta SQL externa:

```xml
<!-- El valor se calcula con una SQL definida en <ext-formula> -->
<prop name="MAP_TOTAL_PEDIDOS" type="N"
      formula="ext.[TOTAL_PEDIDOS]"
      onchange="refresh"
      visible="3" />

<!-- Definición de la formula en el nodo coll -->
<ext-formula>
    <param name="TOTAL_PEDIDOS"
           sql="SELECT COUNT(*) AS N FROM ##PREF##Pedidos WHERE IDCLIENTE=##ID##"
           field="N" type="N" cache="true" />
</ext-formula>
```

| Atributo | Descripción |
|----------|-------------|
| `formula` | Referencia a una formula definida en `<ext-formula>`. Formato: `ext.[NOMBRE_FORMULA]` |
| `cache` | En `<ext-formula>`: `true` cachea el resultado para no recalcular en cada refresco |

### 5.10 Buenas prácticas

1. **Prefijo `MAP_`** para campos de UI temporal (no se guardan en BD).
2. **MAYUSCULAS** para campos de BD: `NOMBRE`, `DIRECCION`, `FECHA`.
3. **`labelwidth="0"`** cuando no necesitas etiqueta (botones de icono, imágenes, o campos cuyo contenido va en el *valor*: `T`, `N`, etc.). **NUNCA en `type="L"`/`TL`**: el texto del label (su `title`, o el valor del campo si no hay `title`) se pinta dentro del ancho de la etiqueta; con `labelwidth="0"` no queda sitio y el texto se vuelve invisible. Para alinear un label usa `label-align="left|center|right"`, no `labelwidth`.
4. **`visible="0"`** para campos internos/auxiliares.
5. **`type="L"`** para textos que solo se muestran, nunca `type="T"` con `locked="true"`. Un label muestra su `title`; si no declaras `title`, muestra el valor del campo, así que también sirve para valores dinámicos.
6. **`onclick` vs `method`**: Usa `method` para lógica compleja con nodos XML, `onclick` para JavaScript simple y directo. **No combines ambos** en el mismo prop.
7. **`viewmode="recyclerview"`** siempre para listas largas, mejora el rendimiento.

### 5.11 Errores comunes

| Error | Consecuencia | Solución |
|-------|-------------|----------|
| Olvidar `type` | Error de parseo XML | Siempre incluir `type` |
| `visible` incorrecto | Campo no aparece donde se espera | Revisar el bitmask (7 = todos) |
| `onclick` y `method` juntos | Solo se ejecuta uno | Usar uno u otro |
| `linkedto` sin `mapcol` en el prop oculto | Combo no carga opciones | Asegurar que el prop oculto tiene `mapcol` y `mapfld` |
| `contents` sin prefijo `@` | El content no se vincula | Usar `contents="@NombreContent"` |
| Usar `px` en lugar de `p` | Unidad no reconocida | Usar `p` (puntos) o `%` |
| Inventar atributos | Se ignoran silenciosamente | Consultar esta documentación |

---

**Anterior:** [02a - Estructura: coll, group, frame](02a-xml-estructura.md) · **Siguiente:** [02c - Contents, macros, patrones de pantalla](02c-xml-contents-patrones.md) · **Índice:** [02 - Guía XML/UI](02-xml-ui-complete-guide.md)
