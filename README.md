# XOne Plugins Market

Marketplace de plugins de [Claude Code](https://code.claude.com/docs/en/plugins) para desarrollo con XOne.

También incluye una instalación nativa para [OpenCode](https://opencode.ai/), con las mismas skills disponibles en `.opencode/skills/`.

## Plugins

### xone-development

Skill experta para crear, verificar, revisar y depurar aplicaciones XOne con XML `.xne`, JavaScript y CSS XOne. Incluye 9 skills especializadas:

| Skill | Área |
| --- | --- |
| `xone-development` | Coordinadora: inspección, clasificación de tareas y reglas transversales |
| `xone-xml-ui` | XML `.xne`, `app.xml`, colecciones, props, types, combos, mapas, layouts, macros y permisos |
| `xone-javascript` | Objetos globales, ciclo de vida, callbacks, Futures, SQL seguro y patrones críticos |
| `xone-css` | Selectores, unidades, colores ARGB, herencia `extends`, temas y animaciones |
| `xone-data-integration` | SQL, `$http`, OAuth2, TLS, réplica, mocks HTTP y seguridad |
| `xone-device` | GPS, cámara, permisos, biometría, Bluetooth, NFC, WebSocket y archivos |
| `xone-verification` | Validación y smoke automáticos con `xone-simulator` |
| `xone-debugging` | Diagnóstico sistemático de errores y rendimiento |
| `xone-review` | Revisión de código: validación, anti-patrones y checklist de entrega |

`xone-verification`, `xone-debugging` y `xone-review` usan el paquete npm [`xone-linter`](https://www.npmjs.com/package/xone-linter) (binario `xone-simulator`) para validar, hacer smoke y revisar proyectos XOne.

## Instalación

Desde Claude Code:

```text
/plugin marketplace add sleiva/xone-plugins-marketplace
/plugin install xone-development@xone-plugins
```

Las skills de verificación requieren el CLI instalado en el entorno:

```bash
npm install -g xone-linter
```

Después de instalarlo, Claude usará la skill automáticamente cuando la tarea esté relacionada con XOne. Para probar el plugin durante el desarrollo:

```bash
claude --plugin-dir ./plugins/xone-development
```

En OpenCode, abre este repositorio como proyecto y las skills se descubrirán desde `.opencode/skills/`.

## Desarrollo

Las skills canónicas viven en `plugins/xone-development/skills/` y se sincronizan hacia `.opencode/skills/` con:

```bash
scripts/sync.sh
```

Tras modificar el plugin, incrementa su versión en ambos manifiestos (`plugins/xone-development/.claude-plugin/plugin.json` y `.claude-plugin/marketplace.json`), registra el cambio en `CHANGELOG.md` y valida con:

```bash
claude plugin validate ./plugins/xone-development
```

## Documentación

- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md): arquitectura, taxonomía y plan de fases de las skills.

## Licencia

MIT
