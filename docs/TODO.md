# Tareas pendientes

Lista operativa de trabajo pendiente sobre `xone-plugins-market`. Detalle técnico y contexto en [`ARCHITECTURE.md`](ARCHITECTURE.md) §13. Diagnóstico del diseño previo a la v0.10.0 en [`ANALISIS.md`](ANALISIS.md).

## Estado

- [x] **1. Frontmatter `name` en todos los `SKILL.md`**
- [x] **2. Capa de referencias sobre el corpus original** (v0.10.0 — el «refactor» de la v0.9.0 había producido resúmenes, no partición)
- [x] **3. Configurar `opencode.json` con `skills.paths`**
- [x] **4. Versionar la fuente canónica `xone/` en git**
- [x] **5. Validador que compruebe enlaces y huérfanos**
- [ ] **6. Pruebas de activación real** ← siguiente (simplificada por la tarea 7, v0.11.0)
- [x] **7. Consolidación de fronteras entre skills** (v0.11.0 — cuatro puertas)
- [ ] **8. Versiones de XOne soportadas**
- [ ] **9. Revisores expertos por área**
- [ ] **10. Consolidación editorial de las dos redacciones del corpus** (prioridad baja)

---

## 6. Pruebas de activación real

**Prioridad:** alta · **Esfuerzo:** medio (bajó con la tarea 7) · **Ref:** ARCHITECTURE.md §13.3

Es la única tarea que sigue pendiente desde el plan original. El validador estático comprueba estructura y enlaces, pero no si el agente elige la skill correcta ni si lee sus referencias.

**Simplificada por la consolidación a cuatro puertas (tarea 7, v0.11.0).** Con seis skills de conocimiento solapadas la pregunta era «¿elige el agente la puerta correcta entre seis?». Con una sola puerta de conocimiento (`xone-development`) esa elección casi desaparece; la pregunta que queda, y la que de verdad importa, es **si el agente abre las referencias del índice o contesta solo con las reglas de cabecera del `SKILL.md`**.

- [ ] Proyecto XOne mínimo de prueba con XML, JS y CSS.
- [ ] Tarea XML, JavaScript o CSS → debe invocar `xone-development` y abrir la referencia que indica su índice para esa área, no responder solo con las reglas de cabecera.
- [ ] Tarea de validación → debe invocar `xone-review`.
- [ ] Tarea que cruza áreas (añadir un filtro a una pantalla de listado toca `.xne`, evento JS y clase CSS): ya no hay que medir cuántas skills de conocimiento abre (solo hay una); medir si dentro de esa puerta lee las referencias de las áreas relevantes o improvisa alguna.
- [ ] Comprobar que, invocada la skill, el agente **lee la referencia** del índice en vez de responder solo con las reglas del `SKILL.md`.
- [ ] Script de smoke que ejecute prompts reales y reporte qué skill se activó y qué ficheros leyó.

La última comprobación es la que valida el rediseño de la v0.10.0: si el agente no abre las referencias, el problema no era la falta de detalle sino el índice.

---

## 7. Consolidación de fronteras entre skills

**Estado:** hecha en v0.11.0 · **Ref:** ARCHITECTURE.md §13.4

`xone-verification` ya se había fusionado en `xone-review` (v0.10.0: era contenido duplicado, no una duda empírica). Para las seis skills de conocimiento se decidió sin esperar a la tarea 6 (las pruebas de activación seguían pendientes): el peor caso — el agente abre una sola puerta y escribe el resto de memoria — solo se evita con una puerta única, y la asimetría de coste (cargar contexto de más vs. inventar) hacía que esperar no compensara.

**Opción elegida: cuatro puertas.** `xone-xml-ui`, `xone-javascript`, `xone-css`, `xone-data-integration` y `xone-device` se fusionan en `xone-development`, cuyas 54 referencias pasan a subcarpetas por área (`xml-ui/`, `javascript/`, `css/`, `datos/`, `device/`, más `fundamentos/`). Se mantienen las tres de procedimiento: `xone-project-generator`, `xone-review` y `xone-debugging`. El invariante «una regla, un sitio» y el guardián de `scripts/validate-skills.sh` que lo hace cumplir sustituyen a la antigua nota de «reglas duplicadas a propósito» (ver ARCHITECTURE.md §10.1).

---

## 8. Versiones de XOne soportadas

**Prioridad:** media · **Esfuerzo:** bajo (decisión) · **Ref:** ARCHITECTURE.md §12

Confirmar qué versiones de XOne se soportan y documentarlo en `ARCHITECTURE.md` y `README.md`. Condiciona el tono de las reglas: hoy las skills no distinguen entre API estable y API dependiente de versión.

---

## 9. Revisores expertos por área

**Prioridad:** media · **Esfuerzo:** bajo (coordinación) · **Ref:** ARCHITECTURE.md §7.2

- [ ] Experto de XML/UI
- [ ] Experto de JavaScript y runtime
- [ ] Experto de CSS y diseño responsive
- [ ] Experto de integraciones, seguridad y sincronización
- [ ] Desarrollador que valide la experiencia real en Claude Code y OpenCode

Dos discrepancias concretas que necesitan que un experto zanje:

1. **`progid`: decidido, pendiente de implementar en el linter.** El validador `xone-simulator` emite `COLL_MISSING_PROGID` como **error** cuando una coll tiene `objname` sin `progid`, mientras la documentación lo declara **opcional** (sin él la coll equivale a `ASData.CASBasicDataObj`; solo Empresas y Usuarios requieren el suyo). Nótese que el corpus nunca menciona `objname`: el linter añade una condición que la documentación no recoge.

   **Resolución (2026-08-03):** el linter es demasiado estricto y se corregirá en la próxima versión de `xone-linter`. La documentación se queda como está.

   Hasta que esa versión salga, el conflicto sigue siendo real para quien use el linter actual, así que las skills mantienen su aviso: declararlo y no resolverlo por cuenta propia. Cuando el linter se publique corregido, retirar esa frase de la regla de `progid` en `xone-development/SKILL.md` (línea 12).
2. El corpus se contradice en los nombres de las variantes CSS (`default_night.css` con guion bajo en §1.2, `default.night.css` con punto en §9.1/§9.2). Las skills declaran la discrepancia; hace falta que un experto zanje cuál es la correcta.

---

## 10. Consolidación editorial de las dos redacciones

**Prioridad:** baja · **Esfuerzo:** alto · **Ref:** ARCHITECTURE.md §13.5

`xone/` tiene dos redacciones del mismo conocimiento con cortes distintos y material único en cada una. Unificarlas permitiría retirar las referencias marcadas como «referencia ampliada» en `xone-development/references/datos/` y `xone-development/references/device/`. No bloquea nada.

---

## Orden sugerido

1. **Tarea 6** (activación real) — valida el rediseño; su alcance bajó al cerrarse la 7.
2. **Tarea 8** (versiones) — estabiliza el tono de las reglas.
3. **Tarea 9** (revisores) — en paralelo.
