# Arquitectura de Skills XOne

**Estado:** skills implementadas, capa de referencias reconstruida sobre el corpus original (v0.10.0) y adaptación a OpenCode completada. Pendiente: pruebas de activación con tareas reales, consolidación de fronteras entre skills a la luz de esas pruebas, versiones soportadas de XOne y revisión experta.

**Versión:** 0.2

**Ámbito:** marketplace `xone-plugins-marketplace`, plugin `xone-development` y skills compatibles con Claude Code y OpenCode.

## 1. Objetivo

Construir un conjunto de skills que ayude a desarrollar, revisar y depurar aplicaciones XOne con respuestas técnicamente fiables y cambios mínimos.

La arquitectura debe:

- Separar el conocimiento por áreas para reducir instrucciones irrelevantes.
- Activar la skill adecuada según la tarea, sin obligar al usuario a conocer la taxonomía.
- Mantener las restricciones reales del runtime XOne visibles y verificables.
- Funcionar en Claude Code y OpenCode sin crear comportamientos incompatibles.
- Permitir revisión por expertos de XOne antes de publicar conocimiento sensible o dudoso.
- Evolucionar sin romper instalaciones existentes del plugin.

## 2. Principios

### 2.1. Exactitud antes que cobertura

Una skill debe declarar una API o atributo solo cuando existe evidencia en la documentación de XOne o en un proyecto validado. Si hay incertidumbre, debe indicarla y pedir el contexto que falta.

### 2.2. Divulgación progresiva

Las instrucciones comunes deben ser breves. El detalle específico debe vivir en skills o referencias especializadas y cargarse solo cuando sea relevante.

### 2.3. Mínimo cambio seguro

La skill debe inspeccionar el proyecto antes de editar, respetar sus convenciones y evitar refactorizaciones no solicitadas.

### 2.4. Compatibilidad explícita

Claude Code y OpenCode comparten el formato `SKILL.md`, pero no comparten el sistema de marketplace ni todos los mecanismos de instalación. La documentación y las pruebas deben distinguir ambos canales.

### 2.5. Conocimiento versionado

Las reglas del runtime, los ejemplos y las decisiones de compatibilidad se versionan junto con el plugin. Cada cambio relevante debe poder rastrearse a una fuente o revisión.

## 3. Capas de la solución

### 3.1. Marketplace

Responsable de descubrir y distribuir plugins para Claude Code.

```text
.claude-plugin/marketplace.json
```

El marketplace actual publica el plugin local `./plugins/xone-development`.

### 3.2. Plugin

Responsable de empaquetar la identidad, versión y componentes de XOne para Claude Code.

```text
plugins/xone-development/
├── .claude-plugin/plugin.json
└── skills/
```

El plugin no debe depender de archivos fuera de su propia carpeta, porque Claude Code lo copia a una caché al instalarlo.

### 3.3. Skills

Responsables de un área concreta del trabajo XOne. Cada skill tiene un `SKILL.md` y, si lo necesita, referencias locales.

```text
plugins/xone-development/skills/<skill-name>/
├── SKILL.md
└── references/
```

### 3.4. Adaptador OpenCode

OpenCode descubre skills desde varias rutas (`.opencode/skills/`, `.claude/skills/`, `.agents/skills/`) y, además, permite apuntar a carpetas arbitrarias mediante el campo `skills.paths` de `opencode.json`. No se mantiene copia duplicada: la fuente canónica `plugins/xone-development/skills/` se referencia directamente.

```json
{
  "$schema": "https://opencode.ai/config.json",
  "skills": { "paths": ["./plugins/xone-development/skills"] }
}
```

La carpeta `.opencode/` queda reservada para el entorno de desarrollo de plugins OpenCode (`node_modules`, `package.json` con `@opencode-ai/plugin`) y se ignora en git.

### 3.5. Frontmatter compatible

OpenCode exige `name` en el frontmatter (debe coincidir con el nombre del directorio y seguir `^[a-z0-9]+(-[a-z0-9]+)*$`). Claude Code lo trata como opcional. Para compatibilidad cruzada, todo `SKILL.md` debe incluir:

```yaml
---
name: xone-css
description: ...
---
```

## 4. Taxonomía propuesta

### 4.1. `xone-development`

Fundamentos y estructura de proyecto, más las reglas transversales.

Responsabilidades:

- Anatomía del proyecto: carpetas, ficheros raíz, `app.xml`, `app.ini`, `mappings.xne`.
- Conceptos base: colecciones, DataObject, props, `##PREF##`, macros del sistema, códigos de error.
- Qué sintaxis JavaScript soporta el motor.
- Reglas transversales: la fuente son los `.xne`, unicidad y case-sensitivity de nombres, encoding, `progid` opcional, evento correcto de inicialización.

No debe contener la referencia completa de todas las APIs XOne.

**Nota de diseño (v0.10.0).** Hasta la v0.9.0 esta skill se describió como «coordinadora y punto de entrada». No es implementable: la selección de skill se hace por coincidencia con la `description`, y no existe mecanismo de routing entre skills — una descripción que cubría todos los dominios capturaba casi cualquier consulta y su cuerpo no derivaba a ningún sitio. La skill pasó a tener un dominio propio y no solapable.

### 4.2. `xone-xml-ui`

XML `.xne`, `app.xml`, colecciones, grupos, frames, props, contents, layouts, herencia, macros, permisos y validación estructural.

Debe cubrir especialmente:

- Tipos válidos de propiedades.
- Navegación y composición de pantallas.
- Unicidad de nombres.
- `before-edit`, `create` y eventos XML.
- Errores que producen pantallas vacías.

### 4.3. `xone-javascript`

JavaScript del runtime XOne, objetos globales, ciclo de vida, navegación, controles, callbacks, Futures y patrones de datos.

Debe separar APIs confirmadas de APIs dependientes de versión.

### 4.4. `xone-css`

Selectores, unidades, colores, temas, herencia, animaciones y layouts visuales XOne.

Debe advertir de las diferencias frente a CSS web, especialmente unidades no soportadas y `compatibility-mode`.

### 4.5. `xone-data-integration`

Colecciones, SQL, filtros, REST, `$http`, OAuth2, TLS, réplica, serialización y tratamiento de credenciales.

Debe priorizar seguridad y evitar ejemplos que interpolen entradas no validadas.

### 4.6. `xone-device`

GPS, cámara, archivos, permisos de runtime, biometría, sensores, impresión, Bluetooth, NFC y capacidades del dispositivo.

Cada integración debe indicar requisitos de permisos, limitaciones de plataforma y manejo de errores.

### 4.7. `xone-debugging`

Diagnóstico sistemático de errores de compilación, carga, UI, datos, red, rendimiento y diferencias Android/iOS.

Debe producir hipótesis comprobables y no limitarse a sugerir cambios aleatorios. Puede apoyarse en `xone-review` para confirmar hipótesis.

### 4.8. `xone-review`

Verificación y revisión en una sola skill: validación automatizada con el CLI `xone-simulator` del paquete `xone-linter` y revisión manual por capas.

Debe cubrir:

- `validate`: verificación estática (XML, atributos, unicidad, tipos, `progid`, ficheros, JS, referencias cruzadas y anti-patrones).
- `smoke`: ciclo de vida de toda la app con informe JSON y exit code encadenable.
- `run`: ejecución de un evento concreto para aislar fallos de runtime.
- `render`: render de una coll a HTML para diagnóstico de UI.
- Corrección iterativa hasta que la validación pase.
- Revisión por capas, anti-patrones, checklist de entrega y priorización por severidad, con archivo, línea, impacto y corrección propuesta.

Debe comprobar que `xone-simulator` exista e indicar `npm install -g xone-linter` si no. Trabaja sobre el paquete publicado, no asume acceso al código fuente del simulador.

**Nota de diseño (v0.10.0).** Antes eran dos skills, `xone-verification` y `xone-review`. Se fusionaron: envolvían el mismo CLI con el mismo bloque de comandos, describían el mismo bucle (validar → corregir → smoke) y sus descripciones disparaban con lo mismo («revisar si un cambio rompe la app» frente a «auditar un cambio antes de entregarlo»). No eran dos procedimientos, sino dos fases de uno. La duplicación ya había divergido: ambas repetían las reglas de sintaxis JavaScript y ambas estaban mal del mismo modo.

### 4.10. `xone-project-generator`

Generación de un proyecto XOne completo a partir de una descripción en lenguaje natural: flujo de 12 fases, plantillas de pantalla obligatorias, tamaños canónicos y prohibiciones explícitas.

Es una skill de **procedimiento**, no de conocimiento: impone un orden de trabajo. Durante la generación deriva a las skills de dominio para el detalle de cada área.

### 4.11. Objeto `ai`

El objeto `ai` (LLM local en el dispositivo) no tiene skill propia: vive como referencia de `xone-javascript`, porque es una superficie de API del runtime y no un dominio separado.

## 5. Flujo de selección de skills

1. Inspeccionar archivos y estructura del proyecto.
2. Clasificar la petición por uno o más dominios.
3. Aplicar primero las reglas transversales de `xone-development`.
4. Consultar la skill especializada principal.
5. Consultar una segunda skill solo si existe una dependencia real, por ejemplo XML + JavaScript o datos + permisos.
6. Generar la respuesta o el cambio con supuestos explícitos.
7. Ejecutar validaciones disponibles y reportar lo que no pueda verificarse.

La clasificación no debe depender únicamente de palabras clave. También debe considerar la extensión del archivo, los símbolos usados y el flujo funcional descrito por el usuario.

## 6. Contrato de cada skill

Cada skill debe incluir:

- Frontmatter con una descripción activable y concreta.
- Objetivo y límites del área.
- Método de inspección antes de editar.
- Reglas confirmadas y anti-patrones.
- Ejemplos mínimos, válidos y coherentes con el runtime.
- Checklist de validación.
- Referencias locales cuando el contenido supere el tamaño razonable del `SKILL.md`.
- Indicaciones para declarar incertidumbre o dependencia de versión.

Una skill no debe:

- Inventar atributos XML, tipos o APIs.
- Asumir que JavaScript moderno del navegador funciona en XOne.
- Ocultar permisos, credenciales, riesgos TLS o efectos sobre datos.
- Modificar archivos no relacionados con la tarea.
- Duplicar reglas contradictorias con otra skill.

## 7. Fuentes y revisión experta

### 7.1. Niveles de evidencia

Cada regla importante debe clasificarse internamente como:

- **A: documentación oficial:** descrita por la documentación de XOne o del framework.
- **B: código validado:** confirmada en un proyecto funcional y reproducible.
- **C: experiencia operativa:** patrón observado, pendiente de confirmación formal.
- **D: hipótesis:** no debe presentarse como solución confirmada.

Las reglas de nivel C deben incluir una nota de cautela. Las de nivel D no deben entrar en la skill publicada.

### 7.2. Revisores recomendados

- Experto de XML/UI XOne.
- Experto de JavaScript y runtime XOne.
- Experto de CSS y diseño responsive XOne.
- Experto de integraciones, seguridad y sincronización.
- Desarrollador que valide la experiencia real con Claude Code y OpenCode.

### 7.3. Proceso de revisión

1. Abrir una propuesta o issue con el cambio de conocimiento.
2. Identificar fuente, versión de XOne y alcance.
3. Revisar ejemplos y anti-patrones.
4. Probar el ejemplo en un proyecto XOne cuando sea posible.
5. Revisar activación y ausencia de contradicciones.
6. Registrar decisión, revisor y fecha.
7. Publicar solo después de resolver dudas críticas.

## 8. Versionado y compatibilidad

- El marketplace y el plugin usan versiones explícitas.
- Un cambio de reglas o comportamiento requiere incrementar la versión del plugin.
- Las correcciones de redacción sin cambio de comportamiento pueden usar una versión patch.
- Las nuevas skills o APIs compatibles incrementan minor.
- Cambios que retiren, contradigan o modifiquen reglas existentes incrementan major.
- Toda skill debe declarar si una API depende de una versión concreta del runtime XOne.
- Los cambios visibles para usuarios finales (skills, reglas, correcciones) se registrarán en `CHANGELOG.md` con la versión correspondiente.

## 9. Plan de implementación incremental

Para reducir riesgo y permitir revisión experta en cada paso, las skills no se construirán todas a la vez, sino en fases con dependencias explícitas:

### 9.1. Fase 0: habilitadores
- Crear `scripts/sync.sh` y validar la sincronización Claude Code/OpenCode.
- Añadir `CHANGELOG.md`.
- Declarar las versiones de XOne soportadas y registrar esa decisión.
- ✅ `xone-verification` (validación y smoke con el paquete npm `xone-linter`) — implementada en v0.2.0 y fusionada en `xone-review` en v0.10.0, sobre el paquete publicado como `xone-linter` en npm y en GitHub `sleiva/xone-linter`.

### 9.2. Fase 1: núcleo de dominio
- ✅ `xone-xml-ui` (colecciones, props, types válidos, combos, mapas, contents, layouts, visibilidad, ciclo de vida, progid, splash, encoding, macros, permisos y anti-patrones) — implementada en v0.3.0, alineada con las reglas del validador `xone-simulator`.
- ✅ `xone-debugging` (diagnóstico sistemático de errores y rendimiento, apoyado en `xone-simulator` validate/run/render/smoke) — implementada en v0.4.0.
- Son las de mayor retorno: cubren la mayoría de consultas y errores recurrentes.

### 9.3. Fase 2: runtime y estilo
- ✅ `xone-javascript` (objetos globales, ciclo de vida, callbacks, Futures, SQL seguro y patrones críticos) — implementada en v0.5.0, alineada con los métodos del runtime `xone-simulator`.
- ✅ `xone-css` (selectores, unidades, colores ARGB, atributos, herencia `extends`, estilos dinámicos, temas y animaciones) — implementada en v0.6.0.
- Fase 2 completa.

### 9.4. Fase 3: integraciones y dispositivo
- ✅ `xone-data-integration` (SQL, `$http`, OAuth2, TLS, réplica, mocks HTTP y seguridad) — implementada en v0.7.0, alineada con `mock/http.json` y el modo mock del `xone-simulator`.
- ✅ `xone-device` (GPS, cámara, permisos, biometría, Bluetooth, NFC, WebSocket, archivos y simulación `mock/device.json`) — implementada en v0.8.0.
- Fase 3 completa.

### 9.5. Fase 4: control de calidad
- ✅ `xone-review` (revisión de código: validación automatizada, revisión por capas, anti-patrones, checklist de entrega y severidades) — implementada en v0.9.0, alineada con los códigos reales del validador `xone-simulator`.
- Pruebas de activación real en proyectos XOne de ejemplo — pendiente.

Cada fase se revisa por expertos antes de iniciar la siguiente. Una fase solo se cierra cuando sus skills superan los criterios de aceptación aplicables a su área.

## 10. Estructura objetivo

```text
.
├── .claude-plugin/marketplace.json
├── docs/
│   ├── ARCHITECTURE.md
│   ├── ANALISIS.md
│   └── TODO.md
├── plugins/
│   └── xone-development/
│       ├── .claude-plugin/plugin.json
│       ├── commands/
│       │   └── xone-validate.md
│       └── skills/
│           ├── xone-development/     (SKILL.md + 5 referencias)
│           ├── xone-xml-ui/          (SKILL.md + 18 referencias)
│           ├── xone-javascript/      (SKILL.md + 16 referencias)
│           ├── xone-css/             (SKILL.md + 6 referencias)
│           ├── xone-data-integration/(SKILL.md + 5 referencias)
│           ├── xone-device/          (SKILL.md + 4 referencias)
│           ├── xone-project-generator/(SKILL.md + 14 referencias)
│           ├── xone-debugging/       (SKILL.md + 2 referencias)
│           └── xone-review/          (SKILL.md)
├── scripts/validate-skills.sh
├── xone/                             # fuente canónica, versionada
├── opencode.json
└── README.md
```

### 10.1 Patrón de supporting files

Cada skill se organiza siguiendo el patrón estándar de Agent Skills (compatible con Claude Code y OpenCode):

```text
<skill-name>/
├── SKILL.md              # requerido — reglas duras + índice de navegación (<500 líneas)
└── references/           # opcional — material autoritativo troceado, carga perezosa
```

- **`SKILL.md`** se carga siempre al invocar la skill. Contiene solo lo que hace falta en todo momento: reglas ancladas al corpus, anti-patrones y un índice «para responder X, lee Y». Se mantiene por debajo de 500 líneas.
- **`references/`** contiene el **material original completo**, no resúmenes. Es la diferencia que define el patrón: si la referencia también resume, no hay divulgación progresiva, hay pérdida de información. El agente las lee bajo demanda con `Read`.

**Troceo por bytes, no por líneas.** El presupuesto por chunk es de ~15-35 KB, no un número de líneas: la densidad varía mucho entre documentos (una guía con ejemplos ronda 30 B/línea, una tabla de atributos 66 B/línea), así que un límite en líneas produce chunks del doble del coste previsto en los documentos densos. Se corta por secciones completas, nunca a mitad de una.

**Procedencia declarada.** Cada chunk abre con su origen, de modo que cualquier regla se puede rastrear hasta la fuente:

```markdown
> Fuente: `xone/xone-help-docs/topics/04-css-styling-guide.md` §1–§4.
```

**Sin pipeline de sincronización.** Los chunks se generaron una sola vez desde `xone/` y se versionan ya troceados. No hay script de build que regenere en cada cambio: un mecanismo así vuelve a introducir el problema de la copia que se desincroniza en silencio (fue la razón de retirar `scripts/sync.sh`). La trazabilidad la dan la cabecera de procedencia y que `xone/` esté en git.

**Reglas duplicadas a propósito.** Algunas reglas aparecen en más de un `SKILL.md` porque son necesarias en varios contextos: tipos de prop válidos (`xone-development`, `xone-xml-ui`, `xone-review`), bitmask de visibilidad (los mismos tres), opcionalidad de `progid` (`xone-development`, `xone-xml-ui`, `xone-review`), encoding de los `.xne` (`xone-development`, `xone-xml-ui`), sintaxis JavaScript soportada (`xone-development`, `xone-javascript`, `xone-review`) y patrones lock/unlock y browse (`xone-javascript`, `xone-review`). **Una corrección en cualquiera de ellas debe aplicarse en todas.** El caso del bit `8` de visibilidad ya mostró el modo de fallo: se corrigió en un sitio y quedó desalineado en otro hasta que se revisó el conjunto. Ningún check automático detecta dos skills afirmando reglas opuestas.

**El índice hace el enrutado.** Con las referencias troceadas y un índice que dice qué fichero responde a qué pregunta, la frontera entre skills pesa mucho menos de lo que pesaba cuando el conocimiento vivía en el `SKILL.md`. Eso abre la puerta a consolidar skills (ver §13.4).

## 11. Criterios de aceptación

La arquitectura se considerará lista para implementación cuando:

- Cada skill tenga un objetivo que no se solape de forma ambigua con otra.
- Exista una fuente o responsable para cada regla crítica.
- El flujo de selección funcione con tareas XML, JavaScript, CSS y debugging.
- Las skills puedan instalarse en Claude Code y descubrirse en OpenCode.
- Existan ejemplos mínimos verificables para cada dominio.
- Las skills se descubran en OpenCode vía `skills.paths` sin copia duplicada.
- Cada `SKILL.md` incluya `name` en el frontmatter y se mantenga por debajo de 500 líneas.
- El material extenso (API, snippets, tablas de errores) viva en `references/` y se cargue perezosamente.
- La activación real esté validada: una tarea de prueba invoca la skill adecuada sin intervención del usuario.
- Dos revisores expertos hayan aprobado las reglas críticas de su área.

## 12. Decisiones pendientes

- Confirmar las versiones de XOne que se quieren soportar (condiciona el tono y las reglas de todas las skills).
- Definir los proyectos de prueba representativos para XML/UI, datos, dispositivos y debugging.
- Confirmar los expertos responsables de cada área y el canal de revisión.
- Completar pruebas de activación real con tareas ejecutadas por un agente.

### Resuelto

- Sincronización Claude Code/OpenCode: resuelta sin duplicación mediante `skills.paths` en `opencode.json` (ver §3.4). Se eliminó `.opencode/skills/` y `scripts/sync.sh`.
- `CHANGELOG.md`: registra los cambios visibles desde v0.1.0 hasta v0.9.0.
- Ubicación de las referencias completas: dentro del plugin, en `skills/<name>/references/`, con carga perezosa (ver §10.1).
- Contenido de las referencias: material original troceado, no resúmenes (v0.10.0, ver §10.1 y `ANALISIS.md`).
- Fuente canónica: `xone/` se versiona en git, lo que hace cierto el §2.5 y los niveles de evidencia del §7.1.
- Hogar del objeto `ai`: referencia de `xone-javascript` (§4.11).
- Rol de `xone-development`: dominio propio de fundamentos, no coordinadora (§4.1).

## 13. Tareas pendientes

### 13.1. Refactor de skills con `references/` (completado en v0.10.0)

Aplicado a las diez skills. El refactor de la v0.9.0 se había registrado como completado, pero lo que produjo fueron resúmenes en prosa: ~1.000 líneas frente a las ~46.000 del corpus. La v0.10.0 sustituye esos resúmenes por 70 chunks (1,3 MB) extraídos del original. Diagnóstico completo en [`ANALISIS.md`](ANALISIS.md).

### 13.2. Frontmatter `name` (completado)

Todos los `SKILL.md` declaran `name` coincidente con su directorio. Lo verifica `scripts/validate-skills.sh`.

### 13.3. Pruebas de activación real (pendiente — bloquea §13.4)

**Prioridad: alta.** Es la única tarea que queda del plan original y de la que dependen las decisiones de taxonomía.

Definir 1-2 proyectos XOne mínimos y ejecutar tareas en sesiones aisladas para confirmar que se invoca la skill correcta. El validador estático no sustituye la prueba semántica.

Cobertura mínima:

- [ ] Proyecto XOne de prueba con XML, JS y CSS mínimos.
- [ ] Tarea XML → debe invocar `xone-xml-ui`.
- [ ] Tarea JavaScript → debe invocar `xone-javascript`.
- [ ] Tarea de validación → debe invocar `xone-review`.
- [ ] **Tarea que cruza áreas** (p. ej. añadir un filtro a una pantalla de listado: `.xne` + evento JS + clase CSS) → medir si el agente abre más de una skill o improvisa el resto. De esto depende §13.4.
- [x] Script de validación estructural y descubrimiento: `scripts/validate-skills.sh`.

### 13.4. Consolidación de fronteras entre skills (pendiente, depende de §13.3)

La taxonomía divide el conocimiento por área temática, pero las tareas de XOne llegan cruzadas: una pantalla es `.xne` + evento JavaScript + clase CSS. Además, `xone-data-integration` y `xone-device` no son dominios independientes, sino superficies de API que se invocan desde JavaScript.

Con las referencias troceadas y un índice que enruta (§10.1), el número de puertas importa menos que antes. La asimetría de coste es clara: cargar reglas de un área que no hacía falta cuesta unos miles de tokens; abrir la skill equivocada hace que el agente escriba de memoria, es decir, invente.

La fusión de `xone-verification` en `xone-review` ya está hecha (§4.8): no necesitaba medición previa porque el problema era contenido duplicado que ya había divergido, no una duda empírica sobre activación. Las opciones que quedan, a decidir **con los datos de §13.3**, no por intuición:

1. **Siete puertas.** `data-integration` y `device` pasan a ser grupos de referencias de `xone-javascript`; se mantienen `xml-ui`, `css`, `development` y las tres de procedimiento.
2. **Cuatro puertas.** Una sola de conocimiento (`xone-development` con el índice maestro) más las de procedimiento: `project-generator`, `review` y `debugging`.
3. **Nueve, como ahora.**

Criterio propuesto para decidir: *el conocimiento va a referencias bajo una puerta; el procedimiento merece puerta propia, porque cambia cómo trabaja el agente.*

Reubicar chunks es barato (cambiar una ruta y reescribir índices de ~20 líneas); el corpus es idéntico en las tres opciones.

### 13.5. Consolidación editorial de las dos redacciones (pendiente, prioridad baja)

`xone/` contiene dos redacciones del mismo conocimiento con cortes temáticos distintos (`xone-help-docs/topics/` y `xone-project-generator/references/`), cada una con material único. Donde la cobertura difería se importaron ambas, con el índice indicando qué aporta cada una. Unificarlas es trabajo editorial sobre miles de líneas y no bloquea nada; hacerlo eliminaría las referencias marcadas como «referencia ampliada» en `xone-data-integration` y `xone-device`.
