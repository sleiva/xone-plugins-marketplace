---
name: xone-verification
description: Verificación y corrección de aplicaciones XOne con el linter xone-simulator. Usar al validar un proyecto XOne, al corregir errores de XML/JS/CSS, al hacer smoke de una app, al ejecutar eventos concretos, o al revisar si un cambio rompe la app.
---

# XOne Verification

Valida y corrige proyectos XOne usando el CLI `xone-simulator` del paquete `xone-linter`. Antes de editar el código, ejecuta la verificación para conocer el estado real del proyecto.

## Precondiciones

El CLI debe estar disponible en el entorno. Comprueba con:

```bash
command -v xone-simulator
```

Si no existe, instálalo:

```bash
npm install -g xone-linter
```

Si `xone-simulator` está instalado pero el shell no lo encuentra, usa la ruta completa al binario global (p. ej. `~/.hermes/node/bin/xone-simulator` o comprueba `npm config get prefix`).

## Flujo de verificación

1. Comprueba que el CLI existe; si no, indícalo al usuario y detente.
2. Ejecuta `validate` sobre el proyecto y lee los issues.
3. Corrige los errores de forma iterativa: modifica el XML/JS/CSS, revalida y repite hasta que pase.
4. Ejecuta `smoke` sobre la app completa para detectar fallos de runtime en el ciclo de vida.
5. Si `smoke` falla, usa `run` y `render` para aislar la coll y el evento problemáticos.
6. Reporta el resultado final con los errores resueltos y los que queden pendientes.

## Comandos

### validate — verificación estática

```bash
xone-simulator validate /ruta/a/tu/app --json
```

Valida XML bien formado y encoding, atributos obligatorios, unicidad de nombres, tipos de propiedad, `progid`, ficheros/estilos incluidos, sintaxis JS y referencias cruzadas (`mapcol`, `inherits`, `contents`, `openEditView`), además de anti-patrones documentados.

Salida JSON (con `--json`):

```json
{
  "success": true,
  "path": "/ruta/a/tu/app",
  "summary": { "total": 0, "errors": 0, "warnings": 0 },
  "issues": []
}
```

Cada `issue` incluye severidad, fichero y mensaje. Prioriza `errors` sobre `warnings`. Corrige iterativamente hasta que `success` sea `true` y no queden `errors`.

### smoke — verificación de toda la app

```bash
xone-simulator smoke /ruta/a/tu/app --json
```

Dispara el ciclo de vida (`create`/`before-edit`/`after-edit`) + render con flow de todas las colls (o del subconjunto `--coll X`). Con `--interact` además tapea los props con `onclick`/`method=ExecuteNode(...)` (máx. `--max-taps`, default 20).

- Exit code **1** si hay `failures`; 0 si no.
- Una coll rota no aborta el resto; cada fallo incluye su **fase** y **stack truncado**.
- `totals.stubWarnings > 0` en una coll que pasó indica que algún método no está implementado de verdad en el sandbox (fue absorbido por autostub). No bloquea, pero reporta el `kind: 'stub-method'`.

El entorno del smoke es siempre seguro: `network:'mock'` e in-memory, sin tocar red ni SQLite reales.

### run — ejecutar un evento concreto

```bash
xone-simulator run /ruta/a/tu/app --coll EntradaApp --event before-edit --json
xone-simulator run /ruta/a/tu/app --coll Clientes --event onclick --prop MAP_BT_GUARDAR --data '{"NOMBRE":"Acme"}' --json
```

Ejecuta un evento a nivel de coll (`before-edit`, `create`, `onback`) o inline de prop (`onclick`, `onchange`). Devuelve estado y `log` de side-effects (navegación, mensajes, refrescos, HTTP, cambios de datos, errores). Úsalo para aislar una coll que falla en el smoke o para probar un evento antes de modificarlo.

### render — renderizar una coll a HTML

```bash
xone-simulator render /ruta/a/tu/app --coll EntradaApp
```

Renderiza una coll a HTML (con ciclo de vida; `--no-flow` = en frío). Úsalo para inspeccionar la estructura de una pantalla cuando el smoke falla o cuando el problema puede ser de UI.

## Estrategia de corrección

1. Empieza por `validate`: los errores estáticos (XML mal formado, tipos inválidos, nombres duplicados, referencias rotas) son la causa más común de pantallas vacías o de código que no se carga.
2. Corrige **un tipo de error a la vez** y revalida tras cada tanda para confirmar que no introduces regresiones.
3. Cuando `validate` pase, ejecuta `smoke`. Si falla una coll concreta, usa `run` sobre su evento con `--json` para ver el error exacto y el stack.
4. Si el fallo es de UI, usa `render` para ver la pantalla renderizada.
5. No des por cerrado el trabajo hasta que `validate` pase sin `errors` y `smoke` devuelva exit 0 (o los `failures` restantes sean conocidos y justificados).

## Reglas al corregir

- Inspecciona el código y las convenciones del proyecto antes de editar.
- No inventes atributos XML, tipos de prop ni APIs XOne.
- Respeta las restricciones del runtime: un subconjunto de ES6+, sin template literals ni `async`/`await` salvo confirmación.
- Escapa correctamente el JavaScript embebido en XML (entidades o CDATA).
- No elimines ni sobrescribas partes del proyecto que no estén relacionadas con el error.
- Al final, reporta: qué se corrigió, qué se verificó (validate + smoke) y cualquier limitación del sandbox.

## Diagnóstico rápido

- Error de XML mal formado o encoding → revisa prólogo y `iso-8859-15`/UTF-8 del `.xne`.
- Pantalla vacía → revisa XML, primer `newline`, nombres duplicados, `visible`/`disablevisible` y `compatibility-mode`.
- Inicialización que no ocurre → mueve lógica de `load` a `before-edit` o `create`.
- Coll que falla en smoke pero no en validate → usa `run` con `--json` para ver el stack en runtime.
- Muchos `stubWarnings` → reporta qué APIs del sandbox no están cubiertas; no los trates como errores bloqueantes.
