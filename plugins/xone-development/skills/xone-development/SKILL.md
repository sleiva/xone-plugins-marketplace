---
name: xone-development
description: Desarrollo experto de aplicaciones XOne. Usar al crear o revisar XML .xne, JavaScript XOne, CSS XOne, colecciones, pantallas, navegación, integraciones HTTP, permisos, GPS, cámara, sincronización o al depurar errores de runtime.
---

# XOne Development

Ayuda a desarrollar aplicaciones móviles con la plataforma XOne. Antes de proponer código, inspecciona la estructura y los archivos existentes del proyecto. Respeta siempre las convenciones que ya use el proyecto salvo que estén causando un error.

## Método de trabajo

1. Identifica si el problema afecta a XML, JavaScript, CSS, datos, navegación o configuración.
2. Busca definiciones y usos relacionados antes de editar.
3. Propón el cambio mínimo que resuelva el problema.
4. Mantén separados layout, lógica y estilos cuando el proyecto lo permita.
5. Comprueba sintaxis XML, nombres únicos de nodos y referencias entre colecciones.
6. Resume qué cambió, qué se verificó y cualquier limitación del runtime.

## Reglas XOne críticas

- Las colecciones se declaran con `<coll>` y los controles con `<prop>` dentro de `<group>` o `<frame>`.
- Los tipos habituales son `T`, `TN`, `N`, `D`, `DT`, `TT`, `B`, `L`, `THTML`, `WEB`, `IMG`, `PH`, `VD`, `DR`, `NC`, `X`, `Z`, `AT` y `O`. No inventes tipos.
- Un combo usa `type="T"` con `mapcol`, `mapfld` y, cuando corresponda, `linkedfield`; no uses `type="C"`.
- Un mapa usa `type="Z" viewmode="mapview"`; no uses un tipo de mapa inventado.
- El primer elemento de una fila no debe llevar `newline="false"`; ese atributo se aplica a los siguientes elementos de la fila.
- Los nombres de props, groups, frames y contents deben ser únicos dentro de su ámbito.
- `before-edit` inicializa una pantalla al abrirse. `create` se usa para inicialización de objetos nuevos. No uses `load` para inicializar una pantalla: se ejecuta por cada objeto cargado y puede degradar el rendimiento.
- El splash es un fichero estático en la raíz del proyecto; no lo confundas con `EntradaApp` ni con `load-imgbk`.
- En CSS XOne usa unidades `p` y `%`, no `px`, `em` o `rem`. Los colores con alpha usan formato `#AARRGGBB`.
- Si `compatibility-mode="true"` está activo en `app.xml`, el CSS se ignora.

## JavaScript XOne

- Usa `self` para el objeto actual, `selfDataColl` para su colección, `appData` para datos de aplicación y `ui` para navegación e interfaz.
- Para abrir una pantalla usa normalmente `ui.openEditView(...)`; `ui.openMenu(...)` abre la lista de una colección.
- Para refrescar usa `ui.refresh()` o `window.refreshValue()` solo cuando sea necesario. Evita refrescos repetidos dentro de bucles.
- Los singletons se usan directamente: `$http`, `crypto`, `deviceInfo` y `systemSettings`. No los instancies con `new`.
- Para objetos XOne creables usa el constructor documentado, por ejemplo `new FileManager()` o `new Animation()`.
- Preserva el contexto de `self` en callbacks asíncronos guardándolo en una variable local.
- El runtime soporta un subconjunto de ES6+. Evita template literals, `async`/`await`, spread/rest, optional chaining y parámetros por defecto salvo que el proyecto confirme soporte.
- Escapa JavaScript embebido en XML o usa CDATA correctamente.
- Valida y escapa entradas antes de construir SQL o URLs. Nunca interpolas credenciales ni secretos en código enviado al dispositivo.

## Respuesta y revisión

Cuando generes una solución:

- Incluye nombres de archivo y fragmentos directamente aplicables.
- Explica supuestos si falta información del proyecto.
- Señala APIs o atributos no confirmados en vez de inventarlos.
- En una revisión, prioriza errores funcionales, regresiones, seguridad y rendimiento sobre estilo.
- Si el cambio es XML, revisa también que el prólogo y el encoding declarado coincidan con el fichero.
- Si el cambio requiere permisos, indica el nodo `<permissions>` y el permiso de runtime correspondiente.

## Diagnóstico rápido

- Si una pantalla aparece vacía, revisa primero el XML, el primer `newline`, los nombres duplicados, `visible`, `disablevisible` y `compatibility-mode`.
- Si la inicialización no ocurre, mueve la lógica de `load` a `before-edit` o `create` según corresponda.
- Si un control no responde, confirma el nombre exacto usado por `getControl("NOMBRE")` y que la ventana destino esté visible.
- Si una lista es lenta, evita trabajo pesado en `load`, limita refreshes y usa browse/contents de forma controlada.
- Si una petición falla, revisa método, URL, autenticación, certificado TLS, permisos y el tratamiento del Future/callback.
