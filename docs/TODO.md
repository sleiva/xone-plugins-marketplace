# Tareas pendientes

Lista operativa de trabajo pendiente sobre `xone-plugins-market`. Detalle técnico y contexto en [`ARCHITECTURE.md`](ARCHITECTURE.md) §13. Diagnóstico del diseño previo a la v0.10.0 en [`ANALISIS.md`](ANALISIS.md).

## Estado

- [x] **1. Frontmatter `name` en todos los `SKILL.md`**
- [x] **2. Capa de referencias sobre el corpus original** (v0.10.0 — el «refactor» de la v0.9.0 había producido resúmenes, no partición)
- [x] **3. Configurar `opencode.json` con `skills.paths`**
- [x] **4. Versionar la fuente canónica `xone/` en git**
- [x] **5. Validador que compruebe enlaces y huérfanos**
- [ ] **6. Pruebas de activación real** ← siguiente, y bloquea la 7
- [ ] **7. Consolidación de fronteras entre skills**
- [ ] **8. Versiones de XOne soportadas**
- [ ] **9. Revisores expertos por área**
- [ ] **10. Consolidación editorial de las dos redacciones del corpus** (prioridad baja)

---

## 6. Pruebas de activación real

**Prioridad:** alta · **Esfuerzo:** medio · **Ref:** ARCHITECTURE.md §13.3

Es la única tarea que sigue pendiente desde el plan original, y de ella dependen las decisiones de taxonomía. El validador estático comprueba estructura y enlaces, pero no si el agente elige la skill correcta.

- [ ] Proyecto XOne mínimo de prueba con XML, JS y CSS.
- [ ] Tarea XML → debe invocar `xone-xml-ui`.
- [ ] Tarea JavaScript → debe invocar `xone-javascript`.
- [ ] Tarea de validación → debe invocar `xone-review`.
- [ ] Tarea que cruza áreas (añadir un filtro a una pantalla de listado toca `.xne`, evento JS y clase CSS): medir si el agente abre varias skills o improvisa el resto.
- [ ] Comprobar que, invocada una skill, el agente **lee la referencia** del índice en vez de responder solo con las reglas del `SKILL.md`.
- [ ] Script de smoke que ejecute prompts reales y reporte qué skill se activó y qué ficheros leyó.

La última comprobación es la que valida el rediseño de la v0.10.0: si el agente no abre las referencias, el problema no era la falta de detalle sino el índice.

---

## 7. Consolidación de fronteras entre skills

**Prioridad:** media · **Esfuerzo:** bajo · **Ref:** ARCHITECTURE.md §13.4 · **Depende de:** tarea 6

`xone-verification` ya se fusionó en `xone-review` (hecho en la v0.10.0: era contenido duplicado, no una duda empírica). Queda decidir entre nueve puertas (actual), siete (`data-integration` y `device` como referencias de `xone-javascript`) o cuatro (una sola de conocimiento más las tres de procedimiento). Criterio propuesto: el conocimiento va a referencias bajo una puerta; el procedimiento merece puerta propia.

Decidir con los datos de la tarea 6. Reubicar chunks es barato; el corpus no cambia.

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

1. **`progid` obligatorio u opcional.** El validador `xone-simulator` emite `COLL_MISSING_PROGID` como **error** cuando una coll tiene `objname` sin `progid`, mientras la documentación lo declara **opcional** (sin él la coll equivale a `ASData.CASBasicDataObj`; solo Empresas y Usuarios requieren el suyo). Hoy las skills declaran el conflicto en vez de resolverlo. Hay que decidir si el linter es demasiado estricto o si la documentación está desactualizada.
2. El corpus se contradice en los nombres de las variantes CSS (`default_night.css` con guion bajo en §1.2, `default.night.css` con punto en §9.1/§9.2). Las skills declaran la discrepancia; hace falta que un experto zanje cuál es la correcta.

---

## 10. Consolidación editorial de las dos redacciones

**Prioridad:** baja · **Esfuerzo:** alto · **Ref:** ARCHITECTURE.md §13.5

`xone/` tiene dos redacciones del mismo conocimiento con cortes distintos y material único en cada una. Unificarlas permitiría retirar las referencias marcadas como «referencia ampliada» en `xone-data-integration` y `xone-device`. No bloquea nada.

---

## Orden sugerido

1. **Tarea 6** (activación real) — desbloquea la 7 y valida el rediseño.
2. **Tarea 7** (fronteras) — con los datos de la 6.
3. **Tarea 8** (versiones) — estabiliza el tono de las reglas.
4. **Tarea 9** (revisores) — en paralelo.
