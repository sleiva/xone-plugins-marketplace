---
description: Descompone un PLAN.md (spec) en tareas tracer-bullet con dependencias (TASKS.md) para ejecutar un desarrollo XOne
argument-hint: [ruta del proyecto con PLAN.md]
allowed-tools: Read, Edit, Write, Glob, Grep
---

Descompone el `PLAN.md` producido por `xone-spec-builder` en un plan de ejecución (`TASKS.md`): tareas tracer-bullet verticales con dependencias explícitas.

Procedimiento:

1. **Carga la skill `xone-plan-builder`** por su nombre y síguela estrictamente. Carga también `xone-development` para conocer las dependencias naturales entre colls, pantallas, eventos y estilo.
2. **Directorio de trabajo.** Usa `$1` si se indicó; si no, usa el directorio actual. `TASKS.md` se escribe junto a `PLAN.md`.
3. **Valida precondiciones.** Lee `PLAN.md`. Si no existe, detente y pide al usuario que ejecute `xone-spec-builder` primero. Si tiene pendientes bloqueantes o decisiones sin resolver, devuelve el spec a `xone-spec-builder` con una nota específica de qué falta —no inventes las respuestas.
4. **Descompone en tareas tracer-bullet.** Sigue las reglas del SKILL.md: cortes verticales (no horizontales), cada uno demoable y verificable, cada uno cabe en un context window, cada uno declara sus dependencias. Respeta el orden natural de XOne: mappings → colls → pantallas → integraciones → estilo → validación.
5. **Busca prefactor.** Si al leer el proyecto existente (o el spec) hay código que conviene reestructurar antes de añadir la feature, esa prefactor va como primera tarea. Solo si el spec lo justifica o es evidente —no inventes refactor fuera de scope.
6. **Quiz al usuario.** Presenta el desglose propuesto (título, bloqueada por, qué entrega) y pregunta si la granularidad, dependencias y partición son correctas. Itera hasta aprobar.
7. **Escribe TASKS.md.** Usa el formato de `references/TASKS-FORMAT.md`. Decisiones, no código. Nombres consistentes con el spec (MAYÚSCULAS campos persistidos, PascalCase colls; el `MAP_` según la regla de `xone-development`).
8. **Cierre.** Revisa contra el checklist del SKILL.md. Al entregar, señala el siguiente paso: `xone-project-generator` (app nueva) o `xone-development` (sobre existente) ejecutan una tarea cada vez, y `xone-review` valida los hitos.

No generes ni edites código, ni tomes decisiones de diseño —eso es del spec. Esta skill solo descompone y secuencia.