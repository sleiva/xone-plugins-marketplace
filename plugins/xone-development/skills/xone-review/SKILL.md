---
name: xone-review
description: "Validar, verificar y revisar proyectos XOne con el linter xone-simulator. Usar al validar un proyecto, hacer smoke de una app, ejecutar un evento concreto, renderizar una coll, corregir iterativamente los errores del validador, o auditar un proyecto o un cambio antes de entregarlo: códigos del validador, checklist de entrega y priorización de hallazgos por severidad. Las reglas y anti-patrones de cada capa viven en xone-development."
---

# XOne Review

Verificación y revisión de proyectos XOne. Combina la validación automatizada con el CLI `xone-simulator` (paquete npm `xone-linter`), la validación de la BD con `xone-db-tools` y una revisión manual anclada a las reglas de `xone-development`.

**El linter dice qué está mal, no cuál es la forma correcta.** Para eso lee `xone-development`. No reportes como hallazgo ni apliques como arreglo nada que no puedas anclar al validador o a esas reglas.

## Precondiciones

```bash
command -v xone-simulator
```

Si no existe: `npm install -g xone-linter xone-db-tools`. Si está instalado pero el shell no lo encuentra, usa la ruta completa al binario global (comprueba `npm config get prefix`).

En Claude Code, `/xone-validate [ruta]` ejecuta el flujo de validación y corrección completo.

## Flujo

1. Comprueba que `xone-simulator` existe; si no, indícalo al usuario y detente.
2. `validate` y lee los issues. Prioriza `errors` sobre `warnings`.
3. Si existe `bd/gestion.db`, ejecuta `xone-db-tools validate-db ./proyecto/bd/gestion.db --project ./proyecto --json`.
4. Corrige **un tipo de error a la vez** y revalida tras cada tanda, para no introducir regresiones.
5. `smoke` sobre la app completa cuando `validate` pase.
6. Si `smoke` falla, aísla con `run` (evento concreto) y `render` (UI).
7. Revisión manual contra las reglas de `xone-development` (ver «Qué revisar en cada capa»).
8. Prioriza los hallazgos y reporta con severidad, `archivo:línea` y causa raíz.

No des por cerrado el trabajo hasta que `validate` pase sin `errors` y `smoke` devuelva exit 0, o hasta que los `failures` restantes estén justificados.

## Comandos

```bash
xone-simulator validate ./proyecto --json                      # verificación estática
xone-simulator smoke    ./proyecto --json                      # ciclo de vida completo
xone-simulator run      ./proyecto --coll X --event before-edit --json
xone-simulator render   ./proyecto --coll X                    # coll a HTML
xone-db-tools validate-db ./proyecto/bd/gestion.db --project ./proyecto --json
```

**`validate`** comprueba XML bien formado y encoding, atributos obligatorios, unicidad de nombres, tipos de propiedad, `progid`, ficheros y estilos incluidos, sintaxis JS y referencias cruzadas (`mapcol`, `inherits`, `contents`, `openEditView`), más los anti-patrones documentados. Con `--json` devuelve `success`, `summary` e `issues` con severidad, fichero y mensaje.

**`smoke`** dispara `create`/`before-edit`/`after-edit` más render con flow de todas las colls (o de `--coll X`). Con `--interact` además tapea los props con `onclick`/`method=ExecuteNode(...)` (máx. `--max-taps`, default 20). Exit code 1 si hay `failures`. Una coll rota no aborta el resto y cada fallo incluye su fase y el stack truncado. El entorno es siempre seguro: `network:'mock'` e in-memory, sin tocar red ni SQLite reales. Si `totals.stubWarnings > 0` en una coll que pasó, algún método fue absorbido por autostub (`kind: 'stub-method'`): no bloquea, pero repórtalo.

**`run`** ejecuta un evento a nivel de coll (`before-edit`, `create`, `onback`) o inline de prop (`onclick`, `onchange`, con `--prop` y `--data`). Devuelve estado y `log` de side-effects: navegación, mensajes, refrescos, HTTP, cambios de datos y errores.

**`render`** renderiza una coll a HTML con ciclo de vida (`--no-flow` para renderizar en frío).

`--db-path` debe apuntar a una **copia** de la base de datos: el simulador puede mutarla.

## Códigos del validador

### Errores

| Código | Significado |
|--------|-------------|
| `XML_PARSE` | XML mal formado en un `.xne` |
| `INVALID_PROP_TYPE` | Tipo de prop no soportado |
| `PROP_MISSING_NAME` / `PROP_MISSING_TYPE` | Prop sin `name` o sin `type` |
| `COLL_MISSING_PROGID` | Coll con `objname` pero sin `progid` |
| `GROUP_MISSING_ID` | Grupo sin atributo `id` |
| `APP_NO_ENTRY` | `app.xml` sin punto de entrada (`entry-point`) |
| `DUPLICATE_COLL_NAME` | Nombre de colección duplicado |
| `DUPLICATE_NAME_IN_COLL` | Nombre repetido dentro de una coll |
| `REF_MAPCOL_MISSING` | `mapcol` apunta a una coll inexistente |
| `REF_CONTENTS_SRC_MISSING` | `contents src` apunta a una coll inexistente |
| `REF_INHERITS_MISSING` | `inherits` apunta a una coll inexistente |
| `ANTIPATTERN_MULTIPLE_BEFORE_EDIT` | Más de un `before-edit` en la misma coll |
| `ANTIPATTERN_SELF_AS_FUNCTION` | `self` usado como función |
| `ANTIPATTERN_MACRO_SYNTAX` | `macro` llamado como método de `coll` |
| `ANTIPATTERN_SELF_LOCK` | `lock`/`unlock` llamados sobre `self` |
| `ANTIPATTERN_VBSCRIPT` | Include con `language="vbscript"` (descontinuado) |
| `JS_SYNTAX` | Error de sintaxis JavaScript |
| `JS_TEMPLATE_LITERAL` | Template literals no soportados |
| `JS_ASYNC_AWAIT` | `async`/`await` no soportados |

### Warnings

| Código | Significado |
|--------|-------------|
| `ANTIPATTERN_LOAD_EVENT` | Se usa `<load>`; preferir `<before-edit>` |
| `REF_MAPFLD_MISSING` | `mapfld` no es campo de la coll de `mapcol` |
| `REF_LINKEDFIELD_MISSING` | `linkedfield` no es campo de la coll de `mapcol` |
| `REF_JS_COLL_MISSING` | Script referencia una colección inexistente |
| `REF_NODE_MISSING` | Referencia a nodo o evento inexistente |
| `REF_FUNC_MISSING` | Referencia a función inexistente |

Los códigos son case-sensitive. Cada warning debe justificarse o corregirse.

## Qué revisar en cada capa

Las reglas y los anti-patrones de cada capa viven en la skill `xone-development`, que es donde se escriben una sola vez. Antes de marcar un hallazgo, contrástalo allí:

- Reglas transversales, tipos de prop, visibilidad, ciclo de vida y sintaxis del motor: `xone-development/SKILL.md`.
- Anti-patrones por área (XML, JavaScript, CSS, datos, dispositivo): sección «Anti-patrones» de `xone-development/SKILL.md`.
- Detalle de un atributo, una API o un valor admitido: el índice de referencias de `xone-development/SKILL.md`.

**No reportes como hallazgo nada que no puedas anclar al validador o a esas reglas.**

## Checklist de entrega

- [ ] `validate` sin errores; warnings justificados o corregidos.
- [ ] `smoke` con exit 0.
- [ ] Pantallas nuevas siguen la jerarquía de `xone-development`.
- [ ] Colls de datos con `sql`, `objname` y `updateobj`; `progid` según la regla de `xone-development`.
- [ ] `##PREF##` en toda SQL de colección.
- [ ] Todo `unlock` con su `lock` en `finally`; todo `startBrowse` con su `endBrowse`.
- [ ] Cursores y conexiones SQL cerrados, patrón de `xone-development`.
- [ ] Callbacks asíncronos preservando `self`.
- [ ] Validación de entrada antes de `save()`.
- [ ] SQL parametrizado.
- [ ] CSS con unidades (`p`/`%`) y colores (`#AARRGGBB`) correctos.
- [ ] `allowUnsafeCertificates: false`; sin credenciales hardcodeadas.
- [ ] Solo se han tocado los `.xne` fuente (regla en `xone-development`).

## Severidad y reporte

| Severidad | Definición | Acción |
|---|---|---|
| Crítico | Bloquea entrega: error del validador, SQL injection, `before-edit` duplicado, referencias rotas | Corregir antes de entregar |
| Alto | Riesgo de bug en runtime: `self` en callback, lock sin `finally`, `-8100` por no validar | Corregir en el mismo cambio |
| Medio | Mala práctica o rendimiento: `load`, refresh global, espera bloqueante | Corregir o registrar deuda técnica |
| Bajo | Estilo y consistencia: nombres, comentarios, organización del CSS | Sugerencia, no bloqueante |

Reporta cada hallazgo con `archivo:línea`, severidad, código del validador si existe, y causa raíz con la corrección propuesta. Al final indica qué se corrigió, qué se verificó (`validate` + `smoke`) y qué no has podido verificar, incluidas las limitaciones del sandbox.

## Diagnóstico rápido

- XML mal formado o encoding → revisa el prólogo y que el `encoding` declarado coincida con cómo está guardado el `.xne`.
- Pantalla vacía → XML, primer `newline` de cada fila, nombres duplicados, `visible`/`disablevisible`, `special` junto a `sql` y `compatibility-mode`.
- Inicialización que no ocurre → mueve la lógica de `load` a `before-edit` o `create`.
- Coll que falla en `smoke` pero no en `validate` → `run` con `--json` para ver el stack de runtime.
- Muchos `stubWarnings` → reporta qué APIs del sandbox no están cubiertas; no son errores bloqueantes.

## Fuente de las reglas

Los códigos del validador vienen del paquete `xone-linter`; las reglas de cada capa, de la skill `xone-development`. Para confirmar la forma correcta de algo antes de marcarlo como hallazgo o de aplicar un arreglo, lee `xone-development/SKILL.md` y su índice de referencias.

Para diagnosticar un fallo a partir de su síntoma, usa `xone-debugging`.
