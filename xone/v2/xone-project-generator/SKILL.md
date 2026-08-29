---
name: xone-project-generator
description: Create complete XOne mobile app projects from descriptions. Generates XML screens, JavaScript logic, CSS styles, data models, and project structure for the XOne platform.
version: 52_12082026
---

# XOne Project Generator & Development Assistant

Eres un experto en la plataforma XOne para desarrollo de aplicaciones móviles nativas (Android e iOS). Tu conocimiento se basa EXCLUSIVAMENTE en los archivos de recursos incluidos en este skill.

---

## Capacidades

### 1. Generación de Proyectos
Creas proyectos XOne completos a partir de descripciones en lenguaje natural:
- Estructura de carpetas completa (`bd/`, `icons/`, `files/`, `fonts/`)
- Archivos de configuración (`app.xml`, `app.ini`, `mappings.xne`)
- Modelo de datos con colecciones y relaciones
- Pantallas con layout, navegación y eventos
- Estilos CSS propietarios de XOne
- Funciones JavaScript globales y especificas
- Documentación README en cada carpeta

### 2. Asistencia en Desarrollo
Respondes preguntas, depuras problemas y guías el desarrollo en XOne:
- Estructura y atributos de archivos XML (.xne)
- API JavaScript de XOne (`ui`, `self`, `appData`, `$http`, `deviceInfo`, `systemSettings`)
- Sistema de estilos CSS propietario de XOne
- Patrones de navegación y flujo de pantallas
- Integraciones con hardware (camara, GPS, firma digital DR, escaner)
- Modelo de datos y persistencia en SQLite

---

## Archivos de Referencia

Consulta SIEMPRE estos archivos antes de responder. Están incluidos en la carpeta `references/` de este skill:

| Archivo | Contenido |
|---------|-----------|
| **[references/xone-xml-ui-reference.md](references/xone-xml-ui-reference.md)** (índice) + 5 sub-archivos | Referencia completa de interfaz XML (.xne): nodos, atributos, tipos, eventos. Sub-archivos: a (estructura coll/frame/group), b (prop/tipos), c (contents/eventos/macros), d (patrones/mappings), e (mapas/errores) |
| **[references/xone-javascript-patterns.md](references/xone-javascript-patterns.md)** (índice) + 6 sub-archivos | Patrones JavaScript XOne: API completa, seguridad, optimización. Sub-archivos: a (contexto/self/colecciones), b (ui), c (appData/$http/SqlManager/Crypto), d (createObject/dispositivo), e (patrones/seguridad/optimización/errores), f (métodos de los controles de vista accedidos por el nombre de la `<prop>`) |
| [references/xone-javascript-runtime-objects.md](references/xone-javascript-runtime-objects.md) | Objetos globales (selfDataColl, err, user) y todos los objetos createObject() de XOne |
| [references/xone-javascript-ai.md](references/xone-javascript-ai.md) | Objeto `ai`: IA generativa local (LLM on-device). Descarga de modelos `.litertlm` (Gemma), carga, `generate`/`chat`, herramientas, skills, imagen/audio, MTP |
| [references/xone-xml-attributes-reference.md](references/xone-xml-attributes-reference.md) | Referencia completa de atributos XML por nodo. **Tipos validos**: T, TN/TN2..TN6, N/N2..N6, D, DT, TT, B, L, TL (alias legacy), THTML, WEB, IMG, PH, VD, DR, NC, X, Z, AT, O |
| [references/xone-css-styling-guide.md](references/xone-css-styling-guide.md) | Guía de estilos CSS propietarios de XOne |
| [references/xone-canonical-sizes.md](references/xone-canonical-sizes.md) | Tabla de tamaños canónicos (`width`/`height`/`fontsize`) por tipo de elemento: frames, botones, inputs, listas, avatares, iconos. **Consultar antes de poner cualquier `width`/`height`** |
| [references/xone-project-generation-workflow.md](references/xone-project-generation-workflow.md) | Flujo completo para generar proyectos XOne |

---

## Índice Contextual: Necesito implementar X → Donde mirar

Tabla de **acceso directo** para que el LLM cargue solo la sección necesaria al generar código. Cuando la descripción del usuario menciona una funcionalidad concreta, ir directo al archivo y sección indicados en `references/`.

### Estructura de proyecto y configuración base

| Funcionalidad solicitada | Archivo + sección |
|--------------------------|--------------------|
| Carpetas obligatorias (bd, icons, files, fonts) | [references/xone-project-generation-workflow.md "Estructura"](references/xone-project-generation-workflow.md) |
| `app.xml` configuración global | [references/xone-project-generation-workflow.md "Fase 5"](references/xone-project-generation-workflow.md) |
| `app.ini` metadatos | [references/xone-project-generation-workflow.md "Fase 5"](references/xone-project-generation-workflow.md) |
| `mappings.xne` (Empresas + Usuarios) | [references/xone-xml-ui-reference.md "mappings.xne"](references/xone-xml-ui-reference.md) y plantilla en este SKILL.md |
| Campos obligatorios de Empresas/Usuarios | Tabla `Campos Mínimos Obligatorios` más abajo |
| `default.css` estilos globales | [references/xone-css-styling-guide.md](references/xone-css-styling-guide.md) |
| `functions.js` punto de entrada | [references/xone-javascript-patterns.md](references/xone-javascript-patterns.md) |
| Pantalla de entrada (`EntradaApp.xne`) — pantalla **post-login** de bienvenida, NO es el splash | [references/xone-project-generation-workflow.md "Fase 7"](references/xone-project-generation-workflow.md) |
| Splash de carga inicial (logo mientras arranca la app) — NO es una `<coll>`, es un fichero `splash.png` (o `.jpg`/`.gif`/`.webp`/`.apng`/`.mp4`/`.3gp`) en la **raíz del proyecto** | [references/xone-project-generation-workflow.md "Fase 5 / 5.5"](references/xone-project-generation-workflow.md) |

### Pantallas y modelo de datos

| Funcionalidad solicitada | Archivo + sección |
|--------------------------|--------------------|
| Coleccion de datos con `objname`/`sql` | [references/xone-xml-ui-a-estructura.md §2](references/xone-xml-ui-a-estructura.md#2-nodo-coll---referencia-completa) |
| Pantalla `special="true"` (sin datos) | [references/xone-xml-ui-reference.md](references/xone-xml-ui-reference.md) |
| Tabla completa de tipos prop validos | [references/xone-xml-attributes-reference.md §10](references/xone-xml-attributes-reference.md#10-tipos-de-propiedad-atributo-type) (T, TN, TN2-TN6, N, N2-N6, D, DT, TT, B, L, TL (alias legacy), X, IMG, PH, VD, DR, NC, Z, WEB, AT, THTML, O) |
| Bitmask `visible` (0/1/2/4/7) | [references/xone-xml-attributes-reference.md §4 (visible)](references/xone-xml-attributes-reference.md#4-nodo-prop--propiedadcampo) |
| Combos/selectores (`mapcol`/`mapfld`/`linkedto`) | [references/xone-xml-ui-reference.md "Combo"](references/xone-xml-ui-reference.md) |
| Lista embebida (`contents` + `type="Z"`) | [references/xone-xml-ui-reference.md "contents"](references/xone-xml-ui-reference.md) |
| Mapa | `type="Z" viewmode="mapview"` — ver [references/xone-xml-ui-reference.md](references/xone-xml-ui-reference.md) |
| Kanban / CoverFlow / Slider / Stepper / OTP / Markdown | [references/xone-xml-attributes-reference.md (viewmodes)](references/xone-xml-attributes-reference.md) |
| Firma / dibujo | `type="DR"` |
| Maestro-detalle | [references/xone-project-generation-workflow.md](references/xone-project-generation-workflow.md) |
| Filtros de busqueda (`<asfilter>`) | [references/xone-xml-ui-reference.md "asfilter"](references/xone-xml-ui-reference.md) |
| Herencia entre colls (`inherits`) | Sección "Herencia" más abajo en este SKILL.md |
| Fragmentos XML (`<include-layout>`) | Sección "Herencia" más abajo en este SKILL.md |

### Funcionalidad de la app — que incluir según la descripción del usuario

Cuando el usuario describe una app, mapear sus necesidades a las integraciones / plantillas correspondientes:

| El usuario quiere... | Que incluir |
|---------------------|--------------|
| **GPS / tracking de ubicación** | `<permission name="location-foreground"/>` o `location-background` dentro de `<permissions>`; `ui.startGps({nodeName: "callbackgps"})`; colección `GpsCollection` con connector GPS; `GpsTools` para distancias. Ver [references/xone-javascript-patterns.md GPS](references/xone-javascript-patterns.md) |
| **Cámara / fotos** | `<permission name="camera"/>` dentro de `<permissions>`; `<prop type="PH">` o `<prop type="VD">`; opcional `control.takePicture()` / `control.record()` |
| **Escáner QR / barras** | `<permission name="camera"/>` dentro de `<permissions>`; `<prop type="VD" code-type="qr">` con `oncodescanned` o `control.setOnCodeScanned(...)` |
| **Scanner industrial (Zebra/Symbol DataWedge)** | Configurar perfil DataWedge enviando un broadcast intent (`new AndroidIntent()` + `new Bundle()` + `intent.sendBroadcast()`), o bien manualmente desde la app DataWedge del dispositivo. Ver ejemplo `addDataWedgeProfile()` (nombre de función del usuario, no API del framework) en [references/xone-javascript-patterns-d-createobject.md §2.12.4](references/xone-javascript-patterns-d-createobject.md#2124-datawedge-scanner-hardware-symbolzebra) |
| **NFC / DNI electrónico** | `<permission name="nfc"/>` dentro de `<permissions>`; `new XOneNFC()` |
| **Animación (loader, check animado, ilustración en movimiento)** | `<prop type="IMG">` apuntando a un `.json`, `.lottie` o `.tgs`; arranca sola en bucle infinito. `repeat-mode="reverse"` para ida y vuelta; desde JS, `playAnimation` / `stopAnimation` / `setAnimationFrame`. Las fuentes que use la animación van en `fonts/`. Ver [references/xone-xml-ui-b-prop-tipos.md](references/xone-xml-ui-b-prop-tipos.md) |
| **Firma digital** | `<prop type="DR">` (NO `type="IMG" readonly="false"` que es obsoleto) |
| **Generación de PDF** | `new XOnePDF()` |
| **Impresión Bluetooth (Zebra/etc.)** | `<permission name="bluetooth"/>` dentro de `<permissions>`; `new XOnePrinter().setDriver("zebra")` |
| **Generación de códigos QR/barcode** | `new BarcodeGenerator().setType("qrcode")` |
| **Biometria (huella / FaceID)** | Singleton `biometricsManager.launch()` |
| **Login OAuth2 (Google/Microsoft/SSO)** | `new OAuth2().withOptions({...}).authenticate(...)` |
| **API REST con servidor** | `$http.get/post/...`; ver [references/xone-javascript-patterns.md HTTP](references/xone-javascript-patterns.md) |
| **WebSocket / tiempo real** | `new WebSocket({url, onMessage, ...})` |
| **Push notifications** | `appData.registerPush({onSuccess, onFailure, onPushReceived})` (los tres nombres exactos que lee el motor; NO `onRegistered`); también admite `(successFn)` o `(successFn, failureFn)` posicional. Nodo `<onpushreceived>` en coll Empresas |
| **Chat / mensajeria** | Plantilla chat en topics/02c §8.8 del help-docs |
| **Multi-idioma** | Carpeta `lang/` con subcarpetas `es/`, `en/`, etc.; atributo `default-language` en `app.xml` |
| **Replica con servidor central** | Configurar conexión en `app.xml`; `replica.start()` / `replica.processReplicatorQueue()` |
| **Modo kiosko / MDM** | `systemSettings.isRunningInMdm()`; `ui.startKioskMode()` |
| **Cronometro / contador continuo en pantalla** | `control.startChronometer({fromDate, dateFormat})` — NO encadenar `executeActionAfterDelay` |
| **Voz: texto a voz / reconocimiento** | `ui.speak({...})` + `ui.recognizeSpeech({...})` |
| **Grabacion de audio** | `ui.startAudioRecord({onComplete, outputFormat: "mp4"})` |
| **Calendario / agenda de eventos** | `<prop type="Z" viewmode="calendarview">` + `ui.addCalendarItem(...)` |
| **Contactos del teléfono (leer/escribir)** | `<connection name="ContactsConnection" connstring="Provider=Xone Remote Provider;ProgID=com.xone.db.impl.contacts.ContactsConnection"/>` + `<permission name="contacts"/>` + coll sobre la tabla `Contacts` (campos `id,name,email,phone,photo,photo_thumbnail`). Detalle en [references/xone-project-generation-workflow.md §"Leer y escribir los contactos del teléfono"](references/xone-project-generation-workflow.md) |
| **Modal / dialogo personalizado** | `ui.msgBox(dataObject)` sincrono o asíncrono con campos `type="O"` |
| **Bottom Sheet (panel inferior)** | `<frame floating="true" behavior="bottom-sheet">` + `setBottomSheetState(...)` |
| **Drawer (menu lateral)** | `<group drawer-orientation="left" id="999">` + `ui.showGroup(999)` |
| **Splash de carga inicial (logo al arrancar)** | Colocar fichero `splash.png` (o `.jpg`/`.gif`/`.webp`/`.apng`/`.mp4`/`.3gp`) en la **raíz del proyecto**. El framework lo carga automáticamente desde `LoadAppActivity`. **NO** es una `<coll>`, NO se mete en `EntradaApp`, NO se configura con `load-imgbk` (ese atributo es la imagen de fondo del EditView, no el splash) |

### Patrones JavaScript imprescindibles

| Necesito implementar... | Donde mirar |
|------------------------|--------------|
| Modificar coll/contents (con `lock`/`unlock`) | [references/xone-javascript-patterns.md "lock/unlock"](references/xone-javascript-patterns.md) |
| Recorrer una coleccion (`startBrowse`/`endBrowse`) | [references/xone-javascript-patterns.md "browse"](references/xone-javascript-patterns.md) |
| Pasar datos entre pantallas (`ui.openEditView(obj)`) | [references/xone-javascript-patterns.md "openEditView"](references/xone-javascript-patterns.md) |
| Macros globales (alternativa a `localStorage`) | `appData.setGlobalMacro("##KEY##", valor)` |
| Macros de coll (parámetros SQL dinámicos) | `<macro name="##X##" value="..." default="true" />` + `coll.setMacro(...)` |
| SQL injection prevention | Usar `SqlManager.doRawQuery("... ?", valor)` con parámetros |
| Callbacks asíncronos / preservar `self` | `let miSelf = self;` antes de cualquier callback |
| Plantilla CRUD completa | [references/xone-javascript-patterns.md "CRUD"](references/xone-javascript-patterns.md) |
| `functions.js` boilerplate | [references/xone-javascript-patterns.md "Funciones utilitarias"](references/xone-javascript-patterns.md) |
| Métodos de un control desde JS (`getControl("MAP_X").metodo(...)`) | [references/xone-javascript-patterns-f-controles.md](references/xone-javascript-patterns-f-controles.md) |

### Estilos CSS

| Necesito... | Donde mirar |
|------------|--------------|
| Estilos visuales base de la app | [references/xone-css-styling-guide.md](references/xone-css-styling-guide.md) |
| Selectores CSS (`coll`, `prop:TYPE`, `.clase`, `group`, `frame`) | [references/xone-css-styling-guide.md](references/xone-css-styling-guide.md) |
| Animaciones (`##RIGHT_IN##`, `##ALPHA_IN##`, etc.) | [references/xone-css-styling-guide.md](references/xone-css-styling-guide.md) |
| Charts/gráficos (chart-*) | [references/xone-css-styling-guide.md](references/xone-css-styling-guide.md) |
| Calendario (`calendar-viewmode`, weekdays-forecolor) | [references/xone-css-styling-guide.md](references/xone-css-styling-guide.md) |

### Tamaños (`width`, `height`, `fontsize`, `fieldsize`)

| Necesito decidir... | Donde mirar |
|---------------------|--------------|
| `width` / `height` de un `<frame>` (header, body, footer, drawer, bottom-sheet, card) | [references/xone-canonical-sizes.md §2](references/xone-canonical-sizes.md#2-frames-estructurales) |
| Tamaño de un botón (CTA, FAB, chip, icon button, tab) | [references/xone-canonical-sizes.md §3](references/xone-canonical-sizes.md#3-botones) |
| Tamaño de un input (texto, número, fecha, combo, OTP, slider, firma) | [references/xone-canonical-sizes.md §4](references/xone-canonical-sizes.md#4-inputs-y-campos-de-formulario) |
| Altura de items de `<contents>` (1 línea, 2 líneas, con avatar, grid) | [references/xone-canonical-sizes.md §5](references/xone-canonical-sizes.md#5-listas-e-items-dentro-de-contents) |
| Tamaño de avatares, iconos, fotos preview, miniaturas | [references/xone-canonical-sizes.md §6](references/xone-canonical-sizes.md#6-imagenes-avatares-e-iconos) |
| Tamaño de separadores, badges, divisores y elementos auxiliares | [references/xone-canonical-sizes.md §7](references/xone-canonical-sizes.md#7-separadores-badges-y-elementos-auxiliares) |
| `fontsize` por rol tipográfico (display, headline, title, body, caption) | [references/xone-canonical-sizes.md §8](references/xone-canonical-sizes.md#8-tipografia-fontsize--escala-xone-1-12) |
| Tamaños de mapas, calendarios, charts, webviews, kanban | [references/xone-canonical-sizes.md §9](references/xone-canonical-sizes.md#9-areas-especiales) |
| Márgenes y padding (`tmargin`, `bmargin`, `lmargin`, `rmargin`) | [references/xone-canonical-sizes.md §10](references/xone-canonical-sizes.md#10-margenes-y-padding-tmargin-bmargin-lmargin-rmargin) |
| Wearable (smartwatch) — proporciones reducidas | [references/xone-canonical-sizes.md §11](references/xone-canonical-sizes.md#11-wearable-wear-os) |
| Anti-patrones de tamaños (qué NO hacer) | [references/xone-canonical-sizes.md §12](references/xone-canonical-sizes.md#12-anti-patrones-de-tamanos) |
| Default seguro cuando no sé qué poner | [references/xone-canonical-sizes.md §13](references/xone-canonical-sizes.md#13-tabla-de-fallback-rapido-cuando-no-sabes-que-poner) |

### Objetos creables y singletons (catálogo completo)

| Que objeto necesito? | Donde esta el catálogo |
|---------------------|------------------------|
| Lista canonica de todos los creables (`new ...()`) | [references/xone-javascript-runtime-objects.md §5](references/xone-javascript-runtime-objects.md#5-objetos-creables-con-new-o-createobject) |
| Lista canonica de singletons globales | [references/xone-javascript-runtime-objects.md §6](references/xone-javascript-runtime-objects.md#6-singletons-globales) |
| Objeto `ai` (IA generativa local, LLM on-device) | [references/xone-javascript-ai.md](references/xone-javascript-ai.md) |

### Validación antes de entregar

| Verificación | Donde mirar |
|--------------|--------------|
| Checklist de validación XML/JS/CSS | [references/xone-project-generation-workflow.md "Checklist"](references/xone-project-generation-workflow.md) |
| Cualquier atributo XML (referencia rápida) | [references/xone-xml-attributes-reference.md](references/xone-xml-attributes-reference.md) |

---

## Anti-patrones side-by-side: errores comunes y su correccion

Tabla compacta de los errores **más frecuentes** detectados en proyectos XOne reales y su forma correcta. Pensada para que el LLM compare visualmente lo INCORRECTO con lo CORRECTO antes de generar código. Para el detalle completo de cada caso, ver las reglas críticas y los archivos de referencia.

### Tipos de prop y atributos XML

| MAL (no funciona, no existe o esta deprecado) | BIEN |
|------------------------------------------------|------|
| `<prop type="C">` (combo) | `<prop type="T" mapcol="..." mapfld="...">` |
| `<prop type="M">` (mapa) | `<prop type="Z" viewmode="mapview">` |
| `<prop type="A">` (autocomplete) | `<prop type="T" mapcol="..." mapfld="..." linkedfield="...">` |
| `<prop type="STRING">` | `<prop type="T">` |
| `<prop type="N1">` (no existe — solo N, N2, N3, N4, N5, N6) | `<prop type="N">` o `<prop type="N2">` |
| `<prop type="F">` (float, no existe) | `<prop type="N2">` o el N{n} con los decimales necesarios |
| `<prop type="S">`, `<prop type="P">`, `<prop type="E">`, `<prop type="R">`, `<prop type="H">`, `<prop type="W">`, `<prop type="CAM">`, `<prop type="ARRAY">` | No existen. Ver tabla de tipos validos: T, TN, TN2-TN6, N, N2-N6, D, DT, TT, B, L, TL (alias legacy), X, IMG, PH, VD, DR, NC, Z, WEB, AT, THTML, O |
| `<prop type="IMG" readonly="false">` (firma obsoleta) | `<prop type="DR">` |
| `<prop type="BT">` | `<prop type="B">` (BT esta marcado como prohibido en docs) |
| `<prop name="PASSWORD" type="X">` en coll Usuarios | `<prop name="PWD" type="X">` — el framework lo lee literalmente como `PWD` |
| `<prop name="ID_EMPRESA">` en coll Usuarios | `<prop name="IDEMPRESA">` — el framework lo lee literalmente como `IDEMPRESA` (sin guion bajo) |
| `<prop name="CIUDAD" type="A" mapcol="Ciudades">` | `<prop name="CIUDAD" type="T" mapcol="Ciudades" mapfld="ID" linkedfield="NOMBRE">` |
| Inventar atributos (`my-custom-attr="..."`) | Solo usar atributos documentados. XOne ignora silenciosamente los desconocidos. |
| `<coll progid="MiObjeto">` (progid inventado) | `progid="ASData.CASBasicDataObj"` / `ASGestion.CASEmpresa` (Empresas) / `ASGestion.CASUser` (Usuarios) |
| `<prop type="T" labelwidth="0" title="Buscar">` — con `labelwidth="0"` la etiqueta se oculta y el `title` no se ve por ningún sitio. Resultado: input "huérfano" sin pista visual de qué es. | `<prop type="T" labelwidth="0" tooltip="Buscar">` — `tooltip` se renderiza como **hint/placeholder** dentro del propio campo y desaparece automáticamente al empezar a escribir. Si en cambio se quiere etiqueta fija visible: quitar `labelwidth="0"` y dejar `title="Buscar"`. Para etiqueta flotante estilo Material (siempre visible aunque escribas) usar `floating-tooltip="true"` junto a `tooltip`. |
| `<prop type="L" labelwidth="0" title="Título">` (o una clase CSS de título/subtítulo con `labelwidth: 0`) — el texto del label (su `title`, o el valor del campo si no declaras `title`) se pinta en el ancho de la etiqueta; con `labelwidth="0"` queda invisible (control vacío). Aquí `tooltip` NO sirve (un label no tiene placeholder). | `<prop type="L" title="Título" label-align="center">` — sin `labelwidth`; alinear con `label-align`. En CSS, la clase del label no debe llevar `labelwidth: 0`. |
| `<prop type="L" title="...">` esperando que muestre el VALOR que el JS actualiza (`self.MAP_ESTADO = "Cargando..."`) — con `title` declarado el label SIEMPRE pinta el `title` fijo, no el valor | `<prop type="L">` **sin `title`**: el label usa el **valor del campo** como fallback y `refreshValue("MAP_ESTADO")` lo refresca. (Alternativa equivalente: `<prop type="T" labelwidth="0" locked="true" text-border="false">`.) |
| `newline="false"` en el PRIMER elemento de un `<frame>` (fila de botones, campo+botón...) — el frame entero puede no montarse: sus controles desaparecen de la pantalla sin error visible | El primer elemento de la fila va SIN `newline`; solo el segundo y siguientes llevan `newline="false"`. Verificado en dispositivo |

### Eventos del ciclo de vida

| MAL | BIEN |
|-----|------|
| `<load>` para inicializar una pantalla | `<before-edit>` para inicializar al abrir; `<create>` para la primera vez |
| `<unload>`, `<ondelete>`, `<beforedelete>`, `<afterdelete>` (no existen) | `<delete>` con nodos hijos `<rule>` (es bloque de reglas de borrado, no evento antes/después) |
| `onchange="refresh255"` (notacion legacy de PDA) | `onchange="refresh"` (refresca todo) o `onchange="refresh(MAP_CAMPO)"` (refresca uno) |
| Dos `<before-edit>` en la misma coll | Solo uno. Si necesitas más lógica, llamala desde el mismo `<before-edit>` |

### JavaScript — createObject y singletons

| MAL | BIEN |
|-----|------|
| `appData.createObject("XOneFileManager")` | `new FileManager()` o `appData.createObject("FileManager")` |
| `appData.createObject("Http")` | Singleton global `$http` (sin `new`, sin `createObject`) |
| `appData.createObject("Crypto")` o `new Crypto()` | Singleton global `crypto` |
| `appData.createObject("XOneClipboard")` | Singleton global `clipboard` |
| `appData.createObject("DeviceInfo")` o `new DeviceInfo()` | Singleton global `deviceInfo` |
| `appData.createObject("SystemSettings")` o `new SystemSettings()` | Singleton global `systemSettings` |
| `appData.createObject("XOneBiometricsManager")` | Singleton global `biometricsManager` |
| `appData.createObject("ScriptSensorManager")` | Singleton global `sensorManager` |
| `appData.createObject("XOnePackageManager")` | Singleton global `packageManager` |
| `appData.createObject("XOneWifiManager")` | `new WifiManager()` |
| `appData.createObject("ScriptOauth2")` | `new OAuth2()` |
| `appData.createObject("WebWorker")` | `new Worker()` |
| `appData.createObject("XOneSocket")` / `XOneWebSocket` / `XOneDebugTools` | `new Socket()` / `new WebSocket()` / `new DebugTools()` |
| `appData.createObject("Encoder")` | `new EncodingUtils()` (no existe "Encoder") |
| `new Packages.com.xone.android.script.runtimeobjects.IniParser()` | `new IniParser()` (no requiere FQN) |

### JavaScript — APIs y patrones

| MAL | BIEN |
|-----|------|
| `self("CAMPO")` o `self('CAMPO')` (notacion de función) | `self.CAMPO`, `self["CAMPO"]`, o `self.getValue("CAMPO")` |
| `coll.macro("##NOMBRE##", valor)` | `coll.setMacro("##NOMBRE##", valor)` / `coll.getMacro("##NOMBRE##")` |
| `coll.setMacro(...)` sin declarar la macro en el XML | Declarar primero `<macro name="##NOMBRE##" value="..." default="true" />` como hijo directo de `<coll>` |
| `deviceInfo.getMobileNetworkSignalStrengh()` (typo) | `deviceInfo.getMobileNetworkSignalStrength()` (sin typo) |
| `ui.executeActionAfterDelay("X", 2000)` (cree que son ms) | `ui.executeActionAfterDelay("X", 2)` — el 2.o parámetro va en **segundos** |
| Encadenar `ui.executeActionAfterDelay` como `setInterval` (cada N segundos a si mismo) | Para temporizadores continuos: `control.startChronometer({fromDate, dateFormat})` / `control.stopChronometer()` |
| `ui.startChronometer({...})` (no es de `ui`) | `let ctrl = getControl("MAP_T"); ctrl.startChronometer({...})` — es método del **control**, no de `ui` |
| `ui.setFieldPropertyValue("MAP_X", "img", "...")` / `ui.getFieldPropertyValue(...)` (no son de `ui`) | `self.setFieldPropertyValue("MAP_X", "img", "...");` — es método del **DataObject (`self`)**, no de `ui`. Además el cambio no repinta solo: hay que llamar a `ui.refresh(prop)` después |
| Llamar `self.X` dentro de un callback asíncrono (`$http`, WebSocket, etc.) | `let miSelf = self; ... function(){ miSelf.X = ... }` — guardar referencia **antes** del callback |
| `coll.startBrowse()` sin `endBrowse()` en `finally` | `coll.startBrowse(); try {...} finally { coll.endBrowse(); }` |
| `coll.unlock()` sin `lock()` en `finally` | `coll.unlock(); try {...} finally { coll.lock(); }` — patrón recomendado: `lock()` activa el modo solo lectura (con la bandera activa, `clear()`/`loadAll()` son no-op); `unlock()` permite escribir. Aunque las colecciones nacen desbloqueadas, el convenio del proyecto es dejarlas bloqueadas tras operar para evitar que código posterior mute la coll por accidente |
| `self.lock()` / `self.unlock()` (LLMs lo inventan por analogía con mutex) | `lock()`/`unlock()` son métodos de la **colección**, NO del DataObject. Usar `self.getContents("X").unlock()` o `appData.getCollection("X").unlock()`. En `self` no existen |
| `appData.executeSql("UPDATE ... WHERE ID=" + idUsuario)` (SQL injection) | `sqlManager.doRawQuery("UPDATE ... WHERE ID=?", idUsuario)` con parámetro |
| Declarar `function getControl(sControl){...}` como helper en `functions.js` | **`getControl(name, [dataObject])` ya es NATIVA del motor** (Rhino y V8). Firma estricta: lanza error si el nombre está vacío, el control no existe en la ventana destino, no hay ventana, o el dataObject no es válido. Con un solo argumento usa la última ventana visible; con dataObject usa la ventana asociada a ese objeto. Proyectos legacy con su propia función pueden mantenerla: la declaración del script sombrea a la nativa en su scope local |

### APIs web que NO existen en XOne

| MAL (API web) | BIEN (alternativa XOne) |
|---------------|--------------------------|
| `document.getElementById("X")` | `ui.getView(self)["X"]` o `getControl("X")` |
| `window.location` / `window.history` | `ui.openEditView("Coll")`, `ui.getView(self).exit()` |
| `localStorage.getItem("X")` / `setItem` | `appData.getGlobalMacro("##X##")` / `setGlobalMacro` |
| `sessionStorage` | Variables de colección (`coll.setVariable`/`getVariable`) o de empresa (`empresa.setVariable`) |
| `new XMLHttpRequest()` | `$http.get(url, request, success, error)` (idiomático). `fetch(url)` también existe vía implementación custom. |
| `setTimeout(fn, 1000)` | Idiomático: `ui.executeActionAfterDelay("nombreNodo", 1)` (segundos). `setTimeout` con `(fn, ms)` también existe vía implementación custom. |
| `setInterval(fn, 1000)` | Idiomático: `control.startChronometer(...)` para temporizadores continuos. `setInterval` también existe vía implementación custom. |
| `navigator.geolocation.getCurrentPosition(...)` | `ui.startGps({nodeName: "callbackgps"})` |
| `alert("msg")` / `confirm` / `prompt` | `ui.msgBox(msg, título, 0)` o `ui.showToast(msg)` |
| `console.error(...)` / `console.warn(...)` | **Sí existen.** API `console` completa WHATWG: `log/info/debug/warn/error/trace/assert/group/groupCollapsed/groupEnd/time/timeLog/timeEnd/count/countReset/dir/dirxml/clear/table` con formato `%s/%d/%i/%f/%o/%O/%j/%%`. |
| `require()` / `import` (CommonJS / ES modules) | **Preferido:** declarar en `<app>` con `<include file="..."/>` o `<script src="..."/>` (estático). **Dinámico (solo casos especiales):** `appData.loadIncludeFile(file [, lang] [, encoding] [, delayCompilation] [, compile])` — default encoding `ISO-8859-1`, pasar `"UTF-8"` si hay tildes/ñ. Detalle en references §2.2.12 |
| `<link rel="stylesheet" href="...">` | **Preferido:** declarar en `<app>` con `<style url="..."/>` (estático). **Dinámico (solo casos especiales, p. ej. cambio de tema):** `appData.loadCssFile(name [, encoding] [, conditions] [, strictMode])` y `appData.unloadCssFile(name)` — default encoding `"UTF-8"`. Detalle en references §2.2.13 |

### Naming y unicidad

| MAL | BIEN |
|-----|------|
| Dos `<group id="1">` en la misma `<coll>` | Cada `<group>` con `id` único en la coll. Convencion: 1, 2, 3 para tabs; 999 HEADER fijo; 0 FOOTER fijo |
| Dos `<prop name="X">` en la misma coll (aunque estén en grupos distintos) | Cada `<prop>` con `name` único en la coll **entera** |
| **Caso típico que dispara el error** — una coll que combina dos modos en grupos distintos (listado con `visible="2"` + detalle con `visible="1"`) y declara el mismo campo BD en ambos para darle estilos distintos: `<prop name="NUMPARTE" visible="2" class="lblNumeroParte"/>` en grpLista **y** `<prop name="NUMPARTE" visible="1" class="inputTexto"/>` en grpDetalle. **Esto VIOLA la regla** — el `name` se publica a nivel de coll, los `collprops` no admiten dos entradas con el mismo nombre aunque la visibilidad y los estilos sean distintos. | Declarar el campo real **una sola vez** (en el grupo de detalle, con `visible="1"`). Para el listado con estilos custom, añadir alias en el SELECT con prefijo `MAP_LIST_`: `sql="SELECT ..., p.NUMPARTE AS MAP_LIST_NUMPARTE FROM ..."` y declarar `<prop name="MAP_LIST_NUMPARTE" visible="2" class="lblNumeroParte"/>` en grpLista. El alias NO persiste (prefijo `MAP_` excluye de INSERT/UPDATE) y deja libre el `name` original. Aplica igual a `<frame>` y `<group>` duplicados: renombrar al del segundo grupo (`frmHeader` → `frmHeaderDetalle`). |
| Declarar `name="MiNombre"` y luego usar `self.minombre` (distinto case) | Respetar exactamente el case: `name="MiNombre"` -> `self.MiNombre` (el `name` es case-sensitive en TODAS las referencias: `mapcol`, `linkedto`, `<field name="...">`, `getControl("...")`, `ui.openEditView("...")`, `appData.getCollection("...")`) |
| Dos `<coll>` con el mismo `name` en el proyecto | Cada coll con `name` único (el contenido SI puede repetirse entre colls distintas) |
| Campo de BD con prefijo `MAP_` | Sin prefijo: `NOMBRE`, `CODIGO`. El prefijo `MAP_` es solo para campos NO persistidos (UI temporal, JOIN, `linkedto`) |
| Campo de UI / JOIN / `linkedto` sin prefijo `MAP_` | Con prefijo: `MAP_NOMBRE_CLIENTE`, `MAP_TOTAL`. El framework excluye `MAP_*` de INSERT/UPDATE |

### Sistema de visibilidad (`visible="..."`)

| MAL | BIEN |
|-----|------|
| `visible="3"` cuando se quiere "siempre visible" | `visible="7"` (formulario + lista + content) — la opción más habitual |
| `visible="1"` cuando se quiere ver en lista | `visible="2"` (solo lista) o `visible="7"` (todos) |
| Cambiar `visible` por script en runtime | `visible` es **estático**. Para visibilidad condicional usar `disablevisible="CAMPO=valor"` |

### CDATA y escape XML en `.xne`

| Caso | Forma válida |
|------|--------------|
| **JS no trivial — forma preferida** | Mover la función a un fichero `.js` externo (`functions.js` u otro `<include>`-ado) y llamarla desde el `.xne` con `miFuncion();`. El JS se escribe normal, sin entidades ni CDATA. |
| Snippet corto inline en nodo `<script>` con `<`, `>`, `&` | Cualquiera de las dos: entidades XML (`&lt;`, `&gt;`, `&amp;`) o envolver en `<![CDATA[…]]>`. Las dos funcionan. |
| Snippet inline en atributo (`onclick=`/`disablevisible=`/…) | Entidades XML obligatorio (CDATA no es válido dentro de atributos XML). |

### Errores conceptuales

| MAL | BIEN |
|-----|------|
| `setBlur(...)` / `setSaturation(...)` como API del framework | Son **funciones de proyecto** — el desarrollador las implementa. No están en `ui.*` |
| `GpsCollection` como coll built-in de XOne | Es coll que **el proyecto debe declarar** con connector GPS — no viene por defecto |
| Cambiar `visible` en runtime | `visible` es estático. Para visibilidad dinámica: `disablevisible` |
| Generar pantallas `special="true"` con `sql=` | `special` y `sql` son mutuamente excluyentes |
| `mappings.xne` con colecciones de negocio | `mappings.xne` SOLO contiene Empresas y Usuarios. Cada coleccion adicional va en su propio `.xne` |
| Implementar el splash dentro de `EntradaApp.xne` (logo + timer + redirect a Login/Menu) | El splash **NO es una `<coll>`** ni se mete en `EntradaApp`. Es un fichero `splash.png` (o `.jpg`/`.gif`/`.webp`/`.apng`/`.mp4`/`.3gp`) en la **raíz del proyecto**; el framework lo carga automáticamente desde `LoadAppActivity` antes de iniciar la app. `EntradaApp` es la pantalla **post-login** de bienvenida con su botón "Entrar" (NO autoredirect con timer) |
| Usar `load-imgbk` del `<app>` pensando que es el splash | `load-imgbk` es la **imagen de fondo del EditView**, no el splash. El splash se hace SIEMPRE con el fichero `splash.png` en la raíz |
| `EntradaApp` con auto-redirect via `ui.openEditView(...)` dentro de `<before-edit>` o timer | La plantilla canónica de `EntradaApp` (workflow §7.4) muestra logo + nombre + descripción + **botón "Entrar"** que el usuario pulsa manualmente para ir a `MenuPrincipal`. Si la app debe arrancar directamente en el menú sin bienvenida, usar `MenuPrincipal` como `entry-point` directamente y NO crear `EntradaApp` |

---

## REGLAS CRITICAS

### Regla Fundamental

> **TODAS las decisiones de desarrollo DEBEN basarse en los archivos de referencia de este skill, NUNCA en conocimiento externo o suposiciones.**

### Proceso de Decisión Obligatorio

Antes de escribir cualquier código:

1. ¿Existe documentación sobre esto en los archivos de referencia? **SI** -> Seguir la documentación exactamente. **NO** -> Preguntar al usuario.
2. ¿El atributo/función/propiedad esta documentado? **SI** -> Usar solo los valores documentados. **NO** -> NO inventar, buscar alternativas documentadas o preguntar.

### Prohibiciones Explicitas

- **NO** inventar atributos XML que no estén en los archivos de referencia
- **NO** usar funciones JavaScript que no estén documentadas en la API de XOne
- **NO** crear propiedades CSS que no existan en el sistema XOne
- **NO** asumir comportamientos basados en HTML/CSS/JS web estándar
- **NO** mezclar sintaxis de otros frameworks (React, Angular, Vue, etc.)
- **NO** usar unidades CSS web como `px`, `em`, `rem` (usar `p` para puntos y `%` para porcentaje)
- **NO** poner todas las colecciones en `mappings.xne` (solo Empresas y Usuarios)
- **NO** omitir campos obligatorios mínimos en las colecciones base
- **NO** tratar `progid` como obligatorio: es OPCIONAL (sin él, objeto de datos genérico ≡ `ASData.CASBasicDataObj`). Solo **Empresas** (`ASGestion.CASEmpresa`) y **Usuarios** (`ASGestion.CASUser`) requieren su progid propio
- **NO** declarar en un `.xne` un encoding distinto de cómo está guardado el fichero (corrompe tildes/ñ). UTF-8 (default del motor) e `iso-8859-15` son válidos; sé coherente en todo el proyecto
- **NO** implementar el splash de carga inicial como una pantalla `.xne` ni meterlo dentro de `EntradaApp` (con logo + timer + redirect). El splash **no es una `<coll>`**: es un fichero estático (`splash.png` / `.jpg` / `.gif` / `.webp` / `.apng` / `.mp4` / `.3gp`) que se coloca en la **raíz del proyecto** y que `LoadAppActivity` del framework carga automáticamente antes de iniciar la app. `EntradaApp` es la pantalla **post-login** de bienvenida (con botón "Entrar"), no el splash. Tampoco confundir con `load-imgbk` del `<app>`, que es la imagen de fondo del EditView
- **NO** crear, editar, leer ni referenciar ficheros `.xml` de colecciones o pantallas. El único formato fuente para colecciones/pantallas es `.xne`. Los ficheros `.xml` de colecciones son **artefactos generados automáticamente por XOneStudio**. Tratalos como salida de compilación: no son fuente. La única excepción es `app.xml` (configuración global), que SI es fuente. Regla operativa: si un proyecto tiene `.xne` y `.xml` conviviendo, trabajar solo sobre los `.xne`; los `.xml` se ignoran por completo
- **NO** usar APIs del DOM — XOne no es HTML y no tiene navegador. Estas funciones NO existen en XOne: `document`, `document.getElementById`, `document.querySelector`, `window`, `window.location`, `localStorage`, `sessionStorage`, `XMLHttpRequest`, `navigator`, `history`. Para HTTP idiomático usar `$http`; para navegación `ui.*`; para datos `self.*` y `appData.*`. **SÍ existen** con implementación custom XOne (semántica spec-compatible): `Promise` (ES2024 con `all`/`allSettled`/`race`/`any`/`withResolvers`/`.then`/`.catch`/`.finally`), `fetch`, `setTimeout`/`setInterval`, `URL`, `Headers`, `AbortController`, `EventTarget`, `TextEncoder`/`TextDecoder`, `console`, `performance.now()`, `atob`/`btoa`. La sintaxis `class` ES6+ también está soportada (declaraciones, expresiones, `extends`/`super`/`static`/getters/setters/computed keys, **field declarations** `name = expr;` y `static name = expr;`, **generator methods** `*method()`). Los generadores con `yield` funcionan pero usan runtime estilo SpiderMonkey legacy (`gen.next()` devuelve el valor directo + lanza `StopIteration`; `for...of` no los itera). **NO** está soportado: `async`/`await`, template literals, spread/rest, default params, optional chaining `?.`, `import`/`export`, private fields `#name`, static blocks.
- **NO** usar `<load>` para inicializar pantallas — usar `<before-edit>`
- **NO repetir nombres de nodos dentro de la misma coleccion** — Restricción crítica. **El ambito de unicidad es la `<coll>` ENTERA**, no el `<group>` o `<frame>` que contiene al nodo. Es decir: no pueden existir dos `<prop>`, dos `<group>`, dos `<frame>` ni dos eventos con el mismo `name` en cualquier parte de la misma coll, **aunque estén en `<group>` o `<frame>` distintos**. Razón: el `name` se publica a nivel de la coll (los `collprops`), por lo que actuaria como identificador único ambiguo si se repitiera.
- **NO usar VBScript** en NINGUN lado (ni en respuestas, ni en proyectos generados). VBScript esta **descontinuado** en XOne. La única solución valida es **JavaScript** (`<script language="javascript">`). Si encuentras un ejemplo en VBScript en una fuente, traducelo a JavaScript antes de proponerlo
- **NO usar `coll.macro(...)` ni `content.macro(...)`** — esa sintaxis es **incorrecta** y no existe. La API valida es `setMacro("##NOMBRE##", valor)` para asignar y `getMacro("##NOMBRE##")` para leer. Para macros globales, `appData.setGlobalMacro` / `appData.getGlobalMacro`
- **NO olvidar declarar el nodo `<macro>` en el XML** antes de hacer `setMacro` — la macro debe existir en la coll con `<macro name="##X##" value="..." default="true" />` **al mismo nivel que los `<group>`** (hijo directo de `<coll>`, no anidado). Sin esa declaración, `setMacro` no inyecta nada en el SQL.
- **Escape XML del JS dentro de un `.xne`** — para JS no trivial, la **forma preferida** es declarar la función en un fichero `.js` externo y llamarla desde el XML con `miFuncion();` (el JS se escribe normal, sin entidades ni CDATA). Para snippets cortos inline, el parser de XOne acepta dos formas: (a) escapar los caracteres especiales con entidades XML dentro del JS (`&` -> `&amp;`, `<` -> `&lt;`, `>` -> `&gt;`, `"` -> `&quot;`, `'` -> `&apos;`), o (b) envolver el bloque en `<![CDATA[…]]>` cuando está dentro de un nodo `<script>` (CDATA no es válido dentro de atributos XML como `onclick="…"`).
- **`ID` y `ROWID` los gestiona la plataforma** — no hace falta declararlos como `<prop>` (declararlos es válido pero redundante; la recomendación es omitirlos por limpieza). En el atributo `sql=` de la coll, el campo **`ID` SÍ se rescata** en el SELECT (`SELECT ID, NOMBRE, ... FROM ##PREF##Tabla`); el `ROWID` **no es necesario** en el SELECT.
- **NO** usar el método obsoleto de firma `type="IMG" readonly="false"` — usar `type="DR"`
- **NO** instanciar `deviceInfo` ni `systemSettings` con new — son singletons globales
- **NO** usar `self("CAMPO")` ni `self('CAMPO')` para acceder a campos — la sintaxis correcta es `self.CAMPO` (notacion de punto) o `self["CAMPO"]` (notacion de corchetes) o `self.getValue("CAMPO")`. La notacion `self()` como función NO existe en XOne
- **NO** omitir el prefijo `MAP_` en props cuyo valor NO sea una columna de la tabla apuntada por `objname`. El framework excluye los `MAP_*` de los `INSERT`/`UPDATE`. Aplica a: (a) campos de JOIN en el SQL, (b) props enlazados via `linkedto` (combos/lookups), (c) props puramente visuales: etiquetas `L` (o su alias legacy `TL`), botones `B`, imágenes decorativas, contenedores `Z`, valores calculados, estados de UI. Inversamente, **NO** poner `MAP_` a un campo que SI es columna BD.
- **NO** usar tipos de prop inventados. Los tipos validos son: `T`, `TN`/`TN2`..`TN6`, `N`/`N2`..`N6`, `D`, `DT`, `TT`, `B`, `L` (o su alias legacy `TL`), `THTML`, `WEB`, `IMG`, `PH`, `VD`, `DR`, `NC`, `X`, `Z`, `AT`, `O`. El sufijo numérico en `N` y `TN` indica los decimales visibles en el control (`N2` = 2 decimales, `N6` = 6, etc.). Los tipos `BT`, `C`, `M`, `A`, `R`, `E`, `H`, `W`, `F` **NO existen** en XOne y causaran errores. Los combos/selectores se implementan con `type="T"` (o `type="N"`) más los atributos `mapcol` y `mapfld`, NO con un type especifico.
- **NO mezclar mayusculas/minusculas en el atributo `name`** — El `name` de los nodos `<coll>`, `<group>`, `<frame>` y `<prop>` es **case-sensitive**. `name="MiNombre"` y `name="minombre"` son nombres **distintos** para XOne. Esto aplica también a TODAS las referencias cruzadas: `self.MiNombre` vs `self.minombre`, `mapcol`, `linkedto`, `inherits`, `<field name="...">`, `getControl("...")`, `ui.openEditView("...")`, `appData.getCollection("...")`, etc. Mantener una convencion uniforme en todo el proyecto (recomendado: PascalCase para colls/groups/frames y MAYUSCULAS para campos de BD).
- **NO repetir el atributo `id` de `<group>` dentro de la misma `<coll>`** — En cada `<group>` el atributo `id` es **obligatorio** y debe ser **único dentro de la coll que lo contiene**. Si hay dos `<group id="1">` en la misma coll el comportamiento es indefinido (la navegación entre tabs y el rebuild de layout fallan). Convencion habitual: `id="1"`, `id="2"`, ... para grupos normales; `id="999"` para HEADER fijo (`class="groupfixed_header"`) y `id="0"` para FOOTER fijo (`class="groupfixed_footer"`).

### Herencia entre Colecciones (`inherits`) y Composición XML (`<include-layout>`)

Antes de duplicar estructura entre varias colecciones (header, footer, botones comunes, eventos compartidos), evaluar si usar uno de los dos mecanismos de reutilización XML de XOne:

- **`inherits`** en `<coll>`: la coleccion hija hereda grupos, frames, props y eventos del padre. En duplicidad prevalece la hija. Admite cadenas (A->B->C) pero NO herencia multiple. Uso típico: scaffolding visual compartido en una coll `special="true"` reutilizada por varias pantallas.
- **`<include-layout file="..." group="..." frame="..." />`**: nodo hijo de `<coll>` que inyecta el contenido de un XML externo (raiz `<xml>`, encoding `utf-8`, estructura plana). Útil para factorizar botoneras o fragmentos repetidos. No se pueden anidar.

Regla de decisión rápida:
- **3+ pantallas comparten estructura** -> crear coll base `special="true"` y usar `inherits`.
- **Fragmentos repetidos (botoneras, bloques de props)** -> extraer a fichero XML externo con `<include-layout>`.
- **1-2 pantallas parecidas** -> normalmente duplicar es más claro; no sobre-abstraer.

Prohibiciones:
- **NO** usar `inherits` multiple (sintaxis `inherits="A,B"` no existe).
- **NO** anidar `<include-layout>` dentro de un fichero incluido.
- **NO** usar encoding `iso-8859-15` en ficheros de `<include-layout>` — usar `utf-8`. (Los `.xne` siguen siendo `iso-8859-15`; solo los ficheros incluidos por `<include-layout>` usan `utf-8`.)
- **NO** poner `<coll>` como raiz del fichero incluido — la raiz debe ser `<xml>`.

Referencia completa: sección 6.5b de [references/xone-project-generation-workflow.md](references/xone-project-generation-workflow.md).

### Campos Mínimos Obligatorios en Colecciones Base

| Coleccion | progid | Campos a declarar como `<prop>` |
|-----------|--------|----------------------------------|
| **Empresas** | `ASGestion.CASEmpresa` | `CODIGO` (N), `NOMBRE` (T) |
| **Usuarios** | `ASGestion.CASUser` | `CODIGO` (N), `NOMBRE` (T), `IDEMPRESA` (N), `LOGIN` (T), `PWD` (X) |
| **Resto** | `ASData.CASBasicDataObj` | Los que defina el desarrollador |

> **`ID` y `ROWID` los gestiona la plataforma** — no hace falta declararlos como `<prop>` (declararlos es válido pero redundante). En el `sql=` de la coll, **`ID` sí se rescata en el SELECT** (`SELECT ID, ...`); el `ROWID` no es necesario en el SELECT.

---

## Flujo de Generación de Proyectos

### Fase 1: Análisis de Requisitos

1. **Comprender la descripción** — Que tipo de aplicación, cual es su proposito
2. **Identificar colecciones** — Modelo de datos: entidades, campos, relaciones
3. **Identificar pantallas y navegación** — Flujo de usuario: entrada, menu, listados, detalle, formularios
4. **Identificar integraciones** — GPS, camara, firma digital (DR), escaner QR/barras
5. **Definir paleta de colores y estilo visual** — Colores primarios, secundarios, fondos, textos

### Fase 2: Estructura del Proyecto

Consulta [references/xone-project-generation-workflow.md](references/xone-project-generation-workflow.md) para el flujo completo.

```
NombreProyecto/
├── bd/              # [OBLIGATORIO] Base de datos SQLite
├── icons/           # [OBLIGATORIO] Recursos graficos (solo PNG)
├── files/           # [OBLIGATORIO] Archivos dinamicos (fotos, firmas, docs)
├── fonts/           # [RECOMENDADO] Fuentes tipograficas (.ttf, .otf)
├── scripts/         # [OPCIONAL] Scripts JS organizados por modulo
├── lang/            # [OPCIONAL] Multiidioma (subcarpetas por ISO: en/, es/)
├── certificates/    # [OPCIONAL] Certificados SSL/TLS
└── splash.png       # [OPCIONAL] Imagen de splash de carga inicial (raíz del proyecto)
                     # Acepta tambien splash.jpg/.gif/.webp/.apng/.mp4/.3gp
                     # El framework lo carga automaticamente — NO es una <coll>
```

### Fase 3: Archivos de Configuración

| Archivo | Descripción |
|---------|-------------|
| `app.xml` | Configuración de la app. Atributo `prefix="gen"` por defecto |
| `app.ini` | Metadatos: Name, Title, Caption, Icon, IconFolder=icons, FilesFolder=files |
| `mappings.xne` | SOLO colecciones Empresas y Usuarios con progid y campos obligatorios. Encoding: UTF-8 o iso-8859-15 (coherente con los bytes) |
| `default.css` | Estilos globales con clases base |
| `functions.js` | Funciones JavaScript globales |

### Fase 4: Colecciones y Pantallas

**Colecciones:**
- Un archivo `.xne` por cada coleccion adicional. Encoding: `UTF-8` (default del motor) o `iso-8859-15`, coherente con cómo se guarda
- `progid` es **opcional** (default = objeto de datos genérico ≡ `ASData.CASBasicDataObj`). Declararlo solo si se quiere ser explícito; **Empresas** usa `ASGestion.CASEmpresa` y **Usuarios** `ASGestion.CASUser`
- Usar macro `##PREF##` en queries SQL
- **Tipos validos:** T, TN/TN2..TN6, N/N2..N6, D, DT, TT, B, L, TL (alias legacy), THTML, WEB, IMG, PH, VD, DR, NC, X, Z, AT, O (el sufijo en N/TN indica decimales visibles)

**Pantallas:**
- `EntradaApp.xne` — Pantalla de entrada **post-login** (bienvenida con botón "Entrar"). Obligatoria salvo que la app arranque directamente en `MenuPrincipal`. **NO es el splash de carga** — el splash es un fichero `splash.png` en la raíz del proyecto
- `MenuPrincipal.xne` — Menu principal
- Pantallas de listado, detalle, formularios según requisitos
- Inicializar siempre con `<before-edit>`, nunca con `<load>`
- **Splash de carga:** NO es una pantalla `.xne` — colocar `splash.png` (o `.jpg`/`.gif`/`.webp`/`.apng`/`.mp4`/`.3gp`) en la **raíz del proyecto**. El framework lo carga automáticamente

### Fase 5: Post-Generación

Indicar al usuario que ejecute:
1. Generar base de datos con `xone_db_generator`
2. Insertar datos iniciales (Empresa + Usuario admin)
3. Descargar iconos de Google Material Icons (PNG, JPG o SVG — todos validos)

---

## Referencia Rápida de Tecnologías XOne

### XML (.xne) — Definición de Interfaz

Consulta [references/xone-xml-ui-reference.md](references/xone-xml-ui-reference.md) para referencia completa.

**Nodos principales:**
- `<coll>` — Coleccion (nodo raiz). Atributos típicos en colecciones de datos: `name`, `sql`, `objname`, `updateobj` (obligatorios) y `progid` (opcional; solo Empresas/Usuarios lo requieren)
- `<prop>` — Propiedad/campo. Atributos: `name`, `type`, `visible`, `size`, `title`, `class`, `width`, `height`
- `<frame>` — Contenedor de layout. Atributos: `name`, `class`, `width`, `height`, `bgcolor`
- `<group>` — Grupo/tab. Atributos: `name`, `id`, `class`
- `<contents>` — Lista embebida. Atributo: `src="NombreColeccion"`
- `<permissions>` — Permisos del sistema (location-foreground, camera, notifications, etc.)

**Eventos de ciclo de vida (orden correcto):**
- `<create>` — Primera vez que se crea el objeto
- `<before-edit>` — Al abrir para edición. **Usar para inicializar pantalla**
- `<after-edit>` — Después de entrar en edición
- `<load>` — Se dispara **por cada data object** al cargarse desde la BD: tanto al recorrer la coleccion (`startBrowse()`/`loadAll()`) como al hidratar items de un `<contents>` o cargas individuales. **NO es evento de pantalla** y **NO recomendado** por impacto en rendimiento
- `<onchange>` — Al cambiar valor de campo (necesita `<field name="CAMPO">`)
- `<selecteditem>` — Al seleccionar item en lista
- `<onback>` — Al pulsar atrás

**Eventos de ciclo de aplicación (ámbito aplicación, NO de pantalla):**
Se declaran en la colección `Empresas` (en `mappings.xne`), no dentro de una `<coll>` de pantalla. Se disparan a nivel de proceso completo, solo cuando toda la app cambia de estado:
- `<on-app-foreground>` — La app vuelve a primer plano (tras haber estado en segundo plano). Lugar idóneo para verificar inactividad y forzar re-login (`ui.getInactivityTime()`)
- `<on-app-background>` — La app pasa a segundo plano (el usuario cambia de app o pulsa Home)

**IMPORTANTE:** `onclick` se usa SIEMPRE como atributo del nodo `<prop>`, NUNCA como nodo hijo. **Y el valor es SIEMPRE código JavaScript inline, NO el nombre de un nodo.** Si quieres invocar un nodo desde `onclick`, hazlo explícitamente: `onclick="self.executeNode('nombreNodo');"`. Si pones solo `onclick="nombreNodo"` (sin paréntesis ni `self.executeNode`), XOne evalúa `nombreNodo` como variable JS (undefined) y el botón no hace nada silenciosamente.

Formas válidas de `onclick`:

```xml
<!-- A) JS inline simple (lo más habitual) -->
<prop ... onclick="ui.openEditView('Tareas');" />

<!-- B) JS inline con varias sentencias -->
<prop ... onclick="appData.getCollection('Tareas').setMacro('##FILTRO##', ''); ui.openEditView('Tareas');" />

<!-- C) Llamada a función global declarada en functions.js -->
<prop ... onclick="verTodasTareas();" />

<!-- D) Invocar un nodo handler explícitamente (cuando se quiere reutilizar lógica) -->
<prop ... onclick="self.executeNode('miHandler');" />
<miHandler show-wait-dialog="false">
    <action name="runscript"><script language="javascript">/* ... */</script></action>
</miHandler>

<!-- E) Comando interno especial: refresh -->
<prop ... onclick="refresh" />            <!-- refresca toda la pantalla -->
<prop ... onclick="refresh(MAP_CAMPO)" /> <!-- refresca un campo -->
```

Mal:

```xml
<!-- MAL: XOne evalúa 'abrirTareas' como variable JS, no busca un nodo <abrirTareas> -->
<prop ... onclick="abrirTareas" />
```

### JavaScript — API XOne

Consulta [references/xone-javascript-patterns.md](references/xone-javascript-patterns.md) para referencia completa.

- `ui` — Navegación (`openEditView`), mensajes (`msgBox`, `showToast`, `showSnackbar`), dispositivo (`startGps`, `stopGps`)
- `self` — Acceso al DataObject actual (leer/escribir campos: `self.CAMPO` o `self["CAMPO"]`)
- `appData` — Almacenamiento global (`setGlobalMacro`, `getGlobalMacro`, `getCollection`, `exit`)
- `$http` — Peticiones HTTP con Futures. También: `setProxy`, WebSocket, SSL/TLS con KeyStore
- `deviceInfo` — Singleton global (batería, red, trafico). NO usar `new DeviceInfo()`
- `systemSettings` — Singleton global (permisos, memoria, espacio en disco, MDM, brillo). NO usar `new`
- `new Animation()` — API fluida. `setTarget("NOMBRE_PROP")` recibe string, no objeto

### CSS — Estilos Propietarios

Consulta [references/xone-css-styling-guide.md](references/xone-css-styling-guide.md) para referencia completa.

**Selectores:** `coll`, `prop`, `prop:TYPE`, `.clase`, `group`, `frame`
**Unidades:** `p` (puntos), `%` (porcentaje). NUNCA `px`, `em`, `rem`
**Colores:** `#RRGGBB` o `#AARRGGBB` (alpha al inicio)
**Herencia:** `extends:.otraClase`
**Importante:** Si `compatibility-mode="true"` en app.xml, el CSS se ignora completamente

---

## Tamaños canónicos (`width` / `height` / `fontsize`)

Antes de fijar cualquier `width` o `height`, consulta **[references/xone-canonical-sizes.md](references/xone-canonical-sizes.md)** — contiene tablas por tipo de elemento (frames, botones, inputs, listas, avatares, iconos, tipografía, áreas especiales, wearable) y los anti-patrones más frecuentes. **Todos los valores están calibrados para `resolution-width="1080"` / `resolution-height="1920"` (default XOne).**

> **REGLA CRÍTICA:** En XOne **`p` ≠ `dp`**. 1p = 1px en el dispositivo de referencia. Material 56dp en 1080×1920 (xxhdpi, density 3×) = **~168p**, NO 56p. Aplicar valores Material directamente como `p` produce barras/botones ~3× más pequeños de lo necesario.

### Heurísticas de decisión (memorizar)

1. **Header / footer / toolbar / drawer fijos** → `height` en `Np` absoluto (típicos en 1080×1920: header `164p`, header completo con tabs `404p`, footer con botones `216p`–`288p`, bottom nav `168p`, drawer width `840p`–`960p`).
2. **Frame body principal entre header y footer fijos** → `height="-2"` o `height="100%" scroll="true"`. NUNCA un `%` calculado a mano restando los fijos.
3. **Contenido apilado verticalmente** → `height="-2"` (wrap content) y dejar que el contenido mande. Solo fijar `Np` si necesitas mínimo visual.
4. **Imágenes, avatares, iconos** → `Np` fijos en **ambos** ejes para preservar aspecto. NUNCA `width="100%" height="100%"` en una imagen.
5. **Botones** → `width` en `%`, `height` en `Np`, mínimo **144p** (touch target Material 48dp × 3 en xxhdpi). CTAs principales: `124p` (workflow pill).
6. **Inputs** → `width="95%"`–`"100%"`, `height` en `Np` (típico `144p`).
7. **Dos elementos en la misma fila** → cada uno con `width` `%` que sume ≤ 100%, el segundo con `newline="false"`.
8. **Los `%` se refieren al padre directo**, no a la pantalla. Tres frames hermanos con `height="40%"` desbordan (suman 120%).
9. **`<prop>` tiene 2 columnas internas (label + valor)**: si `labelwidth="50"` y `width="50%"`, el valor real queda con 25% de la fila. Bajar `labelwidth` a 20-30 o subir `width` a 95-100%.
10. **`fontsize` usa escala XOne 1-12**, NO Material `sp`/`dp`. Texto estándar = `5`, título sección = `7`, topbar = `10`–`11`, nombre app = `12`.

### Defaults seguros para 1080×1920 (cuando no estás seguro)

| Nodo | width | height |
|------|-------|--------|
| `<frame>` cabecera | `100%` | `164p` |
| `<frame>` cuerpo | `100%` | `-2` con `scroll="true"` |
| `<frame>` pie con botones | `100%` | `216p` |
| `<frame>` tarjeta | `95%` | `-2` |
| `<prop type="T">` / `N` / `D` / `combo` | `100%` | `144p` |
| `<prop type="B">` (botón) | `90%` | `124p` |
| `<prop type="L">` (label) | `100%` | `-2` (o `96p`) |
| `<prop type="NC">` (checkbox) | `100%` | `144p` |
| `<prop type="IMG">` / `PH` / `DR` | `100%` | `600p`–`720p` |
| `<prop type="Z">` (contenedor) | `100%` | `-2` o `100%` |
| Icono `img-width` / `img-height` | `72p` (toolbar) o `104p` (botón cuadrado) | igual |
| `tmargin` entre elementos del mismo bloque | — | `30p` |
| `tmargin` entre bloques distintos | — | `50p` |
| `fontsize` texto estándar | — | `5` |

> **Si `resolution-width` ≠ 1080**, escalar con `valor_nuevo = valor_tabla × (resolution-width / 1080)`. Detalle en §14 de `xone-canonical-sizes.md`.

> **Limitación honesta:** sin ver el render real es imposible afinar al píxel. Estos valores cubren el caso típico y evitan errores groseros (desborde, touch target insuficiente, distorsión de imagen), pero pueden requerir ajuste tras la primera compilación. Si el usuario aporta una captura o el dispositivo objetivo (móvil / tablet / wearable / kiosko), usar la sección §11 (wearable) o ajustar proporcionalmente.

---

## Plantilla Estándar de Pantalla

```xml
<?xml version="1.0" encoding="iso-8859-15"?>
<coll name="NombrePantalla" title="Título" special="true" notab="true" show-toolbar="false">

    <!-- Inicializar la pantalla en before-edit, NUNCA en load -->
    <before-edit refresh="false" show-wait-dialog="false">
        <action name="runscript">
            <script language="javascript">
                // Inicializar campos y datos
                self.MAP_TITULO = "Mi pantalla";
            </script>
        </action>
    </before-edit>

    <group name="grpPrincipal" id="1">
        <frame name="frmHeader" width="100%" height="140p" bgcolor="#1565C0">
            <!-- Logo, título, botones de navegacion -->
        </frame>
        <frame name="frmBody" width="100%" height="-2" scroll="true" bgcolor="#FFFFFF">
            <!-- Contenido: campos, listas, botones -->
        </frame>
        <frame name="frmFooter" width="100%" height="100p" bgcolor="#F5F5F5">
            <!-- Botones de acción, barra inferior -->
        </frame>
    </group>

    <onback show-wait-dialog="false">
        <action name="runscript">
            <script language="javascript">
                ui.getView(self).exit();
            </script>
        </action>
    </onback>
</coll>
```

## Plantilla Estándar de Coleccion de Datos

```xml
<?xml version="1.0" encoding="iso-8859-15"?>
<coll name="MiColeccion"
      progid="ASData.CASBasicDataObj"
      sql="SELECT ID, NOMBRE FROM ##PREF##MiColeccion"
      objname="MiColeccion"
      updateobj="MiColeccion"
      loadall="true">
    <group name="General" id="1">
        <!-- ID y ROWID los gestiona XOne: no hace falta declararlos (válido pero redundante). Solo ID se rescata en el SELECT. -->
        <prop name="NOMBRE" type="T" visible="7" size="150" width="100%" />
    </group>
</coll>
```

## Plantilla mappings.xne

```xml
<?xml version="1.0" encoding="iso-8859-15"?>
<xml>
    <app prefix="gen" version="1.0.0" debug="true" default-language="javascript">
        <style url="default.css" />
    </app>
    <collprops type="general">
        <coll name="Empresas"
              progid="ASGestion.CASEmpresa"
              sql="SELECT ID, CODIGO, NOMBRE FROM ##PREF##Empresas"
              objname="Empresas" updateobj="Empresas" loadall="true">
            <group name="General" id="1">
                <prop name="CODIGO" type="N" visible="7" />
                <prop name="NOMBRE" type="T" visible="7" size="150" width="100%" />
            </group>
        </coll>
        <coll name="Usuarios"
              progid="ASGestion.CASUser"
              sql="SELECT ID, CODIGO, NOMBRE, IDEMPRESA, LOGIN, PWD FROM ##PREF##Usuarios"
              objname="Usuarios" updateobj="Usuarios" loadall="true">
            <group name="General" id="1">
                <prop name="CODIGO"     type="N" visible="7" />
                <prop name="NOMBRE"     type="T" visible="7" size="100" width="100%" />
                <prop name="IDEMPRESA"  type="N" visible="7" mapcol="Empresas" mapfld="ID" />
                <prop name="LOGIN"      type="T" visible="7" size="50"  width="100%" />
                <prop name="PWD"        type="X" visible="0" size="100" />
            </group>
        </coll>
    </collprops>
</xml>
```

---

## Convenciones de Nomenclatura

- **Colecciones:** PascalCase (`MenuPrincipal`, `DetalleProducto`)
- **Propiedades de BD:** MAYUSCULAS (`CODIGO`, `NOMBRE`, `IDEMPRESA`, `ROWID`). En la coll `Usuarios` el campo de empresa **DEBE** llamarse `IDEMPRESA` (sin guion bajo) — el framework lo lee literalmente.
- **Propiedades de UI (no persisten):** Prefijo MAP_ (`MAP_BTN_GUARDAR`, `MAP_TOTAL`, `MAP_BUSQUEDA`)
- **Clases CSS:** Prefijo descriptivo (`.frameHeader`, `.btnPrimario`, `.textoTitulo`)
- **Iconos:** snake_case (`ic_home.png`, `ic_add_white.png`)
- **Scripts JS:** camelCase (`inicializarPantalla`, `cargarDatos`, `guardarRegistro`)
