# XML/UI — Estructura: coll, group, frame

Sub-archivo del [Tópico 02 - Guía Completa de XML/UI](02-xml-ui-complete-guide.md). Cubre la jerarquía base de los archivos `.xne`: introduccion al modelo, nodo `<coll>` (coleccion/pantalla), nodo `<group>` (agrupacion/tab) y nodo `<frame>` (contenedor visual).

> **REGLAS GENERALES DE NAMING (aplican a coll/group/frame/prop):**
>
> 1. **`name` es case-sensitive.** `name="MiNombre"` y `name="minombre"` son nombres **distintos**. Aplica también a TODAS las referencias cruzadas: `self.X`, `mapcol`, `linkedto`, `inherits`, `<field name="...">`, `getControl("...")`, `ui.openEditView("...")`, `appData.getCollection("...")`.
> 2. **El `id` de `<group>` es obligatorio y único en la coll.** Dos `<group id="1">` en la misma `<coll>` producen comportamiento indefinido. Convencion: `id="1"`, `id="2"`, ... normales; `id="999"` HEADER fijo y `id="0"` FOOTER fijo.
> 3. **Unicidad de `name` en la coll.** No puede repetirse el `name` de ningun nodo dentro de una `<coll>`, aunque estén en `<group>` o `<frame>` distintos.

## Tabla de Contenidos

1. [Introduccion al Sistema de UI](#1-introduccion-al-sistema-de-ui)
2. [Nodo coll - Colecciones](#2-nodo-coll---colecciones)
3. [Nodo group - Agrupaciones](#3-nodo-group---agrupaciones)
4. [Nodo frame - Contenedores Visuales](#4-nodo-frame---contenedores-visuales)

---

## 1. Introduccion al Sistema de UI

### 1.1 El modelo declarativo XML de XOne

XOne utiliza un sistema declarativo basado en XML para definir la interfaz de usuario de aplicaciones móviles nativas. Cada pantalla, formulario o lista se describe en un archivo con extensión `.xne`, que es un documento XML con etiquetas propietarias de la plataforma.

A diferencia de tecnologías web como HTML + CSS + JavaScript, donde la estructura, el estilo y la lógica están separados en archivos distintos, XOne combina los tres aspectos en un mismo archivo `.xne`:

- **Estructura**: Definida por los nodos XML (`<coll>`, `<group>`, `<frame>`, `<prop>`).
- **Estilos**: Aplicados mediante atributos inline o clases CSS propietarias (ver [Tópico 04 - CSS](./04-css-styling-guide.md)).
- **Lógica**: Integrada mediante event handlers (`<create>`, `<load>`, `<onchange>`) y nodos custom que contienen JavaScript (ver [Tópico 03 - JavaScript API](./03-javascript-api-guide.md)).

### 1.2 Jerarquía: coll > group > frame > prop

La estructura de UI en XOne sigue una jerarquía estricta:

```
<coll>                        ← Coleccion (raiz de la pantalla)
  ├── <group>                 ← Agrupacion / pestana
  │     ├── <frame>           ← Contenedor visual
  │     │     ├── <prop>      ← Campo / control
  │     │     ├── <prop>      ← Campo / control
  │     │     └── <frame>     ← Frame anidado
  │     │           └── <prop>
  │     └── <prop>            ← Campo directo en grupo
  ├── <group>                 ← Otra pestana
  ├── <contents>              ← Coleccion embebida
  ├── <create>                ← Evento de creacion
  ├── <load>                  ← Evento de carga
  ├── <onchange>              ← Evento de cambio
  └── <onback>                ← Evento de retroceso
```

**Reglas clave**:
- `<coll>` es siempre el nodo raiz.
- Los `<group>` son hijos directos de `<coll>` y definen secciones o pestanas.
- Los `<frame>` pueden estar dentro de `<group>` o anidados dentro de otros `<frame>`.
- Los `<prop>` pueden estar dentro de `<group>` o `<frame>`.
- Los `<contents>` se declaran como hijos directos de `<coll>` (o dentro de frames/groups en algunos casos).
- Los event handlers se declaran como hijos directos de `<coll>`.

### 1.3 Diferencias con HTML/CSS/JS web

Si vienes del mundo web, estas son las diferencias fundamentales:

| Aspecto | HTML/CSS/JS Web | XOne XML |
|---------|----------------|----------|
| Extensión de archivo | `.html`, `.css`, `.js` | `.xne` (todo junto) |
| Nodo raiz | `<html>` | `<coll>` |
| Contenedores | `<div>`, `<section>` | `<frame>`, `<group>` |
| Campos de entrada | `<input>`, `<select>` | `<prop type="T">` (texto), `<prop type="T" mapcol="..." mapfld="...">` (selector/combo) |
| Botones | `<button>` | `<prop type="B">` |
| Imágenes | `<img>` | `<prop type="IMG">` |
| Listas | `<ul>`, `<table>` | `<prop type="Z">` + `<contents>` |
| Unidades CSS | `px`, `em`, `rem` | `p` (puntos), `%` (porcentaje) |
| Layout | Flexbox, Grid | Flujo lineal con `newline`, `width`, `align` |
| Eventos | `addEventListener` | Nodos XML: `<create>`, `<onchange>`, etc. |
| Estilos | CSS3 estándar | CSS propietario XOne (ver [Tópico 04](./04-css-styling-guide.md)) |

> **Importante**: NO uses atributos o funciones de HTML/CSS/JS web estándar. XOne tiene su propia API (ver [Tópico 03 - JavaScript](./03-javascript-api-guide.md)) y su propio sistema CSS (ver [Tópico 04 - CSS](./04-css-styling-guide.md)).

### 1.4 Declaración XML y encoding

Todo archivo `.xne` debe comenzar con la declaración XML:

```xml
<?xml version="1.0" encoding="utf-8"?>
```

Los encodings más comunes son:
- `utf-8` (recomendado para proyectos nuevos)
- `iso-8859-1`
- `iso-8859-15`

---

## 2. Nodo coll - Colecciones

El nodo `<coll>` es el nodo raiz de cada archivo `.xne`. Representa una **coleccion**, que en XOne puede ser:
- Una **pantalla** de la aplicación (menú, formulario, etc.).
- Una **tabla de base de datos** con su interfaz visual asociada.
- Un **contenedor de lógica** sin datos reales (`special="true"`).

### 2.1 Atributos de identificación

| Atributo | Tipo | Requerido | Descripción |
|----------|------|-----------|-------------|
| `name` | string | **Si** | Nombre único de la coleccion. Usa PascalCase: `MenuPrincipal`, `DetalleProducto`. |
| `title` | string | No | Título visible en la barra de la aplicación. Si se omite, no muestra título. |
| `objname` | string | No | Nombre del objeto de datos en la base de datos. Suele coincidir con el nombre de la tabla. |
| `updateobj` | string | No | Nombre del objeto para operaciones de escritura (INSERT, UPDATE, DELETE). |
| `progid` | string | No | Identificador del tipo de objeto de negocio. |

**Ejemplo**:
```xml
<coll name="Clientes" title="Lista de Clientes"
      objname="Clientes" updateobj="Clientes">
```

### 2.2 Atributos de datos

| Atributo | Tipo | Descripción | Ejemplo |
|----------|------|-------------|---------|
| `sql` | string | Consulta SQL para cargar datos. Usar `##PREF##` para el prefijo de tabla. | `sql="SELECT * FROM ##PREF##Clientes"` |
| `filter` | string | Filtro SQL adicional (clausula WHERE). | `filter="ACTIVO=1"` |
| `sort` | string | Ordenamiento de datos (clausula ORDER BY). | `sort="NOMBRE ASC"` |
| `connection` | string | Nombre de la conexión a base de datos si no es la principal. | `connection="GpsConnection"` |
| `loadall` | boolean | Si es `true`, carga todos los registros al abrir. | `loadall="true"` |
| `dependent` | boolean | Indica si la coleccion depende de una coleccion padre. | `dependent="false"` |
| `check-owner` | boolean | Verifica que los registros pertenezcan al usuario/empresa actual. | `check-owner="false"` |
| `page-limit-off` | string | Desactiva la paginación automática. | `page-limit-off="1"` |
| `userawsql` | boolean | Usar SQL sin procesar (sin modificaciones del framework). | `userawsql="true"` |
| `autorefresh` | boolean | Refresca datos automáticamente al regresar de otra ventana o pantalla. | `autorefresh="true"` |
| `start-from-bottom` | boolean | El scroll empieza desde el final y se mantiene anclado al último elemento (estilo chat). Se puede declarar aquí en la coll o en el propio content (el prop `type="Z"`); si está en ambos, gana el del content. | `start-from-bottom="true"` |
| `no-data-text` | string | Texto a mostrar cuando la coleccion no tiene registros. | `no-data-text="Sin datos"` |
| `stringkey` | boolean | Indica que la clave primaria es de tipo texto en lugar de entero. | `stringkey="true"` |
| `idfieldname` | string | Nombre del campo que actua como clave primaria cuando no se llama `ID`. | `idfieldname="CODIGO"` |

**Ejemplo con SQL compleja**:
```xml
<coll name="ContentDatos"
      sql="select t1.*, t1.NOMBRE as MAP_NOMBRE_GRID,
           t1.DIRECCION as MAP_DIRECCION_GRID,
           replace(t1.LATITUD, ',', '.') as MAP_LATITUD_GRID
           from ##PREF##mapa_datos t1"
      objname="mapa_datos"
      updateobj="mapa_datos"
      loadall="true"
      check-owner="false"
      dependent="false">
```

### 2.3 Atributos visuales

| Atributo | Tipo | Descripción | Ejemplo |
|----------|------|-------------|---------|
| `bgcolor` | color | Color de fondo de la coleccion. | `bgcolor="#FFFFFF"` |
| `notab` | boolean | Oculta las pestanas de navegación entre grupos. | `notab="true"` |
| `special` | boolean | Marca como coleccion especial (sin tabla real en BD). | `special="true"` |
| `show-toolbar` | boolean | Muestra u oculta la barra de herramientas del sistema. | `show-toolbar="false"` |
| `show-footer` | boolean | Muestra u oculta el pie de página del sistema. | `show-footer="true"` |
| `group-theme` | string | Tema visual para los tabs de grupo. | `group-theme="material"` |
| `tab-mode` | string | Modo de los tabs: `scrollable` o `fixed`. | `tab-mode="scrollable"` |
| `group-swipe` | boolean | Permite deslizar entre grupos con gesto. | `group-swipe="true"` |
| `no-data-align` | string | Alineacion del mensaje "sin datos". | `no-data-align="center"` |
| `cell-selected-bgcolor` | color | Color de fondo de celda seleccionada. | `cell-selected-bgcolor="#00FF00"` |
| `cell-selected-border-color` | color | Color del borde de celda seleccionada. | `cell-selected-border-color="#00000000"` |
| `cell-odd-color` | color | Color de filas impares. | `cell-odd-color="#FFFFFF"` |
| `cell-even-color` | color | Color de filas pares. | `cell-even-color="#F2F2F2"` |
| `cell-height` | dimensión | Alto fijo de cada fila en modo listado (en puntos `p`). | `cell-height="80p"` |
| `cell-tpadding` | dimensión | Margen interior superior de cada celda. | `cell-tpadding="4p"` |
| `cell-bpadding` | dimensión | Margen interior inferior de cada celda. | `cell-bpadding="4p"` |
| `cell-bgcolor` | color | Color de fondo general de todas las celdas. | `cell-bgcolor="#FFFFFF"` |

### 2.4 Valores de progid

El atributo `progid` define el tipo de objeto de datos:

| Valor | Descripción |
|-------|-------------|
| `ASData.CASBasicDataObj` | Objeto de datos básico (el más común) |
| `ASGestion.CASEmpresa` | Objeto de gestion de empresa (para coleccion Empresas) |
| `ASGestion.CASUser` | Objeto de gestion de usuario (para coleccion Usuarios) |

> **Nota**: `progid` es **opcional**. Si se omite, la coll se comporta como un objeto de datos genérico (equivalente a `ASData.CASBasicDataObj`). Solo los casos especiales lo requieren: **Empresas** usa `ASGestion.CASEmpresa` y **Usuarios** `ASGestion.CASUser`, normalmente en `mappings.xne`.

#### `ID` y `ROWID`: columnas de plataforma (no hace falta declararlas)

Los campos `ID` y `ROWID` existen siempre en toda tabla persistida (con `objname`) **a nivel de base de datos** y XOne **gestiona sus valores automáticamente** (el `ID` es autonumérico; el `ROWID` lo autogenera el framework). **No hace falta declararlos** como nodo `<prop>` dentro del `<group>`: declararlos es válido pero redundante, así que la recomendación es omitirlos por limpieza.

| Campo  | Tipo BD | ¿Hace falta declararlo como `<prop>`? | ¿Incluir en el SELECT del `sql=`? |
|--------|---------|--------------------------|-----------------------------------|
| `ID`   | N (autoincremental, clave primaria) | **No** (redundante, aunque válido) | **SI** — siempre |
| `ROWID`| T size 32 (GUID hex sin guiones, gestionado por XOne para la replica) | **No** (redundante, aunque válido) | **NO** — no es necesario |

```xml
<!-- REDUNDANTE: declarar ID y ROWID (es válido, pero los gestiona XOne) -->
<coll name="Clientes" progid="ASData.CASBasicDataObj"
      sql="SELECT * FROM ##PREF##Clientes" objname="Clientes" updateobj="Clientes">
    <group name="General" id="1">
        <prop name="ID" type="N" visible="0" />              <!-- redundante: lo gestiona XOne -->
        <prop name="NOMBRE" type="T" visible="7" />
        <prop name="ROWID" type="T" size="32" visible="0" /> <!-- redundante: lo gestiona XOne -->
    </group>
</coll>

<!-- RECOMENDADO (más limpio): solo campos de negocio; el ID se rescata en el SELECT -->
<coll name="Clientes" progid="ASData.CASBasicDataObj"
      sql="SELECT ID, NOMBRE FROM ##PREF##Clientes" objname="Clientes" updateobj="Clientes">
    <group name="General" id="1">
        <prop name="NOMBRE" type="T" visible="7" />
    </group>
</coll>
```

> Aplica a TODAS las colls, incluidas Empresas (`ASGestion.CASEmpresa`) y Usuarios (`ASGestion.CASUser`).

#### Convencion de prefijos en nombres de campos

| Prefijo | Uso | Ejemplo |
|---------|-----|---------|
| _(sin prefijo)_ | Campo de la tabla principal — se graba en BD | `NOMBRE`, `FECHA`, `ESTADO` |
| `MAP_` | Campo de tabla enlazada (JOIN) — **no** se graba en BD | `MAP_NOMBRE_CLIENTE`, `MAP_TOTAL` |
| `ID` + nombre | Clave foranea de enlace a otra coleccion | `IDCLIENTE`, `IDEMPRESA` |
| `@` | Campo de tipo `Z` (contents embebido) | `@LineasPedido` |
| `%` | Campo de tipo `NC` usado como bitmask | `%OPCIONES` |
| `$` | Campo calculado (formula) | `$IMPORTE_TOTAL` |

### 2.5 Colecciones especiales vs colecciones de datos

**Coleccion especial** (`special="true"`):
- No tiene tabla en la base de datos.
- Se usa para pantallas de menú, login, bienvenida (`EntradaApp`) u otras sin datos persistentes.
- Los campos `<prop>` son solo de memoria temporal.
- No necesita `sql`, `objname` ni `updateobj`.

```xml
<coll name="MenuPrincipal" title="Menu"
      special="true" notab="true" bgcolor="#FFFFFF">
    <!-- Solo lógica y UI, sin datos en BD -->
</coll>
```

**Coleccion de datos**:
- Tiene tabla en la base de datos.
- Requiere `sql`, `objname` y `updateobj`.
- Los campos `<prop>` se mapean a columnas de la tabla.

```xml
<coll name="Clientes"
      sql="SELECT * FROM ##PREF##Clientes"
      objname="Clientes" updateobj="Clientes"
      loadall="true">
    <!-- Campos mapeados a columnas de gen_Clientes -->
</coll>
```

### 2.6 Ejemplo completo comentado

Ejemplo real basado en el proyecto UseCars:

```xml
<?xml version="1.0" encoding="utf-8"?>
<!--
    MenuPrincipal - Pantalla principal con mapa
-->
<coll name="MenuPrincipal" title="UseCars"
      notab="true"
      show-toolbar="false"
      bgcolor="#FFFFFF">

    <!-- Evento create: se ejecuta una sola vez al crear -->
    <create>
        <script>
            self.MAP_ORIGEN = "";
            self.MAP_DESTINO = "";
            self.MAP_TIPO_VEHICULO = "ECONOMY";
        </script>
    </create>

    <!-- Inicializar la pantalla cada vez que se abre: usar before-edit -->
    <before-edit refresh="false" show-wait-dialog="false">
        <script>
            let usuario = obtenerUsuarioActual();
            if (usuario) {
                self.MAP_NOMBRE_USUARIO = usuario.NOMBRE;
            }
        </script>
    </before-edit>

    <!-- Grupo principal sin pestana -->
    <group name="grpPrincipal" id="1" class="groupNoTab">
        <frame name="frmMapa" width="100%" height="100%">
            <prop name="MAP_MAPA" type="Z" viewmode="mapview" visible="7"
                  width="100%" height="100%"
                  show-user-location="true"/>
        </frame>
    </group>

    <!-- Evento al pulsar atrás -->
    <onback>
        <script>
            if (confirmar("Desea salir?", "Salir")) {
                appData.exit();
            }
        </script>
    </onback>
</coll>
```

### 2.7 Buenas prácticas

1. **Nombres descriptivos en PascalCase**: `MenuPrincipal`, `DetallePedido`, `ListaClientes`.
2. **Usar `##PREF##`** siempre en consultas SQL para compatibilidad con el prefijo de tablas.
3. **`special="true"`** para pantallas sin datos: menús, login, pantallas de selección.
4. **`notab="true"`** cuando la pantalla tiene un solo grupo visible (sin pestanas).
5. **`show-toolbar="false"`** para pantallas con header personalizado.
6. **No mezclar** `special="true"` con consultas SQL.

### 2.8 Errores comunes

| Error | Consecuencia | Solución |
|-------|-------------|----------|
| Olvidar `name` | La coleccion no se identifica | Siempre incluir `name` único |
| SQL sin `##PREF##` | Error "tabla no encontrada" | Usar `##PREF##` antes del nombre de tabla |
| `special="true"` con `sql` | Comportamiento indefinido | Usar uno u otro, nunca ambos |
| `loadall="true"` en tabla grande | Lentitud al cargar | Solo para tablas con pocos registros |
| `objname` diferente al nombre de tabla | No se guardan los datos | `objname` debe coincidir con el nombre de tabla (sin prefijo) |

---

## 3. Nodo group - Agrupaciones

El nodo `<group>` organiza el contenido dentro de una coleccion. Puede representar una pestana (tab), una sección fija (header/footer) o una zona flotante.

### 3.1 Atributos principales

| Atributo | Tipo | Requerido | Descripción |
|----------|------|-----------|-------------|
| `name` | string | **Si** | Nombre del grupo. Se muestra como nombre de pestana si hay tabs. |
| `id` | integer | **Si** | Identificador numérico **único dentro de la coll**. Si dos `<group>` comparten `id` en la misma coll el comportamiento es indefinido. Convencion: `1, 2, ...` normales; `999` HEADER fijo (`class="groupfixed_header"`), `0` FOOTER fijo (`class="groupfixed_footer"`). |
| `width` | dimensión | No | Ancho del grupo. |
| `height` | dimensión | No | Alto del grupo. Obligatorio cuando `fixed="true"`. |
| `align` | string | No | Alineacion del contenido dentro del group. Funciona igual que en `<frame>`. Ver tabla de valores en sección 4.2. Ejemplos: `center`, `left\|top`, `center\|top` |
| `scroll` | boolean | No | Habilita scroll vertical en el grupo. |
| `bgcolor` | color | No | Color de fondo. |
| `imgbk` | string | No | Imagen de fondo del grupo. |
| `class` | string | No | Clase CSS para estilizar. |
| `fixed` | boolean | No | Si es `true`, el grupo queda fijo (header/footer) sin desplazarse con el scroll. |
| `orientation` | string | No | Posición del grupo fijo: `top` o `bottom`. Solo cuando `fixed="true"`. |
| `below-drawer` | boolean | No | El grupo queda por debajo de cualquier drawer abierto. Usar en headers y footers. |
| `floating` | boolean | No | Si es `true`, el grupo se superpone sobre el contenido (modal/overlay). |
| `top` | dimensión | No | Coordenada vertical del grupo flotante. |
| `left` | dimensión | No | Coordenada horizontal del grupo flotante. |
| `tab-width` | dimensión | No | Ancho de la pestana en la barra de tabs. Por defecto `"33%"`. |
| `disableedit` | condition | No | Deshabilita la edición de todos los campos del grupo si se cumple la condición. |
| `disablevisible` | condition | No | Oculta el grupo entero si se cumple la condición. |
| `animation-in` | string | No | Macro de animación al entrar al grupo (ej: `##ALPHA_IN##`, `##RIGHT_IN##`). |
| `animation-out` | string | No | Macro de animación al salir del grupo (ej: `##ALPHA_OUT##`, `##LEFT_OUT##`). |
| `onfocus` | string | No | Evento que se ejecuta cuando el usuario selecciona el grupo. |
| `drawer-orientation` | string | No | Define el grupo como drawer lateral. Valores: `left` o `right`. |

### 3.2 Grupos fijos (fixed, orientation: top/bottom)

Los grupos fijos permanecen visibles sin importar el scroll del contenido. Son ideales para headers y footers.

```xml
<!-- Header fijo en la parte superior -->
<group name="HEADER" id="10"
       fixed="true"
       orientation="top"
       width="100%" height="120p">
    <frame name="frmtitulo" class="frmsuperior">
        <prop name="SALIR" type="B" class="btvolversuper" />
        <prop name="MENU" type="L" class="tlsuper" title="Mi App" />
    </frame>
</group>

<!-- Footer fijo en la parte inferior -->
<group name="FOOTER" id="0"
       fixed="true"
       orientation="bottom"
       width="100%" height="100p">
    <prop name="BTN_GUARDAR" type="B" title="Guardar" />
</group>
```

| Atributo | Tipo | Descripción |
|----------|------|-------------|
| `fixed` | boolean | Fija el grupo en su posición. No se desplaza con el scroll. |
| `orientation` | string | Donde se fija: `top` o `bottom`. |
| `below-drawer` | boolean | El grupo queda por debajo de cualquier drawer abierto. Usar en headers y footers para que el drawer se superponga correctamente. |

> **IMPORTANTE:** Una vez definidos los grupos fijos, el espacio restante se toma como el 100% para los grupos de contenido. No hay que restar el alto de los grupos fijos al calcular dimensiones.

### 3.3 Grupos flotantes (floating, top, left)

Los grupos flotantes se superponen sobre el contenido, como modales u overlays.

```xml
<group name="Modal" id="50"
       floating="true"
       top="100p"
       left="0"
       width="100%"
       height="400p"
       bgcolor="#77000000"
       disablevisible="MOSTRAR_MODAL=0">
    <frame name="ContenidoModal" width="80%" bgcolor="#FFFFFF">
        <!-- contenido del modal -->
    </frame>
</group>
```

### 3.3b Grupos Drawer (panel lateral deslizante)

Un drawer es un grupo que permanece oculto hasta que el usuario desliza desde un borde lateral de la pantalla o se abre por código. Al desplegarse, el fondo queda oscurecido por una capa semitransparente.

```xml
<!-- Definición del drawer -->
<group name="MenuLateral" id="999" drawer-orientation="left" width="70%" height="100%">
    <prop name="MAP_BT_CLIENTES" type="B" title="Clientes" visible="1"
          onclick="javascript:irColl('ListaClientes'); ui.hideGroup(999);"
          class="xnTituloDrawerC" />
    <prop name="MAP_BT_SALIR" type="B" title="Salir" visible="1"
          method="ExecuteNode(onback)" class="xnTituloDrawerC" />
</group>

<!-- Header con botón para abrir el drawer — below-drawer para que el drawer se superponga -->
<group name="Header" id="10" fixed="true" orientation="top" below-drawer="true" width="100%" height="120p">
    <prop name="MAP_BT_MENU" type="B" img="menu_icon.png"
          onclick="javascript:ui.showGroup(999);" width="80p" height="80p" />
    <prop name="MAP_TITULO" type="L" title="Mi App" newline="false" />
</group>
```

**Métodos JavaScript para controlar grupos y drawers:**

| Método | Descripción |
|--------|-------------|
| `ui.showGroup(id)` | Muestra el grupo |
| `ui.showGroup(id, animIn, durIn, animOut, durOut)` | Muestra con animación personalizada |
| `ui.hideGroup(id)` | Oculta el grupo |
| `ui.toggleGroup(id)` | Alterna entre mostrar y ocultar |
| `ui.lockGroup(id, close)` | Bloquea el grupo: `close=true` lo bloquea cerrado, `false` lo bloquea abierto |
| `ui.unlockGroup(id)` | Desbloquea el grupo para que vuelva a ser interactivo |

```javascript
// Abrir drawer con animacion
ui.showGroup(999, "##RIGHT_IN##", 300, "##LEFT_OUT##", 200);
// Cerrar
ui.hideGroup(999);
// Bloquear cerrado (util durante carga inicial)
ui.lockGroup(999, true);
```

> **Convencion de IDs:** Usar IDs altos (999, 9998, 9997...) para drawers y grupos flotantes/modales, para evitar conflictos con los grupos de contenido (1, 2, 3...).

### 3.4 Grupos como pestanas (tabs)

Cuando una coleccion tiene multiples grupos con `notab="false"` (o sin `notab`), cada grupo se convierte en una pestana:

```xml
<coll name="MiApp" group-theme="material" tab-mode="scrollable">
    <group name="Datos" id="1" align="center">
        <!-- Contenido de la pestana "Datos" -->
    </group>
    <group name="Fotos" id="2" align="center">
        <!-- Contenido de la pestana "Fotos" -->
    </group>
    <group name="Mapa" id="3" align="center">
        <!-- Contenido de la pestana "Mapa" -->
    </group>
</coll>
```

**Atributos de la coleccion para tabs:**

| Atributo | Descripción |
|----------|-------------|
| `group-theme="material"` | Estilo Material Design para las pestanas |
| `tab-mode="scrollable"` | Los tabs se deslizan si no caben en pantalla |
| `tab-mode="fixed"` | Los tabs tienen ancho fijo distribuido en la barra |
| `notab="true"` | Oculta completamente la barra de tabs |
| `group-swipe="true"` | Permite deslizar entre grupos con gesto horizontal |

**Atributos del `<group>` para personalizar la pestana:**

| Atributo | Descripción |
|----------|-------------|
| `tab-width` | Ancho de la pestana en la barra. Por defecto `"33%"` |
| `animation-in` | Animación al entrar. Macros disponibles abajo |
| `animation-out` | Animación al salir |

**Macros de animación:**

| Macro entrada | Macro salida | Efecto |
|---------------|--------------|--------|
| `##ALPHA_IN##` | `##ALPHA_OUT##` | Fundido de entrada/salida |
| `##RIGHT_IN##` | `##RIGHT_OUT##` | Desde/hacia la derecha |
| `##LEFT_IN##` | `##LEFT_OUT##` | Desde/hacia la izquierda |
| `##PUSH_IN##` | `##PUSH_OUT##` | Empuje desde abajo |
| `##PUSH_DOWN_IN##` | `##PUSH_DOWN_OUT##` | Empuje hacia abajo |
| `##ROTATE3D_IN##` | `##ROTATE3D_OUT##` | Rotación 3D |
| `##ZOOM_IN##` | `##ZOOM_OUT##` | Zoom de entrada/salida |

### 3.5 group-swipe y navegación entre grupos

Con `group-swipe="true"` en la coleccion, el usuario puede deslizar horizontalmente entre grupos. Esto es útil para pantallas tipo wizard o tutorial.

```xml
<coll name="EspecialBasicos" special="true" group-swipe="true">
    <group name="Paso1" id="1">...</group>
    <group name="Paso2" id="2">...</group>
    <group name="Paso3" id="3">...</group>
</coll>
```

También se puede navegar programaticamente con `ui.showGroup()`:

```javascript
ui.showGroup(2, "##ALPHA_IN##", 500, "##ALPHA_OUT##", 500);
```

El evento `onfocus` de grupo permite detectar cuando un grupo se activa:

```xml
<group name="Group1" id="1" onfocus="ExecuteNode(onfocusgrupo(1))">
```

### 3.6 disablevisible para visibilidad condicional

Los grupos pueden ocultarse condicionalmente:

```xml
<group name="Modal" id="50"
       disablevisible="MOSTRAR_MODAL=0">
    <!-- Se oculta cuando MAP_MOSTRAR_MODAL vale 0 -->
</group>
```

La expresión sigue el formato `CAMPO=VALOR` o `CAMPO>VALOR`, `CAMPO<VALOR`, etc.

### 3.7 Patron Header + Content + Footer

Este es el patron más común en aplicaciones XOne:

```xml
<coll name="MiPantalla" special="true" notab="true">
    <!-- Header fijo arriba -->
    <group name="Header" id="10"
           fixed="true" orientation="top"
           width="100%" height="120p">
        <frame name="frmHeader" class="frmsuperior">
            <prop name="SALIR" type="B" class="btvolversuper" />
            <prop name="TITULO" type="L" class="tlsuper" title="Mi Pantalla" />
        </frame>
    </group>

    <!-- Contenido scrollable -->
    <group name="Contenido" id="1" align="center">
        <frame name="frmBody" width="100%" height="100%" scroll="true">
            <!-- Contenido principal aquí -->
        </frame>
    </group>

    <!-- Footer fijo abajo -->
    <group name="Footer" id="0"
           fixed="true" orientation="bottom"
           width="100%" height="80p">
        <frame name="frmFooter" class="frmsuperior">
            <prop name="BTN_ACCION" type="B" title="Acción" class="btinferior" />
        </frame>
    </group>
</coll>
```

### 3.8 Buenas prácticas

1. **IDs secuenciales**: Usa `id="1"`, `id="2"`, `id="3"` para grupos de contenido.
2. **ID alto para headers**: Usa `id="10"` o `id="999"` para headers fijos.
3. **ID 0 para footer**: Convencion para el footer de la aplicación.
4. **ID 99 para campos ocultos**: Grupo con `class="groupNoTab"` para props ocultos.
5. **Nombres descriptivos**: `Header`, `Contenido`, `Footer`, `Datos`, `Mapa`.
6. **`class="groupNoTab"`** cuando quieres un grupo sin que aparezca como pestana visible.

### 3.9 Errores comunes

| Error | Consecuencia | Solución |
|-------|-------------|----------|
| IDs duplicados | Solo se muestra un grupo | Cada grupo con ID único |
| `fixed="true"` sin `orientation` | No se posiciona correctamente | Siempre definir `orientation` |
| Altura fija sin `fixed` | Puede cortar contenido | Usar `scroll="true"` o altura automática |
| Grupo drawer sin `id="999"` | Conflicto con otros grupos | Usar IDs altos para drawers |

---

## 4. Nodo frame - Contenedores Visuales

El nodo `<frame>` es el equivalente a un `<div>` en HTML. Agrupa elementos visuales y permite crear layouts complejos mediante anidamiento.

### 4.1 Atributos de dimensión

| Atributo | Tipo | Descripción | Valores comunes |
|----------|------|-------------|-----------------|
| `width` | dimensión | Ancho del frame | `"100%"`, `"90%"`, `"300p"`, `"50%"` |
| `height` | dimensión | Alto del frame | `"100%"`, `"200p"`, `"-2"`, `"-1"` |

**Valores especiales de height**:
- `height="-1"`: Altura automática según contenido.
- `height="-2"`: Altura automática con ajuste fino (más preciso que -1).
- `height="100%"`: Ocupa todo el alto disponible.

```xml
<!-- Frame con altura automática -->
<frame name="frmAuto" width="100%" height="-2">
    <prop name="CAMPO1" type="T" title="Nombre" />
    <prop name="CAMPO2" type="T" title="Email" />
    <!-- La altura se ajusta al contenido -->
</frame>
```

### 4.2 Atributos de alineacion (align con |)

El atributo `align` funciona igual en los tres nodos que lo soportan: `<group>`, `<frame>` y `<prop>`. Controla la posición del contenido **dentro** del nodo. Es diferente de `text-align` (alineacion del texto dentro del campo) y de `label-align` (alineacion de la etiqueta).

El atributo acepta valores simples o combinados con el separador `|`. El primer valor es la **alineacion horizontal** y el segundo es la **alineacion vertical**:

| Valor horizontal | Valor vertical | Descripción |
|-----------------|----------------|-------------|
| `left` | — | Alineado a la izquierda |
| `right` | — | Alineado a la derecha |
| `center` | — | Centrado horizontalmente |
| — | `top` | Alineado arriba |
| — | `bottom` | Alineado abajo |
| — | `center` | Centrado verticalmente |

**Combinaciones más usadas** (formato: `horizontal|vertical`):

| Valor | Descripción |
|-------|-------------|
| `center` | Centrado solo horizontalmente |
| `center\|center` | Centrado en ambos ejes — el más común en modales y overlays |
| `left\|top` | Esquina superior izquierda — inicio del flujo normal |
| `left\|center` | Centrado verticalmente, pegado a la izquierda |
| `right\|center` | Centrado verticalmente, pegado a la derecha |
| `center\|top` | Arriba centrado horizontalmente |
| `center\|bottom` | Abajo centrado horizontalmente |
| `right\|top` | Esquina superior derecha |

> **Nota:** `align` controla la posición del **contenido dentro del nodo**. Para alinear el texto dentro de un campo de texto usar `text-align`. Para alinear la etiqueta usar `label-align`.

Ejemplo real del wiki (EspecialFrames.xne):

```xml
<frame name="group1Frame" width="100%" height="100%"
       scroll="true" align="left|top">
    <frame name="topLeft" bgcolor="#5B8DDE"
           width="30%" height="20%"
           align="center" lmargin="5%" tmargin="5%">
        <prop name="text1" type="L" title="Izquierda, arriba"
              label-wrap="true" labelbox="false" align="center" />
    </frame>
    <frame name="topRight" bgcolor="#5B8DDE"
           width="50%" height="20%"
           align="center" newline="false" lmargin="10%" tmargin="5%">
        <prop name="text2" type="L" title="Derecha, arriba"
              label-wrap="true" labelbox="false" align="center" />
    </frame>
</frame>
```

### 4.3 Margenes y padding

| Atributo | Descripción | Ejemplo |
|----------|-------------|---------|
| `tmargin` | Margen superior | `tmargin="20p"` |
| `bmargin` | Margen inferior | `bmargin="10p"` |
| `lmargin` | Margen izquierdo | `lmargin="15p"` |
| `rmargin` | Margen derecho | `rmargin="15p"` |
| `tpadding` | Padding superior | `tpadding="15p"` |
| `bpadding` | Padding inferior | `bpadding="15p"` |
| `lpadding` | Padding izquierdo | `lpadding="15p"` |
| `rpadding` | Padding derecho | `rpadding="15p"` |

> **Diferencia margen vs padding**: El margen es el espacio exterior al frame; el padding es el espacio interior entre el borde y el contenido.

### 4.3b Flujo de layout y newline

XOne posiciona los elementos en **flujo lineal de arriba a abajo**: por defecto cada `<frame>` o `<prop>` ocupa su propia línea y el siguiente baja. El atributo `newline` controla este comportamiento.

| Valor | Comportamiento |
|-------|---------------|
| `newline="true"` | **Por defecto.** El elemento empieza en una nueva línea bajo el anterior |
| `newline="false"` | El elemento se coloca a la derecha del anterior en la misma línea |

`newline` funciona igual en `<frame>` y en `<prop>`.

#### Uso principal: columnas horizontales

```xml
<!-- Dos columnas de igual ancho -->
<frame name="frmCol1" width="50%" height="200p">
    <prop name="CAMPO1" type="T" visible="1" title="Columna 1" />
</frame>
<frame name="frmCol2" width="50%" height="200p" newline="false">
    <prop name="CAMPO2" type="T" visible="1" title="Columna 2" />
</frame>

<!-- Tres columnas -->
<frame name="frmA" width="33%" height="200p">...</frame>
<frame name="frmB" width="33%" height="200p" newline="false">...</frame>
<frame name="frmC" width="34%" height="200p" newline="false">...</frame>
```

> El primer elemento de la fila **no debe llevar** `newline="false"` — ya parte desde la izquierda. Se pone solo en los siguientes. **No es solo cuestión de estilo**: poner `newline="false"` en el primer elemento de un `<frame>` puede hacer que el frame entero no se monte (sus controles desaparecen de la pantalla sin error visible). Verificado en dispositivo.

#### Uso en props: campos en la misma línea

```xml
<!-- Campo de texto con botón de busqueda al lado -->
<prop name="NOMBRE" type="T" visible="1"
      width="75%" title="Cliente:" />
<prop name="MAP_BT_BUSCAR" type="B" visible="1"
      width="20%" lmargin="5%"
      img="search.png" labelwidth="0"
      newline="false" />

<!-- Tres campos numericos en una fila -->
<prop name="CANTIDAD" type="N2" visible="1" width="30%" title="Cant:" />
<prop name="PRECIO"   type="N2" visible="1" width="30%" title="Precio:" newline="false" lmargin="2%" />
<prop name="TOTAL"    type="N2" visible="1" width="30%" title="Total:"  newline="false" lmargin="2%" locked="true" />
```

#### Reglas importantes

- Los anchos de los elementos en la misma fila **deben sumar 100%** (o menos, con márgenes). Si superan el 100% el último elemento se desborda a una nueva línea.
- Si se mezclan frames y props en la misma fila, todos deben llevar `newline="false"` salvo el primero.
- `newline` no tiene efecto en grupos fijos (`fixed="true"`) — su posición la controla `orientation`.

### 4.4 Atributos visuales

| Atributo | Tipo | Descripción | Ejemplo |
|----------|------|-------------|---------|
| `bgcolor` | color | Color de fondo | `bgcolor="#FFFFFF"` |
| `forecolor` | color | Color del borde (en combinacion con `framebox`) | `forecolor="#666666"` |
| `elevation` | integer | Elevacion / sombra (estilo Material Design) | `elevation="5"` |
| `border-corner-radius` | string | Radio de esquinas redondeadas | `border-corner-radius="10"` |
| `framebox` | boolean | Muestra un borde visible alrededor del frame | `framebox="true"` |
| `border` | boolean | Muestra el borde del frame | `border="true"` |
| `border-width` | integer | Ancho del borde en puntos | `border-width="2"` |
| `border-left` | boolean | Muestra solo el borde izquierdo | `border-left="false"` |
| `border-top` | boolean | Muestra solo el borde superior | `border-top="false"` |
| `border-right` | boolean | Muestra solo el borde derecho | `border-right="false"` |
| `border-bottom` | boolean | Muestra solo el borde inferior | `border-bottom="true"` |
| `imgbk` | string | Imagen de fondo del frame | `imgbk="background.png"` |
| `class` | string | Clase CSS para estilos reutilizables | `class="frameCard"` |
| `ignore-touch-on-transparent-area` | boolean | En frames flotantes, los toques sobre zonas transparentes no son capturados por el frame y pasan al elemento que hay detras | `ignore-touch-on-transparent-area="true"` |

Ejemplo de tarjeta con sombra:

```xml
<frame name="frmCard"
       width="90%" lmargin="5%"
       tmargin="15p"
       bgcolor="#FFFFFF"
       border-corner-radius="8"
       elevation="3"
       tpadding="15p" bpadding="15p"
       lpadding="15p" rpadding="15p">
    <prop name="TITULO" type="L" fontbold="true" fontsize="14" />
    <prop name="DESCRIPCION" type="L" forecolor="#666666" />
</frame>
```

### 4.5 Frames flotantes (floating, top, left)

Los frames flotantes se posicionan por encima del flujo normal, similar a `position: absolute` en CSS:

```xml
<frame name="frmOverlay"
       floating="true"
       left="10%"
       top="100p"
       width="80%"
       height="300p"
       bgcolor="#FFFFFF"
       elevation="10"
       disablevisible="MOSTRAR_OVERLAY=0">
    <!-- Contenido del overlay -->
</frame>
```

Ejemplo real del wiki (botón flotante para scroll):

```xml
<frame name="frmblotante"
       floating="true"
       top="976p" left="650p"
       width="64p" height="64p"
       disablevisible="MAP_VALORVER=0">
    <prop name="ICONOMAS" type="IMG"
          path="##APP##\icons\arrow_down.png"
          visible="1" width="64p" labelwidth="0" />
</frame>
```

### 4.5b Bottom Sheet (panel deslizante inferior)

El Bottom Sheet es un panel que aparece deslizando desde la parte inferior de la pantalla. Se define con `behavior="bottom-sheet"` en un frame flotante.

```xml
<frame name="frmPanel" floating="true" left="0" behavior="bottom-sheet"
       initial-state="collapsed" width="100%" height="50%">
    <prop name="MAP_TL_TITULO" type="L" title="Opciones" labelwidth="0" width="100%"
          height="96p" fontbold="true" />
    <prop name="MAP_BT_OPCION1" type="B" title="Opción 1"
          width="90%" height="124p" lmargin="5%" />
    <prop name="MAP_BT_CERRAR" type="B" title="Cerrar"
          width="90%" height="124p" lmargin="5%"
          onclick="javascript:var w=ui.getView(self); w.setBottomSheetState('frmPanel','hidden');" />
</frame>
```

**Atributos del Bottom Sheet:**

| Atributo | Descripción |
|----------|-------------|
| `behavior` | Debe ser `"bottom-sheet"` para activar el panel deslizante |
| `initial-state` | Estado inicial al abrir la pantalla: `expanded`, `collapsed` o `hidden` |
| `floating` | Debe ser `"true"` |
| `left` | Posición horizontal. Normalmente `"0"` para ocupar todo el ancho |
| `width` | Ancho del panel. Normalmente `"100%"` |
| `height` | Alto máximo del panel cuando esta expandido |

**Estados disponibles para `initial-state` y `setBottomSheetState`:**

| Estado | Descripción |
|--------|-------------|
| `expanded` | Panel completamente visible al 100% de su alto |
| `collapsed` | Panel minimizado, mostrando solo una franja inferior |
| `hidden` | Panel completamente oculto |

**Control por JavaScript:**

```javascript
// Obtener la vista actual
var view = ui.getView(self);
// Expandir el panel
view.setBottomSheetState("frmPanel", "expanded");
// Colapsar
view.setBottomSheetState("frmPanel", "collapsed");
// Ocultar
view.setBottomSheetState("frmPanel", "hidden");
```

### 4.6 Frames con scroll

```xml
<frame name="frmScrollable"
       width="100%"
       height="500p"
       scroll="true">
    <!-- Contenido que puede ser mas alto que 500p -->
    <prop name="CAMPO1" type="T" title="Campo 1" />
    <prop name="CAMPO2" type="T" title="Campo 2" />
    <!-- ... mas campos ... -->
</frame>
```

El evento `onscroll` permite detectar cuando el usuario hace scroll:

```xml
<frame name="group3Frame" width="100%" height="1040p"
       scroll="true"
       onscroll="javascript:scrollArrow(e,'1');">
```

### 4.7 Frames clickeables (onclick)

Los frames pueden ser interactivos:

```xml
<frame name="frmItem"
       width="100%"
       height="100p"
       bgcolor="#FAFAFA"
       onclick="abrirDetalle(self);">
    <prop name="TITULO" type="L" fontbold="true" />
    <prop name="SUBTITULO" type="L" forecolor="#888888" />
</frame>
```

### 4.8 Frames anidados para layouts complejos

La potencia de los frames viene de la anidacion. Este ejemplo del wiki muestra frames dentro de frames:

```xml
<frame name="bottomContainer" bgcolor="#5B8DDE"
       width="100%" height="45%"
       tmargin="10%" align="left|top">
    <frame name="containedTop" bgcolor="#113163"
           width="40%" height="30%"
           align="center" lmargin="30%" tmargin="5%">
        <prop name="text3" type="L" title="Arriba"
              label-wrap="true" labelbox="false" align="center" />
    </frame>
    <frame name="containedBottom" bgcolor="#113163"
           width="50%" height="20%"
           align="center" lmargin="5%" tmargin="40%">
        <prop name="text5" type="L" title="Abajo"
              label-wrap="true" labelbox="false" align="center" />
    </frame>
</frame>
```

### 4.9 Patron: Tarjeta (Card) con Material Design

```xml
<frame name="frmCard"
       width="90%" lmargin="5%"
       tmargin="15p"
       bgcolor="#FFFFFF"
       border-corner-radius="8"
       elevation="3"
       tpadding="15p" bpadding="15p"
       lpadding="15p" rpadding="15p">
    <prop name="TITULO" type="L" fontbold="true" fontsize="16" />
    <prop name="DESCRIPCION" type="L" forecolor="#666666" fontsize="13" />
    <prop name="BTN_VER" type="B" title="Ver mas"
          width="100%" tmargin="10p" />
</frame>
```

### 4.10 Patron: Fila horizontal con columnas

Usa `newline="false"` para colocar frames uno al lado del otro:

```xml
<frame name="frmFila" width="100%" height="80p">
    <frame name="frmCol1" width="50%" newline="false">
        <prop name="CAMPO1" type="T" title="Columna 1" />
    </frame>
    <frame name="frmCol2" width="50%" newline="false">
        <prop name="CAMPO2" type="T" title="Columna 2" />
    </frame>
</frame>
```

### 4.11 Patron: Item de lista con icono y textos

```xml
<frame name="frmListItem" width="100%" height="80p" bgcolor="#FFFFFF">
    <frame name="frmIcono" width="60p" height="60p"
           newline="false" align="center">
        <prop name="ICONO" type="IMG" width="40p" height="40p" />
    </frame>
    <frame name="frmTexto" width="-2" height="60p"
           newline="false" lmargin="10p">
        <prop name="TITULO" type="L" fontbold="true" />
        <prop name="SUBTITULO" type="L" forecolor="#888888" fontsize="10" />
    </frame>
</frame>
```

### 4.12 Buenas prácticas

> **REGLA CRITICA:** Un `<frame>` **solo se pinta si contiene al menos un `<prop>` visible**. Un frame vacio o con todos sus props ocultos (`visible="0"`) no ocupa espacio ni se renderiza. No usar frames como espaciadores ni como elementos decorativos vacios.

1. **Nombres con prefijo `frm`**: `frmHeader`, `frmBody`, `frmFooter`, `frmCard`.
2. **Siempre al menos un prop visible**: Todo frame que deba aparecer en pantalla debe contener al menos un `<prop>` con `visible` distinto de `0`.
3. **Porcentajes para responsive**: Usa `%` para anchos que se adapten a diferentes pantallas.
4. **`height="-2"` para contenido variable**: Evita alturas fijas cuando el contenido puede cambiar.
5. **`newline="false"` para filas**: Indispensable para colocar frames en horizontal.
6. **Evitar anidamiento excesivo**: Más de 4-5 niveles afecta al rendimiento.
7. **`elevation` para jerarquía visual**: Valores de 1 a 10 para sombras sutiles.

### 4.13 Errores comunes

| Error | Consecuencia | Solución |
|-------|-------------|----------|
| Frame sin props visibles dentro | El frame no se renderiza — no ocupa espacio ni se pinta | Asegurarse de que haya al menos un `<prop>` visible dentro del frame |
| Usar frame como espaciador vacio | No funciona — el frame no ocupa espacio si no tiene props visibles | Usar `tmargin`/`bmargin` en el prop anterior o un `<prop type="L" visible="1" height="20p">` como separador |
| Olvidar `newline="false"` | Los frames se apilan verticalmente | Anadir `newline="false"` al frame que va al lado |
| Altura fija con contenido variable | Contenido cortado o espacio vacio | Usar `height="-2"` |
| Anidamiento excesivo | Rendimiento degradado | Aplanar la estructura |
| `width` que suma más de 100% | Desbordamiento visual | Verificar que las columnas sumen 100% |
| `floating="true"` sin `top`/`left` | Posición impredecible | Siempre especificar posición |

---

**Siguiente:** [02b - Nodo prop y tipos](02b-xml-prop-tipos.md) · **Índice:** [02 - Guía XML/UI](02-xml-ui-complete-guide.md)
