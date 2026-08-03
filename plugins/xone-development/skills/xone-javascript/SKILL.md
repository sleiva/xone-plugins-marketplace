---
name: xone-javascript
description: Programación JavaScript en XOne. Usar al escribir o depurar scripts en eventos XML, acceso a self/ui/appData/$http, colecciones y contents, callbacks asíncronos, patrones lock/unlock y startBrowse/endBrowse, SQL seguro, o utilidades de functions.js.
---

# XOne JavaScript

Usa esta skill para JavaScript ejecutado en bloques `<script>` de `.xne` y en `functions.js`. No es JavaScript de navegador ni Node: no hay módulos (`require`/`import`) y el código compartido es global.

## Reglas esenciales

- Los objetos principales son `self` (DataObject actual), `ui`, `appData`, `$http`, `replica` y `crypto`; `console` solo ofrece `console.log()`.
- No uses `document`, `window`, `localStorage`, `fetch`, `setTimeout`, `navigator.geolocation`, `alert` ni `async/await`; usa `ui`, `appData`, `$http` y callbacks según [references/api.md](references/api.md).
- Inicializa pantallas en `<before-edit>`; `<create>` se ejecuta una vez y `<load>` no es fiable para inicialización.
- Los nombres de props, eventos, contents y colecciones son case-sensitive.
- `MAP_` suele ser un campo transitorio: no lo trates como persistente sin verificar el modelo.
- En callbacks asíncronos guarda `var contexto = self` antes de la llamada y comprueba la vista antes de usar controles.
- `ui.refresh()` debe recibir solo los campos afectados; usa `ui.refreshValue()` cuando no sea necesario reconstruir el control.

## Patrones críticos

Modifica colecciones solo dentro de `unlock()` y garantiza `lock()` en `finally`. Navega con `startBrowse()`/`endBrowse()` en `finally`. Al filtrar, guarda y restaura el filtro original. Cierra siempre cursores y conexiones SQL. Mantén abierto un `WaitDialog` solo dentro de `try/finally`.

```javascript
var original = coll.getFilter();
try {
    coll.unlock();
    coll.setFilter("ACTIVO = 1");
    coll.loadAll();
    // procesar
} finally {
    coll.setFilter(original);
    coll.lock();
}
```

Para contents: `getContents(nombre)` -> `unlock` -> `createObject`/`addItem` -> `lock` -> `saveAll`. Para SQL, usa parámetros `?`, no concatenes entrada de usuario. Para `$http`, parsea la respuesta string con `try/catch`, cancela futures de búsquedas anteriores y no habilites certificados inseguros en producción.

## Eventos y acceso básico

Eventos habituales: `<create>`, `<before-edit>`, `<onchange>`, `<selecteditem>`, `<onback>` y scripts personalizados invocados mediante `executeNode()`. Accede a datos con `self.CAMPO`, `self["CAMPO"]` o `getValue/setValue`; usa `selfDataColl` para la colección contenedora.

```javascript
var n = self.getValue("MAP_NOMBRE");
self.MAP_NOMBRE = "texto";
ui.refreshValue("MAP_NOMBRE");
```

## Seguridad y rendimiento

- No hardcodees credenciales ni registres tokens; cifra los datos sensibles y limpia la sesión al cerrar.
- Valida campos obligatorios, longitud, rangos y formato antes de `save()`; un obligatorio vacío puede producir `-8100`.
- Usa `saveAll()` al final de bucles, `clear()` tras procesar colecciones y `createSearchIndex()`/`doSearch()` para búsquedas grandes.
- Prefiere `ui.executeActionAfterDelay()` a una espera bloqueante.

## Anti-patrones

| Evitar | Usar |
|---|---|
| `load` para inicializar | `before-edit` |
| `addItem` con la colección bloqueada | `unlock` + `try/finally` + `lock` |
| `self` dentro de un callback sin conservarlo | `var contexto = self` |
| `document`/`fetch`/`localStorage` | `ui`/`$http`/macros globales |
| SQL concatenado con entrada externa | parámetros `?` o escape validado |
| refresh de toda la vista | `refresh`/`refreshValue` específico |

## Recursos adicionales

- API exhaustiva de `DataCollection`, `UserInterface`, `AppData` y `SqlManager`: [references/api.md](references/api.md)
- Ejemplos extensos de HTTP, GPS, contents, SQL y filtros: [references/examples.md](references/examples.md)
- Errores comunes y soluciones: [references/troubleshooting.md](references/troubleshooting.md)
