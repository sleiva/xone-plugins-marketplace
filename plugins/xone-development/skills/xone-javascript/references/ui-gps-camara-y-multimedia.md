# XOne JavaScript — ui: GPS, cámara, firma, escáner y timers

> Fuente: `xone/xone-help-docs/topics/03b-js-ui.md` §3.5–§3.9. Referencia de la skill; el índice está en [../SKILL.md](../SKILL.md).

Contenido: §3.5 GPS (startGps completo, GpsCollection, GpsTools) y cámara/archivos · §3.6 firma digital · §3.7 escáner QR/barcode · §3.8 sleep y timers · §3.9 otros

---

### 3.5 GPS

```javascript
// === Iniciar GPS (modo básico) ===
ui.startGps();

// === Iniciar GPS con configuración completa ===
ui.startGps({
    nodeName                  : "callbackgps",  // Handler en la coll que recibe las actualizaciones
    timeBetweenUpdates        : 10000,          // Milisegundos entre actualizaciones
    minimumMetersDistanceRange: 10,             // Metros minimos de desplazamiento para notificar
    maxUpdateDelayMillis      : 0,
    priority                  : "high",         // high / balanced / low_power / passive
    maxUpdates                : 1000,           // Máximo de actualizaciones
    durationMs                : 3600000,        // Duracion total del servicio (1 hora)
    granularity               : "permission_level",  // permission_level / fine / coarse
    waitForAccurateLocation   : true
});

// === Detener GPS ===
ui.stopGps();

// === Comprobar estado del GPS ===
let nStatus = ui.checkGpsStatus();
// 0: No hay hardware GPS
// 1: Solo GPS activado
// 2: Solo WiFi/redes activado
// 3: Ninguno activado (pedir permiso)
// 4: GPS y WiFi/redes activados (optimo)

// === Pedir permiso de GPS al usuario ===
ui.askUserForGpsPermission({
    onEnabled: function() {
        ui.showToast("GPS activado correctamente");
    },
    onDenied: function() {
        ui.showToast("Se necesita GPS para esta funcion");
    }
});

// === GpsCollection - Leer posicion actual del GPS ===
// Convencion: el proyecto declara una coll llamada "GpsCollection" con connector GPS.
// NO es una coll built-in del framework — hay que declararla en el mapping del proyecto.
// El patron correcto es loadAll() + get(0), NO startBrowse/endBrowse.
function actualizarGps() {
    let collGps = appData.getCollection("GpsCollection");
    collGps.loadAll();
    let objGps = collGps.get(0);

    if (!objGps) return false;           // GPS no disponible
    if (objGps.STATUS != 1) return false; // Sin señal GPS
    if (!objGps.LONGITUD) return false;   // Sin cobertura GPS

    self.MAP_FAKE      = objGps.FAKE;     // 1 = localización simulada (mock)
    self.MAP_LONGITUD  = objGps.LONGITUD;
    self.MAP_LATITUD   = objGps.LATITUD;
    self.MAP_ALTITUD   = objGps.ALTITUD;
    self.MAP_VELOCIDAD = objGps.VELOCIDAD;
    self.MAP_RUMBO     = objGps.RUMBO;
    self.MAP_FGPS      = objGps.FGPS;     // Fecha GPS
    self.MAP_HGPS      = objGps.HGPS;     // Hora GPS
    self.MAP_STATUS    = objGps.STATUS;
    self.MAP_SATELITES = objGps.SATELITES;
    self.MAP_FUENTE    = objGps.FUENTE;    // Proveedor: gps, network, etc.
    self.MAP_PRECISION = objGps.PRECISION;

    ui.refreshValue("MAP_LONGITUD", "MAP_LATITUD", "MAP_ALTITUD",
                    "MAP_VELOCIDAD", "MAP_RUMBO", "MAP_STATUS",
                    "MAP_SATELITES", "MAP_FUENTE", "MAP_PRECISION");
    return true;
}

// === GpsTools - Utilidades de geolocalizacion ===

// Distancia entre dos puntos (metros)
let nMetros = new GpsTools().distanceTo([
    { latitude: 38.8685452, longitude: -6.8170906 },
    { latitude: 40.4167747, longitude: -3.70379019 }
]);

// Distancia entre dos puntos (alternativa con dos objetos)
let nMetros2 = new GpsTools().distanceBetweenCoordinates(
    { latitude: 38.87, longitude: -6.97 },
    { latitude: 40.42, longitude: -3.70 }
);

// Geocodificacion inversa: coordenadas -> dirección
let result = new GpsTools().getAddressFromPosition("38.8862106, -7.0040345");
// result: { locality, subLocality, adminArea, subAdminArea, features,
//           country, countryCode, street, number, address, postal }

// Geocodificacion directa: dirección -> coordenadas
let pos = new GpsTools().getPositionFromAddress("Badajoz");
// pos: { latitude, longitude } o null si no se encuentra

// Verificar si un punto esta dentro de un poligono
let bDentro = new GpsTools().containsLocation(
    "40.3633442, -1.0893794",  // Punto a verificar
    ["38.8685452, -6.8170906", "40.4167747, -3.70379019", "41.3850632, 2.1734035"]
);

// Ultima posicion conocida
let location = new GpsTools().getLastKnownLocation();
// location: { latitude, longitude, accuracy, altitude, bearing, speed, time }

// Codificar array de coordenadas a polyline encoded
let sEncoded = new GpsTools().encode(["38.87, -6.82", "40.42, -3.70"]);

// Decodificar polyline encoded
let locations = new GpsTools().decode("moflFxmrh@kkmHca_R");
// locations: array de { latitude, longitude }

// Simplificar polyline (reducir puntos manteniendo la forma)
let simplified = new GpsTools().simplifyPolyline({
    polyline : [{ latitude: 43.104, longitude: -3.4261 }, /* ... */],
    tolerance: 3000   // En metros. Mayor = menos vertices
});

// Añadir metadatos EXIF de localización a una imagen
new GpsTools().addExifLocationToFile({
    file     : "foto.jpg",
    latitude : 40.4165000,
    longitude: -3.7025600
});

// Calcular ruta con app externa
new GpsTools().routeTo({
    sourceLatitude     : 40.4167747,
    sourceLongitude    : -3.70379019,
    destinationLatitude : 41.3850632,
    destinationLongitude: 2.1734035,
    source             : "google_maps"  // internal / external / google_maps / osmand / osmand_plus
});
```

### 3.5 Camara y Archivos

```javascript
// === Tomar foto con la camara (prop tipo VD) ===
function takePicture() {
    let control = getControl("MAP_CAMERA");
    if (!control) return;

    control.takePicture({
        filename     : "foto_" + Date.now() + ".jpg",
        saveToGallery: true,
        width        : 360,
        height       : 360,
        onFinished   : function(sFileName) {
            if (!sFileName) {
                ui.showToast("Error de camara");
            } else {
                ui.showToast("Foto capturada");
                ui.openFile(sFileName);
            }
        }
    });
}

// === Grabar video ===
function record() {
    let control = getControl("MAP_CAMERA");
    if (!control) return;

    control.record({
        quality     : 80,
        maxDuration : 10000,    // milisegundos
        maxFileSize : 10485760, // bytes (10MB)
        withMicAudio: true,
        onFinished  : function(sFileName) {
            if (sFileName) {
                ui.openFile(sFileName);
            }
        }
    });
}

// === Controles de camara ===
control.stopRecording();
control.startPreview();
control.stopPreview();
control.isCameraOpened();
control.isAutoFocus();
control.setAutoFocus(true);
control.getSupportedAspectRatios();

// === Flash modes ===
control.setFlashMode("on");    // Siempre encendido al tomar foto
control.setFlashMode("off");   // Siempre apagado
control.setFlashMode("torch"); // Siempre encendido (linterna)
control.setFlashMode("auto");  // Automático según sensor de luz
control.setFlashMode("red_eye"); // Anti ojos rojos
let mode = control.getFlashMode();

// === Cambiar camara frontal/trasera ===
let sCamera = control.getCamera();
control.setCamera(sCamera == "front" ? "back" : "front");

// === Seleccionar archivo del dispositivo ===
ui.pickFile({
    targetProperty        : "MAP_ADJUNTO",
    fileTypes             : "jpg,png,pdf",
    allowMultipleSelection: true,
    resolveFileName       : true,
    showSearch            : true,
    initialDirectory      : appData.getFilesPath(),
    onFinishPicking       : function(sAllFiles) {
        for (let sKey in sAllFiles) {
            let file = sAllFiles[sKey];
            console.log("Nombre: " + file.name + " Extension: " + file.extension);
        }
    }
});

// === Abrir un archivo con la app predeterminada ===
ui.openFile(sPath);

// === Abrir URL en navegador externo ===
ui.openUrl("https://www.ejemplo.com");

// === FileManager ===
let fm = new FileManager();
if (fm.fileExists("archivo.txt") === 0) {
    let contenido = fm.readFile("archivo.txt");
}
fm.saveFile("archivo.txt", "contenido", false);  // false = sobreescribir
fm.delete("temporal.txt");
let nSize = fm.getSize("archivo.txt");
```

### 3.6 Firma Digital

La firma digital se implementa con un campo de tipo `IMG` con `readonly=false`:

```xml
<!-- En el XML -->
<prop name="MAP_FIRMA" type="IMG" visible="7" class="propFirma" />
```

```css
/* En default.css (ver topico 02 para detalles de CSS) */
.propFirma {
    img-sign: bt_Firma.png;
    img-sign-sel: bt_Firma_sel.png;
    sign-title: "Firme aquí";
    sign-clear-text: "Borrar";
    sign-save-text: "Guardar";
}
```

```javascript
// En el <onchange> de MAP_FIRMA
function onFirmaCapturada() {
    let firma = self.MAP_FIRMA;
    if (isEmpty(firma)) {
        mostrarToast("Firma cancelada");
        return;
    }
    self.MAP_FECHA_FIRMA = new Date();
    self.save();
    ui.showToast("Firma capturada");
    ui.refresh("MAP_FIRMA");
}
```

### 3.7 QR/Barcode Scanner

```javascript
// === Escaneo con camara tipo VD ===
function doSetOnCodeScanned() {
    let control = getControl("MAP_CAMERA");
    if (!control) return;

    control.setOnCodeScanned(function(evento) {
        // evento.data = valor escaneado
        // evento.type = tipo de código (qr, datamatrix, barcode, etc.)
        let nResult = ui.msgBox(
            "Valor: " + evento.data + "\nTipo: " + evento.type,
            "Código escaneado. Correcto?", 4
        );
        if (nResult == 6) {
            return true;   // Aceptar y dejar de escanear
        } else {
            return false;  // Rechazar y seguir escaneando
        }
    });
}
```

### 3.8 Sleep y Timers

```javascript
// === Sleep - BLOQUEA la UI (usar con extremo cuidado) ===
ui.sleep(3);  // Pausa de 3 segundos

// === Ejecutar acción con retardo (PREFERIDO sobre sleep) ===
// USO CORRECTO: disparar UNA acción puntual tras un retardo corto.
ui.executeActionAfterDelay("miFuncion", 5);  // Ejecuta miFuncion() tras 5 segundos

// === ATENCION: NO encadenar executeActionAfterDelay como setInterval ===
// Para temporizadores continuos (relojes, contadores, polling regular)
// usar startChronometer. Encadenar executeActionAfterDelay cada segundo
// consume mucha memoria y ralentiza el dispositivo. Ver seccion 3.10.
```

### 3.9 Otros

```javascript
// Verificar si la app esta en background
let bBackground = ui.isInBackground();

// Traer la app al frente
ui.returnToForeground();

// Enviar email
ui.sendMail("destino@email.com", "copia@email.com", "Asunto", "Cuerpo", "adjunto.pdf");

// Hacer llamada telefonica
ui.makePhoneCall("+34123456789");

// Iniciar grabacion de audio (forma con objeto de parametros; ver seccion 3.10)
ui.startAudioRecord({
    onComplete: function(sPath) { self.MAP_AUDIO = sPath; ui.refresh("MAP_AUDIO"); },
    onError:    function(sError) { ui.showToast(sError); },
    timeout: 0, outputFormat: "mp4", audioEncoder: "he_aac"
});
ui.stopAudioRecord();

// Date Picker
ui.showDatePicker({
    initialYear: 2024, initialMonth: 6, initialDay: 15,
    title: "Seleccione fecha",
    onDateSet: function(nYear, nMonth, nDay) {
        self.MAP_FECHA = nDay + "/" + nMonth + "/" + nYear;
        ui.refresh("MAP_FECHA");
    }
});

// Time Picker
ui.showTimePicker({
    initialHour: 17, initialMinute: 30, is24HoursMode: true,
    onTimeSet: function(nHours, nMinutes) {
        let h = ("0" + nHours).slice(-2);
        let m = ("0" + nMinutes).slice(-2);
        self.MAP_HORA = h + ":" + m;
        ui.refresh("MAP_HORA");
    }
});

// Drag and Drop
let control = window["MAP_CONTROL"];
ui.startDrag(control, object);
```

