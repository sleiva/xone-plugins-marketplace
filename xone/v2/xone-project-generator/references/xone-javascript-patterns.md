# Patrones y Buenas Prácticas de JavaScript para XOne — Índice

Esta referencia esta dividida en 6 sub-archivos por área temática. Carga **solo el sub-archivo que necesites** para generar código concreto — reduce el contexto a procesar de ~4,970 lineas a ~600-1,450 por sub-archivo.

## Notas críticas siempre relevantes

> **Motor JS embebido (no es navegador).** XOne NO ejecuta JavaScript en un browser ni en Node.js. APIs web como `document`, `window` (objeto global del DOM), `localStorage`, `XMLHttpRequest`, `navigator` **NO existen**. Las alternativas están documentadas en los sub-archivos. SÍ existen, con implementación custom: `Promise` (ES2024 completo, incluyendo `all`/`allSettled`/`race`/`any`/`withResolvers`), `fetch`, `setTimeout`/`setInterval`, `URL`, `Headers`, `AbortController`, `EventTarget`, `TextEncoder`/`TextDecoder`, `atob`/`btoa`, `console`, `performance.now()`. La sintaxis `class` ES6+ también está soportada (declaraciones, expresiones, `extends`/`super`/`static`/getters/setters/computed keys, field declarations `name = expr;` y `static name = expr;`, generator methods `*method()`).

> **Escape XML obligatorio cuando el JS va dentro de un `.xne`.** Dos formas válidas: (a) escapar los caracteres especiales con entidades XML (`&amp;`, `&lt;`, `&gt;`, `&quot;`, `&apos;`), o (b) envolver el bloque en `<![CDATA[...]]>` (solo en nodos `<script>`, no en atributos). Ver [a - Contexto JS](xone-javascript-patterns-a-self.md#19-javascript-dentro-de-xne-escape-xml-o-cdata).

> **Eventos `<load>`.** `<load>` NO se ejecuta al mostrar una pantalla. Se dispara **por cada DataObject** al cargarse desde la BD. Para inicializar una pantalla usar `<before-edit>` (o `<create>` la primera vez).

## Índice de sub-archivos

| Sub-archivo | Contenido | Cuando usar |
|-------------|-----------|-------------|
| **[a - Contexto, self y colecciones](xone-javascript-patterns-a-self.md)** | §1 Contexto JS (motor, objetos globales, limitaciones, eventos XML, ambitos, escape XML). §2.3 `self`. §2.4 Colecciones (DataCollection). §2.5 Contents embebidos. | Manipular el registro actual, recorrer/modificar colecciones, acceder a contents. |
| **[b - Objeto ui](xone-javascript-patterns-b-ui.md)** | §2.1 entero — Objeto `ui`: navegación, mensajes/dialogos, vista (refresh, getView), GPS, camara, voz (TTS/STT), audio, calendario, cronometros, Date/Time pickers, escaner QR, Stepper, OTP. | Cualquier interaccion con la UI o servicios del dispositivo desde JavaScript. |
| **[c - appData, $http, SqlManager, Crypto](xone-javascript-patterns-c-appdata-http.md)** | §2.2 `appData` (colecciones globales, autenticación, macros, SQL directo, push). §2.6 `$http` (GET/POST/PUT/PATCH/DELETE, Futures, SSL/TLS, WebSocket, JSON). §2.8 `SqlManager`. §2.9 API `crypto` (hashing, AES, RSA, firma). | Llamadas HTTP/API, BD, autenticación, criptografía. |
| **[d - createObject y singletons (dispositivo)](xone-javascript-patterns-d-createobject.md)** | §2.7 FileManager. §2.10 GPS y Mapas. §2.11 Biometrics Manager. §2.12 Objetos complementarios (XOnePDF, XOnePrinter, BarcodeGenerator, XOneNFC, XOneOCR, BluetoothSerialPort, WifiManager, Animation, WebSocket). | Funcionalidad especifica de dispositivo: PDFs, impresion BT, códigos, NFC, OCR, biometria, animaciones. |
| **[e - Patrones, seguridad, optimización y errores](xone-javascript-patterns-e-patrones.md)** | §3 Buenas prácticas. §4 Seguridad (validación, SQL injection, almacenamiento, TLS). §5 Optimización (memoria, UI, BD, HTTP). §6 Utilidades (`isEmpty`, `cstr`, `cnum`, `getControl`, ...). §7 Patrones comunes (login biometrico, CRUD, GPS, fotos, firma, API HTTP, offline-first, voz). §8 Patrones críticos (lock/unlock, browse, filtros, callbacks, WaitDialog, cronometros). §9 Errores comunes. | Antes de generar código de produccion. Plantillas reusables para casos completos (offline-first, voz, biometria). |
| **[f - Métodos de los controles de vista](xone-javascript-patterns-f-controles.md)** | API que cada control de pantalla expone a JavaScript, accedida por el nombre de su `<prop>` (`getControl("MAP_X")`): campos de texto/botón/checkbox/imagen, numéricos con viewmode (slider, stepper, otp, navbar), multimedia (webview, vídeo, cámara, dibujo, pdf, skeleton), listas/contents (recyclerview, slider, grid, expandible, chips, calendario), mapas, gráficas, AR. | Llamar métodos sobre un control concreto desde un script (añadir ítems a una lista, controlar la cámara/vídeo, dibujar en un mapa, etc.). |

## Referencia rápida — atajos

| Quiero implementar... | Sub-archivo + sección |
|----------------------|------------------------|
| Acceder a campo `self.X` | [a §2.3](xone-javascript-patterns-a-self.md#23-objeto-self) |
| Recorrer una coleccion | [a §2.4](xone-javascript-patterns-a-self.md#24-colecciones) y [e §8.2 browse](xone-javascript-patterns-e-patrones.md#82-patron-startbrowseendbrowse-tryfinally) |
| Escape XML del JS dentro de `.xne` | [a §1.9](xone-javascript-patterns-a-self.md#19-javascript-dentro-de-xne-escape-xml-o-cdata) |
| Abrir otra pantalla | [b §2.1 navegación](xone-javascript-patterns-b-ui.md#21-objeto-ui) |
| msgBox / showToast | [b §2.1 mensajes](xone-javascript-patterns-b-ui.md#21-objeto-ui) |
| `ui.startGps` | [b §2.1 GPS](xone-javascript-patterns-b-ui.md#21-objeto-ui) |
| Cronometro continuo | [e §8.6 startChronometer](xone-javascript-patterns-e-patrones.md#86-cronometros-y-temporizadores-startchronometer-vs-executeactionafterdelay) |
| Login / logout | [c §2.2 appData](xone-javascript-patterns-c-appdata-http.md#22-objeto-appdata) |
| Macros globales | [c §2.2 macros](xone-javascript-patterns-c-appdata-http.md#22-objeto-appdata) |
| HTTP GET/POST/PUT/DELETE | [c §2.6 $http](xone-javascript-patterns-c-appdata-http.md#26-api-http-http) |
| WebSocket | [c §2.6 WebSocket](xone-javascript-patterns-c-appdata-http.md#26-api-http-http) |
| OAuth2 | [d §2.12 OAuth2](xone-javascript-patterns-d-createobject.md#212-objetos-complementarios) |
| Generar PDF | [d §2.12 XOnePDF](xone-javascript-patterns-d-createobject.md#212-objetos-complementarios) |
| Imprimir Bluetooth | [d §2.12 XOnePrinter](xone-javascript-patterns-d-createobject.md#212-objetos-complementarios) |
| QR / Barcode | [d §2.12 BarcodeGenerator](xone-javascript-patterns-d-createobject.md#212-objetos-complementarios) |
| NFC / DNI | [d §2.12 XOneNFC](xone-javascript-patterns-d-createobject.md#212-objetos-complementarios) |
| Animaciones | [d §2.12 Animation](xone-javascript-patterns-d-createobject.md#212-objetos-complementarios) |
| Biometria | [d §2.11](xone-javascript-patterns-d-createobject.md#211-biometrics-manager) |
| Patron lock/unlock | [e §8.1](xone-javascript-patterns-e-patrones.md#81-patron-lockunlock-tryfinally) |
| Plantilla login con huella | [e §7.1](xone-javascript-patterns-e-patrones.md#71-login-con-biometria) |
| Plantilla CRUD | [e §7.2](xone-javascript-patterns-e-patrones.md#72-crud-completo) |
| Plantilla GPS tracking | [e §7.4](xone-javascript-patterns-e-patrones.md#74-rastreo-gps) |
| Plantilla offline-first | [e §7.8](xone-javascript-patterns-e-patrones.md#78-patron-offline-first-con-sincronizacion) |
| Plantilla voz bidireccional | [e §7.9](xone-javascript-patterns-e-patrones.md#79-patron-control-por-voz-tts--stt) |
| Prevenir SQL injection | [e §4.2](xone-javascript-patterns-e-patrones.md#42-prevencion-de-inyeccion-sql) |
| Funciones utilitarias para `functions.js` | [e §6](xone-javascript-patterns-e-patrones.md#6-funciones-utilitarias-estandar) |
| Errores comunes (top 12) | [e §9](xone-javascript-patterns-e-patrones.md#9-errores-comunes-a-evitar) |
| Métodos de un control desde JS (`getControl("MAP_X").metodo(...)`) | [f - Métodos de los controles](xone-javascript-patterns-f-controles.md) |
| Añadir/quitar ítems de una lista por código | [f §4 Listas y contenidos](xone-javascript-patterns-f-controles.md#4-listas-y-contenidos-typez) |
| Controlar cámara / vídeo / webview / dibujo desde JS | [f §3 Multimedia](xone-javascript-patterns-f-controles.md#3-multimedia-y-especiales) |
| Dibujar en un mapa desde JS | [f §5 Mapas](xone-javascript-patterns-f-controles.md#5-mapas-viewmodemapview-maplibre-openstreetmap) |

---

*Índice generado a partir del documento original. Cada sub-archivo es autocontenido y puede leerse sin necesidad de los demas.*
