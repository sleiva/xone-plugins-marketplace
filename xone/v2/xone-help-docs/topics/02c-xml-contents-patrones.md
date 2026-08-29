# XML/UI — Contents, macros y patrones de pantalla

Sub-archivo del [Tópico 02 - Guía Completa de XML/UI](02-xml-ui-complete-guide.md). Cubre el nodo `<contents>` (relación padre-hijo entre colecciones), `<asfilter>`, nodo `<macro>` y macros del sistema, y los patrones de pantalla más comunes (login, menú, lista, detalle, tabs, mapa, chat, dashboard, maestro-detalle, edit-inrow, multi-selección).

## Tabla de Contenidos

- [6. Nodo contents - Contenido Embebido](#6-nodo-contents---contenido-embebido)
- [7. Nodo macro - Variables](#7-nodo-macro---variables)
- [8. Patrones de Pantalla Comunes](#8-patrones-de-pantalla-comunes)

---

## 6. Nodo contents - Contenido Embebido

### 6.1 Sintaxis y atributos

El nodo `<contents>` define una relación padre-hijo entre colecciones. Permite embeber una lista de registros dentro de otra pantalla.

```xml
<contents name="@NombreContent"
          src="NombreColeccionHija"
          filter="CAMPO=VALOR"
          sort="CAMPO ASC" />
```

| Atributo | Tipo | Requerido | Descripción |
|----------|------|-----------|-------------|
| `name` | string | **Si** | Nombre del content, con prefijo `@` |
| `src` | string | **Si** | Nombre de la coleccion fuente (la coleccion hija) |
| `filter` | string | No | Filtro SQL para los registros |
| `sort` | string | No | Ordenamiento de los registros |

### 6.2 Vinculacion con prop type=Z

Un `<contents>` por si solo no muestra nada. Necesita estar vinculado a un `<prop type="Z">`:

```xml
<!-- Prop que muestra la lista -->
<prop name="MAP_LISTA" type="Z" visible="1"
      contents="@MiContent"
      viewmode="recyclerview"
      width="100%" height="60%"
      edit-inrow="true" />

<!-- Contents que define la fuente de datos -->
<contents name="@MiContent" src="ColeccionHija" />
```

### 6.3 Patron maestro-detalle

El patron más común es mostrar una lista (maestro) donde cada item abre un detalle:

```xml
<coll name="ListaPedidos" notab="true"
      sql="SELECT * FROM ##PREF##Pedidos"
      objname="Pedidos" loadall="true">
    <group name="Lista" id="1">
        <!-- Campos visibles en la lista (visible="4" para content) -->
        <prop name="NUMERO" type="T" visible="4" />
        <prop name="FECHA" type="D" visible="4" />
        <prop name="TOTAL" type="N2" visible="4" />

        <!-- Campos visibles solo en edicion -->
        <prop name="CLIENTE" type="T" visible="1" title="Cliente" />
        <prop name="ESTADO" type="T" visible="1" title="Estado" />

        <!-- Lista de lineas del pedido -->
        <prop name="MAP_LINEAS" type="Z" visible="1"
              contents="@LineasPedido"
              viewmode="recyclerview"
              width="100%" height="300p"
              edit-inrow="true" />
    </group>

    <contents name="@LineasPedido" src="LineasPedido"
              filter="ID_PEDIDO=##FLD_ID##" />

    <selecteditem>
        <action name="runscript">
            <script>
                ui.openEditView(self);
            </script>
        </action>
    </selecteditem>
</coll>
```

### 6.4 Filtros dinámicos con ##FLD_CAMPO##

La macro `##FLD_CAMPO##` permite filtrar el content basandose en el valor de un campo del registro padre:

```xml
<!-- Filtra por el ID del registro actual -->
<contents name="@Detalles" src="Detalles"
          filter="ID_PADRE=##FLD_ID##" />

<!-- Filtro complejo con fecha -->
<contents name="Calendariodatos" src="ContentCalendarioLista"
          filter="strftime('%m',##FLD_MAP_FECHA##)=strftime('%m',FECHA)
                  and strftime('%Y',##FLD_MAP_FECHA##)=strftime('%Y',FECHA)" />

<!-- Filtro con campo de chat -->
<contents name="Chatear" src="Chatear"
          filter="IDCHAT=##FLD_MAP_CHATSEL##" />

<!-- Filtro con usuario actual -->
<contents name="nUsuarios" src="UsuariosChat"
          filter="ID<>##USERID##" />

<!-- Filtro complejo con multiples condiciones -->
<contents name="ContentDatosFiltroMultiseleccion"
          src="ContentDatosFiltroMultiseleccion"
          filter="((t1.MARCADO=1 AND 1=##FLD_MAP_BUSCAR_MARCADOS##)
                   OR (t1.MARCADO=0 AND 1=##FLD_MAP_BUSCAR_NOMARCADOS##))
                  AND (ifnull(t1.NOMBRE,'') LIKE ##FLD_MAP_BUSCAR_TEXT##)" />
```

### 6.5 Ejemplos reales

**Ejemplo de contents con edición directa** (del wiki, EspecialContents.xne):

```xml
<frame name="c1" width="98%" height="78%"
       framebox="true" border-corner-radius="10" lmargin="1%" tmargin="2%">
    <prop name="MAP_content1" height="96%" type="Z"
          contents="content1"
          forceonchange="true"
          bgcolor="#FFFFFF"
          onchange="refresh(@content1)" />
    <contents name="content1" src="ContentDatos" />
</frame>
```

**Ejemplo de contents con edición en fila**:

```xml
<frame name="c2" width="98%" height="75%"
       framebox="true" border-corner-radius="10" lmargin="1%" tmargin="2%">
    <prop name="@content2" height="96%" type="Z"
          contents="content2"
          mask="0"
          edit-inrow="true"
          bgcolor="#FFFFFF" />
    <contents name="content2" src="ContentDatosEditRow" />
</frame>
```

**Manipulación de contents desde JavaScript** (ver [Tópico 03](./03-javascript-api-guide.md)):

```javascript
// Obtener un content
var coll = self.getContents("content1");

// Crear un nuevo objeto
var obj = coll.createObject();
obj.NOMBRE = "Nuevo registro";
obj.DIRECCION = "Dirección nueva";

// Agregar a la lista (al final)
let view = ui.getView(self);
view.MAP_content1.addItem(obj);

// Agregar en una posicion concreta: 2o parametro opcional con el indice.
// Sincroniza lista y datos; el indice se acota al rango valido (negativo -> primer
// elemento; mayor que el total -> al final). Devuelve la vista de la fila insertada.
view.MAP_content1.addItem(obj, 0);   // insertar como primer elemento

// Filtrar un content
self.getContents("content4").setFilter("NOMBRE like '%texto%'");
self.getContents("content4").loadAll();
ui.getView(self).refresh("@content4");

// Ordenar un content
self.getContents("content4").sort = "NOMBRE ASC";
self.getContents("content4").loadAll();
```

### 6.6 Nodo asfilter - Filtros de Busqueda en Listas

El nodo `<asfilter>` define campos de busqueda que permiten al usuario filtrar los registros de una coleccion directamente desde la interfaz. Se declara como hijo directo de `<coll>` y genera automáticamente una barra de busqueda con los campos especificados.

```xml
<asfilter fontsize="8" left="12" sort="false">
    <field name="NUMCOMPLETO" fldname="NUMCOMPLETO"
           oper="##FLD## LIKE '##VAL##%'" width="15"
           tooltip="Albaran" newline="false">ALBARAN</field>
    <field name="FECHA" fldname="FECHA"
           oper="##FLD## >= '##VAL##'" width="10"
           tooltip="Fecha desde">FECHA DESDE</field>
</asfilter>
```

**Atributos de `<asfilter>`:**

| Atributo | Descripción |
|----------|-------------|
| `fontsize` | Tamaño de fuente de los campos del filtro |
| `left` | Margen izquierdo del panel de filtro |
| `sort` | Habilita ordenamiento en el filtro (`true`/`false`) |

**Atributos de `<field>` dentro de `<asfilter>`:**

| Atributo | Descripción |
|----------|-------------|
| `name` | Nombre del campo de filtro |
| `fldname` | Nombre del campo real en la tabla de base de datos |
| `oper` | Operador SQL. Usa `##FLD##` para el nombre del campo y `##VAL##` para el valor ingresado por el usuario |
| `width` | Ancho del campo de filtro |
| `tooltip` | Texto de ayuda / placeholder del campo |
| `newline` | Si es `false`, se coloca en la misma linea que el campo anterior |

**Ejemplo básico de busqueda por nombre:**

```xml
<asfilter>
    <field name="BUSCAR" fldname="NOMBRE"
           oper="##FLD## LIKE '%##VAL##%'" width="20"
           tooltip="Buscar por nombre">BUSCAR</field>
</asfilter>
```

> **Nota:** El contenido de texto del nodo `<field>` (ej. `BUSCAR`, `ALBARAN`) se usa como etiqueta visible del campo de filtro. La macro `##FLD##` se reemplaza por el valor de `fldname` y `##VAL##` por lo que el usuario escribe.

---

## 7. Nodo macro - Variables

### 7.1 Definición y uso

Las macros en XOne son variables que se resuelven en tiempo de ejecución. Se usan con la sintaxis `##NOMBRE##` tanto en atributos XML como en consultas SQL.

### 7.2 Macros del sistema

| Macro | Descripción | Uso típico |
|-------|-------------|------------|
| `##PREF##` | Prefijo de tablas en BD (ej: `gen_`) | Consultas SQL |
| `##ENTID##` | ID de la empresa/entidad actual | Filtros por empresa |
| `##USERID##` | ID del usuario logueado | Filtros por usuario |
| `##VERSION##` | Versión de la aplicación | Pantallas "Acerca de" |
| `##FRAME_VERSION##` | Versión del framework XOne | Información de sistema |
| `##APP##` | Ruta de la carpeta de la aplicación | Rutas de imágenes |
| `##EXIT##` | Comando para salir de la pantalla actual (con `appData.failWithMessage(-11888, ...)`). Para cerrar la app entera usar `appData.exit()` | Evento onback |
| `##NOW_TIME##` | Hora actual del sistema | Timestamps |

**Ejemplo de uso en SQL**:
```xml
<coll name="MisRegistros"
      sql="SELECT * FROM ##PREF##Registros WHERE USUARIO_ID = ##USERID##">
```

**Ejemplo de uso en ruta de imagen**:
```xml
<prop name="ICONO" type="IMG" path="##APP##\icons\xone.png" />
```

**Ejemplo de uso en create**:
```xml
<create>
    <action name="setval" field="MAP_VERSION"
            value="Versión ##VERSION## - Framework ##FRAME_VERSION##" />
</create>
```

### 7.3 Macros de campo (##FLD_CAMPO##)

Las macros `##FLD_CAMPO##` se resuelven al valor actual del campo especificado. Son útiles en:

- Filtros de contents
- Colores dinámicos
- Textos dinámicos en atributos

```xml
<!-- Color de fondo dinámico basado en un campo -->
<prop name="MAP_LABEL" type="L"
      bgcolor="##FLD_MAP_COLOR1##"
      forecolor="##FLD_MAP_COLOR2##" />

<!-- Imagen dinámica basada en un campo -->
<prop name="BTORDENAR" type="B"
      img="##FLD_MAP_BTORDEN##"
      imgsel="##FLD_MAP_BTORDENCLICK##" />

<!-- Título dinámico -->
<prop name="lblOrigen" type="L"
      title="##FLD_MAP_ORIGEN##" />

<!-- Filtro de contents con campo del padre -->
<contents name="@Detalles" src="Detalles"
          filter="ID_PADRE=##FLD_ID##" />
```

### 7.4 Macros de animación

| Macro | Descripción |
|-------|-------------|
| `##ALPHA_IN##` | Fade in (aparece) |
| `##ALPHA_OUT##` | Fade out (desaparece) |
| `##ZOOM_IN##` | Zoom in (agranda) |
| `##ZOOM_OUT##` | Zoom out (reduce) |
| `##LEFT_IN##` | Entrada desde la izquierda |
| `##LEFT_OUT##` | Salida hacia la izquierda |
| `##RIGHT_IN##` | Entrada desde la derecha |
| `##RIGHT_OUT##` | Salida hacia la derecha |
| `##TOP_IN##` | Entrada desde arriba |
| `##BOTTOM_IN##` | Entrada desde abajo |

**Uso en frames animados**:

```xml
<frame name="frmnuevochat"
       animation-in-delay="250"
       animation-out-delay="250"
       animation-in="##RIGHT_IN##"
       animation-out="##LEFT_OUT##"
       disablevisible="MAP_VERFLOTANTE=0"
       floating="true" top="0" left="0"
       width="100%" height="100%">
```

**Uso en navegación entre grupos**:

```javascript
ui.showGroup(2, "##ALPHA_IN##", 500, "##ALPHA_OUT##", 500);
```

### 7.5 Macros de coleccion — Nodo XML `<macro>` + API `setMacro`/`getMacro`

Las macros de coleccion permiten **parametrizar el SQL de una `<coll>`** (en `sql`, `filter`, subconsultas, etc.) y cambiar su valor en tiempo de ejecución desde JavaScript. Son la herramienta principal para filtros dinámicos por interaccion del usuario (ej: cambiar el filtro de una lista cuando se selecciona un combo).

> **No confundir con `appData.setGlobalMacro` / `getGlobalMacro`**: las macros globales son variables de aplicación (equivalentes a `localStorage` en navegador) y se leen desde cualquier punto. Las macros de coll viven dentro de **una sola coleccion** y solo afectan al SQL de esa coll. Ver también la API JavaScript en el tópico 03.

#### Declaración en el XML — nodo `<macro>`

Para que una macro de coll funcione, **debe declararse explicitamente** dentro de la `<coll>`. El nodo `<macro>` se coloca **al mismo nivel que los nodos `<group>`** (es decir, hijo directo de `<coll>`, no anidado dentro de un `<group>` ni de un `<frame>`).

Sintaxis:

```xml
<macro name="##NOMBRE##" value="valor por defecto" default="true" />
```

| Atributo | Descripción |
|----------|-------------|
| `name`   | Nombre de la macro con dobles `##...##`. Libre (ej. `##TIPO##`, `##FILTRO##`, `##MACRO1##`). Es el token que se sustituira en el SQL. |
| `value`  | Valor por defecto. Puede ser un literal (`"1"`, `"abc"`) o un fragmento SQL completo (ej. `"1=1"`, `"FILTRO='A'"`, una subconsulta entera). XOne lo inyecta tal cual en la consulta. |
| `default`| `true` o `false`. Indica si la macro se aplica desde el inicio (con su `value` por defecto). **Convencion: poner siempre `default="true"`** salvo que tengas una razón explicita para lo contrario. |

#### Ejemplo completo (declaración + uso en SQL + cambio desde JS)

```xml
<?xml version="1.0" encoding="iso-8859-15"?>
<coll name="ListaControles"
      progid="ASData.CASBasicDataObj"
      sql="SELECT ID, TITULO, FILTRO FROM ##PREF##CONTROLES WHERE ##TIPO##"
      objname="Controles"
      loadall="true">

    <!-- Declaracion de macros: al mismo nivel que los <group>, NO dentro de ninguno -->
    <macro name="##TIPO##" value="1=1" default="true" />

    <group name="General" id="1">
        <prop name="TITULO"  type="T"  visible="7" />
        <prop name="FILTRO"  type="T"  visible="7" />
    </group>
</coll>
```

Y desde JavaScript, en un `onchange` de un combo de la pantalla padre:

```javascript
// CORRECTO: setMacro / getMacro
var coll = self.getContents("content1");
if (self.TIPO == "TODOS") {
    coll.setMacro("##TIPO##", "1=1");
} else {
    coll.setMacro("##TIPO##", "FILTRO='" + self.TIPO.toString() + "'");
}
ui.refresh();
```

> **API correcta:** `setMacro("##NOMBRE##", valor)` y `getMacro("##NOMBRE##")`. **NUNCA** `coll.macro(...)` — esa forma no existe en XOne.

#### Casos de uso típicos

- Filtrar una lista por un valor de combo/segmented control.
- Cambiar la query SELECT entera de un content en función del estado de la pantalla padre (`coll.setMacro("##TIPO##", "SELECT ID, TITULO, FILTRO FROM GEN_CONTROLES WHERE FILTRO='" + valor + "'")`).
- Habilitar/deshabilitar un fragmento del WHERE poniendo la macro a `"1=1"` (todo) o a una clausula concreta.

#### Diferencias con `##FLD_CAMPO##`

| | `<macro>` + `setMacro` | `##FLD_CAMPO##` |
|---|---|---|
| Donde se define | Nodo `<macro>` en la coll + JS imperativo | En el `filter`/SQL del content directamente |
| Quien la cambia | Código JS llamando a `setMacro` | XOne automáticamente al cambiar el campo padre |
| Caso típico | Filtro dinámico por interaccion del usuario | Maestro-detalle (sub-content filtrado por el padre) |

---

## 8. Patrones de Pantalla Comunes

### 8.1 Pantalla de Login

Basado en el proyecto UseCars y el patron del wiki:

```xml
<?xml version="1.0" encoding="utf-8"?>
<coll name="Login" title="Iniciar Sesion"
      special="true" notab="true" show-toolbar="false">

    <group name="grpPrincipal" id="1" class="groupNoTab">
        <frame name="frmLogin" width="100%" height="100%" bgcolor="#FFFFFF"
               align="center">

            <!-- Logo -->
            <prop name="imgLogo" type="IMG" visible="1"
                  path="logo.png" width="150p" height="150p"
                  align="center" tmargin="80p"
                  keep-aspect-ratio="true" />

            <!-- Usuario -->
            <prop name="MAP_USUARIO" type="T" visible="1"
                  floating-tooltip="true"
                  tooltip="Usuario"
                  width="80%" tmargin="60p"
                  expanded-hint-color="#1565C0" />

            <!-- Contraseña -->
            <prop name="MAP_PASSWORD" type="X" visible="1"
                  floating-tooltip="true"
                  tooltip="Contraseña"
                  width="80%" tmargin="30p"
                  show-password-visibility-toggle="true" />

            <!-- Mensaje de error (oculto por defecto) -->
            <frame name="frmError" width="80%"
                   disablevisible="MAP_ERROR=''"
                   tmargin="10p">
                <prop name="MAP_ERROR" type="L" visible="1"
                      forecolor="#F44336" fontsize="12" />
            </frame>

            <!-- Botón Entrar -->
            <prop name="btnEntrar" type="B" visible="1"
                  title="Entrar"
                  width="80%" height="56p" tmargin="40p"
                  bgcolor="#1565C0" forecolor="#FFFFFF"
                  border-corner-radius="28"
                  method="executenode(aceptar)" />
        </frame>
    </group>

    <prop name="MAP_ERROR" type="T" visible="0" />

    <aceptar>
        <action name="runscript">
            <script language="javascript">
                hacerLogin(self.MAP_USUARIO, self.MAP_PASSWORD);
            </script>
        </action>
    </aceptar>

    <onback>
        <action name="runscript">
            <script language="javascript">
                appData.exit();
            </script>
        </action>
    </onback>
</coll>
```

### 8.2 Menu Principal con tarjetas

```xml
<?xml version="1.0" encoding="utf-8"?>
<coll name="MenuPrincipal" special="true"
      notab="true" show-toolbar="false" bgcolor="#F5F5F5">

    <group name="grpPrincipal" id="1" class="groupNoTab">
        <!-- Header -->
        <frame name="frmHeader" width="100%" height="120p"
               bgcolor="#1565C0" align="center|center">
            <prop name="lblTitulo" type="L" visible="1"
                  title="Mi Aplicación"
                  forecolor="#FFFFFF" fontsize="20" fontbold="true" />
        </frame>

        <!-- Cuerpo con tarjetas -->
        <frame name="frmBody" width="100%" height="100%" scroll="true">
            <!-- Tarjeta 1 -->
            <frame name="frmCard1" width="90%" height="100p"
                   lmargin="5%" tmargin="20p"
                   bgcolor="#FFFFFF" border-corner-radius="8" elevation="3"
                   onclick="abrirOpcion('Pedidos');">
                <prop name="imgCard1" type="IMG" visible="1"
                      path="ic_pedidos.png"
                      width="48p" height="48p" lmargin="20p" tmargin="26p" />
                <prop name="lblCard1" type="L" visible="1"
                      title="Pedidos"
                      fontsize="16" fontbold="true"
                      lmargin="20p" tmargin="30p" newline="false" />
            </frame>

            <!-- Tarjeta 2 -->
            <frame name="frmCard2" width="90%" height="100p"
                   lmargin="5%" tmargin="15p"
                   bgcolor="#FFFFFF" border-corner-radius="8" elevation="3"
                   onclick="abrirOpcion('Clientes');">
                <prop name="imgCard2" type="IMG" visible="1"
                      path="ic_clientes.png"
                      width="48p" height="48p" lmargin="20p" tmargin="26p" />
                <prop name="lblCard2" type="L" visible="1"
                      title="Clientes"
                      fontsize="16" fontbold="true"
                      lmargin="20p" tmargin="30p" newline="false" />
            </frame>
        </frame>
    </group>

    <onback>
        <action name="runscript">
            <script language="javascript">
                appData.exit();
            </script>
        </action>
    </onback>
</coll>
```

### 8.3 Lista con filtros

Basado en el patron del wiki (EspecialContents.xne):

```xml
<?xml version="1.0" encoding="utf-8"?>
<coll name="ListaFiltrada"
      sql="SELECT * FROM ##PREF##Datos"
      objname="Datos" loadall="true"
      notab="true" show-toolbar="false">

    <group name="Lista" id="1">
        <!-- Barra de busqueda -->
        <prop name="MAP_FILTRO" type="T" visible="1"
              tooltip="Escriba para buscar..."
              labelwidth="0" width="70%"
              ontextchanged="javascript:filtrarLista(e);" />

        <prop name="BTN_BUSCAR" type="B" visible="1"
              img="lupa.png" labelwidth="0" width="75p"
              method="ExecuteNode(buscar)" newline="false" />

        <prop name="BTN_ORDENAR" type="B" visible="1"
              img="##FLD_MAP_BTORDEN##" labelwidth="0" width="75p"
              method="ExecuteNode(ordenar)" newline="false" />

        <!-- Lista con RecyclerView -->
        <frame name="frmLista" width="98%" height="80%"
               framebox="true" border-corner-radius="10" lmargin="1%">
            <prop name="@listaContent" type="Z" visible="1"
                  contents="listaContent"
                  height="96%"
                  viewmode="recyclerview"
                  bgcolor="#FFFFFF" />
            <contents name="listaContent" src="DatosLista" />
        </frame>
    </group>

    <prop name="MAP_BTORDEN" type="T" visible="0" />
    <prop name="MAP_ORDEN" type="T" visible="0" />

    <selecteditem>
        <action name="runscript">
            <script>
                ui.openEditView(self);
            </script>
        </action>
    </selecteditem>
</coll>
```

### 8.4 Formulario de detalle/edición

```xml
<?xml version="1.0" encoding="utf-8"?>
<coll name="DetalleCliente"
      sql="SELECT * FROM ##PREF##Clientes"
      objname="Clientes" updateobj="Clientes"
      notab="true" show-toolbar="false">

    <group name="Detalle" id="1">
        <!-- Header con botones -->
        <frame name="frmHeader" width="100%" height="60p" bgcolor="#1565C0">
            <prop name="BTN_VOLVER" type="B" visible="1"
                  img="ic_back.png" labelwidth="0"
                  width="48p" height="48p"
                  method="executenode(onback)" />
            <prop name="LBL_TITULO" type="L" visible="1"
                  title="Detalle Cliente"
                  forecolor="#FFFFFF" fontsize="18"
                  newline="false" lmargin="10p" />
        </frame>

        <!-- Formulario -->
        <frame name="frmFormulario" width="100%" height="100%"
               scroll="true" tmargin="10p">
            <prop name="NOMBRE" type="T" visible="1"
                  title="Nombre" width="90%" lmargin="5%"
                  floating-tooltip="true" tooltip="Nombre del cliente" />

            <prop name="EMAIL" type="T" visible="1"
                  title="Email" width="90%" lmargin="5%" tmargin="10p" />

            <prop name="TELEFONO" type="N" visible="1"
                  title="Teléfono" width="90%" lmargin="5%" tmargin="10p"
                  phone="true" />

            <prop name="DIRECCION" type="T" visible="1"
                  title="Dirección" width="90%" lmargin="5%" tmargin="10p"
                  lines="3" fixed-lines="true" />

            <prop name="ACTIVO" type="NC" visible="1"
                  title="Cliente activo" width="90%" lmargin="5%" tmargin="10p" />

            <!-- Botón guardar -->
            <prop name="BTN_GUARDAR" type="B" visible="1"
                  title="Guardar" width="90%" height="56p"
                  lmargin="5%" tmargin="30p"
                  bgcolor="#4CAF50" forecolor="#FFFFFF"
                  border-corner-radius="28"
                  method="executenode(guardar)" />
        </frame>
    </group>

    <guardar>
        <action name="runscript">
            <script language="javascript">
                self.save();
                ui.showToast("Cliente guardado correctamente");
                let window = ui.getView(self);
                if (window) window.exit();
            </script>
        </action>
    </guardar>

    <onback>
        <action name="runscript">
            <script language="javascript">
                let window = ui.getView(self);
                if (window) window.exit();
            </script>
        </action>
    </onback>
</coll>
```

### 8.5 Pantalla con pestanas (tabs)

Basada en el proyecto MiMensajeria:

```xml
<?xml version="1.0" encoding="utf-8"?>
<coll name="AppConTabs" special="true"
      group-theme="material" tab-mode="scrollable">

    <group name="Chats" id="1" align="center">
        <prop name="LISTA_CHATS" type="Z" visible="1"
              contents="@Chats"
              viewmode="recyclerview"
              width="100%" height="100%"
              show-no-data="true" />
        <contents name="@Chats" src="Conversaciones" />
    </group>

    <group name="Estados" id="2" align="center">
        <!-- Contenido de estados -->
    </group>

    <group name="Llamadas" id="3" align="center">
        <!-- Contenido de llamadas -->
    </group>

    <onback>
        <action name="runscript">
            <script language="javascript">
                appData.exit();
            </script>
        </action>
    </onback>
</coll>
```

### 8.6 Pantalla con mapa

Basada en EspecialMapa.xne del wiki:

```xml
<?xml version="1.0" encoding="utf-8"?>
<coll name="PantallaMapa" special="true" notab="true">

    <group name="Mapa" id="1">
        <frame name="frmMapa" width="100%" height="80%">
            <prop name="MAP_MAPA" type="Z" visible="1"
                  viewmode="mapview"
                  mapview-embedded="true"
                  contents="mapaDatos"
                  width="100%" height="100%"
                  show-user-location="true" />
            <contents name="mapaDatos" src="ContentMapaDatos" />
        </frame>

        <!-- Información del punto seleccionado -->
        <frame name="frmInfo" width="100%" height="20%"
               bgcolor="#FFFFFF" tmargin="0">
            <prop name="MAP_NOMBRE" type="T" visible="1"
                  title="Nombre" locked="true"
                  labelwidth="0" width="96%" lmargin="2%" />
            <prop name="MAP_DIRECCION" type="T" visible="1"
                  title="Dirección" locked="true"
                  labelwidth="0" width="96%" lmargin="2%" />
        </frame>
    </group>

    <before-edit refresh="true">
        <action name="runscript">
            <script language="javascript">
                ui.startGps();
            </script>
        </action>
    </before-edit>
</coll>
```

### 8.7 Chat

Basado en EspecialChat.xne del wiki:

```xml
<?xml version="1.0" encoding="utf-8"?>
<coll name="Chat" title="" special="true" notab="true">

    <!-- Header con info del contacto -->
    <group name="Header" id="10" fixed="true" orientation="top"
           width="100%" height="120p">
        <frame name="frmHeader" width="100%" height="120p" bgcolor="#1565C0">
            <prop name="BTN_VOLVER" type="B" visible="1"
                  img="icon_back.png" width="60p" height="120p"
                  method="ExecuteNode(onback)" />
            <prop name="MAP_TITULO" type="L" visible="1"
                  forecolor="#FFFFFF" fontbold="true"
                  newline="false" lmargin="10p" />
        </frame>
    </group>

    <!-- Mensajes -->
    <group name="Conversacion" id="1">
        <frame name="frmMensajes" width="100%" height="85%">
            <prop name="Mensajes" type="Z" visible="1"
                  contents="Mensajes"
                  viewmode="recyclerview"
                  bgcolor="#FFFFFF"
                  edit-inrow="true"
                  width="100%" height="100%" />
            <contents name="Mensajes" src="MensajesChat"
                      filter="IDCHAT=##FLD_MAP_CHATSEL##" />
        </frame>

        <!-- Barra de entrada -->
        <frame name="frmInput" width="100%" height="100p"
               bgcolor="#FFFFFF" align="center">
            <prop name="MAP_TEXTO" type="T" visible="1"
                  labelwidth="0" width="80%" height="80p"
                  tmargin="10p" lmargin="10p"
                  border-corner-radius="20"
                  text-border="true" />
            <prop name="BTN_ENVIAR" type="B" visible="1"
                  img="icon_send.png"
                  labelwidth="0" width="100p" height="100p"
                  newline="false"
                  method="executenode(enviar)" />
        </frame>
    </group>

    <prop name="MAP_CHATSEL" type="T" visible="0" />
</coll>
```

### 8.8 Dashboard con estadisticas

Basado en EspecialGraficos.xne del wiki:

```xml
<?xml version="1.0" encoding="utf-8"?>
<coll name="Dashboard" special="true"
      group-theme="material" tab-mode="scrollable"
      group-swipe="true">

    <group name="Ventas" id="1">
        <!-- Gráfico de barras -->
        <frame name="frmBarras" width="98%" height="510p"
               tmargin="14p" lmargin="1%"
               framebox="true" forecolor="#666666" border-width="2">
            <prop name="@GraficoVentas" type="Z"
                  classid="XOneCharts"
                  viewmode="barchart"
                  contents="DatosVentas"
                  width="96%" lmargin="2%" height="490p" tmargin="6p" />
            <contents name="DatosVentas" src="ContentGraficoVentas" />
        </frame>
        <prop name="lblVentas" type="L"
              title="Ventas por Mes"
              fontbold="true" lmargin="14p" height="50p" />
    </group>

    <group name="Categorias" id="2">
        <!-- Gráfico circular -->
        <frame name="frmPie" width="98%" height="510p"
               tmargin="14p" lmargin="1%"
               framebox="true" forecolor="#666666" border-width="2">
            <prop name="@GraficoCategorias" type="Z"
                  classid="XOneCharts"
                  viewmode="piechart"
                  contents="DatosCategorias"
                  width="96%" lmargin="2%" height="490p" tmargin="6p" />
            <contents name="DatosCategorias" src="ContentGraficoCategorias" />
        </frame>
    </group>

    <group name="Tendencia" id="3">
        <!-- Gráfico de lineas -->
        <frame name="frmLineas" width="98%" height="510p"
               tmargin="14p" lmargin="1%"
               framebox="true" forecolor="#666666" border-width="2">
            <prop name="@GraficoTendencia" type="Z"
                  classid="XOneCharts"
                  viewmode="linechart"
                  contents="DatosTendencia"
                  width="96%" lmargin="2%" height="490p" tmargin="6p" />
            <contents name="DatosTendencia" src="ContentGraficoTendencia"
                      sort="CATEGORIA,VALOR1,VALOR2" />
        </frame>
    </group>

    <onback>
        <action name="runscript">
            <script language="javascript">
                appData.exit();
            </script>
        </action>
    </onback>
</coll>
```

### 8.9 Patron Maestro-Detalle Completo

El patron maestro-detalle combina una coleccion principal (maestro) con un content embebido (detalle). La coleccion maestro muestra una lista de registros; al seleccionar uno, se muestra el formulario de edición con los detalles y sus lineas hijas.

```xml
<?xml version="1.0" encoding="utf-8"?>
<!-- MAESTRO: Lista de pedidos con lineas de detalle -->
<coll name="Pedidos"
      sql="SELECT p.*, c.NOMBRE AS MAP_CLIENTE
           FROM ##PREF##Pedidos p
           LEFT JOIN ##PREF##Clientes c ON p.IDCLIENTE=c.ID"
      objname="Pedidos" updateobj="Pedidos"
      loadall="true" notab="true" show-toolbar="false"
      autorefresh="true">

    <group name="Lista" id="1">
        <!-- Campos visibles en grid (visible="4") -->
        <prop name="NUMERO" type="T" visible="4" size="20" />
        <prop name="MAP_CLIENTE" type="T" visible="4" size="100" />
        <prop name="FECHA" type="D" visible="4" />
        <prop name="TOTAL" type="N2" visible="4" />

        <!-- Campos visibles en edicion (visible="1") -->
        <prop name="MAP_ETIQUETA" type="L" visible="1"
              title="Detalle del Pedido" fontbold="true" fontsize="16"
              tmargin="20p" lmargin="5%" />
        <prop name="NUMERO" type="T" visible="1" title="Número"
              width="90%" lmargin="5%" locked="true" />
        <prop name="MAP_CLIENTE" type="T" visible="1" title="Cliente"
              width="90%" lmargin="5%" locked="true" />

        <!-- DETALLE: Lineas del pedido embebidas -->
        <prop name="lblLineas" type="L" visible="1"
              title="Lineas del Pedido" fontbold="true"
              tmargin="20p" lmargin="5%" />
        <prop name="@LineasPedido" type="Z" visible="1"
              contents="LineasPedido"
              viewmode="recyclerview"
              width="90%" height="300p" lmargin="5%"
              edit-inrow="true"
              show-no-data="true" />
    </group>

    <!-- Vinculo content: filtra lineas por ID del pedido padre -->
    <contents name="LineasPedido" src="LineasPedido"
              filter="ID_PEDIDO=##FLD_ID##" />

    <!-- Al seleccionar un pedido, abrir la vista de edicion -->
    <selecteditem>
        <action name="runscript">
            <script language="javascript">
                ui.openEditView(self);
            </script>
        </action>
    </selecteditem>

    <create>
        <action name="setval" field="FECHA" value="##NOW##" />
        <action name="setval" field="IDUSUARIO" value="##USERID##" />
    </create>
</coll>
```

**Puntos clave del patron:**
- `visible="4"` para campos que solo se ven en el grid (lista).
- `visible="1"` para campos que solo se ven en edición (formulario).
- `filter="ID_PEDIDO=##FLD_ID##"` en el contents para vincular las lineas hijas al registro padre.
- `autorefresh="true"` en la coleccion para que se actualice al volver del detalle.

### 8.10 Edición en Linea (edit-inrow)

El atributo `edit-inrow="true"` permite editar los campos de una lista directamente dentro de cada fila, sin necesidad de abrir una pantalla de edición aparte. Es ideal para listas de lineas editables (como lineas de pedido o inventario).

```xml
<!-- En la coleccion padre: content con edicion en fila -->
<prop name="@content2" height="96%" type="Z"
      contents="content2"
      mask="0"
      edit-inrow="true"
      bgcolor="#FFFFFF" />
<contents name="content2" src="ContentDatosEditRow" autofocus="true" />
```

La coleccion hija (`ContentDatosEditRow`) debe definir dos layouts usando `visible`:
- `visible="4"` para los campos que se ven en modo **lista** (solo lectura).
- `visible="7"` para los campos que se ven en modo **edición en fila**.

```xml
<!-- ContentDatosEditRow.xne -->
<coll name="ContentDatosEditRow" title="Datos Editables"
      sql="SELECT * FROM ##PREF##datosdemo"
      objname="datosdemo" updateobj="datosdemo"
      loadall="true">
    <group name="General" id="1">
        <!-- Layout de grid (solo lectura) -->
        <prop name="IMAGEN" visible="4" type="IMG"
              width="60p" height="60p" lmargin="10p" tmargin="2p" />
        <frame name="frmDatos" newline="false" width="500p" height="100p">
            <prop name="TITULO" visible="4" type="T" size="255"
                  class="contentTitulo" lines="1" />
            <prop name="DESCRIPCION" visible="4" type="T" size="255"
                  class="contentDescripcion" lines="1" />
        </frame>

        <!-- Layout de edicion en fila -->
        <prop name="TITULO_EDIT" visible="7" type="T" size="255"
              title="Título" width="90%" />
        <prop name="DESCRIPCION_EDIT" visible="7" type="T" size="255"
              title="Descripción" width="90%" lines="3" />
    </group>
</coll>
```

### 8.11 Multi-selección en Listas

Patron para permitir que el usuario seleccione multiples elementos de una lista mediante checkboxes. La coleccion hija incluye un campo `MAP_SELECTED` de tipo `NC` (checkbox) para cada fila.

**Coleccion hija con checkbox de selección:**

```xml
<!-- ContentDatosFiltroMultiseleccion.xne -->
<coll name="ContentMultiseleccion" title="Datos"
      sql="SELECT * FROM ##PREF##datosdemo"
      objname="datosdemo" updateobj="datosdemo"
      loadall="true">
    <group name="General" id="1">
        <frame name="frmDatos" width="100%">
            <prop name="MAP_SELECTED" visible="4" type="NC"
                  width="60p" height="60p"
                  tmargin="10p" lmargin="10p" />
            <prop name="TITULO" visible="4" type="T"
                  newline="false" size="255"
                  class="contentTitulo" lines="1" />
        </frame>
    </group>
</coll>
```

**JavaScript para procesar los elementos seleccionados:**

```javascript
function procesarSeleccionados() {
    var coll = self.getContents("ContentMultiseleccion");
    var n = coll.getCount();
    var seleccionados = [];

    for (var i = 0; i < n; i++) {
        var obj = coll.getObject(i);
        if (obj.MAP_SELECTED == 1) {
            seleccionados.push(obj.TITULO);
        }
    }

    if (seleccionados.length > 0) {
        ui.msgBox(seleccionados.join("\n"), "Seleccionados", 0);
    } else {
        ui.showToast("No hay elementos seleccionados");
    }
}
```

**En la coleccion padre:**

```xml
<!-- Botón para procesar seleccionados -->
<prop name="BTN_PROCESAR" type="B" visible="1"
      title="Procesar seleccionados"
      onclick="procesarSeleccionados();"
      width="90%" height="56p" lmargin="5%" tmargin="10p"
      bgcolor="#1565C0" forecolor="#FFFFFF"
      border-corner-radius="28" />

<!-- Lista con multi-selección -->
<prop name="@ContentMultiseleccion" type="Z" visible="1"
      contents="ContentMultiseleccion"
      viewmode="recyclerview"
      width="100%" height="70%"
      show-no-data="true" />
<contents name="ContentMultiseleccion" src="ContentMultiseleccion" />
```

---

**Anterior:** [02b - Nodo prop y tipos](02b-xml-prop-tipos.md) · **Siguiente:** [02d - Layouts avanzados, herencia y best practices](02d-xml-layouts-herencia.md) · **Índice:** [02 - Guía XML/UI](02-xml-ui-complete-guide.md)
