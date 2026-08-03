---
description: Desarrollo de XML/UI en XOne. Usar al crear o modificar colecciones (.xne), props, groups, frames, contents, layouts, herencia, macros, permisos, o al diagnosticar errores estructurales y pantallas vacías.
---

# XOne XML / UI

Ayuda a crear y corregir la capa declarativa de XOne: ficheros `.xne`, estructura `coll > group > frame > prop`, `contents`, macros y permisos. Antes de proponer código, inspecciona los `.xne` y el CSS del proyecto para respetar sus convenciones.

## Reglas estructurales

- La jerarquía de pantalla es `coll > group > frame > prop`. Un `<prop>` vive dentro de un `<group>` o `<frame>`.
- La colección se declara con `<coll name="...">`; los controles con `<prop name="..." type="...">`.
- Una coll de datos requiere `sql`, `objname` y `updateobj`, y usa `##PREF##` como prefijo de tabla (ej. `sql="SELECT * FROM ##PREF##Clientes"`).
- Una pantalla sin datos (menú, login, splash) usa `special="true"` y **no** debe llevar `sql`.
- `notab="true"` si solo hay un grupo visible.
- El nodo `<prop>` tiene dos atributos obligatorios: `name` y `type`.
- Los campos de UI que no se persisten usan el prefijo `MAP_` (ej. `MAP_BTN_GUARDAR`). Los campos sin `MAP_` se mapean a columnas de BD.

## Tipos de prop válidos

El validador `xone-simulator` solo acepta estos tipos:

`T` texto · `TN`/`TN2`–`TN6` texto numérico · `N`/`N2`–`N6` número · `D` fecha · `DT` fecha y hora · `TT` hora · `B` botón · `L` label · `TL` label legacy · `NC` checkbox/toggle/radio · `X` password · `IMG` imagen · `PH` foto · `VD` vídeo/cámara/QR · `DR` dibujo/firma · `WEB` webview · `AT` adjunto · `O` sub-objeto JS · `THTML` texto HTML · `Z` contenedor de lista embebida.

No uses tipos no documentados ni nombres legacy no soportados (`C`, `M`, `F`, `S`, `P`, `E`, `R`, `H`, `W`, `A`, `CAM`, `ARRAY`, `STRING`, `BT`): fallan la validación o se ignoran.

## Combo y selector

Un combo son **dos props vinculados**: uno oculto que guarda el ID y otro visible que muestra la descripción. No uses un tipo de combo inventado.

```xml
<prop name="ID_TIPO" type="N" visible="0"
      mapcol="TiposProducto" mapfld="ID" />

<prop name="TIPO_DESC" type="T" visible="1"
      title="Tipo de producto"
      linkedto="ID_TIPO"
      linkedfield="DESCRIPCION"
      showinline="true" />
```

Para valores fijos sin tabla, usa `mapcol-values` en el prop oculto:

```xml
<prop name="MAP_IDTIPOIDEN" type="T" visible="0"
      mapcol-values="CC, TI, CE, Otro, Varios" mapfld="DATA" />
<prop name="TIPOIDENTIFICADOR" type="T" visible="1"
      linkedto="MAP_IDTIPOIDEN" linkedfield="DATA" />
```

Reglas de referencia (validadas por `xone-simulator`): `mapcol` debe apuntar a una coll existente; `mapfld` y `linkedfield` deben ser campos reales de esa coll.

## Mapa

Un mapa con marcadores usa `type="Z" viewmode="mapview"` vinculado a un `<contents>`, no un tipo de mapa inventado:

```xml
<prop name="MAP_MAPA" type="Z" visible="1"
      viewmode="mapview" contents="mapaDatos"
      width="100%" height="80%"
      show-user-location="true" />
<contents name="mapaDatos" src="ContentMapa" />
```

## Lists y contents

Un `<contents>` define una relación padre-hijo y se vincula a un `<prop type="Z">`:

```xml
<prop name="MAP_LISTA" type="Z" visible="1"
      contents="@MiContent" viewmode="recyclerview"
      width="100%" height="60%" edit-inrow="true" />

<contents name="@MiContent" src="ColeccionHija" />
```

- El `name` del contents lleva prefijo `@`; sin él no se vincula correctamente.
- `src` es obligatorio y debe apuntar a una coll existente.
- `filter` y `sort` son opcionales (SQL/orden).
- Para listas largas usa `viewmode="recyclerview"`.
- Filtros dinámicos por el objeto padre: `##FLD_CAMPO##` en el `filter` (ej. `filter="IDPADRE=##FLD_IDPADRE##"`).

## Layout: filas y columnas

- Los elementos son `newline="true"` por defecto (se apilan verticalmente).
- Para colocar elementos en la misma fila, usa `newline="false"` **en el segundo y siguientes** elementos de la fila. El primer elemento de la fila no debe llevar `newline="false"` (si el primero lo lleva, puede no montarse la fila completa).
- Ancho/altura en `p` o `%`, nunca `px`, `em` ni `rem`.

## Visibilidad (bitmask)

El atributo `visible` es un mapa de bits: `1` edición · `2` lista · `4` content · `8` combo.

- `7` = visible en edición + lista + content (el más común).
- `0` = oculto (solo lógica interna).
- `15` = todos los contextos.
- `disablevisible="CAMPO=VALOR"` oculta el control condicionalmente según el valor de otro campo.

## Eventos y ciclo de vida en XML

- `before-edit`: inicializa la pantalla al abrirse. Es lo correcto para preparar una pantalla.
- `create`: inicialización la primera vez.
- `after-edit`: tras editar.
- **No uses `<load>` para inicializar pantallas**: se dispara por cada DataObject cargado y degrada el rendimiento (lo detecta `xone-simulator` como `ANTIPATTERN_LOAD_EVENT`).
- Solo puede haber **un** `<before-edit>` por coll (múltiples = `ANTIPATTERN_MULTIPLE_BEFORE_EDIT`).
- En un botón usa `onclick` **o** `method="ExecuteNode(...)"`, nunca ambos a la vez.
- Lógica compleja en botones: usa `method="ExecuteNode(nombre)"` y un nodo aparte, en vez de meterla en `onclick`.

## progid

- `progid` es opcional en la mayoría de colls. Solo colecciones especiales requieren el suyo:
  - `ASData.CASBasicDataObj` — objeto genérico (por defecto)
  - `ASGestion.CASEmpresa` — colección Empresas
  - `ASGestion.CASUser` — colección Usuarios
- No inventes `progid`: el validador solo acepta esos tres.

## Splash

- El splash es un **fichero estático en la raíz del proyecto** (`splash.png`/`.jpg`/`.gif`/`.webp`/`.apng`/`.mp4`/`.3gp`) que el framework carga automáticamente al arrancar.
- No es una `<coll>`, no es `EntradaApp` (pantalla post-login de bienvenida), ni es `load-imgbk` del `<app>` (imagen de fondo del EditView).

## Encoding y XML

- El motor respeta el `encoding` declarado en el prólogo (y asume UTF-8 si falta).
- Válidos: UTF-8 e iso-8859-15. Lo crítico es que el encoding declarado coincida con cómo está guardado el fichero.
- Escapa el JavaScript embebido con entidades XML o CDATA.

## Macros

- `##PREF##`: prefijo de tablas (obligatorio en SQL).
- Macros de sistema: `##NOW_TIME##`, `##USERID##`, `##DEVICE_OS##`, `##DEVICE_TYPE##`, `##CURRENT_ORIENTATION##`, `##FRAME_VERSION_CODE##`, etc.
- `##FLD_CAMPO##`: valor del campo del objeto padre en un `contents`.
- La API correcta desde JS es `setMacro("##NOMBRE##", valor)` / `getMacro("##NOMBRE##")`. No uses `coll.macro(...)` (anti-patrón).

## Permisos

Los permisos de plataforma se declaran con el nodo `<permissions>` y algunos requieren solicitud en runtime. Ejemplos de valores: `location-foreground`, `location-background`, `camera`, `notifications`.

## Anti-patrones frecuentes

1. Inventar atributos XML o tipos de prop: se ignoran o fallan la validación.
2. Usar `px`/`em`/`rem` como unidades (usar `p` y `%`).
3. Mezclar `onclick` y `method` en el mismo botón.
4. `<load>` para inicializar pantallas (usar `before-edit`).
5. Más de un `<before-edit>` por coll.
6. `loadall="true"` en tablas grandes (bloquea la app).
7. Contents sin prefijo `@`.
8. `special="true"` junto con consultas SQL (excluyentes).
9. CSS web estándar en vez de CSS XOne.
10. `progid` inventado.

## Diagnóstico rápido

- **Pantalla vacía**: revisa el XML, el primer `newline` de cada fila, nombres duplicados, `visible`/`disablevisible`, `special`/`sql` y `compatibility-mode` (si es `true`, el CSS se ignora).
- **Lista que no muestra datos**: contents con `@`, `src` correcto, `viewmode` válido y `filter`/`##FLD_CAMPO##` correctos.
- **Combo vacío**: `mapcol` debe apuntar a una coll con datos y `mapfld`/`linkedfield` a campos reales.
- **Botón que no responde**: confirma `onclick` o `method`, y que el handler exista.
- **Validación con `xone-simulator`**: ejecuta `validate` para confirmar tipos, referencias y anti-patrones antes de entregar el XML.
