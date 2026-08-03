# Arquitectura de Skills XOne

**Estado:** borrador para revisión

**Versión:** 0.1

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

OpenCode descubre skills desde `.opencode/skills/<name>/SKILL.md`. Durante la primera fase se mantiene una copia compatible de las skills:

```text
.opencode/skills/<skill-name>/SKILL.md
opencode.json
```

La fuente canónica será `plugins/xone-development/skills/`. Las copias de OpenCode deben mantenerse sincronizadas y no deben introducir reglas diferentes.

La sincronización se automatizará con un script `scripts/sync.sh` que copie la fuente canónica hacia `.opencode/skills/` y verifique cada fichero con `cmp`, para fail si divergen. Se ejecutará de forma local y, si se habilita CI, como paso de validación. Esto evita duplicación manual y cubre la aceptación "sincronizarse sin divergencias manuales".

## 4. Taxonomía propuesta

### 4.1. `xone-development`

Skill coordinadora y punto de entrada. Debe detectar el área principal, aplicar el método de trabajo común y derivar mentalmente al conocimiento especializado.

Responsabilidades:

- Inspección inicial del proyecto.
- Clasificación de la tarea.
- Reglas transversales de seguridad, rendimiento y cambios mínimos.
- Formato de respuesta y reporte de verificación.
- Identificación de incertidumbres y necesidad de consultar a un experto.

No debe contener la referencia completa de todas las APIs XOne.

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

### 4.7. `xone-verification`

Verificación automática de proyectos XOne con el CLI `xone-simulator` del paquete `xone-linter` (publicado en npm como `xone-linter`).

Debe cubrir:

- `validate`: verificación estática (XML, atributos, unicidad, tipos, `progid`, ficheros, JS, referencias cruzadas y anti-patrones).
- `smoke`: ciclo de vida de toda la app con informe JSON y exit code encadenable.
- `run`: ejecución de un evento concreto de una coll/prop para aislar fallos de runtime.
- `render`: render de una coll a HTML para diagnóstico de UI.
- Corrección iterativa: detectar errores, corregir, revalidar hasta que pase.

Debe comprobar que `xone-simulator` exista en el entorno e indicar `npm install -g xone-linter` si no. Trabaja en entornos con el paquete publicado, no asume acceso al código fuente del simulador.

### 4.8. `xone-debugging`

Diagnóstico sistemático de errores de compilación, carga, UI, datos, red, rendimiento y diferencias Android/iOS.

Debe producir hipótesis comprobables y no limitarse a sugerir cambios aleatorios. Puede apoyarse en `xone-verification` para confirmar hipótesis.

### 4.9. `xone-review`

Revisión de código orientada a bugs, seguridad, rendimiento, compatibilidad y cobertura de casos límite.

Los hallazgos deben ordenarse por severidad e incluir archivo, línea, impacto y corrección propuesta.

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
- ✅ `xone-verification` (validación y smoke con el paquete npm `xone-linter`) — implementada en v0.2.0, sobre el paquete publicado como `xone-linter` en npm y en GitHub `sleiva/xone-linter`.

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
├── .claude-plugin/
│   └── marketplace.json
├── .opencode/
│   └── skills/
│       └── xone-development/
│           └── SKILL.md
├── docs/
│   └── ARCHITECTURE.md
├── scripts/
│   └── sync.sh
├── plugins/
│   └── xone-development/
│       ├── .claude-plugin/plugin.json
│       └── skills/
│           ├── xone-development/
│           │   └── SKILL.md
│           ├── xone-xml-ui/
│           │   ├── SKILL.md
│           │   └── references/
│           ├── xone-javascript/
│           ├── xone-css/
│           ├── xone-data-integration/
│           ├── xone-device/
│           ├── xone-verification/
│           │   └── SKILL.md
│           ├── xone-debugging/
│           └── xone-review/
├── opencode.json
└── README.md
```

## 11. Criterios de aceptación

La arquitectura se considerará lista para implementación cuando:

- Cada skill tenga un objetivo que no se solape de forma ambigua con otra.
- Exista una fuente o responsable para cada regla crítica.
- El flujo de selección funcione con tareas XML, JavaScript, CSS y debugging.
- Las skills puedan instalarse en Claude Code y descubrirse en OpenCode.
- Existan ejemplos mínimos verificables para cada dominio.
- La copia de OpenCode pueda sincronizarse sin divergencias manuales mediante `scripts/sync.sh`.
- La activación real esté validada: una tarea de prueba invoca la skill adecuada sin intervención del usuario.
- Dos revisores expertos hayan aprobado las reglas críticas de su área.

## 12. Decisiones pendientes

- Confirmar las versiones de XOne que se quieren soportar (condiciona el tono y las reglas de todas las skills).
- Decidir si las referencias completas se publicarán dentro del plugin o en un repositorio documental separado.
- Elegir si la sincronización Claude Code/OpenCode será manual inicialmente o automatizada mediante `scripts/sync.sh`.
- Definir los proyectos de prueba representativos para XML/UI, datos, dispositivos y debugging.
- Confirmar los expertos responsables de cada área y el canal de revisión.
