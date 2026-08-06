# SKILLS_NEEDED.md — las dos skills que faltan, y las que NO hay que construir

> **De dónde sale esto.** Las mediciones son del agente **XOne v2**
> (`nappai-ai-backend`, `nappai/base/langchain_v1/xone_v2/`), tomadas con sus propios
> comandos (`cli doc --corpus`, `cli verify`, `cli planificar`) el 2026-08-06. Las
> referencias a `CLAUDE.md`, `ESTADO.md` y a los «patrones» numerados apuntan a la doctrina
> de ese paquete, que es donde vive el detalle. El documento vive aquí porque las skills son
> de este repositorio; el consumidor está allí.

Escrito el 2026-08-06, después de una jornada de pruebas en vivo. **Todo lo que se afirma aquí
está medido con los comandos del paquete**, no razonado desde el catálogo — y el orden de las
dos propuestas es el de la evidencia que las respalda, no el de lo interesantes que parecen.

---

## 1. Lo que hay hoy, medido

`cli doc --corpus` y un recuento del árbol:

| Skill | `.md` | Raíz | La consumen |
|---|---:|---|---|
| `xone-development` | 55 | `skills/documentacion/` | doc · ejecutor · planner |
| `xone-project-generator` | 15 | `skills/documentacion/` | doc · ejecutor · planner |
| `xone-debugging` | 3 | `skills/documentacion/` | doc · ejecutor · planner |
| `xone-review` | 1 | `skills/verificacion/` | **solo el juez** |

Y `xone-development` por materia: `xml-ui` 18 · `javascript` 16 · `css` 6 · `fundamentos` 5 ·
`datos` 5 · `device` 4.

**El corpus está organizado por ARTEFACTO.** Ésa es la observación de la que salen las dos
grietas: una porque hay una dimensión que ningún artefacto cubre, y otra porque el eje del
índice dejó de casar con la forma de las preguntas.

---

## 2. `xone-repair` — la que tiene el número más duro detrás

```yaml
name: xone-repair
description: >
  Corregir hallazgos del verificador de XOne, por su código de regla. Usar cuando el brief
  trae hallazgos con rule_id — COLL_MISSING_PROGID, INVALID_PROP_TYPE, REF_FUNC_MISSING,
  MISSING_INCLUDED_FILE, REF_MAPCOL_MISSING, REF_NODE_MISSING, REF_CONTENTS_SRC_MISSING,
  REF_JS_COLL_MISSING, JS_ASYNC_AWAIT, stub-method, render-throw —: qué significa cada uno,
  por qué salta, cuál es la corrección mínima y qué NO hay que tocar.
```

**Raíz:** `skills/documentacion/` — la del ejecutor, que es quien repara.

### Por qué

De seis `rule_id` que el verificador emite **de verdad** (comprobado con `grep` sobre los 73
ficheros del corpus):

| `rule_id` | ficheros que lo mencionan |
|---|---:|
| `COLL_MISSING_PROGID` | 1 |
| `INVALID_PROP_TYPE` | **0** |
| `REF_FUNC_MISSING` | **0** |
| `MISSING_INCLUDED_FILE` | **0** |
| `REF_MAPCOL_MISSING` | **0** |
| `stub-method` | **0** |

**Cinco de seis, cero cobertura.** Y no es material de adorno: la reparación es un camino de
primera clase del grafo, con presupuesto propio (`MAX_REPAIR = 3`) y su propia arista. El
brief que recibe el ejecutor lleva la regla, el fichero y la línea
(`harness/state.py::format_findings`) — o sea que **le damos un código y ninguna forma de
buscarlo**. Hoy tiene que inferir la corrección de documentación genérica.

Los códigos observados en vivo el 2026-08-06 (`cli doctor` sobre `FontIconsApp`, `cli verify`
sobre `AppDemo`, y el smoke sobre `AITest` tras un cambio real): `JS_ASYNC_AWAIT`,
`REF_FUNC_MISSING`, `REF_MAPCOL_MISSING`, `REF_NODE_MISSING`, `COLL_MISSING_PROGID`,
`INVALID_PROP_TYPE`, `MISSING_INCLUDED_FILE`, `REF_CONTENTS_SRC_MISSING`,
`REF_JS_COLL_MISSING`, `stub-method`. `CLAUDE.md` dice que el simulador tiene **28** códigos
de validación, así que ésos diez son el suelo, no el techo.

### Forma

Una entrada por regla, **buscable por el código literal** (el `grep` del especialista lo
encontrará tal cual llega en el brief). Cada una con: qué significa · por qué salta · la
corrección mínima · qué NO tocar · un ejemplo antes/después.

Y **un caso que hay que documentar aunque incomode**: `REF_FUNC_MISSING` es un AVISO y no
bloquea, mientras `stub-method` sí, con la misma severidad. La asimetría es deliberada
(`CLAUDE.md` patrón 27, `HARD_STATIC_RULE_IDS` vacía a propósito) y el ejecutor tiene que saber
cuál le va a costar una reparación y cuál no.

### Fronteras, que van declaradas en su `SKILL.md`

El patrón 23 ya midió lo que cuesta que dos skills solapen materia casi 1:1 — sin remitirse
entre ellas, un `grep` a cero en una se lee como «no está documentado».

- **≠ `xone-debugging`**: aquélla es para síntomas en EJECUCIÓN (pantalla vacía, botón que no
  responde, evento que no dispara). Ésta, para hallazgos del VERIFICADOR, con `rule_id`.
- **≠ `xone-review`**: `xone-review` es del JUEZ y va de *correr* el linter y juzgar.
  `xone-repair` es del EJECUTOR y va de *arreglar* lo que el linter encontró.

---

## 3. `xone-recipes` — la grieta que abrimos nosotros hoy

```yaml
name: xone-recipes
description: >
  Cómo se consigue un EFECTO en XOne componiendo piezas documentadas, cuando no hay una API
  directa. Usar al responder «¿cómo hago X?» y no existir un método con ese nombre: efectos
  visuales (difuminar, atenuar, superponer), capas y flotantes, deshabilitar o resaltar
  controles, feedback de carga. Cada receta dice qué se pide, qué no existe, con qué piezas
  se logra y su ejemplo.
```

**Raíz:** `skills/documentacion/`.

### Por qué

**Las piezas están; la composición no.** `floating` aparece en 21 ficheros, `before-edit` en
25, `zorder` en 2. Lo que no existe en ningún sitio es qué piezas producen qué efecto.

Y esto **es una grieta nueva del 2026-08-06, y la causamos nosotros**. Ese día se arregló el
defecto más caro medido del paquete: `DOC_TOOL_DESCRIPTION` decía «pregunta por el
identificador LITERAL», y el ejecutor hizo exactamente eso 76 veces en un turno
(`ui.showBlur`, `ui.setBlur`, `blur`, `BLUR`, `difum`…) sin preguntar ni una vez «¿cómo
difumino una vista?». Una búsqueda por NOMBRE solo puede contestar sí o no: nunca puede
devolver una alternativa. Se arregló enseñándoles **dos clases de pregunta** —POR NOMBRE y POR
OBJETIVO— y funcionó: el planner pasó a preguntar «¿cómo superpongo una imagen?» y el ejecutor
descubrió `type="IMG"` por objetivo antes de confirmarlo por nombre.

**Pero el corpus sigue indexado por artefacto.** La forma de la pregunta cambió y la del índice
no, así que el planner ya pregunta lo correcto y no llega a `floating`/`zorder`. No es un
problema de búsqueda: es que el conocimiento no está escrito como técnica.

### Su primera entrada, y por qué solo la puede escribir el usuario

**Simular un desenfoque**: XOne no tiene ninguna API de blur —comprobado con tres consultas
(`setBlur`, «cómo difumino una vista», «cómo aplico blur»), las tres «no está documentado»— y
el efecto se logra generando una imagen difuminada y superponiéndola con una prop `IMG`
flotante. Eso lo sabe el usuario; el corpus documenta las dos piezas por separado y nadie las
junta.

Mientras no esté escrito, **ningún prompt lo va a sacar**: pedírselo al modelo es pedirle que
lo invente, que es lo que el harness entero existe para impedir.

### Lo que ya está listo esperándola

`PlannerResult.alternative` (el quinto desenlace del planner) y la **regla 6** del guard, con
sus tests. En cuanto haya recetas, el planner puede responder «lo pedido no existe, pero la
intención se logra así» en vez de «no se puede» — y el camino se activa solo, sin tocar código.

---

## 4. Lo que NO hay que construir, y por qué

Se escribe aquí para que no se reproponga dentro de tres meses.

### Montarle `documentacion/` al juez

Tentador y **medido**: no montarla cuesta **2 de 12** veredictos (rechaza trabajo bueno por
convenciones de nombres que no puede consultar, `CLAUDE.md` patrón 34).

Pero esas convenciones **ya existen** —en `xone-project-generator`—, así que no falta una
skill: falta una decisión de MONTAJE. Y montar 73 ficheros en un nodo que corre por tarea
invita al lazo de 7-13 llamadas del especialista de doc dentro del `checker`. Si algún día
hace falta, lo barato es una skill de convenciones de tres páginas en `verificacion/`, no el
corpus entero. Hoy está tapado con una regla epistémica en `prompts/checker.md`, que es lo
correcto para no duplicar el corpus.

### Skills de proceso (brainstorming / write-plan / execute-plan)

Analizado y descartado el 2026-08-06
(`docs/proposals/2026-08-06-xone-v2-skills-de-proceso.md`): **dos de las tres no se
construyen** porque ya existen en forma FUERTE —el nodo `planner` con salida tipada, y la
topología sin arista `executor`→`END`—, y un `.md` no puede igualar una garantía estructural.

### Una capa de navegación / índice del corpus

Ya existió y **se retiró**, con su motivo (`CLAUDE.md` patrón 23): una capa de navegación se
justifica por documentación que NO tiene puerta de entrada, no por el tamaño del corpus. Al
desaparecer el árbol sin `SKILL.md`, desapareció el motivo.

---

## 5. Cómo se sabrá si sirvieron

No por que existan. Con los instrumentos que ya hay:

| Skill | Cómo medirla | Contra qué |
|---|---|---|
| `xone-repair` | un turno que provoque un hallazgo real y entre a reparación (`test_verify_lazo_real.py`) | intentos de reparación gastados, y si el ejecutor cita la regla o la adivina |
| `xone-recipes` | `cli planificar --project AppDemo "que la vista de EntradaApp se difumine al entrar en modo edición"` | hoy: `NO SE PUEDE HACER`, código 4, ~13 s. Con la receta debería salir un plan con `alternativa` |

Y el **control** que no puede faltar, porque este paquete ya pagó por olvidarlo: comprobar que
una tarea que **sí** tiene API directa sigue resolviéndose igual de rápido. Una skill nueva que
mejore el caso raro y empeore el normal es una pérdida, y sin control no se ve.
