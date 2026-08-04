# Instalacion

Este repositorio distribuye el plugin `xone-development` para Claude Code y las
skills compatibles para OpenCode.

## Claude Code

### Instalar desde el marketplace

En Claude Code, ejecuta:

```text
/plugin marketplace add sleiva/xone-plugins-marketplace
/plugin install xone-development@xone-plugins
```

Claude Code cargara automaticamente las skills cuando la tarea este relacionada
con XOne.

### Probar una copia local

Para probar cambios sin instalar el plugin:

```bash
git clone https://github.com/sleiva/xone-plugins-marketplace.git
cd xone-plugins-marketplace
claude --plugin-dir ./plugins/xone-development
```

### Validar el plugin

Desde la raiz del repositorio:

```bash
claude plugin validate ./plugins/xone-development
scripts/validate-skills.sh
```

El comando `/xone-validate [ruta]` esta disponible en Claude Code y usa
`xone-simulator`.

## OpenCode

OpenCode no instala este repositorio mediante el marketplace de Claude. Descubre
las skills leyendo la ruta configurada en `opencode.json`.

### Usar el repositorio como proyecto

Clona el repositorio y abre OpenCode desde su raiz:

```bash
git clone https://github.com/sleiva/xone-plugins-marketplace.git
cd xone-plugins-marketplace
opencode
```

El `opencode.json` incluido ya configura la ruta canonica:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "skills": {
    "paths": ["./plugins/xone-development/skills"]
  }
}
```

### Usarlo desde otros proyectos

1. Clona el repositorio en una ubicacion estable:

```bash
git clone https://github.com/sleiva/xone-plugins-marketplace.git ~/xone-plugins-market
```

2. Anade la ruta a la configuracion global de OpenCode,
   `~/.config/opencode/opencode.json`:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "skills": {
    "paths": [
      "~/xone-plugins-market/plugins/xone-development/skills"
    ]
  }
}
```

Si el archivo ya contiene otras opciones, conserva su contenido y añade solo
`skills.paths`.

### Verificar la deteccion

Ejecuta desde cualquier proyecto donde quieras usar las skills:

```bash
opencode debug skill
```

Deben aparecer estas cuatro skills con una ruta que termine en
`plugins/xone-development/skills/`:

- `xone-development`
- `xone-project-generator`
- `xone-review`
- `xone-debugging`

El comando `/xone-validate` es especifico de Claude Code. En OpenCode se debe
invocar la skill `xone-review`.

## Requisito para validar y depurar

Las skills `xone-review` y `xone-debugging` utilizan el binario
`xone-simulator`, incluido en el paquete `xone-linter`:

```bash
npm install -g xone-linter
xone-simulator --help
```

Las skills de conocimiento y `xone-project-generator` no necesitan este paquete.

## Actualizar

Para actualizar una copia clonada:

```bash
cd ~/xone-plugins-market
git pull
```

Claude Code actualiza el plugin instalado desde su marketplace mediante su
propio flujo de plugins. OpenCode usa directamente la copia indicada en
`skills.paths`, por lo que basta actualizar ese repositorio.
