---
description: Entrevista para especificar cualquier desarrollo XOne (app nueva, feature, refactor, integración, cambio de modelo, rediseño) y dejar un PLAN.md (el spec)
argument-hint: [ruta del proyecto o directorio destino]
allowed-tools: Read, Edit, Write, Glob, Grep
---

Especifica un desarrollo XOne por entrevista y deja un `PLAN.md` que `xone-plan-builder` descompone en tareas, y que `xone-project-generator` (app nueva) o `xone-development` (sobre existente) ejecutan.

Procedimiento:

1. **Carga la skill `xone-spec-builder`** por su nombre y síguela estrictamente. Carga también `xone-development` para consultar reglas y referencias.
2. **Directorio de trabajo.** Usa `$1` si se indicó; si no, usa el directorio actual. Los artefactos (`PLAN.md`, `CONTEXT.md`, `docs/adr/`) se escriben ahí.
3. **Triage de complejidad.** Antes de nada, clasifica la petición: **Trivial** (una acción mecánica, sin decisiones) → no produces `PLAN.md`; confirma en 1-2 preguntas, ejecuta con `xone-development`/`xone-project-generator` directamente y valida con `xone-review`. **Simple** (cambio acotado con decisión menor) → spec ligero, solo los rounds que apliquen, `PLAN.md` condensado. **Normal** (feature con varias colls/pantallas, refactor, integración multi-pantalla) → spec completo. **Grande** (app nueva, re-arquitectura) → spec completo + considerar dividir. Si dudas, empieza por el inferior; puedes subir si la entrevista saca más complejidad. El usuario puede subir o bajar el nivel.
4. **Clasifica el desarrollo** con el usuario antes de la primera ronda: ¿app nueva, feature, refactor, integración de dispositivo, cambio de modelo de datos, rediseño de pantalla? El tipo fija qué rounds aplican. Si es trabajo sobre existente, **lee los `.xne`, `.js` y `.css` del proyecto** antes de seguir — el spec debe respetar convenciones que ya viven ahí.
5. **Entrevista relentless, una ronda cada vez, una pregunta cada vez.** Tú preguntas; el usuario responde. Nunca respondas a tus propias preguntas ni rellenes huecos por intuición. Sigue los rounds del SKILL.md que apliquen al tipo de desarrollo, saltando los que no apliquen y diciéndolo explícito.
6. **Cristaliza a medida.** Actualiza `PLAN.md`, `CONTEXT.md` y los ADRs según se resuelven los términos y decisiones —sin batchear. Usa los formatos de `references/PLAN-FORMAT.md`, `references/CONTEXT-FORMAT.md` y `references/ADR-FORMAT.md`.
7. **Cruza siempre con `xone-development`** antes de afirmar nada sobre XOne: tipos de prop válidos, reglas de unicidad, `progid` opcional, eventos de ciclo de vida, anti-patrones de XML/JS/CSS, objetos canónicos de dispositivo. Si no aparece en las referencias, dilo y pregunta; no inventes.
8. **No generes ni edites código, ni descompongas en tareas.** El spec son decisiones de diseño, no XML/JS/CSS ni tareas. Eso lo hacen `xone-project-generator`/`xone-development` y `xone-plan-builder` respectivamente.
9. **Cierre.** Revisa el `PLAN.md` contra el checklist de `PLAN-FORMAT.md`. Lo que no se resolvió va en §Pendientes, no se rellena por intuición. Al terminar, señala el siguiente paso: `xone-plan-builder` para descomponer en tareas (opcional para Trivial/Simple), después `xone-project-generator` (app nueva) o `xone-development` (sobre existente), y `xone-review` para validar al final.

Si el usuario ya trae una descripción del desarrollo en el mensaje inicial, úsala como arranque del Round 1, pero no la des por buena sin entrevistarla.