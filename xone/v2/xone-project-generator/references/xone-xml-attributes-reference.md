# Referencia Completa de Atributos XML en XOne

Documentación de todos los atributos XML que el framework reconoce en los nodos principales.

> **Convenciones**
> - **Obligatorio**: Si = debe estar presente. No = opcional.
> - **Default**: valor por defecto si el atributo no esta. "heredado" = se busca en `<platform>`, CSS, o nodo padre.
> - Los valores `bool` admiten `true`/`false` (también `1`/`0`, `yes`/`no`).
> - Los valores `formula` son formulas evaluables sobre los campos del objeto actual.
> - Las medidas aceptan sufijo `dp` (density-independent), `p` (pixels) o `%` (porcentaje del padre).
> - Colores: `#RRGGBB` o `#AARRGGBB` (alpha primero).

---

## Tabla de Contenidos

1. [Nodo `<coll>` — Coleccion/Pantalla](#1-nodo-coll--coleccionpantalla)
2. [Nodo `<group>` — Grupo](#2-nodo-group--grupo)
3. [Nodo `<frame>` — Frame/Contenedor](#3-nodo-frame--framecontenedor)
4. [Nodo `<prop>` — Propiedad/Campo](#4-nodo-prop--propiedadcampo)
5. [Nodo `<method>` — Método ejecutable](#5-nodo-method--metodo-ejecutable)
6. [Nodo `<macro>` — Macro de coleccion](#6-nodo-macro--macro-de-coleccion)
7. [Nodo `<script>` — Script](#7-nodo-script--script)
8. [Nodo `<event>` — Eventos disponibles](#8-nodo-event--eventos-disponibles)
9. [Nodo `<platform>` — Override por plataforma](#9-nodo-platform--override-por-plataforma)
10. [Tipos de propiedad (atributo `type`)](#10-tipos-de-propiedad-atributo-type)
11. [Atributos globales de la app](#11-atributos-globales-de-la-app)

---

## 1. Nodo `<coll>` — Coleccion/Pantalla

Define una tabla de datos (mapeada a SQL) o una pantalla de UI. Es el nodo raiz de cada fichero `.xne`.

> **REGLAS GENERALES DE NAMING (aplican a coll/group/frame/prop):**
>
> - **`name` es case-sensitive.** `name="MiNombre"` y `name="minombre"` son **distintos**. Aplica también a referencias cruzadas: `self.X`, `mapcol`, `linkedto`, `inherits`, `<field name="...">`, `getControl("...")`, `ui.openEditView("...")`, `appData.getCollection("...")`.
> - **El `id` de `<group>` es obligatorio y único en la coll.** Dos `<group id="1">` en la misma coll producen comportamiento indefinido.
> - **Unicidad de `name` en la coll.** No puede repetirse el `name` de ningun nodo dentro de una `<coll>`, aunque estén en grupos/frames distintos.

### 1.1 Atributos de identificación y datos

| Atributo | Tipo | Obligatorio | Default | Descripción |
|---|---|---|---|---|
| `name` | string | **Sí** | — | Identificador único de la colección. Usar PascalCase. **Case-sensitive.** |
| `title` | string | No | `name` | Título visible en la UI. |
| `sql` | string | No | — | Sentencia SQL `SELECT`. Usar `##PREF##` para el prefijo de tabla. |
| `objname` | string | No | — | Nombre de la tabla para operaciones de lectura. |
| `updateobj` | string | No | — | Nombre de la tabla para INSERT/UPDATE/DELETE. |
| `progid` | string | No | — | Identificador del objeto de negocio. **Opcional**: sin él la coll es un objeto de datos genérico (≡ `ASData.CASBasicDataObj`). Solo casos especiales: `ASGestion.CASEmpresa` (Empresas), `ASGestion.CASUser` (Usuarios). |
| `connection` | string | No | conexión por defecto | Nombre de la conexión en `<connection>`. |
| `filter` | string | No | `""` | Filtro SQL adicional (cláusula WHERE). |
| `sort` | string | No | `""` | Orden de datos (cláusula ORDER BY). |
| `loadall` | bool | No | `false` | Carga todos los registros al inicializar. |
| `volatile` | bool | No | `false` | No cachea objetos; siempre relee de BD. |
| `stringkey` | bool | No | `false` | La PK es de tipo string. |
| `threshold` | int | No | `200` | Tamaño máximo de la caché LRU de objetos. |
| `userawsql` | bool | No | `false` | No reescribe el SQL (lo usa tal cual). |
| `idfieldname` | string | No | `ID` | Nombre del campo PK cuando no se llama `ID`. |
| `dependent` | bool | No | `false` | Indica si la colección depende de una colección padre. |
| `check-owner` | bool | No | `false` | Verifica que los registros pertenezcan al usuario/empresa actual. |
| `autorefresh` | bool | No | `false` | Refresca datos automáticamente al regresar de otra ventana. |
| `inherits` | string | No | `""` | Nombre de coll de la que se hereda estructura visual. |

### 1.2 Atributos de UI/celda en listas

| Atributo | Tipo | Default | Descripción |
|---|---|---|---|
| `cell-width` | medida | auto | Ancho fijo de celda en grid. |
| `cell-height` | medida | auto | Alto fijo de celda en grid. |
| `cell-bgcolor` | color | heredado | Color de fondo de celda. |
| `cell-bgcolor_out` | color | heredado | Color de fondo fuera del viewport. |
| `cell-forecolor` | color | heredado | Color de texto de celda. |
| `cell-forecolor_out` | color | heredado | Color texto fuera del viewport. |
| `cell-border-color` | color | — | Color del borde de celda. |
| `cell-border-width` | medida | `0` | Grosor del borde de celda. |
| `cell-even-color` | color | — | Color para filas pares (zebra). |
| `cell-odd-color` | color | — | Color para filas impares (zebra). |
| `cell-selected-bgcolor` | color | — | Fondo de celda seleccionada. |
| `cell-selected-forecolor` | color | — | Texto de celda seleccionada. |
| `cell-selected-border-color` | color | — | Borde de celda seleccionada. |
| `cell-selected-border-width` | medida | — | Grosor borde celda seleccionada. |
| `editinline-rows` | int | `1` | Filas visibles en edición inline. |
| `no-data-text` | string | `""` | Texto cuando no hay registros. |
| `start-from-bottom` | bool | `false` | Scroll anclado al final de la lista (chats). Declarable en la coll o en el content (`type="Z"`); el del content tiene preferencia. |
| `divider-height` | int | — | Alto (grosor) del separador entre ítems de la lista (`type="Z"`). En listas expandibles el default es `4`. |
| `divider-color` | color | — | Color del separador entre ítems de la lista (`type="Z"`). |
| `divider-background` | string | — | Imagen (ruta de recurso) usada como separador entre ítems; tiene prioridad sobre `divider-color`. |
| `page-limit-off` | bool | `false` | Desactiva la paginación automática. |

### 1.3 Atributos de pantalla y comportamiento

| Atributo | Tipo | Default | Descripción |
|---|---|---|---|
| `special` | bool | `false` | Coleccion de pantalla pura (sin datos). |
| `notab` | bool | `false` | No muestra pestanas aunque haya varios grupos. |
| `show-toolbar` | bool | `true` | Muestra la toolbar. |
| `fullscreen` | bool | `false` | Pantalla a fullscreen. |
| `secure-window` | bool | `false` | Bloquea capturas de pantalla del sistema. |
| `disable-keyguard` | bool | `false` | Desbloquea el teclado al mostrar la pantalla. |
| `keep-screen-on` | bool | `false` | Mantiene la pantalla encendida mientras esta visible. |
| `ignore-safe-area` | bool | `false` | Ignora la safe-area del sistema (notch, barra de navegación). |
| `load-imgbk` | bool | `false` | Carga la imagen de fondo durante la carga inicial. |
| `load-wait` | bool | `true` | Muestra el dialogo de espera durante la carga. |
| `show-async` | bool | `false` | Muestra la pantalla aunque aún estén cargando datos. |
| `fixed-group` | int | `-1` | ID de grupo siempre visible (header fijo). |
| `tab-height` | medida | auto | Alto de la barra de pestanas. |
| `tab-orientation` | enum | `top` | `top` o `bottom`. Posición de la barra de pestanas. |
| `toolbar-bgcolor` | color | — | Fondo de la toolbar. |
| `toolbar-forecolor` | color | — | Texto de la toolbar. |
| `window-keyboard-behaviour` | enum | `adjustResize` | Modo del teclado software: `adjustResize`, `adjustPan`, `adjustNothing`. |
| `screen-orientation` | enum | `sensor` | `portrait`, `landscape`, `reversePortrait`, `reverseLandscape`, `sensorPortrait`, `sensorLandscape`, `sensor`. |
| `resolution-width` | int | auto | Ancho lógico de diseño (el contenido se escala a este ancho). |
| `resolution-height` | int | auto | Alto lógico de diseño. |
| `remote-mapcoll` | string | `""` | Coleccion remota para uso con mapas. |
| `login-coll` | string | `""` | Marca esta coll como pantalla de login. |
| `logoff-coll` | string | `""` | Marca esta coll como pantalla de logoff. |
| `readonly` | bool | `false` | Toda la colección es de **solo lectura a nivel de persistencia**: ni INSERT ni UPDATE en BD. Útil para colls que solo muestran datos sin permitir grabar. No tiene efecto sobre la UI de los controles individuales (esa se controla con `locked` / `disableedit` en cada `<prop>`). |
| `class` | string | `""` | Clase CSS aplicada a la coleccion. |

### 1.4 Nodos especiales hijos de `<coll>`

| Nodo hijo | Descripción |
|---|---|
| `<create>` | Script ejecutado una sola vez al crear el objeto (primera apertura). |
| `<before-edit>` | Script al abrir para edición. **Usar para inicializar la pantalla.** |
| `<after-edit>` | Script tras entrar en modo edición. |
| `<load>` | Se dispara **por cada DataObject** al cargarse desde la BD: tanto al recorrer la coleccion (`startBrowse()`/`loadAll()`) como al hidratar items de un `<contents>` o cargas individuales. **NO es evento de pantalla** y **NO recomendado** por impacto en rendimiento. |
| `<onchange>` | Script al cambiar el valor de un campo (necesita `<field name="CAMPO">`). |
| `<selecteditem>` | Script al pulsar un item de lista. |
| `<auto-selecteditem>` | Selecciona automáticamente un item al cargar. |
| `<onlongpressitem>` | Script al hacer long-press sobre un item. |
| `<onback>` | Script al pulsar el botón atrás. |
| `<macro>` | Declara una macro de coleccion (ver sección 6). |
| `<contents>` | Coleccion anidada embebida. |
| `<permissions>` | Permisos del sistema requeridos. |
| `<platform>` | Override de atributos por plataforma (ver sección 10). |

```xml
<coll name="MiPantalla" title="Mi Pantalla" special="true" notab="true"
      show-toolbar="false" keep-screen-on="true" screen-orientation="portrait">
    <before-edit refresh="false" show-wait-dialog="false">
        <action name="runscript">
            <script language="javascript">inicializar();</script>
        </action>
    </before-edit>
    <group name="grpMain" id="1">
        <!-- ... -->
    </group>
</coll>
```

---

## 2. Nodo `<group>` — Grupo

Agrupa propiedades en una pestana o sección lógica dentro de una coleccion.

| Atributo | Tipo | Obligatorio | Default | Descripción |
|---|---|---|---|---|
| `name` | string | **Si** | — | Nombre único del grupo dentro de la coll. |
| `id` | int/string | **Si** | — | Identificador numérico **único dentro de la coll**. Si dos `<group>` comparten `id` en la misma coll el comportamiento es indefinido. Convencion: `1, 2, ...` normales; `999` HEADER fijo, `0` FOOTER fijo. |
| `title` | string | No | `id` | Título visible de la pestana. |
| `visible` | int (mask) | No | `-1` | Mascara binaria de visibilidad (misma lógica que `<prop>`). |
| `disableedit` | formula | No | `""` | Si la fórmula es verdadera, todos los controles del grupo quedan bloqueados para edición en la **UI** (equivalente a aplicar `locked="true"` a todos los `<prop>` del grupo). No afecta a la persistencia. |
| `disablevisible` | formula | No | `""` | Si la formula es verdadera, el grupo se oculta. |
| `fixed` | bool | No | `false` | Grupo fijo: no scrollea con el contenido. |
| `cache-groups` | bool | No | `false` | Cachea el contenido renderizado del grupo para mejorar rendimiento. |
| `drawer-orientation` | enum | No | `left` | `left` o `right`. Lado por el que aparece el drawer lateral. |
| `tab-theme` | string | No | tema actual | Tema visual de las pestanas. |
| `tab-width` | medida | No | auto | Ancho de cada pestana. |
| `group-theme` | string | No | tema actual | Tema visual del grupo. |
| `group-swipe` | bool | No | `true` | Permite cambiar de grupo deslizando horizontalmente. |
| `page-limit-off` | bool | No | `false` | Desactiva el limite de paginación visual del grupo. |
| `page-margin` | medida | No | `10dp` | Margen entre páginas al paginar. |
| `float-over-drawer` | bool | No | `false` | Los elementos flotantes se muestran sobre el drawer. |
| `bgcolor` | color | No | heredado | Color de fondo del grupo. |
| `forecolor` / `fgcolor` | color | No | heredado | Color de texto del grupo. |
| `class` | string | No | `""` | Clase CSS. |

```xml
<group name="grpPrincipal" id="1" group-swipe="true" tab-orientation="bottom">
    <!-- frames y props aquí -->
</group>
```

---

## 3. Nodo `<frame>` — Frame/Contenedor

Contenedor visual dentro de un grupo. Puede anidarse.

### 3.1 Identidad y posicionamiento

| Atributo | Tipo | Obligatorio | Default | Descripción |
|---|---|---|---|---|
| `name` | string | **Si** | — | Nombre único del frame dentro de la coll. |
| `group` | int | **Si** | — | ID del grupo al que pertenece. |
| `frame` | string | No | `""` | Nombre del frame padre (anidado). |
| `title` | string | No | `""` | Título mostrado en la cabecera del frame (si aplica). |
| `floating` | bool | No | `false` | Posicionamiento absoluto (saca el frame del flujo normal). |
| `top` / `left` / `right` / `bottom` | medida | No | — | Posición absoluta. Solo con `floating="true"`. |
| `width` / `height` | medida | No | auto | Tamaño explicito. `-1` = ocupar todo el espacio restante. `-2` = igual que `-1` pero con scroll. |
| `min-width` / `max-width` / `min-height` / `max-height` | medida | No | — | Restricciones de tamaño. |
| `newline` | bool | No | `true` | Salto de linea antes del frame. |
| `zorder` | int | No | `0` | Orden Z (profundidad) del frame. |

### 3.2 Comportamiento y scroll

| Atributo | Tipo | Default | Descripción |
|---|---|---|---|
| `scroll` | bool | `false` | Activa scroll interno en el frame. |
| `modal` | bool | `false` | Frame modal (bloquea interaccion con el resto). |
| `disableedit` | formula | `""` | Si verdadero, deshabilita el frame y todos sus hijos. |
| `disablevisible` | formula | `""` | Si verdadero, oculta el frame. |
| `ignore-touch-on-transparent-area` | bool | `false` | Los toques sobre áreas transparentes pasan al elemento del fondo. |
| `blend-bgcolor-with-image` | bool | `false` | Mezcla el color de fondo con la imagen de fondo. |

### 3.3 Drag & Drop

| Atributo | Tipo | Default | Descripción |
|---|---|---|---|
| `drag-enable` | bool | `false` | El frame es arrastrable. |
| `drag-area` | string | `""` | Nombre del hijo que actua como manija de arrastre. |
| `drag-opaque` | bool | `false` | El frame es opaco durante el arrastre. |
| `drop-target` | bool | `false` | Este frame acepta elementos soltados (drop). |
| `dropcoll` | string | `""` | Coleccion destino al soltar un elemento. |
| `notify-only-when-dropped` | bool | `false` | Solo dispara el evento al soltar (no durante el arrastre). |

### 3.4 Apariencia

| Atributo | Tipo | Default | Descripción |
|---|---|---|---|
| `bgcolor` | color | heredado | Color de fondo del frame. |
| `forecolor` | color | heredado | Color de texto del frame. |
| `border` | int (mask) | `0` | Bordes activos: top=1, right=2, bottom=4, left=8. Sumar para combinar. |
| `border-color` | color | — | Color del borde. |
| `border-width` | medida | `0` | Grosor del borde. |
| `border-corner-radius` | medida | `0` | Radio de esquinas redondeadas. |
| `tmargin` / `bmargin` / `lmargin` / `rmargin` | medida | `0` | Margenes externos. |
| `tpadding` / `bpadding` / `lpadding` / `rpadding` | medida | `0` | Padding interno. |
| `class` | string | `""` | Clase CSS. |
| `imgbk` | string | `""` | Imagen de fondo del frame. |

```xml
<frame name="frmHeader" group="1" width="100%" height="140p"
       bgcolor="#1565C0" lpadding="15p" rpadding="15p">
    <!-- props aquí -->
</frame>

<!-- Frame flotante (overlay) -->
<frame name="frmOverlay" group="1" floating="true"
       top="50p" left="10%" width="80%" height="200p"
       bgcolor="#FFFFFF" border-corner-radius="12" zorder="10">
</frame>
```

---

## 4. Nodo `<prop>` — Propiedad/Campo

### 4.1 Identidad y obligatorios

| Atributo | Tipo | Obligatorio | Default | Descripción |
|---|---|---|---|---|
| `name` | string | **Si** | — | Nombre del campo (= columna SQL). Usar `MAP_` si no es columna BD. |
| `type` | enum | **Si** | — | Tipo de dato. Ver [sección 10](#10-tipos-de-propiedad-atributo-type). |
| `group` | int | **Si** | — | ID del grupo donde se renderiza. |
| `title` | string | No | `name` | Etiqueta visible. |
| `value` | string/formula | No | `""` | Valor inicial. |
| `size` | int | No | `0` | Tamaño máximo del campo en BD. |
| `fldname` | string | No | `""` | Nombre de la columna en BD si difiere de `name`. |

### 4.2 Layout

| Atributo | Tipo | Default | Descripción |
|---|---|---|---|
| `frame` | string | `""` | Frame padre donde se renderiza. |
| `subgroup` | int | `-1` | Subgrupo dentro del grupo. |
| `newline` | bool | `true` | Salto de linea antes del control. |
| `width` | medida | auto | Ancho del control. |
| `height` | medida | auto | Alto del control. |
| `min-width` / `max-width` / `min-height` / `max-height` | medida | — | Restricciones de tamaño. |
| `lines` | int | `1` | Número de lineas de texto visibles. |
| `fixed-lines` | int | `0` | Lineas de texto fijas. |
| `floating` | bool | `false` | Posicionamiento absoluto. |
| `top` / `left` / `right` / `bottom` | medida | — | Posición absoluta (requiere `floating="true"`). |
| `scroll` | bool | `false` | Scroll interno del control. |
| `align` | enum | `left` | `left`, `center`, `right`. Alineacion horizontal del control. |
| `vertical-align` | enum | `middle` | `top`, `middle`, `bottom`. Alineacion vertical. |
| `text-align` | enum | `left` | Alineacion del texto dentro del campo. |
| `label-align` | enum | `left` | Alineacion del label. |
| `labelwidth` | int | `10` | Ancho del label en caracteres. |
| `fieldsize` | int | `14` | Tamaño del área de campo. |
| `width-to-text` | bool | `false` | Ajusta el ancho del control al texto que contiene. |
| `tmargin` / `bmargin` / `lmargin` / `rmargin` | medida | `0` | Margenes externos. |
| `tpadding` / `bpadding` / `lpadding` / `rpadding` | medida | `0` | Padding interno. |
| `zorder` | int | `0` | Orden Z. |
| `elevation` | medida | `0` | Sombra/elevacion Material Design. |

### 4.3 Visibilidad y estado

| Atributo | Tipo | Default | Descripción |
|---|---|---|---|
| `visible` | int (mask) | `-1` | Mascara binaria: 0=oculto, 1=formulario, 2=lista, 4=contents, 7=todos. |
| `disableedit` | formula | `""` | Si la fórmula es verdadera, bloquea la **UI** de edición del control (versión dinámica de `locked`); se OR-ea con `locked`. **No** afecta a la persistencia. |
| `disablevisible` | formula | `""` | Si verdadero, el campo se oculta. |
| `readonly` | bool | `false` | **Persistencia**: excluye el campo del UPDATE en BD (el framework lo interpreta como "no actualizable"). **No** bloquea la UI en `T`/`N`/`NC`/spinners/etc. Caso especial: en `<prop type="VD">` actúa como flag de UI (`true` = reproducir, `false` = capturar). Ver nota abajo. |
| `locked` | bool | `false` | **UI**: bloquea visualmente la edición del control (lo respetan inputs de texto, números, spinners, checkboxes, OTP, sliders, kanban, charts, etc.). Equivalente estático de `disableedit`. **No** afecta a la persistencia: si el valor cambia desde JS, se graba. Ver nota abajo. |
| `showinline` | bool | `false` | Muestra dentro de la fila de lista. |
| `showinline-keyboard` | bool | `false` | En selectores `linkedto`/`linkedfield` con `showinline="true"`, añade una caja de búsqueda en la cabecera del panel para filtrar las opciones por texto. |
| `bgcolor-dialog` | color | — | Color de fondo del panel de selección del showinline y de los selectores de fecha/hora (`D`/`DT`/`TT`). |
| `forecolor-dialog` | color | — | Color de primer plano: en el showinline tiñe el texto de las opciones; en los pickers de fecha/hora actúa como color de acento (día/hora seleccionados, botones). |
| `fontsize-dialog` | int (sp) | — | Tamaño del texto de las opciones del showinline y de los números de los pickers de fecha/hora. |
| `listview-visible` | bool | `false` | Visible en la vista de lista. |
| `listview-position` | int | `0` | Orden en la lista. |
| `listview-line` | int | `0` | Linea en la lista (0=primera, 1=segunda...). |
| `apply-css` | bool | `true` | Aplica reglas CSS al control. |
| `class` | string | `""` | Clase CSS. |

> **Nota: `readonly` vs `locked` vs `disableedit` NO son sinónimos.**
>
> - **`locked="true"`** (estático) y **`disableedit="<fórmula>"`** (dinámico) bloquean la **UI** del control (se OR-ean entre sí). **No** afectan a la persistencia — si el valor se cambia desde JavaScript con `self.X = ...`, sí se graba.
> - **`readonly="true"` en `<prop>`** excluye el campo del **UPDATE en BD**. **No** bloquea la UI por sí mismo en controles de texto / numéricos / checks / spinners.
> - **`readonly="true"` en `<coll>`** hace toda la colección no escribible (ni INSERT ni UPDATE).
> - **Caso especial `<prop type="VD">`**: reinterpreta `readonly` como flag de UI (`true` = solo reproducir, `false` = capturar).
>
> Si necesitas un campo visible pero ni editable ni grabable, combina ambos: `locked="true" readonly="true"`. Si solo quieres mostrar texto sin valor en BD, usa `type="L"` (label) en lugar de `type="T" locked="true"`.

### 4.4 Textos y fuentes

| Atributo | Tipo | Default | Descripción |
|---|---|---|---|
| `caption` | string | `""` | Texto placeholder (hint). |
| `tooltip` | string | `""` | Texto hint/placeholder que se muestra **dentro** del campo editable mientras está vacío y **desaparece automáticamente al empezar a escribir**. Es el sustituto correcto de `title` cuando se oculta la etiqueta con `labelwidth="0"` (en ese caso el `title` no se renderiza por ningún sitio). |
| `tooltip-forecolor` | color | — | Color del texto del tooltip. |
| `floating-tooltip` | bool | `false` | Si `true`, el `tooltip` se comporta como **floating label** estilo Material Design: al recibir foco/empezar a escribir, el texto del tooltip se desplaza arriba del campo y permanece visible, en lugar de desaparecer. Útil para que el usuario siga viendo la etiqueta mientras edita. |
| `fontname` | string | tema | Nombre del fichero de fuente (ej. `Roboto-Regular.ttf`). |
| `fontsize` | int (sp) | `14` | Tamaño en sp. |
| `fontbold` | bool | `false` | Negrita. |
| `fontitalic` | bool | `false` | Cursiva. |
| `fontunderline` | bool | `false` | Subrayado. |
| `auto-fontsize` | bool | `false` | Reduce automáticamente el tamaño de fuente para que entre el texto. |
| `textfont-name` | string | — | Fuente del valor editable. |
| `textfont-size` | int | — | Tamaño de fuente del valor. Aliases: `textfontsize`, `text-font-size`. |
| `textfont-bold` | bool | `false` | Valor en negrita. |
| `textfont-italic` | bool | `false` | Valor en cursiva. |
| `labelfontsize` | int | — | Tamaño de fuente del label. |
| `labelfont-name` | string | — | Fuente del label. |
| `labelfont-bold` | bool | `false` | Label en negrita. |
| `label-format` | string | `""` | Formato printf del label (ej. `"Total: %.2f"`). |
| `label-value-decimals` | int | `2` | Decimales del label cuando es numérico. |
| `label-wrap` | bool | `false` | Permite wrap del texto del label. |
| `labelbox` | bool | `false` | Dibuja una caja alrededor del label. |
| `framebox` | bool | `false` | Dibuja una caja alrededor del control completo. |
| `fixed-text` | bool | `false` | Texto del label fijo (no se traduce con el sistema de idiomas). |
| `locale` | string | locale del sistema | Locale para formateo de números y fechas. |

### 4.5 Colores

| Atributo | Tipo | Default | Descripción |
|---|---|---|---|
| `bgcolor` | color | heredado | Fondo del control. |
| `bgcolor-pressed` | color | — | Fondo cuando el control esta pulsado. |
| `bgcolor-disabled` | color | — | Fondo cuando el control esta deshabilitado. |
| `forecolor` | color | heredado | Color de texto del label. |
| `forecolor-pressed` | color | — | Color de texto pulsado. |
| `forecolor-disabled` | color | — | Color de texto deshabilitado. |
| `text-bgcolor` | color | — | Fondo del área de texto editable. |
| `text-bgcolor-focus` | color | — | Fondo del área de texto cuando tiene foco. |
| `text-forecolor` | color | — | Color del valor escrito. |
| `text-forecolor-focus` | color | — | Color del valor cuando tiene foco. |
| `border-color` | color | — | Color del borde del control. |
| `border-color-focus` | color | — | Color del borde cuando tiene foco. |
| `link-color` | color | sistema | Color de enlaces en controles `THTML`. |
| `bar-color` | color | — | Color de la barra de progreso (`progress-bar`). |
| `track-color` | color | — | Color de la pista (slider, switch). |
| `track-color-checked` | color | — | Color de la pista cuando esta marcado. |
| `thumb-color` | color | — | Color del pulsador del slider. |
| `thumb-color-checked` | color | — | Color del pulsador cuando esta marcado. |
| `check-color-checked` | color | — | Color del checkbox cuando esta marcado. |
| `check-color-unchecked` | color | — | Color del checkbox sin marcar. |
| `status-bar-color` | color | — | Color de la barra de estado del sistema. |

### 4.6 Bordes

| Atributo | Tipo | Default | Descripción |
|---|---|---|---|
| `border` | int (mask) | `0` | Bordes activos: top=1, right=2, bottom=4, left=8. Sumar para combinar (ej. `15` = todos). |
| `border-top` / `border-bottom` / `border-left` / `border-right` | bool | `false` | Activar bordes individuales. |
| `border-width` | medida | `0` | Grosor del borde. |
| `border-corner-radius` | medida | `0` | Radio común de esquinas redondeadas. |
| `border-corner-radius-top-left` | medida | `0` | Radio esquina superior izquierda. |
| `border-corner-radius-top-right` | medida | `0` | Radio esquina superior derecha. |
| `border-corner-radius-bottom-left` | medida | `0` | Radio esquina inferior izquierda. |
| `border-corner-radius-bottom-right` | medida | `0` | Radio esquina inferior derecha. |

### 4.7 Imágenes e iconos

| Atributo | Tipo | Default | Descripción |
|---|---|---|---|
| `img` | string | `""` | Imagen principal del control. |
| `img-sel` | string | `""` | Imagen en estado seleccionado. |
| `img-disabled` | string | `""` | Imagen en estado deshabilitado. |
| `imgbk` | string | `""` | Imagen de fondo. |
| `img-rotate` | bool | `false` | Permite rotar la imagen con gesto. |
| `img-thumb` | string | `""` | Miniatura. |
| `error-image` | string | `""` | Imagen a mostrar si la carga de imagen falla. |
| `keep-aspect-ratio` | bool | `true` | Conserva el aspect ratio de la imagen. |
| `scale-type` | enum | `fit_center` | `fit_center`, `center_crop`, `center_inside`, `fit_xy`, `center` (el motor parsea snake_case; `center_crop` requiere `keep-aspect-ratio="true"`). |
| `zoom` | bool | `false` | Permite zoom con pellizco. |
| `zoom-max-scale` | float | `3.0` | Factor máximo de zoom. |
| `icon` | string | `""` | Icono asociado al control. |
| `icon-left` / `icon-right` / `icon-top` / `icon-bottom` | string | `""` | Iconos en cada lado del control. |
| `icon-orientation` | enum | `left` | Posición del icono respecto al texto. |
| `icon-size` | medida | `24dp` | Tamaño del icono. |
| `hide-no-picture` | bool | `false` | Oculta el control si no hay imagen asignada. |

### 4.8 Datos y enlazado (lookups/combos)

| Atributo | Tipo | Default | Descripción |
|---|---|---|---|
| `linkedto` | string | `""` | Coleccion remota enlazada (para combo con `linkedfield`). |
| `linkedfield` | string | `""` | Campo de la coleccion linked a mostrar. |
| `mapcol` | string | `""` | Coleccion de mapeo (lookup). |
| `mapfld` | string | `""` | Campo en `mapcol` que coincide con el valor del prop. |
| `mapcol-values` | string | `""` | Valores embebidos para mapeo rápido (sin coleccion). |
| `dropcoll` | string | `""` | Coleccion destino al soltar un elemento (drag & drop). |
| `filter` | formula | `""` | Filtro WHERE para la coleccion linked/lookup. |
| `linkfilter` | formula | `""` | Filtro adicional aplicado al linkear. |
| `contents` | string | `""` | Nombre de la coleccion anidada (para `type="Z"`). |
| `src` | string | `""` | Fuente externa de contenidos. |
| `allow-view` | bool | `true` | Permite visualizar el contenido del lookup. |
| `refresh` | bool | `false` | Recarga la coleccion al cambiar este campo. |
| `refresh-owner` | string | `""` | Campo padre que dispara el refresco. |
| `forceonchange` | bool | `false` | Fuerza el evento `onchange` aunque el valor no cambie. |
| `postonchange` | bool | `false` | Lanza `onchange` después de salir del campo (no en tiempo real). |
| `cache-timeout` | int (ms) | `0` | TTL para cache del valor del lookup. |
| `colorview` | bool | `false` | Este campo provee el color de la fila en la lista. |
| `index` | int | `0` | Orden manual en la lista. |

### 4.9 Entrada y mascara de texto

| Atributo | Tipo | Default | Descripción |
|---|---|---|---|
| `mask` | string | `""` | Mascara de entrada (ej. `"##/##/####"` para fecha). |
| `numeric` | bool | `false` | Solo acepta caracteres numéricos. |
| `upper` | bool | `false` | Convierte automáticamente a mayusculas. |
| `lower` | bool | `false` | Convierte automáticamente a minusculas. |
| `input-type` | enum | `text` | Valores XOne (NO constantes Android): `text`, `numeric`, `numeric_unsigned`, `decimal`, `phone`, `datetime`, `email`, `username`, `uri`, `password`, `none`. Un valor no reconocido lanza error. |
| `software-input` | enum | `default` | Modo del teclado software. |
| `enable-software-keyboard` | bool | `true` | Activa el teclado software al recibir foco. |
| `show-softinput` | bool | `false` | Muestra el teclado automáticamente al obtener foco. |
| `select-all-text-on-focus` | bool | `false` | Selecciona todo el texto al recibir foco. |
| `disable-copy-paste` | bool | `false` | Desactiva las opciones copiar/pegar del sistema. |
| `next-focus` | string | `""` | Nombre del siguiente campo al pulsar Enter/Tab. |
| `show-clear-toggle` | bool | `false` | Muestra botón "x" para limpiar el campo. |
| `show-counter` | bool | `false` | Muestra contador de caracteres. |
| `show-password-visibility-toggle` | bool | `false` | Muestra botón para ver/ocultar el password (tipo `X`). |
| `autocomplete` | bool | `false` | Activa el autocompletado del sistema. |
| `autocomplete-suggestions` | string | `""` | Sugerencias de autocompletado separadas por `;`. |
| `autolink` | bool | `false` | Convierte automáticamente URLs y emails en enlaces. |
| `autosave` | bool | `false` | Guarda automáticamente al cambiar el campo. |
| `pull-to-refresh` | bool | `false` | Activa el gesto "pull to refresh". |

### 4.10 Fechas y horas

| Atributo | Tipo | Default | Descripción |
|---|---|---|---|
| `date-format` | string | locale | Formato de fecha (ej. `"dd/MM/yyyy"`). |
| `time-format` | string | locale | Formato de hora (ej. `"HH:mm:ss"`). |
| `utc` | bool | `false` | Trata el valor como UTC. |
| `use-unix-epoch` | bool | `false` | Almacena el valor como timestamp Unix (epoch). |
| `calendar-viewmode` | enum | `month` | `month`, `week`, `day`. Modo del calendario. |
| `show-events` | bool | `true` | Muestra eventos en el calendario. |
| `time-interval` | int | `1` | Intervalo de minutos en el time picker. |
| `date-mode` | int | — (nuevo) | Estilo del selector de fecha (`D`/`DT`). Ausente o `4` = nuevo diseño moderno (calendario con deslizamiento lateral de meses); `0`–`3` = selectores nativos del sistema (0 por defecto del dispositivo, 1 oscuro, 2 claro, 3 oscuro). |
| `time-mode` | int | — (nuevo) | Estilo del selector de hora (`TT` y la hora de `DT`). Ausente o `4` = nuevo diseño moderno (ruedas de hora/minuto); `0`–`3` = selectores nativos del sistema. |

> Nota: `type="TT"` (solo hora) requiere `mask="Hh#:#Mm"` para que el campo sea visible.

> **Nuevo selector por defecto:** los campos `D`/`DT`/`TT` usan por defecto un selector moderno (calendario con swipe lateral entre meses y ruedas para la hora). Para volver al selector nativo del sistema, fijar `date-mode`/`time-mode` a `0`. El selector admite `bgcolor-dialog`, `forecolor-dialog` (color de acento) y `fontsize-dialog`.

### 4.11 Sliders, Progress, Rating, Stepper, OTP, NavigationBar, Kanban, CoverFlow, Markdown

| Atributo | Tipo | Default | Descripción |
|---|---|---|---|
| `viewmode` | enum | — | Slider/Progress: `slider`, `range-slider`, `rounded-slider`, `progress-bar`, `circular-progress-bar`, `rating-bar`. Numérico compacto: `stepper`. Barra de navegación Material 3: `navbar`. OTP: `otp` (en `T`/`N`). Texto formateado: `markdown` (en `T`). Lista (`Z`): `kanban`, `coverflow`, `chipsview` (además de `recyclerview`, `slideview`, etc.). |
| `orientation` | enum | `horizontal` | `horizontal` o `vertical`. |
| `step-size` | float/int | `1` | Incremento del slider o del stepper (en stepper debe ser `> 0`). |
| `bar-width` | medida | — | Ancho de la barra de progreso. |
| `indeterminate` | bool | `false` | Modo indeterminado (animación sin valor fijo). |
| `clockwise` | bool | `true` | Sentido horario para `circular-progress-bar`. |
| `from` | float | `0` | Valor mínimo del `range-slider`. |
| `to` | float | `100` | Valor máximo del `range-slider`. |
| `label-format` | string | `""` | Formato del label del slider (ej. `"%.0f%%"`). |
| `track-thickness` | medida | — | Grosor de la pista de la barra. |

#### 4.11a Stepper (`viewmode="stepper"`, `type="N"`)

Control compacto `−` / `+` para valores **enteros**. Auto-repite cada 80 ms al mantener pulsado.

| Atributo | Tipo | Default | Descripción |
|---|---|---|---|
| `min` | int | `0` | Valor mínimo. Si el valor actual es menor, se clampa al cargar. |
| `max` | int | `100` | Valor máximo. Debe ser `>= min` (si no, lanza `IllegalArgumentException`). |
| `step-size` | int | `1` | Incremento por pulsacion. Debe ser `> 0`. |
| `wrap` | bool | `false` | Si `true`, al sobrepasar `max` vuelve a `min` (selector ciclico). |
| `bar-color` | color | — | Color de fondo de los botones `−` / `+`. |
| `forecolor` | color | — | Color del número del centro. |
| `disableedit` | formula/bool | `false` | Si evalua a `true`, los botones quedan deshabilitados. |

API JS del control: `getValue()`, `setValue(n)`, `setMin(n)`, `setMax(n)`, `setStepSize(n)`.

#### 4.11b OTP (`viewmode="otp"`, `type="T"` o `type="N"`)

Entrada de códigos de un solo uso con cajas individuales, auto-avance, backspace inverso y paste distribuido. Se persiste como string concatenado sin separadores.

| Atributo | Tipo | Default | Descripción |
|---|---|---|---|
| `digits` | int | `6` | Número de cajas (debe ser positivo). Una caja por carácter. |
| `secret` | bool | `false` | Si `true`, oculta los caracteres (modo password). Útil para PINs. |
| `auto-submit` | bool | `true` | Si `true`, al rellenar la última caja oculta el teclado. |
| `allow-letters` | bool | `false` | Si `true`, acepta letras además de digitos. |
| `box-size` | medida | `44p` | Tamaño (ancho y alto) de cada caja. |
| `box-spacing` | medida | `8p` | Separación horizontal entre cajas. |
| `box-color` | color | — | Color de fondo de las cajas en estado normal. |
| `box-color-focus` | color | usa `box-color` | Color de fondo de la caja con foco. |
| `forecolor` | color | — | Color del texto dentro de las cajas. |
| `disableedit` | formula/bool | `false` | Si evalua a `true`, control en solo lectura. |

API JS del control: `getOtpValue()`, `clearOtp()`, `focusOtp()`.

#### 4.11c Kanban (`viewmode="kanban"`, `type="Z"`)

Tablero estilo Trello/Jira con drag&drop entre columnas. Al soltar una card, el framework asigna al campo `kanban-column-field` el valor de la columna destino y guarda automáticamente.

| Atributo | Tipo | Obligatorio | Default | Descripción |
|---|---|---|---|---|
| `contents` | string | **Si** | — | Nombre del `<contents>` vinculado. |
| `kanban-column-field` | string | **Si** | — | Campo del item cuyo valor determina la columna. |
| `kanban-columns` | string | **Si** | — | Valores posibles separados por `\|` (ej. `TODO\|DOING\|DONE`). |
| `kanban-column-titles` | string | No | usa los valores | Títulos visibles separados por `\|`. |
| `kanban-column-colors` | string | No | gris claro | Colores de fondo de las cabeceras separados por `\|`. |
| `kanban-column-width` | medida | No | `280p` | Ancho de cada columna. |
| `kanban-card-title-field` | string | No | — | Campo a mostrar como título (modo simple). |
| `kanban-card-subtitle-field` | string | No | — | Campo a mostrar como subtítulo (modo simple). |
| `kanban-card-bgcolor` | color | No | blanco | Color de fondo de las cards. |
| `draggable` | bool | No | `true` | Si `false`, deshabilita drag&drop. |
| `disableedit` | formula/bool | No | `false` | Si evalua a `true`, las cards no son arrastrables. |

**Modos de renderizado:**
- **Simple:** activo si esta presente al menos uno de `kanban-card-title-field` / `kanban-card-subtitle-field`.
- **Objeto XOne completo:** activo si **ninguno** de esos atributos esta presente — la card usa el `<frame>` declarado en la coll del contents.

#### 4.11d Cover Flow (`viewmode="coverflow"`, `type="Z"`)

Variante de `slideview` con efecto Cover Flow estilo iTunes. Hereda toda la configuración de `slideview`.

| Atributo | Tipo | Default | Rango | Descripción |
|---|---|---|---|---|
| `cover-flow-min-scale` | float | `0.75` | `0.0` – `1.0` | Escala mínima de las cards laterales. |
| `cover-flow-min-alpha` | float | `0.6` | `0.0` – `1.0` | Opacidad mínima de las cards laterales. |
| `cover-flow-rotation` | float (grados) | `0` | — | Rotación 3D sobre el eje Y. Si `!= 0`, aplica perspectiva 3D real. Típicos: `25`–`45`. |

#### 4.11e Markdown (`viewmode="markdown"`, `type="T"`)

Renderiza el contenido del campo como Markdown CommonMark base (cabeceras, enfasis, listas, enlaces, imágenes, blockquotes, código inline/bloque, reglas horizontales). **No introduce atributos propios** — aplican los atributos comunes de `type="T"`.

**No soportado por defecto:** tablas, strikethrough, task lists, HTML embebido, syntax highlighting.

#### 4.11f Chips (`viewmode="chipsview"`, `type="Z"`)

Conjunto de **chips Material** (pastillas redondeadas) con *wrap* automático a varias filas. Cada fila del `<contents>` vinculado se pinta como un chip.

| Atributo | Tipo | Obligatorio | Default | Descripción |
|---|---|---|---|---|
| `contents` | string | **Si** | — | Nombre del `<contents>` vinculado (su colección aporta los chips). |
| `width` / `height` | medida | No | `wrap` | Tamaño del contenedor; `height="-2"` = ajuste al contenido. |

En las **props de la colección del contents**:

| Atributo de prop | Obligatorio | Descripción |
|---|---|---|
| `chip-value` | **Si** (en una prop) | Marca la prop cuyo valor es el **texto del chip**. |
| `chip-close-enabled` | No | Prop booleana; si su valor es verdadero el chip muestra una "x" para cerrarse. |

Notas:
- Para chips generados al vuelo, la colección puede ser **en memoria**: `volatile="true"` + **`manual-load="true"`** + **`loadall="true"`** en la `<coll>` (si no, el control la recarga desde BD y la deja vacía). Se rellena por JS con `createObject()` + **`addItem()`** (NO `save()`), luego `lock()` y `ui.refresh("NOMBRE_DEL_Z")`.
- **Todos los chips son seleccionables (toggle)** → sirven directamente como *filter chips*. Eventos del prop: `onitemschanged="h(e)"` (el handler recibe `e.values` = array con los textos marcados y `e.ids` = sus ids), `onitemremoved="h(e)"` al cerrar un chip (`e.value` / `e.id`). Alternativa imperativa: `ui.getView(self).getControl("NOMBRE").getCheckedValues()` → `[{id, value}]`.

#### 4.11g NavigationBar pill animada (`viewmode="navbar"`, `type="N"`)

Barra de navegación Material 3 con indicador "pill" deslizante. El valor del campo es el índice del destino activo (0..N−1); tocar un destino lo escribe y dispara el `<onchange>`, y un cambio del valor por código (con refresco) desliza la pill. Los destinos se declaran **inline** (no desde un `<contents>`).

| Atributo | Tipo | Default | Descripción |
|---|---|---|---|
| `nav-titles` | string | — | Títulos de los destinos separados por barra vertical. Define el número de pills. |
| `nav-icons` | string | — | Iconos (recurso, como los `img` de botón) separados por barra vertical, emparejados por posición con los títulos. Se tiñen con el color activo / inactivo. |
| `pill-color` | color | `#E8DEF8` | Color de la pill deslizante. |
| `pill-text-color` (o `forecolor`) | color | `#1D192B` | Color de icono + texto del destino activo. |
| `nav-text-color` | color | `#49454F` | Color de icono + texto de los destinos inactivos. |
| `bar-color` / `bgcolor` | color | transparente | Color de fondo de la barra. |
| `label-visibility` | enum | `always` | `always`, `selected` (solo el activo) o `never`. |
| `animation-duration` | int (ms) | `300` | Duración del deslizamiento. |
| `pill-corner-radius` | medida | mitad de la altura | Radio de las esquinas de la pill. |
| `nav-icon-size` | medida (dp) | `24` | Tamaño del icono. |
| `disableedit` / `locked` | formula/bool | `false` | Si evalúa a `true`, la barra no es tocable ni muestra efecto al pulsar (queda como indicador). |

El índice se acota a `[0, nº de pills − 1]`; un valor negativo cae a `0` y uno mayor que el máximo al último, corrigiéndose también en el campo. API JavaScript: `getValue()`, `setValue(n)`, `getItemCount()` (en el control).

### 4.12 Animaciones y eventos inline

| Atributo | Tipo | Default | Descripción |
|---|---|---|---|
| `animation-in` | string | `""` | Macro de animación de entrada (ej. `##RIGHT_IN##`, `##BOTTOM_IN##`). |
| `animation-in-delay` | int (ms) | `0` | Retardo antes de ejecutar la animación de entrada. |
| `animation-out` | string | `""` | Macro de animación de salida. |
| `repeat-mode` | enum | `restart` | **Solo animaciones Lottie en `type="IMG"`.** `restart` (vuelve a empezar) o `reverse` (va y vuelve). La animación arranca sola en bucle infinito, así que sin declararlo se repite desde el inicio. |
| `clip-text-to-bounds` | bool | `false` | **Solo animaciones Lottie en `type="IMG"`.** Recorta el texto de párrafo a la caja definida en el diseño. Una línea que desborde la altura no se dibuja en absoluto, de ahí que venga apagado: si la fuente no es la del diseño, el texto se reparte en más líneas y desaparece contenido. |
| `ripple-effect` | bool | `true` | Efecto ripple Material Design al pulsar. |
| `onclick` | script | `""` | Script JavaScript inline al pulsar el control. **Solo como atributo**, nunca como nodo hijo `<onclick>`. **Modo estricto:** cada sentencia debe terminar en `;` (incluida la última, también si el script acaba con un bloque `{...}`). Para invocar un nodo XML custom de la coll: `self.ExecuteNode('nombreNodo');` (nombre como string literal, **no** `ExecuteNode(nombreNodo)` ni `ExecuteNode(función())`). |
| `onchange` | script | `""` | Script al cambiar el valor. Misma regla que `onclick` (script inline, `;` al final de cada sentencia). |
| `onfocus` | script | `""` | Script al recibir foco. Misma regla que `onclick`. |
| `ontouchdown` | script | `""` | **Solo `type="B"`.** Script JavaScript inline al presionar el botón (en el instante en que el dedo lo toca). Misma regla que `onclick`. Junto con `ontouchup` permite interacciones "mantener pulsado" (p. ej. grabar mientras se mantiene). El objeto evento `e` expone `e.x`/`e.y` (coordenadas del toque). |
| `ontouchup` | script | `""` | **Solo `type="B"`.** Script JavaScript inline al soltar el botón (al levantar el dedo o cancelarse el gesto). Misma regla que `onclick`. Se dispara antes que `onclick` si ambos están definidos. |
| `execute-async` | bool | `false` | Ejecuta el script de eventos de forma asíncrona. |
| `load-async` | bool | `false` | Carga del control de forma asíncrona. |
| `abort-on-error` | bool | `false` | Aborta la cadena de eventos si se produce un error. |
| `sound` | string | `""` | Sonido a reproducir al interactuar con el control. |

### 4.13 Multimedia y archivos adjuntos

| Atributo | Tipo | Default | Descripción |
|---|---|---|---|
| `attach-allowed` | string | `""` | Tipos MIME permitidos para adjuntos (ej. `"image/*"`, `"application/pdf"`). |
| `file-maxsize` | int (KB) | `0` | Tamaño máximo del fichero adjunto en KB. `0` = sin limite. |
| `file-maxwidth` | int | `0` | Ancho máximo para imágenes capturadas. |
| `file-maxheight` | int | `0` | Alto máximo para imágenes capturadas. |
| `file-quality` | int (%) | `90` | Calidad JPEG para imágenes. |
| `max-duration` | int (s) | `0` | Duración máxima para video/audio. `0` = sin limite. |
| `use-internal-camera` | bool | `false` | Captura con la cámara que trae el framework en vez de abrir la app de cámara del dispositivo. |
| `motion-photo` | bool | `false` | Captura una foto en movimiento: un JPG con un clip de vídeo corto embebido detrás, que las galerías compatibles reproducen. Requiere `use-internal-camera="true"` para funcionar en cualquier versión de Android; sin él lo tiene que implementar la app de cámara del dispositivo (Android 16 o superior). Ignora los atributos `file-*`, porque recomprimir la imagen tiraría el vídeo. |
| `apply-format-to-file` | bool | `false` | Aplica el formato al fichero resultante (para `type="DR"`). |

### 4.14 Machine Learning y camara avanzada

| Atributo | Tipo | Default | Descripción |
|---|---|---|---|
| `analyze-exif-metadata` | bool | `false` | Gira el fichero de imagen según la orientación con la que se hizo la foto, para que se vea derecho en cualquier visor. Girar obliga a recomprimir la imagen; si la foto es una foto en movimiento, el clip de vídeo se conserva. |
| `ml-model` | string | `""` | Ruta del modelo TensorFlow Lite (`.tflite`). |
| `ml-model-quantized` | bool | `false` | Indica que el modelo esta cuantizado. |
| `ml-classes` | string | `""` | Ruta del fichero de clases/etiquetas del modelo. |
| `ml-input-size` | int | — | Tamaño de entrada del modelo (en pixeles). |
| `ml-threads` | int | `1` | Número de hilos para inferencia. |
| `ml-use-gpu` | bool | `false` | Usa GPU para inferencia. |
| `ml-use-nnapi` | bool | `false` | Usa Android NNAPI para inferencia. |
| `ml-use-yolo-v5` | bool | `false` | Activa el modo de deteccion YOLOv5. |
| `ml-filter-min-confidence` | float | `0.5` | Confianza mínima para mostrar un resultado (0.0-1.0). |

### 4.15 Atributos varios

| Atributo | Tipo | Default | Descripción |
|---|---|---|---|
| `classid` | string | `""` | Control especial por ID de clase: `mobbsignview` (firma Mobbsign), `vaxtorocr` (OCR Vaxtoro), `xonecharts` (gráficos avanzados). |
| `phone` | bool | `false` | Permite marcar el número de telefono al pulsar. |
| `barcode` | bool | `false` | Permite escanear un código de barras al pulsar. |
| `method` | string | `""` | Nombre del método ejecutable asociado. |
| `message` | string | `""` | Mensaje de confirmacion antes de ejecutar la acción. |
| `scale` | float | `1.0` | Escala global del control. |
| `accessibility-label` | string | `""` | Etiqueta para lectores de pantalla (accesibilidad). |
| `draggable-scrollbar` | bool | `false` | Scrollbar arrastrable con el dedo. |
| `show-scrollbar` | bool | `true` | Muestra la barra de desplazamiento. |
| `paging-enabled` | bool | `false` | Activa paginación en listas. |
| `page-swipe` | bool | `false` | Permite cambiar de página deslizando. |
| `records-limit` | int | `0` | Limite de registros visibles. `0` = sin limite. |
| `edit-inrow` | bool | `false` | Edita el registro directamente en la fila de lista. |
| `grid-header` | bool | `false` | Muestra cabecera de columna en grid. |
| `click-anywhere` | bool | `false` | Hace que el clic sobre el texto del control abra su picker, sin necesidad de pulsar el botón/lupa. Aplica a: campos con `linked-to` + `linked-field` y `showinline="true"` (excepto `viewmode="spinner"`) — el texto abre el selector de registro enlazado; `type="D"`, `type="DT"` y `type="TT"` (y `type="T"` con `mask="Hh#:#Mm"`) — el texto de fecha abre `DatePicker` y el de hora abre `TimePicker` (en `DT` cada zona dispara su propio diálogo). Ignorado en cualquier otro control. |
| `icon-inside` | bool | `false` | En controles con botón lateral (`linked-to` + `linked-field` con `showinline="true"` excepto `viewmode="spinner"`, `linked-to` + `linked-field` con `showinline="false"`, `type="D"`, `type="DT"`, `type="TT"`), si está activo el icono se pinta dentro del propio texto en lugar de a su lado, y el clic sobre la zona del icono abre el picker del control. |
| `icon-align` | enum | `right` | En los mismos controles que `icon-inside`. Posiciona el icono respecto al texto: `left` lo coloca antes del texto, `right` (default) lo deja al final. Los valores `top` y `bottom` se aceptan pero se tratan como `right` en esta versión. |
| `check-type` | enum | (omitido) | Para `type="NC"`: `toggle`, `switch`, `radio`. Si se omite o se pasa otro valor, se renderiza un CheckBox estándar. |
| `radio-group` | string | `""` | Grupo de radio buttons (para `check-type="radio"`). |
| `code-type` | string | `""` | Tipo de código para `type="VD"`: `qr`, `barcode`, `any`. |
| `show-user-location` | bool | `false` | Muestra la ubicación del usuario en el mapa (`type="Z" viewmode="mapview"/"maplibre"/"openstreetmap"`). |

---

## 5. Nodo `<method>` — Método ejecutable

Define un método reutilizable que puede ser invocado desde scripts via `self.executeNode("nombre")`.

| Atributo | Tipo | Obligatorio | Default | Descripción |
|---|---|---|---|---|
| `name` | string | **Si** | — | Nombre único del método dentro de la coll. |
| `language` | enum | No | lenguaje por defecto | `javascript` (recomendado). `vbscript` esta descontinuado. |
| `params` | string | No | `""` | Parámetros separados por coma. |
| `return-type` | string | No | `""` | Tipo de retorno. |
| `execute-async` | bool | No | `false` | Ejecuta de forma asíncrona. |
| `disableedit` | formula | No | `""` | Si verdadero, el método no puede ejecutarse. |

Requiere nodo hijo `<script language="javascript">` con el código.

```xml
<method name="calcularTotal" language="javascript">
    <script language="javascript">
        var base = self.getValue("IMPORTE_BASE");
        var iva  = base * 0.21;
        self.setValue("IVA", iva);
        self.setValue("TOTAL", base + iva);
    </script>
</method>
```

> Llamada desde otro script: `self.executeNode("calcularTotal");`

---

## 6. Nodo `<macro>` — Macro de coleccion

Variable de tipo string con ambito de la coleccion, usable en SQL y filtros mediante la sintaxis `##NOMBRE##`.

| Atributo | Tipo | Obligatorio | Default | Descripción |
|---|---|---|---|---|
| `name` | string | **Si** | — | Nombre de la macro. Usar formato `##NOMBRE##`. |
| `value` | string | No | `""` | Valor inicial de la macro. |
| `default` | bool | No | `false` | Si `true`, se usa como valor por defecto. |

**Reglas críticas:**
- El nodo `<macro>` se declara como **hijo directo de `<coll>`**, al mismo nivel que los `<group>`.
- Sin declaración del nodo, `setMacro("##X##", valor)` no tiene efecto en el SQL.
- Para leer/escribir desde JS: `selfDataColl.getMacro("##X##")` / `selfDataColl.setMacro("##X##", valor)`.
- Para macros globales (toda la app): `appData.getGlobalMacro` / `appData.setGlobalMacro`.

```xml
<coll name="Pedidos" sql="SELECT * FROM ##PREF##Pedidos WHERE estado = ##FILTRO_ESTADO##">
    <macro name="##FILTRO_ESTADO##" value="'pendiente'" default="true" />
    <group name="grp1" id="1">
        <!-- ... -->
    </group>
</coll>
```

---

## 7. Nodo `<script>` — Script

Nodo que contiene código JavaScript. Puede ser hijo de eventos, métodos o usarse inline.

| Atributo | Tipo | Obligatorio | Default | Descripción |
|---|---|---|---|---|
| `name` | string | No | `""` | Identificador del script. |
| `language` | enum | No | lenguaje por defecto | `javascript` (recomendado). No usar `vbscript`. |
| `type` | string | No | `text/javascript` | MIME type alternativo. |
| `src` | string | No | `""` | URL o ruta a fichero externo. |
| `ext-file` | string | No | `""` | Fichero externo relativo al proyecto. |

**Escape XML del JS embebido.** Para JS no trivial, **forma preferida**: declarar la función en un fichero `.js` externo (`functions.js` u otro `<include>`-ado) y llamarla desde el `.xne` con `miFuncion();` — así el JS se escribe normal y el XML solo invoca. Para snippets cortos inline, hay dos formas válidas: (a) entidades XML dentro del JS (`&` → `&amp;`, `<` → `&lt;`, `>` → `&gt;`), o (b) envolver el bloque en `<![CDATA[…]]>` (solo válido dentro de nodos `<script>`; NO dentro de atributos XML como `onclick="…"`).

(fence sin lenguaje para que las entidades se rendericen literales)

```
<!-- OPCIÓN A: entidades XML -->
<script language="javascript">
    if (a &gt; 0 &amp;&amp; b &lt; 10) {
        self.setValue("RESULTADO", a + b);
    }
</script>

<!-- OPCIÓN B: CDATA (también válido dentro de <script>) -->
<script language="javascript"><![CDATA[
    if (a > 0 && b < 10) {
        self.setValue("RESULTADO", a + b);
    }
]]></script>
```

---

## 8. Nodo `<event>` — Eventos disponibles

| Evento | Aplicable a | Cuando dispara |
|---|---|---|
| `<create>` | coll | Una sola vez al crear el objeto (primera apertura). |
| `<before-edit>` | coll | Al abrir para edición. **Usar para inicializar pantalla.** |
| `<after-edit>` | coll | Después de entrar en modo edición. |
| `<load>` | coll | Se dispara **por cada DataObject** al cargarse desde la BD: tanto al recorrer la coleccion (`startBrowse()`/`loadAll()`) como al hidratar items de un `<contents>` o cargas individuales. **NO es evento de pantalla** y **NO recomendado** por impacto en rendimiento. |
| `<onchange>` + `<field name="X">` | coll, prop | Al cambiar el valor del campo indicado. |
| `<selecteditem>` | coll | Al seleccionar un item en lista. |
| `<auto-selecteditem>` | coll | Selección automática al cargar. |
| `<onlongpressitem>` | coll | Pulsacion larga sobre un item. |
| `<onback>` | coll | Al pulsar el botón atrás. |
| `<onfocus>` | prop | Al recibir foco. |
| `<delete>` (con `<rule>` hijos) | coll | Define **reglas de borrado** que se evaluan antes de eliminar un objeto. No es un evento "antes/después"; es un bloque de reglas (`<rule>` con condiciones SQL/script). |
| `<onlogon>` / `<login-ok>` / `<login-fail>` | coll de login | Flujo de autenticación. |
| `<onlogoff>` | coll | Al cerrar sesión. |
| `<onpushreceived>` | coll Empresas | **Exclusivo de la coll `Empresas`** (`ASGestion.CASEmpresa`). Al recibir una notificación push. |
| `<maintenance>` | coll Empresas | **Exclusivo de la coll `Empresas`.** Tarea de mantenimiento periódico. |
| `<sys-message>` | coll Empresas | **Exclusivo de la coll `Empresas`.** Mensaje de sistema (códigos 1000-1003). |
| `<nodoCustom>` | coll | Nodo invocable con `self.executeNode("nodoCustom")`. |

> **Nota:** `onclick`, `onchange`, `onfocus` se declaran **solo como atributos** del nodo `<prop>`, **nunca como nodos hijos** `<onclick>`/`<onchange>`/`<onfocus>`. Los siguientes nombres **NO existen en ningún sitio** (ni nodo ni atributo): `onlostfocus`, `onblur`, `onsave`, `oncreate`, `oninit`. Hay además nombres que **SÍ existen como atributo de evento en `<prop>`** pero NO como nodo hijo de `<coll>`: `ontouch`, `onlongpress`, `ontextchanged`, `onfocuschanged`, `oneditoraction`, `onscroll`, `onkeydown`, `onswipe`, `oncodescanned`, `oncheckedchange`, etc. Casos específicos: `ondismiss` (atributo de `<prop>` con `behavior="swipe-dismiss"`), `beforesave`/`aftersave` (atributos de `<executeNode>`).
>
> **Caso especial — `<button>`:** existe como **alias legacy** de `<prop type="B">`. Forma canónica recomendada hoy: `<prop type="B">`.

---

## 9. Nodo `<platform>` — Override por plataforma

Permite sobrescribir atributos de cualquier nodo según la plataforma o tipo de dispositivo. Se declara como hijo del nodo que quiere sobreescribir.

| Atributo | Tipo | Obligatorio | Default | Descripción |
|---|---|---|---|---|
| `name` | string | **Si** | — | Plataforma: `android`, `ios`, `windows`. |
| `device` | string | No | `""` | Tipo de dispositivo: `phone`, `hiphone`, `tablet`, `mini`, `watchround`, `watchsquare`. |
| *(cualquier atributo del padre)* | — | No | heredado | Sobrescribe el atributo cuando la plataforma coincide. |

**Orden de resolución de atributos:**
1. `<platform name="...">` que coincide con la plataforma actual.
2. El nodo principal (el padre).
3. Regla CSS por clase.
4. Cadena vacia / valor por defecto.

```xml
<prop name="NOMBRE" type="T" visible="7" width="100%">
    <!-- En tablet, el campo ocupa solo el 50% -->
    <platform name="android" device="tablet">
        <width>50%</width>
    </platform>
</prop>

<coll name="MiPantalla" screen-orientation="portrait">
    <!-- En tablet, la orientacion es libre -->
    <platform name="android" device="tablet">
        <screen-orientation>sensor</screen-orientation>
    </platform>
</coll>
```

---

## 10. Tipos de propiedad (atributo `type`)

> **IMPORTANTE**: Los tipos `BT`, `C`, `M`, `A`, `R`, `E`, `H`, `W`, `F` NO existen en XOne y causaran errores. Los combos se implementan con `type="T"` o `type="N"` más `mapcol`/`mapfld`.

| Código | Descripción | Notas |
|---|---|---|
| `T` | Texto editable. | El más usado para campos de texto. |
| `TN` / `TN2`..`TN6` | Texto numérico con N decimales. | `TN` = sin decimales fijos, `TN2` = 2 dec., etc. |
| `N` / `N2`..`N6` | Numérico con N decimales. | `N` = entero, `N2` = 2 decimales, `N6` = 6 decimales, etc. El sufijo controla los decimales visibles en el control. |
| `D` | Fecha. | Requiere `date-format` para personalizar. |
| `DT` | Fecha y hora. | |
| `TT` | Solo hora/reloj. | Requiere `mask="Hh#:#Mm"` para ser visible. |
| `B` | Botón en formulario. | Usar `onclick` como atributo. Soporta también `ontouchdown`/`ontouchup` para distinguir presionar de soltar (interacciones "mantener pulsado"). |
| `L` | Etiqueta de solo lectura (label) — forma preferida. | No editable. Muestra el `title`; sin `title`, usa el valor del campo. Usar prefijo `MAP_` en el name. |
| `TL` | Alias legacy de `L`: se renderiza igual (label de solo lectura). | Equivalente a `type="L"`; el framework instancia el mismo control. Mantener por compatibilidad. |
| `THTML` | Texto con formato HTML. | Soporta HTML básico. `link-color` para enlaces. |
| `WEB` | WebView embebido. | Carga URLs o HTML local. |
| `IMG` | Imagen referenciada (path o URL). | `scale-type`, `zoom`, `keep-aspect-ratio`. |
| `PH` | Foto capturable con la camara. | Equivalente a `IMG` con captura integrada. |
| `VD` | Video o escaner. | `code-type` para QR/barcode. |
| `DR` | Dibujo/firma digital. | `stroke-color`, `stroke-width`, `apply-format-to-file`. |
| `NC` | Checkbox/toggle/radio/switch. | `check-type` para variante visual. |
| `X` | Campo password (enmascarado). | `show-password-visibility-toggle` para ver/ocultar. |
| `Z` | Contenedor de lista embebida (grid). | Requiere `contents="NombreColeccion"`. |
| `AT` | Adjunto/fichero. | `attach-allowed` para filtrar tipos MIME. |
| `O` | Sub-objeto JavaScript. | No persiste en BD. Ideal para callbacks y estados UI. |

---

## 11. Atributos globales de la app

Atributos del nodo raiz `<app>` en `mappings.xne` o `app.xml`.

| Atributo | Tipo | Default | Descripción |
|---|---|---|---|
| `prefix` | string | `""` | Prefijo de tablas (macro `##PREF##`). Ej. `gen` genera `gen_` en el SQL. |
| `versión` | string | — | Versión de la aplicación. |
| `mainentry` | string | — | Coleccion de entry-point (pantalla inicial). |
| `login-coll` | string | — | Coleccion de login. |
| `default-language` | string | `javascript` | Lenguaje de scripts por defecto. Usar siempre `javascript`. |
| `theme` | string | `default` | Tema visual global de la app. |
| `scale-fontsize` | bool | `true` | Escala fuentes según `fontScale` del sistema (accesibilidad). |
| `android-font-factor` | float | `7` | Factor adicional de escala de fuentes en Android. |
| `appname` | string | nombre del fichero | Nombre lógico de la app. |
| `license` | string | — | Licencia de la app. |
| `compatibility-mode` | bool | `false` | Si `true`, ignora COMPLETAMENTE el CSS. |
| `debug` | bool | `false` | Activa el modo debug. |

### Macros de sistema disponibles

| Macro | Descripción |
|---|---|
| `##PREF##` | Prefijo de tablas definido en `app.xml`. |
| `##APP##` | Referencia a la app. |
| `##DEFAULT##` | Valor por defecto. |
| `##MAINFRAME##` | Frame raiz de la aplicación. |
| `##MAINENTRYPOINT##` | Padre del menu principal. |
| `##NOW_TIME##` | Fecha y hora actual. |
| `##DEVICE_OS##` | Sistema operativo del dispositivo. |
| `##DEVICE_OSSDKCODE##` | Código SDK del OS (Android API level). |
| `##DEVICE_TYPE##` | Tipo de dispositivo (`phone`, `tablet`, etc.). |
| `##CURRENT_ORIENTATION##` | Orientación actual (`portrait` o `landscape`). |
| `##FRAME_VERSION_CODE##` | Versión del framework XOne. |
| `##LIVEUPDATE_VERSION##` | Versión del LiveUpdate. |
| `##RIGHT_IN##` | Animación de entrada desde la derecha. |
| `##RIGHT_OUT##` | Animación de salida hacia la derecha. |
| `##LEFT_IN##` | Animación de entrada desde la izquierda. |
| `##LEFT_OUT##` | Animación de salida hacia la izquierda. |
| `##TOP_IN##` | Animación de entrada desde arriba. |
| `##BOTTOM_IN##` | Animación de entrada desde abajo. |
| `##PUSH_IN##` / `##PUSH_OUT##` / `##PUSH_DOWN_IN##` | Variantes de animación tipo push. |
| `##ALPHA_IN##` | Animación de entrada con fade. |
| `##ZOOM_IN##` | Animación de entrada con zoom. |

### Ficheros de configuración del proyecto

| Fichero | Uso |
|---|---|
| `app.ini` | Configuración inicial: Name, Title, Caption, Icon, IconFolder, FilesFolder. |
| `app.xml` | Definición global de la app (prefix, versión, CSS, scripts). |
| `mappings.xne` | Mapping principal: solo colecciones Empresas y Usuarios. Encoding: UTF-8 o iso-8859-15 (coherente con los bytes). |
| `default.css` | Estilos globales. |
| `functions.js` | Funciones JavaScript globales (carga automática). |
| `license.ini` | Licencia de la aplicación. |
