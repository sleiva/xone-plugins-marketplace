---
name: xone-development
description: Fundamentos y estructura de un proyecto XOne. Usar al crear un proyecto desde cero, al entender o modificar app.xml, app.ini, mappings.xne, la anatomía de carpetas (bd, icons, files, fonts), el prefijo ##PREF##, las macros del sistema, los códigos de error, el flujo Splash→Login→EntradaApp→Menu, las convenciones de nombres, o al preguntar qué sintaxis JavaScript soporta el motor.
---

# XOne — Fundamentos y reglas transversales

Estas son las reglas que aplican a cualquier trabajo sobre un proyecto XOne, sea XML, JavaScript o CSS. **No afirmes nada que no esté en las referencias de esta skill o de las especializadas.** Si una API, atributo o comportamiento no aparece, dilo y pide el dato; no lo deduzcas por analogía con la web ni con otros frameworks.

## Siempre

1. **Consulta la referencia antes de responder.** Cada área tiene su fichero; están indexados abajo y en las skills especializadas.
2. **La fuente es el `.xne`.** Los ficheros `.xml` de colecciones y pantallas son artefactos generados automáticamente por XOneStudio a partir de los `.xne`: no se leen, no se editan, no se consultan. La única excepción es `app.xml`, que sí es fuente. Si conviven `.xne` y `.xml`, trabaja solo sobre los `.xne`.
3. **`progid` es opcional.** Sin él, la coll es un objeto de datos genérico (equivalente a `ASData.CASBasicDataObj`). Solo **Empresas** (`ASGestion.CASEmpresa`) y **Usuarios** (`ASGestion.CASUser`) requieren el suyo para activar su lógica de negocio. No inventes progids.
4. **Encoding coherente en los `.xne`.** El motor respeta el `encoding` declarado en el prólogo y asume UTF-8 si falta. UTF-8 e iso-8859-15 son válidos; lo que corrompe tildes y eñes es declarar uno y guardar en otro.
5. **`ID` y `ROWID` los gestiona la plataforma.** No hace falta declararlos como `<prop>` (es válido pero redundante). En el `sql=` de la coll, `ID` sí se rescata en el SELECT; `ROWID` no es necesario.
6. **Inicializa con el evento correcto:** `<before-edit>` al abrir para editar, `<create>` la primera vez. `<load>` se dispara **por cada DataObject** al cargar desde la BD (startBrowse, loadAll, `<contents>`) y no se recomienda por rendimiento.
7. **Los nombres son únicos y case-sensitive.** Ver la sección de unicidad más abajo.

## Nunca

1. **No inventes** atributos XML, funciones JavaScript ni propiedades CSS que no estén en las referencias. XOne ignora silenciosamente los atributos desconocidos, así que un invento no da error: da un bug silencioso.
2. **No uses APIs del DOM.** No existen: `document`, `window`, `localStorage`, `sessionStorage`, `XMLHttpRequest`, `navigator`, `history`.
3. **No uses VBScript.** Está descontinuado en XOne aunque alguna referencia histórica lo mencione. La única opción válida es `<script language="javascript">`; si encuentras un ejemplo en VBScript, tradúcelo antes de proponerlo.
4. **No mezcles patrones de React, Angular, Vue** ni de ningún framework web.
5. **No repitas nombres de nodos dentro de la misma colección.**
6. **No uses `<load>`** para inicializar una pantalla: produce bugs silenciosos.

## Sintaxis JavaScript que soporta el motor

**Sí:** `let`, `const`, arrow functions, destructuring, `class` (con `extends`, `super`, `static`, getters/setters, computed keys, field declarations y generator methods con `*`), `Promise` (ES2024 completo: `all`, `allSettled`, `race`, `any`, `withResolvers`, `.then`, `.catch`, `.finally`), generadores con `yield` (runtime estilo SpiderMonkey legacy: `.next()` devuelve el valor directo y `StopIteration`; no `for...of` sobre generadores), `for...of` sobre arrays y strings, `Symbol`, typed arrays.

**No, a nivel de sintaxis:** template literals `` `${x}` ``, `async`/`await`, spread/rest, parámetros por defecto, optional chaining `?.`, nullish coalescing `??`, computed keys en object literals (sí en cuerpo de clase), campos privados `#name`, bloques `static`.

**Sí existen con implementación custom de XOne** (semántica compatible con WHATWG): `fetch(input, init?)` con limitaciones (no admite `Request` como primer argumento, ni body `FormData`/`Blob`/`ReadableStream`, ni cancelación real en vuelo), `setTimeout`/`clearTimeout`/`setInterval`/`clearInterval`/`queueMicrotask`, `URL`/`URLSearchParams`, `Headers`, `AbortController`/`AbortSignal`, `Response`, `EventTarget`, `TextEncoder`/`TextDecoder`, `console` completo (`log`, `info`, `debug`, `warn`, `error`, `trace`, `assert`, `group`, `time`, `table`… con formato `%s`/`%d`/`%j`), `performance.now()`, `atob`/`btoa`, `structuredClone`, `DOMParser`/`XMLSerializer`, `globalThis`.

Aun existiendo, lo idiomático en XOne es `$http` en vez de `fetch`, y `ui.executeActionAfterDelay` en vez de `setTimeout`.

## Unicidad y nombres

- El ámbito de unicidad es la **`<coll>` entera**, no el `<group>` ni el `<frame>`: no puede haber dos `<prop>`, dos `<group>`, dos `<frame>` ni dos eventos con el mismo `name` en ninguna parte de la misma coll, aunque estén en grupos distintos. El `name` se publica a nivel de coll (los `collprops`) y se volvería ambiguo.
- Dos `<coll>` distintas **sí** pueden tener contenido idéntico, siempre que su propio `name` sea distinto. Dos colls con el mismo `name` en el proyecto no son válidas.
- El atributo `name` es **case-sensitive**, y eso aplica a todas las referencias cruzadas: `self.MiNombre`, `mapcol`, `linkedto`, `inherits`, `<field name="...">`, `getControl("...")`, `ui.openEditView("...")`, `appData.getCollection("...")`.
- En cada `<group>`, `id` es obligatorio y único dentro de la coll. Convención habitual: `1`, `2`, `3`… para grupos normales, `999` para HEADER fijo y `0` para FOOTER fijo.
- Prefijo `MAP_`: solo para campos **no persistidos** (UI temporal, JOIN, `linkedto`). El framework excluye `MAP_*` de INSERT y UPDATE. Los campos de BD van sin prefijo.

## Tipos de prop válidos

| Tipo | Descripción |
|---|---|
| `T` | Texto editable |
| `TN` / `TN2`…`TN6` | Texto numérico; el sufijo son los decimales visibles |
| `L` | Etiqueta de solo lectura. Sin `title`, muestra el valor del campo |
| `TL` | Alias legacy de `L` |
| `THTML` | Texto con formato HTML |
| `N` / `N2`…`N6` | Número; el sufijo son los decimales visibles |
| `D` / `DT` / `TT` | Fecha / fecha y hora / solo hora |
| `B` | Botón |
| `NC` | Checkbox, toggle, radio o switch |
| `X` | Password enmascarado |
| `IMG` / `PH` | Imagen referenciada / foto capturable |
| `VD` | Vídeo o escáner QR/barcode |
| `DR` | Dibujo o firma digital |
| `Z` | Contenedor de lista embebida |
| `WEB` | WebView |
| `AT` | Adjunto |
| `O` | Sub-objeto JavaScript, no persiste |

Los combos **no tienen tipo propio**: se hacen con `type="T"` (o `type="N"`) más `mapcol` y `mapfld`. No existen `type="C"`, `"M"`, `"A"`, `"F"`, `"S"`, `"P"`, `"E"`, `"R"`, `"H"`, `"W"`, `"CAM"`, `"ARRAY"`, `"STRING"`, `"N1"` ni `"BT"`.

## Visibilidad

Bitmask de 4 bits: `1` edición · `2` lista · `4` content · `8` combo. Cualquier combinación es válida.

| Valor | Contextos |
|---|---|
| `0` | Ninguno: campo interno, solo para lógica |
| `1` | Solo formulario de edición |
| `2` | Solo lista |
| `3` | Edición + lista |
| `4` | Solo content (lista embebida) |
| `7` | Edición + lista + content — **el más habitual** |
| `8` | Solo combo |
| `15` | Todos |

`visible` es **estático**: no se cambia en runtime, ni por script ni por eventos. Para visibilidad condicional se usa `disablevisible="CAMPO=valor"`, que sí es dinámico.

## Ciclo de vida

| Necesito | Evento |
|---|---|
| Inicializar la primera vez | `<create>` |
| Inicializar al abrir para editar | `<before-edit>` |
| Ejecutar tras entrar en edición | `<after-edit>` |
| Reaccionar a cada ítem al cargar una colección (no recomendado) | `<load>` |
| Cambio de campo | `<onchange>` + `<field name="CAMPO">` |
| Botón atrás | `<onback>` |

No existen `<unload>`, `<ondelete>`, `<beforedelete>` ni `<afterdelete>`. Para borrado hay `<delete>` con hijos `<rule>`, que es un bloque de reglas, no un evento antes/después. Solo puede haber un `<before-edit>` por coll.

## JavaScript embebido en `.xne`

Para JS no trivial, la forma preferida es declarar la función en un `.js` externo (`functions.js` u otro incluido) y llamarla desde el XML con `miFuncion();`, escribiendo el JS normal, sin entidades ni CDATA. Para snippets cortos inline: dentro de un nodo `<script>` valen tanto entidades XML (`&lt;`, `&gt;`, `&amp;`) como `<![CDATA[…]]>`; dentro de un atributo (`onclick=`, `disablevisible=`) **solo entidades**, porque CDATA no es válido en atributos XML.

## Referencias

| Para… | Lee |
|---|---|
| Qué es XOne, arquitectura, ciclo de vida colección/objeto/propiedad, sincronización, anatomía de carpetas y tipos de fichero | [references/plataforma-y-anatomia-de-proyecto.md](references/plataforma-y-anatomia-de-proyecto.md) |
| `app.xml` atributo por atributo, `app.ini` y `mappings.xne` | [references/configuracion-app-xml-ini-mappings.md](references/configuracion-app-xml-ini-mappings.md) |
| Colecciones, DataObject, props, `##PREF##`, macros del sistema, códigos de error y detalle de la sintaxis JS soportada | [references/conceptos-clave.md](references/conceptos-clave.md) |
| Flujo Splash→Login→EntradaApp→Menu, convenciones de nombres y creación de un proyecto básico paso a paso | [references/navegacion-convenciones-y-primer-proyecto.md](references/navegacion-convenciones-y-primer-proyecto.md) |
| Errores frecuentes al empezar y su corrección | [references/errores-comunes.md](references/errores-comunes.md) |

Para el detalle de cada área, usa la skill correspondiente: `xone-xml-ui`, `xone-javascript`, `xone-css`, `xone-data-integration`, `xone-device`. Para crear un proyecto completo desde cero, `xone-project-generator`. Para validar y auditar, `xone-review`; para diagnosticar un fallo a partir de su síntoma, `xone-debugging`.
