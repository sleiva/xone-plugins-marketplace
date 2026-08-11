# XOne Plugins Market

Marketplace de plugins de [Claude Code](https://code.claude.com/docs/en/plugins) para desarrollo con XOne.

También incluye una instalación nativa para [OpenCode](https://opencode.ai/), que descubre directamente la fuente canónica mediante `opencode.json`.

## Plugins

### xone-development

Skills expertas para crear, verificar, revisar y depurar aplicaciones XOne con XML `.xne`, JavaScript y CSS XOne. Incluye 4 skills: una puerta de conocimiento y tres de procedimiento.

| Skill | Rol |
| --- | --- |
| `xone-development` | Puerta de conocimiento: todas las reglas duras de XOne (XML `.xne`, JavaScript del runtime, CSS, datos e integración, dispositivo y fundamentos de proyecto) y el índice maestro de referencias, organizado en subcarpetas por área |
| `xone-project-generator` | Procedimiento: generación de un proyecto completo desde lenguaje natural, flujo de 12 fases, plantillas y tamaños canónicos |
| `xone-review` | Procedimiento: validar, hacer smoke y auditar con `xone-simulator` — códigos del validador, checklist de entrega y priorización por severidad (anti-patrones y reglas por capa viven en `xone-development`) |
| `xone-debugging` | Procedimiento: diagnóstico sistemático de errores y rendimiento, síntoma → hipótesis → comprobación |

`xone-review` y `xone-debugging` usan el paquete npm [`xone-linter`](https://www.npmjs.com/package/xone-linter) (binario `xone-simulator`) para validar, hacer smoke y revisar proyectos XOne. `xone-project-generator` y los diagnósticos de BD usan [`xone-db-tools`](https://www.npmjs.com/package/xone-db-tools).

#### Comandos

| Comando | Qué hace |
| --- | --- |
| `/xone-validate [ruta]` | Valida el proyecto con `xone-simulator` y corrige iterativamente los errores encontrados |

## Cómo está organizado el conocimiento

Cada skill sigue el patrón de Agent Skills. La puerta de conocimiento, `xone-development`, organiza sus referencias en subcarpetas por área:

```text
xone-development/
├── SKILL.md              # reglas duras + índice «para responder X, lee Y» (<400 líneas)
└── references/
    ├── fundamentos/       (5 ficheros)
    ├── xml-ui/            (18 ficheros)
    ├── javascript/        (16 ficheros)
    ├── css/               (6 ficheros)
    ├── datos/             (5 ficheros)
    └── device/            (4 ficheros)
```

Las tres skills de procedimiento (`xone-project-generator`, `xone-review`, `xone-debugging`) siguen el patrón simple:

```text
<skill-name>/
├── SKILL.md
└── references/    # opcional
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

`xone-review` y `xone-debugging` requieren el CLI en el entorno, con **`xone-linter >= 1.1.0`** —de esa versión salen `validate-coll`, `login` y `render --session`:

```bash
npm install -g xone-linter
npm install -g xone-db-tools
```

El CLI no expone un comando de versión, así que para confirmar cuál tienes: `npm list -g xone-linter`. Un `xone-simulator help` que no liste `login` es de una versión anterior.

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

`scripts/validate-skills.sh` descubre las skills desde el sistema de ficheros y comprueba: el frontmatter (`name`/`description` presentes, más un parseo YAML real que detecta un frontmatter sintácticamente inválido); el tamaño del `SKILL.md` (techo general de 500 líneas, y uno propio de 400 para la puerta de conocimiento `xone-development`); que todo enlace a `references/` resuelva, tanto desde el `SKILL.md` como los enlaces relativos dentro de los propios ficheros de referencia; que ninguna referencia quede huérfana; un guardián de duplicados que falla si dos líneas largas (>35 caracteres) de `SKILL.md` distintos superan el 65% de solape de tokens — una heurística con malla conocida, no una prueba exhaustiva: ver `docs/ARCHITECTURE.md` §10.1 — con una allowlist corta de excepciones documentadas; y que `opencode debug skill` enumere las cuatro por nombre con su `location` bajo `plugins/xone-development/skills/` (no solo por nombre: un `xone-help-docs` global homónimo no basta para pasar).

## Documentación

- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md): arquitectura, taxonomía y estado de las fases.
- [`docs/ANALISIS.md`](docs/ANALISIS.md): análisis del diseño previo a la v0.10.0 y rediseño aplicado.
- [`docs/TODO.md`](docs/TODO.md): trabajo pendiente.

## Licencia

MIT
