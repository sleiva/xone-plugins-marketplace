# Instalacion

Este repositorio distribuye el plugin `xone-development` para Claude Code y las
skills compatibles para OpenCode y Antigravity.

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

## Antigravity

Antigravity no instala el marketplace de Claude. Descubre skills compatibles con
`SKILL.md` desde estas rutas:

```text
<proyecto>/.agents/skills/<skill>/SKILL.md
~/.gemini/config/skills/<skill>/SKILL.md
```

### Instalacion global

Clona el repositorio y crea enlaces simbolicos para mantener una unica fuente:

```bash
git clone https://github.com/sleiva/xone-plugins-marketplace.git ~/xone-plugins-marketplace
mkdir -p ~/.gemini/config/skills

for skill in xone-development xone-project-generator xone-review xone-debugging; do
  ln -s ~/xone-plugins-marketplace/plugins/xone-development/skills/$skill \
    ~/.gemini/config/skills/$skill
done
```

Si una skill ya existe, elimina primero el enlace o carpeta anterior. Para una
instalacion solo para un proyecto, usa la misma estructura bajo
`<proyecto>/.agents/skills/`.

Reinicia Antigravity o abre una conversacion nueva. Deberian aparecer las cuatro
skills por sus nombres exactos.

Antigravity no soporta el comando `/xone-validate` de Claude Code. Ejecuta las
herramientas directamente:

```bash
xone-simulator validate ./proyecto
xone-db-tools create-db ./proyecto --overwrite
xone-db-tools validate-db ./proyecto/bd/gestion.db --project ./proyecto
```

## Requisito para validar y depurar

Las skills `xone-review` y `xone-debugging` utilizan el binario
`xone-simulator`, incluido en el paquete `xone-linter`:

```bash
npm install -g xone-linter xone-db-tools
xone-db-tools --help
xone-simulator --help
```

Hacen falta **`xone-linter >= 1.2.0`** y **`xone-db-tools >= 0.2.0`**: `validate-coll`, `login` y
`render --session` en el primero; `describe-table` y `execute-sql` en el segundo. Ninguno de los dos
CLI tiene comando de versión, así que se comprueba con `npm list -g xone-linter xone-db-tools`, o
mirando si `xone-simulator help` lista `login` — si no lo lista, es una versión anterior.

`xone-db-tools` se necesita para generar, validar y describir la BD. Las skills de
conocimiento no necesitan herramientas externas.

## Actualizar

Para actualizar una copia clonada:

```bash
cd ~/xone-plugins-market
git pull
```

Claude Code actualiza el plugin instalado desde su marketplace mediante su
propio flujo de plugins. OpenCode usa directamente la copia indicada en
`skills.paths`, por lo que basta actualizar ese repositorio.
