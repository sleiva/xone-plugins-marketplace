---
name: xone-review
description: "Validar, verificar y revisar proyectos XOne con el linter xone-simulator. Usar al validar un proyecto, hacer smoke de una app, ejecutar un evento concreto, renderizar una coll, corregir iterativamente los errores del validador, o auditar un proyecto o un cambio antes de entregarlo: revisión por capas (XML/UI, JavaScript, CSS, datos/integración, device), anti-patrones, checklist de entrega y priorización de hallazgos por severidad."
---

# XOne Review

Verificación y revisión de proyectos XOne. Combina la validación automatizada con el CLI `xone-simulator` (paquete npm `xone-linter`) y una revisión manual por capas anclada al corpus de XOne.

**El linter dice qué está mal, no cuál es la forma correcta.** Para eso lee la referencia de la skill del área. No reportes como hallazgo ni apliques como arreglo nada que no puedas anclar al validador o al corpus.

## Precondiciones

```bash
command -v xone-simulator
```

Si no existe: `npm install -g xone-linter`. Si está instalado pero el shell no lo encuentra, usa la ruta completa al binario global (comprueba `npm config get prefix`).

En Claude Code, `/xone-validate [ruta]` ejecuta el flujo de validación y corrección completo.

## Flujo

1. Comprueba que el CLI existe; si no, indícalo al usuario y detente.
2. `validate` y lee los issues. Prioriza `errors` sobre `warnings`.
3. Corrige **un tipo de error a la vez** y revalida tras cada tanda, para no introducir regresiones.
4. `smoke` sobre la app completa cuando `validate` pase.
5. Si `smoke` falla, aísla con `run` (evento concreto) y `render` (UI).
6. Revisión por capas: XML/UI, JavaScript, CSS, datos/integración, device.
7. Prioriza los hallazgos y reporta con severidad, `archivo:línea` y causa raíz.

No des por cerrado el trabajo hasta que `validate` pase sin `errors` y `smoke` devuelva exit 0, o hasta que los `failures` restantes estén justificados.

## Comandos

```bash
xone-simulator validate ./proyecto --json                      # verificación estática
xone-simulator smoke    ./proyecto --json                      # ciclo de vida completo
xone-simulator run      ./proyecto --coll X --event before-edit --json
xone-simulator render   ./proyecto --coll X                    # coll a HTML
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
| `ANTIPATTERN_SELF_AS_FUNCTION` | `self("CAMPO")`; usar `self.CAMPO` o `self.getValue` |
| `ANTIPATTERN_MACRO_SYNTAX` | `coll.macro(...)`; usar `setMacro`/`getMacro` |
| `ANTIPATTERN_SELF_LOCK` | `self.lock()`/`self.unlock()`; son de la colección |
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

## Revisión XML/UI

- Jerarquía `coll > group > frame > prop` correcta.
- `prop` siempre con `name` y `type` válido: `T`, `TN`/`TN2`-`TN6`, `N`/`N2`-`N6`, `D`, `DT`, `TT`, `B`, `L`, `TL`, `NC`, `X`, `IMG`, `PH`, `VD`, `DR`, `WEB`, `AT`, `O`, `THTML`, `Z`.
- Coll de datos con `sql` (con `##PREF##`), `objname` y `updateobj`. Pantalla sin datos (`special="true"`) sin `sql`.
- **`progid`: conflicto entre fuentes.** El validador emite `COLL_MISSING_PROGID` como error cuando una coll tiene `objname` sin `progid`, pero la documentación lo declara opcional (sin él la coll equivale a `ASData.CASBasicDataObj`; solo **Empresas** y **Usuarios** requieren el suyo). No resuelvas la discrepancia por tu cuenta: si el proyecto no lo declara, señala que el linter lo marcará y deja la decisión al desarrollador.
- Combo bien definido: prop oculto con `mapcol`/`mapfld` más prop visible con `linkedto`/`linkedfield`; `mapcol-values` para valores fijos.
- Mapa con `type="Z" viewmode="mapview"` vinculado a un `<contents>`.
- `visible` correcto: 4 bits (`1` edición, `2` lista, `4` content, `8` combo), `7` lo habitual y `15` todos. Es estático; para condicional, `disablevisible`.
- Grupos con `id` único en la coll; un solo grupo visible → `notab="true"`.
- Un solo `before-edit` por coll; sin `load` para inicializar.
- Nombres únicos en la coll entera y case-sensitive en todas las referencias cruzadas.
- El primer elemento de una fila sin `newline="false"`.

## Revisión JavaScript

- **Patrones de bloqueo**: toda modificación de colección con `unlock`/`lock` en `finally`; browse con `startBrowse`/`endBrowse` en `finally`; cursor y conexión SQL cerrados en `finally`.
- **Contexto `self`**: en callbacks asíncronos (`$http`, GPS, cámara, WebSocket) `self` se guarda en variable local antes del callback.
- **Acceso a campos**: `self.CAMPO` o `self.getValue`; nunca `self("CAMPO")`.
- **Macros**: `setMacro`/`getMacro`, con la macro declarada en el XML antes de usarla.
- **`lock`/`unlock`** son de la colección, no del DataObject.
- **Sintaxis del motor**: `let`, `const`, arrow functions, destructuring, `class`, `Promise` (ES2024) y generadores **sí** están soportados. No lo están: template literals, `async`/`await`, spread/rest, parámetros por defecto, optional chaining `?.`, `??` y campos privados. No marques `let`/`const` como hallazgo.
- **APIs web**: no existen `document`, `window`, `localStorage`, `sessionStorage`, `XMLHttpRequest`, `navigator` ni `history`. En cambio `fetch`, `setTimeout`, `setInterval`, `Promise`, `URL`, `AbortController` y la API `console` completa **sí existen** con implementación custom: su uso no es un error, aunque lo idiomático sea `$http` y `ui.executeActionAfterDelay`.
- **`executeActionAfterDelay`**: el segundo parámetro va en segundos, no en milisegundos.
- **Validación antes de guardar**: obligatorios, rangos y formatos antes de `save()`; evita `-8100`.
- Refrescos acotados al campo afectado, no `ui.refresh()` global.

## Revisión CSS

- `default.css` en la raíz, declarado en `app.xml`; selectores `coll` y `prop` globales presentes.
- Unidades `p`/`%`; sin `px`, `em`, `rem`, `vh`, `vw`. Sin unidad: `fontsize`, `border-corner-radius`, `border-width`, `labelwidth`, `lines`, `visible`, `gallery-columns`, `img-width`, `img-height`.
- Colores `#RRGGBB` o `#AARRGGBB` con **alpha primero**; sin nombres de color.
- Márgenes y padding individuales; no existen los abreviados `margin`/`padding`.
- Selectores solo `coll`, `prop`, `prop:TYPE`, `.clase`, `group`, `frame`; sin combinadores ni IDs.
- `extends:` o `@extend` sin ciclos; recuerda que solo `@extend` los detecta en parseo.
- `:root`/`var()`, `calc()`, `@import`, `!important` y `!default` **son válidos**: no los marques como hallazgo.
- Si el CSS «no se aplica», comprueba `compatibility-mode` antes de cualquier otra cosa.

## Revisión datos / integración

- SQL de colecciones con `##PREF##`, nunca el prefijo literal.
- SQL directo parametrizado con `?`; sin concatenar entrada de usuario.
- Cursor y conexión cerrados en `finally`.
- `$http` con `allowUnsafeCertificates: false` en producción; `enablePinning` donde aplique.
- Tokens cifrados; credenciales nunca hardcodeadas ni logueadas.
- Réplica: configuración en `Empresas`, manejo de `sys-message` correcto.

## Revisión device

- Permisos pedidos y comprobados antes de GPS, cámara, micrófono o biometría, y declarados en `<permissions>`.
- GPS iniciado antes de leer la colección, con browse y verificación de `STATUS` y `LONGITUD`.
- Firma con `type="DR"`; `type="IMG" readonly="false"` está obsoleto.
- `biometricsManager` en código nuevo, no `fingerprintManager`.
- Bluetooth y WebSocket cerrados al terminar.

## Anti-patrones a buscar

1. `load` para inicializar en lugar de `before-edit`.
2. Múltiples `before-edit` en una coll.
3. `self("campo")` en vez de `self.campo`.
4. `self.lock()`/`self.unlock()` en vez de la colección.
5. `coll.macro(...)` en vez de `setMacro`/`getMacro`, o `setMacro` sin declarar el nodo `<macro>`.
6. Concatenar input del usuario en SQL.
7. `ui.refresh()` global en vez de campos concretos.
8. Acceso a `self` dentro de callbacks sin guardar referencia.
9. Espera bloqueante en vez de `executeActionAfterDelay`.
10. Unidades `px`/`em`/`rem` y atributos CSS web (`font-size`, `margin-top`, `background-color`, `box-shadow`).
11. `visible` con bitmask incorrecto, o intento de cambiarlo por script.
12. VBScript en includes.
13. Template literals, `async`/`await`, spread/rest u optional chaining.
14. `localStorage`/`document`/`window`/`XMLHttpRequest` (no existen). `setTimeout` y `fetch` sí existen: revísalos como preferencia de estilo, no como error.
15. Nombres duplicados en la misma coll, o `id` de `group` repetido.
16. Trabajar sobre los `.xml` generados en vez de los `.xne`.

## Checklist de entrega

- [ ] `validate` sin errores; warnings justificados o corregidos.
- [ ] `smoke` con exit 0.
- [ ] Pantallas nuevas con la jerarquía `coll > group > frame > prop`.
- [ ] Colls de datos con `sql`, `objname` y `updateobj` (`progid` según la nota de conflicto).
- [ ] Un solo `before-edit` por coll; sin `load` para inicializar.
- [ ] `##PREF##` en toda SQL de colección.
- [ ] Todo `unlock` con su `lock` en `finally`; todo `startBrowse` con su `endBrowse`.
- [ ] Cursores y conexiones SQL cerrados en `finally`.
- [ ] Callbacks asíncronos preservando `self`.
- [ ] Validación de entrada antes de `save()`.
- [ ] SQL parametrizado.
- [ ] CSS con unidades y colores correctos.
- [ ] `allowUnsafeCertificates: false`; sin credenciales hardcodeadas.
- [ ] Solo se han tocado ficheros `.xne` (y `app.xml`), no los `.xml` generados.

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

Los códigos del validador vienen del paquete `xone-linter`; las reglas de cada capa, del corpus de XOne. Para confirmar la forma correcta de algo antes de marcarlo como hallazgo o de aplicar un arreglo, lee la referencia de la skill correspondiente: `xone-xml-ui` (nodos y atributos), `xone-javascript` (API del runtime), `xone-css` (estilos), `xone-data-integration` (SQL, `$http`, réplica), `xone-device` (hardware), `xone-development` (fundamentos y reglas transversales).

Para diagnosticar un fallo a partir de su síntoma, usa `xone-debugging`.
