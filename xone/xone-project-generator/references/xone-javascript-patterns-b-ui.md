# JavaScript Patterns — Objeto `ui` (UI y dispositivo)

Sub-archivo de [xone-javascript-patterns.md](xone-javascript-patterns.md). Cubre el objeto global `ui` entero: navegación, mensajes, vista, GPS, camara, archivos, voz, audio, cronometros, API de controles especificos (Stepper, OTP), date/time pickers, escaner QR, drawer/bottom sheet, showcase, etc.

## Tabla de Contenidos

- [2.1 Objeto ui](#21-objeto-ui)

---

### 2.1 Objeto `ui`

El objeto `ui` proporciona todas las funciones de interfaz de usuario.

#### 2.1.1 Dialogos y Mensajes

```javascript
// === Message Box clasico ===
// Tipo 0 = OK, Tipo 4 = Si/No
// Retorna: 6 = Si, 7 = No
let nResult = ui.msgBox("Desea continuar?", "Confirmar", 4);
if (nResult == 6) {
    // Usuario pulso Si
}

// === Toast simple ===
ui.showToast("Operación completada");

// === Toast personalizado ===
ui.showToast({
    color    : "#4CAF50",       // Color de fondo
    duration : "short",         // "short" o "long"
    text     : "Guardado correctamente",
    textColor: "#FFFFFF",       // Color del texto
    textFont : "Roboto-Regular.ttf",  // Fuente (debe estar en fonts/)
    textSize : 14,              // Tamano de fuente
    rounded  : true             // Esquinas redondeadas
});

// === Snackbar simple (solo texto) ===
ui.showSnackbar("Registro eliminado");   // duración "long", texto blanco por defecto

// === Snackbar con acción ===
ui.showSnackbar({
    text           : "Registro eliminado", // OBLIGATORIO (vacío => excepción)
    color          : "#323232",
    duration       : "long",     // "short" | "long" | "indefinite" (otro valor => excepción)
    width          : "80%",      // "100%" => ancho completo
    textColor      : "#FFFFFF",
    actionText     : "Deshacer", // solo se muestra si TAMBIÉN hay actionMethod
    actionTextColor: "#FFEB3B",
    maxLines       : 1,          // solo aplica si > 1
    height         : "10%",          // Altura del snackbar (opcional)
    align          : "center|bottom",
    actionMethod   : function() { // se ejecuta en un hilo aparte, no en el de UI
        deshacerEliminacion();
    }
});

// Ocultar snackbar manualmente (oculta el último mostrado; false si no hay ninguno visible)
ui.hideSnackbar();

// NOTA: showSnackbar solo funciona dentro de una pantalla de edición.
// En otros contextos lanza una excepción.
```

#### 2.1.2 Wait Dialog (Indicador de Carga)

```javascript
// Mostrar indicador de carga
ui.showWaitDialog("Cargando datos...");

// Actualizar texto del indicador
ui.setWaitDialogText("Procesando registros...");

// Ocultar indicador
ui.hideWaitDialog();
```

#### 2.1.3 Notificaciones

```javascript
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
ui.setNotificationLed("#00FF00", 1000, 1000);
```

El handler que recibe los eventos de notificación se declara en la coll con el nodo `<notificaciones>`. Recibe tres parámetros: `nId` (ID del botón pulsado), `sDirectReply` (texto escrito en respuesta directa) y `parameters` (JSON con datos adicionales):

```xml
<notificaciones refresh="false" show-wait-dialog="false">
    <action name="runscript">
        <param name="nId" />
        <param name="sDirectReply" />
        <param name="parameters" />
        <script language="javascript">
            let sMessage = "ID notificación o botón: " + nId;
            if (sDirectReply) {
                sMessage = sMessage + "\nTexto respuesta: " + sDirectReply;
            }
            if (parameters) {
                parameters = JSON.parse(parameters);
                sMessage = sMessage + "\nParametro extra: " + parameters.miCampo;
            }
            ui.showToast(sMessage);
        </script>
    </action>
</notificaciones>
```

#### 2.1.4 Navegación y Vistas

```javascript
// Obtener ventana actual
let window = ui.getView(self);
let window = ui.getView();  // Sin parametro = ventana actual

// Abrir una pantalla — patrón canónico
// Firma: ui.openEditView(target, [exit])
//   target : dataObject | string — un dataObject ya preparado, o el nombre de la coll destino
//   exit   : boolean — si true, cierra la vista origen al abrir la nueva (default false)

// Forma corta: pasar el nombre de la coll (XOne hace createObject + addItem internamente)
ui.openEditView("NombreColeccion");

// Abrir un objeto existente o pre-rellenado
ui.openEditView(dataObject);

// Cerrar la vista origen al abrir la nueva (flujos lineales sin botón atrás)
ui.openEditView(dataObject, true);

// Caso especial — abrir la LISTA de una coll directamente (legacy):
// ui.openMenu(collName, mask, 0) lanza MainListCollectionActivity en vez del EditView.
// Constantes mask combinables con OR (JavaScript no expone los nombres, usar el valor):
//   ADD=0x01  EDIT=0x02  DELETE=0x04  EXIT=0x08  FILTRAR=0x10
//   SAVE=0x40  SORT=0x80  REFRESH=0x100  VIEW=0x200  FULLMASK=0xFFFFFF
ui.openMenu("NombreColeccion", 0xFFFFFF, 0);   // lista con todas las opciones

// Refrescar toda la interfaz
ui.refresh();

// Refrescar un campo específico
ui.refresh("MAP_NOMBRE");

// Refrescar multiples campos
ui.refresh("MAP_NOMBRE,MAP_ESTADO,MAP_FECHA");

// Solo actualizar el valor (sin reconstruir la vista)
ui.refreshValue("MAP_CAMPO");

// Refrescar una fila específica de un content
ui.refreshContentRow("MAP_CONTENT", 0);

// Refrescar la fila seleccionada de un content
ui.refreshContentSelectedRow("MAP_CONTENT");

// Mostrar/ocultar grupos (tabs)
ui.showGroup(2);  // Mostrar grupo por indice (base 0)
ui.showGroup(2, "##ALPHA_IN##", 100, "##ALPHA_OUT##", 100);

// Cerrar ventana actual
let window = ui.getView(self);
if (window) {
    window.exit();
}

// Salir de la aplicación
appData.exit();

// Comprobar si un grupo (tab/drawer) esta abierto
let bAbierto = window.isGroupOpen(999);  // 999 = id del grupo

// Ocultar un grupo (util para cerrar drawers)
window.hideGroup(999);

// Patron comun: interceptar botón atrás para cerrar drawer primero
function doOnBack() {
    let window = ui.getView();
    if (!window) return;
    if (window.isGroupOpen(999)) {
        window.hideGroup(999);
        return;
    }
    window.exit();
}

// Traer la app al primer plano (desde un handler de notificación o mensajeria)
ui.returnToForeground();

// Obtener el nombre de la coleccion activa en la ventana actual
function getCurrentCollectionName() {
    let window = ui.getView();
    if (!window) return "";
    let dataObject = window.getDataObject();
    if (!dataObject) return "";
    let dataCollection = dataObject.getOwnerCollection();
    if (!dataCollection) return "";
    return dataCollection.getName();
}
```

#### 2.1.5 Date/Time Pickers

```javascript
// Date Picker con callback
ui.showDatePicker({
    initialYear : 2024,
    initialMonth: 6,
    initialDay  : 15,
    title       : "Seleccione fecha",
    theme       : "holo_light",          // Tema visual del picker
    onDateSet   : function(nYear, nMonth, nDay) {
        self.MAP_FECHA = nDay + "/" + nMonth + "/" + nYear;
        ui.refresh("MAP_FECHA");
    }
});

// Date Picker que escribe directamente en un campo (sin callback)
ui.showDatePicker({
    targetProperty: "MAP_FECHA"          // El picker escribe aquí al confirmar
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

// Time Picker que escribe directamente en un campo (sin callback)
ui.showTimePicker({
    targetProperty: "MAP_HORA"
});
```

> **Diseño del picker.** Sin `theme`, `showDatePicker`/`showTimePicker` usan el nuevo selector moderno (calendario con swipe lateral de meses / ruedas de hora). Pasar `theme` fuerza el selector nativo del sistema con ese tema. `showTimePicker` con `is24HoursMode: false` (formato 12 h) también usa el nativo, porque el nuevo diseño es 24 h.

#### 2.1.6 Archivos e Imágenes

```javascript
// Seleccionar archivo del dispositivo
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

// Abrir un archivo con la aplicación predeterminada del sistema
ui.openFile(sPath);

// Abrir URL en navegador externo
ui.openUrl("https://www.example.com");
```

#### 2.1.7 GPS

```javascript
// Iniciar GPS con callback
ui.startGps({
    nodeName                  : "callbackGPS",
    timeBetweenUpdates        : 10000,
    minimumMetersDistanceRange: 10,
    foreground                : true,
    title                     : "Mi App GPS",
    text                      : "Rastreando ubicación..."
});

// Detener GPS
ui.stopGps();

// Comprobar estado del GPS
let nStatus = ui.checkGpsStatus();
// 0: No hay hardware GPS
// 1: Solo GPS activado
// 2: Solo WiFi/redes activado
// 3: Ninguno activado
// 4: GPS y WiFi/redes activados

// Pedir permiso de GPS al usuario
ui.askUserForGpsPermission({
    onEnabled: function() {
        ui.showToast("GPS activado");
    },
    onDenied: function() {
        ui.showToast("Necesita activar el GPS");
    }
});
```

#### 2.1.8 Otras Funciones UI

```javascript
// Ejecutar acción con retardo — UNA sola vez (alternativa a setTimeout, NO a setInterval)
// Para timers continuos usar startChronometer (ver seccion 8.6)
ui.executeActionAfterDelay("miFuncionRetardada", 5);

// Sleep - BLOQUEA la UI, usar con mucho cuidado
ui.sleep(3);  // Segundos

// Drag and Drop
let control = window["MAP_CONTROL"];
ui.startDrag(control, object);
```

#### 2.1.9 Multimedia: Audio, Voz y Vibracion

**`ui.speak(params)` — Text-to-Speech**

Objeto de parámetros: `language`, `text`, `speechRate` (ms), `onCompleted` (callback al terminar).

```javascript
ui.speak({
    language   : "es",
    text       : "El pedido ha sido enviado correctamente",
    speechRate : 120,
    onCompleted: function() {
        // Opcional: encadenar aquí ui.recognizeSpeech() para escuchar la respuesta
    }
});
```

**`ui.recognizeSpeech(params)` — Speech-to-Text**

Objeto de parámetros: `language`, `timeoutAfterSilence` (ms), `characterLimit` *(opcional)*, callbacks `onRecognize(sText)`, `onError(nErrorCode, sError)`, `onPartialResults(extras)` *(opcional)*, `onEndOfSpeech()` *(opcional)*.

```javascript
ui.recognizeSpeech({
    language: "es",
    timeoutAfterSilence: 10000,
    onRecognize: function(sText) {
        self.MAP_TEXTO_DICTADO = sText;
        ui.refreshValue("MAP_TEXTO_DICTADO");
    },
    onError: function(nErrorCode, sError) {
        ui.msgBox("Error " + nErrorCode + ": " + sError, "Reconocimiento", 0);
    },
    onEndOfSpeech: function() {
        // p.ej. restaurar icono del microfono
    }
});
```

> **Patron "preguntar y escuchar":** poner `ui.recognizeSpeech(...)` dentro del `onCompleted` de `ui.speak(...)` para que el microfono solo empiece a grabar una vez terminado el TTS (evita que el reconocedor capture la propia síntesis). Ver wiki: `2.-desarrollo-app/2.5.-controles-by-xone/control_por_voz/start.md`.

**`ui.startAudioRecord(params)` / `ui.stopAudioRecord()` — Grabacion de audio**

Objeto de parámetros: `onComplete(sPath)`, `onError(sError)`, `timeout` (segundos, `0` = infinito hasta `stopAudioRecord`), `outputFormat` *(opcional)* (`wav`, `3gp`, `mp4`, `amr_nb`, `amr_wb`, `aac_adts`, `mp2_ts`, `webm`, `ogg`), `audioEncoder` *(opcional)* (`amr_nb`, `amr_wb`, `aac`, `he_aac`, `aac_eld`, `vorbis`, `opus`).

```javascript
ui.startAudioRecord({
    onComplete: function(sPath) {
        self.MAP_AUDIO_GRABADO = sPath;
        ui.refresh("MAP_AUDIO_GRABADO");
    },
    onError: function(sError) {
        ui.showToast("Error al grabar: " + sError);
    },
    timeout: 0,                 // 0 = infinito, hasta stopAudioRecord()
    outputFormat: "mp4",
    audioEncoder: "he_aac"
});

// Detener grabacion manualmente
ui.stopAudioRecord();
```

> **`stopAudioRecord()` finaliza la grabación de forma asíncrona.** No deja el fichero listo en la línea siguiente: corta la captura y cierra el archivo en segundo plano, y el audio solo está completo cuando se dispara `onComplete(sPath)`. Tanto si la grabación termina sola por `timeout` como si la paras a mano con `stopAudioRecord()`, el final pasa por el mismo `onComplete`; haz ahí cualquier uso del fichero (subirlo, reproducirlo, transcribirlo con la IA), nunca justo después de la llamada a `stopAudioRecord()`.

> **Para transcribir voz con la IA on-device (objeto `ai` / Gemma), graba en `wav`.** El formato por defecto es `mp4` (códec AAC), que el motor de IA **no admite**. Usa `outputFormat: "wav"` (produce WAV PCM de 16 bits, 16 kHz, mono, justo el formato recomendado por el modelo) y limita la duración con `timeout: 30` (máximo de audio que acepta Gemma). La ruta que llega al `onComplete` se pasa tal cual como `audio`:

```javascript
ui.startAudioRecord({
    outputFormat: "wav",          // imprescindible: el default mp4/AAC no lo acepta la IA
    timeout: 30,                  // segundos; 30 = máximo de audio que admite Gemma
    onComplete: function(sPath) {
        // el modelo debe estar cargado con audioBackend (ver xone-javascript-ai.md)
        var sTexto = ai.generate({ prompt: "Transcribe el audio en español.", audio: sPath });
        self.TRANSCRIPCION = sTexto;
        ui.refresh("TRANSCRIPCION");
    },
    onError: function(sError) { ui.showToast(sError); }
});
```

> `ai.generate` es síncrono y bloquea mientras transcribe; si el `onComplete` se ejecuta en el hilo de UI, lánzalo en segundo plano o usa `ai.chat({audio, onComplete})` para no congelar la pantalla.

**Otros multimedia:**

```javascript
// === Reproducir sonido y vibrar ===
ui.playSoundAndVibrate({
    sound: "alerta.mp3",
    vibrate: true,
    continuePlaying: false
});
ui.stopPlaySoundAndVibrate();

// === Vibrar solo ===
ui.vibrate();

// === Reproducir archivo de audio ===
ui.playSound("sonido.mp3");
```

#### 2.1.10 Captura de Imagen y Compartir

```javascript
// === Capturar imagen de un control de la interfaz ===
ui.captureImage("variable_destino", "nombre_control");

// === Compartir datos via sistema operativo ===
ui.shareData("Texto a compartir", "Asunto del mensaje", "archivo_adjunto.pdf");

// === Guardar dibujo/firma como imagen ===
ui.saveDrawing("MAP_DIBUJO", "firma.png");

// === Limpiar control de dibujo ===
ui.clearDrawing("MAP_DIBUJO");
```

#### 2.1.11 Calendario

```javascript
// === Agregar evento al calendario del dispositivo ===
ui.addCalendarItem({
    title: "Reunion con cliente",
    description: "Revision de proyecto",
    startDate: new Date(),
    endDate: new Date(),
    location: "Oficina central"
});
```

#### 2.1.12 Correo Electrónico y Llamadas

```javascript
// === Enviar correo electrónico ===
ui.sendMail("destino@email.com", "copia@email.com", "Asunto", "Cuerpo del mensaje", "adjunto.pdf");

// === Realizar llamada telefonica ===
ui.makePhoneCall("+34123456789");

// === Verificar si aplicación esta instalada ===
var instalada = ui.isApplicationInstalled("com.package.name");

// === Verificar conectividad ===
var wifiActivo = ui.isWifiEnabled();
var bluetoothEstado = ui.getBluetoothStatus();
ui.setBluetoothStatus(true);
```

#### 2.1.13 Aplicación en Segundo Plano

```javascript
// === Verificar si la app esta en segundo plano ===
var enBackground = ui.isInBackground();

// === Traer la app al primer plano ===
ui.returnToForeground();

// === Iniciar/detener replica desde UI ===
ui.startReplica();
```

---

#### 2.1.14 msgBox con DataObject (Dialogos Personalizados)

`ui.msgBox(dataObject)` permite abrir una coleccion XOne como dialogo completamente personalizado. Hay dos variantes según si el resultado se necesita de forma sincrona o mediante callbacks.

##### Variante sincrona (MessageBoxNormal)

Usa `button-option` en los botones. `ui.msgBox(dataObject)` **bloquea** hasta que el usuario pulsa un botón y devuelve el valor del `button-option` correspondiente.

```javascript
// Llamada sincrona: bloquea hasta que el usuario pulsa
let msgBoxObj = new MessageBoxNormal();
let nResult   = ui.msgBox(msgBoxObj);
// nResult == 1 -> pulsó Cancel (button-option="1")
// nResult == 2 -> pulsó OK     (button-option="2")
if (nResult === 2) {
    // usuario pulsó OK
}
```

La coll `MessageBoxNormal` debe tener estas caracteristicas obligatorias:
- `notab="true"` y `show-toolbar="false"` para ocultar chrome del sistema
- `check-owner="false"` y `dependent="false"`
- `bgcolor` con el color de fondo del dialogo (opaco o con alpha)
- Grupos con `bgcolor="#00000000"` para fondo transparente dentro
- Botones con `button-option="N"` donde N es el valor que devolvera `ui.msgBox()`

```xml
<coll name="MessageBoxNormal" special="false" notab="true"
      bgcolor="#FF0000" show-toolbar="false"
      check-owner="false" dependent="false">
    <group name="General" id="1" align="center" bgcolor="#00000000">
        <frame name="contenido" width="80%" height="30%"
               align="center" bgcolor="#0000FF">
            <prop name="MAP_CANCEL" type="B" title="CANCEL"
                  width="40%" height="50%"
                  button-option="1" />
            <prop name="MAP_OK" type="B" title="OK"
                  width="40%" height="50%" lmargin="20p"
                  button-option="2" newline="false" />
        </frame>
    </group>
</coll>
```

##### Variante asíncrona con callbacks (MessageBoxAsync)

Usa campos `type="O"` para almacenar funciones callback. Los botones invocan directamente `self.MAP_CALLBACK_OK()` o `self.MAP_CALLBACK_CANCEL()`. No bloquea — la ejecución continua y las callbacks se invocan cuando el usuario pulsa.

```javascript
// Abrir dialogo asincrono pasando las funciones callback
function showMessageBoxDataObject(callbackOk, callbackCancel) {
    let newMessageBox = new MessageBoxAsync({
        MAP_CALLBACK_OK: callbackOk,
        MAP_CALLBACK_CANCEL: callbackCancel
    });
    ui.openEditView(newMessageBox);
}

// Uso
showMessageBoxDataObject(
    function() {
        ui.showToast("OK pulsado");
        ui.getView(self).exit();
    },
    function() {
        ui.showToast("Cancelar pulsado");
        ui.getView(self).exit();
    }
);
```

La coll `MessageBoxAsync` debe tener estas caracteristicas obligatorias:
- `hardware-accelerated="false"` — imprescindible para que el fondo transparente no aparezca negro
- `bgcolor="#00000000"` — fondo completamente transparente
- `notab="true"` y `show-toolbar="false"`
- Dos campos `type="O"` para las callbacks (ej: `MAP_CALLBACK_OK`, `MAP_CALLBACK_CANCEL`)
- Botones que invocan directamente `self.MAP_CALLBACK_OK();` y `self.MAP_CALLBACK_CANCEL();`

```xml
<coll name="MessageBoxAsync" special="false" notab="true"
      bgcolor="#00000000" hardware-accelerated="false"
      show-toolbar="false" check-owner="false" dependent="false"
      onback="ui.getView().exit();">
    <group name="General" id="1" align="center" bgcolor="#00000000">
        <prop type="O" visible="0" name="MAP_CALLBACK_OK" />
        <prop type="O" visible="0" name="MAP_CALLBACK_CANCEL" />
        <frame name="contenido" width="80%" height="30%"
               align="center" bgcolor="#FFFFFF">
            <prop name="MAP_CANCEL" type="B" title="CANCEL"
                  width="40%" height="50%"
                  onclick="self.MAP_CALLBACK_CANCEL();" />
            <prop name="MAP_OK" type="B" title="OK"
                  width="40%" height="50%" lmargin="20p"
                  onclick="self.MAP_CALLBACK_OK();" newline="false" />
        </frame>
    </group>
</coll>
```

> **Diferencia clave:** Sincrono (`button-option`) = bloquea y devuelve valor. Asíncrono (`type="O"`) = no bloquea, usa callbacks. Para diálogos que necesitan cerrar la ventana actual tras el resultado, usar la variante asíncrona.

---

#### 2.1.15 Bottom Sheet (Control desde JS)

Los frames con `behavior="bottom-sheet"` se controlan desde JavaScript con métodos de la ventana. Ver atributos XML en la sección de frames.

```javascript
// Establecer estado del bottom sheet
// sFrame: nombre del frame
// sState: "expanded" / "collapsed" / "hidden"
// bLockDrag: true = bloquear que el usuario lo arrastre con el dedo
function setBottomSheetState(sFrame, sState) {
    let window = ui.getView(self);
    window.setBottomSheetState(sFrame, sState, self.MAP_LOCK_DRAG);
}

// Obtener estado actual
function getBottomSheetState(sFrame) {
    let window = ui.getView(self);
    let sState = window.getBottomSheetState(sFrame);
    // sState: "expanded" / "collapsed" / "hidden"
    return sState;
}

// Callback al cambiar de estado (declarado en el atributo onbottomsheetstatechanged del frame)
function onBottomSheetStateChanged(evento) {
    // evento.target    -> nombre del frame
    // evento.state     -> nuevo estado: "expanded" / "collapsed" / "hidden"
    // evento.objItem   -> dataObject de la coll que contiene el frame
    let sEstado = evento.state;
    let dataObject = evento.objItem;
    dataObject.MAP_ESTADO = sEstado;
    ui.getView(dataObject).refreshValue("MAP_ESTADO");
}
```

Declaración XML del frame bottom-sheet:

```xml
<frame name="mi_bottom_sheet"
       width="80%" height="60%"
       floating="true" left="10%"
       behavior="bottom-sheet"
       initial-state="collapsed"
       on-click-outside-state="hidden"
       hideable="false"
       peek-height="400p"
       onbottomsheetstatechanged="onBottomSheetStateChanged(e);">
    <!-- Contenido del bottom sheet -->
</frame>
```

---

#### 2.1.16 Progress Bar (Control desde JS)

Los controles `viewmode="progress-bar"` y `viewmode="circular-progress-bar"` se controlan obteniendo el control desde la ventana.

```javascript
// Obtener el control de progreso
let window  = ui.getView(self);
let control = window["MAP_PROGRESS_BAR"];

// Modo indeterminado: animacion continua sin valor concreto
control.setIndeterminate(true);   // Activar indeterminado
control.setIndeterminate(false);  // Desactivar (muestra el valor actual)

// Alternar indeterminado
control.toggleIndeterminate();

// Consultar si esta en modo indeterminado
let bIndet = control.isIndeterminate();

// Cambiar el valor del progreso (igual que self.MAP_PROGRESS_BAR = N + ui.refresh)
self.MAP_PROGRESS_BAR++;
ui.refresh("MAP_PROGRESS_BAR");
// O usando setIndeterminate(false) primero si estaba indeterminado
window["MAP_PROGRESS_BAR"].setIndeterminate(false);
self.MAP_PROGRESS_BAR = 7;
ui.refresh("MAP_PROGRESS_BAR");
```

---

#### 2.1.17 Showcase (Tutorial interactivo)

`window.startShowcase()` lanza un tutorial paso a paso que resalta controles de la pantalla con circulos y textos explicativos.

```javascript
function doStartShowcase() {
    let window = ui.getView(self);
    window.startShowcase({
        // Si el usuario cancela un paso, continuar al siguiente en lugar de detener
        continueOnCancel: true,
        tapTargets: [{
            target              : "MAP_BOTON1",     // Nombre del prop a resaltar
            title               : "Paso 1",
            description         : "Descripción del paso 1",
            cancelable          : true,             // Permite saltarlo tocando fuera
            transparentTarget   : true,             // El target se ve a traves del circulo
            targetRadius        : 90,               // Tamaño del circulo pequeño
            outerCircleOpacity  : 96,               // Opacidad 0-100 del circulo grande
            outerCircleColor    : "#00FF00",        // Color del circulo grande
            targetCircleColor   : "#FF0000",        // Color del circulo pequeño bajo el target
            dimColor            : "#CC000000",      // Color del área oscura exterior
            titleTextSize       : 20,
            descriptionTextSize : 15,
            textColor           : "#FFFFFF",        // Color general del texto
            titleTextColor      : "#FFFF00",        // Color específico del título
            descriptionTextColor: "#FFFFFF",
            textFont            : "MiFuente.ttf",   // Fuente para título y descripción
            // titleFont        : "MiFuente.ttf",   // Fuente solo para título
            // descriptionFont  : "MiFuente.ttf",   // Fuente solo para descripción
            drawShadow          : true,             // Sombra en el circulo grande
            // tintTarget       : false,
        }, {
            target     : "MAP_BOTON2",
            title      : "Paso 2",
            description: "Descripción del paso 2",
            cancelable : true
        }, {
            target     : "MAP_BOTON3",
            title      : "Paso 3",
            description: "Descripción del paso 3",
            cancelable : true
        }]
    });
}
```

---

#### 2.1.18 Efectos Visuales: Blur y Saturacion

XOne no expone blur y saturacion como funciones del framework directamente — se implementan como funciones de proyecto que actuan sobre un frame llamando a métodos internos de la ventana. El patron típico es un slider cuyo `onchange` llama a la función de efecto.

```javascript
// Aplicar efecto blur a un frame (valor: 0 = sin blur, mayor = mas desenfoque)
function doBlurEffect(sFrame, nValue) {
    let window = ui.getView(self);
    if (!window) return;
    window[sFrame].setBlur(nValue);
}

// Aplicar efecto de saturacion a un frame (valor: 0 = escala de grises, mayor = mas saturacion)
function doSaturationEffect(sFrame, nValue) {
    let window = ui.getView(self);
    if (!window) return;
    window[sFrame].setSaturation(nValue);
}
```

Patron completo con sliders de control en la coll:

```xml
<!-- Slider de blur -->
<prop name="MAP_BLUR_SLIDER" type="N"
      updates="MAP_BLUR_SLIDER"
      min="0" max="32"
      viewmode="slider" orientation="horizontal"
      notify-only-when-dropped="false"
      width="800p" height="100p" />

<!-- Slider de saturacion -->
<prop name="MAP_SATURATION_SLIDER" type="N"
      updates="MAP_SATURATION_SLIDER"
      min="0" max="32"
      viewmode="slider" orientation="horizontal"
      notify-only-when-dropped="false"
      width="800p" height="100p" />
```

```xml
<!-- onchange en la coll: reaccionar al mover el slider -->
<onchange>
    <field name="MAP_BLUR_SLIDER">
        <action name="runscript">
            <script>
                doBlurEffect("mi_frame", self.MAP_BLUR_SLIDER);
            </script>
        </action>
    </field>
    <field name="MAP_SATURATION_SLIDER">
        <action name="runscript">
            <script>
                doSaturationEffect("mi_frame", self.MAP_SATURATION_SLIDER);
            </script>
        </action>
    </field>
</onchange>
```

#### 2.1.19 Catálogo completo de métodos de `ui`

El objeto global `ui` expone ~130 métodos agrupables en: UI, dispositivo, multimedia, GPS, impresion, calendario, notificaciones, drawer, firma, etc. Esta tabla es una referencia rápida; para métodos con parámetros complejos (`speak`, `recognizeSpeech`, `startAudioRecord`, `showDatePicker`, `addCalendarItem`, `playSoundAndVibrate`, `pickFile`, etc.) hay ejemplos detallados en las subsecciones anteriores (2.1.1-2.1.18).

| Método | Descripción |
| --- | --- |
| **addCalendarItem** | Añadir item al calendario. |
| **askUserForGPSPermission** | Solicitar al usuario permiso para GPS. |
| **canMakePhoneCall** | Comprueba si se puede hacer una llamada de teléfono. |
| **captureImage** | Capturar imagen de un control. |
| **checkGPSStatus** | Comprobar el status del GPS. |
| **clearDrawing** | Eliminar el dibujo/firma. |
| **createShortcut** | Crear acceso directo en el launcher. |
| **deleteShortcut** | Borrar acceso directo. |
| **dismissNotification** | Rechazar/ocultar una notificación. |
| **drawMapRoute** | Dibujar ruta en el mapa. |
| **endPrint** | Finalizar impresión. |
| **ensureVisible** | Asegurar que el control sea visible (scroll). |
| **executeActionAfterDelay** | Ejecutar acción tras un retraso en segundos. |
| **getLastKnownLocation** | Obtener la última localización conocida (lat,long). |
| **getLastKnownLocationAccuracy** | Precisión de la última localización. |
| **getLastKnownLocationAltitude** | Altitud de la última localización. |
| **getLastKnownLocationBearing** | Marcación/rumbo. |
| **getLastKnownLocationDateTime** | Fecha/hora de la última localización. |
| **getLastKnownLocationLatitude** | Latitud. |
| **getLastKnownLocationLongitude** | Longitud. |
| **getLastKnownLocationProvider** | Proveedor (gps, network, ...). |
| **getLastKnownLocationSpeed** | Velocidad. |
| **getMaxSoundVolumen** | Máximo volumen. |
| **getSoundVolumen** | Volumen actual. |
| **getView** | Obtener la vista actual (p.ej. `ui.getView(self)`). |
| **hideGroup** | Ocultar grupo. |
| **hideNavigationDrawer** | Ocultar cajón de navegación. |
| **hideSoftwareKeyboard** | Ocultar teclado del software. |
| **hideWaitDialog** | Ocultar diálogo de espera. |
| **injectJavascript** | Inyectar Javascript. |
| **isApplicationInstalled** | Comprobar si una app está instalada (por package). |
| **isOnCall** | ¿En llamada? |
| **isSuperuserAvailable** | ¿Hay super usuario? |
| **isTaskKillerInstalled** | ¿Hay task killer? |
| **isWifiConnected** | ¿Wifi conectada? |
| **isWifiEnabled** | ¿Wifi activada? |
| **launchApp** / **launchApplication** | Lanzar aplicación. |
| **lineFeed** | Salto de línea (impresión). |
| **lockGroup** / **unlockGroup** | Bloquear/desbloquear grupo. |
| **makePhoneCall** | Llamada telefónica. |
| **mergeImagesLeftToRight** | Fusionar imágenes horizontalmente. |
| **msgBox** / **msgBoxWithSound** | Caja de mensaje (con o sin sonido). |
| **openEditView** | Abrir vista edición. |
| **openFile** | Abrir fichero (delega al SO). |
| **openMenu** | **Legacy** — usar `openEditView` para abrir pantallas. Sólo útil para el caso especial de lanzar directamente la LISTA de una coll: `openMenu(collName, mask, 0)`. Ver §2.1.4. |
| **openUrl** | Abrir URL. |
| **pickFile** | Seleccionar archivo. Params: prop destino, extensiones, solo fotos, ruta inicial, restringir rutas superiores. |
| **playSoundAndVibrate** / **stopPlaySoundAndVibrate** | Reproducir sonido con vibración. |
| **playSoundVolumen** | Reproducir con volumen. |
| **print** / **printBarcode** / **printBIDI** / **printCommand** / **printImage** / **printLine** / **printPDF** | Familia de impresión. |
| **quitApp** / **restartApp** | Salir/reiniciar la app. |
| **recognizeSpeech** | Reconocimiento de voz (ver 2.1.9). |
| **refresh** | Refrescar props pasadas por parámetro. |
| **refreshContentRow** | Refrescar línea de content. |
| **refreshContentSelectedRow** | Refrescar content en fila seleccionada. |
| **refreshValue** | Refrescar valor de un campo. |
| **relayout** | Rediseñar la página. |
| **returnToForeground** | Volver al primer plano. |
| **returnToMainMenu** | Volver al menú principal. |
| **saveDrawing** | Guardar dibujo/firma. |
| **sendMail** | Enviar email. |
| **sendSMS** | Enviar SMS. |
| **setFeedMode** | Modo de alimentación (impresión). |
| **setLanguage** | Cambiar idioma. |
| **setMaxWaitDialog** | Máximo del progreso del wait dialog. |
| **setNotificationLed** | LED de notificación. |
| **setSelection** | Ajustar selección. |
| **shareData** / **sharedData** | Compartir datos / datos compartidos. |
| **showConsoleReplica** | Consola de réplica visible. |
| **showDatePicker** / **showTimePicker** | Selector de fecha/hora. |
| **showGroup** / **toggleGroup** | Mostrar/alternar grupo. |
| **showNavigationDrawer** | Mostrar cajón de navegación. |
| **showNotification** | Mostrar notificación. |
| **showSnackbar** | Snackbar. |
| **showSoftwareKeyboard** | Mostrar teclado. |
| **showToast** | Toast. |
| **showWaitDialog** / **updateWaitDialog** / **hideWaitDialog** | Diálogo de espera. |
| **signDataObject** | Firmar DataObject. |
| **sleep** | Pausa (no recomendado; usar executeActionAfterDelay). |
| **speak** | Síntesis de voz (ver 2.1.9). |
| **startAudioRecord** / **stopAudioRecord** | Grabación audio (ver 2.1.9). |
| **startCamera** / **takePhoto** | Cámara y foto. |
| **startGps** / **startGpsV1** / **startGpsV2** / **stopGps** / **stopGpsV1** / **stopGpsV2** | Control GPS. |
| **startKioskMode** / **stopKioskMode** | Modo kiosko. |
| **startPrint** / **endPrint** / **useLastPrinter** | Flujo de impresión. |
| **startReplica** / **stopReplica** | Réplica on/off. |
| **startSignature** | Iniciar firma. |
| **startWifi** / **stopWifi** | Wifi on/off. |
| **uninstallApplication** | Desinstalar app (pide permiso). |

---


**Anterior:** [a - self y colecciones](xone-javascript-patterns-a-self.md) · **Siguiente:** [c - appData y $http](xone-javascript-patterns-c-appdata-http.md) · **Índice:** [xone-javascript-patterns.md](xone-javascript-patterns.md)