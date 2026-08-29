# JavaScript Patterns — Contexto, self, colecciones y contents

Sub-archivo de [xone-javascript-patterns.md](xone-javascript-patterns.md). Cubre el contexto de ejecución JS en XOne (motor, objetos globales, limitaciones, eventos XML, alcance de variables, ámbitos, escape XML — entidades o CDATA, ambas válidas), el objeto `self` (DataObject), la API de colecciones (`DataCollection`) y la API de contents embebidos.

## Tabla de Contenidos

- [1. Contexto de Ejecución JavaScript en XOne](#1-contexto-de-ejecucion-javascript-en-xone)
- [2.3 Objeto `self`](#23-objeto-self)
- [2.4 Colecciones](#24-colecciones)
- [2.5 Contents (Contenidos Embebidos)](#25-contents-contenidos-embebidos)

---

## 1. Contexto de Ejecución JavaScript en XOne

### 1.1 Donde se Ejecuta el Código

El código JavaScript en XOne **NO se ejecuta en un navegador web**. Se ejecuta dentro del motor JavaScript nativo embebido en la aplicación móvil. Los scripts se colocan dentro de nodos `<script>` en archivos `.xne`:

```xml
<coll name="MiPantalla" title="Mi Pantalla">
    <create>
        <script language="javascript">
            // Este código se ejecuta una sola vez al crear la pantalla
            inicializar();
        </script>
    </create>
    <before-edit refresh="false" show-wait-dialog="false">
        <action name="runscript">
            <script language="javascript">
                // Este código se ejecuta al abrir la pantalla para edicion
                // (es el evento correcto para inicializar la UI de pantalla)
                cargarDatos();
            </script>
        </action>
    </before-edit>
</coll>
```

> **Importante sobre `<load>`:** el evento `<load>` se dispara **por cada DataObject** al cargarse desde la BD: tanto al recorrer la coleccion (`startBrowse()`/`loadAll()`) como al hidratar items de un `<contents>` o cargas individuales. **NO** es un evento de pantalla y **no se recomienda usarlo** porque el rendimiento puede verse seriamente afectado (se ejecuta una vez por item cargado). Para inicializar una pantalla usar siempre `<before-edit>`.

### 1.2 Objetos Globales Disponibles

XOne expone los siguientes objetos globales accesibles desde cualquier script:

| Objeto | Descripción |
|--------|-------------|
| `ui` | Interfaz de usuario: dialogos, toasts, navegación, GPS, camara |
| `appData` | Datos de la aplicación: colecciones, autenticación, rutas, macros |
| `self` | Objeto de datos actual en el contexto del script |
| `crypto` | Funciones criptograficas: hashing, cifrado, firma digital, encoding |
| `$http` | Cliente HTTP asíncrono: GET, POST, PUT, DELETE, PATCH, download |
| `console` | Logging WHATWG completo: `console.{log,info,debug,warn,error,trace,assert,group,groupCollapsed,groupEnd,time,timeLog,timeEnd,count,countReset,dir,dirxml,clear,table}` con formato `%s/%d/%j/...` |
| `biometricsManager` | Autenticación biometrica (huella, face) y firma digital biometrica |
| `fingerprintManager` | Huella dactilar (API legacy, usar `biometricsManager` en su lugar) |
| `bluetoothSerial` | Comunicación por puerto serie Bluetooth |

### 1.3 Limitaciones Críticas del Entorno

**APIs que NO están disponibles en XOne:**

| API Web | Alternativa XOne |
|---------|------------------|
| `document`, `window` (DOM) | `ui.getView(self)` para acceder a controles |
| `localStorage` / `sessionStorage` | `appData.getGlobalMacro()` / `appData.setGlobalMacro()` |
| `XMLHttpRequest` | `$http.get()`, `$http.post()`, etc. (también existe `fetch` custom) |
| `navigator.geolocation` | `ui.startGps()` / `ui.checkGpsStatus()` |
| `alert()` / `confirm()` / `prompt()` | `ui.msgBox()` / `ui.showToast()` |
| `async` / `await` | Callbacks o `Promise` (sí soportado vía implementación custom) |
| `require()` / `import` | No existe sistema de módulos; usar `functions.js` global |

**APIs que SÍ existen** (implementación custom de XOne, compatible con WHATWG/spec): `Promise` (full ES2024: `all`/`allSettled`/`race`/`any`/`withResolvers`/`.then`/`.catch`/`.finally`/`.status`), `fetch`, `setTimeout`/`setInterval`/`clearTimeout`/`clearInterval`, `URL`/`URLSearchParams`, `Headers`, `AbortController`/`AbortSignal`, `EventTarget`, `TextEncoder`/`TextDecoder`, `console.{log,info,warn,error,debug,trace,...}` con formato `%s/%d/%j/...`, `performance.now()`, `atob`/`btoa`, `structuredClone`, `DOMParser`/`XMLSerializer`.

**Sintaxis ES6+ NO soportada:**

| Sintaxis | Estado | Alternativa |
|----------|--------|-------------|
| Template literals `` `${var}` `` | Parse error sobre el backtick | Concatenación con `+` |
| `async` / `await` | Parse error (reservadas) | Callbacks o `Promise` |
| Spread/rest `...args` | Parse error | `arguments`, `fn.apply(this, arr)` |
| Default params `function f(x=1)` | Parse error | `if (x === undefined) x = 1;` |
| Computed keys en object literals `{[k]: v}` | Parse error (sí en class body) | `var o = {}; o[k] = v;` |
| Optional chaining `?.` / nullish coalescing `??` | Parse error | Chequeos manuales |
| Private fields `#name` en class | Parse error (requiere runtime) | Convención `_name` |
| Static blocks `static { ... }` en class | Parse error | Sentencias `ClassName.x = ...;` tras la clase |

**SÍ funciona:** `let`, `const`, arrow functions `() => {}` (con binding léxico de `this`), destructuring (`var {a, b} = o`), `for...of` sobre arrays/strings, generadores con `yield` (runtime SpiderMonkey legacy — `.next()` devuelve valor directo + `StopIteration`, no `for...of`), Symbol, typed arrays, **`class` ES6+ completo** (declaraciones, expresiones, `extends`/`super`/`static`/getters/setters/computed keys/field declarations/generator methods con `*`), métodos modernos de `String` (`padStart`, `replaceAll`, `at`, `matchAll`, `trimStart`/`trimEnd`, `String.raw` con objeto manual, `fromCodePoint`...) y de `Array` (`map`, `filter`, `reduce`, `find`, `includes`...), `JSON`.

### 1.4 Eventos Disponibles en Nodos XML

Los scripts se vinculan a eventos del ciclo de vida de la pantalla:

| Evento | Momento de Ejecución |
|--------|---------------------|
| `<create>` | Una sola vez al crear el data object |
| `<before-edit>` | **Al abrir la pantalla para edición. Evento correcto para inicializar la UI de pantalla.** |
| `<after-edit>` | Después de entrar en modo edición (post-`before-edit`) |
| `<load>` | Se dispara **por cada DataObject** al cargarse desde la BD (startBrowse/loadAll/`<contents>`/cargas individuales). **NO** es evento de pantalla y **NO** se recomienda usarlo por impacto en rendimiento. |
| `<onchange>` | Cuando cambia el valor de una propiedad (dentro de `<prop>`) |
| `<selecteditem>` | Cuando se selecciona un item en un content/lista |
| `<onback>` | Cuando el usuario pulsa el botón atrás |
| `<script>` con `nodeName` | Nodos personalizados invocables desde código |

### 1.5 Alcance de Variables

```javascript
// Variables globales: accesibles desde cualquier script del proyecto
// Se definen en functions.js
var MI_CONSTANTE = "valor";

// Variables locales: solo dentro de la funcion
function miFuncion() {
    let variableLocal = "solo aquí";
}

// IMPORTANTE: 'self' puede cambiar de contexto en callbacks asincronos
// Guardar referencia antes de callbacks
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

### 1.6 Archivos JavaScript en el Proyecto

```
MiProyecto/
  functions.js          <- Funciones globales (siempre presente)
  scripts/              <- Scripts adicionales organizados
    modulo1.js
    modulo2.js
```

El archivo `functions.js` es el punto de entrada global. Se carga automáticamente y sus funciones están disponibles en todos los scripts del proyecto. Para proyectos grandes, se pueden usar archivos adicionales en la carpeta `scripts/`.

### 1.7 Ambitos de ejecución

Cada script se ejecuta dentro de un **ambito** que determina el valor de `self` (o `This` en VB) y `ThisDataColl`:

| Ambito | Cuando | `self` / `This` | `ThisDataColl` |
| --- | --- | --- | --- |
| **Objeto** | Acción disparada desde un objeto: `<create>`, `<onchange>` de un prop, `<action>` de un botón sobre un objeto | El DataObject en cuestion | `null` |
| **Coleccion** | Acción `<coll-action>` (ej. `<onlogon>`) | `null` | La coleccion |
| **Local** | Dentro de una `function()` JS | — | — |

Las **acciones anidadas** (p.ej. un `self.save()` que dispara `<before-edit>`) crean su propio ambito: las variables locales del script exterior **no son visibles** dentro.

**Para pasar datos entre scripts anidados** usar:

- Propiedades del objeto: `self.MAP_FLAG = 1`
- Variables de coleccion: `coll.setVariable(...)` / `coll.getVariable(...)`
- Colecciones globales: `appData.getCollection("...")`
- Macros globales: `appData.setGlobalMacro("##KEY##", valor)` / `appData.getGlobalMacro("##KEY##")`
- Objeto `user`: propiedades/variables sobreviven toda la sesión

### 1.8 Checklist de buenas prácticas

Al programar en XOne:

- [ ] **No** llamar `LoadAll()` salvo para datasets pequeños y controlados. Preferir `startBrowse()`/`endBrowse()`. Para contar: `startBrowse(true)`.
- [ ] **No** aplicar filtros/orden sobre colecciones globales que también use la UI sin restaurar después. Mejor usar `createClone()`.
- [ ] **Anular referencias en orden inverso** a su creación: primero objetos hijos, luego la coleccion contenedora.
- [ ] **No modificar `CurrentItem`** mientras el cursor esta abierto en BBDD que no lo soporten; usar `executeSql` o acumular IDs.
- [ ] Usar una **propiedad centinela** (`self.MAP_SAVING`) para evitar bucles infinitos cuando un `save()` puede re-disparar el mismo script.
- [ ] En **callbacks asíncronos** (`$http`, `setTimeout`-like, callbacks de voz/NFC/GPS): capturar `self` en una variable local antes porque el contexto puede cambiar.
- [ ] En patrones con `speak` + `recognizeSpeech`, encadenar la escucha dentro de `onCompleted` (ver 7.9).
- [ ] En colecciones con escritura masiva, usar `coll.lock()` / `coll.unlock()` para agrupar escrituras.

---

### 1.9 JavaScript dentro de XNE: escape XML o CDATA

Cuando el JavaScript va embebido dentro de un fichero `.xne` (en `<script language="javascript">` o en atributos como `onclick`, `disablevisible`, `value`...), el bloque JS forma parte del XML y **debe respetar las reglas de XML**.

**Regla preferida — JS no trivial debe vivir fuera del `.xne`:** declarar una función en `functions.js` (o un fichero `.js` incluido) y llamarla desde el XML con `miFuncion();`. Así el JS se escribe normal (sin entidades, sin CDATA) y el XML solo invoca. Es lo más mantenible, lo más legible y evita por completo el problema del escape.

Cuando aun así necesitas escribir JS inline (snippets cortos), hay dos formas válidas de evitar que los caracteres especiales rompan el parseo XML:

1. **Entidades XML** dentro del JavaScript — funciona en cualquier sitio (nodo y atributo).
2. **`<![CDATA[...]]>`** envolviendo el bloque — funciona solo dentro de nodos `<script>`. NO es válido dentro de atributos XML.

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
<!-- Atributo onclick (delimitador "): comparaciones con entidades, comillas internas con &quot; o '.
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

### 2.3 Objeto `self`

El objeto `self` representa el DataObject actual en el contexto de ejecución del script.

```javascript
// Leer propiedades del objeto actual
let nombre = self.MAP_NOMBRE;
let estado = self.MAP_ESTADO;

// Escribir propiedades
self.MAP_NOMBRE = "Nuevo nombre";
self.MAP_ESTADO = "ACTIVO";
self.MAP_FECHA = new Date();

// Obtener la coleccion propietaria del objeto
let coll = self.getOwnerCollection();
let nombreColl = coll.getName();

// Guardar cambios del objeto actual en la base de datos
self.save();

// Obtener contenidos embebidos (contents)
let content = self.getContents("@NombreContent");

// Cargar datos desde JSON
self.loadFromJson('{"ID": 1, "NOMBRE": "Test", "ACTIVO": 1}');

// Convertir a JSON
var jsonObj = self.toJson();        // Retorna objeto JS nativo
var jsonStr = self.toJsonString();  // Retorna string JSON

// Clonar el objeto
var copia = self.clone();
```

#### 2.3.2 Métodos Adicionales del DataObject

```javascript
// === Valor anterior de un campo (util en eventos onchange) ===
// Dentro de un <onchange> de MAP_PRECIO:
var precioAnterior = self.getOldValue("MAP_PRECIO");
var precioNuevo = self.MAP_PRECIO;
if (precioNuevo > precioAnterior * 2) {
    ui.showToast("Alerta: el precio se ha mas que duplicado");
}

// === Verificar si el objeto es nuevo o modificado ===
if (self.isNew()) {
    // Es un registro nuevo, no guardado aún
    self.MAP_FECHA_ALTA = new Date();
}

if (self.getDirty()) {
    // Tiene cambios pendientes de guardar
    ui.showToast("Hay cambios sin guardar");
}

// === Obtener indice del objeto en su coleccion ===
var index = self.getObjectIndex();

// === Obtener el objeto padre (relacion maestro-detalle) ===
var padre = self.getParent();
if (padre) {
    var nombrePadre = padre.MAP_NOMBRE;
}

// === Ejecutar un nodo script definido en el XML ===
self.executeNode("refrescaTotal");
self.executeNode("applyfilter");
self.executeNode("abrirDrawer(2)");

// === Cambiar atributos visuales en tiempo de ejecución ===
// ⚠️ setFieldPropertyValue / setNodePropertyValue son de ÚLTIMO RECURSO.
// Antes valora alternativas: cambiar clase CSS (getControl(x).setClass/addClass),
// usar métodos específicos del control, o expresarlo en el XML/CSS desde el inicio.
// Sobrescribir atributos por cache obliga a llamar a ui.refresh() manualmente y
// rompe la trazabilidad respecto al XML original.
self.setFieldPropertyValue("MAP_BOTON", "img", "nuevo_icono.png");
self.setFieldPropertyValue("MAP_TITULO", "width", "200p");
self.setFieldPropertyValue("MAP_CAMPO_OCULTO", "visible", "7");  // 7 = visible

// === Obtener atributos visuales actuales ===
var ancho = self.getFieldPropertyValue("MAP_TITULO", "width");
var w = parseInt(ancho.replace("p", "")) + 100;
self.setFieldPropertyValue("MAP_TITULO", "width", w.toString() + "p");

// === refresh() / refresh(sqlSentence) - Recargar los valores desde BD ===
// Vuelve a leer el registro de la base de datos (descarta cambios en memoria no guardados).
// NO refresca la UI — para eso usa ui.refresh(prop).
// Con argumento, ejecuta esa sentencia SQL en lugar de la del mapping.
self.refresh();
self.refresh("SELECT * FROM PRODUCTOS WHERE ID=" + self.MAP_ID);

// === setVariable(name, value) / getVariable(name) ===
// Variables de scope del objeto (en memoria, no se persisten en BD).
self.setVariable("estadoCalculo", "ok");
var estado = self.getVariable("estadoCalculo");

// === isPropertyDirty(name) / getDirtyProperties() ===
// Para saber qué campos han cambiado desde la última carga/guardado.
if (self.isPropertyDirty("MAP_PRECIO")) { /* ... */ }
var cambiados = self.getDirtyProperties();   // array de nombres

// === Contents: metadatos ===
var nContents = self.getContentsCount();
var sql = self.getContentAttr("@LineasPedido", "sql");   // atributo XML del content

// === getOldItem(name) ===
// Como getOldValue, pero sin conversion de tipos Date/Calendar (valor crudo).
var valorAntes = self.getOldItem("MAP_FECHA");

// === setNodePropertyValue / getNodePropertyValue ===
// Cambia en runtime un atributo de un nodo del layout, localizándolo por su TAG
// (frame, group, prop...) y el valor de su atributo "name". Para FRAMES es la vía
// correcta: setFieldPropertyValue solo actúa sobre props/campos, NO sobre frames.
// Aplica al renderizar; si la vista ya existe, refrescar después (window.refresh).
// Firma: (tagDelNodo, valorDelAtributoName, nombreAtributo, valor)
self.setNodePropertyValue("frame", "frmCabecera", "bgcolor", "#7C3AED");  // <frame name="frmCabecera">
var v = self.getNodePropertyValue("frame", "frmCabecera", "bgcolor");

// === bind(controlName, eventName, callback) / unbind(controlName, eventName) ===
self.bind("MAP_BOTON", "onclick", function(e) { ui.showToast("Pulsado"); });
self.unbind("MAP_BOTON", "onclick");

// === Metadatos de campos ===
var titulo = self.getPropertyTitle("MAP_NOMBRE");
var grupo  = self.getPropertyGroup("MAP_NOMBRE");
var conValor = self.getPropertyNames();   // nombres de los campos que tienen valor cargado
                                          // (no incluye los declarados sin valor)

// === clearCaches() - Vacía la caché de atributos resueltos ===
self.clearCaches();
```

**IMPORTANTE - Perdida de contexto de `self`:**

```javascript
// PROBLEMA: 'self' puede cambiar en callbacks asincronos
function cargarDesdeAPI() {
    // INCORRECTO
    $http.get(url, request,
        function(sData) {
            self.MAP_RESULTADO = sData;  // self puede haber cambiado
        },
        function(nError, sDesc) {}
    );

    // CORRECTO - guardar referencia antes del callback asincrono
    let miObjeto = self;
    $http.get(url, request,
        function(sData) {
            miObjeto.MAP_RESULTADO = sData;  // referencia segura
            ui.refresh("MAP_RESULTADO");
        },
        function(nError, sDesc) {
            ui.showToast("Error: " + sDesc);
        }
    );
}
```

---

### 2.4 Colecciones

#### 2.4.1 Operaciones CRUD Completas

```javascript
// === CREAR ===
let coll = appData.getCollection("Productos");
coll.unlock();
try {
    let obj = new Productos({
        MAP_NOMBRE: "Producto nuevo",
        MAP_PRECIO: 29.99,
        MAP_ACTIVO: 1,
        MAP_FECHA_ALTA: new Date()
    });
    coll.addItem(obj);
    obj.save();
} finally {
    coll.lock();
}

// === LEER (buscar uno) ===
let coll = appData.getCollection("Productos");
let producto = coll.findObject("MAP_CODIGO = '001'");
if (producto) {
    let nombre = producto.MAP_NOMBRE;
    let precio = producto.MAP_PRECIO;
}

// === LEER (listar todos con filtro) ===
let coll = appData.getCollection("Productos");
coll.setFilter("MAP_ACTIVO = 1");
coll.clear();
coll.loadAll();
coll.doSort("MAP_NOMBRE ASC");

let items = [];
let nCount = coll.getCount();
for (let i = 0; i < nCount; i++) {
    items.push(coll.get(i));
}

// === ACTUALIZAR ===
let producto = coll.findObject("MAP_CODIGO = '001'");
if (producto) {
    producto.MAP_PRECIO = 34.99;
    producto.MAP_FECHA_MOD = new Date();
    producto.save();
}

// === ELIMINAR ===
for (let i = 0; i < coll.getCount(); i++) {
    if (coll.get(i).MAP_CODIGO == "001") {
        coll.deleteItem(i);
        break;
    }
}
```

#### 2.4.2 Bloqueo y Desbloqueo de Colecciones

El patron lock/unlock es obligatorio al modificar colecciones:

```javascript
function agregarItemSeguro(nombreColl, datos) {
    let coll = appData.getCollection(nombreColl);
    coll.unlock();
    try {
        let obj = coll.createObject();
        for (let key in datos) {
            obj[key] = datos[key];
        }
        coll.addItem(obj);
        obj.save();
        return obj;
    } catch(ex) {
        ui.showToast("Error: " + ex);
        return null;
    } finally {
        coll.lock();  // SIEMPRE en finally
    }
}
```

#### 2.4.3 Navegación Browse (startBrowse / endBrowse)

El patron browse permite navegar registro a registro por una coleccion. **Siempre** usar `endBrowse()` en un bloque `finally`.

```javascript
// Patron básico startBrowse / endBrowse
var coll = appData.getCollection("Datos");
coll.startBrowse();
try {
    var item = coll.getCurrentItem();
    if (item !== undefined && item != null) {
        // Procesar el item actual
        var nombre = item.MAP_NOMBRE;
    }
} finally {
    coll.endBrowse();  // SIEMPRE en finally
}

// Recorrer todos los registros con browse
coll.startBrowse();
try {
    coll.moveFirst();
    while (coll.getCurrentItem() !== undefined && coll.getCurrentItem() != null) {
        var obj = coll.getCurrentItem();
        // procesar obj...
        coll.moveNext();
    }
} finally {
    coll.endBrowse();
}
```

#### 2.4.4 Busqueda Avanzada y Macros

```javascript
// === findAllObjects: buscar TODOS los objetos que cumplen un filtro ===
var resultados = coll.findAllObjects("ACTIVO = 1 AND TIPO = 'VIP'");
// Retorna un array de DataObject

// === setMacro / getMacro: macros de coleccion (filtrado dinámico) ===
// REQUISITO: la macro debe estar declarada en el XML de la coll con
//            <macro name="##X##" value="..." default="true" /> al mismo nivel
//            que los <group>. Si no esta declarada, setMacro no inyecta nada.
// API CORRECTA: setMacro / getMacro. NUNCA coll.macro(...) (no existe).
var contentGastos = self.getContents("Gastos");
contentGastos.setMacro("##TIPO##", "tg.NOMBRE LIKE '%" + self.MAP_FTTIPOGASTO + "%'");
coll.setMacro("##MACRO1##", "IDORDEN=" + numOrden);
// Lectura
var filtroActual = contentGastos.getMacro("##TIPO##");

// Diferencia con setGlobalMacro:
// - coll.setMacro afecta SOLO al SQL de esa coleccion (filtros locales).
// - appData.setGlobalMacro guarda un valor en una macro GLOBAL accesible
//   desde cualquier punto del código (equivalente a localStorage).

// === Busqueda indexada en memoria ===
// Crear indice sobre campos especificos (para busqueda rápida en listas grandes)
coll.createSearchIndex(["NOMBRE,"]);

// Buscar texto en el indice creado (ideal para filtrado en tiempo real)
coll.doSearch(evento.newText);

// === Variables de coleccion (almacenamiento temporal asociado a la coleccion) ===
coll.setVariable("totalProcesados", 0);
var total = coll.getVariable("totalProcesados");
```

#### 2.4.5 Información y Metadatos de la Coleccion

```javascript
// Nombre de la coleccion
var nombre = coll.getName();

// Número de propiedades definidas
var numProps = coll.getPropertyCount();

// Nombre de una propiedad por indice
var propName = coll.propertyName(0);

// Tipo de una propiedad
var tipo = coll.getPropType("MAP_NOMBRE");

// Generar ROWID unico
var rowId = coll.generateRowId();

// Verificar si la coleccion esta vacia
if (coll.isEmpty()) {
    ui.showToast("No hay registros");
}
```

#### 2.4.6 Cargar desde JSON

`loadFromJson` ya vacía la coll antes de cargar, así que el `clear()` es opcional. Sigue el patrón estándar de modificación: `unlock(); try {...} finally { lock(); }`.

```javascript
var coll = appData.getCollection("MiColeccion");
coll.unlock();
try {
    coll.loadFromJson(jsonData);
} finally {
    coll.lock();
}
```

#### 2.4.7 Binding de Eventos en Coleccion

```javascript
var coll = appData.getCollection("MiColeccion");

coll.bind("onbeforeedit", function(e) {
    // Se ejecuta antes de entrar en edicion de un registro
});

coll.bind("ongroupselected", function(e) {
    // Se ejecuta cuando se cambia de pestana/grupo
});
```

---

### 2.5 Contents (Contenidos Embebidos)

Los contents son listas embebidas dentro de un objeto (relación maestro-detalle).

#### 2.5.1 Manipulación de Contents

```javascript
// Obtener content del objeto actual
let content = self.getContents("@MisLineas");

// Cargar datos del content
content.unlock();
try {
    content.clear();
    content.loadAll();
} finally {
    content.lock();
}

// Agregar un item al content
let newItem = content.createObject();
newItem.MAP_DESCRIPCION = "Línea nueva";
newItem.MAP_CANTIDAD = 1;
newItem.MAP_PRECIO = 10.50;

content.unlock();
try {
    content.addItem(newItem);
} finally {
    content.lock();
}
content.saveAll();

// Obtener item por posicion
let primerItem = content.get(0);

// Contar items
let total = content.getCount();

// Refrescar la vista del content
ui.refresh("MAP_CONTENT_PROP");
```

#### 2.5.2 Control de Content en la UI

```javascript
let window = ui.getView(self);
let vContent = window["MAP_CONTENT_PROP"];

// Scroll a una posicion
vContent.scrollTo(5);

// Agregar item a la vista (al final de la lista)
vContent.addItem(object);

// Agregar item en una posicion concreta (2o parametro opcional: indice)
vContent.addItem(object, 0);   // lo inserta como primer elemento de la lista

// Seleccionar un item
vContent.setSelectedItem(0);
```

**`addItem(objeto, [indice])`** — agrega el objeto a la lista visible y a la coleccion
de datos del content. Sin el segundo parametro lo añade al final; con un indice lo
inserta en esa posicion (lista y datos quedan sincronizados). El indice se acota al
rango valido: un valor negativo equivale a `0` (primer elemento) y un valor mayor que el
numero de elementos lo añade al final. Devuelve la vista de la fila insertada.

---


**Siguiente:** [b - Objeto ui](xone-javascript-patterns-b-ui.md) · **Índice:** [xone-javascript-patterns.md](xone-javascript-patterns.md)