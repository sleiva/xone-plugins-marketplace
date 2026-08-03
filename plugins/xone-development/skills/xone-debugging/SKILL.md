---
name: xone-debugging
description: Diagnóstico sistemático de errores y rendimiento en aplicaciones XOne. Usar al depurar pantallas vacías, botones que no responden, eventos que no disparan, colecciones sin datos, self null, errores -8100/-11888, problemas de refresh o de persistencia MAP_, o al analizar fallos con xone-simulator.
---

# XOne Debugging

Diagnostica por capas: reproduce, aísla, corrige y verifica. Antes de cambiar código ejecuta el caso con `xone-simulator` y confirma el síntoma exacto.

## Proceso y herramientas

1. Reproduce el fallo.
2. Aísla XML/UI, evento JS, colección o persistencia.
3. Consulta el síntoma en [references/troubleshooting.md](references/troubleshooting.md).
4. Corrige con el patrón correcto.
5. Ejecuta de nuevo validación y smoke.

```bash
xone-simulator validate ./proyecto
xone-simulator run ./proyecto --coll MiColl --event before-edit
xone-simulator render ./proyecto --coll MiColl
xone-simulator smoke ./proyecto --json
```

Usa `--coll` para acotar, `--json` para salida estructurada y `--db-path` sobre una copia de la BD. El validador detecta `ANTIPATTERN_LOAD_EVENT` y `ANTIPATTERN_MULTIPLE_BEFORE_EDIT`.

## Diagnóstico rápido

- **Pantalla vacía**: verifica `loadAll()`, `visible`, `unlock`, `ui.refresh()`, filtros `##FLD_CAMPO##`, y que `prop type="Z" contents` coincida con `<contents name>`. Un content necesita definición fuente.
- **Botón mudo**: verifica `visible`, `disableedit`, solapamientos y `method="ExecuteNode(nombre)"`.
- **Evento ausente**: nombres exactos y case-sensitive, `refresh`, `method` y errores JS silenciosos.
- **`onchange` ausente**: en `T` ocurre al perder foco; para cada tecla usa `ontextchanged`. `onchange` acepta comandos, no booleanos.
- **Refresh ausente**: usa el nombre exacto del `<prop>`; en callbacks conserva `self` y comprueba `ui.getView(...)`.
- **Datos no persistidos**: `MAP_` es transitorio; utiliza un campo con columna para guardar.
- **`-8100`**: falta un campo obligatorio. **`-11888`** con `##EXIT##` es cierre normal de pantalla y con `##EXITAPP##`, cierre de app.

## Reglas y anti-patrones

- No uses `load` para inicializar ni dupliques `before-edit`.
- No asumas que los contents cargan solos: carga solo lo necesario y refresca lo afectado.
- No modifiques colecciones sin `unlock`/`lock` garantizado en `finally`.
- No uses `MAP_` como si fuera una columna persistente.
- No uses `px`/`em`/`rem` en CSS ni atributos inline incompatibles.
- No apuntes el simulador a la BD original: puede mutarla.

## Recursos adicionales

- Tabla detallada por capa, `onchange`, refresh, colecciones, CSS, GPS y réplica: [references/troubleshooting.md](references/troubleshooting.md)
