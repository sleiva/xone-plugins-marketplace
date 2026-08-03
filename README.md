# XOne Plugins Market

Marketplace de plugins de [Claude Code](https://code.claude.com/docs/en/plugins) para desarrollo con XOne.

También incluye una instalación nativa para [OpenCode](https://opencode.ai/), con la misma skill disponible en `.opencode/skills/`.

## Plugins

### xone-development

Skill experta para crear, verificar, revisar y depurar aplicaciones XOne con XML `.xne`, JavaScript y CSS XOne. Incluye `xone-verification`, que usa el paquete npm [`xone-linter`](https://www.npmjs.com/package/xone-linter) (binario `xone-simulator`) para validar y hacer smoke de proyectos XOne.

## Instalación

Desde Claude Code:

```text
/plugin marketplace add sleiva/xone-plugins-marketplace
/plugin install xone-development@xone-plugins
```

La skill `xone-verification` requiere el CLI instalado en el entorno:

```bash
npm install -g xone-linter
```

Después de instalarlo, Claude usará la skill automáticamente cuando la tarea esté relacionada con XOne. Para probar el plugin durante el desarrollo:

```bash
claude --plugin-dir ./plugins/xone-development
```

En OpenCode, abre este repositorio como proyecto y la skill `xone-development` se descubrirá desde `.opencode/skills/`.

## Desarrollo

Tras modificar el plugin, incrementa su versión en ambos manifiestos y valida con:

```bash
claude plugin validate ./plugins/xone-development
```

## Licencia

MIT
