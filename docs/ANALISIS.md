# Análisis honesto del plugin `xone-development`

Fecha: 2026-08-03 · Estado del repo analizado: commit `8955635`

> **Estado del rediseño.** Aplicado en la v0.10.0: R1 (referencias troceadas desde el corpus), R2 (`SKILL.md` como reglas + índice), R3 (activación de `xone-development`), R4 (`xone-project-generator` integrada en README, arquitectura, changelog y validador), R5 (validador que descubre skills y comprueba enlaces) y R6 (`xone/` versionada). Pendiente: las pruebas de activación real, que son las que dicen si el rediseño funciona de verdad — ver [`TODO.md`](TODO.md) tarea 6. **Actualización v0.11.0:** la taxonomía de nueve skills que este análisis diagnostica (tabla de la sección 1) ya no existe — se consolidó en cuatro (una puerta de conocimiento más tres de procedimiento); ver [`ARCHITECTURE.md`](ARCHITECTURE.md) §13.4. Lo que sigue es una fotografía honesta del estado en el commit `8955635`, no el diseño actual.

## Resumen en una frase

La arquitectura (§ARCHITECTURE) es buena; la implementación hizo lo contrario de lo que la arquitectura dice: **no hay ningún camino desde dentro del plugin hasta el detalle autoritativo**. Las skills saben *que existe* `startGps`, pero no su firma. Eso no reduce el contexto: aumenta la confianza sin aumentar la exactitud.

## 1. El defecto central: resumen en lugar de partición

La divulgación progresiva significa **SKILL.md pequeño + references grandes cargadas bajo demanda**. Aquí las references también son resúmenes:

| Skill | `SKILL.md` | `references/` | Fuente original equivalente |
|---|---|---|---|
| `xone-css` | 41 líneas | 23 + 16 líneas | `04-css-styling-guide.md` — **3.811 líneas** |
| `xone-javascript` | 71 | 41 + 71 + 18 | `06-javascript-runtime-objects.md` (1.549) + `03a/03b/03d/03e/03f` (~5.000) |
| `xone-xml-ui` | 158 | *(ninguna)* | `02a-02d` (4.455) + `07-xml-attributes-reference.md` (924) |
| `xone-data-integration` | 43 | 17 + 42 + 13 | `03c-js-appdata-http.md` (1.130) |
| `xone-device` | 48 | 33 + 48 + 13 | disperso en `03b`, `06`, `03d` |
| `xone-debugging` | 48 | 61 | `05-events-patterns-faq.md` (4.094) |

Total: ~46.000 líneas de conocimiento original → ~1.000 líneas de prosa comprimida.

Lo que se perdió es exactamente lo que evita alucinaciones. Comparación real:

**En el plugin hoy** (`xone-javascript/references/api.md`, una sola frase con 40 nombres):
> Dispositivo: `startGps`, `stopGps`, `checkGpsStatus`, `askUserForGpsPermission`, `takePicture`, …

**En el original** (`03b-js-ui.md:464`):
```js
ui.startGps({
    nodeName                  : "callbackgps",  // Handler en la coll que recibe las actualizaciones
    timeBetweenUpdates        : 10000,          // Milisegundos entre actualizaciones
    minimumMetersDistanceRange: 10,
    priority                  : "high",         // high / balanced / low_power / passive
    granularity               : "permission_level",  // permission_level / fine / coarse
    waitForAccurateLocation   : true
});
let nStatus = ui.checkGpsStatus();
// 0: No hay hardware GPS · 1: Solo GPS · 2: Solo WiFi/redes · 3: Ninguno · 4: GPS+WiFi (óptimo)
```

Una lista de nombres sin firma es peor que no tener nada: el modelo inventa los parámetros con total seguridad.

Esto contradice el propio principio §2.1 «Exactitud antes que cobertura» y el §7.1 (niveles de evidencia): una regla no puede rastrearse a su fuente cuando la fuente no está en el repositorio.

## 2. Colisión de activación: `xone-development` absorbe a las otras ocho

Su `description` es la **unión literal** de las demás:

> «…XML .xne, JavaScript XOne, CSS XOne, colecciones, pantallas, navegación, integraciones HTTP, permisos, GPS, cámara, sincronización o al depurar errores de runtime.»

En Claude Code y OpenCode la selección de skill se hace por coincidencia con la descripción. Una skill «coordinadora» cuya descripción cubre todos los dominios se activará casi siempre, y su cuerpo de 61 líneas no deriva a ningún sitio: **no existe mecanismo de routing entre skills**; el modelo tiene que decidir invocar la siguiente. Resultado práctico: el usuario recibe las 61 líneas genéricas y nunca el conocimiento especializado.

El diseño de «skill coordinadora» (§4.1) no es implementable con el mecanismo real de activación. Las descripciones de las otras ocho, en cambio, sí discriminan bien entre sí.

## 3. 108 KB muertos: `fundamentals.md` es inalcanzable

`skills/xone-development/references/fundamentals.md` son 2.510 líneas (108 KB) copiadas de `01-xone-fundamentals.md`, versionadas en git, y **no las referencia ningún `SKILL.md`** (`grep -rn "fundamentals" plugins --include=SKILL.md` → vacío). El agente no puede saber que existe.

## 4. `xone-project-generator` está fuera de todo el diseño

Se distribuye en el plugin (SKILL.md 338 líneas + `workflow.md` 267 KB + `canonical-sizes.md`, todo en git), pero **no aparece** en:

- el README (dice «Incluye 9 skills» y lista nueve),
- la taxonomía `ARCHITECTURE.md` §4, ni la estructura objetivo §10,
- el `CHANGELOG.md` (ninguna versión la registra),
- el array `expected` de `scripts/validate-skills.sh`.

Así que el validador da «Validated 9 skills» sobre un plugin que envía 10. Es, además, la única skill que **sí** conservó la profundidad (mantiene los originales íntegros) — no hay ningún criterio uniforme aplicado.

## 5. El validador certifica lo que no importa

`scripts/validate-skills.sh` comprueba `< 500 líneas` en `SKILL.md` — un techo que nadie roza (el máximo real es 338) — y no comprueba nada de lo que se rompió:

- que la lista de skills coincida con el sistema de ficheros (por eso pasó desapercibida la #4),
- que cada `references/*.md` esté enlazada desde su `SKILL.md` (por eso pasó desapercibida la #3),
- que los enlaces relativos resuelvan.

## 6. Deriva entre documentación y realidad

- README: «9 skills» → hay 10.
- `docs/TODO.md` §2 registra el refactor como «Líneas actuales: 71 · Acción: mover material extenso a `references/`». Los 71 son el estado *posterior*: nunca hubo material extenso que mover. El refactor se documentó al revés — el contenido se resumió en el momento de crear cada skill (v0.2–v0.9), no se partió desde los originales.
- `/xone/` (la fuente canónica, 2 MB) está en `.gitignore`, así que no tiene respaldo en git y su contenido no es auditable. Sin embargo dos de sus ficheros están copiados dentro del plugin: duplicación sin mecanismo de sincronización, justo lo que se quiso evitar al borrar `scripts/sync.sh`.
- La propia fuente está duplicada: `xone/xone-help-docs/topics/*` y `xone/xone-project-generator/references/xone-*` son casi los mismos documentos (p. ej. `08-objeto-ai.md` 397 líneas ≡ `xone-javascript-ai.md` 397 líneas). Hay que elegir un juego canónico.

## 7. Hueco de cobertura

`08-objeto-ai.md` / `xone-javascript-ai.md` (397 líneas, el objeto AI de XOne) no tiene hogar en la taxonomía de nueve skills.

## Lo que sí está bien y no hay que tocar

- La taxonomía por dominios y las descripciones de las ocho skills especializadas: discriminan correctamente.
- La decisión de OpenCode vía `skills.paths` sin espejo duplicado (§3.4): es la solución correcta.
- Separar `xone-debugging` (síntoma → hipótesis) de la verificación: son modos de trabajo distintos.
  - *Corrección posterior:* este análisis daba también por buena la separación entre `xone-verification` y `xone-review`. Al auditarlas se vio que duplicaban el bloque de comandos, el bucle de corrección y las reglas de sintaxis JS —con el mismo error en ambas—, así que se fusionaron en `xone-review`.
- El CHANGELOG y el versionado por fases.
- Apoyar la verificación en un CLI real (`xone-linter`) en lugar de en la intuición del modelo.

## Rediseño propuesto

### R1. References = detalle autoritativo troceado (no resúmenes)

Copiar el juego canónico de `xone/` dentro de `plugins/xone-development/skills/<skill>/references/`, troceando los ficheros grandes a ≤ ~800 líneas para que una lectura sea asequible en contexto (`04-css-styling-guide.md` son ~30k tokens: demasiado para un solo `Read`).

Debe vivir **dentro** de la carpeta del plugin: Claude Code copia el plugin a su caché al instalarlo (§3.2), y `/xone/` ni siquiera está en git.

Mapa fuente → destino:

| Destino | Fuentes |
|---|---|
| `xone-development/references/` | `01-xone-fundamentals.md` (ya copiado — **enlazarlo**) |
| `xone-xml-ui/references/` | `02a-estructura`, `02b-prop-tipos`, `02c-contents-patrones`, `02d-layouts-herencia`, `07-xml-attributes-reference` |
| `xone-javascript/references/` | `03a-js-self`, `03b-js-ui`, `03d-js-createobject`, `03e-js-patrones`, `03f-js-controles-metodos`, `06-javascript-runtime-objects` |
| `xone-data-integration/references/` | `03c-js-appdata-http` |
| `xone-css/references/` | `04-css-styling-guide` (trocear) |
| `xone-debugging/references/` | `05-events-patterns-faq` (trocear) |
| `xone-device/references/` | secciones de dispositivo de `03b`, `06`, `03d` |
| decidir | `08-objeto-ai` |

### R2. `SKILL.md` = reglas de decisión + índice de navegación

Cada `SKILL.md` se queda con lo que el modelo necesita *siempre*: reglas duras, anti-patrones, y una tabla «para responder X, lee Y». Los resúmenes actuales sirven como esa capa; lo que falta es el índice que apunta al detalle. Los nombres de API sueltos deben desaparecer de `SKILL.md` o llevar el puntero al fichero con la firma.

### R3. Arreglar la activación

Reducir la `description` de `xone-development` a lo transversal y no solapable (método de trabajo, cambio mínimo, formato de respuesta, elección de área) o eliminarla como skill y mover esas reglas al `SKILL.md` de cada dominio. Hoy es la única colisión real del conjunto.

### R4. Integrar o retirar `xone-project-generator`

Si se mantiene: añadirla al README, a §4 y §10 de `ARCHITECTURE.md`, al `CHANGELOG.md` y al validador.

### R5. Validador que compruebe lo que se rompió

Enumerar las skills desde el sistema de ficheros en vez de una lista fija, y verificar que toda `references/*.md` esté enlazada desde su `SKILL.md` y que los enlaces resuelvan.

### R6. Fuente canónica en git

Versionar el juego elegido de `xone/` (o eliminarlo del repo y declarar el plugin como fuente única) para que §2.5 y §7.1 sean ciertos.
