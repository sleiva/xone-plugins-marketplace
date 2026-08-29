# Referencia de Objetos JavaScript en XOne

Documentación completa de los objetos globales, coleccion actual, objeto de error, objetos creables con `new` y singletons globales del framework XOne Android.

> **Nota:** Los ejemplos usan JavaScript. VBScript esta descontinuado — usar siempre JavaScript (`<script language="javascript">`).

---

## Tabla de Contenidos

1. [Objetos Globales — Resumen](#1-objetos-globales--resumen)
2. [selfDataColl / datacollection — Coleccion Actual](#2-selfdatacoll--datacollection--coleccion-actual)
3. [err / error — Objeto de Error Global](#3-err--error--objeto-de-error-global)
4. [user — Usuario Logueado](#4-user--usuario-logueado)
5. [Objetos Creables con `new` o `createObject()`](#5-objetos-creables-con-new-o-createobject)
   - [FileManager — Gestion de ficheros](#51-filemanager)
   - [GpsTools — Utilidades GPS](#52-gpstools)
   - [SqlManager — SQLite a bajo nivel](#53-sqlmanager)
   - [IniParser — Ficheros INI](#54-iniparser)
   - [EncodingUtils — Base64](#55-encodingutils)
   - [AndroidIntent — Intents Android](#56-androidintent)
   - [DeviceManager — MDM](#57-devicemanager)
   - [WifiManager — WiFi](#58-wifimanager)
   - [BluetoothSerialPort — BT serie](#59-bluetoothserialport)
   - [OAuth2 — Autenticación OAuth2](#510-oauth2)
   - [Worker — Workers en hilo aparte](#511-worker)
   - [Animation — Animaciones programaticas](#512-animation)
   - [Socket / WebSocket — TCP/IP y WebSocket](#513-socket--websocket)
   - [DebugTools — Depuracion remota](#514-debugtools)
   - [IrManager — Infrarrojos](#515-irmanager)
   - [SoundManager — Audio](#516-soundmanager)
   - [VibrationManager — Vibracion](#517-vibrationmanager)
   - [WearableConnection — Wear OS](#518-wearableconnection)
   - [AccountManager — Cuentas Android](#519-accountmanager)
   - [XOneNFC — NFC](#520-xonenfc)
   - [ImageDrawing — Imágenes programaticas](#521-imagedrawing)
   - [BarcodeGenerator — Códigos de barras](#522-barcodegenerator)
   - [XOnePrinter — Impresion](#523-xoneprinter)
   - [XOnePDF — Generación de PDFs](#524-xonepdf)
   - [XOneOCR — Reconocimiento de texto](#525-xoneocr)
   - [XOneSigner — Firma digital de documentos](#526-xonesigner)
   - [Lista completa de creables](#527-lista-completa-de-creables)
6. [Singletons Globales (sin `new`, acceso directo)](#6-singletons-globales)

---

## 1. Objetos Globales — Resumen

Los siguientes objetos se inyectan automáticamente en cada script de XOne:

| Nombre global | Alias | Que representa |
|---|---|---|
| `self` | `dataobject` | El objeto/registro actual sobre el que se ejecuta el script. API completa en tópico 03 sección 2. |
| `selfDataColl` | `datacollection` | La coleccion actual. API completa en §2 de este tópico. |
| `appData` | `appdata` | La aplicación (raiz). API en tópico 03 sección 4. |
| `user` | — | El usuario logueado. Hereda toda la API de `self`. Ver §4. |
| `err` | `error` | El último error producido por el framework. Ver §3. |
| `ui` | — | La interfaz de usuario y servicios del dispositivo. API en tópico 03 sección 3. |

> **Regla de nomenclatura:** Los alias (`dataobject`, `datacollection`, `appdata`, `error`) son equivalentes a los nombres principales. En JavaScript se recomienda usar los nombres principales (`self`, `selfDataColl`, `appData`, `err`).

---

## 2. selfDataColl / datacollection — Coleccion Actual

`selfDataColl` representa la coleccion sobre la que se ejecuta el script actual. Es el equivalente al concepto de "tabla" o "resultado de consulta" en memoria.

### 2.1 Información básica

| Método | Descripción |
|---|---|
| `getName()` / `name()` → `String` | Nombre de la coleccion (el atributo `name` del `<coll>`). |
| `getOwnerApp()` → `appData` | App propietaria. |
| `getOwnerObject()` / `ownerObject()` → `dataobject` | Objeto contenedor (en colecciones anidadas / contents). |
| `getCount()` / `count()` → `int` | Total de objetos cargados en memoria. |
| `isEmpty()` → `boolean` | Atajo equivalente a `getCount() == 0`. |
| `browseLength()` → `long` | Cantidad de filas del recorrido browse. **Solo devuelve un valor útil tras `startBrowse(true)`**; con `startBrowse()` por defecto devuelve `-1`. |
| `stringKey()` → `boolean` | `true` si la PK es de tipo texto. |
| `getMultipleKey()` → `boolean` | `true` si la PK es múltiple (varios campos clave). |
| `getCurrentItem()` → `dataobject` | Objeto actual del cursor browse. **El objeto devuelto es efímero**: su contenido se reemplaza con cada `moveNext()`. No guardar la referencia para usarla después; leer o copiar los campos dentro de la iteración. |
| `getIdFieldName()` → `String` | Nombre del campo PK de la coleccion. |
| `isFull()` → `boolean` | `true` si todos los registros están cargados en memoria. |
| `isLocked()` → `boolean` | `true` si la coleccion esta bloqueada (`lock()`). |
| `isBrowsing()` → `boolean` | `true` si hay un cursor browse activo. |
| `getXmlNode()` → `XmlNode` | Nodo XML que define la coleccion (acceso a metadatos del modelo). |
| `getConnection()` / `getDataConnector()` → `Connection` | Conexión de base de datos usada. |
| `getAccessString()` → `String` | SQL/objeto de acceso declarado en la coll. |
| `getDevelopedAccessString()` → `String` | SQL con macros expandidas. |
| `getDevelopedFilter()` → `String` | Filtro activo con macros expandidas. |
| `getDevelopedLinkFilter()` → `String` | Linkfilter con macros expandidas. |

### 2.2 Acceso a objetos

| Método | Descripción |
|---|---|
| `get(index)` / `getObject(index)` / `getItem(index)` → `dataobject` | Obtiene el objeto por índice (base 0). |
| `get(key)` / `getObject(key)` / `getItem(key)` → `dataobject` | Obtiene el objeto por valor de PK (clave). |
| `getItem(field, value)` → `dataobject` | Busca por par campo/valor (primero en memoria, luego en BD). Equivalente a `getObject(field, value)`. |
| `findObject(criteria)` → `dataobject` | Busca el primer objeto que cumple una cláusula WHERE SQL (p.ej. `"LOGIN='admin'"` o `"ID=5 AND ACTIVO=1"`). Lanza la búsqueda contra BD. |
| `findAllObjects(criteria)` → `Object[]` | Igual que `findObject` pero devuelve todas las coincidencias. |
| `getObjectIndex(item)` → `int` | Índice del objeto dentro de la coleccion. |
| `swapItems(a, b)` | Intercambia dos objetos de posición. Cada argumento puede ser índice, clave PK o `dataobject`. Si alguno no se encuentra en la coll, no hace nada. |

### 2.3 Crear, anadir, borrar

| Método | Descripción |
|---|---|
| `createObject(...)` → `dataobject` | Crea un nuevo objeto (no guardado en BD) (legacy; el patrón preferido es `new NombreColeccion({...})`). |
| `createClone()` → `datacollection` | Clona la coleccion (útil para filtrar sin afectar la original). |
| `addItem(item)` / `addItem(index, item)` → `boolean` | Anade un objeto a la lista en memoria. Con 2 params, el **índice va primero** y el item segundo. Si `index == -1` se añade al final. |
| `removeItem(idx \| key \| dataobject)` → `boolean` | Elimina un objeto **solo de la lista en memoria**. **NO** lo borra en BD. |
| `deleteItem(idx \| key \| dataobject)` → `boolean` | Elimina un objeto de la lista **Y de la base de datos**. |
| `clear()` → `boolean` | Vacia la coleccion en memoria. Si la coll está bloqueada con `lock()`, no hace nada. |
| `deleteAll()` → `boolean` | Borra todos los objetos en BD. |
| `browseDeleteAll()` → `boolean` | Borra todos recorriendo (lanza eventos por objeto). |
| `browseDeleteWithNoRules()` → `boolean` | Borra todos sin lanzar eventos. |
| `loadAll()` → `boolean` | Carga todos los registros en memoria. Usar con precaucion en datasets grandes. |
| `saveAll()` → `boolean` | Guarda todos los objetos modificados. |

### 2.4 Browse (cursor de navegación)

El browse es el patron correcto para recorrer grandes colecciones sin cargarlas todas en memoria.

| Método | Descripción |
|---|---|
| `startBrowse(...)` → `boolean` | Inicia el cursor browse. |
| `endBrowse()` → `boolean` | Finaliza el cursor. **Siempre en bloque `finally`**. |
| `moveFirst()` → `boolean` | Mueve al primer item. |
| `moveLast()` → `boolean` | Mueve al último item. |
| `moveNext()` → `boolean` | Avanza al siguiente item. Devuelve `false` al llegar al final. |
| `movePrevious()` → `boolean` | Retrocede al item anterior. |
| `lock()` / `unlock()` | Bloquea/desbloquea la coll. La coll nace **desbloqueada**. Estando bloqueada, `clear()` y `loadAll()` no hacen nada — útil para "congelar" el contenido de la coll mientras se opera sobre ella. `isLocked()` devuelve el estado actual. |

```js
// Patron correcto: startBrowse posiciona en el primer item; iterar con getCurrentItem+moveNext;
// siempre endBrowse() en finally.
var coll = appData.getCollection("Pedidos");
coll.setFilter("estado = 'pendiente'");
coll.startBrowse();
try {
    var item = coll.getCurrentItem();
    while (item != null) {
        item.setValue("revisado", 1);
        item.save();
        if (!coll.moveNext()) break;
        item = coll.getCurrentItem();
    }
} finally {
    coll.endBrowse();
}
```

### 2.5 Filtros y orden

| Método | Descripción |
|---|---|
| `getFilter()` → `String` | Filtro SQL activo. |
| `setFilter(value)` | Cambia el filtro SQL. |
| `getLinkFilter()` → `String` | Linkfilter activo. |
| `setLinkFilter(value)` | Cambia el linkfilter. |
| `getSort()` → `String` | Orden activo. |
| `setSort(value)` | Cambia el orden. |
| `doSort(expr?)` | Reordena los objetos **en memoria**. Acepta una expresión SQL-like (`"CAMPO asc, CAMPO2 desc"`); sin argumento usa el sort actual de la coll. |
| `reload(xmlNode, [forced])` → `boolean` | **NO recarga datos.** Recarga la **definición XML** de la coll en runtime. Requiere un nodo XML obligatorio; sin él falla. Para recargar los datos con el filtro actual usar `clear()`+`loadAll()` o un nuevo `startBrowse()`. |
| `rebuildLayout(...)` | Reconstruye el layout de propiedades visibles. |

### 2.6 Busqueda full-text

| Método | Descripción |
|---|---|
| `createSearchIndex(field/fields[]/table+fields[])` | Crea índice FTS para busqueda rápida. |
| `createPersistData(fields.../table+fields...)` | Crea tabla persistente de busqueda. |
| `doSearch(criteria)` / `doSearch(table, criteria)` | Ejecuta la busqueda full-text. |
| `generateRowId()` → `String` | Genera un nuevo ROWID (GUID) valido para un nuevo objeto. |

### 2.7 Macros y variables de coleccion

| Método | Descripción |
|---|---|
| `getMacro(name)` / `getMacro(index)` → `String` | Lee el valor de una macro. Acepta nombre (`"##X##"`) o índice numérico. |
| `setMacro(name, value)` / `setMacro(index, value)` | Asigna una macro. Igual: por nombre o por índice. |
| `getMacroCount()` → `int` | Número de macros declaradas. |
| `getAllMacros()` → `Map<String,Object>` | Todas las macros como mapa. |
| `getVariable(name)` → `Object` | Lee variable de scope (en memoria, no se persiste). |
| `setVariable(name, value)` | Asigna variable de scope. |
| `getVariables(name)` / `setVariables(name, value)` | **Obsoletos.** Alias de `getVariable`/`setVariable`; usar las formas en singular. |
| `getAllVariables()` → `Map<String,Object>` | Todas las variables. |

> **Importante:** Para usar `setMacro` hay que declarar previamente el nodo `<macro name="##X##" value="" default="true" />` como hijo directo de `<coll>`.

### 2.8 Metadatos y propiedades

| Método | Descripción |
|---|---|
| `getCollPropertyValue(attr)` → `String` | Lee un atributo XML del nodo `<coll>` (p.ej. `"sql"`, `"loadall"`). |
| `getGroupCount()` → `int` | Número de grupos. |
| `getGroup(index)` → `String` | Nombre del grupo por índice. |
| `getPropertyCount()` → `int` | Número de propiedades. |
| `getPropertyName(index)` / `propertyName(index)` → `String` | Nombre del campo por índice. |
| `getPropType(name)` / `propType(name)` → `String` | Tipo del campo (`T`, `TL`, `N`, `NC`, `Z`, `D`, etc.). |
| `getPropertyTitle(name)` → `String` | Título visible del campo. |
| `getPropertyGroup(name)` → `String` | Nombre del grupo al que pertenece el campo. |
| `getPropVisibility(name)` / `propVisibility(name)` → `String` | Visibilidad bitmask del campo. |
| `bind(...)` / `unbind(...)` | Vincula/desvincula eventos. |
| `clearCaches()` | Propaga `clearCaches()` a todos los objetos cargados en memoria (vacía la caché de atributos resueltos de cada uno). |

### 2.9 SQL directo y JSON

| Método | Descripción |
|---|---|
| `executeSqlString(sql)` → `Object` | Ejecuta SQL contra la conexión de la coll. **Las macros (`##X##`) se sustituyen automáticamente** en el SQL antes de ejecutarlo. |
| `toJson()` → `Object[]` | Serializa todos los objetos en memoria a un array. |
| `loadFromJson(jsonArray, [{strictMode: true}])` → `datacollection` | Hidrata la coleccion desde un array. **Vacía la coll antes de cargar.** Acepta un array JSON o un string parseable como JSON. Con `strictMode: true` ignora campos no declarados en el mapping. |

```js
// Ejemplo: clonar coleccion para filtrar sin afectar la original
var colOriginal = appData.getCollection("Articulos");
var colFiltrada = colOriginal.createClone();
colFiltrada.setFilter("activo = 1");
colFiltrada.reload();
appData.writeConsoleString("Articulos activos: " + colFiltrada.getCount());
```

---

## 3. err / error — Objeto de Error Global

`err` (alias `error`) es el objeto de error global del framework. Se actualiza automáticamente cuando se produce un error en operaciones de BD, guardado, etc.

| Método | Descripción |
|---|---|
| `getNumber()` → `int` | Código de error. `0` significa sin error. |
| `setNumber(value)` | Asigna un código de error personalizado. |
| `getDescription()` → `String` | Descripción/mensaje del error. |
| `setDescription(value)` | Asigna un mensaje de error personalizado. |
| `getFailedSql()` → `String` | La sentencia SQL que provoco el error (si aplica). |
| `clear()` | Limpia el estado de error (pone número a 0 y descripción a ""). |
| `toString()` → `String` | Serialización legible: `"[código] descripción"`. |

```js
// Patron de verificación de errores tras operación
self.save();
if (err.getNumber() != 0) {
    appData.writeConsoleString("Error " + err.getNumber() + ": " + err.getDescription());
    if (err.getFailedSql()) {
        appData.writeConsoleString("SQL: " + err.getFailedSql());
    }
    err.clear();
}
```

```js
// Usar failWithMessage para lanzar un error controlado
// (detiene la ejecución del flujo y propaga el código y mensaje)
if (!self.getValue("DNI")) {
    appData.failWithMessage(101, "El DNI es obligatorio");
}
```

### 3.1 Excepciones del framework

| Excepción | Causa típica |
|---|---|
| `XoneGenericException` | Error generico del framework. |
| `XoneFailWithMessageException` | Lanzada por `appData.failWithMessage(code, msg)`. |
| `XOneJavascriptException` | Error en el motor JS (sintaxis, variable no definida, etc.). |
| `FormulaParseException` | Error al parsear una formula de atributo XML. |
| `LocationNotFoundException` | No hay fix GPS disponible. |
| `PluginNotInstalledException` | Plugin requerido no esta instalado. |

```js
try {
    self.save();
} catch (e) {
    appData.writeConsoleString("Excepcion: " + e);
    err.setNumber(-1);
    err.setDescription(e.toString());
}
```

---

## 4. user — Usuario Logueado

`user` representa la fila del usuario que ha iniciado sesión. Hereda **toda la API de `self` / `dataobject`**: `getValue`, `setValue`, `save`, `executeNode`, `getOwnerCollection`, etc.

```js
var nombre   = user.getValue("NOMBRE");
var rol      = user.getValue("ROL");
var empresa  = user.getValue("IDEMPRESA");

// user tiene las mismas propiedades que cualquier dataobject
user.setValue("ULTIMO_ACCESO", new Date().toISOString());
user.save();
```

> **Nota:** Si el mapping no tiene coleccion de login configurada, `user` sera `null`. Verificar antes de usar en pantallas de acceso publico.

---

## 5. Objetos Creables con `new` o `createObject()`

XOne expone una serie de objetos que se instancian con `new NombreClase()` (forma preferida e idiomatica en JavaScript) o, alternativamente, con `appData.createObject("NombreClase")`. Ambas formas son equivalentes — `createObject` hace match **case-insensitive** internamente, pero los ejemplos usan PascalCase canonico.

```js
// Forma preferida — new
var fm = new FileManager();

// Alternativa equivalente
var fm = appData.createObject("FileManager");
```

> **IMPORTANTE:** Los objetos `crypto`, `clipboard`, `deviceInfo`, `systemSettings`, `biometricsManager`, `fingerprintManager`, `bleManager`, `sensorManager`, `packageManager`, `paymentManager`, `pushMessage`, `appBroadcastManager`, `$http` y otros **NO** son creables — son **singletons globales** y se acceden directamente por su nombre. Ver §6.

Además de estos objetos del runtime, **todas las colecciones de la aplicación** son creables con `new`: `new NombreColeccion()` crea un objeto nuevo de esa colección, con un parámetro opcional de valores iniciales. Es el patrón preferido para crear dataobjects:

```js
var obj = new Usuarios({ ID: 5, MAP_TITULO: "El titulo" });
// (legacy) Equivale a:
// var obj = appData.getCollection("Usuarios").createObject();
// obj.ID = 5; obj.MAP_TITULO = "El titulo";
```

Excepciones donde se mantiene el patrón clásico: contents anidados (`self.Contents("X").createObject()` vincula la línea al objeto padre; el constructor no) y nombres de colección dinámicos (`appData.getCollection(variable).createObject()`).

---

### 5.1 FileManager

Gestión completa de ficheros y directorios en el dispositivo. Convención: las funciones que retornan `int` siguen estilo C → **`0` = OK / existe**, **`-1` = error / no existe**.

| Método | Descripción |
|---|---|
| `readFile(path, [encoding])` → `String` | Lee texto del fichero (UTF-8 por defecto). |
| `saveFile(path, content, [append], [encoding])` → `boolean` | Escribe / añade contenido (acepta texto o `byte[]`). |
| `fileExists(path)` → `int` | **`0` si existe**, `-1` si no. |
| `directoryExists(path)` → `int` | **`0` si existe**, `-1` si no. |
| `getFileInfo(path)` → `Map` | `{size, creationDate, modificationDate, isHidden, canRead, canWrite, canExecute}`. |
| `getLastModifiedDate(path)` → `Date` | Fecha de última modificación. |
| `getSize(path)` → `long` | Tamaño del fichero o del árbol (si es directorio). |
| `isDirectoryEmpty(path)` → `boolean` | `true` si la carpeta no tiene contenido. |
| `listFiles(path \| {source, fileTypes, orderBy, dateFrom, dateTo})` → `Object[]` | Lista paths de ficheros con filtros opcionales. |
| `listDirectories(path)` → `Object[]` | Lista subdirectorios. |
| `createDirectory(path)` → `int` | `0` OK, `1` ya existe (dir), `2` existe como fichero, `-1` error. |
| `deleteDirectory(path)` → `int` | Borrado recursivo. |
| `copy(src, dst)` / `move(src, dst)` / `rename(src, dst)` → `int` | Operaciones de fichero. |
| `delete(path, ...)` → `int` | Borra uno o varios ficheros. |
| `zip(src, [dst])` → `int` | Comprime fichero o carpeta. |
| `zipAll(target \| {targetZip, password, files}, ...)` → `int` | Zip de múltiples ficheros (con password opcional). |
| `unzip(src, [dstDir], [password])` → `int` | Descomprime ZIP (con password si lo tiene). |
| `toBase64(path)` → `String` | Codifica fichero a Base64. |
| `toFile(base64, path)` → `int` | Decodifica Base64 a fichero. |
| `getChecksum(path, [type], [urlSafe])` → `String` | Tipos: `crc32` (default), `adler32`, `sha1`, `sha2`, `sha256`, `sha512`. |
| `download(url, dest) \| download({source, target, method, headers, parameters, onSuccess, onProgress, onError, ...})` → `int \| Future` | Síncrono (legacy) o asíncrono con Future. |
| `uploadFile({url, file, headers, parameters, onSuccess, onProgress, onError, ...})` → `Object` | Sube fichero multipart. |
| `downloadDatabase(url)` → `int` | Reemplaza atómicamente la BD por la remota. |
| `deleteDatabase(name)` → `int` | Borra `.db`, `.db-wal` y `.db-shm`. |
| `openFile(path)` → `int` | Abre con la app del sistema (ACTION_VIEW). |
| `getRootDirectory()` → `String` | `/data/data/<package>/`. |
| `getCacheDirectory()` → `String` | `/data/data/<package>/cache`. |
| `getCodeCacheDirectory()` → `String` | `/data/data/<package>/code_cache`. |
| `clearCache({maxSize?, olderThan?})` | Limpia caché por tamaño o por fecha. |
| `addOnDirectoryChangedListener(path, cb)` / `removeOnDirectoryChangedListener(path)` | Watcher de cambios (`cb(sEvent, sPath)`). |

Catálogo completo con ejemplos por área (lectura, listado, compresión, descarga/subida, watchers, etc.) en [03d-js-createobject.md §8.1](03d-js-createobject.md#81-filemanager---gestion-de-archivos).

```js
var fm = new FileManager();
var ruta = appData.getFilesPath() + "/backup.txt";
if (fm.fileExists(ruta) === 0) {
    var contenido = fm.readFile(ruta);
    appData.writeConsoleString(contenido);
} else {
    fm.saveFile(ruta, "datos iniciales");
}
```

---

### 5.2 GpsTools

Utilidades de calculo y gestion GPS avanzadas.

| Método | Descripción |
|---|---|
| `startGps(params)` → `boolean` | Inicia la escucha GPS con parámetros de precisión. |
| `stopGps(...)` → `boolean` | Detiene la escucha GPS. |
| `getLastKnownLocation()` → `Map` | Posición actual como mapa `{lat, lng, alt, accuracy, ...}`. |
| `distanceBetweenCoordinates(lat1, lng1, lat2, lng2)` → `double` | Distancia en metros entre dos puntos (4 args posicionales). |
| `distanceTo([{latitude, longitude}, {latitude, longitude}])` → `double` | Distancia en metros entre dos puntos (variante con un array de 2 coordenadas; equivalente a `distanceBetweenCoordinates`). |
| `bearingBetweenCoordinates(lat1, lng1, lat2, lng2)` → `double` | Rumbo (ángulo) entre dos puntos. |
| `simplifyPolyline(points, tolerance)` → `Object[]` | Simplifica una polilinia (algoritmo Douglas-Peucker). |
| `getArea(polygon)` → `double` | Calcula el área de un poligono (en m2). |
| `encode(points)` → `String` | Codifica puntos en formato Polyline encoded (Google). |
| `decode(polyline)` → `Object[]` | Decodifica un Polyline encoded a array de puntos. |
| `containsLocation(point, polygon)` → `boolean` | Comprueba si un punto esta dentro de un poligono. |
| `getAddressFromPosition({latitude, longitude})` → `Map` | Geocoding inverso. Toma **1 NativeObject** o un string `"lat,lng"`, NO dos argumentos posicionales. |
| `getPositionFromAddress(address)` → `Map` | Geocoding directo (dirección a coordenadas). |
| `launchMaps(...)` | Lanza la app de mapas del sistema. |
| `addExifLocationToFile({file, latitude, longitude, date?})` | Anade metadatos EXIF GPS a una imagen. Toma **1 NativeObject**, no `(file, lat, lng)`. |

```js
var gps = new GpsTools();
var dist = gps.distanceBetweenCoordinates(40.416775, -3.703790, 40.453191, -3.688344);
appData.writeConsoleString("Distancia: " + Math.round(dist) + " m");
```

---

### 5.3 SqlManager

Acceso a bases de datos SQLite a bajo nivel, para operaciones que la API de colecciones no cubre.

**Importante**: la mayoría de métodos toman **un único `NativeObject` de configuración** (no argumentos posicionales). Las claves son las que se indican en la columna "Firma".

| Método | Firma |
|---|---|
| `openDatabase({databasePath, enableWal?, readOnly?, createIfNeeded?, noLocalizedCollators?, useExistingConnection?, password?, onDatabaseCorrupted?})` | Abre la BD SQLite. **No** acepta `(path)` posicional. |
| `close()` | Cierra la base de datos. |
| `isOpen()` → `boolean` | `true` si la conexión esta abierta. |
| `doRawQuery(sql, [args])` → `Cursor` | Ejecuta una sentencia SQL (sí acepta argumentos posicionales: SQL + varargs). |
| `doBatchRawQueries(sqls)` / `doBatchParseSqls(sqls)` | Ejecución en lote. |
| `insert({tableName, fields})` → `long` | Inserta una fila. Devuelve el `rowid`. `fields` es un objeto `{col1: val1, col2: val2}`. |
| `update({tableName, fields, whereClause?, whereArguments?})` → `long` | Actualiza filas. |
| `delete({tableName, whereClause?, whereArguments?})` → `long` | Borra filas. |
| `getVersion()` / `setVersion(n)` | PRAGMA user_version. |
| `isReadOnly()` / `isInTransaction()` / `isDatabaseIntegrityOk()` → `boolean` | Estado de la BD. |
| `getAttachedDbs()` → `Object[]` | Lista de BDs adjuntadas (ATTACH). |
| `setLocale(locale)` / `setMaxSqlCacheSize(n)` / `setForeignKeyConstraintsEnabled(bool)` | Configuración. |
| `enableWriteAheadLogging()` / `disableWriteAheadLogging()` / `isWriteAheadLoggingEnabled()` / `doWalCheckpoint()` | Gestión del modo WAL. |
| `doVacuum()` → `boolean` | Ejecuta `VACUUM` para compactar la BD. |
| `dropIndex(name)` / `dropAllIndexes()` | Borrado de índices. |

**`Cursor`** expone: `getCount()`, `moveToFirst()`/`moveToNext()`/`moveToPrevious()`/`moveToLast()`/`moveToPosition(n)`, `getColumnNames()`, `getString(colName)`, `getInteger(colName)`, `getLong(colName)`, `getShort(colName)`, `getFloat(colName)`, `getDouble(colName)`, `getBlob(colName)`, `close()`.

> **AVISO**: los getters reciben el **nombre de columna como String**, NO el índice numérico. Y el método entero se llama `getInteger`, NO `getInt` (que es el nombre que usa la API Android `Cursor`).

```js
var db = new SqlManager();
// Apertura: SIEMPRE un objeto con `databasePath` (NO un string posicional)
db.openDatabase({
    databasePath  : appData.getFilesPath() + "/cache.db",
    createIfNeeded: true,
    enableWal     : true
});
try {
    var cursor = db.doRawQuery("SELECT id, nombre FROM articulos WHERE activo = ?", 1);
    if (cursor.moveToFirst()) {
        do {
            appData.writeConsoleString(cursor.getInteger("id") + ": " + cursor.getString("nombre"));
        } while (cursor.moveToNext());
    }
    cursor.close();

    // Insert / update / delete: NativeObject con `tableName` + `fields` + `whereClause` opcional
    var rowid = db.insert({
        tableName: "articulos",
        fields   : { nombre: "Nuevo", activo: 1 }
    });
    db.update({
        tableName    : "articulos",
        fields       : { activo: 0 },
        whereClause  : "id = ?",
        whereArguments: [rowid]
    });
    db.delete({
        tableName    : "articulos",
        whereClause  : "id = ?",
        whereArguments: [rowid]
    });
} finally {
    db.close();
}
```

---

### 5.4 IniParser

Lectura y escritura de ficheros de configuración en formato INI.

| Método | Descripción |
|---|---|
| `parseFromString(text)` | Parsea contenido INI desde un String. |
| `parseFromFile(path)` | Parsea desde un fichero. |
| `serialize()` → `String` | Vuelca el contenido a String INI. |
| `save(path)` | Guarda el contenido en un fichero. |
| `getValue(key)` → `String` | Lee el valor de una clave (sin sección). |
| `setValue(key, value)` | Asigna una clave. |
| `getValueBySection(section, key)` → `String` | Lee el valor de una clave dentro de una sección. |

```js
var ini = new IniParser();
ini.parseFromFile(appData.getFilesPath() + "/config.ini");
var servidor = ini.getValueBySection("Conexión", "servidor");
var puerto   = ini.getValueBySection("Conexión", "puerto");
```

---

### 5.5 EncodingUtils

Codificación y decodificacion Base64 y otros formatos.

| Método | Descripción |
|---|---|
| `toBase64(data, [opts])` → `String` | Codifica datos a Base64. |
| `fromBase64(text, [opts])` → `String` | Decodifica Base64 a datos. |

```js
var enc = new EncodingUtils();
var codificado = enc.toBase64("usuario:password");
// resultado: "dXN1YXJpbzpwYXNzd29yZA=="
```

> Para hashing (MD5, SHA, etc.) usar el singleton global `crypto`. Ver §6.

---

### 5.6 AndroidIntent

Wrapper sobre `android.content.Intent` para componer y lanzar intents desde JS. La mayoría de setters devuelven la propia instancia (encadenable); los lanzadores (`startActivity`, `startService`, broadcasts) devuelven `int` (siempre 0).

| Método | Parámetros | Retorno | Descripción |
|---|---|---|---|
| `setPackage(packageName)` | 1 String | `AndroidIntent` | Fija el paquete destino. |
| `setClassName(packageName, className)` | 2 Strings | `AndroidIntent` | Fija el componente destino (FQDN). |
| `setAction(action)` o `setAction(className, fieldName)` | 1 o 2 Strings | `AndroidIntent` | Fija acción. Con 2 args resuelve por reflexión el valor de la constante estática `className.fieldName`. |
| `setData(uriString)` | 1 String | `AndroidIntent` | Fija URI mediante `Uri.parse`. |
| `setDataFromFile(filePath)` | 1 String | `AndroidIntent` | Resuelve `filePath` dentro de la app y genera un FileProvider URI. |
| `setType(mimeType)` | 1 String | `AndroidIntent` | Fija el tipo MIME. |
| `setDataAndType(uriOrFile, mimeType)` | 2 Strings | `AndroidIntent` | Si el path existe como fichero usa FileProvider; si no, `Uri.parse`. |
| `addCategory(category)` o `addCategory(className, fieldName)` | 1 o 2 Strings | `AndroidIntent` | Añade categoría (literal o por reflexión). |
| `addFlag(flag)` o `addFlag(className, fieldName)` | 1 int o 2 Strings | `AndroidIntent` | Añade flag (literal int o por reflexión). |
| `putStringExtra(name, value)` | 2 Strings | `AndroidIntent` | Extra String. |
| `putStringArrayExtra(name, array)` | String + NativeArray | `AndroidIntent` | Extra `String[]`. |
| `putStringArrayListExtra(name, array)` | String + NativeArray | `AndroidIntent` | Extra `ArrayList<String>`. |
| `putCharSequenceArrayListExtra(name, array)` | String + NativeArray | `AndroidIntent` | Extra `ArrayList<CharSequence>`. |
| `putParcelableArrayListExtra(name, array)` | String + NativeArray | `AndroidIntent` | Extra `ArrayList<Parcelable>`. |
| `putIntegerExtra(name, value)` | String + int | `AndroidIntent` | Extra int. |
| `putIntegerArrayExtra(name, array)` | String + NativeArray | `AndroidIntent` | Extra `int[]`. |
| `putIntegerArrayListExtra(name, array)` | String + NativeArray | `AndroidIntent` | Extra `ArrayList<Integer>`. |
| `putLongExtra(name, value)` | String + long | `AndroidIntent` | Extra long. |
| `putFloatExtra(name, value)` | String + float | `AndroidIntent` | Extra float. |
| `putFloatArrayExtra(name, array)` | String + NativeArray | `AndroidIntent` | Extra `float[]`. |
| `putDoubleExtra(name, value)` | String + double | `AndroidIntent` | Extra double. |
| `putDoubleArrayExtra(name, array)` | String + NativeArray | `AndroidIntent` | Extra `double[]`. |
| `putBooleanExtra(name, value)` | String + String/boolean | `AndroidIntent` | Extra boolean (acepta string `"true"/"false"`). |
| `putBooleanArrayExtra(name, array)` | String + NativeArray | `AndroidIntent` | Extra `boolean[]`. |
| `putBundleExtra(name, bundleWrapper)` | String + `ScriptBundleWrapper` | `AndroidIntent` | Extra Bundle. El segundo arg debe ser un Bundle (`new Bundle()`). |
| `putFileExtra(name, filePath)` | 2 Strings | `AndroidIntent` | Localiza el fichero en la app y mete su FileProvider URI como extra. |
| `putExtra(name, value)` | String + Object | `AndroidIntent` | Extra genérico (auto-detecta tipo: String, Integer, Float, Double, Boolean, Parcelable, Serializable, etc.). |
| `getLaunchIntentForPackage(packageName)` | 1 String | `AndroidIntent` | Reemplaza el intent interno con el de lanzamiento del paquete. |
| `getMyPackageName()` | ninguno | `String` | Nombre de paquete del proceso actual. |
| `startActivity()` | ninguno | `int` (0) | Lanza el intent como Activity. |
| `startActivityForResult(callback)` / `startActivityForResult(callback, bundleExtras?)` / `startActivityForResult(dataObject, nodeName, bundleExtras?)` | 1..3 args | `int` (0) | Lanza esperando resultado. Si el primer arg es Function se invoca al volver con `(resultCode, ScriptBundleWrapper)`; si es un dataObject se ejecuta el nodo `nodeName`. |
| `startService()` | ninguno | `int` (0) | Llama `Context.startService`. |
| `stopService()` | ninguno | `int` (0) | Llama `Context.stopService`. |
| `sendBroadcast(receiverPermission?)` | 0 o 1 String | `int` (0) | Envía broadcast (opcionalmente con permission). |
| `sendOrderedBroadcast(receiverPermission?)` | 0 o 1 String | `int` (0) | Envía broadcast ordenado. |
| `registerBroadcastReceiver({action, permission?, exported?, onReceive})` | 1 NativeObject | `int` (0) | Registra `ScriptBroadcastReceiver` para la `action` (única por action). `exported` por defecto `true` (Android 13+). |
| `unregisterBroadcastReceiver(action)` | 1 String | `int` (0) | Desregistra el receiver de esa action. |
| `isReceiverRegistered(action)` | 1 String | `boolean` | Indica si hay receiver registrado para la action. |

```js
// Marcar teléfono
new AndroidIntent()
    .setAction("android.intent.action.DIAL")
    .setData("tel:" + self.getValue("TELEFONO"))
    .startActivity();

// Abrir URL con flag (resolución por reflexión)
new AndroidIntent()
    .setAction("android.intent.action.VIEW")
    .setData("https://www.xone.es")
    .addFlag("android.content.Intent", "FLAG_ACTIVITY_NEW_TASK")
    .startActivity();

// Pedir foto a la cámara y recoger el resultado
new AndroidIntent()
    .setAction("android.media.action.IMAGE_CAPTURE")
    .startActivityForResult(function(resultCode, extras) {
        appData.writeConsoleString("resultado: " + resultCode);
    });

// Registrar receiver de broadcast
new AndroidIntent().registerBroadcastReceiver({
    action   : "com.miempresa.MI_EVENTO",
    onReceive: function(intent) {
        ui.showToast("Evento recibido");
    }
});
```

---

### 5.7 DeviceManager

Funciones de administración del dispositivo (Device Owner / MDM): visibilidad de paquetes, certificados CA, gestión de claves criptográficas. Requiere que la app sea Device Owner o Profile Owner. Muchos métodos devuelven `false` silenciosamente en versiones de Android antiguas.

| Método | Parámetros | Retorno | Descripción |
|---|---|---|---|
| `setAppVisibility(packageName, visible)` | 2 (String, boolean) | `boolean` | Oculta o muestra un paquete (DPM `setApplicationHidden`). |
| `toggleAppVisibility(packageName)` | 1 String | `boolean` | Invierte el estado oculto del paquete. |
| `setSuspendedApps({packageNames, suspended})` | 1 NativeObject | `boolean` | Suspende/reanuda un array de paquetes (requiere API 24+). |
| `setUninstallBlocked({packageNames, blocked})` | 1 NativeObject | `boolean` | Bloquea o permite desinstalar los paquetes indicados (plural). |
| `getInstalledCaCerts()` | ninguno | `ScriptCertificate[]` | Lista certificados CA instalados por el DPM. |
| `installCaCertificates(value)` | 1 (String nombre fichero, NativeArrayBufferView, `ScriptCertificate` o `NativeArray` de cualquiera de los anteriores) | `boolean` | Instala uno o varios certificados CA. |
| `uninstallCaCertificates(value)` | 1 (mismas formas que install) | `boolean` | Desinstala certificados CA. |
| `getEnrollmentId()` | ninguno | `String` | ID de enrollment del DPM (Android 12+); en versiones previas devuelve `""`. |
| `generateKeyPair({alias, algorithm, keySize, purposes})` | 1 NativeObject | `ScriptKeyPairCertificate` o `null` | Genera par de claves en KeyStore. `purposes` es array con valores `"encrypt"`, `"decrypt"`, `"sign"`, `"verify"`, `"agree"` (API 31+), `"attest"` (API 31+), `"wrap"`. Requiere API 28+. |
| `installKeyPair({alias, privateKey, certificateChain, userSelectable?, requestAccess?})` | 1 NativeObject | `boolean` | Instala una clave privada con su cadena. `userSelectable` y `requestAccess` por defecto `true`. |
| `removeKeyPair({alias})` | 1 NativeObject | `boolean` | Elimina la clave del alias indicado. |
| `grantKeyPair({alias, packageName})` | 1 NativeObject | `boolean` | Concede a `packageName` acceso a la clave (API 30+). |
| `revokeKeyPair({alias, packageName})` | 1 NativeObject | `boolean` | Revoca el acceso (API 30+). |

```js
var dm = new DeviceManager();
dm.setAppVisibility("com.ejemplo.app", false);

// Suspender varias apps a la vez (NativeObject con packageNames PLURAL)
dm.setSuspendedApps({
    packageNames: ["com.facebook.katana", "com.instagram.android"],
    suspended   : true
});

// Bloquear desinstalación (también packageNames plural)
dm.setUninstallBlocked({
    packageNames: ["com.xone.android.framework"],
    blocked     : true
});

// Generar par de claves RSA 2048 para firma
dm.generateKeyPair({
    alias    : "miFirma",
    algorithm: "RSA",
    keySize  : 2048,
    purposes : ["sign", "verify"]
});

// Gestionar acceso de otras apps a la clave (API 30+)
dm.grantKeyPair({ alias: "miFirma", packageName: "com.ejemplo.app" });
```

---

### 5.8 WifiManager

Gestion de conexiones WiFi.

| Método | Descripción |
|---|---|
| `getAdapterMacAddress()` → `String` | Dirección MAC del adaptador WiFi. |
| `connect(ssid)` → `Object` | Conecta a la red WiFi cuyo SSID se pasa como **string** (NO un objeto de opciones). |
| `disconnect()` → `boolean` | Desconecta de la red WiFi actual. |
| `listSavedNetworks()` → `Object[]` | Lista las redes WiFi guardadas en el dispositivo. |
| `scanAvailableNetworks(...)` → `boolean` | Escanea redes WiFi disponibles. |
| `enableWifiAdapter()` | Enciende el adaptador WiFi. |
| `disableWifiAdapter()` | Apaga el adaptador WiFi. |
| `isWifiAdapterEnabled()` → `boolean` | `true` si el adaptador WiFi esta encendido. |
| `getActiveWifiInfo()` → `XOneWifiInfo` | Info de la conexión WiFi actual. |
| `getVpnInfo()` → `XOneVpnInfo` | Info de VPN activa. |
| `addNetwork(...)` / `removeNetwork(...)` / `enableNetwork(...)` / `disableNetwork(...)` | Gestion de redes guardadas. |
| `startLocalOnlyNetwork(...)` | Crea red local sin internet. |

```js
var wifi = new WifiManager();
var redes = wifi.listSavedNetworks();
```

---

### 5.9 BluetoothSerialPort

Cliente Bluetooth clásico (RFCOMM SPP, UUID `00001101-...`). Mantiene conexión persistente con un dispositivo. Operaciones síncronas con timeout configurable. La mayoría de métodos devuelven la propia instancia para encadenado.

| Método | Parámetros | Retorno | Descripción |
|---|---|---|---|
| `setMacAddress(mac)` | 1 String | `BluetoothSerialPort` | Fija la MAC objetivo (validada por `BluetoothAdapter.checkBluetoothAddress`). |
| `isDevicePaired()` | ninguno | `boolean` | Comprueba si la MAC actual (o la guardada en SharedPreferences `BluetoothSerialPort/address`) está emparejada. |
| `pairDevice()` | ninguno | `BluetoothSerialPort` | Inicia emparejamiento (`createBond`). |
| `removePairing()` | ninguno | `BluetoothSerialPort` | Elimina el emparejamiento (`removeBond` por reflexión). |
| `isEnabled()` | ninguno | `boolean` | Estado del adaptador Bluetooth. |
| `enable()` | ninguno | `BluetoothSerialPort` | Activa el adaptador (en Android 14+ lanza si no está ya activado). |
| `disable()` | ninguno | `BluetoothSerialPort` | Desactiva el adaptador. |
| `toggle()` | ninguno | `boolean` | Conmuta el estado del adaptador. |
| `connect(macAddress?)` | 0 o 1 String | `BluetoothSerialPort` | Abre socket RFCOMM inseguro al dispositivo (usa la MAC dada, la previamente fijada o la guardada). Persiste la última MAC en SharedPreferences. |
| `isConnected()` | ninguno | `boolean` | Si el socket está conectado. |
| `getSavedAddress()` | ninguno | `String` | MAC del último dispositivo conectado (puede ser `""`). |
| `setTimeout(timeoutSeconds)` | 1 long | `BluetoothSerialPort` | Timeout en **segundos** para read/write (`-1` = espera infinita). |
| `selectDevice()` | ninguno | `BluetoothSerialPort` | Lanza la actividad `BluetoothDeviceSelector` para elegir un dispositivo emparejado. |
| `selectBluetoothDevice()` | ninguno | `BluetoothSerialPort` | Alias obsoleto de `selectDevice`. |
| `getDiscoverableDevices()` | ninguno | `BluetoothDeviceScript[]` | Lanza descubrimiento BT clásico y devuelve la lista (espera a que termine). |
| `getDiscoverableBluetoothDevices()` | ninguno | `Object[]` | Alias obsoleto del anterior. |
| `write(data)` | 1 (String o `{data, offset?, endIndex?}`) | `boolean` | Escribe en el socket. Si es objeto, `data` es byte array; `endIndex` por defecto = longitud. |
| `read(size?)` | 0 o 1 int | `String` | Lee hasta `size` bytes (default 1) decodificados como String. |
| `readAll()` | ninguno | `String` | Lee todos los bytes disponibles (o bloquea hasta EOF). |
| `readBuffer(size)` | 1 int | `NativeInt8Array` o `null` | Lee `size` bytes y los devuelve como buffer JS. |
| `getAvailableBytes()` | ninguno | `int` | Bytes en buffer de entrada (0 si no hay conexión). |
| `sleep(ms)` | 1 long | `BluetoothSerialPort` | `Thread.sleep` en el hilo actual (default 100 ms). |
| `isOpen()` | ninguno | `boolean` | Si los streams están abiertos. |
| `setReadCallback(callback)` | 1 (callback o `null`) | `BluetoothSerialPort` | Registra callback JS que recibe los datos entrantes como String. Pasar `null` cancela. |
| `disconnect()` | ninguno | `BluetoothSerialPort` | Cierra streams y socket. |
| `requestEnableBluetooth({onEnabled, onDenied})` | 1 NativeObject | `BluetoothSerialPort` | Muestra el diálogo del sistema para activar Bluetooth e invoca el callback correspondiente. |

```js
var bt = new BluetoothSerialPort();
bt.setTimeout(5)
  .connect("00:11:22:33:44:55")
  .write("HOLA\r\n");
var resp = bt.readAll();
appData.writeConsoleString("Respuesta: " + resp);
bt.disconnect();

// Recepción asíncrona con callback
bt.setReadCallback(function(data) {
    appData.writeConsoleString("RX: " + data);
});
```

---

### 5.10 OAuth2

Autenticación OAuth2 y manejo de tokens JWT.

| Método | Descripción |
|---|---|
| `withOptions({clientId, oauthUri, tokenUri, redirectUri, scope, ...})` | Configura el cliente OAuth2. **Obligatorio antes de `authenticate`.** Las claves de URL son `oauthUri`/`tokenUri` (NO `authUrl`/`tokenUrl`). |
| `authenticate({onSuccess, onError, noHistory?})` | Lanza el flujo. **Solo lee onSuccess/onError/noHistory**; el resto de config se toma de `withOptions`. |
| `register(...)` | Registro de cliente dinamico. |
| `requestToken(opts)` | Solicita un token de acceso (refresh, etc.). |
| `parseJwt(jwt)` → `JSONObject` | Decodifica el payload de un token JWT (sin verificar firma). |
| `verifyJwt({token, key})` → `boolean` | Verifica firma JWT. Toma **1 NativeObject** con `token` y `key`/`publicKey`, NO `(jwt, key)`. |
| `logout(callback)` | Cierra sesion. Exige **1 callback**. |
| `isBrowserPresent()` / `getBrowserInfo()` / `fetchConfiguration(...)` | Utilidades del browser custom tab. |

```js
var oauth = new OAuth2();
oauth.withOptions({
    clientId   : "mi-client-id",
    oauthUri   : "https://auth.proveedor.com/oauth/authorize",  // NO "authUrl"
    tokenUri   : "https://auth.proveedor.com/oauth/token",      // NO "tokenUrl"
    redirectUri: "miapp://callback",
    scope      : "openid profile email"
});
oauth.authenticate({
    onSuccess: function(token) {
        appData.setGlobalMacro("##ACCESS_TOKEN##", token.access_token);
    },
    onError: function(e) {
        ui.showToast("Error OAuth2: " + e);
    }
});
```

---

### 5.11 Worker

Ejecuta funciones JavaScript en un hilo separado (worker), evitando bloquear la UI.

| Método | Descripción |
|---|---|
| `setCallback(fn)` | Define la **función a ejecutar** en el worker (es el callback, NO `setExecutor`). También se puede pasar al constructor: `new Worker(fn)`. |
| `setExecutor(name, [threadCount])` | Define un **nombre de pool de hilos** (string) compartido entre workers. Opcionalmente un `int` con el número de hilos. NO acepta una función. |
| `setSelfObject(obj)` | Define el objeto `self` disponible dentro del worker. |
| `start()` → `Future` | Lanza el worker. Devuelve un `Future` con el resultado. Lanza `IllegalStateException` si no se ha hecho `setCallback` y `setExecutor` antes. |

```js
// Forma recomendada: pasar la función al constructor
var worker = new Worker(function() {
    return calcularTotales();
});
worker.setExecutor("poolCalculo");           // nombre del pool (string)
var future = worker.start();
future.then(function(res) {
    self.setValue("MAP_TOTAL", res);
    ui.relayout();
});

// Forma equivalente con setCallback explícito
var worker2 = new Worker();
worker2.setCallback(function() { return calcularTotales(); });
worker2.setExecutor("poolCalculo", 2);       // 2 hilos en el pool
```

---

### 5.12 Animation

Animaciones programaticas sobre controles. API fluida (todos los setters devuelven la propia `Animation`).

| Método | Descripción                                                                              |
|---|------------------------------------------------------------------------------------------|
| `setTarget(propName)` | Nombre del prop a animar (String).                                                       |
| `setX(v)` / `setY(v)` / `setZ(v)` | Translación absoluta (no existe `setXY`).                                                |
| `setRelativeX(v)` / `setRelativeY(v)` / `setRelativeZ(v)` | Translacion relativa (1 parametro, no rango from/to).                                    |
| `setAlpha(v)`, `setRotation(grados)`, `setRelativeRotation(grados)` | Opacidad y rotacion.                                                                     |
| `setScaleX(v)` / `setScaleY(v)` / `setRelativeScaleX(v)` / `setRelativeScaleY(v)` | Escala.                                                                                  |
| `setWidth(v)` / `setHeight(v)` | Dimensiones.                                                                             |
| `setBackgroundColor(color)` / `setBgcolor(color)` | Color de fondo.                                                                          |
| `setCircularReveal(cx, cy, bReveal)` | Reveal circular UNICO (`bReveal`=true muestra, false oculta).                            |
| `setInterpolation(name)` | Tipo de interpolador (`BounceInterpolator`, etc.).                                       |
| `setDuration(ms)` | Duración en milisegundos.                                                                |
| `setRepeatCount(n)` / `setRepeatMode(mode)` | Repeticiones. `setRepeatMode` espera **int**: `1` = restart, `2` = reverse (NO strings). |
| `setStartCallback(fn)` / `setEndCallback(fn)` | Callbacks.                                                                               |
| `setEffect({effect})` | Efectos predefinidos (toma NativeObject con clave `effect`, NO un string suelto).        |
| `cancel()` / `stop(bCompleteFirst)` | `cancel()` cancela inmediatamente. `stop` requiere 1 boolean: `true` = completar la animación antes de cancelar, `false` = corte inmediato. |
| `start()` | Lanza la animación.                                                                      |

```js
var anim = new Animation();
anim.setTarget("MAP_BTN_ACEPTAR");
anim.setRelativeX(100);          // 1 parámetro (no from/to)
anim.setDuration(300);
anim.start();
```

---

### 5.13 Socket / WebSocket

- **`Socket`** — Cliente socket TCP/IP bruto. Métodos: `setProtocol`, `setAddress`, `setPort`, `setTimeout`, `connect`, `send`, `receive`, `receiveAll`, `disconnect`.
- **`WebSocket`** — Cliente WebSocket (`ws://` y `wss://`), soporta certificados y subprotocolos. La configuración va en el **constructor**; los únicos métodos del objeto son `send(data)` y `close()`.

```js
// Toda la configuración se pasa al constructor (NO existe ws.connect())
var ws = new WebSocket({
    url: "wss://servidor.empresa.com/ws",
    onMessage: function(msg) { console.log("WS recibido: " + msg); },
    onError:   function(e)   { console.log("WS error: " + e); }
});
ws.send("hola");
// ws.close();
```

---

### 5.14 DebugTools

Herramientas de envío de información de depuración (logs, BD) al servidor de soporte.

Métodos: `getDeviceId()`, `getLog()`, `sendLog()`, `sendDatabase()`, `sendReplicaDebugDatabase()`, `sendReplicaFilesDatabase()`.

```js
var debug = new DebugTools();
debug.sendLog();             // Envia el logcat al servidor de soporte
// debug.sendDatabase();     // Envia la BD principal
// debug.sendReplicaDebugDatabase();
// debug.sendReplicaFilesDatabase();
// var sId = debug.getDeviceId();
// var sLog = debug.getLog();
```

---

### 5.15 IrManager

Control de infrarrojos (IR blaster) para dispositivos compatibles.

```js
var ir = new IrManager();
ir.transmit(38000, [9000, 4500, 560, 560]);
```

---

### 5.16 SoundManager

Reproducción y gestion de audio (alternativa a métodos de `ui`).

```js
var snd = new SoundManager();
snd.play(appData.getFilesPath() + "/alerta.mp3");
```

---

### 5.17 VibrationManager

Control de vibracion del dispositivo.

```js
var vib = new VibrationManager();
vib.vibrate([0, 200, 100, 200]);   // patron pausa/vibracion (ms)
```

---

### 5.18 WearableConnection

Comunicación con dispositivos Wear OS emparejados.

Métodos disponibles: `setCallbacks(callbacks)`, `removeCallbacks()`, `send(path, data)`.

```js
var wear = new WearableConnection();
wear.setCallbacks({
    onMessageReceived: function(msg) { /* ... */ }
});
wear.send("/path/notificacion", "Pedido listo");   // método se llama send, no sendMessage
```

---

### 5.19 AccountManager

Gestion de cuentas de Android (Google, Microsoft, etc.) almacenadas en el dispositivo.

Métodos disponibles: `getAccounts()` (sin argumentos, devuelve TODAS), `getAccountsByType(type)`, `chooseAccount(...)`, `addAccount(...)`, `getUserData(account, key)`, `getAuthToken(...)`, `getAuthenticatorTypes()`.

```js
var am = new AccountManager();
var todas    = am.getAccounts();                  // todas las cuentas del dispositivo
var google   = am.getAccountsByType("com.google");// filtrar por tipo (NO usar getAccounts con argumento)
```

---

### 5.20 XOneNFC

Lectura y escritura de tags NFC (NDEF, Mifare Classic/Ultralight), emulación HCE, DNI electrónico y operaciones MDM. Requiere `<permission name="nfc"/>` dentro del nodo `<permissions>` de la coll y dispositivo con hardware NFC. Implementación en `xonenfc_lib`. Todos los métodos devuelven la propia instancia (encadenable).

**Patrón de callbacks de las operaciones `*Async`**: estas operaciones reciben el **nombre del nodo XML** a ejecutar como callback (un String), NO un objeto con `onSuccess`/`onError`. El framework invoca ese nodo cuando se detecta el tag y completa la operación.

| Método | Parámetros | Descripción |
|---|---|---|
| `isAvailable()` | ninguno | `true` si el dispositivo tiene chip NFC. |
| `isEnabled()` | ninguno | `true` si NFC está activado. |
| `getAntennaInfo()` | ninguno | NativeObject con info de la antena NFC (nullable). |
| `clearAllPendingOperations()` | ninguno | Cancela todas las operaciones asíncronas pendientes. |
| `setOnTagDiscoveredCallback(callback)` o `setOnTagDiscoveredCallback({callback, window?})` | 1 (Function o NativeObject) | Registra callback que recibe el tag detectado. Si es objeto, la clave es **`callback`** (no `onTagDiscovered`); `callback` puede ser una función o el nombre de un nodo XML. Pasar `null` desactiva el reader. |
| `readNdefMessageAsync(callbackName)` | 1 String | Lee mensaje NDEF del próximo tag detectado. `callbackName` es el nombre del nodo XML a ejecutar al leer. |
| `writeNdefMessageAsync(data, callbackName)` | 2 Strings | Escribe `data` como mensaje NDEF al próximo tag. |
| `formatNdefTagAsync(callbackName)` | 1 String | Formatea un tag virgen como NDEF. |
| `writeNdefFormatableAsync(data, callbackName)` | 2 Strings | Escribe NDEF en un tag formatable. |
| `readMifareClassicAsync(blocks, callbackName, [keyMapJson])` | 2-3 args | Lee los bloques indicados (array de ints) del próximo tag Mifare Classic. `keyMapJson` opcional: ruta a un fichero JSON con las claves A/B por sector. |
| `writeMifareClassicAsync(blocks, data, callbackName, [keyMapJson])` | 3-4 args | Escribe `data` (array) en los `blocks` (array) indicados. |
| `readMifareUltralightAsync(pageIndex, callbackName)` | 2 args (int, String) | Lee desde `pageIndex` el próximo tag Mifare Ultralight/NTAG. |
| `writeMifareUltralightAsync(data, callbackName)` | 2 args (array, String) | Escribe páginas Mifare Ultralight. |
| `startNdefTagEmulation({ndefType, ndefData, oneShot?, password?, readAllowed?, writeAllowed?, size?})` | 1 NativeObject | Inicia emulación HCE como tag NDEF. `ndefType` ∈ `"text"`/`"uri"`. |
| `stopNdefTagEmulation()` | ninguno | Detiene la emulación HCE. |
| `enableDnieReader({onDnieRead, onDnieReadError, onProgressUpdated, authMode?, canNumber? \| mrz? \| (documentNumber+dateOfBirth+dateOfExpiry), readEfcom?, readProfileData?, readUserImage?, readSignatureImage?, readAuthenticationCertificate?, readSignatureCertificate?, enablePassiveAuthentication?, trustedCountries?, minimumSessionKeySize?, password?, timeout?})` | 1 NativeObject | Activa el lector de DNI electrónico. **Obligatorios**: `onDnieRead`, `onDnieReadError` y la clave de acceso (CAN o MRZ). `authMode` por defecto `"PACE"`. `minimumSessionKeySize` exige que la clave de sesión negociada tenga al menos esos bits (`112`, `128`, `192` o `256`); sin especificar se acepta la variante más fuerte que ofrezca el documento. `enablePassiveAuthentication` (por defecto `true`) comprueba que los datos del documento están firmados por el país emisor y, si algo no cuadra, aborta la lectura por `onDnieReadError` sin entregar ningún dato; se reconocen los emisores de más de cien países, y para leer un documento de un emisor que no esté hay que desactivarla. `trustedCountries` acota los emisores que se admiten a una lista de códigos de país separados por comas, por ejemplo `"ES"` para no dar por bueno más que el documento español. |
| `disableDnieReader()` | ninguno | Desactiva el lector de DNIe. |
| `installMdm({method, ...})` | 1 NativeObject | Provisiona MDM via NFC. `method` ∈ `"any"` (default), `"android_beam"`, `"emulate_tag"`. |
| `generateMdmQrCode({targetFile, ...})` | 1 NativeObject | Genera QR de enrolamiento MDM en `targetFile` (640×480 px). |
| `writeMdmTag({...})` | 1 NativeObject | Escribe tag NFC con configuración MDM. |

```js
var nfc = new XOneNFC();
if (!nfc.isAvailable() || !nfc.isEnabled()) {
    ui.msgBox("NFC no disponible o desactivado");
    return;
}

// Escuchar tags: el callback puede ser una función o el nombre de un nodo XML
nfc.setOnTagDiscoveredCallback({
    callback: function(tag) {
        appData.writeConsoleString("Tag detectado: " + tag.getHexId());
    }
});

// O directamente la función:
// nfc.setOnTagDiscoveredCallback(function(tag) { ... });

// Leer NDEF: callbackName es el nombre del nodo XML que se ejecutará
nfc.readNdefMessageAsync("onTagRead");

// Escribir NDEF: data + nombre del nodo callback
nfc.writeNdefMessageAsync("Hola mundo", "onTagWritten");

// Leer DNI electrónico con CAN (claves obligatorias: onDnieRead + onDnieReadError + CAN o MRZ)
nfc.enableDnieReader({
    canNumber       : "123456",
    onDnieRead      : function(result) {
        appData.writeConsoleString("DNI: " + result.getDniNumber());
    },
    onDnieReadError : function(err) { ui.showToast("Error DNIe: " + err); },
    onProgressUpdated: function(progress, message) { /* progreso 0-100 */ },
    readUserImage   : true,
    readProfileData : true,
    // Se comprueba que el documento lo firmó el país emisor salvo que se desactive; acotar los
    // emisores admitidos es lo que impide dar por bueno un pasaporte extranjero auténtico
    trustedCountries : "ES"
});
```

---

### 5.21 ImageDrawing

Manipulación programatica de imágenes: cargar imagen base, anadir texto/superpuestos, rotar, censurar caras.

Métodos disponibles: `create(...)`, `setBackground(path)`, `setBackgroundColor(color)`, `setFont(name)`, `setFontSize(size)`, `setFontColor(color)`, `setFontStyle(style)`, `setGrayscale(bool)`, `addTextSetXY(text, x, y)`, `addImageSetXY(path, x, y)`, `getImageInfo(path)`, `save(path)`, `rotate(grados)`, `copyExifMetadata(src, dst)`, `censorFaces(path)`, `extractFace(path)`.

```js
// IMPORTANTE: setBackground exige que el lienzo este creado con create(w, h).
// Sin create() previo lanza IllegalArgumentException("Width not set").
var img  = new ImageDrawing();
var info = img.getImageInfo(appData.getFilesPath() + "/foto.jpg");
img.create(info.getWidth(), info.getHeight());              // dimensionar lienzo PRIMERO
img.setBackground(appData.getFilesPath() + "/foto.jpg");    // cargar imagen base (NO existe img.load)
img.setFontSize(32);
img.setFontColor("#FF0000");
img.addTextSetXY("ENVIADO", 50, 50);                        // anadir texto (NO existe img.drawText)
img.save(appData.getFilesPath() + "/foto_marcada.jpg");
```

---

### 5.22 BarcodeGenerator

Generación de códigos de barras 1D (EAN, Code128, UPC, etc.) y 2D (incluye QR).

La configuración va por **setters previos**; `generate()` toma **solo el texto a codificar** (un único String), NO un objeto.

```js
var bc = new BarcodeGenerator();
bc.setType("qrcode");                                       // "qrcode", "code128", "ean13", etc.
bc.setResolution(300, 100);                                  // ancho x alto en px
bc.setDestinationFile(appData.getFilesPath() + "/barcode.png");
// Opcionales: setMargin, setRotation, setTextFontSize, setLabelVisibility, setErrorCorrectionLevel
bc.generate("1234567890");                                   // SOLO el texto (NO un objeto)
```

---

### 5.23 XOnePrinter

Impresion en impresoras Bluetooth, USB o de red. Soporta ESC/POS y PDF.

La configuración va por **setters previos**; `connect()` solo acepta un número de reintentos opcional.

```js
var printer = new XOnePrinter();
printer.setDriver("zebra");                                  // o "esc-pos", "datamax", etc.
printer.setMacAddress("AA:BB:CC:DD:EE:FF");                  // o setIpAddress(...) + setPort(...)
printer.connect();                                            // sin argumentos (o connect(3) para 3 reintentos)
printer.print("Ticket de venta\n");                          // print, NO printText
printer.printLineCentered("--------------");
printer.print("Total: 25,00€");
printer.cutPaper();                                           // cutPaper, NO cut
printer.disconnect();
```

---

### 5.24 XOnePDF

Generación de documentos PDF. La API usa `create(path)` + setters + `addText*`/`addImage*` + `newPage()` + `close()` (NO existen `addPage`/`drawText`/`drawImage`/`save`).

```js
var pdf = new XOnePDF();
pdf.create(appData.getFilesPath() + "/factura.pdf");         // ruta de salida
pdf.open();
pdf.setFont("Helvetica");
pdf.setFontSize(12);
pdf.setFontColor("#000000");
pdf.addTextSetXY("Factura N." + self.getValue("NUM"), 50, 50);  // addTextSetXY (NO drawText)
pdf.addImageSetXY(appData.getFilesPath() + "/logo.png", 400, 30, 0.5, 0.5);  // addImageSetXY (NO drawImage)
// pdf.newPage();    // para pagina nueva (NO addPage)
pdf.close();                                                  // close (NO save)
// pdf.launchPDF();  // opcional, abre el PDF generado
```

**Leer / extraer texto de un PDF existente.** `extractText(rutaPdf)` devuelve el texto plano del PDF; `extractTextToFile(rutaPdf, rutaTxt)` lo vuelca a un `.txt` en UTF-8 y devuelve la ruta del fichero generado. Solo extraen la **capa de texto**: un PDF escaneado (imágenes sin texto) devuelve vacío, no hacen OCR. Ambos son síncronos.

```js
var pdf = new XOnePDF();
var texto = pdf.extractText(appData.getFilesPath() + "/documento.pdf");           // a variable
var ruta  = pdf.extractTextToFile(appData.getFilesPath() + "/documento.pdf",      // a fichero .txt
                                  appData.getFilesPath() + "/documento.txt");
```

---

### 5.25 XOneOCR

Reconocimiento óptico de caracteres sobre imágenes o regiones.

Métodos disponibles:
- `scanLicensePlate(imagePath, [{mode, region, withCamera, licensePlateWidth, licensePlateHeight, onResult}])` → `String` con la matrícula.
- `startScan({onResult, regex, oneShot})` — escáner asíncrono con regex.
- `scanText(imagePath, [params])` — **actualmente lanza `UnsupportedOperationException`** (no implementado).

```js
var ocr = new XOneOCR();

// Reconocer matrícula a partir de fichero
var matricula = ocr.scanLicensePlate(appData.getFilesPath() + "/matricula.jpg");
appData.writeConsoleString("Matrícula: " + matricula);

// Escáner asíncrono con regex
ocr.startScan({
    onResult: function(texto) { ui.showToast("Detectado: " + texto); },
    regex   : "\\d{4}[A-Z]{3}",
    oneShot : true
});
```

> **AVISO**: `ocr.recognize(path)` **no existe**. Para OCR genérico no hay método actualmente implementado (`scanText` lanza `UnsupportedOperationException`).

---

### 5.26 XOneSigner

Helper de firma electrónica y primitivas criptográficas básicas (XOR, RC2, Base64, firma CMS de datos, timestamping TSP). Se instancia con `new XOneSigner()`.

| Método | Parámetros | Retorno | Descripción |
|---|---|---|---|
| `xorCipher(value, key)` | 2 (String, String) | `String` | Cifra/descifra XOR el `value` con la `key` (carácter a carácter). |
| `rc2Cipher(mode, value, key, vectorI)` | 4 (int, value, String, String) | `byte[]` | RC2 con `mode=1` (cifrar) o `mode=0` (descifrar); `value` puede ser String o `byte[]`. |
| `encryptRc2(value, key, iv)` | 3 (value, String, String) | `NativeInt8Array` | RC2 cifrado, `value` admite String, `byte[]` o `NativeArrayBufferView`. |
| `decryptRc2(value, key, iv)` | 3 (value, String, String) | `NativeInt8Array` | RC2 descifrado. |
| `base64Encode(value)` | 1 (String o `byte[]`) | `String` | Codifica a Base64 sin saltos de línea. |
| `base64Decode(value)` | 1 String | `byte[]` | Decodifica Base64. |
| `signDataObject({privateKey, certificateChain, data?, dataFile?, templateFile, keystoreFile?, keystorePassword?, certificateAlias?, digestAlgorithm, timeStampServerUrl?, timeStampServerUserName?, timeStampServerPassword?, timeStampDigestAlgorithm?, connectTimeout?, readTimeout?})` | 1 NativeObject | `String` o `null` | Firma CMS según la plantilla XML. Acepta DNIe (`privateKey`+`certificateChain`) o keystore PKCS12 (`keystoreFile`+`keystorePassword`+`certificateAlias`). Opcionalmente añade timestamp TSP. |
| `signDataObject(data, mask)` | 2 (String, int) | `String` o `null` | **Forma legacy**: usa el keystore por defecto, pide PIN con un diálogo del sistema, firma con SHA-1. `mask=0` firma `data` como String, `mask=1` firma el contenido del fichero `data`. |
| `doTimeStampRequest({url, userName?, password?, digestAlgorithm, dataFile? \| data?, connectTimeout?, readTimeout?})` | 1 NativeObject | `TimeStampResponse` | Solicita un token TSP al servidor indicado para los `data`/`dataFile` aportados. |

```js
// Firmar CMS con DNIe (privateKey y certificateChain previos)
var signer = new XOneSigner();
var firma = signer.signDataObject({
    privateKey       : dnie.privateKey,
    certificateChain : dnie.certificateChain,
    data             : "contenido a firmar",
    templateFile     : "template.xml",
    digestAlgorithm  : "SHA-256",
    timeStampServerUrl     : "https://tsa.example.com/tsa",
    timeStampDigestAlgorithm: "SHA-256",
    connectTimeout   : 10000,
    readTimeout      : 30000
});

// Firmar con keystore PKCS12
var firma2 = signer.signDataObject({
    keystoreFile     : "cert.p12",
    keystorePassword : "1234",
    certificateAlias : "miAlias",
    dataFile         : appData.getFilesPath() + "/documento.bin",
    templateFile     : "template.xml",
    digestAlgorithm  : "SHA-256"
});

// Primitivas auxiliares
var b64    = signer.base64Encode("texto plano");
var llano  = signer.base64Decode(b64);
var oculto = signer.xorCipher("secreto", "clave123");
```

> Para **firmar PDFs** completos (no datos CMS arbitrarios) usar `XOnePDF.signPdf(...)` o `XOnePDF.signPdfWithKey(source, dest, keystorePath, keystorePassword, keyAlias, keyPassword)` (6 args posicionales).

---

### 5.28 AccessibilityManager

Wrapper mínimo del servicio de accesibilidad de Android. Permite consultar el estado y emitir anuncios para TalkBack.

| Método | Parámetros | Retorno | Descripción |
|---|---|---|---|
| `isEnabled()` | ninguno | `boolean` | Si el servicio de accesibilidad está activo. |
| `isTouchExplorationEnabled()` | ninguno | `boolean` | Si "explorar por toque" está activo (API 14+; antes devuelve `false`). |
| `sendText(text)` | 1 String | `boolean` | Envía un evento `TYPE_ANNOUNCEMENT` con el texto (API 16+). Devuelve `false` si el servicio está desactivado. |
| `interrupt()` | ninguno | `null` | Llama `AccessibilityManager.interrupt()` para cortar anuncios en curso. |

```js
var a11y = new AccessibilityManager();
if (a11y.isEnabled()) {
    a11y.sendText("Pedido guardado correctamente");
} else {
    appData.writeConsoleString("Accesibilidad desactivada (explorar por toque: " +
        a11y.isTouchExplorationEnabled() + ")");
}
a11y.interrupt();
```

---

### 5.27 Lista completa de creables

Lista canonica de todos los objetos creables, según el registro en `RhinoJavascriptEngine.addCreateObjects()`. **El match es case-insensitive** (`new FileManager()` y `createObject("filemanager")` son equivalentes), pero los ejemplos usan PascalCase canonico.

```
FileManager, WebSocket, XOneNFC, DebugTools, ImageDrawing,
BluetoothSerialPort, SerialPort, AndroidIntent, Bundle, IniParser,
WifiManager, WifiConfiguration, WifiP2p, Animation, SqlManager,
SystemDebug, AccountManager, GpsTools, Worker, OAuth2, IrManager,
Socket, EncodingUtils, XOnePrinter, XOnePDF, BarcodeGenerator,
QRGenerator, XOneOCR, XOneSigner, KeyStore, AccessibilityManager,
PinpadPayment, Loomis, TensorFlow, VeridasManager, RTCClient,
GeoTabKeyless, MobbSign, BeaconyManager, SoundManager, VibrationManager,
WearableConnection, ItronDeviceManager, DeviceManager
```

> Los objetos no documentados arriba (KeyStore, TensorFlow, VeridasManager, PinpadPayment, Loomis, MobbSign, GeoTabKeyless, RTCClient, BeaconyManager, ItronDeviceManager, SystemDebug, Bundle, WifiConfiguration, WifiP2p, SerialPort, QRGenerator) son creables y siguen el mismo patrón de instanciación. Para su API completa consultar el código del módulo. `AccessibilityManager` está en §5.28; `bleSerial` (BLE) es un singleton — ver §6.

---

## 6. Singletons Globales

Los siguientes objetos son **singletons** registrados automáticamente en el scope global. Se acceden directamente por su nombre, **sin `new` y sin `createObject`**. Llamar `new` o `createObject` con estos nombres lanza error o devuelve null.

### 6.1 Catálogo completo

Registrados en `RhinoJavascriptEngine.addReservedObjects()`:

| Singleton | Proposito | Doc detallada |
|-----------|-----------|---------------|
| `$http` | Cliente HTTP con Futures | Tópico 03 §5 |
| `crypto` | Hashing (MD5, SHA), cifrado simetrico/asimetrico | §6.2 |
| `clipboard` | Portapapeles del dispositivo | §6.3 |
| `deviceInfo` | Info hardware: batería, red, sensores físicos | §6.4 |
| `systemSettings` | Ajustes del sistema: brillo, permisos, MDM | §6.5 |
| `packageManager` | Consulta de apps instaladas | §6.6 |
| `biometricsManager` | Biometria moderna (huella, face ID) | §6.7 |
| `fingerprintManager` | Huella legacy (deprecado) | §6.7 |
| `bleManager` | Bluetooth Low Energy | §6.8 |
| `sensorManager` | Sensores físicos (acelerometro, giroscopio, etc.) | §6.9 |
| `paymentManager` | Pasarelas de pago: Google Pay, Redsys, Smartphone TPV (Comercia), BBVA Cobros | §6.10 |
| `pushMessage` | Mensajeria push (FCM) | §6.11 |
| `push` | Alias legacy de pushMessage | §6.11 |
| `appBroadcastManager` | Broadcasts entre apps XOne | §6.12 |
| `replica` | Sistema de replica/sincronización | §6.14 |
| `live` | Sistema de Live Update | §6.15 |
| `smsService` | Envio/recepcion SMS | §6.16 |
| `serial` | Puerto serie generico | §6.17 |
| `bluetoothSerial` | Puerto serie via Bluetooth | §6.17 |
| `bleSerial` | Puerto serie via BLE | §6.17 |
| `efiDiagItv` | Diagnostico EFI / ITV (Itron) | §6.18 |
| `ml` | Machine Learning generico (TensorFlow Lite) | §6.19 |
| `ai` | IA generativa | §6.20 |

### 6.2 crypto

Hashing y criptografía. **Casi todos los métodos toman un único `NativeObject` como argumento** (NO strings sueltos): `{ data: "...", outputFormat: "hex"|"base64"|"buffer", key?: "hmacKey", output?: "fichero.bin" }`.

Métodos disponibles (57): hashes (`md5`, `sha1`, `sha224`, `sha256`, `sha384`, `sha512`), codificación (`toBase64`/`fromBase64`, `toBase58`, `toBase45`, `toBase32`), compresión (`inflate`, `deflate`), keystore (`getCertificate`, `getRsaPublicKey`/`getRsaPrivateKey`, `getEcPublicKey`/`getEcPrivateKey`, `installKeyPairOnKeyStore`, etc.), COSE/CBOR (`decodeCose`/`decodeCbor`/`encodeCbor`/`validateCose`), random (`getRandomString`, `getRandomInt`, `getRandomDouble`, `getNewUuid`), criptografía (`hash`, `sign`, `encrypt`, `decrypt`, `derivePassword`, `generateKeyPair`, `generateAesKey`/`installAesKey`/`getAesKey`), JWT (`isJwtSignatureValid`), BD (`getDatabaseKey`), checksum (`getChecksum`).

```js
// FIRMA CORRECTA: objeto con `data` y `outputFormat`
var hashHex    = crypto.md5({ data: "texto", outputFormat: "hex" });
var hashB64    = crypto.sha256({ data: "texto", outputFormat: "base64" });
var hashBuffer = crypto.sha512({ data: "texto" });   // outputFormat por defecto "buffer"

// HMAC: añadir la clave en `key`
var hmac = crypto.sha256({ data: "texto", key: "miSecretoHmac", outputFormat: "hex" });

// Volcar a fichero
crypto.sha256({ data: "texto", output: appData.getFilesPath() + "/hash.bin" });

// Otros patrones (mismo objeto-argumento, claves según cada método)
var nuevoUuid = crypto.getNewUuid();             // sin args
var num       = crypto.getRandomInt({ min: 0, max: 100 });
var b64       = crypto.toBase64({ data: "hola", outputFormat: "string" });
```

> **AVISO**: `crypto.md5("texto")` con un String literal **lanza `ClassCastException`**. Siempre pasar el objeto.

### 6.3 clipboard

```js
clipboard.setText(self.getValue("CODIGO"));
ui.showToast("Código copiado: " + clipboard.getText());
```

### 6.4 deviceInfo

| Método | Descripción |
|---|---|
| `getBatteryLevelPercentage()` → `int` | Porcentaje de batería. |
| `getBatteryTemperature()` → `float` | Temperatura de batería (°C). |
| `getMobileNetworkSignalStrength()` → `int` | Intensidad de señal móvil. |
| `getConnectedMobileNetworkType()` → `String` | Tipo de red (`"4G"`, `"5G"`, `"WiFi"`...). |
| `getOpenGlVersion()` → `double` | Versión OpenGL ES. |
| `isArCompatible()` → `boolean` | Compatibilidad ARCore. |

```js
appData.writeConsoleString("Bateria: " + deviceInfo.getBatteryLevelPercentage() + "%");
```

### 6.5 systemSettings

| Método | Descripción |
|---|---|
| `isRunningInMdm(...)` → `boolean` | `true` si la app está gestionada por MDM. |
| `isPasswordSecured()` → `boolean` | Dispositivo con PIN/password configurado. |
| `getBrightness()` → `double` | Brillo de la pantalla, rango **0 - 100**. |
| `setBrightness(value)` → `boolean` | Cambia el brillo. Acepta 0 - 100 (se clampa fuera de rango). |
| `getBrightnessMode()` / `setBrightnessMode(mode)` | Modo de brillo: `"manual"` o `"automatic"`. |
| `getDeviceId()` → `String` | Identificador único del dispositivo. |
| `getHardwareIds()` → `Map` | Mapa con todos los identificadores hardware. |
| `requestPermissions(...)` → `Future` | Solicita permisos en runtime. |
| `getApiLevel()` / `getAndroidVersion()` | API level (`Build.VERSION.SDK_INT`) y versión Android (string). |
| `getManufacturer()` / `getDeviceModel()` / `getBrand()` → `String` | Fabricante, modelo y marca del dispositivo. Equivalen a las macros `##DEVICE_MANUFACTURER##` / `##DEVICE_MODEL##`. |
| `getMemoryLevel()` → `String` | Nivel de presión de memoria del SO. Ver §8.11b. |
| `getInternalFreeSpace()` / `getInternalTotalSpace()` → `long` | Espacio libre / total (en bytes) del almacenamiento **interno** (la partición de datos donde residen la app y su BD). |
| `getExternalFreeSpace()` / `getExternalTotalSpace()` → `long` | Espacio libre / total (en bytes) del almacenamiento **externo** principal. Devuelven `0` si no está montado. |

Catálogo completo de métodos por área (brillo, red, batería, permisos, memoria, hardware, rutas, MDM, XOneLive, Intune, Analytics, etc.) en [03d-js-createobject.md §8.11b](03d-js-createobject.md#811b-systemsettings---configuracion-y-estado-del-sistema).

```js
if (systemSettings.getBrightness() < 50) systemSettings.setBrightness(80);
```

### 6.6 packageManager

Métodos disponibles: `getPackageInfo(pkg)`, `isInstalled(pkg)`, `getInstalledPackages()`, `getInstalledPackageNames()`, `installPackage(...)`, `getRunningApps()`, `isPackageInstallPermissionGranted()`, `isAppSuspended(pkg)`, `getInstalledModules()`, `getAllPermissionGroups()`, `getPermissionsByGroup(group)`, `getPackageName()`, `getInstallerPackageName(pkg)`.

```js
// getInstalledApps() NO existe — usar getInstalledPackages() o getInstalledPackageNames()
var apps    = packageManager.getInstalledPackages();
var nombres = packageManager.getInstalledPackageNames();
var isInstalled = packageManager.isInstalled("com.empresa.otra");
```

### 6.7 biometricsManager / fingerprintManager

- **`biometricsManager`** — API moderna (preferida). Huella, face ID, firma biometrica.
- **`fingerprintManager`** — API legacy. Usar `biometricsManager` en nuevos desarrollos.

| Método | Descripción |
|---|---|
| `isHardwareAvailable()` → `boolean` | Hardware biometrico presente. |
| `hasEnrolledFingerprints()` → `boolean` | Hay huellas registradas. |
| `launch()` | Lanza el dialogo de autenticación. |
| `listen()` / `stopListening()` | Escucha continua de eventos biometricos. |

```js
if (biometricsManager.isHardwareAvailable() && biometricsManager.hasEnrolledFingerprints()) {
    biometricsManager.launch();
}
```

### 6.8 bleManager

```js
bleManager.startScan({
    onDeviceFound: function(device) {
        appData.writeConsoleString("BLE: " + device.name + " " + device.address);
    }
});
```

### 6.8b bleSerial (BleSerialPort)

Cliente Bluetooth Low Energy basado en el manager Telit, expuesto como **singleton** (acceso directo `bleSerial`, sin `new`). Solo accesible desde JavaScript. Requiere API 18+.

| Método | Parámetros | Retorno | Descripción |
|---|---|---|---|
| `setDebugMode(enabled)` | 1 boolean | `void` | Activa logs verbosos en el manager Telit. |
| `startLeScan(callback, timeout?)` o `startLeScan({callback, timeout?})` | 1..2 args | `void` | Inicia escaneo BLE. `callback(name, macAddress)` se invoca con el primer dispositivo encontrado y entonces el scan se detiene. `timeout` en ms (0 = sin límite). |
| `stopLeScan()` | ninguno | `void` | Detiene el escaneo. |
| `connect(macAddress, timeoutMs?)` o `connect({macAddress, timeout?, onConnected?, onError?})` | 1..4 args | `void` | Conecta al dispositivo BLE. Sin callbacks es síncrono; con `onConnected`/`onError` es asíncrono. Timeout por defecto 10000 ms. |
| `disconnect()` | ninguno | `void` | Encola un `DisconnectRequest` en el manager. |
| `write(value)` | 1 (String o Number) | `void` | Envía a la característica de escritura. Strings vía `writeString`; números vía `writeUint8`. |
| `setNotificationCallback(uuid, callback)` | 2 (String, Function) | `void` | Suscribe notificaciones de la característica `uuid`; el callback recibe el String recibido. Habilita notificaciones automáticamente. |
| `readString(callback?)` | 0..1 args | `String` | Lee un String de la característica de lectura (trim de `\r\n` final). |
| `readUint8(callback?)` | 0..1 args | `int` | Lee un byte como int sin signo. |

```js
// bleSerial es singleton: NO se hace `new BleSerialPort()`
bleSerial.startLeScan(function(name, mac) {
    appData.writeConsoleString("Encontrado " + name + " (" + mac + ")");
    bleSerial.connect({
        macAddress: mac,
        timeout   : 8000,
        onConnected: function() {
            bleSerial.setNotificationCallback(
                "0000ffe1-0000-1000-8000-00805f9b34fb",
                function(data) { appData.writeConsoleString("RX: " + data); }
            );
            bleSerial.write("AT\r\n");
        },
        onError: function(status) { appData.writeConsoleString("Error " + status); }
    });
}, 15000);
```

### 6.9 sensorManager

| Método | Descripción |
|---|---|
| `getSensorList()` → `Object[]` | Lista de sensores disponibles. |
| `getSensor(type)` | Obtener un sensor concreto. |
| `getDisplayOrientation()` → `int` | Orientacion de la pantalla en grados. |
| `listen({type, onSensorChanged, onSensorAccuracyChanged?, sampling?})` | Inicia escucha. **Toma 1 NativeObject**, NO `(sensor, callback)`. |
| `stopListening({type})` o `stopListening()` | Si pasas `{type}` desuscribe ese sensor; sin argumento (o con string) desuscribe **TODOS**. |
| `listenForFalls({onFallDetected, sensitivity?, sampling?})` | Activa detección de caídas. Toma 1 NativeObject, no una funcion suelta. |
| `stopListeningForFalls()` | Desactiva. |

```js
// Firma correcta: objeto de configuración con clave `type` y callback `onSensorChanged`
sensorManager.listen({
    type: "accelerometer",
    onSensorChanged: function(event) {
        appData.writeConsoleString("X:" + event.x + " Y:" + event.y + " Z:" + event.z);
    }
});
// sensorManager.stopListening({ type: "accelerometer" }); // sólo ese sensor
```

### 6.10 paymentManager

Pasarelas de pago. Singleton global: se obtiene un proveedor concreto con
`paymentManager.getProvider(nombre)` y se opera sobre él. Proveedores disponibles: `"redsys"`,
`"googlepay"`, `"tpv_comercia"` (Smartphone TPV de Comercia / Global Payments) y `"bbva_cobros"`
(BBVA Cobros).

Patrón común a todos: `setupProvider({...})` una vez para configurar, y después las operaciones,
que reciben callbacks **asíncronos** `onResult(self, r)` y `onError(self, e)` (el resultado llega
cuando la pasarela responde, no en la misma línea).

#### Proveedor "tpv_comercia" (Smartphone TPV — App2App)

Convierte el propio móvil en datáfono por NFC. No usa ninguna librería de pago: delega en una
**app externa** de Comercia (`com.comercia.app`), que debe estar instalada; el framework se
comunica con ella y entrega la respuesta a los callbacks.

**Requisitos:** Android 9 o superior, dispositivo con NFC, la app de Smartphone TPV instalada, y el
APK del comercio firmado con una clave cuyo SHA‑256 esté dado de alta en la whitelist de Comercia
(paso de alta previo imprescindible; sin él la comunicación se rechaza).

**Configuración** (`setupProvider`, una vez) — los valores de registro los **asigna Comercia** en
el alta del comercio/terminal:

| Parámetro | Descripción |
|---|---|
| `merchantId` | Número de comercio (obligatorio) |
| `terminalId` | Número de terminal (obligatorio) |
| `activationCode` | Código de activación (obligatorio) |
| `packageName` | Paquete de la app externa (opcional; por defecto `com.comercia.app`) |
| `appName` | Nombre visible de la app externa (opcional) |

**Operaciones** (todas admiten `onResult`/`onError`):

| Método | Qué hace |
|---|---|
| `payment({...})` | Venta o devolución. `transactionType`: `"200"` venta (por defecto), `"300"` devolución (requiere `transactionId`). `amount` en la unidad menor (p.ej. `"1400"` = 14,00 €). Opcionales: `orderId`, `configParameters` (visibilidad de botones: `drawerMenu`, `salesButton`, `voidButton`, `refundButton`, `historyButton`, `settingsButton`, `tipScreen`, `userPhoto`), `customMessage` |
| `getLastTransaction({...})` | Consulta la última transacción |
| `gotoList({...})` | Abre un listado. `listType`: `"3000"` devoluciones, `"5000"` historial |
| `onlyRegister({...})` | Registra el terminal sin realizar cobro |
| `manualSettlement({...})` | Cierre / liquidación manual |

`requestPaymentReference` no aplica a este proveedor (no hay pre‑autorización por referencia).

En `onResult` de un pago llega un objeto con `transactionStatus` (`"success"`/`"decline"`),
`transactionId`, `amount`, `maskedPan`, `refusalCode`, `transactionDate`, `transactionType`…; en
`onError`, el código/mensaje `a2aCode`/`a2aMessage` (o el detalle de la operación declinada).

```js
var tpv = paymentManager.getProvider("tpv_comercia");
tpv.setupProvider({
    merchantId: "329811087",
    terminalId: "00000025",
    activationCode: "000000"
});
var miSelf = self;                               // preservar self para el callback asíncrono
tpv.payment({
    amount: "1400",                              // 14,00 EUR (unidad menor)
    transactionType: "200",                      // venta
    orderId: "" + (new Date()).getTime(),
    configParameters: { refundButton: "1", tipScreen: "0" },
    onResult: function (s, r) { miSelf.MAP_RESP = r.transactionStatus + " " + r.transactionId; ui.refresh("MAP_RESP"); },
    onError:  function (s, e) { miSelf.MAP_RESP = "Error: " + e.a2aMessage; ui.refresh("MAP_RESP"); }
});
```

#### Proveedor "bbva_cobros" (BBVA Cobros — App2App)

Más simple que `tpv_comercia`: lanza la app externa de BBVA Cobros por intent y recibe el resultado
por broadcast; sin servicio, sin handshake y **sin credenciales** que configurar (BBVA Cobros ya va
contratado en el dispositivo, con el acceso automático activo).

**Importante:** el importe va en **euros** (p.ej. `"12.50"` = 12,50 €), **no** en la unidad menor
(al contrario que `tpv_comercia`).

**Operaciones** (todas admiten `onResult`/`onError`):

| Método | Qué hace |
|---|---|
| `payment({...})` | Venta. `amount` en euros (obligatorio) |
| `refund({...})` | Devolución. `amount` (euros) + `idRTS` (el RTS de la venta original), obligatorios |
| `getFuc({...})` | Consulta el FUC y el terminal (devuelve `id_fuc`, `id_terminal`) |

No necesita `setupProvider` (sin credenciales ni configuración; el paquete de la app de BBVA es
fijo). `requestPaymentReference` no aplica.

La respuesta trae `SmartPay_Payment_Result` (`"OK"`/`"KO"`/`"UNKNOWN"`; `OK` dispara `onResult`, el
resto `onError`), `Amount`, `IdRTS`, `id_terminal`, `id_fuc`.

```js
var bbva = paymentManager.getProvider("bbva_cobros");
var miSelf = self;
bbva.payment({
    amount: "12.50",                             // euros, NO céntimos
    onResult: function (s, r) { miSelf.MAP_RESP = r.SmartPay_Payment_Result + " RTS:" + r.IdRTS; ui.refresh("MAP_RESP"); },
    onError:  function (s, e) { miSelf.MAP_RESP = "KO: " + e.SmartPay_Payment_Result; ui.refresh("MAP_RESP"); }
});
// Devolución con el RTS de la venta:  bbva.refund({ amount: "12.50", idRTS: "0750022...", onResult: ..., onError: ... });
// Consulta del FUC:                   bbva.getFuc({ onResult: function (s, r) { /* r.id_fuc, r.id_terminal */ } });
```

### 6.11 pushMessage / push

Mensajeria push via Firebase Cloud Messaging.

Métodos disponibles: `getToken()`, `getFirebaseInstanceId()`, `sendMessageFirebase(...)`.

> **Nota**: NO existe `pushMessage.subscribe(topic)`. La suscripcion a topics se gestiona en el backend o registrando el token mediante la consola de Firebase. El cliente solo expone el token.

```js
var token = pushMessage.getToken();              // obtener token FCM
var instanceId = pushMessage.getFirebaseInstanceId();
// pushMessage.sendMessageFirebase(...);          // envio device-to-device
```

### 6.12 appBroadcastManager

Broadcasts entre diferentes apps XOne instaladas en el dispositivo.

### 6.14 replica

Sistema de replicación / sincronización XOne.

### 6.15 live

Sistema de Live Update — gestion de actualizaciones en caliente del proyecto.

### 6.16 smsService

Envío y recepción de SMS. Requiere `<permission name="sms"/>` dentro del nodo `<permissions>` de la coll.

### 6.17 serial / bluetoothSerial / bleSerial

Puertos serie genericos:
- `serial` — Serie USB / RS232.
- `bluetoothSerial` — Serie sobre Bluetooth clasico.
- `bleSerial` — Serie sobre BLE.

### 6.18 efiDiagItv

Diagnostico EFI / ITV (especifico de equipos Itron).

### 6.19 ml

API de Machine Learning generico (TensorFlow Lite).

### 6.20 ai

IA generativa **local** (LLM on-device): ejecuta modelos de lenguaje dentro del dispositivo, sin servidor. Singleton global. API extensa (descarga de modelos, carga, generación, chat con streaming, herramientas, skills, multimodal imagen/audio). Documentación completa en su propio archivo: [08-objeto-ai.md](08-objeto-ai.md).
