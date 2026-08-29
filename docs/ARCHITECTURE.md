# Arquitectura de Skills XOne

**Estado:** skills implementadas, capa de referencias reconstruida sobre el corpus original (v0.10.0), adaptación a OpenCode y Antigravity completada, y consolidación de nueve skills a cuatro completada (v1.1.0, ver §13.4). La integración con `xone-db-tools` está documentada en v1.2.0. Pendiente: pruebas de activación con tareas reales, versiones soportadas de XOne y revisión experta.

**Versión:** 0.3

**Ámbito:** marketplace `xone-plugins-marketplace`, plugin `xone-development`, skills compatibles con Claude Code, OpenCode y Antigravity, y uso de las herramientas npm `xone-linter` y `xone-db-tools`.

## 1. Objetivo

Construir un conjunto de skills que ayude a desarrollar, revisar y depurar aplicaciones XOne con respuestas técnicamente fiables y cambios mínimos.

La arquitectura debe:

- Separar el conocimiento por áreas para reducir instrucciones irrelevantes.
- Activar la skill adecuada según la tarea, sin obligar al usuario a conocer la taxonomía.
- Mantener las restricciones reales del runtime XOne visibles y verificables.
- Funcionar en Claude Code, OpenCode y Antigravity sin crear comportamientos incompatibles.
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

Claude Code, OpenCode y Antigravity comparten el formato `SKILL.md`, pero no comparten los mecanismos de instalación. La documentación y las pruebas deben distinguir cada canal.

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
├── references/        # opcional
└── agents/            # opcional — metadatos por plataforma
```

**`agents/openai.yaml`**, cuando existe, lleva dos bloques: `interface` (`display_name`,
`short_description`) y `policy` (`allow_implicit_invocation`). **Hoy solo lo tienen
`xone-spec-builder` y `xone-plan-builder`**, las dos skills que entraron el 2026-08-29, y **no
está decidido si las otras cuatro deben tenerlo**: el fichero se añadió con ellas y ningún
documento del repositorio dice qué lo consume. Queda anotado como pregunta abierta en vez de
como convención, que es lo que era hasta hoy — un artefacto sin dueño en el árbol.

### 3.4. Adaptador OpenCode

OpenCode descubre skills desde varias rutas (`.opencode/skills/`, `.claude/skills/`, `.agents/skills/`) y, además, permite apuntar a carpetas arbitrarias mediante el campo `skills.paths` de `opencode.json`. No se mantiene copia duplicada: la fuente canónica `plugins/xone-development/skills/` se referencia directamente.

```json
{
  "$schema": "https://opencode.ai/config.json",
  "skills": { "paths": ["./plugins/xone-development/skills"] }
}
```

La carpeta `.opencode/` queda reservada para el entorno de desarrollo de plugins OpenCode (`node_modules`, `package.json` con `@opencode-ai/plugin`) y se ignora en git.

### 3.5. Adaptador Antigravity

Antigravity descubre skills Agent Skills desde dos ubicaciones:

```text
<workspace>/.agents/skills/<skill-name>/SKILL.md
~/.gemini/config/skills/<skill-name>/SKILL.md
```

La instalación global usa enlaces simbólicos hacia la fuente canónica
`plugins/xone-development/skills/`, evitando copias duplicadas. Antigravity no
consume `.claude-plugin/marketplace.json`, `opencode.json` ni el comando
`/xone-validate`; para validar se ejecutan directamente `xone-simulator` y
`xone-db-tools`.

### 3.6. Frontmatter compatible

OpenCode exige `name` en el frontmatter (debe coincidir con el nombre del directorio y seguir `^[a-z0-9]+(-[a-z0-9]+)*$`). Claude Code lo trata como opcional. Para compatibilidad cruzada, todo `SKILL.md` debe incluir:

```yaml
---
name: xone-debugging
description: ...
---
```

## 4. Taxonomía

### 4.1. `xone-development`

Puerta de conocimiento: todas las reglas duras de XOne y el índice maestro de referencias, organizado en subcarpetas por área.

Responsabilidades:

- Anatomía del proyecto: carpetas, ficheros raíz, `app.xml`, `app.ini`, `mappings.xne`.
- Conceptos base: colecciones, DataObject, props, `##PREF##`, macros del sistema, códigos de error.
- Qué sintaxis JavaScript soporta el motor.
- Reglas transversales: la fuente son los `.xne`, unicidad y case-sensitivity de nombres, encoding, `progid` opcional, evento correcto de inicialización.
- XML `.xne`, `app.xml`, colecciones, grupos, frames, props, contents, layouts, herencia, macros, permisos y validación estructural (subcarpeta `references/xml-ui/`).
- JavaScript del runtime, objetos globales, ciclo de vida, navegación, controles, callbacks, Futures y patrones de datos (subcarpeta `references/javascript/`).
- Selectores CSS, unidades, colores, temas, herencia y animaciones (subcarpeta `references/css/`).
- Colecciones, SQL, `$http`, OAuth2, TLS, réplica y tratamiento de credenciales (subcarpeta `references/datos/`).
- GPS, cámara, archivos, permisos de runtime, biometría, Bluetooth, NFC y capacidades del dispositivo (subcarpeta `references/device/`).

No debe contener la referencia completa de todas las APIs XOne en el propio `SKILL.md`: eso vive en `references/`.

**Nota de diseño (v0.10.0).** Hasta la v0.9.0 esta skill se describió como «coordinadora y punto de entrada». No es implementable: la selección de skill se hace por coincidencia con la `description`, y no existe mecanismo de routing entre skills — una descripción que cubría todos los dominios capturaba casi cualquier consulta y su cuerpo no derivaba a ningún sitio. La skill pasó a tener un dominio propio y no solapable.

**Nota de diseño (v1.1.0).** Las cinco skills de conocimiento que existían por separado (`xone-xml-ui`, `xone-javascript`, `xone-css`, `xone-data-integration`, `xone-device`) se fusionaron en esta. Las tareas de XOne llegan cruzadas — una pantalla es `.xne` más evento JavaScript más clase CSS — y con activación automática el caso a cubrir era que el agente abriera una sola puerta y escribiera el resto de memoria. Sus 54 ficheros de referencia pasaron a ser subcarpetas de `xone-development/references/` sin cambiar contenido. Ver §10.1 (invariante «una regla, un sitio») y §13.4 (decisión y alternativas descartadas).

### 4.2. `xone-debugging`

Diagnóstico sistemático de errores de compilación, carga, UI, datos, red, rendimiento y diferencias Android/iOS.

Debe producir hipótesis comprobables y no limitarse a sugerir cambios aleatorios. Puede apoyarse en `xone-review` para confirmar hipótesis. No repite las reglas de `load`, `lock`/`unlock` ni `MAP_`: las referencia desde `xone-development`.

### 4.3. `xone-review`

Verificación y revisión en una sola skill: validación automatizada con el CLI `xone-simulator` del paquete `xone-linter` y revisión manual por capas.

Debe cubrir:

- `validate`: verificación estática (XML, atributos, unicidad, tipos, `progid`, ficheros, JS, referencias cruzadas y anti-patrones).
- `smoke`: ciclo de vida de toda la app con informe JSON y exit code encadenable.
- `run`: ejecución de un evento concreto para aislar fallos de runtime.
- `render`: render de una coll a HTML para diagnóstico de UI.
- Corrección iterativa hasta que la validación pase.
- Checklist de entrega y priorización por severidad, con archivo, línea, impacto y corrección propuesta. Anti-patrones y reglas por capa se referencian desde `xone-development` (§10.1), no se repiten aquí.

Debe comprobar que `xone-simulator` y, cuando exista `bd/gestion.db`,
`xone-db-tools` existan. Si faltan, indicar:

```bash
npm install -g xone-linter xone-db-tools
```

`xone-db-tools validate-db` valida la integridad y el esquema de la BD contra
los `.xne`; `xone-db-tools describe-table` permite inspeccionar una tabla.
Ambas herramientas trabajan sobre paquetes publicados y no asumen acceso a sus
repositorios fuente.

**Nota de diseño (v0.10.0).** Antes eran dos skills, `xone-verification` y `xone-review`. Se fusionaron: envolvían el mismo CLI con el mismo bloque de comandos, describían el mismo bucle (validar → corregir → smoke) y sus descripciones disparaban con lo mismo («revisar si un cambio rompe la app» frente a «auditar un cambio antes de entregarlo»). No eran dos procedimientos, sino dos fases de uno. La duplicación ya había divergido: ambas repetían las reglas de sintaxis JavaScript y ambas estaban mal del mismo modo.

**Nota de diseño (v1.1.0).** Pierde la lista de anti-patrones y las reglas por capa que antes repetía: viven una sola vez en `xone-development` (§10.1) y esta skill las referencia.

### 4.4. `xone-project-generator`

Generación de un proyecto XOne completo a partir de una descripción en lenguaje natural: flujo de 12 fases, plantillas de pantalla obligatorias, tamaños canónicos y prohibiciones explícitas.

Es una skill de **procedimiento**, no de conocimiento: impone un orden de trabajo. Durante la generación deriva a `xone-development` para el detalle de cada área. Sus «Prohibiciones explícitas» que coincidían con reglas del corpus pasaron a ser un puntero a la puerta de conocimiento (§10.1).

### 4.5. Objeto `ai`

El objeto `ai` (LLM local en el dispositivo) no tiene skill propia: vive como referencia de `xone-development` (subcarpeta `references/javascript/`), porque es una superficie de API del runtime y no un dominio separado.

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
- ✅ `xone-xml-ui` (colecciones, props, types válidos, combos, mapas, contents, layouts, visibilidad, ciclo de vida, progid, splash, encoding, macros, permisos y anti-patrones) — implementada en v0.3.0, alineada con las reglas del validador `xone-simulator`; fusionada en `xone-development` en v1.1.0 (§4.1, §13.4).
- ✅ `xone-debugging` (diagnóstico sistemático de errores y rendimiento, apoyado en `xone-simulator` validate/run/render/smoke) — implementada en v0.4.0.
- Son las de mayor retorno: cubren la mayoría de consultas y errores recurrentes.

### 9.3. Fase 2: runtime y estilo
- ✅ `xone-javascript` (objetos globales, ciclo de vida, callbacks, Futures, SQL seguro y patrones críticos) — implementada en v0.5.0, alineada con los métodos del runtime `xone-simulator`; fusionada en `xone-development` en v1.1.0 (§4.1, §13.4).
- ✅ `xone-css` (selectores, unidades, colores ARGB, atributos, herencia `extends`, estilos dinámicos, temas y animaciones) — implementada en v0.6.0; fusionada en `xone-development` en v1.1.0 (§4.1, §13.4).
- Fase 2 completa.

### 9.4. Fase 3: integraciones y dispositivo
- ✅ `xone-data-integration` (SQL, `$http`, OAuth2, TLS, réplica, mocks HTTP y seguridad) — implementada en v0.7.0, alineada con `mock/http.json` y el modo mock del `xone-simulator`; fusionada en `xone-development` en v1.1.0 (§4.1, §13.4).
- ✅ `xone-device` (GPS, cámara, permisos, biometría, Bluetooth, NFC, WebSocket, archivos y simulación `mock/device.json`) — implementada en v0.8.0; fusionada en `xone-development` en v1.1.0 (§4.1, §13.4).
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
│           ├── xone-development/     (SKILL.md, <400 líneas, + 54 referencias en subcarpetas por área)
│           │   └── references/
│           │       ├── fundamentos/  (5 referencias)
│           │       ├── xml-ui/       (18 referencias)
│           │       ├── javascript/   (16 referencias)
│           │       ├── css/          (6 referencias)
│           │       ├── datos/        (5 referencias)
│           │       └── device/       (4 referencias)
│           ├── xone-project-generator/(SKILL.md + 14 referencias)
│           ├── xone-debugging/       (SKILL.md + 2 referencias)
│           └── xone-review/          (SKILL.md)
├── scripts/validate-skills.sh
├── xone/                             # fuente canónica, versionada
├── opencode.json
├── AGENTS.md                         # descubrimiento de skills desde Codex
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

**Una regla, un sitio (v1.1.0).** Antes de la consolidación, la misma regla vivía en tres o cuatro `SKILL.md` a la vez — tipos de prop válidos, bitmask de visibilidad, opcionalidad de `progid`, sintaxis JavaScript soportada — y ya había divergido dos veces en una sola sesión de trabajo (el bit `8` de visibilidad se corrigió en un sitio y no en otro). Con una sola puerta de conocimiento, el invariante pasa a ser explícito: **una regla se escribe una vez, en `xone-development`; las skills de procedimiento (`xone-project-generator`, `xone-review`, `xone-debugging`) la referencian, no la repiten.** `xone-review` perdió su lista de anti-patrones y sus reglas por capa; `xone-debugging` dejó de repetir las reglas de `load`, `lock`/`unlock` y `MAP_`; `xone-project-generator` convirtió sus «Prohibiciones explícitas» que coincidían con reglas del corpus en un puntero a la puerta.

El invariante lo hace cumplir `scripts/validate-skills.sh` con un guardián de duplicados, y su cobertura real es más estrecha que «línea a línea»: de cada par de `SKILL.md` compara solo las líneas de contenido (sin frontmatter, encabezados ni bloques de código) de **más de 35 caracteres** (`dup_min_line_length`) que tengan al menos **3 tokens significativos** (`dup_min_significant_tokens`) de **5 o más caracteres** (`dup_min_token_length`); dos líneas que superan el **65% de solape** de esos tokens (`dup_overlap_threshold`) se tratan como la misma regla escrita dos veces. Una allowlist corta y documentada (8 entradas, cada una atada a un fragmento de texto y con su razón) cubre los falsos positivos verificados a mano: citas del mismo código de error en dos tablas distintas, avisos operativos que no son reglas de XOne, punteros de navegación entre skills y coincidencias de vocabulario de dominio sin ser la misma regla.

**Lo que el guardián no ve.** El filtro de 35 caracteres descarta solo una minoría de las líneas de contenido candidatas (~14% en las cuatro `SKILL.md` actuales) — pero es justo ahí, en filas de tabla y viñetas cortas, donde vive buena parte de las reglas duplicadas de una sola línea (tipos de prop, bitmask de visibilidad), así que esa duplicación de línea corta puede colarse sin que el guardián la vea. Y por diseño solo detecta paráfrasis con vocabulario compartido: dos formulaciones de la misma regla que no comparten suficientes tokens (por debajo del 65%, o con muy pocos tokens significativos) tampoco se detectan. Es una red con una malla de un tamaño conocido, no una prueba de ausencia de duplicación.

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
- Hogar del objeto `ai`: referencia de `xone-development` (§4.5).
- Rol de `xone-development`: dominio propio de fundamentos, no coordinadora (§4.1).
- Consolidación de fronteras entre skills: cuatro puertas (§13.4, v1.1.0).

## 13. Tareas pendientes

### 13.1. Refactor de skills con `references/` (completado en v0.10.0)

Aplicado a las diez skills. El refactor de la v0.9.0 se había registrado como completado, pero lo que produjo fueron resúmenes en prosa: ~1.000 líneas frente a las ~46.000 del corpus. La v0.10.0 sustituye esos resúmenes por 70 chunks (1,3 MB) extraídos del original. Diagnóstico completo en [`ANALISIS.md`](ANALISIS.md).

### 13.2. Frontmatter `name` (completado)

Todos los `SKILL.md` declaran `name` coincidente con su directorio. Lo verifica `scripts/validate-skills.sh`.

### 13.3. Pruebas de activación real (pendiente)

**Prioridad: alta.** Es la única tarea que queda del plan original.

Definir 1-2 proyectos XOne mínimos y ejecutar tareas en sesiones aisladas para confirmar que se invoca la skill correcta y que el agente abre las referencias, no que improvisa. El validador estático no sustituye la prueba semántica.

**Simplificada por la consolidación a cuatro puertas (§13.4, v1.1.0).** Con seis skills de conocimiento solapadas, la pregunta era «¿elige el agente la puerta correcta entre seis?». Con una sola puerta de conocimiento, esa pregunta casi desaparece: ya no hay elección que hacer entre puertas de conocimiento. Queda la pregunta que de verdad importaba: **invocada `xone-development`, ¿el agente lee la referencia del índice, o contesta solo con las reglas del `SKILL.md`?**

Cobertura mínima:

- [ ] Proyecto XOne de prueba con XML, JS y CSS mínimos.
- [ ] Tarea XML, JavaScript o CSS → debe invocar `xone-development` y abrir la referencia indicada por su índice, no responder solo con las reglas de cabecera.
- [ ] Tarea de validación → debe invocar `xone-review`.
- [ ] **Tarea que cruza áreas** (p. ej. añadir un filtro a una pantalla de listado: `.xne` + evento JS + clase CSS) → con una sola puerta de conocimiento ya no hay que medir cuántas skills abre; medir si dentro de esa puerta lee las referencias de las áreas relevantes o improvisa alguna.
- [x] Script de validación estructural y descubrimiento: `scripts/validate-skills.sh`.

### 13.4. Consolidación de fronteras entre skills (resuelto en v1.1.0, 2026-08-03)

La taxonomía dividía el conocimiento por área temática, pero las tareas de XOne llegan cruzadas: una pantalla es `.xne` + evento JavaScript + clase CSS. Además, `xone-data-integration` y `xone-device` no eran dominios independientes, sino superficies de API que se invocan desde JavaScript.

Con las referencias troceadas y un índice que enruta (§10.1), el número de puertas pesaba menos que antes. La asimetría de coste era clara: cargar reglas de un área que no hacía falta cuesta unos miles de tokens; abrir la skill equivocada hace que el agente escriba de memoria, es decir, invente.

La fusión de `xone-verification` en `xone-review` ya estaba hecha (§4.3): no necesitó medición previa porque el problema era contenido duplicado que ya había divergido, no una duda empírica sobre activación. La decisión sobre las skills de conocimiento se tomó sin esperar a §13.3 (las pruebas de activación seguían pendientes): el peor caso — el agente abre una sola puerta y escribe el resto de memoria — era seguro de evitar solo con una puerta única, y la asimetría de coste (context innecesario vs. invención) hacía que esperar no compensara.

**Opción elegida: cuatro puertas.** Una sola de conocimiento (`xone-development`, con las 54 referencias de las cinco skills absorbidas como subcarpetas por área) más las tres de procedimiento: `xone-project-generator`, `xone-review` y `xone-debugging`.

Opciones descartadas:

1. **Siete puertas.** `data-integration` y `device` como grupos de referencias de `xone-javascript`, manteniendo `xml-ui`, `css`, `development` y las tres de procedimiento separadas. Conservaba intacto el defecto de fondo: una tarea que toca pantalla y evento seguía necesitando dos puertas de conocimiento.
2. **Nueve, como estaba.** No resolvía nada.

Criterio aplicado: *el conocimiento va a referencias bajo una puerta; el procedimiento merece puerta propia, porque cambia cómo trabaja el agente.* El invariante resultante, «una regla, un sitio», y el guardián que lo hace cumplir están en §10.1.

### 13.5. Consolidación editorial de las dos redacciones (pendiente, prioridad baja)

`xone/` contiene dos redacciones del mismo conocimiento con cortes temáticos distintos (`xone-help-docs/topics/` y `xone-project-generator/references/`), cada una con material único. Donde la cobertura difería se importaron ambas, con el índice indicando qué aporta cada una. Unificarlas es trabajo editorial sobre miles de líneas y no bloquea nada; hacerlo eliminaría las referencias marcadas como «referencia ampliada» en `xone-development/references/datos/` y `xone-development/references/device/`.
