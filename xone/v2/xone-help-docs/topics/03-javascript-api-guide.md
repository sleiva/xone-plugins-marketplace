# Guía Completa de JavaScript en XOne — Índice

Esta guía esta dividida en 5 sub-archivos por área temática. Carga **solo el sub-archivo que necesites** para responder a una pregunta concreta — reduce el contexto que el LLM debe procesar de ~5,200 lineas a ~700-1,600 por sub-archivo.

## Notas críticas siempre relevantes

> **Motor JS embebido (no es navegador).** XOne NO ejecuta JavaScript en un browser ni en Node.js. APIs web como `document`, `window` (objeto global del DOM), `localStorage`, `XMLHttpRequest`, `navigator` **NO existen**. Las alternativas están documentadas a lo largo de los sub-archivos. Sí existen, con implementación custom: `fetch`, `setTimeout`/`setInterval` (con sus `clear*`), `Promise` (full ES2024 incluyendo `all`/`allSettled`/`race`/`any`/`withResolvers`), `URL`, `Headers`, `AbortController`, `EventTarget`, `TextEncoder`/`TextDecoder`, `atob`/`btoa`, `console`, `performance.now()`. La sintaxis `class` ES6+ está soportada (`extends`/`super`/`static`/getters/setters/field declarations). **NO** a nivel de sintaxis: `async`/`await`, template literals `` `${x}` ``, spread/rest, default params, optional chaining `?.`.

> **Escape XML obligatorio cuando el JS va dentro de un `.xne`.** Dos formas válidas: (a) escapar los caracteres especiales con entidades XML (`&amp;`, `&lt;`, `&gt;`, `&quot;`, `&apos;`), o (b) envolver el bloque en `<![CDATA[...]]>` (solo en nodos `<script>`, no en atributos). Ver [03a §1.9](03a-js-self.md#19-javascript-dentro-de-xne-escape-xml-o-cdata).

> **Eventos `<load>`.** `<load>` NO se ejecuta al mostrar una pantalla. Se dispara **por cada DataObject** al cargarse desde la BD. Para inicializar una pantalla usar `<before-edit>` (o `<create>` la primera vez).

## Índice de sub-archivos

| Sub-archivo | Contenido | Cuando usar |
|-------------|-----------|-------------|
| **[03a - self / DataObject](03a-js-self.md)** | §1 Introduccion (motor JS, objetos globales, eventos, ambitos, escape XML). §2 Objeto `self` (acceso a campos, getOldValue, getOwnerCollection, getContents, setFieldPropertyValue, executeNode, save, JSON) y `selfDataColl` (browse, deleteItem, findAllObjects, setMacro, lock, bind). | Manipular el registro actual, sus campos, sus contents, eventos del objeto y la coleccion contenedora. |
| **[03b - Objeto `ui` (UI y dispositivo)](03b-js-ui.md)** | §3 entero — Objeto `ui`: navegación (`openEditView`, `getView`, `showGroup`), mensajes/dialogos (`msgBox`, `showToast`, `showSnackbar`, `showWaitDialog`, `showNotification`), vista (`refresh`, `refreshValue`, drawer, bottom sheet, showcase), date/time pickers, GPS (`startGps`, `GpsTools`), camara/archivos (`pickFile`, `openFile`, `FileManager`), firma, QR/barcode, voz (TTS/STT), audio, calendario, cronometros, Stepper, OTP. Catálogo completo de métodos. | Cualquier interaccion con la UI o servicios del dispositivo. Es el sub-archivo más voluminoso pero coherente. |
| **[03c - appData, $http, OAuth2, replica](03c-js-appdata-http.md)** | §4 `appData` (colecciones, autenticación, navegación entre pantallas con datos, macros globales, SQL directo, SqlManager, encriptación, deteccion de dispositivo, push). §5 `$http` (GET/POST/PUT/PATCH/DELETE, Futures, SSL/TLS, proxy, WebSocket, JSON). §6 OAuth2 (login/logout). §7 `replica` (sincronización, restricciones, sys-message). | Operaciones globales de aplicación, llamadas HTTP/API, autenticación OAuth2 y replica. |
| **[03d - createObject (objetos complementarios)](03d-js-createobject.md)** | §8 — Objetos creables con `new`/`createObject`: FileManager, XOnePDF, XOnePrinter, BarcodeGenerator, Datawedge, XOneNFC, XOneOCR, BluetoothSerialPort, WifiManager, Animation, GpsTools, WebSocket. Singletons: `deviceInfo`, `systemSettings` (extenso), `fingerprintManager`, `bluetoothSerial`. | Funcionalidad especifica de dispositivo: PDFs, impresion BT, códigos de barras, NFC, OCR, animaciones, configuración del sistema, biometria. |
| **[03e - Patrones, seguridad y best practices](03e-js-patrones-buenas-practicas.md)** | §9 Patrones críticos (lock/unlock, browse, filter/restore, callbacks asíncronos, WaitDialog, cursor SQL). §10 Seguridad (SQL injection, validación, encriptación, credenciales). §11 Optimización (refreshes, colecciones, bucles, contents, Promise). §12 Patrones comunes con ejemplos (CRUD, filtrado, m-d, GPS, fotos, chat, QR, descargas, sync, login). §13 Funciones utilitarias para `functions.js`. §14 Debugging y troubleshooting. §15 Best practices Top 20. | Antes de escribir código de produccion: como evitar bugs, leaks, problemas de rendimiento y seguridad. Plantillas reusables. |

## Referencia rápida — atajos

| Quiero... | Sub-archivo + sección |
|-----------|----------------------|
| Acceder a un campo del objeto actual | [03a §2.1](03a-js-self.md#21-acceso-a-campos) |
| Obtener un content embebido | [03a §2.4](03a-js-self.md#24-getcontentsnombre---acceso-a-contents) |
| Guardar el objeto en BD | [03a §2.7](03a-js-self.md#27-save---guardar-cambios) |
| Recorrer una coleccion (browse) | [03a §2.11](03a-js-self.md#21-acceso-a-campos) y [03e §9.2](03e-js-patrones-buenas-practicas.md#92-patron-startbrowseendbrowse-navegacion-de-colecciones) |
| Abrir otra pantalla | [03b §3.1](03b-js-ui.md#31-navegacion) |
| Mostrar un mensaje (toast / msgBox) | [03b §3.2](03b-js-ui.md#32-mensajes-y-dialogos) |
| Refrescar campos | [03b §3.3](03b-js-ui.md#33-vista---refrescar-y-acceder-a-controles) |
| Iniciar GPS | [03b §3.5](03b-js-ui.md#35-gps) |
| Tomar foto / escanear QR | [03b §3.5 y §3.7](03b-js-ui.md#35-camara-y-archivos) |
| Cronometro continuo | [03b §3.10 (startChronometer)](03b-js-ui.md#startchronometer--stopchronometer---cronometros-continuos) |
| Acceder a una coleccion global | [03c §4.1](03c-js-appdata-http.md#41-colecciones) |
| Login/logout | [03c §4.2](03c-js-appdata-http.md#42-autenticacion) |
| Macros globales (alternativa a localStorage) | [03c §4.4](03c-js-appdata-http.md#44-macros-globales) |
| Llamada HTTP GET/POST | [03c §5.2 / §5.3](03c-js-appdata-http.md#52-get) |
| WebSocket | [03c §5.11](03c-js-appdata-http.md#511-websocket) |
| OAuth2 login | [03c §6.1](03c-js-appdata-http.md#61-autenticacion-oauth2) |
| Generar PDF | [03d §8.2](03d-js-createobject.md#82-xonepdf---generacion-de-pdf) |
| Imprimir por Bluetooth | [03d §8.3](03d-js-createobject.md#83-xoneprinter---impresion-bluetooth) |
| Generar código QR / barcode | [03d §8.4](03d-js-createobject.md#84-barcodegenerator---generacion-de-codigos) |
| Animar un control | [03d §8.10](03d-js-createobject.md#810-animation---animaciones-programaticas) |
| Permisos en runtime | [03d §8.11b "Permisos"](03d-js-createobject.md#permisos-en-runtime) |
| Patron lock/unlock | [03e §9.1](03e-js-patrones-buenas-practicas.md#91-patron-lockunlock-modificacion-de-colecciones) |
| Prevenir SQL injection | [03e §10.1](03e-js-patrones-buenas-practicas.md#101-prevencion-de-sql-injection) |
| Encriptar datos sensibles | [03e §10.3](03e-js-patrones-buenas-practicas.md#103-encriptacion-de-datos-sensibles) |
| Plantilla CRUD completa | [03e §12.1](03e-js-patrones-buenas-practicas.md#121-crud-completo) |
| Plantilla login | [03e §12.10](03e-js-patrones-buenas-practicas.md#1210-login-personalizado) |
| Funciones helper para functions.js | [03e §13](03e-js-patrones-buenas-practicas.md#13-funciones-utilitarias-recomendadas) |
| Top 20 best practices | [03e §15](03e-js-patrones-buenas-practicas.md#15-best-practices---top-20) |

---

*Índice generado a partir del topic 03 original. Cada sub-archivo es autocontenido y puede leerse sin necesidad de los demas.*
