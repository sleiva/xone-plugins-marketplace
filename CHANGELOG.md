# Changelog

Todos los cambios visibles de `xone-development` se registran aquí. Formato basado en [Keep a Changelog](https://keepachangelog.com/) y [SemVer](https://semver.org/).

## [1.3.0] - 2026-08-07

### Añadido

- `references/javascript/metodos-nativos-de-la-vista.md`: los métodos que actúan sobre la **vista nativa** —`View` en Android, `UIView` en iOS— bajo el frame y el control. Valen igual para uno que para otro, porque lo que hay debajo es una vista en ambos casos. **12 métodos** en una sola tabla: efectos y estilo (`setBlur`, `setSaturation`, `setOpacity`, `setTintColor`, `setShadow`), transformaciones (`setScale`, `setRotation`, `setTranslate`, `resetTransform`) y orden de capas (`setZIndex`, `bringToFront`, `sendToBack`).
- Cada entrada declara **en qué plataforma se ha confirmado**, porque la disponibilidad no es general: los doce constan en Android e iOS, y `setBlur`/`setSaturation` exigen además **iOS 17+**. Se anotan los comportamientos que el nombre no anticipa: las transformaciones **acumulan** en vez de reemplazar, y la sombra no se ve si la vista recorta su contenido.
- El fichero lleva escrita su regla de admisión —una entrada entra solo si se ha confirmado funcionando, anotando la plataforma— y una sección de **pendiente de confirmar**, explícitamente no utilizable, con `setCornerRadius`, `setVisible`/`hide`/`show` y el estado de Android. No enumera la API de vistas de Android ni de iOS: esa lista no pertenece a este repositorio. Diseño en `docs/superpowers/specs/2026-08-07-metodos-nativos-de-la-vista-design.md`.

### Cambiado

- La frontera de capa queda marcada en los tres sitios por donde se llega: el índice de `xone-development`, la fila de anti-patrones de `setBlur` y el §8 (Frames) de `metodos-de-los-controles.md`, que ahora declara que todo lo suyo es API de XOne.
- `ui-navegacion-mensajes-y-vista.md` deja de duplicar los envoltorios `doBlurEffect`/`doSaturationEffect` y remite al fichero nuevo, según el invariante de que una regla se escribe una sola vez.

## [1.2.2] - 2026-08-07

### Corregido

- La `description` de `xone-development` tenía 1197 caracteres y el límite del formato son 1024, así que la skill no validaba. Recortada a 998. Se eliminaron términos cubiertos por otros más amplios (`geolocalización` ⊂ `GPS`; `WifiManager`/`FileManager` ⊂ `creables`), genéricos (`errores estructurales`, `estilos dinámicos`) o que ya dispara otra skill (`pantallas vacías`, en `xone-debugging`). Las otras tres skills estaban dentro de límite: 321, 436 y 465.

## [1.2.1] - 2026-08-07

### Corregido

- El anti-patrón de `setBlur`/`setSaturation` en `xone-development` decía que son «funciones que implementa el proyecto» y no daba la forma correcta. No son de XOne ni las implementa el proyecto: **las expone la vista nativa de Android/iOS** que hay por debajo, y llegan al JS a través del objeto que devuelve la ventana —`ui.getView(self)["mi_frame"].setBlur(8)`—. El proyecto solo escribe el envoltorio (`doBlurEffect`). La fila nombraba la cosa equivocada y, al enunciarse solo en negativo, hacía que una búsqueda por `setBlur` se leyera como «no existe».
- El comentario de `references/javascript/ui-navegacion-mensajes-y-vista.md` se contradecía en dos líneas seguidas: primero decía que eran métodos del control y después que eran funciones de proyecto. Queda una sola versión.

## [1.2.0] - 2026-08-04

### Añadido

- Integración con [`xone-db-tools`](https://www.npmjs.com/package/xone-db-tools) para generar, validar y describir bases de datos XOne.
- `xone-review` valida `bd/gestion.db` con `xone-db-tools` cuando el proyecto incluye una base local.

### Cambiado

- Se sustituyeron todas las referencias al generador anterior por `xone-db-tools create-db`.
- La documentación refleja el contrato del generador: tablas en minúsculas con prefijo `gen_` y campos en mayúsculas.

## [1.1.0] - 2026-08-04

Primera versión de la serie 1.x: el plugin se declara estable en su forma —cuatro skills, una puerta de conocimiento— aunque las pruebas de activación real siguen pendientes (ver `docs/TODO.md`). El trabajo de esta entrada se hizo el 2026-08-03 y se publicó al día siguiente.

De nueve skills a cuatro: una puerta de conocimiento (`xone-development`) más tres de procedimiento (`xone-project-generator`, `xone-review`, `xone-debugging`).

### Cambiado

- `xone-xml-ui`, `xone-javascript`, `xone-css`, `xone-data-integration` y `xone-device` se fusionan en `xone-development`, cuya carpeta `references/` pasa a estar organizada en subcarpetas por área (`fundamentos/`, `xml-ui/`, `javascript/`, `css/`, `datos/`, `device/`; 54 ficheros en total). Las tareas de XOne llegan cruzadas —una pantalla es `.xne` más evento más CSS— y con activación automática el caso a cubrir era que el agente abriese una sola puerta y escribiera el resto de memoria.
- Invariante nuevo: una regla se escribe una vez, en la puerta de conocimiento; las skills de procedimiento la referencian, no la repiten. `xone-review` pierde su lista de anti-patrones y sus reglas por capa; `xone-debugging` deja de repetir las reglas de `load`, `lock`/`unlock` y `MAP_`; las «Prohibiciones explícitas» de `xone-project-generator` que coincidían con reglas del corpus pasan a ser un puntero a la puerta. El conflicto conocido `progid`/`COLL_MISSING_PROGID` (documentación vs. validador `xone-simulator`) pasa a vivir solo en `xone-development`, no en `xone-review`.
- La consolidación de fronteras entre skills (`docs/ARCHITECTURE.md` §13.4, `docs/TODO.md` tarea 7) queda cerrada con la opción de cuatro puertas, decidida sin esperar a las pruebas de activación real (tarea 6): el peor caso de la taxonomía por área solo se evita con una puerta única de conocimiento.

### Añadido

- `AGENTS.md` en la raíz para el descubrimiento de skills desde Codex. Comprobado empíricamente con `codex-cli 0.146.0`: enumera las cuatro skills exactas con el fichero presente, y una ejecución de control sin él devuelve una respuesta contaminada de cinco skills.
- Cuatro comprobaciones nuevas en `scripts/validate-skills.sh`: descubrimiento recursivo de referencias en subcarpetas por área; techo propio de 400 líneas para el `SKILL.md` de la puerta de conocimiento; un parseo YAML real del frontmatter (se añadió tras detectar que un `SKILL.md` fusionado se publicó con un frontmatter sintácticamente inválido, que hace que la skill cargue sin `name` ni `description`); y un guardián de duplicados por solape de tokens (no por marcador literal — tras la fusión no queda duplicación byte-idéntica, solo paráfrasis) con una allowlist corta de 8 excepciones documentadas.
- Una quinta comprobación: enlaces relativos dentro de los propios ficheros de `references/`, no solo los que `SKILL.md` hace hacia ellos. Motivada por una regresión real (ver «Corregido»).

### Corregido

- Los 54 ficheros de referencia movidos a subcarpetas por área en la fusión llevaban el enlace de cabecera `[../SKILL.md](../SKILL.md)`, que dejó de resolver al añadirse un nivel de profundidad. Corregidos a `../../SKILL.md`. Ningún check existente lo detectaba porque ninguno miraba enlaces dentro de los propios ficheros de referencia (ver «Añadido»).

## [0.10.0] - 2026-08-03

Reconstrucción de la capa de referencias. Hasta 0.9.0 las skills resumían el corpus de XOne en prosa; a partir de esta versión las referencias contienen el material original troceado, con su procedencia declarada. Ver [`docs/ANALISIS.md`](docs/ANALISIS.md) para el diagnóstico completo.

### Añadido

- 70 ficheros de referencia (1,3 MB) extraídos del corpus de `xone/`, troceados por secciones completas en piezas de 5-33 KB para que cada lectura sea asequible en contexto. Cada chunk declara su origen en la cabecera (`Fuente: xone/<ruta> §N`).
- La fuente canónica `xone/` pasa a estar versionada en git: las reglas de las skills son ahora trazables a su origen (niveles de evidencia de `ARCHITECTURE.md` §7.1).
- Comando `/xone-validate`: valida un proyecto con `xone-simulator` y corrige iterativamente, sin inventar arreglos.
- Objeto `ai` (LLM local en el dispositivo) documentado como referencia de `xone-javascript`; antes no tenía sitio en la taxonomía.
- Reglas críticas del corpus que las skills no recogían: la fuente son los `.xne` y los `.xml` de colecciones son artefactos generados por XOneStudio; `progid` es opcional; unicidad de nombres en el ámbito de la coll entera; `name` case-sensitive en todas las referencias cruzadas; `id` de `group` obligatorio y único; prohibición de VBScript; `ID`/`ROWID` los gestiona la plataforma; declaración del nodo `<macro>` antes de `setMacro`; `executeActionAfterDelay` en segundos.

### Corregido

- `xone-css` afirmaba que XOne no soporta variables CSS ni `calc`. El parser **sí** soporta `:root`/`var()` con fallback y anidamiento, `calc()`, `@import`, `@extend`, `!important` y `!default`.
- `xone-css` daba `extends:` y `@extend` como equivalentes: solo `@extend` detecta ciclos en tiempo de parseo y admite referencias adelantadas.
- `xone-development` describía el subconjunto de JavaScript de forma vaga y hedged. Ahora distingue lo soportado a nivel de sintaxis (`let`, `const`, arrow functions, `class`, `Promise` ES2024, generadores, `for...of`, `Symbol`) de lo no soportado (template literals, `async`/`await`, spread/rest, parámetros por defecto, optional chaining, `??`, campos privados) y de lo que existe con implementación custom (`fetch`, `setTimeout`, `console` completo, `URL`, `AbortController`).
- La tabla de visibilidad omitía el bit `8` (combo) y el valor `15`. Son 4 bits.
- `xone-device` documentaba la firma con `type="IMG"`, que el corpus marca como obsoleta: es `type="DR"`.
- `xone-javascript` afirmaba que `console` solo ofrece `console.log()`; la API `console` es completa.
- `xone-project-generator` tenía 4 enlaces a referencias que nunca existieron (`contextual-index.md`, `anti-patterns.md`, `tech-reference.md`) y uno a `workflow.md`, ahora troceado.
- `scripts/validate-skills.sh` enumeraba una lista fija de 9 skills sobre un plugin que distribuía 10, y no comprobaba enlaces. Ahora descubre las skills desde el sistema de ficheros y valida que todo enlace resuelva y que ninguna referencia quede huérfana.

### Eliminado

- Los ficheros de resumen deducidos (`api.md`, `examples.md`, `troubleshooting.md`, `reference.md`) de `xone-javascript`, `xone-device`, `xone-data-integration`, `xone-css` y `xone-debugging`. Eran listas de nombres de API sin firmas ni valores: permitían saber que un método existe pero no cómo se llama, lo que aumenta la confianza del modelo sin aumentar su exactitud.
- `xone-development/references/fundamentals.md`: 108 KB que se distribuían en el plugin sin que ningún `SKILL.md` los enlazara.
- `xone-project-generator/references/workflow.md`: 267 KB en un solo fichero, imposible de leer sin agotar el contexto. Sustituido por 13 chunks.

### Cambiado

- La `description` de `xone-development` era la unión literal de las otras ocho skills, así que capturaba casi cualquier consulta de XOne sin derivar a la especializada. Ahora cubre solo fundamentos y estructura de proyecto.
- Cada `SKILL.md` pasa a ser reglas ancladas al corpus más un índice de navegación «para responder X, lee Y».
- Las skills instruyen explícitamente a no afirmar nada que no esté en las referencias y a declarar la incertidumbre en vez de deducir.
- Donde el corpus se contradice (nombres de las variantes CSS con guion bajo o con punto), las skills declaran la discrepancia en lugar de elegir por su cuenta.
- **`xone-verification` se fusiona en `xone-review`** (de 10 skills a 9). Envolvían el mismo CLI con el mismo bloque de comandos y describían el mismo bucle validar → corregir → smoke; sus descripciones disparaban con lo mismo. La duplicación ya había divergido: las dos repetían las reglas de sintaxis JavaScript y las dos estaban mal igual. La skill resultante cubre precondiciones del CLI, los cuatro comandos, los códigos del validador, la revisión por capas, la checklist y las severidades.
- `xone-review` contradecía el corpus en cinco puntos, ya corregidos: daba `progid` por obligatorio (ahora declara el conflicto entre el linter y la documentación), limitaba `visible` a `0-7`, pedía «sintaxis ES5, preferir `var`» cuando el motor soporta `let`/`const`/`class`/`Promise`, listaba `Promise` entre las APIs inexistentes y marcaba `setTimeout` y `fetch` como errores.

## [0.9.0] - 2026-08-03

### Añadido

- Skill `xone-review`: proceso de revisión de código XOne. Flujo validación automatizada + smoke + revisión por capas (XML/UI, JavaScript, CSS, datos/integración, device), tabla de códigos del validador `xone-simulator` (errores y warnings), 14 anti-patrones a buscar, checklist de entrega y priorización de hallazgos por severidad.
- Completa la Fase 4 del plan.

## [0.8.0] - 2026-08-03

### Añadido

- Skill `xone-device`: permisos con `systemSettings`, GPS y `GPSColl`/`GpsTools`, cámara y captura de foto/video, firma digital, escaneo QR/códigos y `BarcodeGenerator`, biometría (`biometricsManager` y `fingerprintManager`), Bluetooth/impresión, NFC y DNIe, WebSocket, `FileManager`, `DeviceInfo`, `WifiManager` y utilidades de `ui`, además de simulación de hardware con `mock/device.json` en `xone-simulator`.

## [0.7.0] - 2026-08-03

### Añadido

- Skill `xone-data-integration`: modelo de datos local (SQLite, `ROWID`, `##PREF##`, generador), SQL directo con SqlManager y prevención de SQL injection, HTTP con `$http` y TLS/pinning/mTLS, pruebas HTTP con `mock/http.json` y `xone-simulator`, OAuth2, réplica y flujo de provisionamiento `sys-message`, encriptación con `crypto`, manejo de credenciales y validación de entrada.

## [0.6.0] - 2026-08-03

### Añadido

- Skill `xone-css`: selectores (coll, prop, prop:TYPE, .clase, group, frame), unidades `p`/`%` y unidades prohibidas, colores `#RRGGBB` y `#AARRGGBB`, atributos (dimensiones, márgenes, padding, fuentes, texto, fondo, bordes, sombras, visibilidad bitmask), herencia `extends:`, estilos dinámicos `##FLD_CAMPO##` y cambio de clase desde JS, cascada de archivos, temas, animaciones y buenas prácticas.

## [0.5.0] - 2026-08-03

### Añadido

- Skill `xone-javascript`: objetos globales (self, ui, appData, $http, console), eventos del ciclo de vida, contents, colecciones, SQL seguro con SqlManager, GPS, patrones críticos (lock/unlock, startBrowse/endBrowse, filter/restore, preservación de contexto, WaitDialog, cursor SQL), utilidades de functions.js, debugging, seguridad y rendimiento. Alineada con los métodos reales del runtime `xone-simulator`.

## [0.4.0] - 2026-08-03

### Añadido

- Skill `xone-debugging`: diagnóstico sistemático de errores y rendimiento. Proceso de diagnóstico con `xone-simulator`, anti-patrones detectados, pantallas vacías, botones mudos, eventos que no disparan, `self` null, colecciones sin datos, lock/unlock, campos `MAP_`, estilos, imágenes, GPS, réplica, errores -8100 y -11888, y tabla de errores recurrentes por capa.

## [0.3.0] - 2026-08-03

### Añadido

- Skill `xone-xml-ui`: colecciones, props, types válidos, combos, mapas, contents, layouts, visibilidad, eventos del ciclo de vida, progid, splash, encoding, macros, permisos y anti-patrones XML.
- `scripts/sync.sh`: sincroniza las skills canónicas hacia `.opencode/skills` y falla si divergen.

## [0.2.0] - 2026-08-03

### Añadido

- Skill `xone-verification`: valida y hace smoke de proyectos XOne con el paquete npm `xone-linter` (binario `xone-simulator`). Comandos `validate`, `smoke`, `run` y `render`, con corrección iterativa.
- Publicado el paquete independiente `xone-linter@1.0.0` en npm y el repositorio GitHub `sleiva/xone-linter`.

## [0.1.0] - 2026-08-03

### Añadido

- Marketplace inicial `xone-plugins` con el plugin `xone-development`.
- Skill coordinadora `xone-development` (XML/UI, JavaScript, CSS, datos, dispositivo y diagnóstico).
- Documento de arquitectura `docs/ARCHITECTURE.md`.
- Compatibilidad OpenCode (`opencode.json` + espejo en `.opencode/skills/`).
