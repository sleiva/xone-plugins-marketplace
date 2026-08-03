# JavaScript API — Objetos Complementarios (createObject) y Singletons

Sub-archivo del [Tópico 03 - Guía Completa de JavaScript](03-javascript-api-guide.md). Cubre objetos especializados creables con `new NombreTipo()` o `createObject("NombreTipo")` (FileManager, XOnePDF, XOnePrinter, BarcodeGenerator, XOneNFC, XOneOCR, WifiManager, Animation, GpsTools, WebSocket, etc.) y singletons globales (`deviceInfo`, `systemSettings`, `bluetoothSerial`, `fingerprintManager`, etc.).

> Ver también el **catálogo completo y autoritativo** de creables y singletons en el sub-archivo 06 ([06-javascript-runtime-objects.md](06-javascript-runtime-objects.md)).

## Tabla de Contenidos

- [8.1 FileManager](#81-filemanager---gestion-de-archivos)
- [8.2 XOnePDF](#82-xonepdf---generacion-de-pdf)
- [8.3 XOnePrinter](#83-xoneprinter---impresion-bluetooth)
- [8.4 BarcodeGenerator](#84-barcodegenerator---generacion-de-codigos)
- [8.5 Datawedge (scanner hardware Symbol/Zebra)](#85-datawedge-scanner-hardware-symbolzebra)
- [8.6 XOneNFC](#86-xonenfc---lecturaescritura-nfc)
- [8.7 XOneOCR](#87-xoneocr---reconocimiento-optico-de-caracteres)
- [8.8 BluetoothSerialPort](#88-bluetoothserialport---comunicacion-bluetooth-serial)
- [8.9 WifiManager](#89-wifimanager---gestion-wifi)
- [8.10 Animation](#810-animation---animaciones-programaticas)
- [8.11 deviceInfo](#811-deviceinfo---informacion-del-dispositivo)
- [8.11b systemSettings](#811b-systemsettings---configuracion-y-estado-del-sistema)
- [8.12 GpsTools](#812-gpstools---herramientas-gps)
- [8.13 OAuth2](#813-oauth2---autenticacion-oauth2)
- [8.14 WebSocket](#814-websocket---websocket-de-xone)
- [8.15 fingerprintManager](#815-fingerprintmanager---gestor-de-huellas-singleton-global)

---

## 8. Objetos Complementarios (createObject)

XOne proporciona objetos especializados que se crean mediante `createObject("NombreTipo")` o `new NombreTipo()`. También existen singletons globales que no requieren instanciacion.

### 8.1 FileManager - Gestión de Archivos

Manejo completo de ficheros y directorios: lectura/escritura, listado, copia/movimiento, compresión, descarga/subida HTTP, caché de la app y watchers de cambios.

```javascript
let fm = new FileManager(); // o createObject("FileManager")
```

#### Lectura y escritura

```javascript
let contenido = fm.readFile("datos.json");                  // UTF-8 por defecto
let raw       = fm.readFile("archivo.bin", "ISO-8859-1");   // Encoding opcional (2º param)

fm.saveFile("notas.txt", "Contenido");                       // Crea / sobreescribe
fm.saveFile("notas.txt", "Más texto", true);                 // 3er param: append
fm.saveFile("datos.txt", "texto", false, "ISO-8859-1");      // 4º param: encoding (default UTF-8)
// saveFile acepta también byte[] como segundo argumento
```

#### Existencia y metadatos

`fileExists` / `directoryExists` siguen convención C: retornan **0 si existe**, **-1 si no**.

```javascript
if (fm.fileExists("documento.pdf") === 0) { /* existe */ }
if (fm.directoryExists("cache/") === 0)   { /* existe */ }

let bVacio = fm.isDirectoryEmpty("cache/");
let dFecha = fm.getLastModifiedDate("documento.pdf"); // Date

// Bytes (fichero) o tamaño agregado del árbol (directorio)
let nBytes = fm.getSize("documento.pdf");

// Metadatos completos en un solo objeto
let info = fm.getFileInfo("documento.pdf");
// info.size, info.creationDate (ms; 0 en Android < 8), info.modificationDate (ms)
// info.isHidden, info.canRead, info.canExecute, info.canWrite
```

#### Listar contenido

```javascript
let aFiles = fm.listFiles("descargas/");        // Array de paths absolutos
let aDirs  = fm.listDirectories("descargas/");  // Sólo subdirectorios

// listFiles con filtros (orderBy: "date_desc" o "name"; fechas en dd/MM/yyyy)
let aPdfs = fm.listFiles({
    source   : "descargas/",
    fileTypes: ["pdf", "doc"],     // extensiones a aceptar
    orderBy  : "date_desc",        // "date_desc" | "name" | ""
    dateFrom : "01/01/2026",
    dateTo   : "31/12/2026"
});
```

#### Copiar, mover, renombrar, borrar

Todos retornan **0 si OK**, **-1 si fallo**.

```javascript
fm.copy("origen.txt", "destino.txt");
fm.move("viejo.txt", "nuevo.txt");
fm.rename("archivo.txt", "renombrado.txt");
fm.delete("temporal.txt");
fm.delete("a.txt", "b.txt", "c.txt"); // delete acepta varios paths (se procesa hasta el primer fallo)
```

#### Directorios

```javascript
let nResult = fm.createDirectory("nuevo/subdir");
// 0 = creado, 1 = ya existe como directorio, 2 = existe como fichero, -1 = error
fm.deleteDirectory("temp/"); // recursivo, 0 OK / -1 fallo
```

#### Compresión (zip / unzip)

```javascript
fm.zip("documento.pdf");                  // -> "documento.pdf.zip" (mismo path)
fm.zip("documento.pdf", "comprimido.zip");
fm.zip("carpeta/", "carpeta.zip");        // Zip recursivo del directorio

// zipAll: comprimir varios ficheros/arrays en un solo zip
fm.zipAll("paquete.zip", "a.txt", "b.txt", ["c.txt", "d.txt"]);

// zipAll con objeto (permite password)
fm.zipAll({
    targetZip: "cifrado.zip",
    password : "secreto",
    files    : ["a.txt", "b.txt"]
});

fm.unzip("paquete.zip");                  // Al directorio padre del zip
fm.unzip("paquete.zip", "destino/");
fm.unzip("cifrado.zip", "destino/", "secreto"); // 3er param: password
```

#### Conversiones (base64, checksum)

```javascript
let sBase64 = fm.toBase64("imagen.jpg");
fm.toFile(sBase64, "imagen_copia.jpg");

// Tipos: "crc32" (default), "adler32", "sha1", "sha2", "sha256", "sha512"
let sCrc = fm.getChecksum("archivo.bin");                  // CRC32
let sSha = fm.getChecksum("archivo.bin", "sha256");
let sUrl = fm.getChecksum("archivo.bin", "sha256", true);  // 3er param urlSafe: Base64 URL-safe
```

#### Descarga y subida HTTP

`download` tiene dos formas:

```javascript
// Forma síncrona (legacy): bloquea, retorna 0 OK / -1 fallo
let nResult = fm.download("https://ejemplo.com/archivo.pdf", "archivo.pdf");
if (nResult === 0) { ui.openFile("archivo.pdf"); }

// Forma asíncrona con objeto: retorna Future, callbacks en JS
let future = fm.download({
    source : "https://ejemplo.com/archivo.pdf",
    target : "archivo.pdf",
    method : "GET",                                // "GET" o "POST"
    headers   : { "X-Api-Key": "xxx" },
    parameters: { id: "123" },                     // Body JSON
    unzip          : false,                        // Descomprimir automáticamente al terminar
    resumeEnabled  : false,                        // Reanudar descargas parciales
    allowUnsafeCertificates: false,
    onSuccess : function(sPath) { ui.openFile(sPath); },
    onProgress: function(nPercent) { /* 0-100 */ },
    onError   : function(nStatus, sMessage) { /* fallo */ }
});

// Subir fichero (multipart/form-data, versión 2 por defecto)
let sRespuesta = fm.uploadFile({
    url     : "https://ejemplo.com/upload",
    file    : "notas.txt",
    version : 2,                                   // 1 = legacy, 2 = moderno (default)
    headers : { Authorization: "Bearer xxx" },
    parameters: { VERSIONAPP: "1.0" },
    allowUnsafeCertificates: false,
    onSuccess : function(sResponse) { /* OK */ },
    onProgress: function(nPercent) { /* 0-100 */ },
    onError   : function(nStatus, sMsg) { /* fallo */ }
});
```

#### Bases de datos SQLite

```javascript
// Cierra conexión abierta, descarga el .db remoto y lo reemplaza atómicamente
fm.downloadDatabase("https://ejemplo.com/datos.db");

// Borra .db + .db-wal + .db-shm; cierra conexión abierta si la hay
fm.deleteDatabase("temporal.db");
```

#### Apertura con la app del sistema

```javascript
fm.openFile("documento.pdf");                   // Lanza ACTION_VIEW con MIME detectado
fm.openFile("https://ejemplo.com/manual.pdf");  // URL: descarga a caché y abre
// APK: bloqueado en builds de Play Store; permitido en standalone
```

#### Rutas internas de la app

Estas rutas son de **almacenamiento privado** del proceso Android, distintas del path de la app XOne (`appData.getAppPath()`).

```javascript
let sRoot      = fm.getRootDirectory();      // /data/data/<package>/  (datos privados)
let sCache     = fm.getCacheDirectory();     //  ".../cache"
let sCodeCache = fm.getCodeCacheDirectory(); //  ".../code_cache"  (dex compilados)

// Limpiar caché (uno de los dos parámetros es obligatorio)
fm.clearCache({ maxSize: 50 * 1024 * 1024 });          // Si supera 50 MB -> vacía entero
fm.clearCache({ maxSize: 0 });                          // Vacía siempre
fm.clearCache({ olderThan: new Date(2026, 0, 1) });    // Borra ficheros anteriores a la fecha
```

#### Watchers de cambios en directorio

Notifica cuando se crean, modifican o borran ficheros/subdirectorios en un directorio.

```javascript
fm.addOnDirectoryChangedListener("descargas/", function(sEvent, sPath) {
    // sEvent: "create" | "delete" | "deleteSelf" | "modify"
    //       | "movedFrom" | "movedTo" | "moveSelf"
    //       | "folderCreated" | "folderDeleted"
    // sPath: nombre del fichero/subdir afectado (no incluye el directorio observado)
    ui.showToast(sEvent + ": " + sPath);
});

fm.removeOnDirectoryChangedListener("descargas/"); // Detener observación
```

### 8.2 XOnePDF - Generación de PDF

```javascript
var pdf = new XOnePDF();
pdf.create("mi_documento.pdf");
pdf.permissions("print");
pdf.setEncryption("", "1234", "128bits");
pdf.open();

// Configurar fuente
pdf.setFont("helvetica");
pdf.setFontSize(12);
pdf.setFontStyle("bold");
pdf.setFontColor("#000000");

// Agregar contenido
pdf.addText("Titulo del documento");
pdf.newLine();
pdf.addTextLine("Línea de texto completa");

// Tabla de 3 columnas
pdf.createTable(3);
pdf.setTableWidth(100);
pdf.setTableCellWidths(33, 33, 33);
pdf.setCellBorder("all");
pdf.setAlignment("center");
pdf.addCellText("Columna 1", "#EEEEEE");
pdf.addCellText("Columna 2", "#EEEEEE");
pdf.addCellText("Columna 3", "#EEEEEE");
pdf.addTable();

// Imagen
pdf.addImageSetXY("logo.png", 0, 0, 150, 75);

pdf.newPage();
pdf.close();
pdf.launchPDF();
```

**Extraer el texto de un PDF existente** (p. ej. para leerlo o procesarlo). `extractText(rutaPdf)` devuelve el texto plano; `extractTextToFile(rutaPdf, rutaTxt)` lo vuelca a un `.txt` en UTF-8 y devuelve su ruta. Solo extraen la capa de texto: un PDF escaneado (imágenes sin texto) devuelve vacío, no hacen OCR. Son síncronos.

```javascript
var pdf = new XOnePDF();
var texto   = pdf.extractText("documento.pdf");                        // a variable
var rutaTxt = pdf.extractTextToFile("documento.pdf", "documento.txt"); // a fichero .txt (UTF-8)
```

### 8.3 XOnePrinter - Impresion Bluetooth

```javascript
var mPrinter = new XOnePrinter();
mPrinter.setDriver("zebra");
mPrinter.setDelay(0);
mPrinter.useStoredPrinter();
mPrinter.connect();
mPrinter.setMaxCharacterWidth(45);
mPrinter.printImage("logo.png", 600, 300, "center", 0);
mPrinter.printLineCentered("Texto centrado");
mPrinter.printLineCentered("---------------------------");
mPrinter.disconnect();
```

### 8.4 BarcodeGenerator - Generación de Códigos

```javascript
var generator = new BarcodeGenerator();
generator.setType("qrcode");  // code128, code39, ean13, qrcode, datamatrix, etc.
generator.setResolution(640, 480);
generator.setDestinationFile("qrcode.png");
generator.generate("Contenido del código");
ui.openFile("qrcode.png");

// Forma rápida
var sFile = new BarcodeGenerator().generate("texto");
ui.openFile(sFile);
```

**Tipos soportados:** `codabar`, `code128`, `code39`, `code93`, `datamatrix`, `qrcode`, `upca`, `upce`, `ean13`, `ean8`, `pdf417`

### 8.5 Datawedge (scanner hardware Symbol/Zebra)

Para scanners Symbol/Zebra (terminales TC, MC, PDA industriales) que usan el servicio DataWedge, hay que definir un perfil que redirija los escaneos a la aplicación XOne via intent broadcast.

```javascript
function addDataWedgeProfile() {
    let sDeviceOs = appData.getGlobalMacro("##DEVICE_OS##");
    if (sDeviceOs != "android") return;

    let mainBundle = new Bundle();
    mainBundle.PROFILE_NAME    = "XOne";
    mainBundle.PROFILE_ENABLED = "true";
    mainBundle.CONFIG_MODE     = "CREATE_IF_NOT_EXIST";
    mainBundle.RESET_CONFIG    = "true";

    let appBundle = new Bundle();
    appBundle.PACKAGE_NAME  = systemSettings.getPackageName();
    appBundle.ACTIVITY_LIST = ["*"];
    mainBundle.APP_LIST = [appBundle];

    let pluginConfig = new Bundle();
    pluginConfig.PLUGIN_NAME        = "BDF";
    pluginConfig.RESET_CONFIG       = "true";
    pluginConfig.OUTPUT_PLUGIN_NAME = "KEYSTROKE";

    let paramBundle = new Bundle();
    paramBundle.bdf_enabled     = "true";
    paramBundle.bdf_send_enter  = "true";
    pluginConfig.PARAM_LIST = paramBundle;
    mainBundle.PLUGIN_CONFIG = pluginConfig;

    let intent = new AndroidIntent();
    intent.setAction("com.symbol.datawedge.api.ACTION");
    intent.putBundleExtra("com.symbol.datawedge.api.SET_CONFIG", mainBundle);
    intent.sendBroadcast();
}
```

**Configuración manual en el dispositivo** (cuando `addDataWedgeProfile` no es suficiente):

1. Abrir la aplicación DataWedge del terminal.
2. Deshabilitar o borrar todos los perfiles existentes.
3. Crear un perfil nuevo.
4. En **Associated apps**, asociar `com.xone.framework.EditView` y `com.xone.framework.EditViewBGCOOR`.
5. Deshabilitar **SimulScan Input**.
6. Deshabilitar **Keystroke Output**.
7. Habilitar **Intent Output** con:
   - Intent action: `com.symbol.datawedge.DWDEMO`
   - Intent category: `Android.intent.category.DEFAULT`
   - Intent delivery: **Broadcast intent**

### 8.6 XOneNFC - Lectura/Escritura NFC

```javascript
var nfc = new XOneNFC();

// Lectura DNI electrónico
nfc.enableDnieReader({
    readProfileData: true,
    readUserImage: true,
    canNumber: "123456789",
    onDnieRead: function(result) {
        var nombre = result.getName();
        var apellido = result.getSurname();
        var dni = result.getDniNumber();
        var foto = result.getUserImage(appData.getFilesPath() + "foto.png");
    },
    onDnieReadError: function(sError) {
        ui.showToast("Error NFC: " + sError);
    }
});

// Escritura/Lectura NDEF
nfc.writeNdefMessageAsync("Texto para NFC", function(result) {
    ui.showToast("Escrito correctamente");
});
nfc.readNdefMessageAsync(function(result) {
    ui.showToast("Leido: " + result);
});
```

### 8.7 XOneOCR - Reconocimiento Optico de Caracteres

```javascript
var ocr = new XOneOCR();
var matricula = ocr.scanLicensePlate("foto_coche.jpg");
// OCR genérico de texto: ocr.scanText(...) NO está implementado actualmente (lanza UnsupportedOperationException).
// Usar scanLicensePlate() para matrículas o startScan({regex, onResult}) para validación por patrones.
```

### 8.8 BluetoothSerialPort - Comunicación Bluetooth Serial

Disponible como singleton global `bluetoothSerial`:

```javascript
var lstDevices = bluetoothSerial.getDiscoverableBluetoothDevices();
var device = null;
for (var i = 0; i < lstDevices.length; i++) {
    if (lstDevices[i].getDeviceName() == "mi_dispositivo") {
        device = lstDevices[i];
        break;
    }
}
if (device) {
    bluetoothSerial.connect(device.getMacAddress());
    bluetoothSerial.write("datos a enviar");
    var respuesta = bluetoothSerial.read(256);
    bluetoothSerial.disconnect();
}
```

### 8.9 WifiManager - Gestion WiFi

```javascript
var wm = new WifiManager(); // o createObject("WifiManager")

var wifiActivo = wm.isWifiAdapterEnabled();
var mac = wm.getAdapterMacAddress();
var info = wm.getActiveWifiInfo();
wm.connect("MiRed");
wm.disconnect();
wm.scanAvailableNetworks(function(redes) {
    // Procesar redes disponibles
});
```

### 8.10 Animation - Animaciones Programaticas

`Animation` usa una **API fluida encadenada**. El target es el **nombre del prop como string**, no el objeto control. Se instancia con `new Animation()`.

```javascript
// API fluida: encadenar metodos sobre el nombre del prop
new Animation()
    .setTarget("MAP_BOTON")       // Nombre del prop (string), no el control
    .setDuration(300)              // Duracion en milisegundos
    .setRelativeX(100)             // Mover 100p a la derecha
    .setRelativeY(-50)             // Mover 50p hacia arriba
    .setInterpolation("BounceInterpolator");

// Con callback al terminar
new Animation()
    .setTarget("MAP_BOTON")
    .setDuration(500)
    .setAlpha(0)
    .setEndCallback(function() {
        ui.showToast("Animacion completada");
    });

// Metodos disponibles
new Animation().setTarget("MAP_CTRL").setDuration(300)
    .setAlpha(0.5)
    .setX(500)                          // Posicion X absoluta (setY por separado)
    .setY(300)                          // Posicion Y absoluta
    .setRelativeX(100)
    .setRelativeY(100)
    .setZ(5)
    .setRelativeZ(10)
    .setScaleX(2.0)
    .setScaleY(0.5)
    .setRelativeScaleX(1.5)
    .setRelativeScaleY(1.5)
    .setWidth(400)
    .setHeight(200)
    .setRotation(180)
    .setRelativeRotation(45)
    .setBackgroundColor("#FF0000")
    .setCircularReveal(0, 0, true)      // (centerX, centerY, bReveal): true=mostrar, false=ocultar
    .setRepeatCount(2)
    .setRepeatMode(2)                    // 1 = restart, 2 = reverse (espera int, NO string)
    .setStartCallback(function() {})
    .setEndCallback(function() {})
    .cancel()                            // Cancela la animación en curso
    .stop(true);                         // stop requiere 1 boolean (true = completa la animación antes de cancelar)

// Interpolaciones disponibles:
// AccelerateDecelerateInterpolator (por defecto)
// BounceInterpolator, LinearInterpolator
// OvershootInterpolator, AccelerateInterpolator, AnticipateInterpolator
new Animation().setTarget("MAP_CTRL").setDuration(300)
    .setRelativeX(200)
    .setInterpolation("BounceInterpolator");
```

### 8.11 deviceInfo - Información del Dispositivo

`deviceInfo` es un **singleton global** — no requiere instanciacion con `new DeviceInfo()`. Accesible directamente como `deviceInfo`.

```javascript
// Bateria
let nPorcentaje  = deviceInfo.getBatteryLevelPercentage(); // 0-100
let nNivel       = deviceInfo.getBatteryLevel();           // valor raw
let nNivelMax    = deviceInfo.getBatteryMaxLevel();        // valor máximo raw
let nTemperatura = deviceInfo.getBatteryTemperature();     // decimas de grado -> / 10 para Celsius
let nVoltaje     = deviceInfo.getBatteryVoltage();         // milivoltios

// Red movil
let nSenal     = deviceInfo.getMobileNetworkSignalStrength(); // dBm (sin typo)
let sTipoRed   = deviceInfo.getConnectedMobileNetworkType();  // "LTE", "HSPA", etc.
let sEstadoRed = deviceInfo.getMobileNetworkState();          // "connected", etc.

// Trafico de red
let nBytesRx = deviceInfo.getRxBytes();
let nBytesTx = deviceInfo.getTxBytes();
```

> **Atención**: El método se llama `getMobileNetworkSignalStrength()` (sin typo). La documentación antigua lo listaba incorrectamente como `getMobileNetworkSignalStrengh`.

### 8.11b systemSettings - Configuración y Estado del Sistema

`systemSettings` es un **singleton global** — no requiere instanciacion. Solo Android salvo indicacion expresa.

#### Pantalla y brillo

```javascript
systemSettings.setBrightness(75);              // 0-100
let nBrillo = systemSettings.getBrightness();  // 0-100
systemSettings.setBrightnessMode("automatic"); // Brillo automático
systemSettings.setBrightnessMode("manual");    // Brillo manual
let sModo   = systemSettings.getBrightnessMode(); // "manual" o "automatic"

// Color de la barra de estado
let ventana = ui.getView(self);
ventana.setStatusBarColor("#1565C0");  // Color RRGGBB
ventana.setStatusBarColor(null);       // Restaurar color por defecto
```

#### Red y conectividad

```javascript
let bAvion    = systemSettings.isAirplaneMode();
let bDatosMov = systemSettings.isMobileDataEnabled(); // Puede mentir en algunos dispositivos
let bHttp     = systemSettings.isClearTextTrafficAllowed();

// Hora de red NTP
let fecha = systemSettings.getNetworkTime();
// Con servidor personalizado:
// let fecha = systemSettings.getNetworkTime({ ntpServer: "time.google.com" });

// Proveedores de localización disponibles
let bLoc  = systemSettings.hasLocationFeature();
let bRed  = systemSettings.hasNetworkLocationFeature();
let bGps  = systemSettings.hasGpsLocationFeature();
```

#### Batería y optimizaciones

```javascript
let bExenta = systemSettings.isIgnoringBatteryOptimizations();

// Pedir exencion de optimizaciones de bateria
if (!systemSettings.isIgnoringBatteryOptimizations()) {
    systemSettings.requestIgnoreBatteryOptimizations(true);
}

// Optimizaciones especificas de fabricante
systemSettings.requestIgnoreSpecialBatteryOptimizations();
```

#### Permisos en runtime

```javascript
// Consultar permisos
let aTodos        = systemSettings.getDeclaredPermissions();
let aConcedidos   = systemSettings.getGrantedPermissions();
let aNoConcedidos = systemSettings.getNotGrantedPermissions();

// Comprobar permiso (nombre corto XOne o nombre completo Android)
let bCamara  = systemSettings.isPermissionGranted("camera");
let bBateria = systemSettings.isPermissionGranted("android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS");

// Solicitar permisos en runtime — future.get() bloquea hasta respuesta del usuario
let future = systemSettings.requestPermissions({
    requestMessage: "Habilite estos permisos para usar la aplicación",
    mandatory     : false,
    permissions   : ["bluetooth"]
});
let bConcedidos = future.get();

// Revocar permisos (Android >= 13) — devuelve el propio systemSettings (encadenable)
systemSettings.revokePermissions("microphone", "camera");

// Permisos especiales (cada uno devuelve un Future)
let futureStorage = systemSettings.requestExternalStoragePermission();
let bStorage      = futureStorage.get();

// Overlay (dibujar sobre otras apps): primero consultar, después solicitar
let bOverlay = systemSettings.hasOverlayPermission();
if (!bOverlay) {
    let futureOverlay = systemSettings.requestOverlayPermission();
    bOverlay = futureOverlay.get();
}

let futureAlarm   = systemSettings.requestScheduleExactAlarmPermission();
let bAlarm        = futureAlarm.get();

// Auto-revocacion de permisos
if (systemSettings.isPermissionAutoRevokeEnabled()) {
    systemSettings.requestDisablePermissionAutoRevoke();
}

let bManager = systemSettings.isExternalStorageManager();
```

#### Memoria y rendimiento

```javascript
// Nivel de memoria actual
let sLevel = systemSettings.getMemoryLevel();
// Valores: "background", "moderate", "ui_hidden",
//          "running_moderate", "running_low", "running_critical", "complete"

try {
    let sNivel = systemSettings.getMemoryLevel();
    if (sNivel === "running_low" || sNivel === "running_critical" || sNivel === "complete") {
        ui.showToast("El dispositivo se esta quedando sin memoria");
    }
} catch(err) { /* puede no estar disponible en todas las versiones */ }

// Memoria de la JVM (en bytes)
let nMax  = systemSettings.getMaxMemory();
let nFree = systemSettings.getFreeMemory();

// RAM física del dispositivo (en bytes)
let nRamTotal = systemSettings.getTotalMemory();      // RAM física total instalada
let nRamLibre = systemSettings.getAvailableMemory();  // RAM física disponible ahora

// Espacio en disco (en bytes) — útil antes de descargas/exportaciones grandes
let nDiscoLibre = systemSettings.getInternalFreeSpace();   // libre en almacenamiento interno (app + BD)
let nDiscoTotal = systemSettings.getInternalTotalSpace();  // total del almacenamiento interno
let nExtLibre   = systemSettings.getExternalFreeSpace();   // libre en almacenamiento externo (0 si no está montado)
let nExtTotal   = systemSettings.getExternalTotalSpace();  // total del almacenamiento externo

let nMbLibres = Math.round(systemSettings.getInternalFreeSpace() / 1024 / 1024);
if (nMbLibres < 100) {
    ui.showToast("Quedan solo " + nMbLibres + " MB libres en disco");
}

systemSettings.garbageCollect();    // Devuelve el propio systemSettings (encadenable)
systemSettings.clearAllAppsCache();
systemSettings.clearApplicationData();
systemSettings.clearJavascriptCache();
systemSettings.clearBitmapCache();
systemSettings.mergeJavascriptCache(); // Compacta los .dex cacheados del motor JS
```

#### Información del dispositivo y hardware

```javascript
// Fabricante, modelo y marca del dispositivo
let sFabricante = systemSettings.getManufacturer(); // ej: "samsung"
let sModelo     = systemSettings.getDeviceModel();  // ej: "SM-G991B"
let sMarca      = systemSettings.getBrand();        // ej: "samsung"
// (equivalen a las macros globales ##DEVICE_MANUFACTURER## y ##DEVICE_MODEL##)

// IDs de hardware
let ids = systemSettings.getHardwareIds();
// ids.deviceIdCount, ids.deviceId0, ids.deviceId1, ... (IMEI)
// ids.wifiMacAddress, ids.androidId

let sDeviceId = systemSettings.getDeviceId();
systemSettings.setDeviceId("nuevo_id");

// Dispositivo con PIN/patron/password de bloqueo configurado
// Si la app es Device Owner / Profile Owner consulta DevicePolicyManager,
// si no, usa KeyguardManager.isDeviceSecure().
let bSecured = systemSettings.isPasswordSecured();

// Tiempo encendido del dispositivo
let uptime = systemSettings.getDeviceUptime();
// uptime.ms, uptime.days, uptime.hours, uptime.minutes

// Hardware disponible
let aFeatures = systemSettings.getFeatures();

// Teclado fisico
let bTeclado  = systemSettings.hasHardwareKeyboard();
let bQwerty   = systemSettings.hasQwertyKeyboard();
let b12Teclas = systemSettings.hasTwelveKeysKeyboard();

// Arquitectura del proceso
let b64Bit = systemSettings.is64Bit();

// Nombres de la app
let sPackage     = systemSettings.getPackageName();
let sSharedUserId= systemSettings.getSharedUserId();
```

#### Versiones de SO y de la app

```javascript
let nApiLevel    = systemSettings.getApiLevel();         // API level del SO (Build.VERSION.SDK_INT)
let sAndroidVer  = systemSettings.getAndroidVersion();   // Build.VERSION.RELEASE (ej: "14")
let nTargetSdk   = systemSettings.getTargetSdkVersion(); // targetSdk del APK
let nMinSdk      = systemSettings.getMinSdkVersion();    // minSdk del APK (Android >= 7 / API 24)
let nVersionCode = systemSettings.getVersionCode();      // versionCode del APK instalado
```

#### Proceso del sistema

```javascript
let nPid      = systemSettings.getPid();            // ID del proceso actual (Process.myPid)
let nUid      = systemSettings.getUid();            // UID Linux del proceso (Process.myUid)
let nTid      = systemSettings.getTid();            // ID del hilo actual (Process.myTid)
let nPriority = systemSettings.getThreadPriority(); // Prioridad nice del hilo actual

systemSettings.killProcess(nPid); // Mata el proceso indicado (uso avanzado)
```

#### Rutas del sistema de ficheros

```javascript
let sExternal   = systemSettings.getExternalStoragePath();
let sGaleria    = systemSettings.getGalleryPath();
let sDocumentos = systemSettings.getDocumentsPath();
let sMusica     = systemSettings.getMusicPath();
let sDescargas  = systemSettings.getDownloadsPath();
let sCapturas   = systemSettings.getScreenshotsPath();
let sTonos      = systemSettings.getRingtonesPath();
let sAlarmas    = systemSettings.getAlarmsPath();
```

#### Wallpaper

```javascript
systemSettings.setWallpaper("wallpaper.png");
systemSettings.getWallpaper(appData.getAppPath() + "files/wallpaper_guardado.png");
```

#### Acceso directo en pantalla de inicio

```javascript
systemSettings.addPinShortcut({
    id   : 1000,
    label: "Mi acceso directo",
    icon : "icono.png",
    extras: { parametro1: "valor1" }
});
```

#### Estado de la app y restricciones

```javascript
let bRestringida = systemSettings.isBackgroundRestricted();
let bDatosRestr  = systemSettings.isBackgroundDataDisabled();
let bInactiva    = systemSettings.isAppInactive();
let sRestriction = systemSettings.getAppRestrictionStatus();
systemSettings.showAppSettingsWindow();  // Devuelve el propio systemSettings (encadenable)

// Actualizacion desde Google Play
let bUpdate = systemSettings.checkMarketUpdate();
// let bUpdate = systemSettings.checkMarketUpdate("flexible"); // Posponer
if (bUpdate) { return; }
```

#### Perfil de trabajo y MDM

```javascript
let bWorkProfile = systemSettings.isRunningInWorkProfile();    // MDM perfil trabajo
let bDeviceOwner = systemSettings.isRunningWithDeviceOwner();  // MDM kiosko
let bHayMdm      = systemSettings.isRunningInMdm();
let bIntune      = systemSettings.isRunningInMdm("com.microsoft.windowsintune.companyportal");
let bXoneMdm     = systemSettings.isRunningInMdm("com.xone.live.services");
```

#### XOneLive

```javascript
systemSettings.enableReplicatorWidget();
systemSettings.disableReplicatorWidget();
systemSettings.enableLiveWidget();
systemSettings.disableLiveWidget();
let jsConfig = systemSettings.getLiveConfig();  // Objeto JS con config actual de XOneLive
```

#### Depuracion e integridad

```javascript
let bIntegro   = systemSettings.isDeviceIntegrityOk();           // Detecta root/emulador
let sToken     = systemSettings.getIntegrityToken("nonce_unico"); // Token Google Play
let bDebugger  = systemSettings.isDebuggerConnected();
appData.setDebugMode(!appData.isDebugMode());
```

#### Accesibilidad

```javascript
let bAccesib   = systemSettings.isAccessibilityEnabled();
let bTalkBack  = systemSettings.isTouchExplorationEnabled();
let bAutoStart = systemSettings.isAutoStartEnabled();
```

#### Ajustes del sistema (propiedades directas)

```javascript
// AUTO_TIME: hora automática de red
// Solo escribible en Android < 4.2 (SDK < 17). Superior: solo lectura.
let nSdk = appData.getGlobalMacro("##DEVICE_OSSDKCODE##");
if (nSdk < 17) {
    systemSettings.AUTO_TIME = 1;
} else {
    let nAutoTime = systemSettings.AUTO_TIME;
    // Equivalente: systemSettings.isNetworkAutoTimeEnabled()
}
```

#### Certificados (solo Android < 11)

```javascript
systemSettings.installCertificate({
    name: "Nombre descriptivo",
    file: "certificado.pem"
});
```

#### Intune (Microsoft Intune MDM)

```javascript
let bCompilacion = systemSettings.isIntuneCompilation();
let sPinRequired = systemSettings.isIntunePinRequired();
let sIntuneId    = systemSettings.getIntuneId();
let bOutdated    = systemSettings.isIntuneAgentOutdated();
let sMsg         = systemSettings.getIntuneAgentOutdatedMessage();
```

#### Firebase Analytics

Sólo funciona si el flavor de la app incluye Firebase Analytics; en builds sin Analytics ambos métodos devuelven `false`.

```javascript
systemSettings.setAnalyticsEnabled(true);  // Activar
systemSettings.setAnalyticsEnabled(false); // Desactivar (cumplir RGPD/opt-out)

// Registrar un evento (la clave "eventTag" del objeto es el nombre del evento; el resto, parámetros)
systemSettings.logAnalyticsEvent({
    eventTag : "purchase_completed",
    sku      : "item_001",
    amount   : 9.99,
    currency : "EUR"
});
```

### 8.12 GpsTools - Herramientas GPS

```javascript
var gps = new GpsTools();

// Distancia entre dos puntos (en metros)
var metros = gps.distanceTo([
    { latitude: 38.8685452, longitude: -6.8170906 },
    { latitude: 40.4167747, longitude: -3.70379019 }
]);

// Geocodificacion inversa
var result = gps.getAddressFromPosition("38.8862106, -7.0040345");

// Verificar si un punto esta dentro de un poligono
var bDentro = gps.containsLocation(
    "40.3633442, -1.0893794",
    ["38.8685452, -6.8170906", "40.4167747, -3.70379019", "41.3850632, 2.1734035"]
);

// Ultima posicion conocida
var location = gps.getLastKnownLocation();
```

### 8.13 OAuth2 - Autenticación OAuth2

(Documentado en detalle en [03c §6](03c-js-appdata-http.md#6-oauth2---autenticacion-oauth).)

```javascript
new OAuth2().withOptions({
    authority: "https://auth.servidor.com/identity",
    clientID: "mi_client_id",
    clientSecret: "mi_secret",
    scope: "openid profile",
    responseType: "code id_token",
    persistenceKey: "oauth_key",
    redirectUri: "com.miapp.oauth:/callback"
}).authenticate({
    onSuccess: function(result) { /* token en result.access_token */ },
    onError: function(err) { ui.showToast("Error: " + err); }
});
```

### 8.14 WebSocket - WebSocket de XOne

```javascript
var request = {
    url: "wss://miservidor.com/ws",
    onOpen: function() {
        console.log("WebSocket conectado");
    },
    onMessage: function(sData) {
        var datos = JSON.parse(sData);
        procesarMensaje(datos);
    },
    onError: function(error) {
        console.log("Error WS: " + error);
    },
    onClose: function() {
        console.log("WebSocket cerrado");
    }
};

var ws = new WebSocket(request);
ws.send(JSON.stringify({ tipo: "saludo", mensaje: "hola" }));
ws.close();
```

### 8.15 fingerprintManager - Gestor de Huellas (Singleton Global)

Objeto global que **no requiere** `createObject()`. Accesible directamente como `fingerprintManager`:

```javascript
fingerprintManager.setCallback({
    onSuccess: function(result) {
        var sPublicKey = result.getPublicKey();
        ui.showToast("Huella verificada");
    },
    onFailure: function(nError, sErrorMessage) {
        ui.showToast("Error: " + sErrorMessage);
    }
});
fingerprintManager.listen();

// Detener escucha
fingerprintManager.stopListening();

// Abrir configuración de huellas
fingerprintManager.launchFingerprintSettings();  // Android
fingerprintManager.launch();                      // iOS
```

---

**Anterior:** [03c - appData, $http, OAuth2](03c-js-appdata-http.md) · **Siguiente:** [03e - Patrones, seguridad y best practices](03e-js-patrones-buenas-practicas.md) · **Índice:** [03 - Guía JavaScript](03-javascript-api-guide.md)
