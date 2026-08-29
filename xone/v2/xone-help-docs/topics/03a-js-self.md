# JavaScript API — Introduccion y objeto `self` / `selfDataColl`

Sub-archivo del [Tópico 03 - Guía Completa de JavaScript](03-javascript-api-guide.md). Cubre la introduccion al motor JS de XOne (objetos globales, ciclo de vida, ambitos, escape XML), el objeto `self` (DataObject) con todos sus métodos, y la coleccion `selfDataColl` / `DataCollection` (browse, lock, macros, busqueda indexada, bind).

## Tabla de Contenidos

- [1. Introduccion al JavaScript de XOne](#1-introduccion-al-javascript-de-xone)
- [2. Objeto Global `self` - El DataObject Actual](#2-objeto-global-self---el-dataobject-actual)

---

## 1. Introduccion al JavaScript de XOne

### 1.1 Motor JS Embebido

El JavaScript de XOne **NO se ejecuta en un navegador web ni en Node.js**. Se ejecuta dentro de un motor JavaScript nativo embebido en la aplicación móvil (Rhino/V8 según la plataforma). Esto implica limitaciones fundamentales que todo desarrollador debe conocer.

Los scripts se colocan dentro de nodos `<script>` en archivos `.xne`, vinculados a eventos del ciclo de vida de la pantalla:

```xml
<coll name="MiPantalla" title="Mi Pantalla" class="xnCollBase">

    <!-- Se ejecuta UNA sola vez al crear el objeto (primera apertura) -->
    <create>
        <action name="runscript">
            <script language="javascript">
                inicializar();
            </script>
        </action>
    </create>

    <!-- Al abrir el objeto para edicion — evento principal para inicializar la pantalla -->
    <before-edit>
        <action name="runscript">
            <script language="javascript">
                cargarDatos();
            </script>
        </action>
    </before-edit>

    <!-- Al pulsar el botón atrás -->
    <onback>
        <action name="runscript">
            <script language="javascript">
                manejarAtras();
            </script>
        </action>
    </onback>

</coll>
```

> **Crítico**: `<load>` NO se ejecuta al mostrar la pantalla — se dispara **por cada DataObject** al cargarse desde la BD: tanto al recorrer la coleccion (`startBrowse()`/`loadAll()`) como al hidratar items de un `<contents>` o cargas individuales. **NO se recomienda usarlo** porque el rendimiento puede verse seriamente afectado (se ejecuta una vez por item cargado). Para inicializar una pantalla usar `<before-edit>` (al abrir para editar) o `<create>` (primera apertura).

> **Referencia cruzada:** Para la estructura completa de eventos en nodos XML, consultar el tópico [02 - Estructura XML](02-xml-ui-complete-guide.md). Para los estilos CSS aplicables a controles manipulados desde JS, ver el tópico [04 - Estilos CSS](04-css-styling-guide.md).

### 1.2 Objetos Globales Disponibles

XOne expone los siguientes objetos globales accesibles desde cualquier script:

| Objeto | Descripción |
|--------|-------------|
| `ui` | Interfaz de usuario: dialogos, toasts, navegación, GPS, camara |
| `appData` | Datos de la aplicación: colecciones, autenticación, macros, rutas |
| `self` | Objeto de datos actual (DataObject) en el contexto del script |
| `crypto` | Funciones criptograficas: hashing, cifrado AES, firma digital, encoding |
| `$http` | Cliente HTTP asíncrono: GET, POST, PUT, DELETE, PATCH, download |
| `console` | Logging WHATWG completo: `console.{log,info,debug,warn,error,trace,assert,group,groupCollapsed,groupEnd,time,timeLog,timeEnd,count,countReset,dir,dirxml,clear,table}` con formato `%s/%d/%j/...` |
| `biometricsManager` | Autenticación biometrica (huella, face) y firma biometrica |
| `fingerprintManager` | Huella dactilar (API legacy, preferir `biometricsManager`) |
| `bluetoothSerial` | Comunicación por puerto serie Bluetooth |
| `replica` | Control de sincronización/replica con servidor |
| `systemSettings` | Singleton global: brillo, permisos, memoria, MDM, batería, rutas, Intune |
| `deviceInfo` | Singleton global: batería, red móvil, trafico de bytes |

### 1.3 Como se Ejecuta el JS: Eventos XML a Acciones a Script

El flujo de ejecución en XOne sigue este patron:

```
1. Usuario interactua con la UI (pulsa boton, cambia campo, etc.)
         |
2. El framework detecta el evento asociado al nodo XML
         |
3. Se ejecuta el bloque <script> vinculado al evento
         |
4. El script accede a objetos globales (self, ui, appData)
         |
5. Las acciones del script modifican datos y/o la interfaz
```

**Eventos disponibles en nodos XML:**

| Evento | Momento de Ejecución | Ubicación |
|--------|---------------------|-----------|
| `<create>` | Una sola vez al crear el objeto (primera apertura) | Dentro de `<coll>` |
| `<before-edit>` | Al abrir un objeto para edición — **el más usado para inicializar la pantalla** | Dentro de `<coll>` |
| `<after-edit>` | Después de entrar en modo edición, con la UI ya montada | Dentro de `<coll>` |
| `<load>` | Se dispara **por cada DataObject** al cargarse desde la BD (startBrowse/loadAll/`<contents>`/cargas individuales). **NO es evento de pantalla** y **NO recomendado** por impacto en rendimiento | Dentro de `<coll>` |
| `<onchange>` | Cuando cambia el valor de una propiedad | Dentro de `<coll>`, nodo `<field>` |
| `<selecteditem>` | Cuando se selecciona un item en una lista | Dentro de `<coll>` |
| `<onlongpressitem>` | Pulsacion larga en un item de lista | Dentro de `<coll>` |
| `<onback>` | Cuando el usuario pulsa el botón atrás | Dentro de `<coll>` |
| `<miNodo>` | Nodo custom invocado con `ExecuteNode(miNodo())` o `method="executenode(miNodo)"` | Dentro de `<coll>` |

### 1.4 Diferencias con JS Web

**APIs que NO están disponibles en XOne:**

| API Web | Alternativa XOne |
|---------|------------------|
| `document`, `window` (DOM) | `ui.getView(self)` para acceder a controles |
| `localStorage` / `sessionStorage` | `appData.getGlobalMacro()` / `appData.setGlobalMacro()` |
| `XMLHttpRequest` | `$http.get()`, `$http.post()`, etc. (también existe `fetch` custom). |
| `navigator.geolocation` | `ui.startGps()` / `ui.checkGpsStatus()` |
| `alert()` / `confirm()` / `prompt()` | `ui.msgBox()` / `ui.showToast()` |
| `require()` / `import` | No hay sistema de módulos; todo va en `functions.js` |
| `async` / `await` | Callbacks o `Promise` (sí soportado vía implementación custom). |

**Sintaxis ES6+ NO soportada:**

| Sintaxis | Estado | Alternativa |
|----------|--------|-------------|
| Template literals `` `${var}` `` | Parse error (*illegal character*) sobre el backtick | Concatenación con `+` |
| `async` / `await` | Parse error (reservadas) | Callbacks o `Promise` |
| Spread/rest `...args`, default params `function f(x=1)` | Parse error | `arguments` / chequeo `=== undefined` |
| Computed keys en object literals `{[k]: v}` | Parse error (sí en class body) | `var o = {}; o[k] = v;` |
| Optional chaining `?.` / nullish coalescing `??` | Parse error | Chequeos manuales |
| Private fields `#name` en class | Parse error (requiere runtime) | Convención `_name` |
| Static blocks `static { ... }` en class | Parse error | Sentencias `ClassName.x = ...;` tras la clase |

**SÍ funciona:** `let`, `const`, arrow functions `() => {}`, destructuring (`var {a, b} = o`), `for...of` sobre arrays/strings, generadores con `yield` (runtime SpiderMonkey legacy — usar `try { while (true) v = iter.next(); } catch (e) {}`), Symbol, typed arrays, **`class` ES6+ con `extends`/`super`/`static`/getters/setters/computed keys/field declarations/generator methods (`*method()`)**, **`Promise` ES2024 completo** (`.then`/`.catch`/`.finally`/`Promise.all`/`allSettled`/`race`/`any`/`withResolvers`), `fetch`, `setTimeout`/`setInterval`, `URL`, `AbortController`, `TextEncoder`/`TextDecoder`, `console.{log,info,warn,error,debug,trace,...}`, `performance.now()`, métodos modernos de `String` (`padStart`, `replaceAll`, `at`, `matchAll`...) y de `Array` (`map`, `filter`, `reduce`, `find`...), `JSON`. Detalle completo en [01-xone-fundamentals.md §6.7](01-xone-fundamentals.md).

### 1.5 Archivos JavaScript en el Proyecto

```
MiProyecto/
  functions.js          <- Funciones globales (siempre presente, carga automatica)
  scripts/              <- Scripts adicionales organizados (opcional)
    ubicacion.js
    viajes.js
    mensajeria.js
```

El archivo `functions.js` es el punto de entrada global. Se carga automáticamente al iniciar la aplicación y sus funciones están disponibles en todos los scripts `.xne` del proyecto. Para proyectos grandes, se recomienda organizar la lógica en archivos adicionales dentro de `scripts/` y cargarlos con `appData.loadIncludeFile()`.

### 1.6 Alcance de Variables

```javascript
// Variables globales: accesibles desde cualquier script del proyecto
// Se definen en functions.js
var MI_CONSTANTE = "valor";
var ESTADOS = { ACTIVO: 1, INACTIVO: 0 };

// Variables locales: solo dentro de la funcion
function miFuncion() {
    let variableLocal = "solo existe aquí";
}

// IMPORTANTE: 'self' puede cambiar de contexto en callbacks asincronos
// Guardar referencia ANTES de cualquier operación asincrona
function operacionAsincrona() {
    let contexto = self;  // Guardar referencia
    $http.get(url, request,
        function(sData) {
            // Aquí 'self' puede NO ser el mismo objeto
            // Usar 'contexto' en su lugar
            contexto.MAP_RESULTADO = sData;
        },
        function(nError, sDesc) {
            ui.showToast("Error: " + sDesc);
        }
    );
}
```

### 1.7 Ambitos de ejecución y persistencia de variables

Entender en que **ambito** se ejecuta cada script es fundamental para usar correctamente `This` / `self`, `ThisDataColl` y las variables globales.

**Ambitos posibles:**

| Ambito | Cuando | `This` / `self` | `ThisDataColl` |
| --- | --- | --- | --- |
| **Objeto** | Acción disparada desde un objeto (p.ej. `<create>`, `<onchange>` de un prop) | El objeto en cuestion | `Nothing` / `null` |
| **Coleccion** | Acción en nodo `<coll-action>` (p.ej. `<onlogon>`) | `Nothing` / `null` | La coleccion que dispara el script |
| **Local** | Dentro de una `function()` | — | — |

**Reglas de visibilidad:**

- `appData` es siempre visible desde cualquier ambito.
- `self` / `This` y `ThisDataColl` son visibles durante la ejecución del script y de todas las funciones que se llamen desde el. **No** son visibles dentro de acciones anidadas (p.ej. un `Save` que dispara otro script tiene su propio ambito).
- `user` es visible cuando hay usuario logueado.
- Una variable declarada en el bloque principal del script es visible para todas las funciones llamadas desde ese mismo script, pero **no** para acciones anidadas.

**Intercambio de datos entre scripts anidados:** como las variables locales no sobreviven al anidamiento, hay que usar mecanismos persistentes:

- Propiedades del objeto (`self.MAP_FLAG = 1`)
- Variables de la coleccion (`coll.setVariable(...)`)
- Colecciones globales (`appData.getCollection("...")`)
- Macros globales (`appData.setGlobalMacro("##KEY##", valor)` / `appData.getGlobalMacro("##KEY##")`)
- Objeto `user` (persiste durante la sesión)

### 1.8 Buenas prácticas al programar en XOne

Patrones que evitan bugs sutiles y problemas de rendimiento:

**1. No uses `LoadAll()` sin motivo.** Cargar todos los objetos en memoria es caro. Si solo necesitas recorrer una coleccion, usa `startBrowse()` / `endBrowse()`. Para contar, `startBrowse(true)`.

**2. No filtres colecciones globales sin restaurar.** Si haces `coll.setFilter(...)` sobre una coleccion global y no la restauras, afectara a todas las vistas que usen esa coleccion.

```javascript
// MAL: filtra la coleccion global y afecta la UI
let coll = appData.getCollection("Clientes");
coll.setFilter("CODIGO=1");
coll.startBrowse();
// ... al salir, la lista de clientes solo muestra el cliente 1

// BIEN: trabajar sobre una copia
let coll = appData.getCollection("Clientes").createClone();
coll.setFilter("CODIGO=1");
// ... usar coll ...
coll = null;  // liberar
```

**3. Anula las referencias en orden inverso.** Si creas una coleccion y sacas objetos de ella, anula primero los objetos y luego la coleccion. Nunca al reves (la coleccion puede destruir los objetos antes).

**4. Guarda una marca para evitar reentradas.** Si un `Save` puede dispararse desde dentro de un `<onchange>` que a su vez puede llamarse otra vez al modificar el mismo campo, usa una propiedad centinela:

```xml
<onchange field="MAP_IMPORTE">
    <action name="runscript">
        <script language="javascript">
            if (self.MAP_SAVING == 0) {
                self.MAP_SAVING = 1;
                // ... calcular cosas ...
                self.save();        // dispara este mismo evento
                self.MAP_SAVING = 0;
            }
        </script>
    </action>
</onchange>
```

**5. No modifiques `CurrentItem` con cursores abiertos.** Algunas bases de datos no permiten modificar una tabla con cursores activos. Si tienes que modificar muchos objetos, mejor hazlo con `executeSql` o carga los IDs, cierra el cursor, y modifica uno a uno.

**6. En callbacks asíncronos, captura `self` antes.** Ver sección 1.6.

---

### 1.9 JavaScript dentro de XNE: escape XML o CDATA

Cuando el JavaScript va embebido dentro de un fichero `.xne` (en `<script language="javascript">` o en atributos como `onclick`, `disablevisible`, `value`, etc.), el bloque JS forma parte del XML y **debe respetar las reglas de XML**.

**Regla preferida — JS no trivial debe vivir fuera del `.xne`:** declarar una función en `functions.js` (o un fichero `.js` incluido) y llamarla desde el XML con `miFuncion();`. Así el JS se escribe normal (sin entidades, sin CDATA) y el XML solo invoca. Es lo más mantenible, lo más legible y evita por completo el problema del escape.

Cuando aun así necesitas escribir JS inline (snippets cortos), hay dos formas válidas de evitar que los caracteres especiales rompan el parseo XML:

1. **Entidades XML** dentro del JavaScript — funciona en cualquier sitio (nodo y atributo).
2. **`<![CDATA[...]]>` envolviendo el bloque** — funciona solo dentro de nodos `<script>`. NO es válido dentro de atributos XML (`onclick="..."`, `disablevisible="..."`).

Las dos son equivalentes en cuanto al resultado: el motor JS recibe el mismo código.

**Tabla de entidades:**

| Carácter JS | Entidad XML | Cuando aparece |
|-------------|-------------|----------------|
| `&`         | `&amp;`     | Operador `&&` se escribe `&amp;&amp;` |
| `<`         | `&lt;`      | Comparación `<` se escribe `&lt;` |
| `>`         | `&gt;`      | Comparación `>` se escribe `&gt;` |
| `"`         | `&quot;`    | Solo si el JS está dentro de un atributo XML con delimitador `"` |
| `'`         | `&apos;`    | Solo si el JS está dentro de un atributo XML con delimitador `'` |

**Ejemplo comparativo — el mismo JS escrito de las dos formas:**

(fence sin lenguaje para que las entidades se rendericen literales y se vean como tendrías que teclearlas en el `.xne`)

```
<!-- OPCIÓN A: entidades XML dentro del JS (válido en nodo o atributo) -->
<before-edit>
    <action name="runscript">
        <script language="javascript">
            if (a &gt; 0 &amp;&amp; b &lt; 10) {
                self.MAP_RES = a + b;
            }
        </script>
    </action>
</before-edit>

<!-- OPCIÓN B: envolver en CDATA (solo válido en nodo <script>) -->
<before-edit>
    <action name="runscript">
        <script language="javascript"><![CDATA[
            if (a > 0 && b < 10) {
                self.MAP_RES = a + b;
            }
        ]]></script>
    </action>
</before-edit>
```

**JS dentro de un atributo XML** (CDATA no aplica — solo entidades):

```
<!-- Atributo onclick (delimitador "): comillas internas con &quot; o usa '.
     onclick es un script JS inline en modo estricto: cada sentencia debe acabar en ';'. -->
<prop name="MAP_BTN" type="B" title="Buscar"
      onclick="if (self.MAP_TEXTO &amp;&amp; self.MAP_TEXTO.length &gt; 0) { hacerBusqueda(self.MAP_TEXTO); };" />

<!-- disablevisible con comparaciones también usa entidades -->
<prop name="MAP_AVISO" type="L"
      disablevisible="MAP_TOTAL &gt;= 100 &amp;&amp; MAP_ACTIVO=1" />
```

**Regla de oro:**

| Donde vive el JS | Cómo se escribe |
|-------------------|-----------------|
| Fichero `.js` separado (`functions.js`, `scripts/*.js`) — **forma preferida para JS no trivial** | JavaScript puro, sin entidades, sin CDATA. |
| Atributo XML (`onclick=`/`disablevisible=`/…) | Con entidades XML (`&amp;`, `&lt;`, `&gt;`, etc.). CDATA no es válido dentro de atributos. |
| Nodo `<script>` dentro de un `.xne` (snippets cortos) | Entidades XML o `<![CDATA[…]]>`. Ambas formas funcionan. |

---

## 2. Objeto Global `self` - El DataObject Actual

El objeto `self` representa la instancia actual del DataObject (registro/fila) en el contexto de ejecución del script. Es el puente entre la interfaz XML y la lógica JavaScript.

### 2.1 Acceso a Campos

Existen tres formas equivalentes de acceder a los campos del objeto actual:

```javascript
// Forma 1: Notacion de punto (mas comun y recomendada)
let nombre = self.MAP_NOMBRE;
self.MAP_NOMBRE = "Nuevo valor";

// Forma 2: Notacion de corchetes (util para nombres dinamicos)
let campo = "MAP_NOMBRE";
let nombre = self[campo];
self[campo] = "Nuevo valor";

// Forma 3: Metodos getValue/setValue (mas explicito)
let nombre = self.getValue("MAP_NOMBRE");
self.setValue("MAP_NOMBRE", "Nuevo valor");

// Asignar diferentes tipos de datos
self.MAP_TEXTO = "Texto";           // String (tipo T)
self.MAP_NUMERO = 42;               // Numerico (tipo N)
self.MAP_FECHA = new Date();         // Fecha (tipo D)
self.MAP_ACTIVO = 1;                 // Booleano (tipo B, 0 o 1)
self.MAP_FOTO = "ruta/imagen.jpg";   // Imagen (tipo IMG/PH)
```

### 2.2 getOldValue() - Valor Anterior

Permite obtener el valor que tenía un campo antes de la última modificación. Muy útil en eventos `<onchange>`:

```javascript
// Dentro de un <onchange> de la propiedad MAP_PRECIO
function onPrecioChanged() {
    let precioAnterior = self.getOldValue("MAP_PRECIO");
    let precioNuevo = self.MAP_PRECIO;

    if (precioNuevo > precioAnterior * 2) {
        ui.showToast("Advertencia: el precio se ha duplicado");
    }

    // Registrar el cambio
    console.log("Precio cambio de " + precioAnterior + " a " + precioNuevo);
}
```

### 2.3 getOwnerCollection() - Coleccion Propietaria

Permite obtener la coleccion a la que pertenece el objeto:

```javascript
// Obtener la coleccion propietaria
let coll = self.getOwnerCollection();
let nombreColl = coll.getName();
console.log("Este objeto pertenece a: " + nombreColl);

// Obtener la aplicación propietaria
let app = self.getOwnerApp();

// Verificar si el objeto es nuevo o existente
if (self.isNew()) {
    console.log("Es un registro nuevo, sin guardar en BD");
}

// Verificar si hay cambios sin guardar
if (self.getDirty()) {
    console.log("Hay cambios pendientes de guardar");
}

// Obtener indice del objeto en la coleccion
let indice = self.getObjectIndex();
```

### 2.4 getContents("nombre") - Acceso a Contents

Los contents son colecciones hijas (relación maestro-detalle) embebidas en un objeto:

```javascript
// Obtener un content
let lineas = self.getContents("@LineasPedido");

// Cargar datos del content
lineas.unlock();
lineas.clear();
lineas.loadAll();
lineas.lock();

// Contar items
let total = lineas.getCount();
console.log("Hay " + total + " lineas");

// Iterar los items
for (let i = 0; i < lineas.getCount(); i++) {
    let linea = lineas.get(i);
    console.log("Línea " + i + ": " + linea.MAP_DESCRIPCION);
}

// Agregar un item al content
lineas.unlock();
let nuevaLinea = lineas.createObject();
nuevaLinea.MAP_DESCRIPCION = "Producto nuevo";
nuevaLinea.MAP_CANTIDAD = 1;
nuevaLinea.MAP_PRECIO = 25.50;
lineas.addItem(nuevaLinea);
lineas.lock();
lineas.saveAll();

// Obtener todos los nombres de contents disponibles
let nombresContents = self.getAllContentNames();
```

### 2.5 setFieldPropertyValue() - Cambiar Atributos en Runtime

Permite modificar atributos visuales de las propiedades (controles) en tiempo de ejecución.

> ⚠️ **Método de último recurso.** Antes de usar `setFieldPropertyValue` valora siempre alternativas más limpias: cambiar la clase CSS con `getControl(...).setClass(...)`/`addClass(...)`, usar métodos específicos del control (p. ej. `control.setFlashMode(...)`), o expresar el comportamiento directamente en el XML/CSS. Sobrescribir atributos por cache rompe la trazabilidad respecto al XML original y obliga a recordar el `ui.refresh()` manual; úsalo solo cuando no exista una vía declarativa o un método de control equivalente.

**Firma:**

```javascript
self.setFieldPropertyValue(fieldName, attrName, value);  // 3 strings, devuelve null
self.getFieldPropertyValue(fieldName, attrName);         // 2 strings, devuelve string
```

- `fieldName`: nombre del prop (p. ej. `"MAP_TITULO"`). Obligatorio, string.
- `attrName`: atributo visual (`"width"`, `"img"`, `"visible"`, `"bgcolor"`, …). Obligatorio, string. Acepta alias CSS3 (p. ej. `"background-color"` se canonicaliza a `"bgcolor"`, así que escribir con uno y leer con el otro alias devuelven el mismo valor cacheado).
- `value`: valor como string. Pasar `null` borra el override y restaura el valor original del XML/CSS.

Lanza excepción si falta un parámetro o si alguno no es string.

**El cambio NO repinta solo — hay que llamar a `ui.refresh()`:**

`setFieldPropertyValue` actualiza la caché de atributos del objeto, pero el control en pantalla no se redibuja hasta llamar a `ui.refresh(prop)` (con el nombre del prop afectado) o `ui.refresh()` (refresca todo).

```javascript
// Cambiar la imagen de un botón
self.setFieldPropertyValue("MAP_BOTON", "img", "nuevo_icono.png");
ui.refresh("MAP_BOTON");  // <-- imprescindible para ver el cambio

// Cambiar el ancho de un campo
self.setFieldPropertyValue("MAP_TITULO", "width", "200p");
ui.refresh("MAP_TITULO");

// Leer un atributo actual
let ancho = self.getFieldPropertyValue("MAP_TITULO", "width");

// Cambiar visibilidad de un campo (ver topico 01 para valores bitmask)
self.setFieldPropertyValue("MAP_CAMPO_OCULTO", "visible", "7");
ui.refresh("MAP_CAMPO_OCULTO");

// Restaurar el valor original del XML/CSS (borrar el override)
self.setFieldPropertyValue("MAP_TITULO", "width", null);
ui.refresh("MAP_TITULO");

// Ejemplo real del wiki: togglear icono de flash de camara
function doToggleFlashMode() {
    let control = getControl("MAP_CAMERA");
    if (!control) return;

    let sFlashMode = control.getFlashMode();
    if (sFlashMode == "on") {
        control.setFlashMode("off");
        self.setFieldPropertyValue("MAP_TOGGLE_FLASH_MODE", "img", "flash-off.png");
    } else if (sFlashMode == "off") {
        control.setFlashMode("auto");
        self.setFieldPropertyValue("MAP_TOGGLE_FLASH_MODE", "img", "flash-auto.png");
    } else if (sFlashMode == "auto") {
        control.setFlashMode("torch");
        self.setFieldPropertyValue("MAP_TOGGLE_FLASH_MODE", "img", "flash-torch.png");
    } else if (sFlashMode == "torch") {
        control.setFlashMode("on");
        self.setFieldPropertyValue("MAP_TOGGLE_FLASH_MODE", "img", "flash-on.png");
    }
    ui.refresh("MAP_TOGGLE_FLASH_MODE");
}
```

### 2.6 executeNode("nodo") - Ejecutar Eventos Custom

Permite ejecutar nodos `<script>` con nombre definido en el XML:

```javascript
// En el XML:
// <script nodeName="applyfilter">
//     <script language="javascript">aplicarFiltro();</script>
// </script>

// Desde JavaScript:
self.executeNode("applyfilter");

// Ejemplo real del wiki: filtrar por texto
function FiltraMarcados(e) {
    self.MAP_BUSCAR_TEXT = e.newText;
    self.executeNode("applyfilter");
}
```

### 2.7 save() - Guardar Cambios

```javascript
// Guardar el objeto actual en la base de datos
self.save();

// Patron seguro con verificación de error
function guardarSeguro() {
    try {
        self.save();
        ui.showToast("Guardado correctamente");
    } catch(ex) {
        ui.showToast("Error al guardar: " + ex);
    }
}

// Verificar errores después de guardar
self.save();
let error = appData.error();
if (error.getNumber() != 0) {
    ui.showToast("Error: " + error.getDescription());
    error.clear();
}
```

### 2.8 Conversion a/desde JSON

```javascript
// Convertir el objeto actual a JSON
let jsonObj = self.toJson();          // Retorna objeto JS nativo
let jsonStr = self.toJsonString();    // Retorna string JSON

// Cargar datos desde JSON
self.loadFromJson('{"MAP_NOMBRE": "Test", "MAP_ACTIVO": 1}');

// Clonar un objeto
let copia = self.clone();
```

### 2.9 Métodos Adicionales del DataObject

```javascript
// === getParent() - Obtener el objeto padre (relacion maestro-detalle) ===
var padre = self.getParent();
if (padre) {
    console.log("Padre: " + padre.MAP_NOMBRE);
}

// === refresh() / refresh(sqlSentence) - Recargar los valores desde BD ===
// Vuelve a leer el registro de la base de datos (descarta cambios en memoria no guardados).
// NO refresca la UI — para eso usa ui.refresh(prop).
// Con argumento, ejecuta esa sentencia SQL en lugar de la del mapping.
self.refresh();
self.refresh("SELECT * FROM PRODUCTOS WHERE ID=" + self.MAP_ID);

// === setVariable(name, value) / getVariable(name) ===
// Variables de scope del objeto (en memoria, no se persisten en BD).
// Útil para pasar datos entre scripts del mismo objeto sin tocar la base.
self.setVariable("estadoCalculo", "ok");
var estado = self.getVariable("estadoCalculo");

// === isPropertyDirty(name) / getDirtyProperties() ===
// Para saber qué campos han cambiado desde la última carga/guardado.
if (self.isPropertyDirty("MAP_PRECIO")) {
    console.log("El precio ha cambiado");
}
var camposCambiados = self.getDirtyProperties();   // Array de nombres

// === Contents: metadatos ===
var nContents = self.getContentsCount();
var sql = self.getContentAttr("@LineasPedido", "sql");   // atributo XML del content

// === getOldItem(name) ===
// Como getOldValue, pero sin conversion de tipos Date/Calendar (devuelve el valor crudo).
var valorAntes = self.getOldItem("MAP_FECHA");

// === setNodePropertyValue / getNodePropertyValue ===
// Cambia en runtime un atributo de un nodo del layout, localizándolo por su TAG
// (frame, group, prop...) y el valor de su atributo "name". Para FRAMES es la vía
// correcta: setFieldPropertyValue solo actúa sobre props/campos, NO sobre frames.
// ⚠️ Método de último recurso: mismo criterio que setFieldPropertyValue (sección 2.5)
//    — antes valora cambiar la clase CSS, usar métodos del control, o dejarlo resuelto
//    en el XML/CSS desde el inicio. Sobrescribir atributos por caché obliga a refrescar
//    a mano y rompe la trazabilidad respecto al XML original.
// El cambio se aplica al renderizar; si la vista ya está creada, refrescar después
// (window.refresh / ui.refresh).
// Firma: (tagDelNodo, valorDelAtributoName, nombreAtributo, valor)
self.setNodePropertyValue("frame", "frmCabecera", "bgcolor", "#7C3AED");  // <frame name="frmCabecera">
var v = self.getNodePropertyValue("frame", "frmCabecera", "bgcolor");

// === bind(controlName, eventName, callback) / unbind(controlName, eventName) ===
// Vincula un callback a un evento de un control concreto del objeto.
self.bind("MAP_BOTON", "onclick", function(e) {
    ui.showToast("Pulsado");
});
self.unbind("MAP_BOTON", "onclick");

// === Metadatos de campos ===
var titulo = self.getPropertyTitle("MAP_NOMBRE");   // título visible del campo
var grupo  = self.getPropertyGroup("MAP_NOMBRE");   // grupo al que pertenece
var conValor = self.getPropertyNames();             // nombres de los campos que tienen valor cargado
                                                    // (no incluye los declarados sin valor)

// === clearCaches() - Vacía la caché de atributos resueltos ===
// Util si has cambiado atributos en el XML/CSS y quieres forzar re-evaluación
// la próxima vez que se lean.
self.clearCaches();
```

### 2.10 selfDataColl - Referencia Directa a la Coleccion

`selfDataColl` proporciona acceso directo a la coleccion contenedora del objeto `self`, sin necesidad de llamar a `getOwnerCollection()`:

```javascript
selfDataColl.loadAll();
var count = selfDataColl.count();
console.log("Total registros: " + count);
```

### 2.11 DataCollection - Métodos Adicionales

#### startBrowse() / endBrowse() - Navegación Browse

Inicia y finaliza una sesión de navegación por la coleccion. **Siempre** usar `endBrowse()` en un bloque `finally`:

```javascript
var coll = appData.getCollection("Datos");
coll.startBrowse();
try {
    coll.moveFirst();
    while (coll.getCurrentItem() != null) {
        var obj = coll.getCurrentItem();
        // procesar obj...
        coll.moveNext();
    }
} finally {
    coll.endBrowse();  // SIEMPRE en finally
}
```

#### deleteItem(index) - Eliminar Item por Índice

```javascript
var coll = appData.getCollection("Productos");
coll.deleteItem(2);  // Elimina el tercer elemento
```

#### findAllObjects(filter) - Buscar Todos los Objetos

Busca todos los objetos que cumplen un filtro. Retorna un array de DataObject:

```javascript
var encontrados = coll.findAllObjects("TIPO = 'A' AND ACTIVO = 1");
for (var i = 0; i < encontrados.length; i++) {
    console.log(encontrados[i].MAP_NOMBRE);
}
```

#### setMacro(name, value) / getMacro(name) - Macros de Coleccion

Las macros de coleccion permiten parametrizar filtros y consultas SQL definidos en el XML de la `<coll>`. Son distintas de las macros globales (`appData.setGlobalMacro`/`getGlobalMacro`): estas viven dentro de **una sola coleccion** y solo afectan a su SQL; las globales son variables de aplicación accesibles desde cualquier punto del código (equivalentes a `localStorage` del navegador).

> **API correcta:** `setMacro("##NOMBRE##", valor)` y `getMacro("##NOMBRE##")`. **NUNCA** `coll.macro(...)` — esa forma no existe en XOne y produce error.

> **Requisito XML:** Para que `setMacro` tenga efecto, la macro debe estar declarada en el XML de la coll con un nodo `<macro name="##NOMBRE##" value="..." default="true" />` **al mismo nivel que los `<group>`** (hijo directo de `<coll>`, no anidado). Si la macro no existe en el XML, `setMacro` no inyecta nada en el SQL. Ver el tópico 02, sección 7.5 para el detalle completo.

```javascript
// === Sobre un content de la pantalla actual ===
var contentGastos = self.getContents("Gastos");
contentGastos.setMacro("##TIPO##", "tg.NOMBRE LIKE '%" + self.MAP_FTTIPOGASTO + "%'");

// === Sobre una coleccion global ===
var coll = appData.getCollection("Ordenes");
coll.setMacro("##MACRO1##", "IDORDEN=" + numOrden);

// === Lectura ===
var filtroActual = contentGastos.getMacro("##TIPO##");
```

El **valor** que pasas a `setMacro` se inyecta tal cual en el SQL — puede ser un literal (`"1"`), un fragmento de WHERE (`"FILTRO='A'"`), o incluso una query SELECT entera si el atributo donde aparece la macro lo permite. Para "desactivar" un filtro sin reescribir la coll, el patron habitual es `coll.setMacro("##TIPO##", "1=1")`.

**Tip:** Después de un `setMacro`, suele hacer falta `ui.refresh()` (o `ui.refresh("nombreContent")`) para que el content recargue su SQL con el nuevo valor de la macro.

#### createSearchIndex(fields) / doSearch(query) - Busqueda Indexada

Permite busqueda rápida en memoria sobre campos indexados:

```javascript
// Crear indice sobre los campos deseados
coll.createSearchIndex(["NOMBRE", "DESCRIPCION"]);

// Buscar en el indice (tipicamente desde un evento onTextChanged)
function onBusquedaTexto(evento) {
    coll.doSearch(evento.newText);
}
```

#### lock() / unlock() - Bloqueo de Coleccion

Activa/desactiva el **modo solo lectura** de la coleccion:

- `lock()` activa la bandera de solo lectura. Con la bandera activa, `clear()`, `loadAll()` y similares son **no-ops silenciosos**: devuelven `true` sin hacer nada.
- `unlock()` desbloquea para poder modificar (vaciar, cargar, añadir items, etc.).
- `lock()`/`unlock()` son métodos de la **coleccion**; NO existen en `self` (DataObject).

Las colecciones **nacen desbloqueadas**, pero el convenio del proyecto es operar en bloque `unlock(); try {...} finally { lock(); }` para dejar la coll bloqueada después y evitar mutaciones accidentales desde código posterior:

```javascript
var coll = appData.getCollection("Clientes");
coll.unlock();
try {
    var obj = new Clientes({ MAP_NOMBRE: "Nuevo" });
    coll.addItem(obj);
} finally {
    coll.lock();  // SIEMPRE en finally
}
```

#### setVariable(name, value) / getVariable(name) - Variables de Coleccion

Almacena y recupera variables temporales asociadas a la coleccion (en memoria):

```javascript
coll.setVariable("totalProcesados", 0);
var total = coll.getVariable("totalProcesados");
```

#### Binding de Eventos en Coleccion

```javascript
var coll = appData.getCollection("MiColeccion");

coll.bind("onbeforeedit", function(e) {
    // Se ejecuta antes de entrar en edicion
});

coll.bind("ongroupselected", function(e) {
    // Se ejecuta al cambiar de pestana/grupo
});
```

---

**Siguiente:** [03b - Objeto `ui` (UI y dispositivo)](03b-js-ui.md) · **Índice:** [03 - Guía JavaScript](03-javascript-api-guide.md)
