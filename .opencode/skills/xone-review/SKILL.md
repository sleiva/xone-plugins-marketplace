---
description: "Revisión de código XOne. Usar para auditar un proyecto o un cambio antes de entregarlo: validación con xone-simulator, revisión por capas (XML/UI, JavaScript, CSS, datos/integración, device), anti-patrones, checklist de verificación y priorización de hallazgos."
---

# XOne Review

Proceso de revisión de código XOne antes de entregar o publicar. Combina la validación automatizada con `xone-simulator` y una revisión manual por capas basada en las buenas prácticas y anti-patrones de la plataforma.

## Flujo de revisión

1. **Validar automáticamente**: ejecuta `xone-simulator validate` y corrige errores, después warnings.
2. **Smoke-run**: ejecuta `xone-simulator smoke` (exit 1 si hay failures) para confirmar que las pantallas arrancan y los eventos no rompen.
3. **Revisar por capas**: XML/UI, JavaScript, CSS, datos/integración, device (checklists abajo).
4. **Verificar anti-patrones** detectados por el validador y los manuales.
5. **Priorizar hallazgos** y reportar con severidad, archivo y causa raíz.

```bash
xone-simulator validate ./proyecto --json   # errores y warnings con ubicación
xone-simulator smoke ./proyecto             # arranque completo; exit 1 si hay failures
xone-simulator render ./proyecto --coll X   # inspeccionar una pantalla
xone-simulator run ./proyecto --coll X --event before-edit   # reproducir un evento
```

## Validación automatizada

El validador `xone-simulator` comprueba (reglas reales del paquete `xone-linter`):

### Errores que detecta

| Código | Significado |
|--------|-------------|
| `XML_PARSE` | XML mal formado en un `.xne` |
| `INVALID_PROP_TYPE` | Tipo de prop no soportado (ver lista de tipos válidos) |
| `PROP_MISSING_NAME` / `PROP_MISSING_TYPE` | Prop sin `name` o sin `type` |
| `COLL_MISSING_PROGID` | Coll con `objname` pero sin `progid` |
| `GROUP_MISSING_ID` | Grupo sin atributo `id` |
| `APP_NO_ENTRY` | `app.xml` sin punto de entrada (`entry-point`) |
| `DUPLICATE_COLL_NAME` | Nombre de colección duplicado |
| `DUPLICATE_NAME_IN_COLL` | Nombre repetido dentro de una coll (props/contents) |
| `REF_MAPCOL_MISSING` | `mapcol` apunta a una coll inexistente |
| `REF_CONTENTS_SRC_MISSING` | `contents src` apunta a una coll inexistente |
| `REF_INHERITS_MISSING` | `inherits` apunta a una coll inexistente |
| `ANTIPATTERN_MULTIPLE_BEFORE_EDIT` | Más de un `before-edit` en la misma coll |
| `ANTIPATTERN_SELF_AS_FUNCTION` | Uso de `self("CAMPO")`; usar `self.CAMPO` / `self.getValue` |
| `ANTIPATTERN_MACRO_SYNTAX` | Uso de `coll.macro(...)`; usar `setMacro`/`getMacro` |
| `ANTIPATTERN_SELF_LOCK` | `self.lock()`/`self.unlock()`; lock/unlock son de la colección |
| `ANTIPATTERN_VBSCRIPT` | Include con `language="vbscript"` (descontinuado) |
| `JS_SYNTAX` | Error de sintaxis JavaScript |
| `JS_TEMPLATE_LITERAL` | Template literals (`` ` ``) no soportados |
| `JS_ASYNC_AWAIT` | `async`/`await` no soportados |
| `XML_PARSE` | XML mal formado |

### Warnings que revisar

| Código | Significado |
|--------|-------------|
| `ANTIPATTERN_LOAD_EVENT` | Se usa `<load>`; preferir `<before-edit>` (impacta rendimiento) |
| `REF_MAPFLD_MISSING` | `mapfld` no es campo de la coll de `mapcol` |
| `REF_LINKEDFIELD_MISSING` | `linkedfield` no es campo de la coll de `mapcol` |
| `REF_JS_COLL_MISSING` | Script referencia a una colección inexistente (`openEditView`, `getCollection`, `openMenu`) |
| `REF_NODE_MISSING` | Referencia a nodo/evento inexistente |
| `REF_FUNC_MISSING` | Referencia a función inexistente |

**Nota**: los códigos son case-sensitive y con prefijo `REF_`/`ANTIPATTERN_`. Al revisar la salida, priorizar errores; cada warning debe justificarse o corregirse.

## Revisión XML/UI

- Estructura `coll > group > frame > prop` correcta; jerarquía sin elementos fuera de lugar.
- `prop` siempre con `name` y `type` válido (lista de tipos: `T`, `TN`/`TN2`-`TN6`, `N`/`N2`-`N6`, `D`, `DT`, `TT`, `B`, `L`, `TL`, `NC`, `X`, `IMG`, `PH`, `VD`, `DR`, `WEB`, `AT`, `O`, `THTML`, `Z`).
- Coll de datos con `sql` (con `##PREF##`), `objname`, `updateobj` y `progid`. Pantalla sin datos (`special="true"`) sin `sql`.
- Combo bien definido: prop oculto `T` con `mapcol`/`mapfld` + prop visible con `linkedto`/`linkedfield`; `mapcol-values` para valores fijos.
- Mapa con `type="Z" viewmode="mapview"` vinculado a un `<contents>`.
- `visible` bitmask correcto según el modo en que debe mostrarse (0-7).
- Grupos con `id`; un solo grupo visible → `notab="true"`.
- Un solo `before-edit` por coll; no usar `load` para inicializar.
- `##FLD_CAMPO##` y `##PREF##`/`##ENTID##`/`##USERID##` donde apliquen.
- Nombres únicos: sin duplicar colls, props ni contents en la misma coll.

## Revisión JavaScript

- **Patrones de bloqueo**: toda modificación de colección con `unlock`/`lock` en `finally`; navegación con `startBrowse`/`endBrowse` en `finally`; cursor SQL y conexión cerrados en `finally`.
- **Contexto `self`**: en callbacks asíncronos (`$http`, GPS, cámara, `executeActionAfterDelay`), `self` se guarda en variable local antes del callback.
- **Acceso a campos**: `self.CAMPO`/`self.getValue`; nunca `self("CAMPO")` (anti-patrón).
- **Macros**: `coll.setMacro("##N##", valor)`/`getMacro`; nunca `coll.macro(...)`.
- **lock/unlock**: se aplican a la colección, no al DataObject (`self.lock()` es anti-patrón).
- **Sintaxis ES5**: sin template literals, `async/await`, `let/const` solo donde el motor los soporte (preferir `var`).
- **APIs web no disponibles**: sin `document`, `window`, `fetch`, `setTimeout`, `localStorage`, `Promise`. Sustitutos: `ui.getView`, `$http`, `ui.executeActionAfterDelay`, `appData.getGlobalMacro`.
- **Validación antes de guardar**: campos obligatorios, rangos y formatos antes de `save()`; evita `-8100`.
- **Errores del framework**: comprobar `appData.error()` tras `save()`.
- **Refrescos acotados**: `ui.refresh("MAP_CAMPO")` específico; no `ui.refresh()` global.
- **Funciones documentadas** y separación lógica de negocio / UI.
- **Constantes** en lugar de valores mágicos.

## Revisión CSS

- Archivo `default.css` en la raíz, declarado en `app.xml`; selectores `coll` y `prop` globales presentes.
- Unidades `p`/`%`; sin `px`, `em`, `rem`, `vh`, `vw`.
- `fontsize`, `border-corner-radius`, `border-width`, `labelwidth` sin unidad.
- Colores `#RRGGBB` (6 dígitos) o `#AARRGGBB` (alpha PRIMERO); sin nombres de color ni abreviaturas.
- Márgenes/padding individuales (`tmargin`, `lpadding`, ...); sin `margin`/`padding` abreviado.
- `extends: .clase` con prefijo punto; sin herencia circular.
- Selectores solo `coll`, `prop`, `prop:TYPE`, `.clase`, `group`, `frame`; sin combinadores ni IDs.
- `visible` bitmask y valores booleanos `true`/`false`.
- Paleta en `colors.css`; temas con `default_night.css`/`default_day.css`.

## Revisión datos / integración

- SQL de colecciones con `##PREF##`; nunca el prefijo literal.
- SQL directo parametrizado (`SqlManager.doRawQuery` con `?`); sin concatenación de entrada de usuario (SQL injection).
- Cursor y conexión cerrados en `finally`.
- `$http` con `allowUnsafeCertificates: false` en producción; TLS/HTTPS; `enablePinning` donde aplique.
- Tokens cifrados en macros globales; credenciales nunca hardcodeadas ni logueadas.
- Validación y saneamiento de entrada antes de guardar.
- Réplica: config en `Empresas`; manejo de `sys-message` correcto.

## Revisión device

- Permisos pedidos antes de GPS/cámara/micrófono/biometría.
- GPS: `GPSColl` con `startBrowse`/`endBrowse`, verificación de `STATUS` y `LONGITUD`.
- Cámara: `filename` en `takePicture`; callbacks con verificación de null.
- Timers: `executeActionAfterDelay` en lugar de `sleep`.
- Cierres de Bluetooth/WebSocket al finalizar.

## Anti-patrones a buscar

1. `load` para inicializar en lugar de `before-edit`.
2. Múltiples `before-edit` en una coll.
3. `self("campo")` en vez de `self.campo`.
4. `self.lock()`/`self.unlock()` en vez de la colección.
5. `coll.macro(...)` en vez de `setMacro`/`getMacro`.
6. Concatenar input del usuario en SQL.
7. `ui.refresh()` global en vez de campos concretos.
8. Acceso a `self` dentro de callbacks sin guardar referencia.
9. `ui.sleep()` bloqueante.
10. Unidades `px`/`em`/`rem` y atributos CSS web (`font-size`, `margin-top`, `background-color`).
11. `visible` con bitmask incorrecto (campo que "desaparece" en un modo).
12. VBScript en includes.
13. Template literals o `async/await` en scripts.
14. `setTimeout`/`fetch`/`localStorage`/`document` (APIs inexistentes).

## Checklist de entrega

Antes de dar por bueno un cambio:

- [ ] `xone-simulator validate` sin errores (warnings justificados o corregidos).
- [ ] `xone-simulator smoke` termina con éxito (sin failures).
- [ ] Pantallas nuevas cumplen la estructura `coll > group > frame > prop`.
- [ ] Colls de datos con `sql`, `objname`, `updateobj` y `progid`.
- [ ] Un solo `before-edit` por coll; sin `load` para inicializar.
- [ ] `##PREF##` en toda SQL de colección.
- [ ] Todo `unlock` tiene su `lock` en `finally`; todo `startBrowse` su `endBrowse`.
- [ ] Cursores y conexiones SQL cerrados en `finally`.
- [ ] Callbacks asíncronos preservan `self` en variable local.
- [ ] Validación de entrada antes de `save()`.
- [ ] SQL parametrizado; sin concatenación de input.
- [ ] CSS con unidades `p`/`%` y colores en formato correcto.
- [ ] `allowUnsafeCertificates: false`; sin credenciales hardcodeadas.

## Severidad y reporte

| Severidad | Definición | Acción |
|-----------|------------|--------|
| Crítico | Bloquea entrega (error del validador, SQL injection, coll sin `progid`, `before-edit` duplicado) | Corregir antes de entregar |
| Alto | Riesgo de bug en runtime (`self` en callback, lock sin `finally`, `-8100` por no validar) | Corregir en el mismo cambio |
| Medio | Mala práctica o rendimiento (uso de `load`, refresh global, `sleep`) | Corregir o registrar deuda técnica |
| Bajo | Estilo/consistencia (nombres, comentarios, secciones CSS) | Sugerencia, no bloqueante |

Reporta cada hallazgo con: `archivo:línea`, severidad, código (si existe) y causa raíz con la corrección sugerida. Prioriza errores del validador, después patrones de bloqueo y contexto, después rendimiento y estilo.
