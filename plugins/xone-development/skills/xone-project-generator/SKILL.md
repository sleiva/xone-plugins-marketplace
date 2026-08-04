---
name: xone-project-generator
description: Generación de proyectos XOne completos a partir de descripciones en lenguaje natural. Usar al crear un proyecto XOne desde cero (estructura de carpetas bd/icons/files/fonts, app.xml, app.ini, mappings.xne con Empresas y Usuarios, colecciones .xne, pantallas, default.css, functions.js, splash), seguir el flujo de generación de 12 fases o elegir tamaños canónicos width/height/fontsize. Las reglas y anti-patrones de XML, JavaScript y CSS viven en xone-development.
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
- CSS propietario de XOne
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

Las prohibiciones de generación no se repiten aquí: viven en `xone-development/SKILL.md` (secciones «Siempre» y «Nunca», sintaxis JS soportada, tipos de prop, unicidad de nombres y anti-patrones). Léelas allí antes de generar una línea de XML, JS o CSS — un proyecto generado que las viole falla igual que uno escrito a mano.

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

> `ID` y `ROWID`: no declararlos como `<prop>` en estas colecciones tampoco. Ver la regla en `xone-development`.

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
| `mappings.xne` | SOLO colecciones Empresas y Usuarios, con los campos de la tabla de arriba. Encoding coherente con el resto del proyecto (regla en `xone-development`) |
| `default.css` | Estilos globales con clases base |
| `functions.js` | Funciones JavaScript globales |

### Fase 4: Colecciones y Pantallas

**Colecciones:**
- Un archivo `.xne` por cada coleccion adicional. Encoding coherente con cómo se guarda (regla en `xone-development`)
- `progid`: opcional salvo Empresas y Usuarios (regla en `xone-development`)
- Usar macro `##PREF##` en queries SQL
- Tipos de prop: solo los de la tabla de tipos de `xone-development`; no inventar otros

**Pantallas:**
- `EntradaApp.xne` — Pantalla de entrada **post-login** (bienvenida con botón "Entrar"). Obligatoria salvo que la app arranque directamente en `MenuPrincipal`. No es el splash (ver la regla de `xone-development` sobre la diferencia)
- `MenuPrincipal.xne` — Menu principal
- Pantallas de listado, detalle, formularios según requisitos
- Inicializar con `<before-edit>` (regla en `xone-development`)
- Splash de carga: fichero en la raíz del proyecto, no una pantalla `.xne` (misma regla)

### Fase 5: Post-Generación

Indicar al usuario que ejecute:
1. Generar base de datos con `xone-db-tools create-db`
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
7. **Dos elementos en la misma fila** → anchos `%` que sumen ≤ 100%; el segundo no hereda el salto de línea por defecto (regla en `xone-development`).
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

Para el detalle de cualquier atributo, API o regla durante la generación, usa `xone-development` (fundamentos y reglas transversales) y su índice de referencias. Al terminar, valida y audita con `xone-review`.
