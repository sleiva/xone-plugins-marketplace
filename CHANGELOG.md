# Changelog

Todos los cambios visibles de `xone-development` se registran aquí. Formato basado en [Keep a Changelog](https://keepachangelog.com/) y [SemVer](https://semver.org/).

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
