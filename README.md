# XOne Plugins Market

Marketplace de plugins de [Claude Code](https://code.claude.com/docs/en/plugins) para desarrollo con XOne.

También incluye una instalación nativa para [OpenCode](https://opencode.ai/), que descubre directamente la fuente canónica mediante `opencode.json`.

## Plugins

### xone-development

Skills expertas para crear, verificar, revisar y depurar aplicaciones XOne con XML `.xne`, JavaScript y CSS XOne. Incluye 9 skills:

| Skill | Área |
| --- | --- |
| `xone-development` | Fundamentos y estructura: `app.xml`, `app.ini`, `mappings.xne`, anatomía de carpetas, macros del sistema, códigos de error, sintaxis JS soportada y reglas transversales |
| `xone-xml-ui` | XML `.xne`: colecciones, props y tipos, groups, frames, contents, `asfilter`, combos, mapas, layouts, herencia, macros, eventos y permisos |
| `xone-javascript` | Runtime: `self`, `selfDataColl`, `ui`, objetos creables, singletons, métodos de los controles, patrones críticos y objeto `ai` |
| `xone-css` | Selectores, unidades, colores ARGB, atributos, herencia `extends`/`@extend`, funciones del parser, temas y animaciones |
| `xone-data-integration` | `appData`, SQL con `SqlManager`, `$http` con TLS/pinning/mTLS, OAuth2, réplica, mocks y seguridad |
| `xone-device` | GPS, cámara, escáner, firma `DR`, permisos, biometría, Bluetooth, impresión, NFC, WiFi y archivos |
| `xone-project-generator` | Generación de un proyecto completo desde lenguaje natural: flujo de 12 fases, plantillas y tamaños canónicos |
| `xone-debugging` | Diagnóstico sistemático de errores y rendimiento |
| `xone-review` | Validar, hacer smoke y auditar con `xone-simulator`: códigos del validador, revisión por capas, anti-patrones y checklist de entrega |

`xone-review` y `xone-debugging` usan el paquete npm [`xone-linter`](https://www.npmjs.com/package/xone-linter) (binario `xone-simulator`) para validar, hacer smoke y revisar proyectos XOne.

#### Comandos

| Comando | Qué hace |
| --- | --- |
| `/xone-validate [ruta]` | Valida el proyecto con `xone-simulator` y corrige iterativamente los errores encontrados |

## Cómo está organizado el conocimiento

Cada skill sigue el patrón de Agent Skills:

```text
<skill-name>/
├── SKILL.md      # reglas duras + índice «para responder X, lee Y»
└── references/   # material autoritativo troceado, de lectura perezosa
```

El `SKILL.md` se carga siempre al invocar la skill, así que contiene solo lo que hace falta en todo momento: reglas, anti-patrones y el índice. Las referencias contienen el **material original completo** —no resúmenes—, troceado por secciones en piezas de 5-33 KB para que una lectura no agote el contexto. Cada chunk declara su procedencia en la cabecera:

```markdown
> Fuente: `xone/xone-help-docs/topics/04-css-styling-guide.md` §1–§4.
```

La fuente canónica vive en [`xone/`](xone/) y está versionada, de modo que cualquier regla de una skill puede rastrearse hasta su origen. Los chunks se generaron una sola vez a partir de ella; no hay pipeline de sincronización que pueda desincronizarse en silencio.

Regla de fondo: **una skill no afirma nada que no esté en sus referencias.** Cuando el corpus se contradice, la skill declara la discrepancia en vez de resolverla por su cuenta.

## Instalación

Desde Claude Code:

```text
/plugin marketplace add sleiva/xone-plugins-marketplace
/plugin install xone-development@xone-plugins
```

`xone-review` y `xone-debugging` requieren el CLI en el entorno:

```bash
npm install -g xone-linter
```

Después Claude usará la skill automáticamente cuando la tarea esté relacionada con XOne. Para probar el plugin durante el desarrollo:

```bash
claude --plugin-dir ./plugins/xone-development
```

En OpenCode, abre este repositorio como proyecto. Las skills se descubren desde `plugins/xone-development/skills/`, configurado mediante `skills.paths` en `opencode.json`. Los comandos son específicos de Claude Code.

En Codex, abre este repositorio como proyecto: `AGENTS.md` en la raíz apunta a `plugins/xone-development/skills/` y lista las cuatro skills. No se mantienen copias para Codex, igual que con OpenCode. Comprobado el 2026-08-03 con `codex-cli 0.146.0` (`codex exec "Lista las skills de XOne disponibles en este repositorio, por su nombre exacto."`), enumerando exactamente las cuatro skills.

## Desarrollo

Las skills canónicas viven en `plugins/xone-development/skills/`; no se mantienen copias sincronizadas para OpenCode.

Tras modificar el plugin, incrementa su versión en ambos manifiestos (`plugins/xone-development/.claude-plugin/plugin.json` y `.claude-plugin/marketplace.json`), registra el cambio en `CHANGELOG.md` y valida con:

```bash
claude plugin validate ./plugins/xone-development
scripts/validate-skills.sh
```

`scripts/validate-skills.sh` descubre las skills desde el sistema de ficheros y comprueba el frontmatter, el tamaño del `SKILL.md`, que todo enlace a `references/` resuelva, que ninguna referencia quede huérfana y que OpenCode pueda enumerarlas.

## Documentación

- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md): arquitectura, taxonomía y estado de las fases.
- [`docs/ANALISIS.md`](docs/ANALISIS.md): análisis del diseño previo a la v0.10.0 y rediseño aplicado.
- [`docs/TODO.md`](docs/TODO.md): trabajo pendiente.

## Licencia

MIT
