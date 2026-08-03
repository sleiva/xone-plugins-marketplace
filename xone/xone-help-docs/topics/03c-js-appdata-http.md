# JavaScript API — `appData`, `$http`, OAuth2 y `replica`

Sub-archivo del [Tópico 03 - Guía Completa de JavaScript](03-javascript-api-guide.md). Cubre el objeto `appData` (colecciones, autenticación, navegación entre pantallas con datos, macros globales, SQL directo, encriptación, deteccion de dispositivo, push, etc.), el cliente HTTP `$http` (GET/POST/PUT/PATCH/DELETE, Futures, SSL/TLS, proxy, WebSocket, JSON), autenticación OAuth2 y replicación con el objeto `replica`.

## Tabla de Contenidos

- [4. Objeto Global `appData`](#4-objeto-global-appdata---aplicacion)
- [5. Objeto Global `$http`](#5-objeto-global-http---peticiones-http)
- [6. OAuth2 - Autenticación OAuth](#6-oauth2---autenticacion-oauth)
- [7. Objeto `replica` - Sincronización](#7-objeto-replica---sincronizacion)

---

## 4. Objeto Global `appData` - Aplicación

El objeto global `appData` gestiona datos, configuración, sesión y estado de la aplicación.

### 4.1 Colecciones

#### Crear objetos: patrón preferido (constructor `new`)

Toda colección de la aplicación está disponible como constructor global. `new NombreColeccion()` crea un objeto nuevo de esa colección y acepta un parámetro opcional con los valores iniciales (cada propiedad se asigna igual que `obj.PROP = valor`, disparando sus `onchange`):

```javascript
// Crear un objeto nuevo con valores iniciales
let obj = new Clientes({ NOMBRE: "ACME", ACTIVO: 1 });

// El parámetro es opcional
let obj2 = new Clientes();

// Crear, añadir a la colección y guardar
let coll = appData.getCollection("Clientes");
let obj3 = new Clientes({ NOMBRE: "Nuevo registro" });
coll.addItem(obj3);
obj3.save();
```

Cuándo NO aplica el constructor:

- **Contents anidados**: para crear líneas de un content usa `self.Contents("Lineas").createObject()` — crear desde el content establece el vínculo con el objeto padre; el constructor crea sobre la colección global y no vincula.
- **Nombre de colección dinámico**: si el nombre llega en una variable, usa el patrón legacy `appData.getCollection(nombre).createObject()`.

El constructor solo crea objetos. No existen métodos estáticos tipo ORM (`Usuarios.find(...)`, `Usuarios.create(...)`, `Usuarios.findById(...)`); las consultas se hacen con `appData.getCollection("Usuarios").findObject(...)` y demás métodos de la colección.

```javascript
// (legacy) Patrón antiguo de creación — sigue funcionando, pero el preferido es el constructor
let coll = appData.getCollection("Clientes");
let obj = coll.createObject();
obj.NOMBRE = "ACME";
obj.ACTIVO = 1;
```

#### API de colecciones

```javascript
// === Obtener una coleccion por nombre ===
let coll = appData.getCollection("NombreColeccion");

// === Crear nuevo objeto y agregarlo ===
let obj = new NombreColeccion({ MAP_NOMBRE: "Nuevo registro" });
coll.addItem(obj);
obj.save();

// === Cargar todos los registros ===
coll.loadAll();
let nCount = coll.getCount();  // Número de registros cargados

// === Iterar registros ===
for (let i = 0; i < coll.getCount(); i++) {
    let obj = coll.get(i);
    console.log(obj.MAP_NOMBRE);
}

// === Navegacion con browse ===
coll.startBrowse();
let item = coll.getCurrentItem();
coll.moveFirst();
while (coll.getCurrentItem() != null) {
    // Procesar item
    coll.moveNext();
}
coll.endBrowse();

// === Buscar objetos ===
let obj = coll.findObject("LOGIN = 'admin'");
let obj2 = coll.findObject("ID = 5 AND ACTIVO = 1");
let obj3 = coll.getItem("MAP_CAMPO", valor);
let todos = coll.findAllObjects("TIPO = 'A'");

// === Filtrar y ordenar ===
coll.setFilter("ACTIVO = 1 AND TIPO = 'A'");
coll.clear();
coll.loadAll();
coll.doSort("NOMBRE ASC");

// === Eliminar registros ===
coll.deleteItem(indice);        // Eliminar por indice
coll.browseDeleteAll();         // Eliminar todos de la BD
coll.clear();                   // Limpiar solo memoria

// === Guardar todos los registros modificados ===
coll.saveAll();

// === Bloquear/desbloquear para modificaciones ===
coll.lock();
coll.unlock();

// === Clonar coleccion ===
let collClone = coll.createClone();

// === Cargar desde JSON ===
coll.loadFromJson("[{'ID': 1, 'NOMBRE': 'Item1'}, {'ID': 2, 'NOMBRE': 'Item2'}]");

// === Variables y macros de coleccion ===
coll.setVariable("totalProcesados", 0);
let total = coll.getVariable("totalProcesados");
coll.setMacro("##FILTRO##", "activo=1");
let filtro = coll.getMacro("##FILTRO##");

// === Busqueda en memoria ===
coll.createSearchIndex(["NOMBRE", "DESCRIPCION"]);
coll.doSearch("texto a buscar");

// === Información de la coleccion ===
let nombre = coll.getName();
let propCount = coll.getPropertyCount();
let propName = coll.propertyName(0);
let propType = coll.getPropType("MAP_CAMPO");

// === Generar ROWID ===
let rowid = coll.generateRowId();
```

### 4.2 Autenticación

```javascript
// === Login ===
appData.login({
    userName          : self.MAP_USER,
    password          : self.MAP_PASSWORD,
    entryPoint        : "MenuPrincipal",
    onLoginSuccessful : function() {
        ui.showToast("Login OK!");
    },
    onLoginFailed     : function() {
        ui.showToast("Login failed!");
    }
});

// === Logout ===
appData.logout();

// === Salir de la app ===
appData.exit();

// === Reiniciar la app ===
appData.restart();

// === Obtener empresa y usuario actual ===
let empresa = appData.getCurrentEnterprise();
let empresas = appData.getAllowedEnterprises();
let usuarios = appData.getAllowedUsers();
```

### 4.3 Navegación entre Pantallas con Datos

Para abrir una pantalla pasándole datos, se usa el patrón **dataObject + `ui.openEditView()`**:

1. Obtener (o crear) un **dataObject** de la colección destino.
2. Asignar los valores deseados a sus propiedades (`obj.MAP_X = valor`).
3. Llamar a `ui.openEditView(dataObject)` — XOne abre la vista de edición de ese objeto.

```javascript
// === Pasar un objeto NUEVO a la pantalla destino ===
let coll = appData.getCollection("DetalleCliente");
let obj = new DetalleCliente({ MAP_CLIENTE_ID: clienteId, MAP_MODO: "consulta" });
coll.addItem(obj);
ui.openEditView(obj);

// === Abrir un objeto EXISTENTE recuperado de la BD ===
let coll = appData.getCollection("Clientes");
let cliente = coll.findObject("ID = " + clienteId);
if (cliente) {
    ui.openEditView(cliente);
}
```

**Forma corta — crear + abrir en una sola llamada:**

Si solo necesitas abrir un objeto nuevo sin preparar nada de antemano, basta con pasar el nombre de la colección. XOne hace internamente `createObject()` + `addItem()`:

```javascript
ui.openEditView("DetalleCliente");
```

**Cerrar la vista actual al abrir la nueva:**

`openEditView` admite un segundo argumento booleano para terminar la vista origen tras abrir la siguiente (flujos lineales sin botón atrás):

```javascript
ui.openEditView(obj, true);  // cierra la vista origen al abrir la nueva
```

### 4.4 Macros Globales

Las macros globales son pares clave-valor accesibles desde toda la aplicación. Son la alternativa de XOne a `localStorage`:

```javascript
// === Establecer y leer macros personalizadas ===
appData.setGlobalMacro("##MI_TOKEN##", "abc123");
let token = appData.getGlobalMacro("##MI_TOKEN##");

// === Macros del sistema ===
let deviceOs = appData.getGlobalMacro("##DEVICE_OS##");     // "android" o "ios"
let version = appData.getGlobalMacro("##VERSION##");
let frameVersion = appData.getGlobalMacro("##FRAME_VERSION##");

// === Obtener todas las macros ===
let todasMacros = appData.getAllGlobalMacros();

// === Patron comun: almacenar datos de sesion ===
function guardarSesion(usuario) {
    appData.setGlobalMacro("##USERID##", usuario.ID);
    appData.setGlobalMacro("##USERNAME##", usuario.NOMBRE);
    appData.setGlobalMacro("##USERROLE##", usuario.ROL);
}

function limpiarSesion() {
    appData.setGlobalMacro("##USERID##", "");
    appData.setGlobalMacro("##USERNAME##", "");
    appData.setGlobalMacro("##USERROLE##", "");
}
```

### 4.5 SQL Directo

**Firma:** `appData.executeSql(sql)`

- Acepta **exactamente 1 parámetro** (string SQL); no admite placeholders `?` ni varargs.
- **Sustituye automáticamente** las macros del framework (`##USERID##`, `##NOW##`, etc.) en el SQL antes de ejecutar.
- **No usar para leer escalares**: para `SELECT` no devuelve el valor, devuelve un cursor inutilizable desde JS. Para leer datos usar `SqlManager.doRawQuery()` + cursor.
- Casos de uso: sentencias de modificación masiva, sobre todo cuando hay cursores abiertos sobre la misma tabla y `CurrentItem` no puede modificarse desde la coll.

```javascript
// === Ejecutar SQL directo (UPDATE/INSERT/DELETE) ===
appData.executeSql("UPDATE gen_Productos SET ACTIVO=0 WHERE STOCK=0");

// NO usar executeSql para leer escalares: no devuelve el COUNT, devuelve un ResultSet
// var n = appData.executeSql("SELECT COUNT(*) FROM gen_Clientes"); // MAL

// === SqlManager para consultas avanzadas ===
let sqlManager = new SqlManager();
try {
    sqlManager.openDatabase({
        databasePath         : "gestion.db",
        useWal               : true,
        readOnly             : false,
        useExistingConnection: true,
        onDatabaseCorrupted  : function() {
            ui.showToast("Base de datos corrupta");
        }
    });

    // Consulta con parametros (SEGURO contra SQL injection)
    let cursor = sqlManager.doRawQuery(
        "SELECT * FROM gen_Usuarios WHERE LOGIN=? AND ACTIVO=?",
        "admin", 1
    );
    try {
        if (cursor.getCount() > 0) {
            cursor.moveToFirst();
            let nombre = cursor.getString("NOMBRE");
            let id = cursor.getInteger("ID");
        }
    } finally {
        cursor.close();  // SIEMPRE cerrar el cursor
    }

    // Insertar con parametros seguros
    sqlManager.insert({
        tableName: "gen_Productos",
        fields: {
            CODIGO: "PROD001",
            NOMBRE: "Producto nuevo",
            PRECIO: 29.99,
            ACTIVO: 1
        }
    });

    // Batch de SQLs
    let sqls = [];
    sqls.push("UPDATE gen_Productos SET PROCESADO=1 WHERE FECHA < '2024-01-01'");
    sqls.push("DELETE FROM gen_Log WHERE FECHA < '2023-01-01'");
    sqlManager.doBatchParseSqls(sqls);

    // Mantenimiento
    sqlManager.doWalCheckpoint();
    sqlManager.doVacuum();

} finally {
    sqlManager.close();  // SIEMPRE cerrar la conexión
}
```

### 4.6 Encriptación (Básica)

```javascript
// Encriptar string (encriptacion simple del framework)
let encrypted = appData.encryptString("texto secreto");

// Desencriptar string
let decrypted = appData.decryptString(encrypted);
```

Para encriptación avanzada (AES, RSA, firma digital), usar el objeto `crypto` documentado más adelante en la sección de Seguridad.

### 4.7 Deteccion de Dispositivo

```javascript
// Tipo de dispositivo
if (appData.isPhone()) { /* Teléfono */ }
if (appData.isTablet()) { /* Tablet */ }
if (appData.isWatch()) { /* Smartwatch */ }
if (appData.isWatchRound()) { /* Reloj redondo */ }
if (appData.isWatchSquare()) { /* Reloj cuadrado */ }

// Subtipos de teléfono
appData.isMiniPhone();  // Teléfono pequeño
appData.isMidPhone();   // Teléfono mediano
appData.isHiPhone();    // Teléfono grande

// Orientacion
if (appData.isVertical()) { /* Modo vertical (portrait) */ }
if (appData.isHorizontal()) { /* Modo horizontal (landscape) */ }

// Sistema operativo
let so = appData.getGlobalMacro("##DEVICE_OS##");  // "android" o "ios"
```

### 4.8 Push Notifications

`appData.registerPush(...)` admite tres firmas:

```javascript
// Forma 1: objeto con callbacks (los nombres correctos son onSuccess/onFailure/onPushReceived,
// NO "onRegistered"; el motor lee exactamente esos tres)
appData.registerPush({
    onSuccess: function(event) {
        let pushToken = event.pushToken;      // EventOnPushRegistered.pushToken
        console.log("Push token: " + pushToken);
        // Enviar token al servidor
    },
    onFailure: function(ex) {
        console.error("Push registration failed:", ex);
    },
    onPushReceived: function(message) {
        // Manejar la notificación recibida
    }
});

// Forma 2: una función (callback de éxito)
appData.registerPush(function(event) { /* event.pushToken */ });

// Forma 3: dos funciones posicionales (éxito, fallo)
appData.registerPush(function(event) { /* OK */ },
                     function(ex)    { /* error */ });
```

> Las notificaciones entrantes también se manejan con el nodo `<onpushreceived>` declarado en la `<coll Empresas>`.

### 4.9 Otros Métodos Importantes

```javascript
// === Cerrar la app ===
appData.exit();

// === Cerrar la ventana actual ===
ui.getView(self).exit();

// === Escribir en consola de debug ===
appData.writeConsoleString("Debug: valor = " + valor);

// === Cargar archivos include (solo para casos dinámicos — preferir <include>/<script> en <app>; ver 4.11) ===
appData.loadIncludeFile("scripts/miModulo.js", "javascript", "UTF-8");

// === Cargar/descargar archivos CSS en runtime (solo para casos dinámicos — preferir <style> en <app>; ver 4.12) ===
appData.loadCssFile("temas/oscuro.css");
appData.unloadCssFile("temas/oscuro.css");

// === Rutas del sistema ===
let appPath = appData.getAppPath();      // Ruta base de la aplicación
let filesPath = appData.getFilesPath();  // Ruta de carpeta files/

// === Manejo de errores ===
let error = appData.error();
if (error.getNumber() != 0) {
    console.log("Error: " + error.getDescription());
    console.log("SQL fallido: " + error.getFailedSql());
    error.clear();
}

// === Limpiar caches ===
appData.clearCaches();

// === Crear objetos especiales ===
let pdf = new XOnePDF();
let ocr = new XOneOCR();
let nfc = new XOneNFC();
let printer = new XOnePrinter();
let wifiMgr = new WifiManager();

// === Redondeo seguro ===
let resultado = appData.safeRound(3.14159, 2);  // 3.14

// === Replicacion ===
let isReplicating = appData.isReplicating();
let replicationId = appData.getReplicationId();
```

### 4.10 Métodos Adicionales de appData

#### getCurrentEnterprise() - Empresa Actual

```javascript
var empresa = appData.getCurrentEnterprise();

// Almacenar variables de sesion en la empresa
empresa.setVariable("GPSTime", new Date().toString());
empresa.setVariable("LATITUD", latitud);
empresa.setVariable("MIUBICACION", 0);

// Recuperar variables de la empresa
var valor = empresa.getVariable("GPSTime");
var lat = empresa.getVariable("LATITUD");
var debug = empresa.getVariable("Debug");
```

#### safeRound(value, decimals) - Redondeo Seguro

```javascript
var precio = appData.safeRound(vPendiente, 2);
var total = appData.safeRound(cantidad * precioUnitario, 2);
```

#### encryptString(text) / decryptString(text) - Cifrado/Descifrado

```javascript
var cifrado = appData.encryptString("texto sensible");
var descifrado = appData.decryptString(cifrado);
```

#### error() - Objeto de Error del Framework

```javascript
var error = appData.error();
if (error.getNumber() != 0) {
    console.log("Código: " + error.getNumber());
    console.log("Descripción: " + error.getDescription());
    console.log("SQL fallido: " + error.getFailedSql());
    error.clear();
}
```

#### writeConsoleString(message) - Consola de Depuracion

```javascript
appData.writeConsoleString("App_log_xone->Mensaje de depuracion");
```

#### setIsReplicating(boolean) - Control de Replicación

```javascript
appData.setIsReplicating(false);
// ... operaciones de mantenimiento local
appData.setIsReplicating(true);
```

#### Conexiones

```javascript
// Conexión por nombre (útil cuando la app declara varias conexiones)
var conn = appData.getConnection("REMOTA");

// String de la conexión PRINCIPAL (la por defecto)
var s = appData.getConnString();
```

#### getCollectionCount() / getVisualConditions()

```javascript
var nColls = appData.getCollectionCount();          // total de colecciones registradas
var conds  = appData.getVisualConditions();         // string con las condiciones visuales activas
```

### 4.11 Carga dinámica de scripts (`loadIncludeFile`) y declaración preferida

> **Regla general:** declara los scripts en el nodo `<app>` siempre que puedas. Reserva `loadIncludeFile()` para casos especiales que **realmente** necesiten cargar el fichero en runtime (carga condicional según usuario/empresa, scripts descargados dinámicamente, parches en caliente, etc.).

#### Forma preferida: declarar en el nodo `<app>` (estática)

```xml
<app default-language="javascript" ...>
    <!-- functions.js se carga automáticamente, no hace falta declararlo -->

    <!-- Forma <include>: encoding por defecto ISO-8859-1 -->
    <include file="scripts/utils.js" />
    <include url="scripts/api.js" encoding="UTF-8" />

    <!-- Forma <script> (alias estilo HTML): encoding por defecto UTF-8 -->
    <script src="scripts/auth.js" />
</app>
```

**Atributos comunes a `<include>` y `<script>`:**

| Atributo | Alias | Obligatorio | Default | Descripción |
|---|---|---|---|---|
| `file` | `url`, `src` | sí | — | Ruta del fichero |
| `language` | — | no | `default-language` del `<app>` | `"javascript"` o `"vbscript"` |
| `encoding` | `charset` | no | `ISO-8859-1` en `<include>` · `UTF-8` en `<script>` | Codificación del fichero |
| `delay-compilation` | — | no | `false` | Difiere la compilación hasta el primer uso |
| `compile` | — | no | `true` | Si `false`, registra el fichero pero no lo compila |

#### Forma dinámica: `appData.loadIncludeFile()` (solo casos especiales)

```javascript
appData.loadIncludeFile(fileName [, scriptLanguage] [, encoding] [, delayCompilation] [, compile]);
```

| # | Nombre | Obligatorio | Valor por defecto | Descripción |
|---|---|---|---|---|
| 1 | `fileName` | sí | — | Ruta del fichero igual que en el nodo XML `<include>` |
| 2 | `scriptLanguage` | no | `default-language` del nodo `<app>` | `"javascript"` o `"vbscript"` |
| 3 | `encoding` | no | `"ISO-8859-1"` | Codificación del fichero. **Atención: el default NO es UTF-8** |
| 4 | `delayCompilation` | no | `false` | Si `true`, difiere la compilación hasta el primer uso |
| 5 | `compile` | no | `true` | Si `false`, registra el fichero pero no lo compila |

```javascript
// Carga simple (asume default-language=javascript y encoding ISO-8859-1)
appData.loadIncludeFile("scripts/miModulo.js");

// Recomendado si el script tiene tildes/ñ guardadas como UTF-8
appData.loadIncludeFile("scripts/miModulo.js", "javascript", "UTF-8");
```

**Advertencia sobre el encoding:** el valor por defecto es `ISO-8859-1`, no UTF-8. Si tu script contiene caracteres no-ASCII (tildes, ñ, símbolos) y está guardado como UTF-8, **se romperán** salvo que pases `"UTF-8"` explícitamente como tercer parámetro.

Llamadas posteriores al mismo fichero **no recompilan**: el motor reutiliza el bytecode ya cargado.

### 4.12 Carga dinámica de CSS (`loadCssFile` / `unloadCssFile`) y declaración preferida

> **Regla general:** declara las hojas de estilo en el nodo `<app>` siempre que puedas. Reserva `loadCssFile()` / `unloadCssFile()` para casos especiales (cambio de tema por usuario, modo oscuro/claro en runtime, A/B testing visual, etc.).

#### Forma preferida: declarar en el nodo `<app>` (estática)

```xml
<app ...>
    <style url="estilos.css" />
    <style url="temas/oscuro.css" encoding="UTF-8" conditions="##DEVICE_OS##='android'" strict-mode="true" />
</app>
```

**Atributos del nodo `<style>`:**

| Atributo | Obligatorio | Default | Descripción |
|---|---|---|---|
| `url` | sí | — | Ruta del fichero CSS |
| `encoding` | no | (depende del fichero) | Codificación del fichero |
| `conditions` | no | (sin condición) | Condición de carga evaluada al iniciar (p. ej. macros globales) |
| `strict-mode` | no | `false` | Si `true`, exige CSS bien formado (avisa de errores como falta de `;`). En modo estricto hay que escapar `:` en valores: `title:Hola\:Mundo;` |

#### Forma dinámica: `appData.loadCssFile()` / `appData.unloadCssFile()` (solo casos especiales)

**Firmas:**

```javascript
// Forma 1: argumentos posicionales
appData.loadCssFile(name [, encoding] [, conditions] [, strictMode]);

// Forma 2: objeto literal
appData.loadCssFile({ name: "...", encoding: "...", conditions: "...", strictMode: false });

// Descarga (un único argumento)
appData.unloadCssFile(name);
```

**Parámetros de `loadCssFile`:**

| # / clave | Obligatorio | Valor por defecto | Descripción |
|---|---|---|---|
| `name` | sí | — | Ruta del fichero CSS |
| `encoding` | no | `"UTF-8"` | Codificación del fichero (¡distinto de `loadIncludeFile`!) |
| `conditions` | no | (sin condición) | Condición de carga |
| `strictMode` | no | `false` | Modo estricto de parseo |

**Ejemplo (cambio de tema en runtime):**

```javascript
function aplicarTemaOscuro() {
    appData.unloadCssFile("temas/claro.css");
    appData.loadCssFile("temas/oscuro.css", "UTF-8");
    // El framework limpia caches de propiedades y refresca la cascada
}
```

`loadCssFile()` y `unloadCssFile()` invalidan automáticamente los caches internos de propiedades visuales (`ClearCollPropValueCaches()`), por lo que los cambios se reflejan en los siguientes renders sin reiniciar la app.

**Diferencia de encoding por defecto:**

| Método | Default encoding |
|---|---|
| `appData.loadCssFile()` | `"UTF-8"` |
| `appData.loadIncludeFile()` | `"ISO-8859-1"` |
| `<style>` en `<app>` | depende del fichero |
| `<include>` en `<app>` | `"ISO-8859-1"` |
| `<script>` en `<app>` | `"UTF-8"` |

---

## 5. Objeto Global `$http` - Peticiones HTTP

`$http` es el cliente HTTP de XOne. Todos los métodos devuelven un `Future` que permite lanzar peticiones en paralelo. Los callbacks son opcionales.

### 5.1 Estructura del objeto request

```javascript
let request = {
    headers: {
        "Content-Type" : "application/json",
        "Authorization": "Bearer " + token,
        "Accept-Encoding": "br"          // Para Brotli
    },
    parameters: {
        connectTimeout         : 120000, // ms espera conexión
        readTimeout            : 120000, // ms espera respuesta
        allowUnsafeCertificates: false,  // true = acepta certs autofirmados (solo dev)
        allowedRootCas         : ["mi_ca.crt"],  // CA propia en carpeta de la app
        enablePinning          : true,   // Certificate pinning
    },
    // En GET: se añaden como ?clave=valor en la URL
    // En POST/PUT/PATCH/DELETE: van como body JSON
    // Puede ser objeto JS o string (para XML, etc.)
    data: { campo1: "valor1", campo2: "valor2" },
    // Certificado de cliente (mutual TLS)
    privateKey      : authenticationKey,        // Obtenido con KeyStore
    certificateChain: certificateChain,         // Obtenido con KeyStore
    // Volcar cadena de certificacion del servidor (solo depuracion)
    dumpCertificateChainPath: "/sdcard/Download/"
};
```

#### Caché de disco para offline (`cacheData`)

Opt-in por petición: guarda en disco la última respuesta exitosa y, si una petición posterior **falla por error de conexión o por un 5xx del servidor**, sirve esa respuesta cacheada de forma transparente para que la app siga funcionando offline. Los 4xx se tratan como respuesta real y van por el flujo de error normal. Aplica a `get`, `post`, `put`, `delete`, `patch` y `request`.

```javascript
$http.post("https://api.ejemplo.com/datos", {
        data       : { id: 1 },
        cacheData  : true,      // activa la caché de disco para esta petición
        cacheTTL   : 3600,      // opcional: segundos de validez (sin él o <=0 = no caduca)
        cacheSetting: {         // opcional: ajustes finos de la clave de caché
            // Campos del body (rutas con punto) que se excluyen de la clave para que dos
            // llamadas que solo difieren en ellos compartan entrada. Si se pasa, REEMPLAZA
            // por completo a los defaults ["transacid", "data.headers"].
            ignoreBodyFields: ["transacid", "data.headers", "miCampoVolatil"]
        }
    },
    function(sData, headers, statusCode, fromCache, fromCacheDate) {
        // fromCache === true  -> sData viene de la caché offline
        // fromCacheDate       -> Date de la última respuesta exitosa (solo si fromCache es true)
        if (fromCache) {
            ui.showToast("Mostrando datos offline de " + fromCacheDate);
        }
        let json = JSON.parse(sData);
    },
    function(nError, sErrorDesc) {
        // Solo se llama si NO hay entrada válida en caché
    }
);
```

Notas:
- El callback de éxito recibe dos parámetros extra al final, `fromCache` (booleano) y `fromCacheDate` (Date). En un éxito de red normal `fromCache` es `false` y `fromCacheDate` viene `undefined`. Los callbacks que no los declaran los ignoran sin problema.
- Solo se cachean respuestas de datos (JSON/texto). Las descargas de fichero no se cachean.
- Sin `cacheData`, el comportamiento es exactamente el de siempre: no se escribe ni se lee nada.

### 5.2 GET

```javascript
let miObjeto = self;  // Guardar contexto ANTES del callback asincrono

$http.get("https://api.ejemplo.com/datos", {
        parameters: { connectTimeout: 120000, readTimeout: 120000 },
        data: { pagina: 1, limite: 50 }  // Se añaden como query string
    },
    function(sData, responseHeaders, nHttpStatusCode) {
        let json = JSON.parse(sData);
        miObjeto.MAP_RESULTADO = json.total;
        ui.refreshValue("MAP_RESULTADO");
    },
    function(nError, sErrorDesc) {
        ui.showToast("Error " + nError + ": " + sErrorDesc);
    }
);

// GET con lectura de cabeceras de respuesta
$http.get("https://api.ejemplo.com", request,
    function(sData, responseHeaders) {
        let contentType = responseHeaders["Content-Type"];
        let fecha = new Date(responseHeaders.Date).getDate();
    },
    function(nError, sErrorDesc) {}
);
```

### 5.3 POST

```javascript
// POST con body JSON
ui.showWaitDialog("Enviando...");
$http.post("https://api.ejemplo.com/usuarios", {
        headers   : { "Content-Type": "application/json" },
        parameters: { connectTimeout: 120000, readTimeout: 120000 },
        data      : { nombre: "Juan", activo: true }
    },
    function(sData, headers, nHttpStatusCode) {
        let resultado = JSON.parse(sData);
        ui.hideWaitDialog();
        ui.showToast("Creado con ID: " + resultado.id);
    },
    function(nError, sErrorDesc) {
        ui.hideWaitDialog();
        ui.showToast("Error: " + sErrorDesc);
    }
);

// POST con body XML (data como string)
$http.post("https://api.ejemplo.com/xml", {
        headers: { "Content-Type": "application/xml" },
        data   : "<nota><de>Juan</de><para>Pedro</para></nota>"
    },
    function(sData) {},
    function(nError, sErrorDesc) {}
);
```

### 5.4 PUT / DELETE / PATCH

```javascript
let request = {
    headers   : { "Content-Type": "application/json" },
    parameters: { connectTimeout: 120000, readTimeout: 120000 },
    data      : { campo: "valor" }
};

$http.put("https://api.ejemplo.com/recurso/1",    request, successCb, errorCb);
$http.delete("https://api.ejemplo.com/recurso/1", request, successCb, errorCb);
$http.patch("https://api.ejemplo.com/recurso/1",  request, successCb, errorCb);
```

### 5.5 Descarga de fichero

```javascript
$http.download("https://ejemplo.com/documento.pdf", {},
    function(sPath, headers, nHttpStatusCode) {
        // sPath: ruta local donde se guardo el fichero descargado
        ui.openFile(sPath);
    },
    function(nError, sMessage) {
        ui.showToast("Error en descarga: " + sMessage);
    }
);
```

### 5.6 Futures — llamadas en paralelo

Un `Future` es el objeto que devuelve cualquier método `$http`. Permite lanzar varias llamadas a la vez y recoger los resultados cuando todas terminen.

- **`future.getResult()`** — devuelve el cuerpo como **string**
- **`future.get()`** — devuelve el cuerpo **parseado a objeto JS** si es posible. **Preferible**
- **`future.cancel()`** — cancela la peticion

```javascript
// Lanzar tres peticiones en paralelo
let future1 = $http.get("https://api.ejemplo.com/datos1", { data: { id: 1 } });
let future2 = $http.get("https://api.ejemplo.com/datos2", { data: { id: 2 } });
let future3 = $http.get("https://api.ejemplo.com/datos3", { data: { id: 3 } });

// getResult() bloquea hasta que cada peticion termina
let sValor1 = future1.getResult();  // string
let oValor2 = future2.get();        // objeto JS parseado (preferible)
let oValor3 = future3.get();

// Futures con callbacks (se ejecutan al terminar) y recogida posterior
let f1 = $http.get(url1, {},
    function(sData) { ui.showToast("OK #1"); },
    function(nErr, sDesc) { ui.showToast("Error #1"); }
);
let f2 = $http.get(url2, {},
    function(sData) { ui.showToast("OK #2"); },
    function(nErr, sDesc) { ui.showToast("Error #2"); }
);
// Esperar a que ambas terminen
let r1 = f1.getResult();
let r2 = f2.getResult();
```

### 5.7 Cancelar request

```javascript
let future = $http.post("https://api.ejemplo.com/lenta", {},
    function(sData) {},
    function(nError, sErrorDesc) { /* se llama con error de cancelacion */ }
);
future.cancel();

// Patron: cancelar peticion anterior antes de lanzar nueva
var requestActual = null;
function buscarEnAPI(termino) {
    if (requestActual) requestActual.cancel();
    requestActual = $http.get(url + "?q=" + termino, {},
        function(sData) { requestActual = null; procesarResultados(sData); },
        function(nError, sDesc) { requestActual = null; }
    );
}
```

### 5.8 Seguridad SSL/TLS

```javascript
// Certificados autofirmados — SOLO desarrollo, nunca produccion
let request = {
    parameters: { allowUnsafeCertificates: true, connectTimeout: 120000, readTimeout: 120000 }
};

// CA propia con certificate pinning
// El fichero .crt debe estar en la carpeta de la app
let request = {
    parameters: {
        allowedRootCas: ["mi_ca_root.crt"],
        enablePinning : true,
        connectTimeout: 120000, readTimeout: 120000
    }
};

// Mutual TLS con certificado de cliente
// Soporta: pkcs12 (recomendado), bks, jks
ui.showWaitDialog("Conectando...");
try {
    let keyStore = new KeyStore();
    keyStore.open({ file: "cert_cliente.p12", type: "pkcs12", password: "" });
    let request = {
        headers         : { "Content-Type": "application/json" },
        parameters      : { connectTimeout: 120000, readTimeout: 120000 },
        data            : { campo: "valor" },
        privateKey      : keyStore.getKey("alias"),
        certificateChain: keyStore.getCertificateChain("alias")
    };
    $http.post("https://servidor-mutual-tls.com", request,
        function(sData) { ui.hideWaitDialog(); },
        function(nCode, sError) { ui.hideWaitDialog(); }
    );
} catch(ex) {
    ui.hideWaitDialog();
    throw ex;
}

// Volcar cadena de certificacion para depuracion
$http.get("https://servidor.com", {
    parameters: { connectTimeout: 120000, readTimeout: 120000 },
    dumpCertificateChainPath: "/sdcard/Download/"
}, function(sData) {
    ui.showToast("Certificados guardados en /sdcard/Download/");
}, function(nError, sErrorDesc) {});
```

### 5.9 Proxy

Configura un proxy global para toda la app, incluyendo XOneLive y el replicador.

```javascript
// Establecer proxy
$http.setProxy({
    host: "192.168.1.100",
    port: 8080,
    type: "http"  // "http" o "socks"
    // enabledHosts: ["api.ejemplo.com"]
    // skipHosts   : ["interno.ejemplo.com"]
});

// Eliminar proxy
$http.setProxy(null);
```

### 5.10 Cleartext HTTP

Por defecto Android solo permite HTTPS. Para saber si HTTP sin cifrar esta permitido:

```javascript
let bPermitido = systemSettings.isClearTextTrafficAllowed();
```

### 5.11 WebSocket

```javascript
let ws;
let dataObject = self;  // Guardar referencia ANTES de los callbacks

function conectarWebSocket() {
    let opciones = {
        url        : "wss://servidor.ejemplo.com/canal",
        // protocol: "mi_protocolo",
        // certificate: "servidor.crt",
        // verifyWithSystemTrustManagers: true,
        onOpen: function() {
            ui.showToast("Conectado");
            ws.send(JSON.stringify({ command: "login", user: "usuario" }));
        },
        onMessage: function(sData) {
            dataObject.MAP_CHAT = dataObject.MAP_CHAT + sData + "\n";
            ui.refreshValue("MAP_CHAT");
        },
        onError: function(error) {
            ui.showToast("Error: " + error.message);
            ws = null;
        },
        onClose: function() {
            ui.showToast("Conexión cerrada");
            ws = null;
        }
    };
    if (ws) { ws.close(); ws = null; }
    ws = new WebSocket(opciones);
}

function enviarMensaje(sTexto) {
    if (!ws) throw "Conecte el WebSocket primero";
    ws.send(JSON.stringify(sTexto));
}

function cerrarWebSocket() {
    if (ws) { ws.close(); ws = null; }
}
```

> **Nota**: Guardar `self` en una variable local (`dataObject`) antes de los callbacks. Dentro de `onMessage` y `onOpen`, `self` puede no estar disponible.

### 5.12 loadFromJson / toJson

```javascript
// Cargar datos en un OBJETO individual desde string JSON
let obj = new Productos();
obj.loadFromJson('{"ID": 1, "NOMBRE": "Tornillo", "PRECIO": 0.15}');

// Cargar datos en una COLECCION desde array JSON
let coll = appData.getCollection("Productos");
coll.loadFromJson('[{"ID": 1, "NOMBRE": "Tornillo"}, {"ID": 2, "NOMBRE": "Tuerca"}]');
let nTotal = coll.getCount();  // 2

// Serializar coleccion a array JS nativo
let jsArray = coll.toJson();
let sJson   = JSON.stringify(jsArray, null, 4);

// Serializar objeto individual
let jsObj  = obj.toJson();
let sObjJs = obj.toJsonString();

// Caso de uso tipico: recibir de API y cargar en coleccion
$http.get("https://api.ejemplo.com/productos", {},
    function(sData) {
        let coll = appData.getCollection("Productos");
        coll.loadFromJson(sData);
    },
    function(nError, sErrorDesc) {}
);
```

---

## 6. OAuth2 - Autenticación OAuth

### 6.1 Autenticación OAuth2

```javascript
function doAuthLogin() {
    let strAuthorityUrl  = "https://auth.miservidor.com/identity";
    let strClientID      = "mi_client_id";
    let strClientSecret  = "mi_client_secret";
    let strPersistenceKey = "oauth_key";
    let strRedirectUri   = "com.miapp.oauth:/callback";

    new OAuth2().withOptions({
        authority     : strAuthorityUrl,
        clientID      : strClientID,
        clientSecret  : strClientSecret,
        scope         : "openid profile",
        responseType  : "code id_token",
        persistenceKey: strPersistenceKey,
        redirectUri   : strRedirectUri
    }).authenticate({
        onSuccess: function(result) {
            console.log("OAuth2 login exitoso");
            console.log(result);
            appData.setGlobalMacro("##OAUTH_TOKEN##", result.access_token);
        },
        onError: function(err) {
            console.log("OAuth2 error: " + err);
            ui.showToast("Error de autenticación");
        }
    });
}
```

### 6.2 OAuth2 Logout

```javascript
function doAuthLogout() {
    new OAuth2().withOptions({
        authority     : "https://auth.miservidor.com/identity",
        clientID      : "mi_client_id",
        clientSecret  : "mi_client_secret",
        scope         : "openid profile",
        persistenceKey: "oauth_key",
        responseType  : "code id_token",
        redirectUri   : "com.miapp.oauth:/callback"
    }).logout();
}
```

### 6.3 Configuración Completa

| Parámetro | Tipo | Descripción |
|-----------|------|-------------|
| `authority` | String | URL del servidor de autorización |
| `clientID` | String | ID del cliente OAuth2 |
| `clientSecret` | String | Secreto del cliente |
| `scope` | String | Ambitos solicitados ("openid profile") |
| `responseType` | String | Tipo de respuesta ("code id_token") |
| `persistenceKey` | String | Clave para persistir la sesión |
| `redirectUri` | String | URI de redirección (esquema de URL de la app) |

---

## 7. Objeto `replica` - Sincronización

El objeto global `replica` gestiona la replicación/sincronización de datos y ficheros entre el dispositivo y el servidor central. También permite imponer restricciones de replica (p.ej. solo wifi) y consultar el estado.

**Catálogo completo de métodos:**

| Método | Descripción |
| --- | --- |
| **start** | Iniciar el servicio de réplica. |
| **stop** | Detener la réplica. |
| **processReplicatorQueue** | Procesar cola pendiente del replicador. Acepta tres formas de argumento (NO un callback): el `LiveSecureProvisioningResponse` recibido en el evento `live`, un `string` con el nombre de la app (resuelve `gestion.db` automáticamente), o un `{databasePath, appName, taskId}`. Devuelve `boolean` (true = cola vacía / éxito). |
| **getLog** | Obtener log de la réplica. |
| **getDatabaseId** | Obtener ID de la base de datos. |
| **getHostname** | Obtener nombre de host del servidor. |
| **getLicense** | Obtener licencia. |
| **getMid** | Obtener MID (identificador del dispositivo). |
| **getRecordsPend** | Obtener registros pendientes de enviar. |
| **getRecordsRX** | Obtener registros RX (recibidos en la sesión actual). |
| **getRecordsTX** | Obtener registros TX (enviados en la sesión actual). |
| **getTotalRecordsRX** | Total registros RX desde el inicio. |
| **getTotalRecordsTX** | Total registros TX desde el inicio. |
| **setRestriction** | Ajustar una restricción de réplica (p.ej. solo wifi). |
| **clearRestrictions** | Quitar las restricciones actuales. |
| **clearAllRestrictions** | Quitar todas las restricciones. |

### 7.1 replica.processReplicatorQueue(arg)

El argumento NO es un callback. Es uno de:
- el objeto `LiveSecureProvisioningResponse` recibido en el evento `live` (forma típica);
- un `string` con el nombre de la app (resuelve internamente `gestion.db`);
- un objeto `{databasePath, appName, taskId}` con los tres datos manuales.

Devuelve `boolean` sincronamente. NO recibe función de progreso (cualquier callback se ignora silenciosamente).

```javascript
// Forma típica: usar el objeto recibido en el evento live
function sincronizar(liveResponse) {
    let bResult = replica.processReplicatorQueue(liveResponse);
    if (bResult) {
        ui.showToast("Sincronización completada");
    } else {
        ui.showToast("Error en sincronización");
    }
}

// Forma alternativa: solo nombre de app
let bResult = replica.processReplicatorQueue("MiApp");

replica.start();

if (appData.isReplicating()) {
    ui.showToast("Sincronización en curso...");
}
```

### 7.2 Flujo de Replica con sys-message

```javascript
// Funcion llamada por el evento sys-message de la coleccion Empresas
function sysMessage(codigo, message) {
    switch(codigo) {
        case 1000:
            // Actualización descargándose
            break;
        case 1001:
            // Actualización aplicada
            break;
        case 1002:
            // Todas las actualizaciones aplicadas
            break;
        case 1003:
            // Provisionamiento seguro: replicar y cerrar
            ui.msgBox("Se va a actualizar la BD. Se replicaran datos y cerrara la app.", "Mensaje", 0);
            let bResult = replica.processReplicatorQueue(message);   // 'message' es el liveResponse del sys-message
            if (bResult) {
                appData.exit();
            } else {
                ui.showToast("Error al procesar cola de salida. Reintente.");
            }
            break;
    }
}
```

---

**Anterior:** [03b - Objeto ui](03b-js-ui.md) · **Siguiente:** [03d - createObject (objetos complementarios)](03d-js-createobject.md) · **Índice:** [03 - Guía JavaScript](03-javascript-api-guide.md)
