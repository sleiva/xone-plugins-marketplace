# Changelog

Todos los cambios visibles de `xone-development` se registran aquí. Formato basado en [Keep a Changelog](https://keepachangelog.com/) y [SemVer](https://semver.org/).

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
