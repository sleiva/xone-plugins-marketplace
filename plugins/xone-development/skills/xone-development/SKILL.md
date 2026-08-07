---
name: xone-development
description: "Desarrollo XOne: XML .xne, JS del runtime, CSS, datos, dispositivo, fundamentos. UI/.xne: colecciones, props/tipos, groups, frames, contents, asfilter, combos mapcol/mapfld, mapas, kanban, chips, layouts, inherits, include-layout, eventos XML, permisos. JS y functions.js: self, selfDataColl, ui, appData, err, user, getControl, métodos de controles, singletons, creables, lock/unlock, startBrowse/endBrowse, objeto ai. CSS: default.css y variantes, clases, selectores coll/prop:TYPE/group/frame, unidades p/%, colores #AARRGGBB, extends/@extend, :root/var(), calc(), @import, temas light/dark, animaciones. Datos: SQL ##PREF##, SqlManager, macros globales, $http TLS/pinning/mTLS, futures, OAuth2, crypto. Dispositivo: GPS, cámara, foto/vídeo, escaneo QR/barcode, firma DR, biometría, Bluetooth, impresión, NFC, DNI electrónico. Fundamentos: app.xml, app.ini, mappings.xne, carpetas bd/icons/files/fonts, macros del sistema, códigos de error, Splash→Login→EntradaApp→Menu, convenciones de nombres."
---

# XOne — Desarrollo (XML, JavaScript, CSS, datos y dispositivo)
Estas son las reglas que aplican a cualquier trabajo sobre un proyecto XOne, sea XML, JavaScript o CSS. **No afirmes nada que no esté en las referencias de esta skill o de las especializadas.** Si una API, atributo o comportamiento no aparece, dilo y pide el dato; no lo deduzcas por analogía con la web ni con otros frameworks.

## Siempre
1. **Consulta la referencia antes de responder.** Cada área tiene su fichero; están indexados abajo y en las skills especializadas.
2. **La fuente es el `.xne`.** Los ficheros `.xml` de colecciones y pantallas son artefactos generados automáticamente por XOneStudio a partir de los `.xne`: no se leen, no se editan, no se consultan. La única excepción es `app.xml`, que sí es fuente. Si conviven `.xne` y `.xml`, trabaja solo sobre los `.xne`.
3. **`progid` es opcional.** Sin él, la coll es un objeto de datos genérico (equivalente a `ASData.CASBasicDataObj`). Solo **Empresas** (`ASGestion.CASEmpresa`) y **Usuarios** (`ASGestion.CASUser`) requieren el suyo para activar su lógica de negocio. No inventes progids. **Conflicto conocido sin resolver:** `xone-simulator` lo marca como error (`COLL_MISSING_PROGID`) pese a ser opcional según lo anterior. No resuelvas la discrepancia por tu cuenta: repórtala y deja la decisión al desarrollador.
4. **Encoding coherente en los `.xne`.** El motor respeta el `encoding` declarado en el prólogo y asume UTF-8 si falta. UTF-8 e iso-8859-15 son válidos; lo que corrompe tildes y eñes es declarar uno y guardar en otro.
5. **`ID` y `ROWID` los gestiona la plataforma.** No hace falta declararlos como `<prop>` (es válido pero redundante). En el `sql=` de la coll, `ID` sí se rescata en el SELECT; `ROWID` no es necesario.
6. **Inicializa con el evento correcto:** `<before-edit>` al abrir para editar, `<create>` la primera vez. `<load>` se dispara **por cada DataObject** al cargar desde la BD (startBrowse, loadAll, `<contents>`) y no se recomienda por rendimiento.
7. **Los nombres son únicos y case-sensitive.** Ver la sección de unicidad más abajo.

## Nunca
1. **No inventes** atributos XML, funciones JavaScript ni propiedades CSS que no estén en las referencias. XOne ignora silenciosamente los atributos desconocidos, así que un invento no da error: da un bug silencioso.
2. **No uses APIs del DOM.** No existen: `document`, `window`, `localStorage`, `sessionStorage`, `XMLHttpRequest`, `navigator`, `history`.
3. **No uses VBScript.** Está descontinuado en XOne aunque alguna referencia histórica lo mencione. La única opción válida es `<script language="javascript">`; si encuentras un ejemplo en VBScript, tradúcelo antes de proponerlo.
4. **No mezcles patrones de React, Angular, Vue** ni de ningún framework web.
5. **No repitas nombres de nodos dentro de la misma colección.**
6. **No uses `<load>`** para inicializar una pantalla: produce bugs silenciosos.

## Sintaxis JavaScript que soporta el motor
**Sí:** `let`, `const`, arrow functions, destructuring, `class` (con `extends`, `super`, `static`, getters/setters, computed keys, field declarations y generator methods con `*`), `Promise` (ES2024 completo: `all`, `allSettled`, `race`, `any`, `withResolvers`, `.then`, `.catch`, `.finally`), generadores con `yield` (runtime estilo SpiderMonkey legacy: `.next()` devuelve el valor directo y `StopIteration`; no `for...of` sobre generadores), `for...of` sobre arrays y strings, `Symbol`, typed arrays.

**No, a nivel de sintaxis:** template literals `` `${x}` ``, `async`/`await`, spread/rest, parámetros por defecto, optional chaining `?.`, nullish coalescing `??`, computed keys en object literals (sí en cuerpo de clase), campos privados `#name`, bloques `static`.

**Sí existen con implementación custom de XOne** (semántica compatible con WHATWG): `fetch(input, init?)` con limitaciones (no admite `Request` como primer argumento, ni body `FormData`/`Blob`/`ReadableStream`, ni cancelación real en vuelo), `setTimeout`/`clearTimeout`/`setInterval`/`clearInterval`/`queueMicrotask`, `URL`/`URLSearchParams`, `Headers`, `AbortController`/`AbortSignal`, `Response`, `EventTarget`, `TextEncoder`/`TextDecoder`, `console` completo (`log`, `info`, `debug`, `warn`, `error`, `trace`, `assert`, `group`, `time`, `table`… con formato `%s`/`%d`/`%j`), `performance.now()`, `atob`/`btoa`, `structuredClone`, `DOMParser`/`XMLSerializer`, `globalThis`.

Aun existiendo, lo idiomático en XOne es `$http` en vez de `fetch`, y `ui.executeActionAfterDelay` en vez de `setTimeout`.

## Unicidad y nombres
- El ámbito de unicidad es la **`<coll>` entera**, no el `<group>` ni el `<frame>`: no puede haber dos `<prop>`, dos `<group>`, dos `<frame>` ni dos eventos con el mismo `name` en ninguna parte de la misma coll, aunque estén en grupos distintos. El `name` se publica a nivel de coll (los `collprops`) y se volvería ambiguo.
- Dos `<coll>` distintas **sí** pueden tener contenido idéntico, siempre que su propio `name` sea distinto. Dos colls con el mismo `name` en el proyecto no son válidas.
- El atributo `name` es **case-sensitive**, y eso aplica a todas las referencias cruzadas: `self.MiNombre`, `mapcol`, `linkedto`, `inherits`, `<field name="...">`, `getControl("...")`, `ui.openEditView("...")`, `appData.getCollection("...")`.
- En cada `<group>`, `id` es obligatorio y único dentro de la coll. Convención habitual: `1`, `2`, `3`… para grupos normales, `999` para HEADER fijo y `0` para FOOTER fijo.
- Prefijo `MAP_`: solo para campos **no persistidos** (UI temporal, JOIN, `linkedto`). El framework excluye `MAP_*` de INSERT y UPDATE. Los campos de BD van sin prefijo.

## Tipos de prop válidos
| Tipo | Descripción |
|---|---|
| `T` | Texto editable |
| `TN` / `TN2`…`TN6` | Texto numérico; el sufijo son los decimales visibles |
| `L` | Etiqueta de solo lectura. Sin `title`, muestra el valor del campo |
| `TL` | Alias legacy de `L` |
| `THTML` | Texto con formato HTML |
| `N` / `N2`…`N6` | Número; el sufijo son los decimales visibles |
| `D` / `DT` / `TT` | Fecha / fecha y hora / solo hora |
| `B` | Botón |
| `NC` | Checkbox, toggle, radio o switch |
| `X` | Password enmascarado |
| `IMG` / `PH` | Imagen referenciada / foto capturable |
| `VD` | Vídeo o escáner QR/barcode |
| `DR` | Dibujo o firma digital |
| `Z` | Contenedor de lista embebida |
| `WEB` | WebView |
| `AT` | Adjunto |
| `O` | Sub-objeto JavaScript, no persiste |

Los combos **no tienen tipo propio**: se hacen con `type="T"` (o `type="N"`) más `mapcol` y `mapfld`. No existen `type="C"`, `"M"`, `"A"`, `"F"`, `"S"`, `"P"`, `"E"`, `"R"`, `"H"`, `"W"`, `"CAM"`, `"ARRAY"`, `"STRING"`, `"N1"` ni `"BT"`.

## Visibilidad
Bitmask de 4 bits: `1` edición · `2` lista · `4` content · `8` combo. Cualquier combinación es válida.

| Valor | Contextos |
|---|---|
| `0` | Ninguno: campo interno, solo para lógica |
| `1` | Solo formulario de edición |
| `2` | Solo lista |
| `3` | Edición + lista |
| `4` | Solo content (lista embebida) |
| `7` | Edición + lista + content — **el más habitual** |
| `8` | Solo combo |
| `15` | Todos |

`visible` es **estático**: no se cambia en runtime, ni por script ni por eventos. Para visibilidad condicional se usa `disablevisible="CAMPO=valor"`, que sí es dinámico.

## Ciclo de vida y eventos
| Necesito | Evento |
|---|---|
| Inicializar la primera vez | `<create>` |
| Inicializar al abrir para editar | `<before-edit>` |
| Ejecutar tras entrar en edición | `<after-edit>` |
| Reaccionar a cada ítem al cargar una colección (no recomendado) | `<load>` |
| Cambio de campo | `<onchange>` + `<field name="CAMPO">` |
| Botón atrás | `<onback>` |

No existen `<unload>`, `<ondelete>`, `<beforedelete>` ni `<afterdelete>`. Para borrado hay `<delete>` con hijos `<rule>`, que es un bloque de reglas, no un evento antes/después. Solo puede haber un `<before-edit>` por coll.

- **No uses `<load>` para inicializar pantallas**: se dispara por cada DataObject cargado. `xone-simulator` lo marca como `ANTIPATTERN_LOAD_EVENT`.
- Solo un `<before-edit>` por coll (`ANTIPATTERN_MULTIPLE_BEFORE_EDIT`).
- En un botón, `onclick` **o** `method="ExecuteNode(...)"`, nunca ambos. Para lógica compleja, `ExecuteNode` y un nodo aparte.
- `onchange="refresh"` o `onchange="refresh(MAP_CAMPO)"`; `refresh255` es notación legacy de PDA.

El **catálogo de eventos** (cuándo dispara cada uno, con qué parámetros) vive con el XML, porque los eventos se declaran en el XML: [eventos de ciclo de vida e interacción](references/xml-ui/eventos-ciclo-de-vida-e-interaccion.md) (`create`, `before-edit`, `after-edit`, `load`, `onclick`, `onchange`, `selecteditem`, `onlongpressitem`, `onback`) y [eventos de sistema, login y personalizados](references/xml-ui/eventos-sistema-login-y-personalizados.md) (drawer, bottom sheet, login, `onpushreceived`, `maintenance`, `sys-message` y sus códigos, ciclo de aplicación, `ExecuteNode` y acciones).

## JavaScript embebido en `.xne`
Para JS no trivial, la forma preferida es declarar la función en un `.js` externo (`functions.js` u otro incluido) y llamarla desde el XML con `miFuncion();`, escribiendo el JS normal, sin entidades ni CDATA. Para snippets cortos inline: dentro de un nodo `<script>` valen tanto entidades XML (`&lt;`, `&gt;`, `&amp;`) como `<![CDATA[…]]>`; dentro de un atributo (`onclick=`, `disablevisible=`) **solo entidades**, porque CDATA no es válido en atributos XML.

## Estructura XML
Capa declarativa de XOne: ficheros `.xne`, jerarquía `coll > group > frame > prop`, `contents`, macros, eventos y permisos. Antes de proponer código, inspecciona los `.xne` y el CSS del proyecto para respetar sus convenciones.

- Jerarquía: `coll > group > frame > prop`. Un `<prop>` vive dentro de un `<group>` o de un `<frame>`.
- Una coll de datos lleva `sql`, `objname` y `updateobj`, y usa `##PREF##` como prefijo de tabla: `sql="SELECT ID, NOMBRE FROM ##PREF##Clientes"`.
- Una pantalla sin datos (menú, login) usa `special="true"` y **no** lleva `sql`. Son excluyentes.
- `<prop>` tiene dos atributos obligatorios: `name` y `type`.
- `notab="true"` cuando solo hay un grupo visible.
- El splash es un **fichero estático en la raíz** (`splash.png`/`.jpg`/`.gif`/`.webp`/`.apng`/`.mp4`/`.3gp`) que carga el framework. No es una `<coll>`, no es `EntradaApp` (pantalla post-login), y no es `load-imgbk` del `<app>` (fondo del EditView).

**Combo y selector.** Un combo **no tiene tipo propio**: son dos props vinculados, uno oculto con el ID y otro visible con la descripción. Para valores fijos sin tabla, `mapcol-values` en el prop oculto. `mapcol` debe apuntar a una coll existente, y `mapfld`/`linkedfield` a campos reales de esa coll: `xone-simulator` lo valida.

**Contents y listas.**

- El `name` del contents lleva prefijo `@`; sin él no vincula.
- `src` es obligatorio y apunta a una coll existente. `filter` y `sort` son opcionales.
- Filtros dinámicos por el objeto padre con `##FLD_CAMPO##`, p. ej. `filter="IDPADRE=##FLD_IDPADRE##"`.
- Un mapa es `type="Z" viewmode="mapview"` vinculado a un `<contents>`, no un tipo inventado.

**Layout.** Los elementos son `newline="true"` por defecto y se apilan. Para ponerlos en la misma fila, `newline="false"` va en el **segundo y siguientes**; el primero de la fila nunca lo lleva. Si el primer elemento de un `<frame>` lleva `newline="false"`, el frame entero puede no montarse y sus controles desaparecen de la pantalla. Dimensiones en `p` o `%`, nunca `px`/`em`/`rem`.

**Macros.** `##PREF##` prefijo de tablas · `##FLD_CAMPO##` valor del campo del objeto padre en un contents · macros del sistema como `##NOW_TIME##`, `##USERID##`, `##DEVICE_OS##`, `##DEVICE_TYPE##`, `##CURRENT_ORIENTATION##`, `##FRAME_VERSION_CODE##`.

Una macro de colección debe declararse en el XML antes de usarla: `<macro name="##NOMBRE##" value="..." default="true" />` como hijo directo de `<coll>`, al mismo nivel que los `<group>`. Sin esa declaración, `setMacro` no inyecta nada en el SQL. La API es `setMacro`/`getMacro`; `coll.macro(...)` no existe.

## JavaScript
JavaScript ejecutado en bloques `<script>` de los `.xne` y en `functions.js`. No es JavaScript de navegador ni de Node: no hay módulos (`require`/`import`) y el código compartido es global. Los LLMs inventan sistemáticamente `self.lock()`, `ui.startChronometer()` y variantes de `setCircularReveal` que no existen.

**Objetos globales.** `self` (DataObject actual, alias `dataobject`) · `selfDataColl` (su colección, alias `datacollection`) · `ui` · `appData` (alias `appdata`) · `err` (alias `error`) · `user`.

Singletons de acceso directo, **sin `new`**: `$http`, `crypto`, `clipboard`, `deviceInfo`, `systemSettings`, `packageManager`, `biometricsManager`, `fingerprintManager`, `bleManager`, `sensorManager`, `paymentManager`, `pushMessage`, `appBroadcastManager`, `replica`, `live`, `smsService`, `serial`, `bluetoothSerial`, `bleSerial`, `ml`, `ai`.

Objetos que se crean con `new` (o `createObject`): `FileManager`, `GpsTools`, `SqlManager`, `IniParser`, `EncodingUtils`, `AndroidIntent`, `DeviceManager`, `WifiManager`, `BluetoothSerialPort`, `OAuth2`, `Worker`, `Animation`, `Socket`, `WebSocket`, `DebugTools`, `IrManager`, `SoundManager`, `VibrationManager`, `WearableConnection`, `AccountManager`, `XOneNFC`, `ImageDrawing`, `BarcodeGenerator`, `XOnePrinter`, `XOnePDF`, `XOneOCR`, `XOneSigner` y los demás de la lista canónica.

**Acceso a datos.** `self.CAMPO`, `self["CAMPO"]` y `self.getValue("CAMPO")` son válidos. **`self("CAMPO")` no existe**: la notación de `self` como función no es parte del motor.

**Controles.** `getControl(name, [dataObject])` es una **función nativa global** del motor (Rhino y V8), no un método de `ui`. Con un solo argumento usa la última ventana visible; con `dataObject`, la ventana asociada a ese objeto. Lanza error si el nombre está vacío, si el control no existe en la ventana destino, si no hay ventana o si el `dataObject` no es válido. Si el proyecto define su propia `function getControl(...)`, esa sombrea a la nativa en su ámbito local.

Los métodos específicos (`getValue`/`setValue`/`setMin`/`setMax`/`setStepSize` de un stepper, `getOtpValue`/`clearOtp`/`focusOtp` de un OTP, `startChronometer`/`stopChronometer`) son métodos **del control**, no de `ui`.

**Patrones críticos.** Modifica colecciones dentro de `unlock()` y devuelve el estado con `lock()` en `finally`. `lock()` activa el modo solo lectura: con la bandera activa, `clear()` y `loadAll()` son no-op. Las colecciones nacen desbloqueadas, pero el convenio es dejarlas bloqueadas tras operar para que código posterior no las mute por accidente.

- `lock()`/`unlock()` son métodos de la **colección**, nunca de `self`. Para bloquear la de un contents: `self.getContents("X").unlock()`.
- Navega con `startBrowse()` y `endBrowse()` en `finally`. Para contents: `getContents(nombre)` → `unlock` → `createObject`/`addItem` → `lock` → `saveAll`. Cierra siempre cursores y conexiones SQL. Un `WaitDialog` abierto va dentro de `try/finally`.
- En callbacks asíncronos (`$http`, WebSocket, GPS) guarda el contexto **antes** de la llamada: `var miSelf = self;`.
- Para crear objetos, el patrón preferido es `new NombreColeccion({ PROP: valor })` (el parámetro es opcional). `coll.createObject()` queda para contents anidados —vincula al padre— o cuando el nombre de la colección es dinámico.

**APIs web y sus equivalentes.**

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

## CSS
Sistema de estilos propietario, con sintaxis parecida a CSS web pero atributos propios. Antes de editar, lee el `default.css` del proyecto y respeta sus convenciones de nombres de clase.

**Archivos.** `default.css` en la raíz del proyecto es obligatorio y es el único que se declara en `app.xml`: `<style url="default.css" encoding="UTF-8" />`. Las variantes se cargan automáticamente por convención de nombre.

Si el atributo `compatibility-mode` del nodo `<app>` vale `true`, **el CSS se ignora por completo** — compruébalo antes de diagnosticar cualquier estilo que «no se aplica».

> El corpus documenta los nombres de variante de dos formas: con guion bajo (`default_night.css`, `default_ios.css`) y con punto (`default.night.css`, `default.ios.css`). Comprueba en el proyecto qué convención está en uso; no asumas una.

**Cascada.** De menor a mayor prioridad: `default.css` → plataforma → orientación → tema → condiciones combinadas → **atributos inline en XML** (máxima prioridad). Lo más específico gana atributo por atributo, no bloque por bloque.

**Selectores.** Solo estos: `coll`, `prop`, `prop:TYPE` (`prop:T`, `prop:N`, `prop:B`, `prop:NC`, `prop:Z`, `prop:IMG`, `prop:D`…), `group`, `frame` y `.clase`. Las clases se asignan con `class="..."` en el XML.

**Unidades.**

- `p` para dimensiones absolutas, `%` relativo al contenedor.
- Sin unidad: `fontsize`, `border-corner-radius`, `border-width`, `labelwidth`, `lines`, `visible`, `gallery-columns`, `img-width`, `img-height`.
- Prohibidas: `px`, `em`, `rem`, `vw`, `vh`, `vmin`, `vmax`.

**Colores.** `#RRGGBB` o ARGB `#AARRGGBB`. **El alpha va primero**, al contrario que el `#RRGGBBAA` de CSS web.

**Herencia.** Dos mecanismos equivalentes: el atributo `extends: .claseBase;` y la at-rule `@extend selector;`. Diferencia relevante: `@extend` detecta ciclos en tiempo de parseo (auto-referencia, 2 vías y N vías) y admite referencias adelantadas; `extends:` no detecta ciclos automáticamente. En un proyecto que ya usa `extends:`, mantén `extends:` por consistencia.

**Funciones del parser.**

**Sí soportadas:** comentarios `/* */` y `//`; `@import "ruta";` (solo al inicio del archivo); variables CSS en `:root` o locales de bloque, con `var(--nombre)` y `var(--nombre, fallback)`; `calc()` con `+ - * /`, paréntesis y `-` unario sobre números puros; `!important`; `!default`; selectores múltiples `a, b, c { }`.

**No soportadas:** `min()`, `max()`, `clamp()`, `@media`, pseudo-clases (`:hover`, `:focus`, `:active`, `:nth-child`), pseudo-elementos (`::before`, `::after`), selectores de atributo (`[data-attr]`), combinadores (`>`, `+`, `~`, descendiente), `transition`, `transform`, Flexbox, CSS Grid, `box-shadow`, `text-shadow` y gradientes.

Para sombras usa `elevation` y `shadow-color`. No hay abreviados `margin` ni `padding`: usa `tmargin`, `bmargin`, `lmargin`, `rmargin` y sus equivalentes `*padding`.

**Estilos dinámicos.** No existe selector condicional puro. Dos vías: tokens `##FLD_CAMPO##` en el valor (funcionan en CSS y en atributos inline XML) y cambio de clase desde JavaScript en tiempo de ejecución.

Si un estilo no se aplica, empieza por `compatibility-mode`; el resto de síntomas está en la skill `xone-debugging`.

## Datos e integración
**Modelo local.** La BD es `gestion.db`, normalmente bajo `bd/`, y las tablas suelen llevar prefijo `gen_` en minúsculas. Usa siempre `##PREF##`, nunca el prefijo literal. Cada registro replicable tiene `ROWID` como GUID hexadecimal de 32 caracteres sin guiones, declarado `type="T" fieldsize="32"`. Las colecciones con `objname`/`updateobj` generan tabla; si falta, regenera con `xone-db-tools create-db mi_proyecto --overwrite`. Instala la herramienta con `npm install -g xone-db-tools`.

Macros habituales: `##PREF##`, `##ENTID##`, `##USERID##`, `##NOW##`, `##NOW_DATE##`, `##NOW_TIME##`, `##FLD_CAMPO##`. Guarda y restaura filtros con `try/finally` y limpia la colección antes de recargar.

**Seguridad.**

- Parametriza SQL: `sqlManager.doRawQuery("… WHERE ID=?", id)`. Nunca concatenes entrada de usuario. Si un filtro exige texto, escapa `'` como `''`; valida los numéricos antes de concatenar.
- Cierra cursor y conexión en `finally`.
- HTTPS siempre, con `allowUnsafeCertificates: false` en producción. Pinning con `enablePinning`/`allowedRootCas`; mTLS con `privateKey`/`certificateChain`.
- No hardcodees ni registres credenciales. Cifra los tokens antes de guardarlos en macros globales y límpialos al cerrar sesión.
- Valida obligatorios, longitud, rangos y formato antes de `save()`: un obligatorio vacío produce `-8100`.

**Integración y réplica.** `$http` devuelve respuestas string y futures cancelables: parsea con `try/catch`, preserva `self` antes del callback y cancela la búsqueda anterior antes de lanzar otra. OAuth2 se usa con `new OAuth2()`. `replica.processReplicatorQueue` sincroniza por `ROWID`; la configuración programada vive en el evento `maintenance` de `Empresas`. El error `-11888` con `##EXIT##` cierra la pantalla y con `##EXITAPP##` cierra la aplicación.

Para almacenamiento clave-valor, el equivalente de `localStorage` es `appData.setGlobalMacro`/`getGlobalMacro`; para datos de sesión, variables de colección (`setVariable`/`getVariable`).

Los **eventos** implicados en la sincronización y el provisionamiento (`maintenance`, `sys-message` con sus códigos detallados, eventos de réplica) están documentados en [eventos de sistema, login y personalizados](references/xml-ui/eventos-sistema-login-y-personalizados.md), porque se declaran en el XML.

Para probar integraciones sin backend, usa `mock/http.json` con `xone-simulator` (skill `xone-review`).

## Dispositivo
`xone-simulator` reproduce muchas capacidades con `mock/device.json` (skill `xone-review`).

- Pide y comprueba permisos antes de GPS, cámara, micrófono o biometría. Los permisos se solicitan con `systemSettings.requestPermissions`, que devuelve un future. En el simulador se conceden automáticamente.
- Declara los permisos que use la app en el nodo `<permissions>`: `location-foreground`, `location-background`, `camera`, `notifications`, `contacts`…
- GPS: `ui.startGps()` antes de leer la colección de GPS; recórrela con `startBrowse`/`endBrowse`, comprueba `STATUS == 1` y que `LONGITUD` no esté vacío. `ui.checkGpsStatus()` devuelve `0` sin hardware, `1` solo GPS, `2` solo redes, `3` ninguno y `4` GPS y redes.
- La colección de GPS (`GPSColl`/`GpsCollection`) **la declara el proyecto** con el connector GPS: no es built-in de XOne.
- En callbacks de cámara, GPS y escáner conserva `self` antes de la operación y refresca solo los campos modificados.
- Cierra Bluetooth y WebSocket al terminar. Prefiere `ui.executeActionAfterDelay()` (segundos) a una espera bloqueante.
- `biometricsManager` es el singleton actual; `fingerprintManager` es legacy.
- La firma se hace con `<prop type="DR">` (`stroke-color`, `stroke-width`, `apply-format-to-file`, `ui.saveDrawing`, `ui.clearDrawing`). `type="IMG" readonly="false"` es la forma **obsoleta**.
- En archivos, comprueba `fileExists(...) === 0`; `saveFile(..., false)` sobrescribe.

Del registro de GPS se leen `LATITUD`, `LONGITUD`, `ALTITUD`, `VELOCIDAD`, `RUMBO`, `FGPS`, `HGPS`, `STATUS`, `SATELITES`, `FUENTE`, `PRECISION` y el campo `FAKE`. Para cálculos hay `GpsTools` (`distanceBetweenCoordinates`, `getPositionFromAddress`, encode/decode, `simplifyPolyline`, `addExifLocationToFile`, `routeTo`).

Los métodos de los controles de cámara, vídeo, dibujo y escáner están en [métodos de los controles](references/javascript/metodos-de-los-controles.md). Los atributos XML de esos props, en [atributos-prop.md](references/xml-ui/atributos-prop.md).

## Anti-patrones
### XML
| Incorrecto | Correcto |
|---|---|
| `<prop type="C">` (combo) | `type="T"` + `mapcol` + `mapfld` |
| `<prop type="M">` (mapa) | `type="Z" viewmode="mapview"` |
| `<prop type="A">` (autocomplete) | `type="T"` + `mapcol` + `mapfld` + `linkedfield` |
| `<prop type="IMG" readonly="false">` (firma obsoleta) | `<prop type="DR">` |
| `<prop type="L" labelwidth="0" title="X">` | `<prop type="L" title="X" label-align="center">` — con `labelwidth="0"` el título se pinta en un ancho de cero |
| `<prop type="L" title="...">` esperando que muestre el valor que actualiza el JS | `<prop type="L">` **sin `title`**: el label usa el valor del campo como fallback |
| `newline="false"` en el primer elemento de un frame | Solo en el segundo y siguientes |
| `<prop name="PASSWORD" type="X">` en Usuarios | `<prop name="PWD" type="X">` — el framework lo lee literalmente |
| `<prop name="ID_EMPRESA">` en Usuarios | `<prop name="IDEMPRESA">` — sin guion bajo |
| Dos `<group id="1">` en la misma coll | `id` único por coll |
| Dos `<prop name="X">` en la misma coll, aunque estén en grupos distintos | `name` único en la coll entera |
| `special="true"` junto con `sql` | Son excluyentes |
| Contents sin prefijo `@` | `contents="@MiContent"` |
| `loadall="true"` en tablas grandes | Carga bajo demanda |
| Mezclar `onclick` y `method` en un botón | Uno u otro |

### JavaScript: APIs y patrones
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
| `ui.setBlur(...)` / `ui.setSaturation(...)` | No son de `ui` ni de XOne: los expone la **vista nativa** que hay debajo. Se llaman sobre el frame o el control — `ui.getView(self)["mi_frame"].setBlur(8)`. Ver [métodos nativos de la vista](references/javascript/metodos-nativos-de-la-vista.md) |
| `GpsCollection` como colección built-in | La declara el proyecto con connector GPS |
| Variantes de `setCircularReveal` (Show/Hide, setXY, growAndShrink) | Solo existe `setCircularReveal(cx, cy, bReveal)` |

### JavaScript: creación de objetos
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

### CSS
| Incorrecto | Correcto |
|---|---|
| `font-size: 14px` | `fontsize: 14` |
| `bg-color: #FFF` | `bgcolor: #FFFFFF` |
| `#00000080` (alpha al final) | `#80000000` (ARGB) |
| `margin: 10p` | `tmargin: 10p; bmargin: 10p; …` |
| `div.header { }` | `.header { }` |
| Duplicar atributos entre clases | `extends: .base;` y sobrescribir |
| `display: none` | `visible` (bitmask) |
| `box-shadow` | `elevation` + `shadow-color` |

### Datos
| Incorrecto | Correcto |
|---|---|
| `gen_` literal en XML o SQL portable | `##PREF##` |
| SQL concatenado con entrada externa | Parámetros `?` |
| Cursor o conexión sin cerrar | `finally` |
| `allowUnsafeCertificates: true` en producción | Verificación TLS |
| Token en claro en logs o macros | Cifrado, limpieza y sin logging |

### Dispositivo
| Incorrecto | Correcto |
|---|---|
| Leer GPS sin iniciarlo ni pedir permiso | `startGps` + `checkGpsStatus` + permiso |
| Aceptar cualquier coordenada | `STATUS == 1` y longitud válida |
| `fingerprintManager` en código nuevo | `biometricsManager` |
| Bloquear la UI esperando | `ui.executeActionAfterDelay` |
| Dejar conexiones abiertas | `disconnect`/`close` al salir |
| Asumir que el simulador tiene datos de hardware | Configurar `mock/device.json` |

## Referencias
Lee el fichero que corresponda antes de responder sobre atributos concretos, valores admitidos o ejemplos.

### Fundamentos
- [fundamentos/plataforma-y-anatomia-de-proyecto.md](references/fundamentos/plataforma-y-anatomia-de-proyecto.md) — Qué es XOne, arquitectura, ciclo de vida colección/objeto/propiedad, sincronización, anatomía de carpetas y tipos de fichero
- [fundamentos/configuracion-app-xml-ini-mappings.md](references/fundamentos/configuracion-app-xml-ini-mappings.md) — `app.xml` atributo por atributo, `app.ini` y `mappings.xne`
- [fundamentos/conceptos-clave.md](references/fundamentos/conceptos-clave.md) — Colecciones, DataObject, props, `##PREF##`, macros del sistema, códigos de error y detalle de la sintaxis JS soportada
- [fundamentos/navegacion-convenciones-y-primer-proyecto.md](references/fundamentos/navegacion-convenciones-y-primer-proyecto.md) — Flujo Splash→Login→EntradaApp→Menu, convenciones de nombres y creación de un proyecto básico paso a paso
- [fundamentos/errores-comunes.md](references/fundamentos/errores-comunes.md) — Errores frecuentes al empezar y su corrección

### XML / UI
- [xml-ui/estructura-y-nodo-coll.md](references/xml-ui/estructura-y-nodo-coll.md) — Introducción a la UI y nodo `coll`: colecciones de datos vs especiales, valores de `progid`, `sql`, `loadall`
- [xml-ui/nodos-group-y-frame.md](references/xml-ui/nodos-group-y-frame.md) — `group` (fijos, drawer, tabs) y `frame` (flotantes, bottom sheet, flujo de layout y `newline`)
- [xml-ui/prop-atributos-y-condiciones.md](references/xml-ui/prop-atributos-y-condiciones.md) — Atributos comunes de `prop`, visibilidad completa, dimensiones, estilos inline, comportamiento, bordes, `disablevisible`/`disableedit`
- [xml-ui/prop-tipos-basicos.md](references/xml-ui/prop-tipos-basicos.md) — Props de texto, número, label, botón, checkbox, fecha/hora, imagen, foto, vídeo y escáner
- [xml-ui/prop-tipos-listas-y-mapas.md](references/xml-ui/prop-tipos-listas-y-mapas.md) — Props de mapa, grid/lista, chips, kanban y coverflow
- [xml-ui/prop-tipos-combos-y-controles.md](references/xml-ui/prop-tipos-combos-y-controles.md) — Combos, web, slider, progress, stepper, OTP, markdown, navbar, password, adjunto, THTML, firma DR, `onchange`, `updates` y `formula`
- [xml-ui/contents-y-macros.md](references/xml-ui/contents-y-macros.md) — `contents` (vinculación, filtros dinámicos) y macros (sistema, `setMacro`/`getMacro`)
- [xml-ui/asfilter-visibilidad-eventos-y-macros.md](references/xml-ui/asfilter-visibilidad-eventos-y-macros.md) — `asfilter`, event handlers detallados, sistema de visibilidad y catálogo de macros del sistema
- [xml-ui/patrones-de-pantalla.md](references/xml-ui/patrones-de-pantalla.md) — Plantillas completas de pantalla: login, menú, lista con filtros, detalle, tabs, mapa, chat, dashboard, maestro-detalle, edición en línea, multi-selección
- [xml-ui/layouts-herencia-y-buenas-practicas.md](references/xml-ui/layouts-herencia-y-buenas-practicas.md) — Layouts responsive, modales, FAB, herencia con `inherits`, `include-layout`, checklist de validación y unicidad de nombres
- [xml-ui/atributos-coll-group-frame.md](references/xml-ui/atributos-coll-group-frame.md) — Cualquier atributo de `coll`, `group` o `frame` con tipo, valores y default
- [xml-ui/atributos-prop.md](references/xml-ui/atributos-prop.md) — Cualquier atributo de `prop`: colores por estado, bordes, entrada, multimedia, ML, `classid`, sliders, stepper, OTP, kanban, coverflow, chips
- [xml-ui/atributos-method-macro-script-event-app.md](references/xml-ui/atributos-method-macro-script-event-app.md) — Atributos de `method`, `macro`, `script`, `event`, `platform`, tipos y atributos globales de la app
- [xml-ui/mappings-y-colecciones-separadas.md](references/xml-ui/mappings-y-colecciones-separadas.md) — `mappings.xne` obligatorio y colecciones en archivos separados
- [xml-ui/mapas.md](references/xml-ui/mapas.md) — Mapas completos: atributos, eventos y API JavaScript del control
- [xml-ui/eventos-ciclo-de-vida-e-interaccion.md](references/xml-ui/eventos-ciclo-de-vida-e-interaccion.md) — Catálogo de eventos: ciclo de vida e interacción (`onclick`, `onchange`, `selecteditem`, `onlongpressitem`, `onback`)
- [xml-ui/eventos-sistema-login-y-personalizados.md](references/xml-ui/eventos-sistema-login-y-personalizados.md) — Eventos de drawer y bottom sheet, login, sistema (`onpushreceived`, `maintenance`, `sys-message`), ciclo de aplicación, inactividad, personalizados con `ExecuteNode` y acciones
- [xml-ui/errores-comunes-xml.md](references/xml-ui/errores-comunes-xml.md) — Errores comunes de XML y su corrección

### JavaScript
- [javascript/motor-js-y-contexto-de-ejecucion.md](references/javascript/motor-js-y-contexto-de-ejecucion.md) — Motor JS, cómo se ejecuta desde eventos XML, diferencias con JS web, ámbitos y persistencia de variables, escape XML/CDATA en `.xne`
- [javascript/self-y-dataobject.md](references/javascript/self-y-dataobject.md) — `self`: campos, `getOldValue`, `getOwnerCollection`, `getContents`, `setFieldPropertyValue`, `executeNode`, `save`, JSON y métodos de `DataCollection`
- [javascript/ui-navegacion-mensajes-y-vista.md](references/javascript/ui-navegacion-mensajes-y-vista.md) — `ui`: navegación, `msgBox`/`showToast`/`showSnackbar`, refresco y acceso a controles, showcase, date/time pickers
- [javascript/ui-gps-camara-y-multimedia.md](references/javascript/ui-gps-camara-y-multimedia.md) — `ui`: GPS completo, cámara, archivos, firma, escáner QR, sleep y timers
- [javascript/ui-catalogo-de-metodos.md](references/javascript/ui-catalogo-de-metodos.md) — `ui`: `executeActionAfterDelay`, cronómetros, API de Stepper y OTP, voz (TTS/STT), audio y catálogo completo de métodos
- [javascript/coleccion-error-y-usuario.md](references/javascript/coleccion-error-y-usuario.md) — API completa de la colección actual (browse, filtros, búsqueda full-text, macros, metadatos, SQL, JSON), objeto de error y usuario logueado
- [javascript/objetos-creables-a-m.md](references/javascript/objetos-creables-a-m.md) — Creables de FileManager a Animation (SqlManager, IniParser, AndroidIntent, Bluetooth, OAuth2, Worker)
- [javascript/objetos-creables-n-z.md](references/javascript/objetos-creables-n-z.md) — Creables de Socket a XOneSigner (NFC, ImageDrawing, BarcodeGenerator, XOnePrinter, XOnePDF, OCR) y la lista canónica completa
- [javascript/singletons-globales.md](references/javascript/singletons-globales.md) — API de cada singleton global
- [javascript/patrones-criticos-seguridad-y-rendimiento.md](references/javascript/patrones-criticos-seguridad-y-rendimiento.md) — Patrones críticos (lock/unlock, browse, filter/restore, contexto en callbacks), seguridad y rendimiento
- [javascript/plantillas-y-funciones-utilitarias.md](references/javascript/plantillas-y-funciones-utilitarias.md) — Plantillas completas: CRUD, filtrado, maestro-detalle, GPS, fotos, chat, QR, login; y utilidades para `functions.js`
- [javascript/debugging-y-best-practices.md](references/javascript/debugging-y-best-practices.md) — Debugging de JavaScript y top 20 de buenas prácticas
- [javascript/metodos-de-los-controles.md](references/javascript/metodos-de-los-controles.md) — Métodos que expone cada control por tipo: campos, numéricos, multimedia, listas, mapas, gráficas, AR, frames
- [javascript/metodos-nativos-de-la-vista.md](references/javascript/metodos-nativos-de-la-vista.md) — Métodos que expone la vista nativa de Android/iOS bajo el frame o el control, no XOne: `setBlur`, `setSaturation`, sin contrato de compatibilidad
- [javascript/patrones-de-navegacion-datos-y-codigo.md](references/javascript/patrones-de-navegacion-datos-y-codigo.md) — Patrones de navegación, de datos y patrones críticos de código
- [javascript/patrones-de-ui-voz-integracion-y-seguridad.md](references/javascript/patrones-de-ui-voz-integracion-y-seguridad.md) — Patrones de UI, control por voz, integración y seguridad
- [javascript/objeto-ai-llm-en-dispositivo.md](references/javascript/objeto-ai-llm-en-dispositivo.md) — Objeto `ai`: LLM en el dispositivo, descarga de modelos, `generate`, `chat` con streaming, function calling, skills y formatos

### CSS
- [css/selectores-unidades-colores.md](references/css/selectores-unidades-colores.md) — Selectores en detalle, unidades, paletas y formatos de color
- [css/propiedades-y-herencia.md](references/css/propiedades-y-herencia.md) — Atributos por categoría con ejemplos largos (dimensiones, márgenes, padding, fuentes, texto, fondo, bordes, sombras, visibilidad, Material) y el sistema `extends` completo
- [css/atributos-por-categoria.md](references/css/atributos-por-categoria.md) — Tablas compactas de atributos por categoría, incluidas etiquetas, checkbox/toggles, imágenes e iconos, atributos de `coll`, machine learning y la tabla de transparencia alpha
- [css/dinamicos-cascada-y-componentes.md](references/css/dinamicos-cascada-y-componentes.md) — `##FLD_CAMPO##`, cascada de dispositivo, `strict-mode`, animaciones y tokens, gráficos, calendario y mapa
- [css/patrones-material-y-temas.md](references/css/patrones-material-y-temas.md) — Patrones Material (header/body/footer, botones, inputs, tarjetas, FAB, toolbar, item de lista), temas light/dark y un `default.css` + `colors.css` completos y comentados
- [css/buenas-practicas-y-parser.md](references/css/buenas-practicas-y-parser.md) — Buenas prácticas, anti-patrones, checklist de validación y detalle de las funciones del parser (`@import`, variables, `calc()`, `!important`, `!default`, `@extend`, modo estricto)

### Datos e integración
- [datos/appdata.md](references/datos/appdata.md) — `appData` completo: colecciones, login/logout, paso de datos entre pantallas, macros globales, SQL directo, detección de dispositivo, `loadIncludeFile` y `loadCssFile`
- [datos/http.md](references/datos/http.md) — `$http`: verbos, descarga de fichero, futures y llamadas en paralelo, TLS y mutual TLS, pinning, proxy y WebSocket
- [datos/oauth2-y-replica.md](references/datos/oauth2-y-replica.md) — OAuth2 completo y objeto `replica`
- [datos/appdata-referencia-ampliada.md](references/datos/appdata-referencia-ampliada.md) — Segunda redacción del corpus para `appData`, con ejemplos adicionales
- [datos/http-sqlmanager-y-crypto.md](references/datos/http-sqlmanager-y-crypto.md) — Segunda redacción para `$http`, más `SqlManager` y la API `crypto`

### Dispositivo
- [device/objetos-de-dispositivo.md](references/device/objetos-de-dispositivo.md) — FileManager, XOnePDF, XOnePrinter, BarcodeGenerator, Datawedge, XOneNFC, XOneOCR, BluetoothSerialPort, WifiManager, Animation, deviceInfo, GpsTools, OAuth2, WebSocket y fingerprintManager
- [device/systemsettings-y-permisos.md](references/device/systemsettings-y-permisos.md) — `systemSettings`: permisos en runtime con futures, brillo, red, batería, memoria y espacio, hardware, rutas, MDM, XOneLive e Intune
- [device/systemsettings-referencia-ampliada.md](references/device/systemsettings-referencia-ampliada.md) — Segunda redacción del corpus para `systemSettings`, más extensa
- [device/biometria-imagedrawing-y-otros.md](references/device/biometria-imagedrawing-y-otros.md) — `biometricsManager`, `ImageDrawing`, otros objetos utilitarios y tabla resumen de complementarios

Para crear un proyecto completo desde cero, `xone-project-generator`. Para validar y auditar el XML resultante, `xone-review` (`xone-simulator validate`); para diagnosticar un fallo a partir de su síntoma, `xone-debugging`.
