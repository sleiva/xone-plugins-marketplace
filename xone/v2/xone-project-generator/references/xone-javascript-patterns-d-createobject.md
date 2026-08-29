# JavaScript Patterns — createObject y singletons (dispositivo)

Sub-archivo de [xone-javascript-patterns.md](xone-javascript-patterns.md). Cubre los objetos creables con `new`/`createObject` (FileManager, BarcodeGenerator, XOnePDF, XOnePrinter, XOneNFC, XOneOCR, BluetoothSerialPort, WifiManager, Animation, GpsTools, WebSocket) y los singletons globales (deviceInfo, systemSettings, fingerprintManager, biometricsManager, bluetoothSerial).

## Tabla de Contenidos

- [2.7 FileManager](#27-filemanager)
- [2.10 GPS y Mapas](#210-gps-y-mapas)
- [2.11 Biometrics Manager](#211-biometrics-manager)
- [2.12 Objetos Complementarios](#212-objetos-complementarios)

---

### 2.7 FileManager

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

---

### 2.10 GPS y Mapas

#### 2.10.1 Control de Mapa

```javascript
let mapControl = ui.getView(self)["MAP_MAPA"];

let marker = mapControl.addMarker({
    title: "Mi Ubicación", latitude: 40.416775, longitude: -3.703790,
    rotation: 0, alpha: 1, draggable: false, anchor: "bottom",
    icon: "ic_marker.png", tag: "marcador_principal",
    onClick: function(evento) {
        ui.showToast("Marcador tag: " + evento.marker.getTag());
    }
});

marker.setVisible(true);
marker.setDraggable(false);
marker.setRotation(180);
marker.setAlpha(0.5);
marker.setAnchor("center");
marker.setIcon("ic_otro.png");
marker.setPosition({
    latitude: 40.5, longitude: -3.8, animate: true, duration: 500
});
marker.remove();

mapControl.zoomTo(40.416775, -3.703790, 15);
```

#### 2.10.2 Dibujar en el Mapa

```javascript
mapControl.drawLine({
    line: "ruta_principal", strokeColor: "#1976D2", strokeWidth: 5.0,
    mode: "normal",  // "normal", "dashed", "dotted", "mixed"
    locations: [
        { latitude: 40.0, longitude: -3.5 },
        { latitude: 40.5, longitude: -3.8 }
    ]
});

let circle = mapControl.drawCircle({
    location: { latitude: 40.416775, longitude: -3.703790 },
    visible: true, radius: 1000, pattern: "dashed",
    fillColor: "#2200FF00", strokeColor: "#4CAF50", strokeWidth: 3
});

mapControl.drawRoute({
    route: "Ruta_1",
    waypoints: [
        { latitude: 40.0, longitude: -3.5 },
        { latitude: 40.5, longitude: -3.8 }
    ],
    mode: "driving", strokeColor: "#1976D2",
    strokeWidth: 5.0, linePattern: "normal"
});

// Limpieza completa (rutas + lineas + areas + polylines + GeoJSON + KML)
mapControl.clearMap();

// O por partes
mapControl.clearAllRoutes();
mapControl.clearAllLines();
mapControl.clearAllAreas();
mapControl.clearAllPolylines();
mapControl.removeAllGeoJson();
mapControl.removeAllKml();
```

#### 2.10.3 Ubicación del Usuario en el Mapa

```javascript
let userLocation = mapControl.getUserLocation();
if (userLocation) {
    console.log("Lat: " + userLocation.latitude);
    console.log("Lng: " + userLocation.longitude);
    console.log("Vel: " + userLocation.speed);
    console.log("Precision: " + userLocation.accuracy);
}

mapControl.enableUserLocation();
mapControl.disableUserLocation();
let bEnabled = mapControl.isUserLocationEnabled();
```

#### 2.10.4 Eventos de Mapa

Definidos como atributos en el nodo `<prop>` del mapa en XML:

```javascript
function onMapClicked(evento) {
    console.log("Lat: " + evento.latitude + " Lng: " + evento.longitude);
}

function onMapLongClicked(evento) {
    // Pulsacion larga en el mapa
}

function onMapReady(evento) {
    // El mapa esta cargado y listo
    cargarMarcadores();
}

function onLocationChanged(evento) {
    console.log("Nueva pos: " + evento.latitude + ", " + evento.longitude);
}

function onMarkerDragEnd(evento) {
    console.log("Tag: " + evento.tag);
}
```

---

### 2.11 Biometrics Manager

```javascript
if (!biometricsManager.isHardwareAvailable()) {
    ui.showToast("Biometria no disponible");
    return;
}

if (!biometricsManager.hasEnrolledFingerprints()) {
    biometricsManager.launchSecuritySettings();
    return;
}

biometricsManager.setCallback({
    title: "Autenticacion", subtitle: "Verificar identidad",
    description: "Coloque su dedo en el sensor",
    negativeButtonText: "Cancelar",
    onSuccess: function(result) {
        let sPublicKey = result.getPublicKey();
        ui.showToast("Autenticación exitosa");
    },
    onFailure: function(nError, sErrorMessage) {
        ui.showToast("Error: " + sErrorMessage);
    }
    // Nota: `onHelp` no existe — la API moderna BiometricPrompt no expone callback de "help".
});
biometricsManager.launch();

// Firma digital con biometria
biometricsManager.setCallback({
    title: "Firma digital",
    onSuccess: function(result) {
        let sSigned = result.signWithPrivateKey("datos a firmar");
        self.MAP_FIRMA_DIGITAL = sSigned;
        self.save();
    }
});
biometricsManager.launch();

// Verificar firma
result.verify(publicKey, signature, "datos originales");

// Firmar/verificar archivos
result.signFileWithPrivateKey("documento.pdf", "documento_firmado.pdf");
result.verifyFile(publicKey, "documento_firmado.pdf", "documento.pdf");
```

---

### 2.12 Objetos Complementarios

XOne proporciona objetos especializados que se crean mediante `createObject("NombreTipo")` o `new NombreTipo()`. A continuacion se documenta cada uno con su descripción y ejemplo de uso.

#### 2.12.1 XOnePDF - Generación de PDF

Generación de documentos PDF con texto, tablas, imágenes y firma digital.

```javascript
var pdf = new XOnePDF();
pdf.create("factura.pdf");
pdf.permissions("assembly");
pdf.permissions("print");
pdf.setEncryption("", "1234", "128bits");
pdf.open();

// Texto
pdf.setFont("helvetica");
pdf.setFontSize(12);
pdf.setFontStyle("bold");
pdf.setFontColor("#000000");
pdf.setAlignment("center");
pdf.addTextLine("FACTURA");

// Tabla de 3 columnas
pdf.createTable(3);
pdf.setCellBorder("all");
pdf.setTableWidth(100);
pdf.setTableCellWidths(33, 33, 33);
pdf.addCellText("Concepto");
pdf.addCellText("Cantidad");
pdf.addCellText("Precio");
pdf.addTable();

// Imagen en posicion absoluta
pdf.addImageSetXY("./icons/logo.png", 0, 0, 100, 50);

// Tabla flotante en posicion absoluta
pdf.createTable(1);
pdf.setTableWidth(418);
pdf.addCellText("Tabla flotante");
pdf.addTableSetXY(88, 542);

pdf.newPage();  // Nueva página
pdf.close();
pdf.launchPDF();

// Generar PDF desde HTML
pdf.fromHtml(htmlSource);

// Firma digital de PDF
// signPdfWithKey toma 6 argumentos posicionales:
//   (source, destination, keystorePath, keystorePassword, keyAlias, keyPassword)
pdf.signPdfWithKey(source, dest, keystorePath, keystorePassword, keyAlias, keyPassword);
// Alternativa con NativeObject:
// pdf.signPdf({source, destination, privateKey, certificateChain});

// Extraer la capa de texto de un PDF existente (vacío si es un escaneo; no hace OCR). Síncronos.
var texto   = pdf.extractText("documento.pdf");                        // a variable
var rutaTxt = pdf.extractTextToFile("documento.pdf", "documento.txt"); // a fichero .txt (UTF-8)
```

#### 2.12.2 XOnePrinter - Impresion Bluetooth

Impresion en impresoras Bluetooth (ej: Zebra).

```javascript
var mPrinter = new XOnePrinter();
mPrinter.setDriver("zebra");
mPrinter.setDelay(0);
mPrinter.selectBluetoothPrinter();  // O: mPrinter.useStoredPrinter();
mPrinter.connect();
mPrinter.setMaxCharacterWidth(45);
mPrinter.printImage("logo.png", 600, 300, "center", 0);
mPrinter.printLineCentered("Texto centrado en ticket");
mPrinter.printLineCentered("---------------------------");
mPrinter.disconnect();
```

#### 2.12.3 BarcodeGenerator - Códigos de Barras

Generador de códigos de barras e imágenes QR.

**Tipos soportados:** `codabar`, `code128`, `code39`, `code93`, `datamatrix`, `qrcode`, `upca`, `upce`, `ean13`, `ean8`, `pdf417`

```javascript
var generator = new BarcodeGenerator();
generator.setType("qrcode");
generator.setResolution(640, 480);
generator.setDestinationFile("qrcode.png");
generator.generate("Contenido del código");
ui.openFile("qrcode.png");

// Forma rápida
var sFile = new BarcodeGenerator().generate("Texto QR");
ui.openFile(sFile);
```

#### 2.12.4 Datawedge: scanner hardware Symbol/Zebra

Para scanners **Symbol/Zebra** (terminales TC/MC/PDA industriales) que usan DataWedge, se registra un perfil via intent broadcast para que los escaneos hardware se entreguen a la app XOne.

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
    paramBundle.bdf_enabled    = "true";
    paramBundle.bdf_send_enter = "true";
    pluginConfig.PARAM_LIST = paramBundle;
    mainBundle.PLUGIN_CONFIG = pluginConfig;

    let intent = new AndroidIntent();
    intent.setAction("com.symbol.datawedge.api.ACTION");
    intent.putBundleExtra("com.symbol.datawedge.api.SET_CONFIG", mainBundle);
    intent.sendBroadcast();
}
```

**Configuración manual alternativa en el terminal:**

1. Abrir la app **DataWedge** del dispositivo.
2. Deshabilitar o borrar todos los perfiles existentes.
3. Crear un perfil nuevo.
4. **Associated apps**: anadir `com.xone.framework.EditView` y `com.xone.framework.EditViewBGCOOR`.
5. Deshabilitar **SimulScan Input** y **Keystroke Output**.
6. Habilitar **Intent Output** con:
   - Intent action: `com.symbol.datawedge.DWDEMO`
   - Intent category: `Android.intent.category.DEFAULT`
   - Delivery: **Broadcast intent**

#### 2.12.5 XOneNFC - NFC y DNI Electrónico

Lectura/escritura NFC y lectura del DNI electrónico español.

```javascript
var nfc = new XOneNFC();

// Lectura del DNI electrónico
nfc.enableDnieReader({
    readProfileData: true,
    readUserImage: true,
    readSignatureImage: true,
    canNumber: self.MAP_CAN_NUMBER,
    onDnieRead: function(result) {
        var dni = result.getDniNumber();
        var nombre = result.getName();
        var apellidos = result.getSurname();
        var foto = result.getUserImage(appData.getFilesPath() + "foto.png");
    },
    onDnieReadError: function(sError) {
        ui.showToast("Error: " + sError);
    },
    onProgressUpdated: function(sMsg, nProgress) {
        ui.showToast("Progreso: " + nProgress + "%");
    }
});

// Desactivar lectura
nfc.disableDnieReader();

// Escribir tag NDEF
nfc.writeNdefMessageAsync("texto a escribir", function(result) {
    ui.showToast("Tag escrito");
});

// Leer tag NDEF
nfc.readNdefMessageAsync(function(data) {
    ui.showToast("Leido: " + data);
});
```

#### 2.12.6 XOneOCR - Reconocimiento Optico de Caracteres

```javascript
var ocr = new XOneOCR();

// Escanear matricula de vehiculo
var matricula = ocr.scanLicensePlate(rutaImagen);

// OCR genérico de texto: ocr.scanText(...) NO está implementado (lanza UnsupportedOperationException).
// Usar ocr.scanLicensePlate(...) para matrículas o ocr.startScan({regex, onResult}) para validación por patrones.
```

#### 2.12.7 BluetoothSerialPort - Puerto Serie Bluetooth

Comunicación por puerto serie Bluetooth. Disponible como singleton `bluetoothSerial`.

```javascript
// Descubrir dispositivos y conectar
ui.showWaitDialog("Buscando dispositivos...");
try {
    var lstDevices = bluetoothSerial.getDiscoverableBluetoothDevices();
    var dispositivo = null;
    if (lstDevices !== null) {
        for (var i = 0; i < lstDevices.length; i++) {
            if (lstDevices[i].getDeviceName() == "miDispositivo") {
                dispositivo = lstDevices[i];
                break;
            }
        }
    }
    if (dispositivo === null) throw "Dispositivo no encontrado";

    bluetoothSerial.connect(dispositivo.getMacAddress());
    bluetoothSerial.write("datos a enviar");
    var respuesta = bluetoothSerial.read(256);
    bluetoothSerial.disconnect();
} finally {
    ui.hideWaitDialog();
}
```

#### 2.12.8 WifiManager - Gestion de Redes WiFi

```javascript
var wm = new WifiManager();

// Verificar estado del adaptador WiFi
if (wm.isWifiAdapterEnabled()) {
    // Obtener info de la WiFi activa
    var info = wm.getActiveWifiInfo();

    // Conectar a una red
    wm.connect("MiRedWiFi");

    // Escanear redes disponibles (asincrono con callback)
    wm.scanAvailableNetworks(function(networks) {
        // Procesar redes encontradas
    });

    // Listar redes guardadas
    var redes = wm.listSavedNetworks();
}

// MAC del adaptador
var mac = wm.getAdapterMacAddress();
```

#### 2.12.9 Animation - Animaciones de Controles

`Animation` se instancia con `new Animation()` y usa una API fluida encadenada. El target es el **nombre del prop** como string, no el control en si.

```javascript
// API fluida: encadenar metodos
new Animation()
    .setTarget("MAP_BOTON")      // Nombre del prop a animar
    .setDuration(300)            // Duracion en milisegundos
    .setRelativeX(100)           // Mover 100p a la derecha
    .setRelativeY(-50)           // Mover 50p hacia arriba
    .setInterpolation("BounceInterpolator");

// Con callback al terminar
new Animation()
    .setTarget("MAP_BOTON")
    .setDuration(500)
    .setAlpha(0)
    .setEndCallback(function() {
        ui.showToast("Animacion completada");
    });

// Metodos de posicion
new Animation().setTarget("MAP_CTRL").setDuration(200)
    .setRelativeX(100)           // Desplazar X relativo (pixeles)
    .setRelativeY(100);          // Desplazar Y relativo

new Animation().setTarget("MAP_CTRL").setDuration(200)
    .setX(500)                   // Posicion absoluta X
    .setY(300);                  // Posicion absoluta Y (no existe setXY: usar setX/setY por separado)

new Animation().setTarget("MAP_CTRL").setDuration(200)
    .setRelativeZ(10);           // Z relativo (elevacion/sombra)

new Animation().setTarget("MAP_CTRL").setDuration(200)
    .setZ(5);                    // Z absoluto

// Opacidad
new Animation().setTarget("MAP_CTRL").setDuration(300)
    .setAlpha(0.5);              // 0.0 = invisible, 1.0 = opaco

// Escala
new Animation().setTarget("MAP_CTRL").setDuration(300)
    .setScaleX(2.0);             // Escala absoluta en X (1.0 = normal)

new Animation().setTarget("MAP_CTRL").setDuration(300)
    .setScaleY(0.5);             // Escala absoluta en Y

new Animation().setTarget("MAP_CTRL").setDuration(300)
    .setRelativeScaleX(1.5)      // Escala relativa en X
    .setRelativeScaleY(1.5);     // Escala relativa en Y

// Dimensiones
new Animation().setTarget("MAP_CTRL").setDuration(300)
    .setWidth(400);              // Ancho en pixeles

new Animation().setTarget("MAP_CTRL").setDuration(300)
    .setHeight(200);             // Alto en pixeles

// Rotacion
new Animation().setTarget("MAP_CTRL").setDuration(300)
    .setRotation(180);           // Rotacion absoluta en grados

new Animation().setTarget("MAP_CTRL").setDuration(300)
    .setRelativeRotation(45);    // Rotacion relativa en grados

// Color de fondo
new Animation().setTarget("MAP_CTRL").setDuration(300)
    .setBackgroundColor("#FF0000");

// Circular reveal: mostrar u ocultar con animacion circular
// Firma: setCircularReveal(centerX, centerY, bReveal)
//   - centerX/centerY: punto de origen de la onda (en pixeles del control)
//   - bReveal: true = aparece, false = desaparece
new Animation().setTarget("MAP_CTRL").setDuration(400)
    .setCircularReveal(0, 0, true);   // Mostrar

new Animation().setTarget("MAP_CTRL").setDuration(400)
    .setCircularReveal(0, 0, false);  // Ocultar

// Repeticion
new Animation().setTarget("MAP_CTRL").setDuration(300)
    .setRepeatCount(2)               // numero de repeticiones (-1 = infinito)
    .setRepeatMode(2)                // 1 = restart, 2 = reverse (espera int, NO string)
    .setAlpha(0.3);

// Callbacks
new Animation().setTarget("MAP_CTRL").setDuration(300)
    .setStartCallback(function() { /* al empezar */ })
    .setEndCallback(function() { /* al terminar */ })
    .setAlpha(0);

// Cancelar / detener
new Animation().setTarget("MAP_CTRL").cancel();        // Cancela la animación en curso
new Animation().setTarget("MAP_CTRL").stop(true);      // stop requiere 1 boolean (true = completa la animación antes de cancelar)

// Interpolaciones disponibles:
// AccelerateDecelerateInterpolator (por defecto)
// BounceInterpolator
// LinearInterpolator
// OvershootInterpolator
// AccelerateInterpolator
// AnticipateInterpolator
new Animation().setTarget("MAP_CTRL").setDuration(300)
    .setRelativeX(200)
    .setInterpolation("BounceInterpolator");
```

**Comportamiento en XML (sin JS):** Los props y frames pueden usar `behavior="move"` con `behavior-target` para que el elemento se desplace automáticamente cuando otro elemento (ej: snackbar) aparezca.

```xml
<!-- Este botón se aleja del snackbar cuando aparece -->
<prop name="MAP_FAB" type="B" floating="true"
      top="1550p" left="850p"
      behavior="move" behavior-target="snackbar"
      img="ic_fab.png" width="192p" height="192p"
      onclick="ui.showToast('pulsado');" />

<!-- Este L se descarta al deslizar -->
<prop name="MAP_CARD" type="L" floating="true"
      top="500p" left="250p"
      behavior="swipe-dismiss"
      width="400p" height="200p" bgcolor="#FFFFFF"
      title="Deslizame!" />
```

#### 2.12.10 deviceInfo - Información del Dispositivo

`deviceInfo` es un **singleton global** (no requiere instanciacion).

```javascript
// Bateria
let nPorcentaje  = deviceInfo.getBatteryLevelPercentage(); // 0-100
let nNivel       = deviceInfo.getBatteryLevel();           // valor raw
let nNivelMax    = deviceInfo.getBatteryMaxLevel();        // valor máximo raw
let nTemperatura = deviceInfo.getBatteryTemperature();     // decimas de grado Celsius -> / 10 para Celsius
let nVoltaje     = deviceInfo.getBatteryVoltage();         // milivoltios

// Mostrar información de bateria
let sMsg = "Nivel bateria (%): " + deviceInfo.getBatteryLevelPercentage()
    + "\nTemperatura (C): " + parseInt(deviceInfo.getBatteryTemperature() / 10)
    + "\nVoltaje (mV): " + deviceInfo.getBatteryVoltage();

// Red movil
let nSenal    = deviceInfo.getMobileNetworkSignalStrength(); // en dBm
let sTipoRed  = deviceInfo.getConnectedMobileNetworkType();  // "LTE", "HSPA", "EDGE", etc.
let sEstadoRed= deviceInfo.getMobileNetworkState();          // "connected", "disconnected", etc.

// Trafico de red (bytes desde el inicio de la app)
let nBytesRx = deviceInfo.getRxBytes();
let nBytesTx = deviceInfo.getTxBytes();
```

#### 2.12.11 GpsTools - Herramientas GPS

```javascript
var gps = new GpsTools();

// Calcular distancia entre dos puntos
var metros = gps.distanceTo([
    { latitude: 38.8685452, longitude: -6.8170906 },
    { latitude: 40.4167747, longitude: -3.70379019 }
]);

// Obtener dirección desde coordenadas (geocoding inverso)
var direccion = gps.getAddressFromPosition({ latitude: 40.416775, longitude: -3.703790 });

// Verificar si un punto esta dentro de un poligono
var dentro = gps.containsLocation(punto, poligono);

// Ultima ubicación conocida
var location = gps.getLastKnownLocation();

// Codificar lista de coordenadas
var encoded = gps.encode(listaCoords);
```

#### 2.12.12 OAuth2 - Autenticación OAuth 2.0

```javascript
new OAuth2().withOptions({
    authority: strAuthorityUrl,
    clientID: strClientID,
    clientSecret: strClientSecret,
    scope: "openid profile",
    persistenceKey: strPersistenceKey,
    responseType: "code id_token",
    redirectUri: strRedirectUri
}).authenticate({
    onSuccess: function(result) {
        ui.showToast("Autenticado: " + result);
    },
    onError: function(err) {
        ui.showToast("Error OAuth: " + err);
    }
});
```

#### 2.12.13 WebSocket - Comunicación en Tiempo Real

```javascript
var ws = new WebSocket({
    url: "wss://miservidor.com/ws",
    onOpen: function() {
        ui.showToast("Conectado al WebSocket");
    },
    onMessage: function(sData) {
        var mensaje = JSON.parse(sData);
        procesarMensaje(mensaje);
    },
    onError: function(error) {
        ui.showToast("Error WebSocket: " + error);
    },
    onClose: function() {
        ui.showToast("WebSocket cerrado");
    }
});

// Enviar mensaje
ws.send(JSON.stringify({ tipo: "chat", texto: "Hola" }));

// Cerrar conexión
ws.close();
```

#### 2.12.14 fingerprintManager (Singleton Legacy)

API legacy de huella dactilar. Preferir `biometricsManager` para nuevos proyectos.

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

// Abrir ajustes de huella (Android)
fingerprintManager.launchFingerprintSettings();

// Lanzar autenticación (iOS)
fingerprintManager.launch();
```

#### 2.12.15 ImageDrawing - Edición de Imágenes

```javascript
var imageDrawing = new ImageDrawing();
var info = imageDrawing.getImageInfo(appData.getFilesPath() + "foto.jpg");
imageDrawing.create(info.getWidth(), info.getHeight());
imageDrawing.setBackground(appData.getFilesPath() + "foto.jpg");
imageDrawing.setFontSize(64);
imageDrawing.setFontColor("#FF0000");
imageDrawing.addTextSetXY(new Date().toString(), 100, 200, 0);
imageDrawing.addImageSetXY("marca_agua.png", 50, 50);
imageDrawing.save(appData.getFilesPath() + "foto_editada.jpg");
```

#### 2.12.16 Otros Objetos Utilitarios

```javascript
// === AndroidIntent (solo Android) ===
var intent = new AndroidIntent();
intent.setAction("android.content.Intent", "ACTION_VIEW");
intent.setData("https://www.youtube.com/watch?v=VIDEO_ID");
intent.startActivity();

// Lanzar otra aplicación
intent.getLaunchIntentForPackage("com.app.package");
intent.startActivity();

// === IniParser - Lectura/escritura de archivos .ini ===
var ini = new IniParser();
ini.parseFromFile("license.ini");
var valor = ini.getValue("UsePush");
ini.setValue("UsePush", false);
ini.save("license.ini");

// === DOMParser - Parsear XML ===
// Parsear desde string XML
let domParser = new DOMParser();
let xmlDoc    = domParser.parseFromString(sXml);

// Parsear desde fichero XML (en la carpeta de la app)
let xmlDoc2   = domParser.parseFromFile("MiFichero.xml");

// Navegar el documento
let nodeList  = xmlDoc.getElementsByTagName("urn:Usuario"); // Soporta namespaces
let nodo      = nodeList[0];
let sTexto    = nodo.getTextContent();   // Texto del nodo

// Ejemplo completo: parsear respuesta SOAP
function parseFromString() {
    let sXml = "<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope""
        + " xmlns:urn="urn:MiServicio">"
        + "<soap:Body>"
        + "<urn:Check_User>"
        + "<urn:Usuario>Admin</urn:Usuario>"
        + "<urn:Password>1234</urn:Password>"
        + "</urn:Check_User>"
        + "</soap:Body>"
        + "</soap:Envelope>";
    let doc      = new DOMParser().parseFromString(sXml);
    let usuarios = doc.getElementsByTagName("urn:Usuario");
    let sUser    = usuarios[0].getTextContent();  // "Admin"
    ui.showToast("Usuario: " + sUser);
}

// Ejemplo completo: parsear desde fichero
function parseFromFile() {
    let doc      = new DOMParser().parseFromFile("FileXML.xml");
    let usuarios = doc.getElementsByTagName("urn:Usuario");
    let sUser    = usuarios[0].getTextContent();
    ui.showToast("Usuario: " + sUser);
}

// === DebugTools - Envio de logs ===
var debugTools = new DebugTools();
var nResult = debugTools.sendLog();
```

#### 2.12.16b systemSettings - Configuración y Estado del Sistema

`systemSettings` es un **singleton global** (no requiere instanciacion). Solo Android salvo indicacion.

##### Pantalla y brillo

```javascript
systemSettings.setBrightness(75);              // 0-100 (se clampa)
let nBrillo = systemSettings.getBrightness();  // 0-100 (no 0-1)
systemSettings.setBrightnessMode("automatic"); // Brillo automático
systemSettings.setBrightnessMode("manual");    // Brillo manual
let sModoBrillo = systemSettings.getBrightnessMode(); // "manual" o "automatic"

// Color de la barra de estado (status bar)
let ventana = ui.getView(self);
ventana.setStatusBarColor("#00FF00"); // Color RRGGBB
ventana.setStatusBarColor(null);      // Restaurar color por defecto
```

##### Red y conectividad

```javascript
let bAvion     = systemSettings.isAirplaneMode();       // true si modo avion activo
let bDatosMov  = systemSettings.isMobileDataEnabled();  // Puede mentir en algunos dispositivos
let bHttp      = systemSettings.isClearTextTrafficAllowed(); // true si HTTP sin cifrar esta permitido

// Hora de red (NTP)
let fecha = systemSettings.getNetworkTime();
// Con servidor NTP personalizado:
// let fecha = systemSettings.getNetworkTime({ ntpServer: "time.google.com" });
ui.showToast(fecha.toString());

// Proveedores de localización disponibles
let bLocalizacion = systemSettings.hasLocationFeature();
let bRedLoc       = systemSettings.hasNetworkLocationFeature();
let bGpsLoc       = systemSettings.hasGpsLocationFeature();
```

##### Batería y optimizaciones

```javascript
// Comprobar si la app esta exenta de optimizaciones de bateria
let bExenta = systemSettings.isIgnoringBatteryOptimizations();

// Pedir al usuario que exima la app (muestra dialogo del sistema)
if (!systemSettings.isIgnoringBatteryOptimizations()) {
    systemSettings.requestIgnoreBatteryOptimizations(true);
}

// Optimizaciones especificas de fabricante (Xiaomi, Huawei, etc.)
// No se puede consultar el estado, solo solicitar la exencion
systemSettings.requestIgnoreSpecialBatteryOptimizations();
```

##### Permisos en runtime

```javascript
// Consultar permisos declarados/concedidos/no concedidos
let aTodos       = systemSettings.getDeclaredPermissions();   // array de strings
let aConcedidos  = systemSettings.getGrantedPermissions();
let aNoConcedidos= systemSettings.getNotGrantedPermissions();

// Comprobar un permiso concreto (nombre corto XOne o nombre completo Android)
let bCamara = systemSettings.isPermissionGranted("camera");
let bBateria= systemSettings.isPermissionGranted("android.permission.REQUEST_IGNORE_BATTERY_OPTIMIZATIONS");

// Solicitar permisos en runtime
let future = systemSettings.requestPermissions({
    requestMessage: "Por favor habilite estos permisos para usar la aplicación",
    mandatory     : false,          // false = puede continuar sin concederlos
    permissions   : ["bluetooth"]   // nombres cortos XOne
});
let bConcedidos = future.get();     // bloquea hasta respuesta del usuario

// Revocar permisos (Android >= 13)
systemSettings.revokePermissions("microphone", "camera", "phone");

// Permiso de almacenamiento externo completo (Android >= 11)
let futureStorage = systemSettings.requestExternalStoragePermission();
let bStorage = futureStorage.get();

// Permiso overlay (dibujar sobre otras apps): consultar antes de solicitar
let bOverlay = systemSettings.hasOverlayPermission();
if (!bOverlay) {
    let futureOverlay = systemSettings.requestOverlayPermission();
    bOverlay = futureOverlay.get();
}

// Permiso alarmas exactas
let futureAlarm = systemSettings.requestScheduleExactAlarmPermission();
let bAlarm = futureAlarm.get();

// Auto-revocacion de permisos (Android apaga permisos de apps sin uso)
let bAutoRevoke = systemSettings.isPermissionAutoRevokeEnabled();
if (bAutoRevoke) {
    systemSettings.requestDisablePermissionAutoRevoke();
}

// Comprobar si tiene gestion completa de almacenamiento externo
let bManager = systemSettings.isExternalStorageManager();
let bManagerPath = systemSettings.isExternalStorageManager("/sdcard/");
```

##### Memoria y rendimiento

```javascript
// Nivel de memoria actual del dispositivo
let sLevel = systemSettings.getMemoryLevel();
// Valores posibles:
// "background"       -> Uso muy ligero, app prescindible
// "moderate"         -> Uso moderado, app prescindible
// "ui_hidden"        -> Uso ligero, limpiar algunos recursos
// "running_moderate" -> Uso moderado, app visible
// "running_low"      -> Uso alto, app visible
// "running_critical" -> Uso muy alto, app visible
// "complete"         -> Dispositivo casi sin memoria

// Patron comun: solo actuar en niveles criticos
try {
    let sNivel = systemSettings.getMemoryLevel();
    if (sNivel === "running_low" || sNivel === "running_critical" || sNivel === "complete") {
        ui.showToast("El dispositivo se esta quedando sin memoria");
    }
} catch(err) {
    // Puede no estar disponible en todas las versiones
}

// Memoria de la JVM (en bytes)
let nMax   = systemSettings.getMaxMemory();
let nFree  = systemSettings.getFreeMemory();
let sMsg   = "Max: " + Math.round(nMax / 1024 / 1024) + " MB"
           + " | Libre: " + Math.round(nFree / 1024 / 1024) + " MB";

// RAM física del dispositivo (en bytes)
let nRamTotal = systemSettings.getTotalMemory();      // RAM física total instalada
let nRamLibre = systemSettings.getAvailableMemory();  // RAM física disponible ahora

// Espacio en disco (en bytes) — comprobar antes de descargas/exportaciones grandes
let nDiscoLibre = systemSettings.getInternalFreeSpace();   // libre en almacenamiento interno (app + BD)
let nDiscoTotal = systemSettings.getInternalTotalSpace();  // total del almacenamiento interno
let nExtLibre   = systemSettings.getExternalFreeSpace();   // libre en almacenamiento externo (0 si no está montado)
let nExtTotal   = systemSettings.getExternalTotalSpace();  // total del almacenamiento externo

let nMbLibres = Math.round(systemSettings.getInternalFreeSpace() / 1024 / 1024);
if (nMbLibres < 100) {
    ui.showToast("Quedan solo " + nMbLibres + " MB libres en disco");
}

// Forzar garbage collector (solicitud, no garantiza ejecución inmediata)
systemSettings.garbageCollect();

// Limpiar cache de todas las apps (requiere permiso de sistema)
systemSettings.clearAllAppsCache();

// Borrar todos los datos de la app (equivale a "Borrar datos" en ajustes)
systemSettings.clearApplicationData();

// Limpiar caches internas del framework
systemSettings.clearJavascriptCache();
systemSettings.clearBitmapCache();

// Compactar los .dex cacheados del motor JS (optimización del arranque tras muchos scripts nuevos)
systemSettings.mergeJavascriptCache();
```

##### Información del dispositivo y hardware

```javascript
// IDs de hardware
let ids = systemSettings.getHardwareIds();
// ids.deviceIdCount -> número de IDs de dispositivo
// ids.deviceId0, ids.deviceId1, ... -> IMEI u otros IDs
// ids.wifiMacAddress -> MAC WiFi (puede ser null)
// ids.androidId -> Android ID unico por instalacion

// Device ID propio del framework XOne
let sDeviceId = systemSettings.getDeviceId();
systemSettings.setDeviceId("nuevo_id"); // Solo para casos especiales

// Tiempo encendido del dispositivo
let uptime = systemSettings.getDeviceUptime();
// uptime.ms, uptime.days, uptime.hours, uptime.minutes

// Features del hardware disponibles (array de strings tipo "android.hardware.camera")
let aFeatures = systemSettings.getFeatures();

// Teclado fisico
let bTeclado  = systemSettings.hasHardwareKeyboard();  // Tiene teclado fisico
let bQwerty   = systemSettings.hasQwertyKeyboard();    // Es estilo QWERTY
let b12Teclas = systemSettings.hasTwelveKeysKeyboard();// Es estilo 12 teclas
// Devuelven true si tiene el hardware, independientemente de si usa el virtual

// Arquitectura del proceso
let b64Bit = systemSettings.is64Bit(); // true en Android M+ con proceso 64 bits

// Nombres de la app
let sPackage     = systemSettings.getPackageName();   // ej: "com.empresa.app"
let sSharedUserId= systemSettings.getSharedUserId();
```

##### Versiones de SO y de la app

```javascript
let nApiLevel    = systemSettings.getApiLevel();         // API level del SO (Build.VERSION.SDK_INT)
let sAndroidVer  = systemSettings.getAndroidVersion();   // Versión Android (Build.VERSION.RELEASE, ej: "14")
let nTargetSdk   = systemSettings.getTargetSdkVersion(); // targetSdk declarado por el APK
let nMinSdk      = systemSettings.getMinSdkVersion();    // minSdk del APK (Android >= 7 / API 24, lanza si menor)
let nVersionCode = systemSettings.getVersionCode();      // versionCode entero del APK instalado
```

##### Proceso del sistema

```javascript
let nPid      = systemSettings.getPid();            // ID del proceso actual (Process.myPid)
let nUid      = systemSettings.getUid();            // UID Linux del proceso (Process.myUid)
let nTid      = systemSettings.getTid();            // ID del hilo actual (Process.myTid)
let nPriority = systemSettings.getThreadPriority(); // Prioridad nice del hilo actual

// Matar un proceso por PID (uso avanzado: tareas de mantenimiento, reinicios programáticos)
systemSettings.killProcess(nPid);
```

##### Seguridad del dispositivo

```javascript
// Dispositivo con PIN/patron/password de bloqueo configurado.
// Si la app es Device Owner/Profile Owner consulta DevicePolicyManager;
// si no, usa KeyguardManager.isDeviceSecure().
let bSecured = systemSettings.isPasswordSecured();
```

##### Rutas del sistema de ficheros

```javascript
let sExternal     = systemSettings.getExternalStoragePath();
let sGaleria      = systemSettings.getGalleryPath();
let sDocumentos   = systemSettings.getDocumentsPath();
let sMusica       = systemSettings.getMusicPath();
let sDescargas    = systemSettings.getDownloadsPath();
let sCapturas     = systemSettings.getScreenshotsPath();
let sTonos        = systemSettings.getRingtonesPath();
let sAlarmas      = systemSettings.getAlarmsPath();
```

##### Wallpaper

```javascript
systemSettings.setWallpaper("wallpaper.png");  // Fichero en carpeta de la app
systemSettings.getWallpaper(appData.getAppPath() + "files/wallpaper_guardado.png");
// getWallpaper guarda el wallpaper actual en la ruta indicada
```

##### Acceso directo en pantalla de inicio (Pin Shortcut)

```javascript
systemSettings.addPinShortcut({
    id   : 1000,
    label: "Nombre del acceso directo",
    icon : "icono.png",         // Fichero PNG en carpeta de la app
    extras: {                   // Datos extra que recibira la app al pulsar
        parametro1: "valor1",
        parametro2: "valor2"
    }
});
```

##### Estado de la app y restricciones

```javascript
let bRestringida  = systemSettings.isBackgroundRestricted();    // Ejecución en background restringida
let bDatosRestr   = systemSettings.isBackgroundDataDisabled();  // Datos en background restringidos
let bInactiva     = systemSettings.isAppInactive();             // App marcada como inactiva por el SO
let sRestriction  = systemSettings.getAppRestrictionStatus();   // Estado de restriccion de la app
systemSettings.showAppSettingsWindow();                         // Abre los ajustes de la app en el sistema (devuelve el propio systemSettings, encadenable)

// Actualizacion desde Google Play
// Devuelve true si hay actualizacion pendiente (y lanza el dialogo de actualizacion)
// Detener el script si devuelve true para no continuar con la app desactualizada
// Parametro opcional: "immediate" (obligatoria) o "flexible" (se puede posponer)
let bUpdate = systemSettings.checkMarketUpdate();
// let bUpdate = systemSettings.checkMarketUpdate("flexible");
if (bUpdate) {
    return; // Detener ejecución hasta que el usuario actualice
}
```

##### Perfil de trabajo y MDM

```javascript
let bWorkProfile  = systemSettings.isRunningInWorkProfile();    // MDM con perfil de trabajo XOne
let bDeviceOwner  = systemSettings.isRunningWithDeviceOwner();  // MDM en modo kiosko XOne
let bHayMdm       = systemSettings.isRunningInMdm();            // Cualquier MDM activo
let bIntune       = systemSettings.isRunningInMdm("com.microsoft.windowsintune.companyportal");
let bXoneMdm      = systemSettings.isRunningInMdm("com.xone.live.services");
// isRunningInMdm acepta el package name del MDM a comprobar
```

##### XOneLive: widgets y configuración

```javascript
// Widgets de la barra de notificaciones
systemSettings.enableReplicatorWidget();
systemSettings.disableReplicatorWidget();
systemSettings.enableLiveWidget();
systemSettings.disableLiveWidget();

// Configuración actual de XOneLive (objeto JS con todos los parametros)
let jsConfig = systemSettings.getLiveConfig();
```

##### Depuracion e integridad

```javascript
// Integridad del dispositivo (detecta root, emuladores, manipulacion)
let bIntegro = systemSettings.isDeviceIntegrityOk();

// Token de integridad de Google Play (para verificar en servidor)
let sToken = systemSettings.getIntegrityToken("nonce_unico_por_peticion");

// Depurador conectado (util para detectar manipulacion en produccion)
let bDebugger = systemSettings.isDebuggerConnected();

// Activar/desactivar modo debug del framework en tiempo de ejecución
let bDebugMode = !appData.isDebugMode();
appData.setDebugMode(bDebugMode);
```

##### Accesibilidad

```javascript
let bAccesibilidad   = systemSettings.isAccessibilityEnabled();
let bTalkBack        = systemSettings.isTouchExplorationEnabled(); // TalkBack activo
let bAutoStart       = systemSettings.isAutoStartEnabled();        // App en autoarranque
```

##### Ajustes del sistema (propiedades directas)

```javascript
// AUTO_TIME: hora automática de red
// Solo se puede escribir en Android < 4.2 (SDK < 17). En versiones superiores es de solo lectura.
let nSdkVersion = appData.getGlobalMacro("##DEVICE_OSSDKCODE##");
if (nSdkVersion < 17) {
    systemSettings.AUTO_TIME = 1; // Forzar hora automática
} else {
    let nAutoTime = systemSettings.AUTO_TIME; // Solo lectura
    // Equivalente: systemSettings.isNetworkAutoTimeEnabled()
}
```

##### Certificados (solo Android < 11)

```javascript
systemSettings.installCertificate({
    name: "Nombre descriptivo del certificado",
    file: "certificado.pem"  // Fichero en carpeta de la app
});
```

##### Intune (Microsoft Intune MDM)

```javascript
let bIntune      = systemSettings.isIntuneCompilation();           // App compilada con soporte Intune
let sPinRequired = systemSettings.isIntunePinRequired();           // PIN de Intune requerido
let sIntuneId    = systemSettings.getIntuneId();                   // ID del dispositivo en Intune
let bOutdated    = systemSettings.isIntuneAgentOutdated();         // Agente Intune desactualizado
let sMsg         = systemSettings.getIntuneAgentOutdatedMessage(); // Mensaje de actualizacion
```

##### Firebase Analytics

Sólo funciona en flavors compilados con Firebase Analytics. En builds sin Analytics ambos métodos devuelven `false` y registran un aviso en log.

```javascript
// Activar / desactivar Analytics en runtime (cumplir RGPD/opt-out del usuario)
systemSettings.setAnalyticsEnabled(true);
systemSettings.setAnalyticsEnabled(false);

// Registrar evento personalizado:
//   - La clave "eventTag" del objeto es el nombre del evento Firebase
//   - El resto de claves se envían como parámetros del evento
systemSettings.logAnalyticsEvent({
    eventTag : "purchase_completed",
    sku      : "item_001",
    amount   : 9.99,
    currency : "EUR"
});
```

#### 2.12.17 Tabla Resumen de Objetos Complementarios

| Objeto | Creación | Uso Principal |
|--------|----------|---------------|
| `FileManager` | `new FileManager()` | Descarga, lectura, escritura, compresión de archivos |
| `XOnePDF` | `new XOnePDF()` | Generación de documentos PDF |
| `XOnePrinter` | `new XOnePrinter()` | Impresion en impresoras Bluetooth |
| `BarcodeGenerator` | `new BarcodeGenerator()` | Generación de códigos de barras/QR |
| `XOneNFC` | `new XOneNFC()` | NFC y DNI electrónico |
| `XOneOCR` | `new XOneOCR()` | Reconocimiento optico de caracteres |
| `BluetoothSerialPort` | Singleton `bluetoothSerial` | Puerto serie Bluetooth |
| `WifiManager` | `new WifiManager()` | Gestion de redes WiFi |
| `Animation` | `new Animation()` | Animaciones de controles UI |
| `deviceInfo` | Singleton global | Información del dispositivo (batería, red, señal móvil) |
| `GpsTools` | `new GpsTools()` | Distancias, geocoding, poligonos |
| `OAuth2` | `new OAuth2()` | Autenticación OAuth 2.0 |
| `WebSocket` | `new WebSocket(config)` | Comunicación en tiempo real |
| `fingerprintManager` | Singleton global | Huella dactilar (legacy) |
| `ImageDrawing` | `new ImageDrawing()` | Edición básica de imágenes |
| `AndroidIntent` | `new AndroidIntent()` | Intents de Android |
| `systemSettings` | Singleton global | Brillo, permisos, memoria, MDM, batería, rutas, Intune |
| `IniParser` | `new IniParser()` | Archivos de configuración .ini |
| `DOMParser` | `new DOMParser()` | Parseo de XML |

---


**Anterior:** [c - appData y $http](xone-javascript-patterns-c-appdata-http.md) · **Siguiente:** [e - Patrones y buenas prácticas](xone-javascript-patterns-e-patrones.md) · **Índice:** [xone-javascript-patterns.md](xone-javascript-patterns.md)