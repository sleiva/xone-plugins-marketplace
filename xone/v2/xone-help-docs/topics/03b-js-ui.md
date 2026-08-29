# JavaScript API — Objeto `ui` (Interfaz de Usuario y dispositivo)

Sub-archivo del [Tópico 03 - Guía Completa de JavaScript](03-javascript-api-guide.md). Cubre el objeto global `ui`: navegación entre pantallas, mensajes/dialogos (msgBox, toast, snackbar, wait, notificaciones), vista (refresh, getView, grupos, drawer, bottom sheet, showcase), date/time pickers, GPS, camara/archivos, firma, QR/barcode, sleep/timers, voz (TTS/STT), grabacion audio, calendario, cronometros, API de controles especificos (stepper, OTP) y catálogo completo de métodos.

## Tabla de Contenidos

- [3.1 Navegación](#31-navegacion)
- [3.2 Mensajes y Dialogos](#32-mensajes-y-dialogos)
- [3.3 Vista - Refrescar y Acceder a Controles](#33-vista---refrescar-y-acceder-a-controles)
- [3.4 Date/Time Pickers](#34-datetime-pickers)
- [3.5 GPS](#35-gps)
- [3.5 Camara y Archivos](#35-camara-y-archivos)
- [3.6 Firma Digital](#36-firma-digital)
- [3.7 QR/Barcode Scanner](#37-qrbarcode-scanner)
- [3.8 Sleep y Timers](#38-sleep-y-timers)
- [3.9 Otros](#39-otros)
- [3.10 Métodos Adicionales de ui (incluye Stepper, OTP, Cronometros)](#310-metodos-adicionales-de-ui)
- [3.11 Catálogo completo de métodos de ui](#311-referencia-completa-catalogo-de-metodos-del-objeto-ui)

---

## 3. Objeto Global `ui` - Interfaz de Usuario

El objeto `ui` proporciona todas las funciones de interaccion con la interfaz de usuario.

### 3.1 Navegación

`ui.openEditView()` es el mecanismo principal de navegación en XOne. Sirve tanto para "abrir una pantalla" como para "editar un objeto existente":

```javascript
// === Abrir una pantalla (la forma habitual) ===
// Firma: ui.openEditView(target, [exit])
//   target : dataObject | string — un dataObject ya preparado, o el nombre de la coll destino
//   exit   : boolean — si true, cierra la vista origen al abrir la nueva (default false)

// Forma corta: pasar el nombre de la coll. XOne crea internamente un dataObject
// vacío de esa coll (createObject + addItem) y abre su vista de edición.
ui.openEditView("Productos");

// Pasar un objeto NUEVO con datos pre-rellenados
let coll = appData.getCollection("Productos");
let obj = new Productos({ MAP_CATEGORIA_ID: idCategoria });
coll.addItem(obj);
ui.openEditView(obj);

// Abrir un objeto EXISTENTE recuperado de la BD
let producto = appData.getCollection("Productos").findObject("ID = " + nId);
if (producto) {
    ui.openEditView(producto);
}

// Cerrar la vista origen al abrir la nueva (flujos lineales sin botón atrás)
ui.openEditView(obj, true);

// === Obtener la ventana actual ===
let window = ui.getView(self);   // Ventana del objeto actual
let window = ui.getView();       // Ventana actual sin parametro

// === Cerrar ventana actual ===
let window = ui.getView(self);
if (window) {
    window.exit();
}

// === Cerrar la aplicación ===
appData.exit();

// === Mostrar/ocultar grupos (tabs) ===
ui.showGroup(2);  // Mostrar grupo por indice

// Con animacion
ui.showGroup(2, "##ALPHA_IN##", 200, "##ALPHA_OUT##", 200);

// Ejemplo real: navegacion entre paginas con animacion
function mostrarGrupo(nGroup, sAnimIn, sAnimOut) {
    sAnimIn = sAnimIn || "##ALPHA_IN##";
    sAnimOut = sAnimOut || "##ALPHA_OUT##";
    ui.showGroup(nGroup, sAnimIn, 200, sAnimOut, 200);
}
```

**Animaciones predefinidas disponibles:**

| Constante | Descripción |
|-----------|-------------|
| `##ALPHA_IN##` / `##ALPHA_OUT##` | Entrada/salida con fundido |
| `##ZOOM_IN##` / `##ZOOM_OUT##` | Entrada/salida con zoom |
| `##LEFT_IN##` / `##LEFT_OUT##` | Deslizar desde/hacia la izquierda |
| `##RIGHT_IN##` / `##RIGHT_OUT##` | Deslizar desde/hacia la derecha |
| `##TOP_IN##` / `##TOP_OUT##` | Deslizar desde/hacia arriba |
| `##BOTTOM_IN##` / `##BOTTOM_OUT##` | Deslizar desde/hacia abajo |

#### Caso especial — abrir la LISTA de una coll directamente

`ui.openEditView()` siempre abre el EditView de un dataObject. Si lo que se necesita es lanzar directamente la **lista** de una coll como pantalla independiente (`MainListCollectionActivity` o `MainCalendarViewActivity` si tiene `viewmode="calendar"`), hay que recurrir al método legacy `ui.openMenu(collName, mask, mode)` con `mode=0`:

```javascript
// Lista con todas las opciones del menú (mode=0, mask=0xFFFFFF)
ui.openMenu("Productos", 0xFFFFFF, 0);

// Lista en modo sólo lectura (mask = MENU_MASK_VIEW)
ui.openMenu("Productos", 0x000200, 0);
```

Constantes `mask` (combinables con OR — JavaScript NO expone los nombres, usar el valor numérico): `ADD=0x01`, `EDIT=0x02`, `DELETE=0x04`, `EXIT=0x08`, `FILTRAR=0x10`, `SAVE=0x40`, `SORT=0x80`, `REFRESH=0x100`, `VIEW=0x200`, `FULLMASK=0xFFFFFF`.

> Para el resto de necesidades de navegación (abrir una pantalla nueva, abrir un objeto existente, abrir un detalle desde un `<selecteditem>`) usar siempre `ui.openEditView()`. Habitualmente las "listas" en XOne se muestran como `<contents>` embebido en una pantalla padre, no como activity independiente — por eso `mode=0` se necesita poco.

### 3.2 Mensajes y Dialogos

```javascript
// === Message Box clasico ===
// Tipo 0 = Solo botón OK
// Tipo 4 = Botones Si/No (retorna 6=Si, 7=No)
let nResult = ui.msgBox("Desea continuar?", "Confirmar", 4);
if (nResult == 6) {
    // Usuario pulso Si
}

// === Toast simple ===
ui.showToast("Mensaje rápido");

// === Toast personalizado ===
ui.showToast({
    color    : "#4CAF50",          // Color de fondo
    duration : "short",            // "short" o "long"
    text     : "Guardado correctamente",
    textColor: "#FFFFFF",          // Color del texto
    textFont : "Roboto-Regular.ttf",  // Fuente (debe estar en fonts/)
    textSize : 14,                 // Tamano de fuente
    rounded  : true                // Esquinas redondeadas
});

// === Snackbar simple (solo texto) ===
ui.showSnackbar("Registro eliminado");   // duración "long", texto blanco por defecto

// === Snackbar con acción ===
ui.showSnackbar({
    text           : "Registro eliminado", // OBLIGATORIO (vacío => excepción)
    color          : "#323232",
    duration       : "long",        // "short" | "long" | "indefinite" (otro valor => excepción)
    width          : "80%",         // "100%" => ancho completo
    textColor      : "#FFFFFF",
    actionText     : "Deshacer",    // solo se muestra si TAMBIÉN hay actionMethod
    actionTextColor: "#FFEB3B",
    maxLines       : 1,             // solo aplica si > 1
    align          : "center|bottom",
    height         : "10%",         // Altura del snackbar (opcional)
    actionMethod   : function() {   // se ejecuta en un hilo aparte, no en el de UI
        deshacerEliminacion();
    }
});

// Ocultar snackbar manualmente (oculta el último mostrado; false si no hay ninguno visible)
ui.hideSnackbar();

// NOTA: showSnackbar solo funciona dentro de una pantalla de edición.
// En otros contextos lanza una excepción.

// === msgBox con DataObject (dialogo completamente personalizado) ===

// Variante SINCRONA: bloquea hasta que el usuario pulsa
// La coll debe tener botones con button-option="N"
// ui.msgBox() devuelve el valor del button-option del botón pulsado
let msgBoxObj  = new MessageBoxNormal();
let nResult    = ui.msgBox(msgBoxObj);
// nResult == 1 -> pulsó Cancel (button-option="1")
// nResult == 2 -> pulsó OK     (button-option="2")

// Variante ASINCRONA con callbacks (no bloquea)
// La coll debe tener: hardware-accelerated="false", bgcolor="#00000000"
// y campos type="O" para los callbacks
function showMsgBoxAsync(callbackOk, callbackCancel) {
    let obj = new MessageBoxAsync({ MAP_CALLBACK_OK: callbackOk, MAP_CALLBACK_CANCEL: callbackCancel });
    ui.openEditView(obj);
}

// Uso:
showMsgBoxAsync(
    function() { ui.showToast("OK pulsado");     ui.getView(self).exit(); },
    function() { ui.showToast("Cancel pulsado"); ui.getView(self).exit(); }
);

// === Wait Dialog (indicador de carga) ===
ui.showWaitDialog("Cargando datos...");
ui.setWaitDialogText("Procesando registros...");
ui.hideWaitDialog();

// === Notificaciones ===
// Notificación simple
ui.showNotification(1, "Titulo", "Texto de la notificación");

// Notificación con ticker
ui.showNotification(2, "Titulo", "Texto", "Texto en barra de estado");

// Notificación con callback al pulsar
ui.showNotification(3, "Titulo", "Texto", "Ticker", self, "miNodoCallback");

// Notificación avanzada con botones
ui.showNotification({
    id             : 5000,
    title          : "Nueva tarea asignada",
    text           : "Tiene una nueva tarea pendiente",
    textHtml       : "<b>Tarea urgente</b>: Revision de inventario",
    icon           : "app_icon1",       // app_icon1 a app_icon10
    largeIcon      : "app_icon4",
    backgroundColor: "#1976D2",
    sound          : "notification.wav",
    cancelable     : true,
    dataObject     : self,
    nodeName       : "callbackNotificacion",
    parameters     : '{ "tareaId": "123" }',
    buttons        : [{
        id              : 5001,
        title           : "Responder",
        directReply     : true,
        directReplyLabel: "Escriba su respuesta...",
        dataObject      : self,
        nodeName        : "respuestaCallback"
    }]
});

// LED de notificación (solo Android)
ui.setNotificationLed("#00FF00", 1000, 1000);  // color, onMs, offMs
```

#### msgBox con DataObject (Dialogos Personalizados)

`ui.msgBox(dataObject)` permite abrir una coleccion XOne como dialogo completamente personalizado.

**Variante sincrona** — Los botones usan `button-option`. `ui.msgBox()` bloquea hasta que el usuario pulsa y devuelve el valor del `button-option` pulsado:

```javascript
let msgBoxObj  = new MessageBoxNormal();
let nResult    = ui.msgBox(msgBoxObj);
// nResult == 1 -> pulsó Cancel (button-option="1")
// nResult == 2 -> pulsó OK     (button-option="2")
```

La coll `MessageBoxNormal` requiere: `notab="true"`, `show-toolbar="false"`, `check-owner="false"`, `dependent="false"`, y botones con `button-option="N"`.

**Variante asíncrona con callbacks** — Los botones invocan `self.MAP_CALLBACK_OK()`. Usa campos `type="O"` para las funciones callback:

```javascript
function showMessageBoxDataObject(callbackOk, callbackCancel) {
    let newMsgBox = new MessageBoxAsync({ MAP_CALLBACK_OK: callbackOk, MAP_CALLBACK_CANCEL: callbackCancel });
    ui.openEditView(newMsgBox);
}

// Uso
showMessageBoxDataObject(
    function() { ui.showToast("OK pulsado");     ui.getView(self).exit(); },
    function() { ui.showToast("Cancel pulsado"); ui.getView(self).exit(); }
);
```

La coll `MessageBoxAsync` requiere además: `hardware-accelerated="false"` y `bgcolor="#00000000"` para fondo transparente sin fondo negro.

### 3.3 Vista - Refrescar y Acceder a Controles

```javascript
// === Obtener la ventana actual ===
let window = ui.getView(self);
let window = ui.getView();    // Sin parametro = ventana activa actual

// === Acceder a un control por nombre ===
let control = window["MAP_BOTON"];

// === getControl(name, [dataObject]) - función NATIVA global (recomendado) ===
// Disponible directamente, NO hace falta declarar el helper. Devuelve el control
// resuelto en la ventana destino:
//   - getControl(name)             → última ventana visible.
//   - getControl(name, dataObject) → ventana asociada a ese DataObject.
//
// Semántica ESTRICTA: lanza error si el nombre está vacío, el control no
// existe, no hay ventana destino, o el dataObject no es válido.
//
// Si un proyecto ya tiene "function getControl(...)" propia, esa sombrea a la
// nativa en su scope local (compatibilidad hacia atrás preservada).
let control = getControl("MAP_BOTON");
let controlEnOtraVentana = getControl("MAP_TITULO", objPadre);

// === Refrescar campos de la interfaz ===
ui.refresh();                           // Refrescar TODO (costoso, evitar)
ui.refresh("MAP_NOMBRE");              // Refrescar un campo específico
ui.refresh("MAP_NOMBRE,MAP_ESTADO");   // Refrescar multiples campos

// Solo actualizar el valor (sin reconstruir la vista del control)
ui.refreshValue("MAP_CAMPO");
// Multiples campos (cada uno como argumento)
let ventana = ui.getView(self);
ventana.refreshValue("MAP_CAMPO1", "MAP_CAMPO2", "MAP_CAMPO3");

// Refrescar una fila específica de un content
ui.refreshContentRow("MAP_CONTENT", 0);

// Refrescar la fila seleccionada de un content
ui.refreshContentSelectedRow("MAP_CONTENT");

// Refrescar usando la ventana directamente
window.refresh("MAP_CAMPO");
window.refreshAll("frmMiFrame");       // Refresca el frame y todos sus hijos

// === Grupos (tabs) y Drawers ===
// Mostrar un grupo por indice
ui.showGroup(2);
ui.showGroup(2, "##ALPHA_IN##", 300, "##ALPHA_OUT##", 300);  // Con animacion

// Comprobar si un grupo esta abierto (util para drawers)
if (window.isGroupOpen(999)) {
    window.hideGroup(999);  // Cerrar el drawer
}

// Patron: botón atrás cierra drawer antes de salir
function doOnBack() {
    let window = ui.getView();
    if (!window) return;
    if (window.isGroupOpen(999)) {
        window.hideGroup(999);
        return;
    }
    window.exit();
}

// === Nombre de la coleccion activa ===
function getCurrentCollectionName() {
    let window = ui.getView();
    if (!window) return "";
    let dataObject = window.getDataObject();
    if (!dataObject) return "";
    let coll = dataObject.getOwnerCollection();
    if (!coll) return "";
    return coll.getName();
}

// === Traer app al primer plano (desde handler de notificación) ===
ui.returnToForeground();

// === Scroll de Frames ===
let frame = window["frmScroll"];
frame.scrollToTop(true);     // true = animado
frame.scrollToBottom(true);

// === Bottom Sheet ===
// sFrame: nombre del frame con behavior="bottom-sheet"
// sState: "expanded" / "collapsed" / "hidden"
// bLockDrag: true = impedir que el usuario lo arrastre
window.setBottomSheetState("mi_panel", "expanded", false);
window.setBottomSheetState("mi_panel", "collapsed", true);  // Bloqueado
let sEstado = window.getBottomSheetState("mi_panel");

// === Progress Bar JS ===
let control = window["MAP_PROGRESS_BAR"];
control.setIndeterminate(true);    // Activar animacion continua
control.setIndeterminate(false);   // Desactivar, mostrar valor actual
control.toggleIndeterminate();     // Alternar estado
let bIndet = control.isIndeterminate();

// === Efectos visuales en frame ===
// setBlur y setSaturation son metodos del control de frame en la ventana.
// Se implementan como funciones de proyecto, no son API global del framework.

// Blur: 0 = sin desenfoque, valores mayores = mas desenfoque
function doBlurEffect(sFrame, nValue) {
    let window = ui.getView(self);
    if (!window) return;
    window[sFrame].setBlur(nValue);
}

// Saturacion: 0 = escala de grises, valores mayores = mas saturacion
function doSaturationEffect(sFrame, nValue) {
    let window = ui.getView(self);
    if (!window) return;
    window[sFrame].setSaturation(nValue);
}
// Patron tipico: vincular a slider con onchange en la coll
// <field name="MAP_BLUR_SLIDER"><action name="runscript"><script>
//     doBlurEffect("frame_imagen", self.MAP_BLUR_SLIDER);
// </script></action></field>

// === Color de la barra de estado ===
window.setStatusBarColor("#1565C0");  // Color RRGGBB
window.setStatusBarColor(null);       // Restaurar color por defecto

// === Showcase (tutorial interactivo) ===
window.startShowcase({
    continueOnCancel: true,     // Si cancela un paso, ir al siguiente
    tapTargets: [{
        target              : "MAP_CAMPO1",
        title               : "Paso 1",
        description         : "Descripción del primer paso",
        cancelable          : true,
        transparentTarget   : true,
        targetRadius        : 90,
        outerCircleOpacity  : 96,
        outerCircleColor    : "#1565C0",
        targetCircleColor   : "#FF0000",
        dimColor            : "#CC000000",
        titleTextSize       : 20,
        descriptionTextSize : 15,
        textColor           : "#FFFFFF",
        titleTextColor      : "#FFFF00",
        descriptionTextColor: "#FFFFFF",
        textFont            : "MiFuente.ttf",
        drawShadow          : true
    }, {
        target     : "MAP_CAMPO2",
        title      : "Paso 2",
        description: "Segundo paso del tutorial",
        cancelable : true
    }]
});
```

### 3.4 Date/Time Pickers

```javascript
// Date Picker con callback
ui.showDatePicker({
    initialYear : 2024,
    initialMonth: 6,
    initialDay  : 15,
    title       : "Seleccione fecha",
    theme       : "holo_light",           // Tema visual del picker
    onDateSet   : function(nYear, nMonth, nDay) {
        self.MAP_FECHA = nDay + "/" + nMonth + "/" + nYear;
        ui.refresh("MAP_FECHA");
    }
});

// Date Picker que escribe directamente en un campo (sin callback)
ui.showDatePicker({
    targetProperty: "MAP_FECHA"           // El picker escribe aquí al confirmar
});

// Time Picker con callback
ui.showTimePicker({
    initialHour  : 17,
    initialMinute: 30,
    is24HoursMode: true,
    title        : "Seleccione hora",
    theme        : "holo_light",
    onTimeSet    : function(nHours, nMinutes) {
        let h = ("0" + nHours).slice(-2);
        let m = ("0" + nMinutes).slice(-2);
        self.MAP_HORA = h + ":" + m;
        ui.refresh("MAP_HORA");
    }
});

// Time Picker que escribe directamente en un campo
ui.showTimePicker({
    targetProperty: "MAP_HORA"
});
```

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

#### startCamera(params) - Capturar una foto o un vídeo sobre un campo

Abre la cámara y guarda el resultado en el campo indicado. A diferencia de `control.takePicture()`, que necesita un control de cámara en la pantalla, aquí no hace falta pintar nada: la captura ocurre en su propia pantalla y al terminar el fichero queda en el campo.

```javascript
// Foto en movimiento, con la cámara del framework
ui.startCamera({
    propName         : "MAP_FOTO",
    type             : "photo",
    useInternalCamera: true,
    motionPhoto      : true,
    onSuccess        : function(sFileName) {
        ui.showToast("Foto guardada: " + sFileName);
    },
    onCancelled      : function() {
        ui.showToast("Captura cancelada");
    }
});

// Vídeo de 30 segundos como máximo
ui.startCamera({
    propName   : "MAP_VIDEO",
    type       : "video",
    maxDuration: 30
});

// Forma corta: nombre del campo y tipo
ui.startCamera("MAP_FOTO", "photo");
```

| Parámetro | Tipo | Default | Descripción |
|-----------|------|---------|-------------|
| `propName` | string | — | Campo donde se guarda el nombre del fichero capturado |
| `type` | string | `"photo"` | `"photo"`, `"video"` o `"attach"` (este último abre el selector de ficheros en vez de la cámara) |
| `useInternalCamera` | boolean | `false` | Captura con la cámara que trae el framework en vez de abrir la app de cámara del dispositivo |
| `motionPhoto` | boolean | `false` | Captura una **foto en movimiento**: un JPG con un clip de vídeo corto embebido detrás. Solo aplica a `type: "photo"` |
| `size` | number | `0` | Tamaño máximo del fichero en KB. `0` = sin límite |
| `width` | number | `-1` | Ancho máximo de la foto en píxeles |
| `height` | number | `-1` | Alto máximo de la foto en píxeles |
| `quality` | number | `90` | Calidad JPEG de la foto (0-100) |
| `maxDuration` | number | `-1` | Duración máxima del vídeo en segundos |
| `onSuccess` | function | — | Recibe el nombre del fichero capturado |
| `onCancelled` | function | — | Se invoca si el usuario cancela la captura |

> **Las fotos en movimiento necesitan `useInternalCamera: true`.** Así funcionan en cualquier versión de Android, porque la captura y el montaje del fichero los hace el propio framework. Sin ese parámetro se delega en la app de cámara del dispositivo, que solo puede atender la petición a partir de **Android 16** y únicamente si la implementa: a día de hoy no lo hace ninguna, ni siquiera la de los Pixel, con lo que se obtiene una foto normal sin más aviso.

Al capturar una foto en movimiento se **ignoran** `size`, `width`, `height` y `quality`, porque redimensionar o recomprimir la imagen se llevaría por delante el vídeo embebido. El fichero pesa lo que la foto más el clip, del orden de varios megas.

#### scanDocument(params) - Escáner de documentos en papel

Abre el escáner de documentos del sistema: guía al usuario para encuadrar el papel, detecta los bordes, recorta y endereza la imagen automáticamente, y permite reencuadrar, aplicar filtros y añadir más páginas antes de aceptar. Es asíncrono: devuelve el control de inmediato y el resultado llega por callback.

| Parámetro | Tipo | Default | Descripción |
|-----------|------|---------|-------------|
| `mode` | string | `"base"` | `"base"` (recorte, rotación y reencuadre), `"baseWithFilters"` (añade filtros de imagen), `"full"` (añade limpieza automática de la imagen: dedos, manchas). Cualquier otro valor da error |
| `pageLimit` | number | `1` | Máximo de páginas que se pueden escanear en una sesión |
| `allowGallery` | boolean | `false` | Permite importar la imagen desde la galería en lugar de capturarla con la cámara |
| `outputJpg` | boolean | `true` | Genera un JPG por página |
| `outputPdf` | boolean | `false` | Genera además un PDF con todas las páginas |
| `onSuccess` | function | — | Recibe un array con los nombres de los ficheros generados |
| `onError` | function | — | **Obligatorio**. Recibe el mensaje de error |
| `onCancelled` | function | — | **Obligatorio**. Se invoca si el usuario cancela el escaneo |

Hay que dejar activo al menos un formato de salida: si se ponen `outputJpg` y `outputPdf` a `false`, la llamada falla.

Los ficheros se escriben en la carpeta de ficheros de la aplicación (`appData.getFilesPath()`) con el prefijo `scan_`, y el array de `onSuccess` trae **solo el nombre del fichero**, no la ruta completa: primero los JPG (uno por página, en orden) y al final el PDF, si se pidió.

```javascript
ui.scanDocument({
    mode        : "baseWithFilters",
    pageLimit   : 3,
    allowGallery: true,
    outputJpg   : true,
    outputPdf   : true,
    onSuccess   : function(aFiles) {
        for (let i = 0; i < aFiles.length; i++) {
            console.log("Escaneado: " + aFiles[i]);
        }
        // Guardar la primera página en un campo de imagen
        self.MAP_DOCUMENTO = aFiles[0];
        self.save();
    },
    onError     : function(sMessage) {
        ui.showToast("Error al escanear: " + sMessage);
    },
    onCancelled : function() {
        ui.showToast("Escaneo cancelado");
    }
});
```

El escáner lo aporta Google Play Services y su módulo se descarga bajo demanda la primera vez que se usa; en dispositivos sin servicios de Google la llamada termina en `onError`.

#### recognizeText(params) - OCR de una imagen

Reconoce el texto (alfabeto latino) de una imagen del dispositivo. Asíncrono, el resultado llega por callback. Encaja detrás de `scanDocument` para digitalizar un papel y leer su contenido.

| Parámetro | Tipo | Default | Descripción |
|-----------|------|---------|-------------|
| `path` | string | — | **Obligatorio**. Imagen a reconocer |
| `onSuccess` | function | — | **Obligatorio**. Recibe el texto (o el objeto con las líneas, si `detail`) |
| `onError` | function | — | **Obligatorio**. Recibe el mensaje de error |
| `roi` | objeto | toda la imagen | Región a reconocer: `{left, top, width, height}`. Valores ≤ 1 se interpretan como fracción del tamaño de la imagen; mayores, como píxeles |
| `scale` | number | `1` | Amplía el recorte antes de reconocer |
| `grayscale` | boolean | `false` | Desatura la imagen antes de reconocer |
| `detail` | boolean | `false` | Devuelve un objeto con las líneas y su geometría en lugar de una cadena |

Sin `roi`, `scale` ni `grayscale` la imagen se reconoce tal cual, resolviendo su rotación EXIF. En cuanto se pide cualquiera de los tres, la imagen se decodifica, se rota según EXIF y se preprocesa antes de reconocerla.

**Recortar es la palanca principal cuando el texto es pequeño** (una matrícula, la banda de caracteres del reverso de un DNI): el reconocedor reescala la imagen internamente, así que cuanto menos sobre en el encuadre, más resolución le queda a cada carácter.

Con `detail: true`, `onSuccess` recibe:

```javascript
{
    text : "…",        // el texto completo, igual que sin detail
    lines: [           // ordenadas por posición vertical
        { text: "…", confidence: 0.87, angle: 0.4,
          left: 24, top: 512, width: 640, height: 28 }
    ]
}
```

Las líneas vienen **ordenadas por su coordenada vertical**, no en el orden de los bloques reconocidos: `text` sigue el orden de los bloques, que no tiene por qué coincidir con el orden de lectura de la página.

```javascript
// Reconocer sólo la banda inferior, ampliada al doble y en escala de grises
ui.recognizeText({
    path     : "scan_a1b2c3.jpg",
    roi      : { left: 0, top: 0.62, width: 1, height: 0.38 },
    scale    : 2,
    grayscale: true,
    detail   : true,
    onSuccess: function(result) {
        for (let i = 0; i < result.lines.length; i++) {
            console.log(result.lines[i].confidence + " -> " + result.lines[i].text);
        }
    },
    onError  : function(sMessage) { ui.showToast(sMessage); }
});
```

No se puede restringir el alfabeto reconocido: el modelo es de texto latino general y aplica su propio criterio, así que sobre secuencias que no son palabras (códigos, matrículas, caracteres de control) hay que validar el resultado por otra vía — un dígito de control, una expresión regular o un formato conocido.

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

### 3.10 Métodos Adicionales de ui

#### refreshValue(fieldName) - Refrescar Valor de Campo

Refresca solo el valor de un campo especifico sin reconstruir la vista del control. Más ligero que `ui.refresh()`:

```javascript
ui.refreshValue("MAP_CAMPO");
```

#### refreshContentRow(contentName, index) - Refrescar Fila de Content

Refresca una fila especifica de un content sin recargar toda la lista:

```javascript
ui.refreshContentRow("@content", 0);  // Refresca la primera fila
ui.refreshContentSelectedRow("MAP_CONTENT");  // Refresca la fila seleccionada
```

#### captureImage(targetVariable, controlName) - Capturar Imagen

```javascript
ui.captureImage("variable_imagen", "nombre_control");
```

#### shareData(text, subject, attachment) - Compartir Datos

```javascript
ui.shareData("Texto a compartir", "Asunto del mensaje", "archivo_adjunto.jpg");
```

#### showDatePicker(params) / showTimePicker(params) - Selectores de Fecha y Hora

```javascript
ui.showDatePicker({
    initialYear: 2024,
    initialMonth: 6,
    initialDay: 15,
    title: "Seleccione fecha",
    onDateSet: function(nYear, nMonth, nDay) {
        self.MAP_FECHA = nDay + "/" + nMonth + "/" + nYear;
        ui.refresh("MAP_FECHA");
    }
});

ui.showTimePicker({
    initialHour: 17,
    initialMinute: 30,
    is24HoursMode: true,
    onTimeSet: function(nHours, nMinutes) {
        var h = ("0" + nHours).slice(-2);
        var m = ("0" + nMinutes).slice(-2);
        self.MAP_HORA = h + ":" + m;
        ui.refresh("MAP_HORA");
    }
});
```

#### speak(params) - Text-to-Speech

Sintetiza voz a partir de texto.

| Parámetro | Descripción |
| --- | --- |
| **language** | Idioma: `"es"`, `"en"`, ... |
| **text** | Texto que se va a pronunciar. |
| **speechRate** | Ritmo de habla en milisegundos. |
| **onCompleted** | Callback `function()` al terminar de hablar. |

```javascript
ui.speak({
    language   : "es",
    text       : "El proceso ha finalizado correctamente",
    speechRate : 120,
    onCompleted: function() {
        // p.ej. arrancar aquí el reconocimiento de la respuesta
    }
});
```

#### recognizeSpeech(params) - Speech-to-Text

| Parámetro | Descripción |
| --- | --- |
| **language** | Idioma del reconocedor (`"es"`, `"en"`, ...). |
| **timeoutAfterSilence** | Milisegundos de silencio antes de cortar la escucha. |
| **characterLimit** | *(Opcional)* Número máximo de caracteres a reconocer. |
| **onRecognize** | Callback `function(sText)` con el texto reconocido. |
| **onError** | Callback `function(nErrorCode, sError)` con el error. |
| **onPartialResults** | *(Opcional)* Callback `function(extras)` con resultados parciales. |
| **onEndOfSpeech** | *(Opcional)* Callback `function()` al terminar la locucion del usuario. |

```javascript
ui.recognizeSpeech({
    language: "es",
    timeoutAfterSilence: 10000,
    onRecognize: function(sText) {
        self.MAP_TEXT = sText;
        ui.refreshValue("MAP_TEXT");
    },
    onError: function(nErrorCode, sError) {
        ui.msgBox("Error " + nErrorCode + ": " + sError, "Reconocimiento", 0);
    }
});
```

> **Patron combinado (voz bidireccional):** usar `onCompleted` de `ui.speak` para arrancar `ui.recognizeSpeech`, de modo que el microfono solo empiece a escuchar cuando el dispositivo ha acabado de hablar (evita que el reconocedor capte la propia síntesis).

#### startAudioRecord(params) / stopAudioRecord() - Grabacion de Audio

| Parámetro | Descripción |
| --- | --- |
| **onComplete** | Callback `function(sPath)` con la ruta del fichero al terminar. |
| **onError** | Callback `function(sError)` con el mensaje de error. |
| **timeout** | Duración máxima en segundos. `0` = infinito. |
| **outputFormat** | *(Opcional)* `wav`, `3gp`, `mp4`, `amr_nb`, `amr_wb`, `aac_adts`, `mp2_ts`, `webm`, `ogg`. |
| **audioEncoder** | *(Opcional)* `amr_nb`, `amr_wb`, `aac`, `he_aac`, `aac_eld`, `vorbis`, `opus`. |

```javascript
ui.startAudioRecord({
    onComplete: function(sPath) {
        self.MAP_AUDIO = sPath;
        ui.refresh("MAP_AUDIO");
    },
    onError: function(sError) { ui.showToast("Error: " + sError); },
    timeout: 0,
    outputFormat: "mp4",
    audioEncoder: "he_aac"
});

ui.stopAudioRecord();
```

> **`stopAudioRecord()` finaliza la grabación de forma asíncrona.** No deja el fichero listo en la línea siguiente: corta la captura y cierra el archivo en segundo plano, y el audio solo está completo cuando se dispara `onComplete(sPath)`. Tanto si la grabación termina sola por `timeout` como si la paras a mano con `stopAudioRecord()`, el final pasa por el mismo `onComplete`; haz ahí cualquier uso del fichero (subirlo, reproducirlo, transcribirlo con la IA), nunca justo después de la llamada a `stopAudioRecord()`.

> **Para transcribir voz con la IA on-device (objeto `ai` / Gemma), graba en `wav`.** El formato por defecto es `mp4` (códec AAC), que el motor de IA **no admite**. Usa `outputFormat: "wav"` (produce WAV PCM de 16 bits, 16 kHz, mono, justo el formato recomendado por el modelo) y limita la duración con `timeout: 30` (máximo de audio que acepta Gemma). La ruta que llega al `onComplete` se pasa tal cual como `audio`:

```javascript
ui.startAudioRecord({
    outputFormat: "wav",          // imprescindible: el default mp4/AAC no lo acepta la IA
    timeout: 30,                  // segundos; 30 = máximo de audio que admite Gemma
    onComplete: function(sPath) {
        // el modelo debe estar cargado con audioBackend (ver objeto ai)
        var sTexto = ai.generate({ prompt: "Transcribe el audio en español.", audio: sPath });
        self.TRANSCRIPCION = sTexto;
        ui.refresh("TRANSCRIPCION");
    },
    onError: function(sError) { ui.showToast(sError); }
});
```

> `ai.generate` es síncrono y bloquea mientras transcribe; si el `onComplete` se ejecuta en el hilo de UI, lánzalo en segundo plano o usa `ai.chat({audio, onComplete})` para no congelar la pantalla.

#### addCalendarItem(params) - Agregar Evento al Calendario

```javascript
ui.addCalendarItem({
    title      : "Reunion con cliente",
    startDate  : "2024-06-15 10:00",
    endDate    : "2024-06-15 11:00",
    description: "Reunion de seguimiento",
    location   : "Oficina central"
});
```

#### executeActionAfterDelay(action, seconds) - Ejecución con Retardo

Ejecuta una acción (definida como nodo XML del mismo nombre, o función JS global) después de un retardo en **segundos**. Equivalente conceptual a `setTimeout()` **para un solo disparo**.

```javascript
// Uso correcto: una sola acción tras un retardo corto
ui.executeActionAfterDelay("miFuncion", 5);

// Típico de una pantalla de bienvenida: ejecutar una acción a los 2 segundos
ui.executeActionAfterDelay("irAMenuPrincipal", 2);
```

> **ATENCION — antipatron a evitar:** **NO** encadenar `executeActionAfterDelay` recursivamente para simular un `setInterval` (que la acción se vuelva a programar a si misma cada segundo). Aunque tecnicamente funcione, **consume mucha memoria y ralentiza el dispositivo** porque acumula overhead en cada iteración.
>
> **Cuándo usar `executeActionAfterDelay`:** acciones puntuales (un toast tras X segundos, redirigir desde una pantalla de bienvenida tras un retardo, mostrar un aviso único).
>
> **Cuando NO:** temporizadores continuos, relojes, polling regular. Para esos casos usar **`control.startChronometer`** (siguiente sección).

```javascript
// MAL — patron prohibido (auto-encadenado para repetir cada segundo)
function onSetTime() {
    actualizarTemporizador();
    if (self.MAP_ACTIVO == 1) {
        ui.executeActionAfterDelay("onSetTime", 1);  // <-- consume memoria, no hacer
    }
}

// BIEN — para reloj/cronometro continuo, usar control.startChronometer (siguiente seccion)
```

#### startChronometer / stopChronometer - Cronometros continuos

> **CLAVE:** `startChronometer` y `stopChronometer` **NO son métodos de `ui.*`**, son métodos de un **control** (un nodo `<prop>` de la pantalla, típicamente `type="T"`). Hay que obtener el control primero.

Es la API correcta para mostrar un cronometro/reloj continuo en pantalla **sin penalizar memoria** (lo gestiona la plataforma, no encadena timers JavaScript).

**Firma:**
```
control.startChronometer(jsOptions);  // arranca
control.stopChronometer();             // detiene
```

| Campo        | Tipo   | Descripción |
|--------------|--------|-------------|
| `fromDate`   | Date   | Fecha desde la que arranca el cronometro. Típico: `new Date()`. |
| `dateFormat` | string | Formato de visualizacion. Ej. `"mm:ss"`, `"HH:mm:ss"`. |

**Ejemplo completo (XML + JS):**

```xml
<coll name="Menu" notab="true" special="true">
    <group name="General" id="1" align="center">
        <prop name="MAP_T"     type="T" visible="7" labelwidth="0"
              width="80%" height="10%" />
        <prop name="MAP_START" type="B" visible="7"
              width="80%" height="10%" title="Start"
              onclick="start('MAP_T');" />
        <prop name="MAP_STOP"  type="B" visible="7"
              width="80%" height="10%" title="Stop"
              onclick="stop('MAP_T');" />
    </group>
</coll>
```

```javascript
function start(sPropName) {
    let control = getControl(sPropName);
    if (!control) return;
    let jsOptions = {
        fromDate  : new Date(),
        dateFormat: "mm:ss"
    };
    control.startChronometer(jsOptions);
}

function stop(sPropName) {
    let control = getControl(sPropName);
    if (!control) return;
    control.stopChronometer();
}
```

> **NO existe `ui.startChronometer(...)`** — es método del control, no del objeto global `ui`.

#### API de controles Stepper (`<prop type="N" viewmode="stepper">`)

Los controles con `viewmode="stepper"` exponen estos métodos:

| Método | Efecto |
|--------|--------|
| `control.getValue()` | Devuelve el valor actual como entero |
| `control.setValue(n)` | Asigna el valor (se clampa al rango `[min, max]`) |
| `control.setMin(n)` | Cambia el mínimo en runtime |
| `control.setMax(n)` | Cambia el máximo en runtime |
| `control.setStepSize(n)` | Cambia el incremento (debe ser `> 0`) |

```javascript
function onTipoChange() {
    var ctrl = getControl("CANTIDAD");
    if (self.TIPO === "PACK_GRANDE") {
        ctrl.setMin(10);
        ctrl.setMax(500);
        ctrl.setStepSize(10);
    } else {
        ctrl.setMin(1);
        ctrl.setMax(99);
        ctrl.setStepSize(1);
    }
}
```

Ver tópico 02 (sub-archivo 02b §5.9.17b) para el detalle XML.

#### API de controles OTP (props con `viewmode="otp"` sobre `type="T"` o `type="N"`)

| Método | Efecto |
|--------|--------|
| `control.getOtpValue()` | Devuelve el valor combinado de todas las cajas como string |
| `control.clearOtp()` | Limpia todas las cajas y pone el foco en la primera |
| `control.focusOtp()` | Pone el foco en la primera caja vacia |

```javascript
function onOtpChange() {
    var sCode = getControl("CODIGO_VERIFICACION").getOtpValue();
    if (sCode.length !== 6) return;
    if (sCode === self.CODIGO_ESPERADO) {
        ui.showToast("Código correcto");
        ui.openEditView("PantallaPrincipal");
    } else {
        ui.showToast("Código incorrecto");
        getControl("CODIGO_VERIFICACION").clearOtp();
    }
}
```

El valor se persiste en el `dataObject` como **string concatenado sin separadores** (ej. `"123456"`). Ver tópico 02 (sub-archivo 02b §5.9.17c) para la definición XML.

#### sleep(seconds) - Pausa de Ejecución

**Precaucion:** Bloquea la interfaz de usuario. Preferir `executeActionAfterDelay()`:

```javascript
ui.sleep(3);  // Pausa de 3 segundos (BLOQUEA la UI)
```

#### Otros Métodos Útiles

```javascript
var bBackground = ui.isInBackground();
ui.returnToForeground();
ui.makePhoneCall("+34123456789");
ui.sendMail("destino@email.com", "copia@email.com", "Asunto", "Cuerpo", "adjunto.pdf");

// Reproducir sonido y/o vibrar
ui.playSoundAndVibrate({ sound: "sonido.mp3", vibrate: true, continuePlaying: false });
ui.stopPlaySoundAndVibrate();
ui.vibrate();

// Verificar conectividad
var wifiOn = ui.isWifiEnabled();
var btStatus = ui.getBluetoothStatus();
ui.setBluetoothStatus(true);

// Iniciar replica desde ui
ui.startReplica();
```

### 3.11 Referencia completa: catálogo de métodos del objeto `ui`

La siguiente tabla lista **todos los métodos** expuestos por el objeto global `ui` con una descripción breve. Para los métodos con parámetros complejos consulta los ejemplos detallados en las secciones 3.1-3.10.

| Método | Descripción |
| --- | --- |
| **addCalendarItem** | Añadir item al calendario. |
| **askUserForGPSPermission** | Solicitar al usuario permiso para GPS. |
| **canMakePhoneCall** | Comprueba si se puede hacer una llamada de teléfono. |
| **captureImage** | Capturar imagen. |
| **checkGPSStatus** | Comprobar el status del GPS. |
| **clearDrawing** | Eliminar el dibujo/firma. |
| **createShortcut** | Crear acceso directo. |
| **deleteShortcut** | Borrar acceso directo. |
| **dismissNotification** | Rechazar/ocultar una notificación. |
| **drawMapRoute** | Dibujar ruta en el mapa. |
| **endPrint** | Finalizar impresión. |
| **ensureVisible** | Asegurar que el control sea visible (scroll). |
| **executeActionAfterDelay** | Ejecutar acción tras un retraso. |
| **getLastKnownLocation** | Obtener la última localización conocida. |
| **getLastKnownLocationAccuracy** | Precisión de la última localización conocida. |
| **getLastKnownLocationAltitude** | Altitud de la última localización conocida. |
| **getLastKnownLocationBearing** | Marcación de la última localización conocida. |
| **getLastKnownLocationDateTime** | Fecha y hora de la última localización conocida. |
| **getLastKnownLocationLatitude** | Latitud de la última localización conocida. |
| **getLastKnownLocationLongitude** | Longitud de la última localización conocida. |
| **getLastKnownLocationProvider** | Proveedor de la última localización conocida. |
| **getLastKnownLocationSpeed** | Velocidad de la última localización conocida. |
| **getMaxSoundVolumen** | Máximo volumen de sonido. |
| **getSoundVolumen** | Volumen de sonido actual. |
| **getView** | Obtener la vista actual (p.ej. `ui.getView(self)`). |
| **hideGroup** | Ocultar grupo. |
| **hideNavigationDrawer** | Ocultar cajón de navegación. |
| **hideSoftwareKeyboard** | Ocultar teclado del software. |
| **hideWaitDialog** | Ocultar diálogo de espera. |
| **injectJavascript** | Inyectar Javascript. |
| **isApplicationInstalled** | Comprobar si una aplicación está instalada. |
| **isOnCall** | Comprobar si el dispositivo está en llamada. |
| **isSuperuserAvailable** | Comprobar si hay super usuario disponible. |
| **isTaskKillerInstalled** | Comprobar si hay instalador de cierre de tareas. |
| **isWifiConnected** | Comprobar si la wifi está conectada. |
| **isWifiEnabled** | Comprobar si la wifi está activada. |
| **launchApp** | Lanzar aplicación. |
| **launchApplication** | Lanzar aplicación (alias). |
| **lineFeed** | Salto de línea (impresión). |
| **lockGroup** | Bloquear grupo. |
| **makePhoneCall** | Hacer una llamada desde el dispositivo. |
| **mergeImagesLeftToRight** | Fusionar imágenes de izquierda a derecha. |
| **msgBox** | Mostrar caja de mensaje. |
| **msgBoxWithSound** | Mostrar caja de mensaje con sonido. |
| **openEditView** | Abrir vista edición. |
| **openFile** | Abrir un archivo. |
| **openMenu** | **Legacy** — usar `openEditView` para abrir pantallas. Sólo útil para el caso especial de lanzar directamente la LISTA de una coll: `openMenu(collName, mask, 0)`. Ver §3.1. |
| **openUrl** | Abrir URL. |
| **pickFile** | Seleccionar archivo. |
| **playSoundAndVibrate** | Reproducir sonido y vibración. |
| **playSoundVolumen** | Reproducir con volumen de sonido. |
| **print** | Imprimir. |
| **printBarcode** | Imprimir código de barras. |
| **printBIDI** | Imprimir BIDI. |
| **printCommand** | Imprimir comando. |
| **printImage** | Imprimir imagen. |
| **printLine** | Línea de impresión. |
| **printPDF** | Imprimir PDF. |
| **quitApp** | Salir de la aplicación. |
| **recognizeSpeech** | Reconocimiento de voz. Ver sección 3.10. |
| **recognizeText** | OCR de una imagen del dispositivo (alfabeto latino). Ver sección 3.5. |
| **refresh** | Refrescar (se le pueden pasar nombres de props a refrescar). |
| **refreshContentRow** | Refrescar la línea de un content. |
| **refreshContentSelectedRow** | Refrescar el content en la fila seleccionada. |
| **refreshValue** | Refrescar el valor de un campo. |
| **relayout** | Rediseñar la página. |
| **restartApp** | Reiniciar la aplicación. |
| **returnToForeground** | Volver al primer plano. |
| **returnToMainMenu** | Volver al menú principal. |
| **saveDrawing** | Guardar dibujo/firma. |
| **scanDocument** | Escanear un documento en papel con la cámara (recorte y enderezado automáticos, JPG y/o PDF). Ver sección 3.5. |
| **sendMail** | Enviar un email. |
| **sendSMS** | Enviar SMS. |
| **setFeedMode** | Ajustar modo de alimentación (impresión). |
| **setLanguage** | Ajustar idioma. |
| **setMaxWaitDialog** | Establecer el máximo del diálogo de espera (progreso). |
| **setNotificationLed** | Ajustar LED de notificación. |
| **setSelection** | Ajustar selección. |
| **shareData** | Compartir datos. |
| **sharedData** | Datos compartidos. |
| **showConsoleReplica** | Mostrar la consola de réplica. |
| **showDatePicker** | Mostrar selector de fecha. |
| **showGroup** | Mostrar grupo. |
| **showNavigationDrawer** | Mostrar cajón de navegación. |
| **showNotification** | Mostrar notificación. |
| **showSnackbar** | Mostrar snackbar. |
| **showSoftwareKeyboard** | Mostrar teclado del software. |
| **showTimePicker** | Mostrar selector de hora. |
| **showToast** | Mostrar toast. |
| **showWaitDialog** | Mostrar diálogo de espera. |
| **signDataObject** | Firmar data object. |
| **sleep** | Dormir (pausa). |
| **speak** | Síntesis de voz (text-to-speech). Ver sección 3.10. |
| **startAudioRecord** | Comenzar grabación de audio. Ver sección 3.10. |
| **startCamera** | Abrir la cámara y guardar la foto o el vídeo en un campo, con opción de foto en movimiento. Ver sección 3.5. |
| **startGps** | Iniciar GPS. |
| **startGpsV1** | Iniciar Gpsv1. |
| **startGpsV2** | Iniciar Gpsv2. |
| **startKioskMode** | Iniciar modo kiosko. |
| **startPrint** | Comenzar la impresión. |
| **startReplica** | Comenzar la réplica. |
| **startSignature** | Iniciar firma. |
| **startWifi** | Iniciar la wifi. |
| **stopAudioRecord** | Detener grabación de audio. |
| **stopGps** | Detener GPS. |
| **stopGpsV1** | Detener Gpsv1. |
| **stopGpsV2** | Detener Gpsv2. |
| **stopKioskMode** | Detener modo kiosko. |
| **stopPlaySoundAndVibrate** | Detener reproducción de sonido y vibración. |
| **stopReplica** | Detener réplica. |
| **stopWifi** | Para detener la wifi. |
| **takePhoto** | Tomar foto. |
| **toggleGroup** | Cambiar el estado de la visibilidad del grupo. |
| **uninstallApplication** | Desinstalar la aplicación. |
| **unlockGroup** | Desbloquear grupo. |
| **updateWaitDialog** | Actualizar diálogo de espera. |
| **useLastPrinter** | Utilizar la última impresora. |

---

**Anterior:** [03a - self / DataObject](03a-js-self.md) · **Siguiente:** [03c - appData, $http, OAuth2, replica](03c-js-appdata-http.md) · **Índice:** [03 - Guía JavaScript](03-javascript-api-guide.md)
