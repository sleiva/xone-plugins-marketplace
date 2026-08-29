# XML/UI Referencia — Estructura: archivos, coll, frame, group

Sub-archivo de [xone-xml-ui-reference.md](xone-xml-ui-reference.md). Cubre la estructura base de los archivos `.xne`: declaración XML, jerarquía de nodos, convencion `MAP_`, nodo `<coll>` completo (atributos, herencia `inherits`, composición `<include-layout>`), nodo `<frame>` y nodo `<group>`.

## Tabla de Contenidos

- [1. Estructura de Archivos .xne](#1-estructura-de-archivos-xne)
- [2. Nodo coll - Referencia Completa](#2-nodo-coll---referencia-completa)
- [5. Nodo frame - Referencia Completa](#5-nodo-frame---referencia-completa)
- [6. Nodo group - Referencia Completa](#6-nodo-group---referencia-completa)

---

## 1. Estructura de Archivos .xne

### Fuente `.xne` vs Salida Generada `.xml`

Antes de nada, un punto importante sobre las extensiones:

- **`.xne`** es el **fichero fuente** de colecciones y pantallas. Es lo que el programador edita y lo que el agente crea, lee y modifica.
- **`.xml`** (en ficheros de colecciones/pantallas, NO `app.xml`) es un **artefacto generado automáticamente por XOneStudio** a partir del `.xne` correspondiente. Existe porque algunos motores de ejecución del framework aún leen `.xml`, pero se regenera solo en cada build. El agente NO debe crear, editar, leer ni referenciar estos `.xml` — se ignoran por completo.
- **`app.xml`** es la única excepción: es fuente (no tiene `.xne` que lo genere) y se edita directamente.

Regla operativa: **solo se trabaja con `.xne`** (más `app.xml`, `app.ini`, CSS, JS y recursos). Si un proyecto tiene `.xne` y `.xml` de colecciones conviviendo, los `.xml` se ignoran. Plan de futuro: los `.xml` de colecciones desaparecen y todo queda en `.xne`.

### Declaración XML

Todo archivo `.xne` debe comenzar con la declaración XML estándar:

```xml
<?xml version="1.0" encoding="utf-8"?>
```

Encodings soportados:
- `utf-8` (recomendado)
- `iso-8859-1`
- `iso-8859-15`

### Estructura Mínima Valida

```xml
<?xml version="1.0" encoding="utf-8"?>
<coll name="NombreColeccion">
    <group name="General" id="1">
        <prop name="CAMPO1" type="T" visible="7" />
    </group>
</coll>
```

### Jerarquía de Nodos

```
<coll>                          # Raiz - Define la coleccion
├── <group>                     # Agrupa contenido (tabs/secciones)
│   ├── <frame>                 # Contenedor visual de layout
│   │   ├── <prop>              # Campo de datos o control UI
│   │   ├── <frame>             # Frames anidados permitidos
│   │   └── <prop>
│   ├── <prop>                  # Props directos en group (sin frame)
│   └── <frame>
├── <prop>                      # Props fuera de group (visible="0", datos internos)
├── <contents>                  # Definiciones de colecciones embebidas
│
│   ── Handlers de ciclo de vida ──────────────────────────────────
├── <create>                    # Una sola vez al instanciar el objeto.
│                               # Inicialización de campos MAP_, flags, version, etc.
│                               # NO se repite al volver a la pantalla.
├── <before-edit>               # Antes de mostrar la pantalla en modo edicion.
│                               # Evento habitual para cargar datos, setval de macros,
│                               # activar auto-refresh. Se ejecuta CADA VEZ que el
│                               # objeto se abre para editar (incluyendo al volver).
├── <after-edit>                # Justo despues de que before-edit termina y la UI
│                               # ya esta visible. Util para acciones post-carga
│                               # que necesitan que la pantalla ya este renderizada.
├── <load>                      # Al cargar datos de un <contents> embebido.
│                               # Uso infrecuente. NO es el evento de mostrar pantalla.
│
│   ── Handlers de datos ──────────────────────────────────────────
├── <insert>                    # Después de insertar un registro nuevo en BD.
├── <update>                    # Después de actualizar un registro existente en BD.
├── <delete>                    # Antes de eliminar un registro. Lanzar excepcion
│                               # para cancelar el borrado.
├── <onchange>                  # Al cambiar el valor de un campo. Puede contener
│                               # subnodos <field name="CAMPO"> para reaccionar
│                               # a campos especificos, o <field name="##ANY##">
│                               # para cualquier campo.
│
│   ── Handlers de navegacion ────────────────────────────────────
├── <onback>                    # Al pulsar el boton atras del dispositivo.
├── <selecteditem>              # Al pulsar un item en una lista (modo lista).
│                               # Habitualmente abre el detalle con ui.openEditView(self).
├── <ondateselected>            # Al seleccionar una fecha en calendarview.
│                               # Recibe parametro DATEVALUE con la fecha seleccionada.
│
│   ── Handlers personalizados ───────────────────────────────────
└── <nombreCustom>              # Handler con nombre propio, invocado con
                                # method="ExecuteNode(nombreCustom)" o
                                # onclick="self.executeNode('nombreCustom');"
                                # (el nombre del nodo debe ser un string literal).
                                # Puede recibir parametros via <param name="x" />
```

### Convencion de Nombres de Archivos

| Tipo de Archivo | Convencion | Ejemplo |
|-----------------|------------|---------|
| Pantalla de entrada | `EntradaApp.xne` | Siempre este nombre |
| Menu principal | `MenuPrincipal.xne` | PascalCase |
| Login | `Login.xne` o `LoginColl.xne` | PascalCase |
| Coleccion de datos | `[NombreColeccion].xne` | `Productos.xne`, `Pedidos.xne` |
| Pantalla de detalle | `Detalle[Entidad].xne` | `DetalleProducto.xne` |
| Pantalla de lista | `Lista[Entidad].xne` | `ListaProductos.xne` |
| Mappings (único) | `mappings.xne` | Solo Empresas y Usuarios |

### Convencion del Prefijo MAP_

El prefijo `MAP_` es una **señal al framework** que indica que el prop NO corresponde a una columna de la tabla apuntada por `objname`. El framework **excluye** los campos `MAP_*` de los `INSERT` y `UPDATE` generados contra esa tabla. Por tanto, **`MAP_loquesea` no existe ni debe existir como columna en la base de datos**.

**Regla de oro:** Si el valor del prop NO proviene de una columna de la tabla de `objname`, su `name` **debe empezar por `MAP_`**.

#### Los tres casos en los que se usa MAP_

**1. Campos que vienen de un JOIN en el SQL de la coll**

Cuando el SQL de la `<coll>` hace `LEFT JOIN` a otra tabla para traer descripciones, los alias de esos campos llevan `MAP_`:

```xml
<coll sql="SELECT t1.*, c.NOMBRE AS MAP_NOMBRECLIENTE
           FROM ##PREF##Pedidos t1
           LEFT OUTER JOIN ##PREF##Clientes c ON t1.IDCLIENTE=c.ID"
      objname="pedidos" updateobj="pedidos" ...>
    <group name="General" id="1">
        <prop name="IDCLIENTE"         type="N" visible="7" mapcol="Clientes" mapfld="ID" />
        <prop name="MAP_NOMBRECLIENTE" type="T" visible="7" locked="true" fieldsize="150" />
    </group>
</coll>
```

**2. Campos enlazados via `linkedto` (combos/lookups)**

El prop visible de un combo (el que tiene `linkedto`/`linkedfield`) lleva `MAP_` porque su valor proviene del lookup, no de la tabla propia:

```xml
<!-- Prop oculto: FK a TiposProducto, SI es columna de la tabla -->
<prop name="IDTIPO" type="N" visible="0" mapcol="TiposProducto" mapfld="ID" />

<!-- Prop visible: descripción del lookup, NO es columna -->
<prop name="MAP_TIPO_DESC" type="T" visible="1"
      linkedto="IDTIPO" linkedfield="DESCRIPCION" showinline="true" />
```

**3. Props puramente visuales (sin origen de datos)**

Cualquier prop sin dato persistible también lleva `MAP_`:

- Etiquetas: `MAP_TITULO`, `MAP_SUBTITULO` (`type="L"`)
- Botones: `MAP_BTN_GUARDAR`, `MAP_BTN_CANCELAR` (`type="B"`)
- Imágenes decorativas: `MAP_LOGO` (`type="IMG"`)
- Contenedores de contents: `MAP_LISTA` (`type="Z"`)
- Valores calculados en runtime: `MAP_TOTAL`, `MAP_SUBTOTAL_IVA`
- Estados de UI: `MAP_TAB`, `MAP_MODO`, `MAP_SELECCIONADO`
- Buscadores / filtros temporales: `MAP_BUSQUEDA`, `MAP_FILTRO`
- Callbacks / objetos JS: `MAP_CALLBACK` (`type="O"`)

#### Campos sin MAP_

Los campos SIN prefijo `MAP_` son **campos de datos que SI se persisten** como columnas de la tabla de `objname`:
- `NOMBRE`, `CODIGO`, `FECHA`, `ID`, `PRECIO`, `ESTADO`, `IDCLIENTE` (FK), etc.

#### Mecanismo y consecuencias

- Los `MAP_*` **no se persisten**: viven solo en memoria del DataObject durante la pantalla.
- Se leen y escriben desde JS con normalidad: `self.MAP_CAMPO`, `self.getValue("MAP_CAMPO")`.
- Pueden usarse en `disablevisible`, macros (`##FLD_MAP_xxx##`) y `ui.refresh("MAP_xxx")`.
- Los `MAP_` **no son de solo lectura** — se les puede asignar valor; `locked="true"` es una decisión de UI independiente.

#### Anti-patrones

| Error | Consecuencia |
|-------|--------------|
| Poner `MAP_` a un campo que SI esta en BD | El dato no se persiste: se pierde al guardar |
| Omitir `MAP_` en un alias de JOIN | El framework genera UPDATE sobre columna inexistente -> error SQL |
| Omitir `MAP_` en el prop visible de un combo con `linkedto` | El framework intenta persistir la descripción -> error SQL |
| Declarar columna `MAP_LOQUESEA` en la tabla | Columna muerta: el framework nunca escribe en ella |

---

## 2. Nodo coll - Referencia Completa

El nodo `<coll>` es la raiz de cada archivo `.xne`. Define una coleccion que puede ser una tabla de base de datos, una pantalla de menu, un formulario, una lista de datos o un contenedor de lógica de negocio.

> **REGLAS GENERALES DE NAMING (aplican a coll/group/frame/prop):**
>
> 1. **`name` es case-sensitive.** `name="MiNombre"` y `name="minombre"` son nombres **distintos** para XOne. Aplica también a TODAS las referencias cruzadas: `self.X`, `mapcol`, `linkedto`, `inherits`, `<field name="...">`, `getControl("...")`, `ui.openEditView("...")`, `appData.getCollection("...")`, etc. Mantener una única convencion en todo el proyecto.
> 2. **El `id` de `<group>` es obligatorio y único en la coll.** No pueden coexistir dos `<group id="1">` en la misma `<coll>`. Convencion: `id="1"`, `id="2"`, ... para grupos normales; `id="999"` para HEADER fijo (`class="groupfixed_header"`) y `id="0"` para FOOTER fijo (`class="groupfixed_footer"`).
> 3. **Unicidad de `name` en la coll.** Dentro de una misma `<coll>` no puede repetirse el `name` de ningun nodo (`<group>`, `<frame>`, `<prop>`, eventos), aunque estén en `<group>` o `<frame>` distintos. El ambito de unicidad es la coll entera.

### Atributos de Identificación

| Atributo | Tipo | Obligatorio | Descripción | Ejemplo |
|----------|------|-------------|-------------|---------|
| `name` | string | **Si** | Nombre identificador único de la coleccion | `name="MenuEntrada"` |
| `title` | string | No | Título visible de la coleccion | `title="Productos"` |
| `progid` | string | No | Identificador del objeto de negocio. **Opcional**: sin él la coll se comporta como un objeto de datos genérico (≡ `ASData.CASBasicDataObj`). Solo casos especiales: `ASGestion.CASEmpresa` (Empresas), `ASGestion.CASUser` (Usuarios) | `progid="ASGestion.CASUser"` |
| `objname` | string | Si* | Nombre del objeto de negocio / tabla en BD (*obligatorio para persistencia) | `objname="Productos"` |
| `updateobj` | string | No | Objeto para actualizaciones (normalmente igual a objname) | `updateobj="Productos"` |
| `inherits` | string | No | Nombre de otra coll de la que hereda grupos, frames, props y eventos. En duplicidad de `name`, prevalece la definición de esta coll hija. No admite herencia multiple (solo un padre). Ver sección dedicada más abajo | `inherits="groupsFixed"` |

### Atributos de Datos y SQL

| Atributo | Tipo | Descripción | Ejemplo |
|----------|------|-------------|---------|
| `sql` | string | Consulta SQL para cargar datos. Usar `##PREF##` para prefijo de tablas | `sql="SELECT * FROM ##PREF##Productos"` |
| `loadall` | bool | Carga todos los registros al abrir | `loadall="true"` |
| `dependent` | bool | Indica si depende de coleccion padre | `dependent="false"` |
| `check-owner` | bool | Verifica propietario del registro | `check-owner="false"` |
| `userawsql` | bool | Usar SQL directo sin procesamiento del framework | `userawsql="true"` |
| `connection` | string | Nombre de conexión a BD alternativa | `connection="GpsConnection"` |
| `page-limit-off` | int | Desactiva paginación (1=desactivar) | `page-limit-off="1"` |
| `autorefresh` | bool | Refresca datos automáticamente al regresar de otra ventana | `autorefresh="true"` |
| `filter` | string | Condición WHERE para filtrar registros por defecto | `filter="ACTIVO=1"` |
| `sort` | string | Criterio de ordenamiento (ORDER BY) | `sort="FECHA DESC"` |

### Atributos de UI

| Atributo | Tipo | Descripción | Ejemplo |
|----------|------|-------------|---------|
| `special` | bool | Marca como coleccion especial (punto de entrada) | `special="true"` |
| `notab` | bool | Oculta pestanas de navegación | `notab="true"` |
| `show-toolbar` | bool | Muestra/oculta barra de herramientas del sistema | `show-toolbar="false"` |
| `show-footer` | bool | Muestra pie de página del sistema | `show-footer="true"` |
| `group-theme` | string | Tema visual de grupos/tabs | `group-theme="material"` |
| `tab-mode` | string | Modo de pestanas: `scrollable` o `fixed` | `tab-mode="scrollable"` |
| `bgcolor` | color | Color de fondo de la coleccion | `bgcolor="#FFFFFF"` |
| `hardware-accelerated` | bool | Activar/desactivar aceleracion por hardware. Poner `false` en colecciones que se abren como dialogo con fondo transparente (`bgcolor="#00000000"`) para evitar que el fondo aparezca negro | `hardware-accelerated="false"` |

### Atributos de Celdas (modo lista)

| Atributo | Tipo | Descripción | Ejemplo |
|----------|------|-------------|---------|
| `cell-bgcolor` | color | Color de fondo de cada celda | `cell-bgcolor="#F2F2F2"` |
| `cell-selected-bgcolor` | color | Color de fondo celda seleccionada | `cell-selected-bgcolor="#00FF00"` |
| `cell-selected-border-color` | color | Color borde celda seleccionada | `cell-selected-border-color="#00000000"` |
| `cell-selected-forecolor` | color | Color texto celda seleccionada | `cell-selected-forecolor="#000000"` |
| `cell-odd-color` | color | Color de fondo de filas impares | `cell-odd-color="#FFFFFF"` |
| `cell-even-color` | color | Color de fondo de filas pares | `cell-even-color="#F2F2F2"` |
| `cell-border` | bool | Mostrar borde de celda | `cell-border="false"` |
| `cell-border-width` | int | Grosor borde celda | `cell-border-width="2"` |
| `cell-tpadding` | dim | Padding superior celda | `cell-tpadding="2p"` |
| `cell-bpadding` | dim | Padding inferior celda | `cell-bpadding="2p"` |
| `cell-align` | string | Alineacion contenido celda | `cell-align="center"` |

### Atributos de Texto sin datos

| Atributo | Tipo | Descripción | Ejemplo |
|----------|------|-------------|---------|
| `no-data-align` | string | Alineacion del mensaje "sin datos" | `no-data-align="center"` |
| `no-data-fontname` | string | Fuente del mensaje "sin datos" | `no-data-fontname="Roboto.ttf"` |
| `loading-align` | string | Alineacion del indicador de carga | `loading-align="left"` |

### Atributos de Eventos en coll

| Atributo | Tipo | Descripción | Ejemplo |
|----------|------|-------------|---------|
| `onback` | string | Código JS al pulsar botón atrás (inline) | `onback="appData.exit();"` |
| `onbeforeedit` | string | Antes de mostrar modo edición | `onbeforeedit="doOnBeforeEdit(e);"` |
| `onafteredit` | string | Después de edición | `onafteredit="doOnAfterEdit(e);"` |
| `ondraweropened` | string | Drawer completamente abierto (`e.id`) | `ondraweropened="onDrawerOpened(e);"` |
| `ondrawerclosed` | string | Drawer completamente cerrado (`e.id`) | `ondrawerclosed="onDrawerClosed(e);"` |
| `ondrawerslide` | string | Mientras se desliza el drawer (`e.id`, `e.slideOffset` 0.0–1.0) | `ondrawerslide="onDrawerSlide(e);"` |
| `ondrawerstatechanged` | string | Cambio de estado del arrastre (`e.state`: idle/dragging/settling) | `ondrawerstatechanged="onDrawerStateChanged(e);"` |

### Ejemplo Completo de coll

```xml
<coll name="Productos"
    title="Catalogo de Productos"
    sql="SELECT t1.* FROM ##PREF##Productos t1"
    loadall="true"
    updateobj="Productos"
    objname="Productos"
    notab="true"
    check-owner="false"
    dependent="false"
    show-toolbar="false"
    cell-bgcolor="#F2F2F2"
    cell-selected-bgcolor="#E3F2FD"
    cell-selected-border-color="#00000000"
    no-data-align="center">
    <!-- contenido -->
</coll>
```

### Herencia entre Colecciones con `inherits`

El atributo `inherits` en `<coll>` permite heredar **grupos, frames, props y nodos de evento** de otra coll. La coll hija se comporta en ejecución como una mezcla entre la padre y la hija.

```xml
<coll name="EspecialHerencia" inherits="groupsFixed"
      special="true" notab="false" group-swipe="true">
    ...
</coll>
```

**Regla de precedencia:** cuando un elemento (`<group>`, `<frame>`, `<prop>` o nodo de evento) aparece con el mismo `name` en padre e hija, **prevalece la definición de la hija**. Los elementos del padre no duplicados se conservan.

**Reglas adicionales:**
- `inherits` admite **un único padre** (no herencia multiple: `inherits="A,B"` NO existe).
- Soporta **cadenas**: A → B → C. La resolución recorre toda la cadena, aplicando hijo-gana en cada nivel.
- Los eventos a nivel de coll (`<onback>`, `<before-edit>`, `<create>`, `<after-edit>`, custom nodes) también se heredan con la misma regla.
- **No hay concepto de `super()`**: si la hija define un evento con el mismo nombre que el padre, ejecuta el suyo y el del padre queda sin ejecutar.

**Caso de uso típico:** scaffolding visual compartido (header fijo, footer de paginación, botones de navegación) definido en una coll `special="true"` y reutilizado por todas las pantallas via `inherits`.

```xml
<!-- PADRE: estructura comun (sin lógica de pantalla concreta) -->
<coll name="groupsFixed" title="" special="true">
    <group name="HEADER" id="999" class="groupfixed_header">
        <frame name="frmtitulo" class="frmsuperior">
            <prop name="SALIR" type="B" class="btvolversuper" />
            <prop name="MENU" type="L" class="tlsuper" title="Título por defecto" />
        </frame>
    </group>
    <group name="FOOTER" id="0" class="groupfixed_footer">
        <prop name="MAP_GROUP" type="N" visible="0" />
        <prop name="MAP_TOTAL_PAGES" type="N" visible="0" />
    </group>
    <onback>
        <action name="runscript">
            <script language="javascript">
                ui.getView(self).exit();
            </script>
        </action>
    </onback>
</coll>

<!-- HIJA: hereda todo y sobreescribe lo que necesite -->
<coll name="PantallaConcreta" inherits="groupsFixed"
      special="true" notab="false">
    <!-- Override solo del título del header -->
    <group name="HEADER" id="999">
        <frame name="frmtitulo" class="frmsuperior">
            <prop name="MENU" type="L" class="tlsuper" title="Mi Pantalla" />
        </frame>
    </group>
    <!-- Grupo nuevo que no existe en el padre -->
    <group name="Group1" id="1">
        <prop name="MAP_CAMPO" type="T" visible="1" />
    </group>
    <before-edit>
        <action name="runscript">
            <script language="javascript">
                self.MAP_GROUP = 1;
                self.MAP_TOTAL_PAGES = 2;
            </script>
        </action>
    </before-edit>
</coll>
```

### Composición XML con `<include-layout>`

`<include-layout>` es un nodo hijo de `<coll>` que inyecta el contenido de un fichero XML externo en el punto donde aparece. Es composición (insertar fragmentos), no herencia.

**Sintaxis:**

```xml
<include-layout file="MisBotones.xml" group="1" frame="todo" />
```

| Atributo | Obligatorio | Descripción |
|----------|-------------|-------------|
| `file` | Si | Ruta relativa a la **raiz del proyecto** al fichero XML a incluir |
| `group` | No | ID de grupo por defecto para props del fichero incluido que no declaren `group` |
| `frame` | No | Nombre de frame por defecto para props del fichero incluido que no declaren `frame` |

**Formato del fichero incluido:**

- Cabecera: `<?xml version="1.0" encoding="utf-8"?>` (utf-8; los `.xne` pueden ir en UTF-8 o iso-8859-15)
- Raiz: `<xml>` (NO `<coll>`)
- Estructura **plana, no jerárquica**: `<prop>`, `<group>`, `<frame>` y nodos de evento al mismo nivel dentro de `<xml>`

```xml
<?xml version="1.0" encoding="utf-8"?>
<xml>
    <prop name="MAP_SALIR" type="B" title="Salir" visible="1"
          method="ExecuteNode(salir)"
          width="100%" height="20%" labelwidth="10" tmargin="0" />
    <salir refresh="false">
        <action name="runscript" type="runscript">
            <script language="javascript">
                appData.exit();
            </script>
        </action>
    </salir>
</xml>
```

**Limitaciones:**
- **No se pueden anidar `<include-layout>`**: el fichero incluido NO puede contener a su vez otro `<include-layout>`. La inclusión es un solo nivel.
- Los nombres de props/groups/frames del fichero incluido deben ser únicos en el ambito final tras la composición.
- Los atributos `group`/`frame` del `<include-layout>` solo actuan como defaults; si un prop del fichero incluido declara los suyos, prevalecen los del fichero.

**Combinacion con `inherits`:** ambos mecanismos son ortogonales y se combinan con normalidad.

```xml
<coll name="PantallaCompleja" inherits="groupsFixed" special="true">
    <group name="Group2" id="2">
        <include-layout file="ControlesGpsComunes.xml" group="2" frame="frmMapa" />
    </group>
</coll>
```

### Anti-patrones de `inherits` e `<include-layout>`

| Error | Consecuencia |
|-------|--------------|
| `inherits` multiple (`inherits="A,B"`) | Sintaxis no soportada — usar `<include-layout>` para composición |
| Cadenas de `inherits` muy largas (>3-4 niveles) | Difícil de depurar: para saber que tiene realmente una coll hay que recorrer toda la cadena hacia arriba |
| Padre gigante que todo el mundo hereda "por si acaso" | Se arrastran nodos innecesarios a cada pantalla. Mejor varias padres pequeñas y especificas |
| `<include-layout>` anidado en el fichero incluido | No soportado, fallo silencioso de carga del fragmento anidado |
| Encoding `iso-8859-1` o `iso-8859-15` en el fichero incluido | Usar **`utf-8`** en el XML de `<include-layout>` |
| Declarar `<coll>` como raiz del fichero incluido | Formato incorrecto: la raiz debe ser `<xml>` |
| Duplicar un `name` entre la coll y el fichero incluido | Viola la restricción de unicidad de nombres dentro del ambito final |

---

## 5. Nodo frame - Referencia Completa

El nodo `<frame>` es un contenedor visual para organizar el layout. Puede contener props, otros frames y controles.

### Atributos del Nodo frame

| Atributo | Tipo | Descripción | Ejemplo |
|----------|------|-------------|---------|
| `name` | string | Nombre identificador del frame | `name="frmHeader"` |
| `width` | dim | Ancho del frame | `width="100%"` |
| `height` | dim | Alto del frame | `height="120p"` |
| `bgcolor` | color | Color de fondo | `bgcolor="#2196F3"` |
| `align` | string | Alineacion del contenido | `align="center"` |
| `scroll` | bool | Habilitar scroll dentro del frame | `scroll="true"` |
| `floating` | bool | Frame flotante (posición absoluta) | `floating="true"` |
| `top` | dim | Posición desde arriba (requiere floating) | `top="100p"` |
| `left` | dim | Posición desde izquierda (requiere floating) | `left="50p"` |
| `border-corner-radius` | int | Bordes redondeados | `border-corner-radius="30"` |
| `framebox` | bool | Mostrar como caja con borde | `framebox="true"` |
| `imgbk` | string | Imagen de fondo del frame | `imgbk="background.png"` |
| `onclick` | string | Evento click en el frame | `onclick="doClick();"` |
| `onlongclick` | string | Click prolongado | `onlongclick="startDrag();"` |
| `class` | string | Clase CSS | `class="frameHeader"` |
| `newline` | bool | Forzar nueva linea | `newline="false"` |
| `tmargin` | dim | Margen superior | `tmargin="10p"` |
| `lmargin` | dim | Margen izquierdo | `lmargin="10p"` |

### Atributos de Visibilidad Condicional

| Atributo | Tipo | Descripción | Ejemplo |
|----------|------|-------------|---------|
| `disablevisible` | string | Condición para ocultar el frame | `disablevisible="MAP_VISIBILITY=0"` |

### Atributos de Animación

| Atributo | Tipo | Descripción | Ejemplo |
|----------|------|-------------|---------|
| `animation-in` | string | Token de animación de entrada | `animation-in="##ZOOM_IN##"` |
| `animation-in-delay` | int | Retardo de animación de entrada (ms) | `animation-in-delay="3000"` |
| `animation-out` | string | Token de animación de salida | `animation-out="##ZOOM_OUT##"` |
| `animation-out-delay` | int | Retardo de animación de salida (ms) | `animation-out-delay="3000"` |

### Atributos de Bottom Sheet

| Atributo | Tipo | Descripción | Ejemplo |
|----------|------|-------------|---------|
| `behavior` | string | Tipo de comportamiento | `behavior="bottom-sheet"` |
| `initial-state` | string | Estado inicial: `expanded`, `collapsed`, `hidden` | `initial-state="collapsed"` |
| `hideable` | bool | Permitir ocultar completamente | `hideable="false"` |
| `peek-height` | dim | Altura visible en modo collapsed | `peek-height="400p"` |
| `onbottomsheetstatechanged` | string | Evento al cambiar estado | `onbottomsheetstatechanged="onStateChanged(e);"` |
| `on-click-outside-state` | string | Estado que toma el bottom sheet al pulsar fuera: `hidden`, `collapsed` | `on-click-outside-state="hidden"` |

### Atributos de Posición Fija

| Atributo | Tipo | Descripción | Ejemplo |
|----------|------|-------------|---------|
| `fixed` | bool | Hacer el frame fijo (no scrolleable) | `fixed="true"` |
| `orientation` | string | Posición fija: `top` o `bottom` | `orientation="top"` |

### Ejemplo: Frame Flotante con Animación

```xml
<frame name="frmNotificacion"
    bgcolor="#4CAF50"
    width="90%"
    height="60p"
    floating="true"
    top="20p"
    left="5%"
    border-corner-radius="8"
    animation-in="##ALPHA_IN##"
    animation-in-delay="500"
    animation-out="##ALPHA_OUT##"
    animation-out-delay="300"
    disablevisible="MAP_MOSTRAR_NOTIF=0">
    <prop name="MAP_TEXTO_NOTIF" type="L" visible="1"
        width="100%" text-align="center" forecolor="#FFFFFF" />
</frame>
```

### Ejemplo: Bottom Sheet

```xml
<frame name="frmBottomSheet"
    width="100%"
    height="60%"
    initial-state="collapsed"
    floating="true"
    left="0%"
    behavior="bottom-sheet"
    hideable="false"
    peek-height="100p"
    bgcolor="#FFFFFF"
    border-corner-radius-top-left="20"
    border-corner-radius-top-right="20"
    onbottomsheetstatechanged="onSheetChanged(e);">
    <!-- Contenido del bottom sheet -->
</frame>
```

---

## 6. Nodo group - Referencia Completa

El nodo `<group>` agrupa propiedades y frames en secciones. Cuando hay multiples groups en un coll, se muestran como pestanas (tabs). Un solo group sin tabs se usa con `class="groupNoTab"`.

### Atributos del Nodo group

| Atributo | Tipo | Obligatorio | Descripción | Ejemplo |
|----------|------|-------------|-------------|---------|
| `name` | string | **Si** | Nombre visible de la pestana | `name="General"` |
| `id` | int | **Si** | Identificador numérico **único dentro de la coll que contiene al group**. Si dos `<group>` comparten `id` en la misma coll el comportamiento es indefinido. Convencion: `1, 2, ...` para tabs normales; `999` para HEADER fijo, `0` para FOOTER fijo | `id="1"` |
| `align` | string | No | Alineacion del contenido | `align="center"` |
| `scroll` | bool | No | Habilitar scroll vertical | `scroll="true"` |
| `width` | dim | No | Ancho del grupo | `width="100%"` |
| `height` | dim | No | Alto del grupo | `height="100%"` |
| `bgcolor` | color | No | Color de fondo | `bgcolor="#FFFFFF"` |
| `class` | string | No | Clase CSS | `class="groupNoTab"` |

### Uso como Tabs (multiples groups)

```xml
<coll name="Dashboard" group-theme="material" tab-mode="scrollable">
    <group name="Resumen" id="1" align="center" scroll="true">
        <!-- Contenido tab Resumen -->
    </group>
    <group name="Productos" id="2" align="center">
        <!-- Contenido tab Productos -->
    </group>
    <group name="Mapa" id="3" align="center">
        <!-- Contenido tab Mapa -->
    </group>
</coll>
```

### Uso sin Tabs (group único)

```xml
<coll name="Formulario" notab="true">
    <group name="grpPrincipal" id="1" class="groupNoTab">
        <frame name="frmHeader" class="frameHeader">
            <!-- Header -->
        </frame>
        <frame name="frmBody" class="frameBody">
            <!-- Cuerpo -->
        </frame>
        <frame name="frmFooter" class="frameFooter">
            <!-- Footer -->
        </frame>
    </group>
</coll>
```

### Uso como Drawer Lateral

Un group con `id="999"` y `drawer-orientation` funciona como drawer lateral:

```xml
<coll name="MenuConDrawer" notab="true"
    ondraweropened="onDrawerOpened(e);"
    ondrawerclosed="onDrawerClosed(e);">

    <!-- Grupo principal -->
    <group name="Principal" id="1" class="groupNoTab">
        <!-- Contenido principal -->
    </group>

    <!-- Drawer lateral -->
    <group name="Drawer" id="999"
        width="60%"
        drawer-orientation="left"
        bgcolor="#FFFFFF">
        <frame name="frmDrawerHeader"
            width="100%"
            height="25%"
            bgcolor="#2B3E51">
            <!-- Cabecera del drawer -->
        </frame>
        <!-- Items del drawer -->
    </group>
</coll>
```

### Navegación Programatica entre Grupos

```javascript
// Mostrar grupo por indice (0-based en la UI)
ui.showGroup(2);

// Con animacion
ui.showGroup(2, "##ALPHA_IN##", 200, "##ALPHA_OUT##", 200);

// Verificar si grupo esta abierto (para drawers)
let window = ui.getView(self);
if (window.isGroupOpen(999)) {
    window.hideGroup(999);
}
```

---


**Siguiente:** [b - Nodo prop y tipos](xone-xml-ui-b-prop-tipos.md) · **Índice:** [xone-xml-ui-reference.md](xone-xml-ui-reference.md)