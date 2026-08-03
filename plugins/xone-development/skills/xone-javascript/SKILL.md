---
name: xone-javascript
description: Programación JavaScript en XOne. Usar al escribir o depurar scripts en eventos XML y functions.js, acceso a self/selfDataColl/ui/appData/err/user, métodos de los controles con getControl, objetos creables con new, singletons globales, callbacks asíncronos, patrones lock/unlock y startBrowse/endBrowse, o el objeto ai de IA local.
---

# XOne JavaScript

JavaScript ejecutado en bloques `<script>` de los `.xne` y en `functions.js`. No es JavaScript de navegador ni de Node: no hay módulos (`require`/`import`) y el código compartido es global.

**No inventes métodos.** Si una API no está en las referencias, dilo y pide el dato. Los LLMs inventan sistemáticamente `self.lock()`, `ui.startChronometer()` y variantes de `setCircularReveal` que no existen.

## Objetos globales

`self` (DataObject actual, alias `dataobject`) · `selfDataColl` (su colección, alias `datacollection`) · `ui` · `appData` (alias `appdata`) · `err` (alias `error`) · `user`.

Singletons de acceso directo, **sin `new`**: `$http`, `crypto`, `clipboard`, `deviceInfo`, `systemSettings`, `packageManager`, `biometricsManager`, `fingerprintManager`, `bleManager`, `sensorManager`, `paymentManager`, `pushMessage`, `appBroadcastManager`, `replica`, `live`, `smsService`, `serial`, `bluetoothSerial`, `bleSerial`, `ml`, `ai`.

Objetos que se crean con `new` (o `createObject`): `FileManager`, `GpsTools`, `SqlManager`, `IniParser`, `EncodingUtils`, `AndroidIntent`, `DeviceManager`, `WifiManager`, `BluetoothSerialPort`, `OAuth2`, `Worker`, `Animation`, `Socket`, `WebSocket`, `DebugTools`, `IrManager`, `SoundManager`, `VibrationManager`, `WearableConnection`, `AccountManager`, `XOneNFC`, `ImageDrawing`, `BarcodeGenerator`, `XOnePrinter`, `XOnePDF`, `XOneOCR`, `XOneSigner` y los demás de la lista canónica.

## Acceso a datos

```javascript
var n = self.getValue("MAP_NOMBRE");
self.MAP_NOMBRE = "texto";
ui.refreshValue("MAP_NOMBRE");
```

`self.CAMPO`, `self["CAMPO"]` y `self.getValue("CAMPO")` son válidos. **`self("CAMPO")` no existe**: la notación de `self` como función no es parte del motor.

Los nombres de props, eventos, contents y colecciones son case-sensitive en todas las referencias.

## Controles

`getControl(name, [dataObject])` es una **función nativa global** del motor (Rhino y V8), no un método de `ui`. Con un solo argumento usa la última ventana visible; con `dataObject`, la ventana asociada a ese objeto. Lanza error si el nombre está vacío, si el control no existe en la ventana destino, si no hay ventana o si el `dataObject` no es válido. Si el proyecto define su propia `function getControl(...)`, esa sombrea a la nativa en su ámbito local.

Los métodos específicos (`getValue`/`setValue`/`setMin`/`setMax`/`setStepSize` de un stepper, `getOtpValue`/`clearOtp`/`focusOtp` de un OTP, `startChronometer`/`stopChronometer`) son métodos **del control**, no de `ui`.

## Patrones críticos

Modifica colecciones dentro de `unlock()` y devuelve el estado con `lock()` en `finally`. `lock()` activa el modo solo lectura: con la bandera activa, `clear()` y `loadAll()` son no-op. Las colecciones nacen desbloqueadas, pero el convenio es dejarlas bloqueadas tras operar para que código posterior no las mute por accidente.

```javascript
var original = coll.getFilter();
try {
    coll.unlock();
    coll.setFilter("ACTIVO = 1");
    coll.loadAll();
    // procesar
} finally {
    coll.setFilter(original);
    coll.lock();
}
```

`lock()`/`unlock()` son métodos de la **colección**, nunca de `self`. Para bloquear la de un contents: `self.getContents("X").unlock()`.

Navega con `startBrowse()` y `endBrowse()` en `finally`. Para contents: `getContents(nombre)` → `unlock` → `createObject`/`addItem` → `lock` → `saveAll`. Cierra siempre cursores y conexiones SQL. Un `WaitDialog` abierto va dentro de `try/finally`.

En callbacks asíncronos (`$http`, WebSocket, GPS) guarda el contexto **antes** de la llamada:

```javascript
var miSelf = self;
$http.get(url, null, function (res) { miSelf.MAP_RESULTADO = res; }, function (e) { ... });
```

Para crear objetos, el patrón preferido es `new NombreColeccion({ PROP: valor })` (el parámetro es opcional). `coll.createObject()` queda para contents anidados —vincula al padre— o cuando el nombre de la colección es dinámico.

## Anti-patrones: creación de objetos

| Incorrecto | Correcto |
|---|---|
| `appData.createObject("XOneFileManager")` | `new FileManager()` |
| `appData.createObject("Http")` | Singleton `$http` |
| `appData.createObject("Crypto")` / `new Crypto()` | Singleton `crypto` |
| `appData.createObject("DeviceInfo")` / `new DeviceInfo()` | Singleton `deviceInfo` |
| `appData.createObject("SystemSettings")` / `new SystemSettings()` | Singleton `systemSettings` |
| `appData.createObject("XOneClipboard")` | Singleton `clipboard` |
| `appData.createObject("XOneBiometricsManager")` | Singleton `biometricsManager` |
| `appData.createObject("ScriptSensorManager")` | Singleton `sensorManager` |
| `appData.createObject("XOnePackageManager")` | Singleton `packageManager` |
| `appData.createObject("XOneWifiManager")` | `new WifiManager()` |
| `appData.createObject("ScriptOauth2")` | `new OAuth2()` |
| `appData.createObject("WebWorker")` | `new Worker()` |
| `appData.createObject("XOneSocket")` / `XOneWebSocket` / `XOneDebugTools` | `new Socket()` / `new WebSocket()` / `new DebugTools()` |
| `appData.createObject("Encoder")` | `new EncodingUtils()` — «Encoder» no existe |
| `new Packages.com.xone.android.script.runtimeobjects.IniParser()` | `new IniParser()` |

## Anti-patrones: APIs y patrones

| Incorrecto | Correcto |
|---|---|
| `self("CAMPO")` | `self.CAMPO`, `self["CAMPO"]` o `self.getValue("CAMPO")` |
| `self.lock()` / `self.unlock()` | Son de la colección: `self.getContents("X").unlock()` |
| `coll.macro("##N##", v)` | `coll.setMacro("##N##", v)` / `getMacro` |
| `setMacro` sin declarar la macro en el XML | Declarar `<macro name="##N##" value="..." default="true" />` en la coll |
| `deviceInfo.getMobileNetworkSignalStrengh()` | `getMobileNetworkSignalStrength()` (sin el typo) |
| `ui.executeActionAfterDelay("X", 2000)` creyendo que son ms | El segundo parámetro va en **segundos**: `("X", 2)` |
| Encadenar `executeActionAfterDelay` como `setInterval` | `control.startChronometer({fromDate, dateFormat})` |
| `ui.startChronometer({...})` | Es del control: `getControl("MAP_T").startChronometer({...})` |
| `ui.setFieldPropertyValue(...)` / `ui.getFieldPropertyValue(...)` | Son de `self`. Y el cambio no repinta solo: llama a `ui.refresh(prop)` después |
| `self.X` dentro de un callback asíncrono | Guardar `var miSelf = self;` antes |
| `startBrowse()` sin `endBrowse()` en `finally` | `try { … } finally { coll.endBrowse(); }` |
| `appData.executeSql("… WHERE ID=" + id)` | `sqlManager.doRawQuery("… WHERE ID=?", id)` |
| `setBlur(...)` / `setSaturation(...)` como API del framework | Son funciones que implementa el proyecto, no están en `ui` |
| `GpsCollection` como colección built-in | La declara el proyecto con connector GPS |
| Variantes de `setCircularReveal` (Show/Hide, setXY, growAndShrink) | Solo existe `setCircularReveal(cx, cy, bReveal)` |

## APIs web y sus equivalentes

| API web | Equivalente XOne |
|---|---|
| `document.getElementById("X")` | `ui.getView(self)["X"]` o `getControl("X")` |
| `window.location` / `window.history` | `ui.openEditView("Coll")`, `ui.getView(self).exit()` |
| `localStorage` | `appData.getGlobalMacro("##X##")` / `setGlobalMacro` |
| `sessionStorage` | `coll.setVariable`/`getVariable` o variables de empresa |
| `new XMLHttpRequest()` | `$http.get(url, request, success, error)` |
| `alert` / `confirm` / `prompt` | `ui.msgBox(msg, título, 0)` o `ui.showToast(msg)` |
| `navigator.geolocation.getCurrentPosition` | `ui.startGps({nodeName: "callbackgps"})` |
| `require()` / `import` | `<include file="..."/>` o `<script src="..."/>` en `<app>`; dinámico solo con `appData.loadIncludeFile(...)` |

`fetch`, `setTimeout`, `setInterval`, `console` completo, `URL`, `Headers`, `AbortController`, `Promise` (ES2024) y otros **sí existen** con implementación custom de XOne, con limitaciones. Lo idiomático sigue siendo `$http` y `ui.executeActionAfterDelay`. El detalle de qué sintaxis admite el motor está en la skill `xone-development`.

## Referencias

| Para… | Lee |
|---|---|
| Motor JS, cómo se ejecuta desde eventos XML, diferencias con JS web, ámbitos y persistencia de variables, escape XML/CDATA en `.xne` | [references/motor-js-y-contexto-de-ejecucion.md](references/motor-js-y-contexto-de-ejecucion.md) |
| `self`: campos, `getOldValue`, `getOwnerCollection`, `getContents`, `setFieldPropertyValue`, `executeNode`, `save`, JSON y métodos de `DataCollection` | [references/self-y-dataobject.md](references/self-y-dataobject.md) |
| `ui`: navegación, `msgBox`/`showToast`/`showSnackbar`, refresco y acceso a controles, showcase, date/time pickers | [references/ui-navegacion-mensajes-y-vista.md](references/ui-navegacion-mensajes-y-vista.md) |
| `ui`: GPS completo, cámara, archivos, firma, escáner QR, sleep y timers | [references/ui-gps-camara-y-multimedia.md](references/ui-gps-camara-y-multimedia.md) |
| `ui`: `executeActionAfterDelay`, cronómetros, API de Stepper y OTP, voz (TTS/STT), audio y catálogo completo de métodos | [references/ui-catalogo-de-metodos.md](references/ui-catalogo-de-metodos.md) |
| API completa de la colección actual (browse, filtros, búsqueda full-text, macros, metadatos, SQL, JSON), objeto de error y usuario logueado | [references/coleccion-error-y-usuario.md](references/coleccion-error-y-usuario.md) |
| Creables de FileManager a Animation (SqlManager, IniParser, AndroidIntent, Bluetooth, OAuth2, Worker) | [references/objetos-creables-a-m.md](references/objetos-creables-a-m.md) |
| Creables de Socket a XOneSigner (NFC, ImageDrawing, BarcodeGenerator, XOnePrinter, XOnePDF, OCR) y la lista canónica completa | [references/objetos-creables-n-z.md](references/objetos-creables-n-z.md) |
| API de cada singleton global | [references/singletons-globales.md](references/singletons-globales.md) |
| Patrones críticos (lock/unlock, browse, filter/restore, contexto en callbacks), seguridad y rendimiento | [references/patrones-criticos-seguridad-y-rendimiento.md](references/patrones-criticos-seguridad-y-rendimiento.md) |
| Plantillas completas: CRUD, filtrado, maestro-detalle, GPS, fotos, chat, QR, login; y utilidades para `functions.js` | [references/plantillas-y-funciones-utilitarias.md](references/plantillas-y-funciones-utilitarias.md) |
| Debugging de JavaScript y top 20 de buenas prácticas | [references/debugging-y-best-practices.md](references/debugging-y-best-practices.md) |
| Métodos que expone cada control por tipo: campos, numéricos, multimedia, listas, mapas, gráficas, AR, frames | [references/metodos-de-los-controles.md](references/metodos-de-los-controles.md) |
| Patrones de navegación, de datos y patrones críticos de código | [references/patrones-de-navegacion-datos-y-codigo.md](references/patrones-de-navegacion-datos-y-codigo.md) |
| Patrones de UI, control por voz, integración y seguridad | [references/patrones-de-ui-voz-integracion-y-seguridad.md](references/patrones-de-ui-voz-integracion-y-seguridad.md) |
| Objeto `ai`: LLM en el dispositivo, descarga de modelos, `generate`, `chat` con streaming, function calling, skills y formatos | [references/objeto-ai-llm-en-dispositivo.md](references/objeto-ai-llm-en-dispositivo.md) |

El **catálogo de eventos** (cuándo dispara cada uno, con qué parámetros) vive en la skill `xone-xml-ui`, porque los eventos se declaran en el XML:

- `xone-xml-ui/references/eventos-ciclo-de-vida-e-interaccion.md` — `create`, `before-edit`, `after-edit`, `load`, `onclick`, `onchange`, `selecteditem`, `onlongpressitem`, `onback`.
- `xone-xml-ui/references/eventos-sistema-login-y-personalizados.md` — drawer, bottom sheet, login, `onpushreceived`, `maintenance`, `sys-message` y sus códigos, ciclo de aplicación, `ExecuteNode` y acciones.

Para `appData`, `$http`, OAuth2 y réplica en detalle, usa `xone-data-integration`. Para hardware y permisos, `xone-device`. Para los fundamentos del motor y las reglas transversales, `xone-development`.
