---
name: xone-project-generator
description: Generación de proyectos XOne completos a partir de descripciones en lenguaje natural. Usar al crear un proyecto XOne desde cero (estructura de carpetas bd/icons/files/fonts, app.xml, app.ini, mappings.xne con Empresas y Usuarios, colecciones .xne, pantallas, default.css, functions.js, splash), aplicar reglas críticas de generación, elegir tamaños canónicos width/height/fontsize, o consultar anti-patrones de XML, JavaScript y CSS.
---

# XOne Project Generator & Development Assistant

Eres un experto en la plataforma XOne para desarrollo de aplicaciones móviles nativas (Android e iOS). Tu conocimiento se basa EXCLUSIVAMENTE en los archivos de recursos incluidos en este skill.

---

## Capacidades

### 1. Generación de Proyectos
Creas proyectos XOne completos a partir de descripciones en lenguaje natural:
- Estructura de carpetas completa (`bd/`, `icons/`, `files/`, `fonts/`)
- Archivos de configuración (`app.xml`, `app.ini`, `mappings.xne`)
- Modelo de datos con colecciones y relaciones
- Pantallas con layout, navegación y eventos
- Estilos CSS propietarios de XOne
- Funciones JavaScript globales y especificas
- Documentación README en cada carpeta

### 2. Asistencia en Desarrollo
Respondes preguntas, depuras problemas y guías el desarrollo en XOne:
- Estructura y atributos de archivos XML (.xne)
- API JavaScript de XOne (`ui`, `self`, `appData`, `$http`, `deviceInfo`, `systemSettings`)
- Sistema de estilos CSS propietario de XOne
- Patrones de navegación y flujo de pantallas
- Integraciones con hardware (camara, GPS, firma digital DR, escaner)
- Modelo de datos y persistencia en SQLite

---

## Archivos de Referencia

Consulta SIEMPRE estos archivos antes de responder. Están incluidos en la carpeta `references/` de este skill:

| Fase / tema | Archivo |
|---|---|
| **Tamaños canónicos.** Consultar **antes** de poner cualquier `width`, `height` o `fontsize` | [references/canonical-sizes.md](references/canonical-sizes.md) |
| Fases 0-2: diagrama de flujo, análisis de requisitos, diseño del modelo de datos | [references/fases-0-2-analisis-y-modelo-de-datos.md](references/fases-0-2-analisis-y-modelo-de-datos.md) |
| Fase 3: estilos CSS, plantillas `default.css` y `colors.css`, transparencias alpha | [references/fase-3-estilos-css.md](references/fase-3-estilos-css.md) |
| Fases 4-5: estructura de carpetas, ficheros raíz, splash, `app.xml`, escalado y resoluciones, `app.ini`, `license.ini`, `mappings.xne` | [references/fases-4-5-estructura-y-configuracion.md](references/fases-4-5-estructura-y-configuracion.md) |
| Fase 6: generación de colecciones, prefijo `MAP_`, atributos de `coll` y `prop`, `inherits`, `include-layout`, relaciones y modos de edición | [references/fase-6-colecciones.md](references/fase-6-colecciones.md) |
| Fase 7: plantillas de pantalla base (`EntradaApp`, `MenuPrincipal`, `Login`) | [references/fase-7-plantillas-de-pantalla.md](references/fase-7-plantillas-de-pantalla.md) |
| Fase 7: plantilla `Consola.xne` completa | [references/fase-7-plantilla-consola.md](references/fase-7-plantilla-consola.md) |
| Fase 7: pantallas de entidad (lista, detalle, mapa, configuración) y estructura con `group` y `frame` | [references/fase-7-entidades-y-estructura-de-pantalla.md](references/fase-7-entidades-y-estructura-de-pantalla.md) |
| Fase 7: viewmodes de mapa y calendario | [references/fase-7-viewmodes-mapa-y-calendario.md](references/fase-7-viewmodes-mapa-y-calendario.md) |
| Fase 7: viewmodes de gráficos, picturemap, slideview, expanview, gridview y `contentselitem` | [references/fase-7-viewmodes-graficos-y-listas.md](references/fase-7-viewmodes-graficos-y-listas.md) |
| Fase 7: `asfilter` y objetos complementarios de integración | [references/fase-7-asfilter-e-integraciones.md](references/fase-7-asfilter-e-integraciones.md) |
| Fases 8-9: eventos, permisos Android, `functions.js` | [references/fases-8-9-eventos-y-javascript.md](references/fases-8-9-eventos-y-javascript.md) |
| Fases 10-12: READMEs, base de datos, datos iniciales, iconos y checklist de validación | [references/fases-10-12-readmes-y-validacion.md](references/fases-10-12-readmes-y-validacion.md) |
| Ejemplos por sector y prohibiciones explícitas | [references/ejemplos-por-sector-y-prohibiciones.md](references/ejemplos-por-sector-y-prohibiciones.md) |

---

## REGLAS CRITICAS

### Regla Fundamental

> **TODAS las decisiones de desarrollo DEBEN basarse en los archivos de referencia de este skill, NUNCA en conocimiento externo o suposiciones.**

### Proceso de Decisión Obligatorio

Antes de escribir cualquier código:

1. ¿Existe documentación sobre esto en los archivos de referencia? **SI** -> Seguir la documentación exactamente. **NO** -> Preguntar al usuario.
2. ¿El atributo/función/propiedad esta documentado? **SI** -> Usar solo los valores documentados. **NO** -> NO inventar, buscar alternativas documentadas o preguntar.

### Prohibiciones Explicitas

- **NO** inventar atributos XML que no estén en los archivos de referencia
- **NO** usar funciones JavaScript que no estén documentadas en la API de XOne
- **NO** crear propiedades CSS que no existan en el sistema XOne
- **NO** asumir comportamientos basados en HTML/CSS/JS web estándar
- **NO** mezclar sintaxis de otros frameworks (React, Angular, Vue, etc.)
- **NO** usar unidades CSS web como `px`, `em`, `rem` (usar `p` para puntos y `%` para porcentaje)
- **NO** poner todas las colecciones en `mappings.xne` (solo Empresas y Usuarios)
- **NO** omitir campos obligatorios mínimos en las colecciones base
- **NO** tratar `progid` como obligatorio: es OPCIONAL (sin él, objeto de datos genérico ≡ `ASData.CASBasicDataObj`). Solo **Empresas** (`ASGestion.CASEmpresa`) y **Usuarios** (`ASGestion.CASUser`) requieren su progid propio
- **NO** declarar en un `.xne` un encoding distinto de cómo está guardado el fichero (corrompe tildes/ñ). UTF-8 (default del motor) e `iso-8859-15` son válidos; sé coherente en todo el proyecto
- **NO** implementar el splash de carga inicial como una pantalla `.xne` ni meterlo dentro de `EntradaApp` (con logo + timer + redirect). El splash **no es una `<coll>`**: es un fichero estático (`splash.png` / `.jpg` / `.gif` / `.webp` / `.apng` / `.mp4` / `.3gp`) que se coloca en la **raíz del proyecto** y que `LoadAppActivity` del framework carga automáticamente antes de iniciar la app. `EntradaApp` es la pantalla **post-login** de bienvenida (con botón "Entrar"), no el splash. Tampoco confundir con `load-imgbk` del `<app>`, que es la imagen de fondo del EditView
- **NO** crear, editar, leer ni referenciar ficheros `.xml` de colecciones o pantallas. El único formato fuente para colecciones/pantallas es `.xne`. Los ficheros `.xml` de colecciones son **artefactos generados automáticamente por XOneStudio**. Tratalos como salida de compilación: no son fuente. La única excepción es `app.xml` (configuración global), que SI es fuente. Regla operativa: si un proyecto tiene `.xne` y `.xml` conviviendo, trabajar solo sobre los `.xne`; los `.xml` se ignoran por completo
- **NO** usar APIs del DOM — XOne no es HTML y no tiene navegador. Estas funciones NO existen en XOne: `document`, `document.getElementById`, `document.querySelector`, `window`, `window.location`, `localStorage`, `sessionStorage`, `XMLHttpRequest`, `navigator`, `history`. Para HTTP idiomático usar `$http`; para navegación `ui.*`; para datos `self.*` y `appData.*`. **SÍ existen** con implementación custom XOne (semántica spec-compatible): `Promise` (ES2024 con `all`/`allSettled`/`race`/`any`/`withResolvers`/`.then`/`.catch`/`.finally`), `fetch`, `setTimeout`/`setInterval`, `URL`, `Headers`, `AbortController`, `EventTarget`, `TextEncoder`/`TextDecoder`, `console`, `performance.now()`, `atob`/`btoa`. La sintaxis `class` ES6+ también está soportada (declaraciones, expresiones, `extends`/`super`/`static`/getters/setters/computed keys, **field declarations** `name = expr;` y `static name = expr;`, **generator methods** `*method()`). Los generadores con `yield` funcionan pero usan runtime estilo SpiderMonkey legacy (`gen.next()` devuelve el valor directo + lanza `StopIteration`; `for...of` no los itera). **NO** está soportado: `async`/`await`, template literals, spread/rest, default params, optional chaining `?.`, `import`/`export`, private fields `#name`, static blocks.
- **NO** usar `<load>` para inicializar pantallas — usar `<before-edit>`
- **NO repetir nombres de nodos dentro de la misma coleccion** — Restricción crítica. **El ambito de unicidad es la `<coll>` ENTERA**, no el `<group>` o `<frame>` que contiene al nodo. Es decir: no pueden existir dos `<prop>`, dos `<group>`, dos `<frame>` ni dos eventos con el mismo `name` en cualquier parte de la misma coll, **aunque estén en `<group>` o `<frame>` distintos**. Razón: el `name` se publica a nivel de la coll (los `collprops`), por lo que actuaria como identificador único ambiguo si se repitiera.
- **NO usar VBScript** en NINGUN lado (ni en respuestas, ni en proyectos generados). VBScript esta **descontinuado** en XOne. La única solución valida es **JavaScript** (`<script language="javascript">`). Si encuentras un ejemplo en VBScript en una fuente, traducelo a JavaScript antes de proponerlo
- **NO usar `coll.macro(...)` ni `content.macro(...)`** — esa sintaxis es **incorrecta** y no existe. La API valida es `setMacro("##NOMBRE##", valor)` para asignar y `getMacro("##NOMBRE##")` para leer. Para macros globales, `appData.setGlobalMacro` / `appData.getGlobalMacro`
- **NO olvidar declarar el nodo `<macro>` en el XML** antes de hacer `setMacro` — la macro debe existir en la coll con `<macro name="##X##" value="..." default="true" />` **al mismo nivel que los `<group>`** (hijo directo de `<coll>`, no anidado). Sin esa declaración, `setMacro` no inyecta nada en el SQL.
- **Escape XML del JS dentro de un `.xne`** — para JS no trivial, la **forma preferida** es declarar la función en un fichero `.js` externo y llamarla desde el XML con `miFuncion();` (el JS se escribe normal, sin entidades ni CDATA). Para snippets cortos inline, el parser de XOne acepta dos formas: (a) escapar los caracteres especiales con entidades XML dentro del JS (`&` -> `&amp;`, `<` -> `&lt;`, `>` -> `&gt;`, `"` -> `&quot;`, `'` -> `&apos;`), o (b) envolver el bloque en `<![CDATA[…]]>` cuando está dentro de un nodo `<script>` (CDATA no es válido dentro de atributos XML como `onclick="…"`).
- **`ID` y `ROWID` los gestiona la plataforma** — no hace falta declararlos como `<prop>` (declararlos es válido pero redundante; la recomendación es omitirlos por limpieza). En el atributo `sql=` de la coll, el campo **`ID` SÍ se rescata** en el SELECT (`SELECT ID, NOMBRE, ... FROM ##PREF##Tabla`); el `ROWID` **no es necesario** en el SELECT.
- **NO** usar el método obsoleto de firma `type="IMG" readonly="false"` — usar `type="DR"`
- **NO** instanciar `deviceInfo` ni `systemSettings` con new — son singletons globales
- **NO** usar `self("CAMPO")` ni `self('CAMPO')` para acceder a campos — la sintaxis correcta es `self.CAMPO` (notacion de punto) o `self["CAMPO"]` (notacion de corchetes) o `self.getValue("CAMPO")`. La notacion `self()` como función NO existe en XOne
- **NO** omitir el prefijo `MAP_` en props cuyo valor NO sea una columna de la tabla apuntada por `objname`. El framework excluye los `MAP_*` de los `INSERT`/`UPDATE`. Aplica a: (a) campos de JOIN en el SQL, (b) props enlazados via `linkedto` (combos/lookups), (c) props puramente visuales: etiquetas `L` (o su alias legacy `TL`), botones `B`, imágenes decorativas, contenedores `Z`, valores calculados, estados de UI. Inversamente, **NO** poner `MAP_` a un campo que SI es columna BD.
- **NO** usar tipos de prop inventados. Los tipos validos son: `T`, `TN`/`TN2`..`TN6`, `N`/`N2`..`N6`, `D`, `DT`, `TT`, `B`, `L` (o su alias legacy `TL`), `THTML`, `WEB`, `IMG`, `PH`, `VD`, `DR`, `NC`, `X`, `Z`, `AT`, `O`. El sufijo numérico en `N` y `TN` indica los decimales visibles en el control (`N2` = 2 decimales, `N6` = 6, etc.). Los tipos `BT`, `C`, `M`, `A`, `R`, `E`, `H`, `W`, `F` **NO existen** en XOne y causaran errores. Los combos/selectores se implementan con `type="T"` (o `type="N"`) más los atributos `mapcol` y `mapfld`, NO con un type especifico.
- **NO mezclar mayusculas/minusculas en el atributo `name`** — El `name` de los nodos `<coll>`, `<group>`, `<frame>` y `<prop>` es **case-sensitive**. `name="MiNombre"` y `name="minombre"` son nombres **distintos** para XOne. Esto aplica también a TODAS las referencias cruzadas: `self.MiNombre` vs `self.minombre`, `mapcol`, `linkedto`, `inherits`, `<field name="...">`, `getControl("...")`, `ui.openEditView("...")`, `appData.getCollection("...")`, etc. Mantener una convencion uniforme en todo el proyecto (recomendado: PascalCase para colls/groups/frames y MAYUSCULAS para campos de BD).
- **NO repetir el atributo `id` de `<group>` dentro de la misma `<coll>`** — En cada `<group>` el atributo `id` es **obligatorio** y debe ser **único dentro de la coll que lo contiene**. Si hay dos `<group id="1">` en la misma coll el comportamiento es indefinido (la navegación entre tabs y el rebuild de layout fallan). Convencion habitual: `id="1"`, `id="2"`, ... para grupos normales; `id="999"` para HEADER fijo (`class="groupfixed_header"`) y `id="0"` para FOOTER fijo (`class="groupfixed_footer"`).

### Herencia entre Colecciones (`inherits`) y Composición XML (`<include-layout>`)

Antes de duplicar estructura entre varias colecciones (header, footer, botones comunes, eventos compartidos), evaluar si usar uno de los dos mecanismos de reutilización XML de XOne:

- **`inherits`** en `<coll>`: la coleccion hija hereda grupos, frames, props y eventos del padre. En duplicidad prevalece la hija. Admite cadenas (A->B->C) pero NO herencia multiple. Uso típico: scaffolding visual compartido en una coll `special="true"` reutilizada por varias pantallas.
- **`<include-layout file="..." group="..." frame="..." />`**: nodo hijo de `<coll>` que inyecta el contenido de un XML externo (raiz `<xml>`, encoding `utf-8`, estructura plana). Útil para factorizar botoneras o fragmentos repetidos. No se pueden anidar.

Regla de decisión rápida:
- **3+ pantallas comparten estructura** -> crear coll base `special="true"` y usar `inherits`.
- **Fragmentos repetidos (botoneras, bloques de props)** -> extraer a fichero XML externo con `<include-layout>`.
- **1-2 pantallas parecidas** -> normalmente duplicar es más claro; no sobre-abstraer.

Prohibiciones:
- **NO** usar `inherits` multiple (sintaxis `inherits="A,B"` no existe).
- **NO** anidar `<include-layout>` dentro de un fichero incluido.
- **NO** usar encoding `iso-8859-15` en ficheros de `<include-layout>` — usar `utf-8`. (Los `.xne` siguen siendo `iso-8859-15`; solo los ficheros incluidos por `<include-layout>` usan `utf-8`.)
- **NO** poner `<coll>` como raiz del fichero incluido — la raiz debe ser `<xml>`.

Referencia completa: [references/fase-6-colecciones.md](references/fase-6-colecciones.md) §6.5b.

### Campos Mínimos Obligatorios en Colecciones Base

| Coleccion | progid | Campos a declarar como `<prop>` |
|-----------|--------|----------------------------------|
| **Empresas** | `ASGestion.CASEmpresa` | `CODIGO` (N), `NOMBRE` (T) |
| **Usuarios** | `ASGestion.CASUser` | `CODIGO` (N), `NOMBRE` (T), `IDEMPRESA` (N), `LOGIN` (T), `PWD` (X) |
| **Resto** | `ASData.CASBasicDataObj` | Los que defina el desarrollador |

> **`ID` y `ROWID` los gestiona la plataforma** — no hace falta declararlos como `<prop>` (declararlos es válido pero redundante). En el `sql=` de la coll, **`ID` sí se rescata en el SELECT** (`SELECT ID, ...`); el `ROWID` no es necesario en el SELECT.

---

## Flujo de Generación de Proyectos

### Fase 1: Análisis de Requisitos

1. **Comprender la descripción** — Que tipo de aplicación, cual es su proposito
2. **Identificar colecciones** — Modelo de datos: entidades, campos, relaciones
3. **Identificar pantallas y navegación** — Flujo de usuario: entrada, menu, listados, detalle, formularios
4. **Identificar integraciones** — GPS, camara, firma digital (DR), escaner QR/barras
5. **Definir paleta de colores y estilo visual** — Colores primarios, secundarios, fondos, textos

### Fase 2: Estructura del Proyecto

Consulta [references/fases-0-2-analisis-y-modelo-de-datos.md](references/fases-0-2-analisis-y-modelo-de-datos.md) para el flujo completo.

```
NombreProyecto/
├── bd/              # [OBLIGATORIO] Base de datos SQLite
├── icons/           # [OBLIGATORIO] Recursos graficos (solo PNG)
├── files/           # [OBLIGATORIO] Archivos dinamicos (fotos, firmas, docs)
├── fonts/           # [RECOMENDADO] Fuentes tipograficas (.ttf, .otf)
├── scripts/         # [OPCIONAL] Scripts JS organizados por modulo
├── lang/            # [OPCIONAL] Multiidioma (subcarpetas por ISO: en/, es/)
├── certificates/    # [OPCIONAL] Certificados SSL/TLS
└── splash.png       # [OPCIONAL] Imagen de splash de carga inicial (raíz del proyecto)
                     # Acepta tambien splash.jpg/.gif/.webp/.apng/.mp4/.3gp
                     # El framework lo carga automaticamente — NO es una <coll>
```

### Fase 3: Archivos de Configuración

| Archivo | Descripción |
|---------|-------------|
| `app.xml` | Configuración de la app. Atributo `prefix="gen"` por defecto |
| `app.ini` | Metadatos: Name, Title, Caption, Icon, IconFolder=icons, FilesFolder=files |
| `mappings.xne` | SOLO colecciones Empresas y Usuarios con progid y campos obligatorios. Encoding: UTF-8 o iso-8859-15 (coherente con los bytes) |
| `default.css` | Estilos globales con clases base |
| `functions.js` | Funciones JavaScript globales |

### Fase 4: Colecciones y Pantallas

**Colecciones:**
- Un archivo `.xne` por cada coleccion adicional. Encoding: `UTF-8` (default del motor) o `iso-8859-15`, coherente con cómo se guarda
- `progid` es **opcional** (default = objeto de datos genérico ≡ `ASData.CASBasicDataObj`). Declararlo solo si se quiere ser explícito; **Empresas** usa `ASGestion.CASEmpresa` y **Usuarios** `ASGestion.CASUser`
- Usar macro `##PREF##` en queries SQL
- **Tipos validos:** T, TN/TN2..TN6, N/N2..N6, D, DT, TT, B, L, TL (alias legacy), THTML, WEB, IMG, PH, VD, DR, NC, X, Z, AT, O (el sufijo en N/TN indica decimales visibles)

**Pantallas:**
- `EntradaApp.xne` — Pantalla de entrada **post-login** (bienvenida con botón "Entrar"). Obligatoria salvo que la app arranque directamente en `MenuPrincipal`. **NO es el splash de carga** — el splash es un fichero `splash.png` en la raíz del proyecto
- `MenuPrincipal.xne` — Menu principal
- Pantallas de listado, detalle, formularios según requisitos
- Inicializar siempre con `<before-edit>`, nunca con `<load>`
- **Splash de carga:** NO es una pantalla `.xne` — colocar `splash.png` (o `.jpg`/`.gif`/`.webp`/`.apng`/`.mp4`/`.3gp`) en la **raíz del proyecto**. El framework lo carga automáticamente

### Fase 5: Post-Generación

Indicar al usuario que ejecute:
1. Generar base de datos con `xone_db_generator`
2. Insertar datos iniciales (Empresa + Usuario admin)
3. Descargar iconos de Google Material Icons (PNG, JPG o SVG — todos validos)

---

## Tamaños canónicos (`width` / `height` / `fontsize`)

Antes de fijar cualquier `width` o `height`, consulta **[references/canonical-sizes.md](references/canonical-sizes.md)** — contiene tablas por tipo de elemento (frames, botones, inputs, listas, avatares, iconos, tipografía, áreas especiales, wearable) y los anti-patrones más frecuentes. **Todos los valores están calibrados para `resolution-width="1080"` / `resolution-height="1920"` (default XOne).**

> **REGLA CRÍTICA:** En XOne **`p` ≠ `dp`**. 1p = 1px en el dispositivo de referencia. Material 56dp en 1080×1920 (xxhdpi, density 3×) = **~168p**, NO 56p. Aplicar valores Material directamente como `p` produce barras/botones ~3× más pequeños de lo necesario.

### Heurísticas de decisión (memorizar)

1. **Header / footer / toolbar / drawer fijos** → `height` en `Np` absoluto (típicos en 1080×1920: header `164p`, header completo con tabs `404p`, footer con botones `216p`–`288p`, bottom nav `168p`, drawer width `840p`–`960p`).
2. **Frame body principal entre header y footer fijos** → `height="-2"` o `height="100%" scroll="true"`. NUNCA un `%` calculado a mano restando los fijos.
3. **Contenido apilado verticalmente** → `height="-2"` (wrap content) y dejar que el contenido mande. Solo fijar `Np` si necesitas mínimo visual.
4. **Imágenes, avatares, iconos** → `Np` fijos en **ambos** ejes para preservar aspecto. NUNCA `width="100%" height="100%"` en una imagen.
5. **Botones** → `width` en `%`, `height` en `Np`, mínimo **144p** (touch target Material 48dp × 3 en xxhdpi). CTAs principales: `124p` (workflow pill).
6. **Inputs** → `width="95%"`–`"100%"`, `height` en `Np` (típico `144p`).
7. **Dos elementos en la misma fila** → cada uno con `width` `%` que sume ≤ 100%, el segundo con `newline="false"`.
8. **Los `%` se refieren al padre directo**, no a la pantalla. Tres frames hermanos con `height="40%"` desbordan (suman 120%).
9. **`<prop>` tiene 2 columnas internas (label + valor)**: si `labelwidth="50"` y `width="50%"`, el valor real queda con 25% de la fila. Bajar `labelwidth` a 20-30 o subir `width` a 95-100%.
10. **`fontsize` usa escala XOne 1-12**, NO Material `sp`/`dp`. Texto estándar = `5`, título sección = `7`, topbar = `10`–`11`, nombre app = `12`.

### Defaults seguros para 1080×1920 (cuando no estás seguro)

| Nodo | width | height |
|------|-------|--------|
| `<frame>` cabecera | `100%` | `164p` |
| `<frame>` cuerpo | `100%` | `-2` con `scroll="true"` |
| `<frame>` pie con botones | `100%` | `216p` |
| `<frame>` tarjeta | `95%` | `-2` |
| `<prop type="T">` / `N` / `D` / `combo` | `100%` | `144p` |
| `<prop type="B">` (botón) | `90%` | `124p` |
| `<prop type="L">` (label) | `100%` | `-2` (o `96p`) |
| `<prop type="NC">` (checkbox) | `100%` | `144p` |
| `<prop type="IMG">` / `PH` / `DR` | `100%` | `600p`–`720p` |
| `<prop type="Z">` (contenedor) | `100%` | `-2` o `100%` |
| Icono `img-width` / `img-height` | `72p` (toolbar) o `104p` (botón cuadrado) | igual |
| `tmargin` entre elementos del mismo bloque | — | `30p` |
| `tmargin` entre bloques distintos | — | `50p` |
| `fontsize` texto estándar | — | `5` |

> **Si `resolution-width` ≠ 1080**, escalar con `valor_nuevo = valor_tabla × (resolution-width / 1080)`. Detalle en §14 de [references/canonical-sizes.md](references/canonical-sizes.md).

> **Limitación honesta:** sin ver el render real es imposible afinar al píxel. Estos valores cubren el caso típico y evitan errores groseros (desborde, touch target insuficiente, distorsión de imagen), pero pueden requerir ajuste tras la primera compilación. Si el usuario aporta una captura o el dispositivo objetivo (móvil / tablet / wearable / kiosko), usar la sección §11 (wearable) o ajustar proporcionalmente.

---

## Plantilla Estándar de Pantalla

```xml
<?xml version="1.0" encoding="iso-8859-15"?>
<coll name="NombrePantalla" title="Título" special="true" notab="true" show-toolbar="false">

    <!-- Inicializar la pantalla en before-edit, NUNCA en load -->
    <before-edit refresh="false" show-wait-dialog="false">
        <action name="runscript">
            <script language="javascript">
                // Inicializar campos y datos
                self.MAP_TITULO = "Mi pantalla";
            </script>
        </action>
    </before-edit>

    <group name="grpPrincipal" id="1">
        <frame name="frmHeader" width="100%" height="140p" bgcolor="#1565C0">
            <!-- Logo, título, botones de navegacion -->
        </frame>
        <frame name="frmBody" width="100%" height="-2" scroll="true" bgcolor="#FFFFFF">
            <!-- Contenido: campos, listas, botones -->
        </frame>
        <frame name="frmFooter" width="100%" height="100p" bgcolor="#F5F5F5">
            <!-- Botones de acción, barra inferior -->
        </frame>
    </group>

    <onback show-wait-dialog="false">
        <action name="runscript">
            <script language="javascript">
                ui.getView(self).exit();
            </script>
        </action>
    </onback>
</coll>
```

## Plantilla Estándar de Coleccion de Datos

```xml
<?xml version="1.0" encoding="iso-8859-15"?>
<coll name="MiColeccion"
      progid="ASData.CASBasicDataObj"
      sql="SELECT ID, NOMBRE FROM ##PREF##MiColeccion"
      objname="MiColeccion"
      updateobj="MiColeccion"
      loadall="true">
    <group name="General" id="1">
        <!-- ID y ROWID los gestiona XOne: no hace falta declararlos (válido pero redundante). Solo ID se rescata en el SELECT. -->
        <prop name="NOMBRE" type="T" visible="7" size="150" width="100%" />
    </group>
</coll>
```

## Plantilla mappings.xne

```xml
<?xml version="1.0" encoding="iso-8859-15"?>
<xml>
    <app prefix="gen" version="1.0.0" debug="true" default-language="javascript">
        <style url="default.css" />
    </app>
    <collprops type="general">
        <coll name="Empresas"
              progid="ASGestion.CASEmpresa"
              sql="SELECT ID, CODIGO, NOMBRE FROM ##PREF##Empresas"
              objname="Empresas" updateobj="Empresas" loadall="true">
            <group name="General" id="1">
                <prop name="CODIGO" type="N" visible="7" />
                <prop name="NOMBRE" type="T" visible="7" size="150" width="100%" />
            </group>
        </coll>
        <coll name="Usuarios"
              progid="ASGestion.CASUser"
              sql="SELECT ID, CODIGO, NOMBRE, IDEMPRESA, LOGIN, PWD FROM ##PREF##Usuarios"
              objname="Usuarios" updateobj="Usuarios" loadall="true">
            <group name="General" id="1">
                <prop name="CODIGO"     type="N" visible="7" />
                <prop name="NOMBRE"     type="T" visible="7" size="100" width="100%" />
                <prop name="IDEMPRESA"  type="N" visible="7" mapcol="Empresas" mapfld="ID" />
                <prop name="LOGIN"      type="T" visible="7" size="50"  width="100%" />
                <prop name="PWD"        type="X" visible="0" size="100" />
            </group>
        </coll>
    </collprops>
</xml>
```

---

## Convenciones de Nomenclatura

- **Colecciones:** PascalCase (`MenuPrincipal`, `DetalleProducto`)
- **Propiedades de BD:** MAYUSCULAS (`CODIGO`, `NOMBRE`, `IDEMPRESA`, `ROWID`). En la coll `Usuarios` el campo de empresa **DEBE** llamarse `IDEMPRESA` (sin guion bajo) — el framework lo lee literalmente.
- **Propiedades de UI (no persisten):** Prefijo MAP_ (`MAP_BTN_GUARDAR`, `MAP_TOTAL`, `MAP_BUSQUEDA`)
- **Clases CSS:** Prefijo descriptivo (`.frameHeader`, `.btnPrimario`, `.textoTitulo`)
- **Iconos:** snake_case (`ic_home.png`, `ic_add_white.png`)
- **Scripts JS:** camelCase (`inicializarPantalla`, `cargarDatos`, `guardarRegistro`)

---

## Recursos adicionales

El índice completo de referencias está en la sección «Archivos de Referencia» de este mismo fichero.

Para el detalle de cada área durante la generación, usa las skills especializadas: `xone-xml-ui` (nodos y atributos), `xone-javascript` (API del runtime), `xone-css` (estilos), `xone-data-integration` (SQL, `$http`, réplica), `xone-device` (hardware) y `xone-development` (fundamentos y reglas transversales). Al terminar, valida y audita con `xone-review`.
