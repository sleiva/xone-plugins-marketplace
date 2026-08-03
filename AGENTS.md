# AGENTS.md

Repositorio de skills de XOne para agentes de código.

## Skills

Las skills viven en `plugins/xone-development/skills/`, una carpeta por skill con su
`SKILL.md` y sus referencias:

- `xone-development` — conocimiento de XOne: XML `.xne`, JavaScript del runtime, CSS,
  datos e integración, dispositivo y fundamentos de proyecto.
- `xone-project-generator` — generar un proyecto XOne completo desde cero.
- `xone-review` — validar, hacer smoke y auditar con `xone-simulator`.
- `xone-debugging` — diagnosticar un fallo a partir de su síntoma.

Al trabajar sobre un proyecto XOne, carga la skill correspondiente desde esa ruta antes
de responder. No afirmes nada sobre XOne que no esté en sus referencias.

## Requisito de entorno

Las skills `xone-review` y `xone-debugging` usan el CLI `xone-simulator`:

    npm install -g xone-linter
