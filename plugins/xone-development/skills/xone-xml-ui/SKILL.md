---
name: xone-xml-ui
description: Desarrollo de XML/UI en XOne. Usar al crear o modificar colecciones .xne, props y sus tipos, groups, frames, contents, asfilter, combos con mapcol/mapfld, mapas, kanban, chips, layouts, herencia con inherits, include-layout, macros, eventos XML, permisos, o al diagnosticar pantallas vacías y errores estructurales.
---

# XOne XML / UI

Capa declarativa de XOne: ficheros `.xne`, jerarquía `coll > group > frame > prop`, `contents`, macros, eventos y permisos. Antes de proponer código, inspecciona los `.xne` y el CSS del proyecto para respetar sus convenciones.

**No inventes atributos ni tipos.** XOne ignora silenciosamente los atributos desconocidos: un invento no da error, da un bug silencioso. Si un atributo no está en las referencias, dilo.

## Reglas estructurales

- Jerarquía: `coll > group > frame > prop`. Un `<prop>` vive dentro de un `<group>` o de un `<frame>`.
- Una coll de datos lleva `sql`, `objname` y `updateobj`, y usa `##PREF##` como prefijo de tabla: `sql="SELECT ID, NOMBRE FROM ##PREF##Clientes"`.
- Una pantalla sin datos (menú, login) usa `special="true"` y **no** lleva `sql`. Son excluyentes.
- `<prop>` tiene dos atributos obligatorios: `name` y `type`.
- `notab="true"` cuando solo hay un grupo visible.
- En cada `<group>`, `id` es obligatorio y único dentro de la coll: `1`, `2`, `3`… para grupos normales, `999` para HEADER fijo, `0` para FOOTER fijo.
- Los nombres de `prop`, `group`, `frame` y eventos son únicos en la **coll entera**, no por grupo, y son case-sensitive.
- Prefijo `MAP_` solo para campos no persistidos (UI, JOIN, `linkedto`); el framework los excluye de INSERT y UPDATE.

## Tipos de prop

`T` · `TN`/`TN2`–`TN6` · `N`/`N2`–`N6` · `D` · `DT` · `TT` · `B` · `L` · `TL` (alias legacy de `L`) · `NC` · `X` · `IMG` · `PH` · `VD` · `DR` · `WEB` · `AT` · `O` · `THTML` · `Z`.

No existen `C`, `M`, `A`, `F`, `S`, `P`, `E`, `R`, `H`, `W`, `N1`, `BT`, `CAM`, `ARRAY` ni `STRING`. El detalle de cada tipo con sus atributos está en las referencias.

## Combo y selector

Un combo **no tiene tipo propio**: son dos props vinculados, uno oculto con el ID y otro visible con la descripción.

```xml
<prop name="ID_TIPO" type="N" visible="0" mapcol="TiposProducto" mapfld="ID" />
<prop name="TIPO_DESC" type="T" visible="1" title="Tipo de producto"
      linkedto="ID_TIPO" linkedfield="DESCRIPCION" showinline="true" />
```

Para valores fijos sin tabla, `mapcol-values` en el prop oculto:

```xml
<prop name="MAP_IDTIPOIDEN" type="T" visible="0"
      mapcol-values="CC, TI, CE, Otro, Varios" mapfld="DATA" />
<prop name="TIPOIDENTIFICADOR" type="T" visible="1"
      linkedto="MAP_IDTIPOIDEN" linkedfield="DATA" />
```

`mapcol` debe apuntar a una coll existente, y `mapfld`/`linkedfield` a campos reales de esa coll: `xone-simulator` lo valida.

## Contents y listas

```xml
<prop name="MAP_LISTA" type="Z" visible="1" contents="@MiContent"
      viewmode="recyclerview" width="100%" height="60%" edit-inrow="true" />
<contents name="@MiContent" src="ColeccionHija" />
```

- El `name` del contents lleva prefijo `@`; sin él no vincula.
- `src` es obligatorio y apunta a una coll existente. `filter` y `sort` son opcionales.
- Filtros dinámicos por el objeto padre con `##FLD_CAMPO##`, p. ej. `filter="IDPADRE=##FLD_IDPADRE##"`.
- Un mapa es `type="Z" viewmode="mapview"` vinculado a un `<contents>`, no un tipo inventado.

## Layout

Los elementos son `newline="true"` por defecto y se apilan. Para ponerlos en la misma fila, `newline="false"` va en el **segundo y siguientes**; el primero de la fila nunca lo lleva. Si el primer elemento de un `<frame>` lleva `newline="false"`, el frame entero puede no montarse y sus controles desaparecen de la pantalla. Dimensiones en `p` o `%`, nunca `px`/`em`/`rem`.

## Visibilidad

Bitmask de 4 bits: `1` edición · `2` lista · `4` content · `8` combo. `7` es lo habitual, `15` todos, `0` ninguno. Es **estático**: no se cambia por script. Para condicional, `disablevisible="CAMPO=valor"`. Tabla completa en [references/prop-atributos-y-condiciones.md](references/prop-atributos-y-condiciones.md) §5.3.

## Eventos en XML

- `before-edit` inicializa al abrir; `create` la primera vez; `after-edit` tras entrar en edición.
- **No uses `<load>` para inicializar pantallas**: se dispara por cada DataObject cargado. `xone-simulator` lo marca como `ANTIPATTERN_LOAD_EVENT`.
- Solo un `<before-edit>` por coll (`ANTIPATTERN_MULTIPLE_BEFORE_EDIT`).
- En un botón, `onclick` **o** `method="ExecuteNode(...)"`, nunca ambos. Para lógica compleja, `ExecuteNode` y un nodo aparte.
- `onchange="refresh"` o `onchange="refresh(MAP_CAMPO)"`; `refresh255` es notación legacy de PDA.
- No existen `<unload>`, `<ondelete>`, `<beforedelete>` ni `<afterdelete>`. Para borrado, `<delete>` con hijos `<rule>`.

## progid, splash y encoding

- `progid` es opcional: sin él la coll es un objeto genérico (`ASData.CASBasicDataObj`). Solo **Empresas** (`ASGestion.CASEmpresa`) y **Usuarios** (`ASGestion.CASUser`) requieren el suyo. No inventes progids.
- El splash es un **fichero estático en la raíz** (`splash.png`/`.jpg`/`.gif`/`.webp`/`.apng`/`.mp4`/`.3gp`) que carga el framework. No es una `<coll>`, no es `EntradaApp` (pantalla post-login), y no es `load-imgbk` del `<app>` (fondo del EditView).
- El motor respeta el `encoding` del prólogo y asume UTF-8 si falta. UTF-8 e iso-8859-15 son válidos; lo que rompe tildes y eñes es declarar uno y guardar en otro.

## Macros

`##PREF##` prefijo de tablas · `##FLD_CAMPO##` valor del campo del objeto padre en un contents · macros del sistema como `##NOW_TIME##`, `##USERID##`, `##DEVICE_OS##`, `##DEVICE_TYPE##`, `##CURRENT_ORIENTATION##`, `##FRAME_VERSION_CODE##`.

Una macro de colección debe declararse en el XML antes de usarla: `<macro name="##NOMBRE##" value="..." default="true" />` como hijo directo de `<coll>`, al mismo nivel que los `<group>`. Sin esa declaración, `setMacro` no inyecta nada en el SQL. La API es `setMacro`/`getMacro`; `coll.macro(...)` no existe.

## Anti-patrones

| Incorrecto | Correcto |
|---|---|
| `<prop type="C">` (combo) | `type="T"` + `mapcol` + `mapfld` |
| `<prop type="M">` (mapa) | `type="Z" viewmode="mapview"` |
| `<prop type="A">` (autocomplete) | `type="T"` + `mapcol` + `mapfld` + `linkedfield` |
| `<prop type="IMG" readonly="false">` (firma obsoleta) | `<prop type="DR">` |
| `<prop type="L" labelwidth="0" title="X">` | `<prop type="L" title="X" label-align="center">` — con `labelwidth="0"` el título se pinta en un ancho de cero |
| `<prop type="L" title="...">` esperando que muestre el valor que actualiza el JS | `<prop type="L">` **sin `title`**: el label usa el valor del campo como fallback |
| `newline="false"` en el primer elemento de un frame | Solo en el segundo y siguientes |
| `<prop name="PASSWORD" type="X">` en Usuarios | `<prop name="PWD" type="X">` — el framework lo lee literalmente |
| `<prop name="ID_EMPRESA">` en Usuarios | `<prop name="IDEMPRESA">` — sin guion bajo |
| Dos `<group id="1">` en la misma coll | `id` único por coll |
| Dos `<prop name="X">` en la misma coll, aunque estén en grupos distintos | `name` único en la coll entera |
| `special="true"` junto con `sql` | Son excluyentes |
| Contents sin prefijo `@` | `contents="@MiContent"` |
| `loadall="true"` en tablas grandes | Carga bajo demanda |
| Mezclar `onclick` y `method` en un botón | Uno u otro |

## Referencias

| Para… | Lee |
|---|---|
| Introducción a la UI y nodo `coll`: colecciones de datos vs especiales, valores de `progid`, `sql`, `loadall` | [references/estructura-y-nodo-coll.md](references/estructura-y-nodo-coll.md) |
| `group` (fijos, drawer, tabs) y `frame` (flotantes, bottom sheet, flujo de layout y `newline`) | [references/nodos-group-y-frame.md](references/nodos-group-y-frame.md) |
| Atributos comunes de `prop`, visibilidad completa, dimensiones, estilos inline, comportamiento, bordes, `disablevisible`/`disableedit` | [references/prop-atributos-y-condiciones.md](references/prop-atributos-y-condiciones.md) |
| Props de texto, número, label, botón, checkbox, fecha/hora, imagen, foto, vídeo y escáner | [references/prop-tipos-basicos.md](references/prop-tipos-basicos.md) |
| Props de mapa, grid/lista, chips, kanban y coverflow | [references/prop-tipos-listas-y-mapas.md](references/prop-tipos-listas-y-mapas.md) |
| Combos, web, slider, progress, stepper, OTP, markdown, navbar, password, adjunto, THTML, firma DR, `onchange`, `updates` y `formula` | [references/prop-tipos-combos-y-controles.md](references/prop-tipos-combos-y-controles.md) |
| `contents` (vinculación, filtros dinámicos) y macros (sistema, `setMacro`/`getMacro`) | [references/contents-y-macros.md](references/contents-y-macros.md) |
| `asfilter`, event handlers detallados, sistema de visibilidad y catálogo de macros del sistema | [references/asfilter-visibilidad-eventos-y-macros.md](references/asfilter-visibilidad-eventos-y-macros.md) |
| Plantillas completas de pantalla: login, menú, lista con filtros, detalle, tabs, mapa, chat, dashboard, maestro-detalle, edición en línea, multi-selección | [references/patrones-de-pantalla.md](references/patrones-de-pantalla.md) |
| Layouts responsive, modales, FAB, herencia con `inherits`, `include-layout`, checklist de validación y unicidad de nombres | [references/layouts-herencia-y-buenas-practicas.md](references/layouts-herencia-y-buenas-practicas.md) |
| Cualquier atributo de `coll`, `group` o `frame` con tipo, valores y default | [references/atributos-coll-group-frame.md](references/atributos-coll-group-frame.md) |
| Cualquier atributo de `prop`: colores por estado, bordes, entrada, multimedia, ML, `classid`, sliders, stepper, OTP, kanban, coverflow, chips | [references/atributos-prop.md](references/atributos-prop.md) |
| Atributos de `method`, `macro`, `script`, `event`, `platform`, tipos y atributos globales de la app | [references/atributos-method-macro-script-event-app.md](references/atributos-method-macro-script-event-app.md) |
| `mappings.xne` obligatorio y colecciones en archivos separados | [references/mappings-y-colecciones-separadas.md](references/mappings-y-colecciones-separadas.md) |
| Mapas completos: atributos, eventos y API JavaScript del control | [references/mapas.md](references/mapas.md) |
| Catálogo de eventos: ciclo de vida e interacción (`onclick`, `onchange`, `selecteditem`, `onlongpressitem`, `onback`) | [references/eventos-ciclo-de-vida-e-interaccion.md](references/eventos-ciclo-de-vida-e-interaccion.md) |
| Eventos de drawer y bottom sheet, login, sistema (`onpushreceived`, `maintenance`, `sys-message`), ciclo de aplicación, inactividad, personalizados con `ExecuteNode` y acciones | [references/eventos-sistema-login-y-personalizados.md](references/eventos-sistema-login-y-personalizados.md) |
| Errores comunes de XML y su corrección | [references/errores-comunes-xml.md](references/errores-comunes-xml.md) |

Para validar el XML resultante usa `xone-review` (`xone-simulator validate`).
