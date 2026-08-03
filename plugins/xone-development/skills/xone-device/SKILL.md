---
description: Acceso a dispositivos y hardware en XOne. Usar al implementar GPS y geolocalización, cámara y captura de fotos/video, escaneo QR/códigos, firma digital, permisos y biometría (huella/face), Bluetooth e impresión, NFC/DNI electrónico, WebSocket, FileManager, o al simular device features con mock/device.json.
---

# XOne Device

Guía de integración con el dispositivo y hardware en XOne: GPS, cámara, escáner QR, firma digital, permisos, biometría, Bluetooth, NFC, archivos y utilidades de dispositivo. El simulador `xone-simulator` puede emular muchas de estas capacidades con `mock/device.json` para reproducir y probar sin hardware real.

## Permisos de dispositivo

Antes de usar GPS, cámara, micrófono o biometría, pedir y comprobar permisos.

```javascript
// Comprobar si un permiso está concedido
if (systemSettings.isPermissionGranted("CAMERA")) {
    // usar cámara
}

// Pedir permisos
systemSettings.requestPermissions(
    ["CAMERA", "RECORD_AUDIO", "ACCESS_FINE_LOCATION"],
    function() { ui.showToast("Permisos concedidos"); },
    function() { ui.showToast("Permisos denegados"); }
);
```

En el simulador, `systemSettings.requestPermissions` invoca el `onSuccess` directamente e `isPermissionGranted` devuelve `true` (el dispositivo se asume con permisos). Otros métodos de `systemSettings`: `getBrightness`/`setBrightness`, `getNetworkType`, `isAirplaneMode`, `getMemoryLevel`, `getTotalMemory`, `getPackageName`, `isRunningInMdm`, `getIntuneId`, `checkMarketUpdate`.

## GPS y geolocalización

### Inicio y estado

```javascript
// Iniciar GPS con callback de posición
ui.startGps({
    nodeName: "callbackgps",
    timeBetweenUpdates: 10000,     // ms entre actualizaciones
    minimumMetersDistanceRange: 10,// desplazamiento mínimo en metros
    foreground: true,
    title: "Mi App",
    text: "Rastreando ubicacion..."
});

// Detener
ui.stopGps();

// Estado (0 sin hardware · 1 solo GPS · 2 solo redes · 3 ninguno · 4 óptimo)
var st = ui.checkGpsStatus();

// Pedir permiso si es necesario
if (st == 0 || st == 3) {
    ui.askUserForGpsPermission({
        onEnabled: function() { ui.startGps(); },
        onDenied:  function() { ui.showToast("Active el GPS"); }
    });
}
```

### Leer posición con GPSColl

La posición actual se lee de la colección especial `GPSColl`. Siempre con startBrowse/endBrowse y verificando `STATUS`:

```javascript
function actualizarGps() {
    var g = appData.getCollection("GPSColl");
    g.startBrowse();
    try {
        var obj = g.getCurrentItem();
        if (!obj) throw "GPS no disponible";
        if (obj.STATUS != 1) throw "GPS sin senal. STATUS: " + obj.STATUS;
        if (!obj.LONGITUD) throw "Sin cobertura GPS";

        self.MAP_LATITUD  = obj.LATITUD;
        self.MAP_LONGITUD = obj.LONGITUD;
        self.MAP_ALTITUD  = obj.ALTITUD;
        self.MAP_VELOCIDAD = obj.VELOCIDAD;
        self.MAP_RUMBO    = obj.RUMBO;
        self.MAP_FGPS     = obj.FGPS;       // fecha GPS
        self.MAP_HGPS     = obj.HGPS;       // hora GPS
        self.MAP_STATUS   = obj.STATUS;
        self.MAP_SATELITES = obj.SATELITES;
        self.MAP_FUENTE   = obj.FUENTE;
        self.MAP_PRECISION = obj.PRECISION;
        ui.refresh("MAP_LATITUD,MAP_LONGITUD,MAP_ALTITUD,MAP_VELOCIDAD");
    } finally {
        g.endBrowse();
    }
}
```

### GpsTools

```javascript
var gps = new GpsTools();
var m = gps.distanceTo([
    { latitude: 38.8685452, longitude: -6.8170906 },
    { latitude: 40.4167747, longitude: -3.70379019 }
]);
var addr = gps.getAddressFromPosition("38.8862106, -7.0040345");
// addr.locality, addr.street, addr.number, addr.country, addr.postal
var dentro = gps.containsLocation("40.3633442, -1.0893794", ["38.868..., -6.817...", ...]);
var last = gps.getLastKnownLocation();   // {latitude, longitude}
```

## Cámara y captura

La cámara se usa con un `<prop type="VD">` y acceso al control vía `getControl`:

```javascript
function takePicture() {
    var control = getControl("MAP_CAMERA");
    if (!control) return;
    control.takePicture({
        filename: "foto_" + Date.now() + ".jpg",
        saveToGallery: true,
        width: 360, height: 360,
        onFinished: function(sFileName) {
            if (!sFileName) { ui.showToast("Error de camara"); }
            else { ui.showToast("Foto capturada"); ui.openFile(sFileName); }
        }
    });
}

function record() {
    var control = getControl("MAP_CAMERA");
    if (!control) return;
    control.record({
        quality: 80, maxDuration: 10000, maxFileSize: 10485760, withMicAudio: true,
        onFinished: function(sFileName) { if (sFileName) ui.openFile(sFileName); }
    });
}
```

Controles de cámara: `stopRecording()`, `startPreview()`/`stopPreview()`, `isCameraOpened()`, `isAutoFocus()`/`setAutoFocus(true)`, `getSupportedAspectRatios()`. Flash: `setFlashMode("on"|"off"|"torch"|"auto"|"red_eye")` y `getFlashMode()`. Cambio de cámara: `getCamera()` / `setCamera("front"|"back")`. Para camuflar el icono del flash según el modo, usar `self.setFieldPropertyValue("MAP_TOGGLE_FLASH_MODE", "img", "flash-<modo>.png")` y `ui.refresh("MAP_TOGGLE_FLASH_MODE")`.

Alternativas de captura con `ui`: `ui.startCamera()`, `ui.captureImage("variable", "control")`, `ui.takePicture(opts)`, `ui.startScanner(...)`.

## Archivos

```javascript
var fm = new FileManager();

// Existe? (retorna 0 si existe)
if (fm.fileExists("documento.pdf") === 0) {
    var contenido = fm.readFile("documento.pdf");
}
fm.saveFile("notas.txt", "Contenido", false);   // append=false sobreescribe
fm.delete("temporal.txt");
fm.copy("origen.txt", "destino.txt");
fm.move("viejo.txt", "nuevo.txt");
fm.rename("archivo.txt", "renombrado.txt");
var size = fm.getSize("archivo.txt");
var b64 = fm.toBase64("imagen.jpg");
fm.toFile(b64, "imagen_copia.jpg");
fm.getChecksum("archivo.txt", "SHA1");   // CRC32, SHA1, Adler32
var ok = fm.download("https://ejemplo.com/archivo.pdf", "archivo.pdf");
var resp = fm.uploadFile({ url: "...", file: "notas.txt", allowUnsafeCertificates: false });
```

En el simulador, `FileManager` opera sobre la carpeta de archivos del proyecto y registra en el log las operaciones no soportadas (`zip`, `unzip`, `downloadFile`) como warning. `ui.pickFile({...})` selecciona archivos del dispositivo; `ui.openFile(path)` los abre con la app predeterminada.

## Firma digital

Se implementa con un `<prop type="IMG">` configurado para firma vía CSS:

```xml
<prop name="MAP_FIRMA" type="IMG" visible="7" class="propFirma" />
```

```css
.propFirma {
    img-sign: bt_Firma.png;
    img-sign-sel: bt_Firma_sel.png;
    sign-title: "Firme aqui";
    sign-clear-text: "Borrar";
    sign-save-text: "Guardar";
}
```

```javascript
// En el onchange de MAP_FIRMA
function onFirmaCapturada() {
    var firma = self.MAP_FIRMA;
    if (isEmpty(firma)) { mostrarToast("Firma cancelada"); return; }
    self.MAP_FECHA_FIRMA = new Date();
    self.save();
    ui.refresh("MAP_FIRMA");
}
```

## Escaneo QR / códigos

```javascript
// Con control de cámara (prop type="VD")
function doSetOnCodeScanned() {
    var control = getControl("MAP_CAMERA");
    if (!control) return;
    control.setOnCodeScanned(function(evento) {
        // evento.data = valor escaneado; evento.type = tipo (qr, datamatrix, barcode...)
        var r = ui.msgBox("Valor: " + evento.data, "Codigo escaneado. Correcto?", 4);
        return r == 6;   // true=aceptar y dejar de escanear, false=seguir
    });
}

// Con app externa
ui.startScanner("", "qr", "");                    // escáner por defecto, tipo QR
ui.startScanner("quickmark", "barcode", "");      // app QuickMark, código de barras

// CodeScanner (global)
codeScanner.startCamera(function(codigo, fichero) {
    self.MAP_CODIGO = codigo;
    ui.refresh("MAP_CODIGO");
}, "qrcode", true);   // tipo, confirmar con foto
var s = codeScanner.scanFromFile("barcode.png", "code128");

// Generar códigos
var gen = new BarcodeGenerator();
gen.setType("qrcode");     // code128, code39, ean13, qrcode, datamatrix, pdf417...
gen.setResolution(640, 480);
gen.setDestinationFile("codigo.png");
gen.generate("Contenido");
ui.openFile("codigo.png");
```

## Biometría

### biometricsManager (preferido)

`biometricsManager` es el singleton global para huella y face ID, y firma biométrica. (La referencia la documenta como el reemplazo moderno de `fingerprintManager`.)

```javascript
biometricsManager.authenticate({
    onSuccess: function(result) {
        // result contiene la clave pública / token del dispositivo
        ui.showToast("Identidad verificada");
    },
    onFailure: function(nError, sMessage) {
        ui.showToast("Error biometrico: " + sMessage);
    }
});
```

### fingerprintManager (legacy)

```javascript
fingerprintManager.setCallback({
    onSuccess: function(result) {
        var pub = result.getPublicKey();
        ui.showToast("Huella verificada");
    },
    onFailure: function(nError, sErrorMessage) {
        ui.showToast("Error: " + sErrorMessage);
    }
});
fingerprintManager.listen();
fingerprintManager.stopListening();
fingerprintManager.launchFingerprintSettings();  // Android
fingerprintManager.launch();                     // iOS
```

## Bluetooth e impresión

### BluetoothSerialPort (singleton global `bluetoothSerial`)

```javascript
var devices = bluetoothSerial.getDiscoverableBluetoothDevices();
var device = null;
for (var i = 0; i < devices.length; i++) {
    if (devices[i].getDeviceName() == "mi_dispositivo") {
        device = devices[i];
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

Estado Bluetooth desde `ui`: `ui.getBluetoothStatus()` y `ui.setBluetoothStatus(true)`.

### Impresión con XOnePrinter

```javascript
var printer = createObject("XOnePrinter");
printer.setDriver("zebra");
printer.setDelay(0);
printer.useStoredPrinter();   // o selectBluetoothPrinter()
printer.connect();
printer.setMaxCharacterWidth(45);
printer.printImage("logo.png", 600, 300, "center", 0);
printer.printLineCentered("Texto centrado");
printer.disconnect();
```

## NFC y DNI electrónico

```javascript
var nfc = createObject("XOneNFC");

// Lectura de DNIe
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

// Lectura/escritura NDEF
nfc.writeNdefMessageAsync("Texto para NFC", function(result) {
    ui.showToast("Escrito correctamente");
});
nfc.readNdefMessageAsync(function(result) {
    ui.showToast("Leido: " + result);
});
```

## WebSocket

```javascript
var ws = new WebSocket({
    url: "wss://miservidor.com/ws",
    onOpen: function() { console.log("WebSocket conectado"); },
    onMessage: function(sData) { procesar(JSON.parse(sData)); },
    onError: function(error) { console.log("Error WS: " + error); },
    onClose: function() { console.log("WebSocket cerrado"); }
});
ws.send(JSON.stringify({ tipo: "saludo", mensaje: "hola" }));
ws.close();
```

## Otras utilidades de dispositivo

```javascript
// DeviceInfo
var di = new DeviceInfo();
di.getBatteryLevelPercentage();
di.getBatteryTemperature();
di.getBatteryVoltage();
di.getRxBytes();
di.getTxBytes();
di.getMobileNetworkSignalStrength();   // en dBm
di.getConnectedMobileNetworkType();

// WifiManager
var wm = new WifiManager();
wm.isWifiAdapterEnabled();
wm.getAdapterMacAddress();
wm.getActiveWifiInfo();
wm.connect("MiRed");
wm.scanAvailableNetworks(function(redes) { /* procesar */ });

// Sistema
ui.isInBackground();
ui.returnToForeground();
ui.isWifiEnabled();
ui.vibrate();
ui.playSoundAndVibrate({ sound: "notificacion.mp3", vibrate: true, continuePlaying: false });
ui.stopPlaySoundAndVibrate();
ui.makePhoneCall("+34123456789");
ui.sendMail("destino@email.com", "copia@email.com", "Asunto", "Cuerpo", "adjunto.pdf");
ui.speak("El proceso ha finalizado correctamente");
ui.recognizeSpeech();
ui.addCalendarItem({ title: "Reunion", startDate: "2024-06-15 10:00", endDate: "2024-06-15 11:00" });

// Selectores de fecha/hora
ui.showDatePicker({ initialYear: 2024, initialMonth: 6, initialDay: 15, title: "Fecha",
    onDateSet: function(y, m, d) { self.MAP_FECHA = d + "/" + m + "/" + y; ui.refresh("MAP_FECHA"); } });
ui.showTimePicker({ initialHour: 17, initialMinute: 30, is24HoursMode: true,
    onTimeSet: function(h, m) { self.MAP_HORA = h + ":" + m; ui.refresh("MAP_HORA"); } });

// Timers: preferir executeActionAfterDelay sobre sleep (bloquea la UI)
ui.executeActionAfterDelay("miFuncion", 5);
// ui.sleep(3);   // evita; bloquea la interfaz
```

## Simulación de device en el simulador

El `xone-simulator` emula GPS, escáner, foto y geocodificación con un manifest `mock/device.json` en la raíz del proyecto:

```json
{
  "gps": { "LATITUD": 38.8685, "LONGITUD": -6.8170, "STATUS": 1, "FAKE": 1 },
  "gpsStatus": 4,
  "gpsPermission": true,
  "scanResult": "QR-SIMULADO-123",
  "photoPath": "camera/photo.jpg",
  "geocode": { "38.8862106, -7.0040345": { "lat": 38.8862, "lon": -7.0040 } }
}
```

Reglas:
- La posición GPS por defecto es `{0,0, STATUS:1, FAKE:1}`; si no configuras `gps`, el simulador emite un warning.
- `scanResult` alimenta `codeScanner`/eventos de código; `photoPath` alimenta `takePicture`/`startCamera`.
- En modo mock, `startGps` devuelve posiciones del manifest sin hardware real: útil para reproducir bugs de lógica de ubicación en CI.
- Ejecutar con: `xone-simulator smoke ./proyecto --json` (exit 1 si hay failures) o `run`/`render` para escenarios puntuales.

## Errores y diagnóstico

| Síntoma | Causa | Solución |
|---------|-------|----------|
| `GPS STATUS != 1` | GPS desactivado o sin señal | `checkGpsStatus()` + `askUserForGpsPermission`; verificar `GPSColl` |
| Coordenadas 0/null | Falta `ui.startGps()` o sin permiso | Iniciar GPS y pedir permiso antes de leer |
| Foto no se guarda | Falta permiso de cámara o `filename` | Pedir permiso; pasar `filename` a `takePicture` |
| Firma cancelada | `self.MAP_FIRMA` vacío en `onchange` | Verificar `isEmpty(firma)` antes de guardar |
| Escáner no devuelve nada | Sin entrada en `mock/device.json` | Configurar `scanResult` en el manifest |
| Bluetooth no conecta | Dispositivo no descubierto o BT apagado | `getBluetoothStatus`/`setBluetoothStatus`; verificar nombre y MAC |
| WebSocket sin mensajes | Servidor/red o formato del payload | Validar JSON en `onMessage` con `try/catch` |

## Buenas prácticas

1. Pedir permisos antes de usar GPS, cámara, micrófono o biometría; verificar el estado antes de actuar.
2. Para GPS, leer `GPSColl` con `startBrowse`/`endBrowse` y verificar `STATUS == 1` y `LONGITUD` no vacío.
3. Configurar `mock/device.json` para reproducir escenarios de dispositivo en el simulador sin hardware.
4. Preservar `self` (contexto) en callbacks de cámara, GPS y escáner.
5. Preferir `ui.executeActionAfterDelay()` a `ui.sleep()` (bloquea la UI).
6. Usar `biometricsManager` en lugar de `fingerprintManager` (legacy) para biometría.
7. Cerrar conexiones Bluetooth y WebSocket cuando ya no se usan.
8. Comprobar `fileExists === 0` antes de `readFile`; usar `saveFile(..., false)` para sobreescribir.
