---
description: Programación JavaScript en XOne. Usar al escribir o depurar scripts en eventos XML, acceso a self/ui/appData/$http, colecciones y contents, callbacks asíncronos, patrones lock/unlock y startBrowse/endBrowse, SQL seguro, o utilidades de functions.js.
---

# XOne JavaScript

Guía del runtime JavaScript de XOne: objetos globales, acceso a datos, UI, HTTP, patrones críticos y mejores prácticas. El JS de XOne **no corre en navegador ni Node**: va en bloques `<script>` de los `.xne` (eventos del ciclo de vida) y en `functions.js`, cargado automáticamente al iniciar. No hay módulos (`require`/`import`): todo lo global va en `functions.js`.

## Objetos globales

| Objeto | Uso |
|--------|-----|
| `self` | DataObject actual (registro/fila) del script |
| `ui` | UI: diálogos, toasts, navegación, GPS, cámara, refresh |
| `appData` | Datos de la app: colecciones, macros, sesión, SQL |
| `$http` | Cliente HTTP asíncrono: GET/POST/PUT/DELETE/PATCH/download |
| `console` | Solo `console.log()` (no hay warn/error) |
| `replica` | Sincronización con servidor |
| `crypto` | Hash, AES, firma digital, encoding |
| `biometricsManager` / `fingerprintManager` | Huella/face (preferir `biometricsManager`) |
| `bluetoothSerial` | Puerto serie Bluetooth |

### APIs web que NO existen

`document`/`window` → `ui.getView(self)`; `localStorage` → `appData.getGlobalMacro()`; `fetch` → `$http`; `setTimeout` → `ui.executeActionAfterDelay()`; `navigator.geolocation` → `ui.startGps()`; `alert` → `ui.msgBox()`; `Promise`/`async/await` → callbacks.

## Eventos del ciclo de vida

| Evento | Momento |
|--------|---------|
| `<create>` | Una sola vez al crear la pantalla |
| `<load>` | Cada vez que la pantalla recibe foco (no fiable para carga, ver skill xml-ui) |
| `<before-edit>` | Antes de entrar en modo edición — el más usado para inicializar |
| `<onchange>` | Cambio de valor de un prop (dentro de `<prop>`) |
| `<selecteditem>` | Selección de un item en un content (dentro de `<contents>`) |
| `<onback>` | Botón atrás del dispositivo |
| `<script nodeName="X">` | Nodo personalizado invocable con `executeNode("X")` |

## `self` — el DataObject actual

```javascript
// Acceso a campos (equivalentes)
self.MAP_NOMBRE = "X";                // notación de punto (recomendada)
self["MAP_NOMBRE"] = "X";             // notación dinámica
self.setValue("MAP_NOMBRE", "X");     // explícito
var n = self.getValue("MAP_NOMBRE");

// Tipos por tipo de prop
self.MAP_TEXTO = "texto";             // T
self.MAP_NUM = 42;                    // N
self.MAP_FECHA = new Date();          // D
self.MAP_ACTIVO = 1;                  // B (0 o 1)
```

Métodos verificados en el runtime `xone-simulator`:

```javascript
self.getOwnerCollection();          // colección propietaria
self.save();                        // guardar en BD (verificar appData.error())
self.getContents("MiContent");      // content hijo (colección embebida)
self.executeNode("miNodo");         // ejecutar <script nodeName>
self.getFieldPropertyValue("MAP_X", "width");   // leer atributo de control
self.setFieldPropertyValue("MAP_X", "width", "200p");  // cambiar en runtime
self.toJSON();                      // objeto JS del registro
self.getObjectIndex();              // índice en la colección
self.getVariables(name);            // variable del objeto
self.setVariables(name, value);
```

Para registrar si hay cambios pendientes o el objeto es nuevo usa los métodos documentados en la referencia (`getDirty()`, `isNew()`), y para el valor previo de un campo `getOldValue("MAP_X")` (útil en `onchange`).

## `selfDataColl` — la colección directa

`selfDataColl` es la colección contenedora de `self`, sin llamar a `getOwnerCollection()`:

```javascript
selfDataColl.loadAll();
var count = selfDataColl.count();
```

## Contenidos (contents)

```javascript
var lineas = self.getContents("@LineasPedido");
lineas.unlock();
try {
    lineas.clear();
    lineas.loadAll();
    // iterar
    for (var i = 0; i < lineas.getCount(); i++) {
        var l = lineas.get(i);
        console.log(l.MAP_DESCRIPCION);
    }
} finally {
    lineas.lock();
}
lineas.saveAll();
```

Para añadir una línea: `unlock` → `createObject()` → asignar campos → `addItem(obj)` → `lock()` en `finally` → `saveAll()`. Usa `getAllContentNames()` para listar contents.

## Colecciones (`appData.getCollection`)

```javascript
var coll = appData.getCollection("Clientes");
coll.loadAll();
var total = coll.getCount();        // o coll.count()
var obj = coll.get(0);

obj = coll.findObject("LOGIN = 'admin'");
obj = coll.getItem("MAP_CAMPO", valor);
var todos = coll.findAllObjects("TIPO = 'A'");
```

Filtrar y ordenar:

```javascript
coll.setFilter("ACTIVO = 1");
coll.clear();
coll.loadAll();
coll.doSort("NOMBRE ASC");
```

Métodos verificados en `DataCollection`: `createObject`, `addItem`, `deleteItem(index)`, `browseDeleteAll`, `clear`, `getCount`/`count`, `get(index)`, `indexOf`, `getCurrentItem`, `moveFirst/moveNext/movePrevious/moveLast/moveTo`, `startBrowse`/`endBrowse`, `setFilter`, `doSort`, `loadAll`, `findObject`, `findAllObjects`, `getItem`, `loadFromJson`, `saveAll`, `lock`/`unlock`, `createClone`, `setMacro`/`getMacro`, `setVariable`/`getVariable`, `createSearchIndex`/`doSearch`, `generateRowId`, `getName`, `getPropertyCount`, `propertyName`, `getPropType`.

## `ui` — interfaz de usuario

```javascript
// Navegación
ui.openMenu("NombreColeccion", self);
ui.openEditView(dataObject);
var win = ui.getView(self);       // ventana actual
win.exit();                       // cerrar pantalla

// Mensajes
var r = ui.msgBox("Continuar?", "Confirmar", 4);   // 4 = Sí/No, retorna 6=Sí 7=No
ui.showToast("Mensaje");                            // o con objeto {text, color, duration...}
ui.showSnackbar({ text: "Registro eliminado", actionText: "Deshacer", ... });
ui.showWaitDialog("Cargando...");
ui.hideWaitDialog();

// Refresh (refrescar solo lo necesario)
ui.refresh("MAP_NOMBRE");                 // o lista separada por comas
ui.refreshValue("MAP_CAMPO");             // solo valor, sin reconstruir
ui.refreshContentRow("MAP_CONTENT", 0);

// Control seguro
function getControl(s) {
    if (!s || !self) return null;
    var w = ui.getView(self);
    return w ? (w[s] || null) : null;
}
```

Otros métodos verificados en `UserInterface`: `openEditView`, `openMenu`, `msgBox`, `showToast`, `showSnackbar`, `showWaitDialog`/`hideWaitDialog`/`updateWaitDialog`/`setMaxWaitDialog`, `refresh`, `refreshValue`, `getView`, `showGroup`/`hideGroup`/`isGroupOpen`, `executeActionAfterDelay(nodeName, seconds)`, `startGps`/`stopGps`/`checkGpsStatus`, `takePicture`, `record`, `scanQr`, `openFile`, `pickFile`, `sendMail`, `openUrl`, `makePhoneCall`, `startCamera`, `startScanner`, `startAudioRecord`/`stopAudioRecord`, `askUserForGpsPermission`, `startReplica`, `setStatusBarColor`, `setBottomSheetState`.

### GPS

```javascript
ui.startGps({ nodeName: "callbackgps", timeBetweenUpdates: 10000, foreground: true });
var st = ui.checkGpsStatus();
// 0 sin hardware · 1 solo GPS · 2 solo redes · 3 ninguno (pedir permiso) · 4 óptimo
if (st == 0 || st == 3) {
    ui.askUserForGpsPermission({
        onEnabled: function() { ui.startGps(); },
        onDenied:  function() { ui.showToast("Active el GPS"); }
    });
}
// Posición actual vía colección GPSColl
var g = appData.getCollection("GPSColl");
g.startBrowse();
try {
    var obj = g.getCurrentItem();
    if (obj && obj.STATUS == 1 && obj.LONGITUD) {
        self.MAP_LATITUD = obj.LATITUD;
        self.MAP_LONGITUD = obj.LONGITUD;
        ui.refresh("MAP_LATITUD,MAP_LONGITUD");
    }
} finally { g.endBrowse(); }
```

## `appData` — aplicación y datos

```javascript
// Colecciones
var coll = appData.getCollection("MiColl");

// Sesión / navegación
appData.login({ userName: "...", password: "...", entryPoint: "MenuPrincipal",
    onLoginSuccessful: function(){}, onLoginFailed: function(){} });
appData.logout();
appData.exit();
appData.restart();

// Pila de valores (pasar datos entre pantallas)
appData.pushValue(clienteId);         // en origen
var id = appData.popValue();          // en destino

// Macros globales (alternativa a localStorage)
appData.setGlobalMacro("##TOKEN##", "abc");
var t = appData.getGlobalMacro("##TOKEN##");
var os = appData.getGlobalMacro("##DEVICE_OS##");   // "android" | "ios"

// SQL directo
appData.executeSql("UPDATE gen_Productos SET ACTIVO=0 WHERE STOCK=0");

// Salida estándar
appData.failWithMessage(-11888, "##EXIT##");      // cerrar pantalla
appData.failWithMessage(-11888, "##EXITAPP##");   // cerrar app
```

Métodos verificados en `AppData`: `getCollection`, `setGlobalMacro`/`getGlobalMacro`, `pushValue`/`popValue`, `getCurrentUser`, `getCurrentEnterprise`, `login`/`logout`, `exit`, `executeSql`, `failWithMessage`, `executeNode`, `getAppPath`, `getFilesPath`, `error`, `loadIncludeFile`, `loadCssFile`/`unloadCssFile`.

### SQL seguro con SqlManager

```javascript
var sql = new SqlManager();
try {
    sql.openDatabase({ databasePath: "gestion.db", useExistingConnection: true });
    var cursor = sql.doRawQuery(
        "SELECT * FROM gen_Usuarios WHERE LOGIN=? AND ACTIVO=?", "admin", 1);
    try {
        if (cursor.getCount() > 0) {
            cursor.moveToFirst();
            var nombre = cursor.getString("NOMBRE");
        }
    } finally { cursor.close(); }   // SIEMPRE cerrar el cursor
} finally { sql.close(); }          // SIEMPRE cerrar la conexión
```

Nunca concatenes valores en el SQL (ver sección de seguridad).

## `$http` — HTTP asíncrono

```javascript
var contexto = self;   // GUARDAR self antes del callback

var request = {
    headers: { "Content-Type": "application/json", "Authorization": "Bearer " + token },
    parameters: { connectTimeout: 120000, readTimeout: 120000,
                  allowUnsafeCertificates: false },
    data: { pagina: 1, limite: 50 }
};

$http.get(url, request,
    function(sData, headers, nHttpStatusCode) {
        var json = JSON.parse(sData);   // envolver en try/catch
        contexto.MAP_RESULTADO = json.id;
        ui.refresh("MAP_RESULTADO");
    },
    function(nError, sErrorDesc) {
        ui.showToast("Error " + nError + ": " + sErrorDesc);
    });
```

Verbos: `$http.get(url, [request], ok, err)`, `$http.post/put/delete/patch(url, request, ok, err)`, `$http.download(url, request, ok, err)` (en éxito, `sPath` es la ruta local; abre con `ui.openFile(sPath)`). El método retorna un `future` que admite `.cancel()` — útil para cancelar la petición anterior al buscar:

```javascript
if (requestActual) requestActual.cancel();
requestActual = $http.get(url + "?q=" + termino, request,
    function(sData) { requestActual = null; procesar(JSON.parse(sData)); },
    function(nError, sDesc) { requestActual = null; });
```

En `parameters`: `allowUnsafeCertificates` nunca debe ser `true` en producción; `enablePinning` y `allowedRootCas` para pinning TLS. La respuesta siempre es string (`sData`): parsear con `JSON.parse` dentro de `try/catch`.

## Patrones críticos

### lock/unlock (modificar colecciones o contents)

```javascript
coll.unlock();
try {
    var obj = coll.createObject();
    obj.MAP_NOMBRE = "X";
    coll.addItem(obj);
    obj.save();
} catch (e) {
    ui.showToast("Error: " + e);
} finally {
    coll.lock();   // SIEMPRE
}
```

### startBrowse/endBrowse (navegar colecciones)

```javascript
coll.startBrowse();
try {
    coll.moveFirst();
    while (coll.getCurrentItem() != null) {
        // procesar getCurrentItem()
        coll.moveNext();
    }
} finally {
    coll.endBrowse();   // SIEMPRE
}
```

### filter/restore (filtrado seguro)

```javascript
var original = coll.getFilter();
try {
    coll.setFilter("ACTIVO = 1");
    coll.loadAll();
    // procesar
    coll.clear();
} finally {
    coll.setFilter(original);   // restaurar SIEMPRE
}
```

### Preservación de contexto (callbacks asíncronos)

`self` puede cambiar de contexto en callbacks de `$http`, `executeActionAfterDelay`, GPS, etc. Guardar la referencia **antes**:

```javascript
var contexto = self;
$http.get(url, function(sData) {
    contexto.MAP_DATO = sData;    // CORRECTO
    // self.MAP_DATO = sData;     // INCORRECTO, puede ser null
    ui.refresh("MAP_DATO");
});
```

### WaitDialog seguro

```javascript
ui.showWaitDialog("Procesando...");
try {
    // trabajo
} catch (e) {
    ui.showToast("Error: " + e);
} finally {
    ui.hideWaitDialog();   // SIEMPRE
}
```

### Cursor SQL seguro

Ver sección SqlManager: `cursor.close()` y `sql.close()` siempre en `finally`.

## Utilidades recomendadas (functions.js)

```javascript
function isEmpty(v)   { return v === undefined || v === null || v === ""; }
function cstr(v)      { return (v === undefined || v === null) ? "" : v.toString(); }
function cnum(v)      { var n = parseFloat(v); return isNaN(n) ? 0 : n; }
function isNothing(o) { return o === null || o === undefined || o == "undefined"; }

function getControl(s) {
    if (!s || !self) return null;
    var w = ui.getView(self);
    return w ? (w[s] || null) : null;
}

function confirmar(mensaje, titulo) {
    return ui.msgBox(mensaje, titulo || "Confirmar", 4) == 6;
}

function buscarObjeto(nombreColl, campo, valor) {
    var esc = cstr(valor).replace(/'/g, "''");   // escapar comillas
    return appData.getCollection(nombreColl).findObject(campo + "='" + esc + "'");
}
```

Usar `cnum()` para evitar `NaN` en cálculos con valores null/undefined. Usar `isEmpty()`/`cstr()` antes de concatenar o comparar.

## Debugging

```javascript
console.log("Valor: " + self.MAP_NOMBRE);
appData.writeConsoleString("Debug: proceso iniciado");   // consola del framework

// Toast para ver en el dispositivo
function debugToast(v, n) { ui.showToast(n + " = " + cstr(v)); }

// Error del framework tras guardar
self.save();
var err = appData.error();
if (err.getNumber() != 0) {
    ui.showToast("Error: " + err.getDescription());
    err.clear();
}
```

### Errores comunes

| Error | Causa | Solución |
|-------|-------|----------|
| `self es null` | Acceso a `self` en callback | Guardar referencia antes |
| `coleccion bloqueada` | `addItem` sin `unlock` | Patrón `unlock; try {...} finally { lock; }` |
| `NaN en cálculos` | Valor null/undefined | Usar `cnum()` |
| `campo no encontrado` | Nombre de prop incorrecto | Coincide exacto con el XML (case-sensitive) |
| `cursor no cerrado` | Fuga de recursos SQL | `cursor.close()` en `finally` |
| `WaitDialog no desaparece` | Error antes de `hideWaitDialog` | `try/finally` |
| `GPS STATUS != 1` | GPS desactivado/sin señal | `checkGpsStatus()` + permiso |
| `Error en JSON.parse` | Respuesta no es JSON | `try/catch` al parsear |
| `window es null` | Pantalla cerrada durante callback | Verificar `window != null` antes de usar controles |
| `refresh no actualiza` | Nombre de campo incorrecto | Usar el nombre exacto del prop |

## Seguridad

- **SQL injection**: usar `SqlManager.doRawQuery` con parámetros `?` o escapar comillas (`'` → `''`) al construir filtros. Nunca concatenar entrada del usuario en SQL.
- **Credenciales**: nunca hardcodear tokens/passwords; usar macros globales o el store seguro.
- **`allowUnsafeCertificates`**: nunca `true` en producción.
- **Validación**: validar entradas con `isEmpty()`, `sanearEntrada()` y comprobaciones de formato antes de `save()` (un campo obligatorio sin valor produce error `-8100`).
- **Encriptación básica**: `appData.encryptString()`/`decryptString()`; para AES/firma usa `crypto`.

## Rendimiento

- Refrescar solo los campos afectados (`ui.refresh("MAP_CAMPO")`), no toda la vista.
- `ui.refreshValue()` para actualizar el valor sin reconstruir el control.
- Liberar colecciones con `clear()` después de procesarlas; cerrar cursores y conexiones SQL.
- Usar `saveAll()` al final en lugar de `save()` individual en bucles.
- Usar `ui.executeActionAfterDelay()` en lugar de `ui.sleep()` (bloqueante).
- `createSearchIndex()` + `doSearch()` para búsqueda en memoria sobre listas grandes.
- No cargar todos los datos si la pantalla no los necesita: filtrar o cargar solo el content visible.
