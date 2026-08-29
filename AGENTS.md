# AGENTS.md

Repositorio de skills de XOne para agentes de código.

## Skills

Las skills viven en `plugins/xone-development/skills/`, una carpeta por skill con su
`SKILL.md` y sus referencias:

- `xone-development` — conocimiento de XOne: XML `.xne`, JavaScript del runtime, CSS,
  datos e integración, dispositivo y fundamentos de proyecto.
- `xone-spec-builder` — especificar cualquier desarrollo XOne por entrevista antes de
  ejecutarlo (app nueva, feature, refactor, integración de dispositivo, cambio de
  modelo de datos, rediseño de pantalla): afina modelo de datos, pantallas, navegación,
  integraciones y estilo, y deja un `PLAN.md` que `xone-plan-builder` descompone en
  tareas y que `xone-project-generator` o `xone-development` ejecutan.
- `xone-plan-builder` — descomponer el `PLAN.md` (spec) en un plan de ejecución
  (`TASKS.md`): tareas tracer-bullet verticales con dependencias explícitas que
  `xone-project-generator` o `xone-development` ejecutan una a una.
- `xone-project-generator` — generar un proyecto XOne completo desde cero.
- `xone-review` — validar, hacer smoke y auditar con `xone-simulator`.
- `xone-debugging` — diagnosticar un fallo a partir de su síntoma.

Al trabajar sobre un proyecto XOne, carga la skill correspondiente desde esa ruta antes
de responder. No afirmes nada sobre XOne que no esté en sus referencias.

## Requisito de entorno

Las skills `xone-review` y `xone-debugging` usan el CLI `xone-simulator`:

    npm install -g xone-linter
