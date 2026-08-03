# Consolidación de skills: de nueve a cuatro — Plan de implementación

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers-extended-cc:subagent-driven-development (recommended) or superpowers-extended-cc:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Consolidar las nueve skills del plugin `xone-development` en cuatro —una puerta de conocimiento y tres de procedimiento— sin perder ninguna regla ni ninguna referencia.

**Architecture:** Las 54 referencias de las seis skills de conocimiento se mueven a subcarpetas por área dentro de `xone-development/references/`, y sus seis `SKILL.md` (603 líneas) se fusionan en uno solo por debajo de 400. Las skills de procedimiento (`xone-project-generator`, `xone-review`, `xone-debugging`) dejan de repetir reglas y pasan a apuntar a la puerta de conocimiento. El validador se amplía primero para que detecte los fallos que la migración puede introducir.

**Tech Stack:** Markdown, bash (`scripts/validate-skills.sh`), git, Python 3 para scripts de un solo uso. CLIs disponibles y verificados en el entorno: `xone-simulator`, `opencode`, `codex`.

**Global Constraints:**
- El `SKILL.md` de `xone-development` debe quedar **por debajo de 400 líneas**. Es un check que falla, no una recomendación.
- **Una regla se escribe una vez**, en la puerta de conocimiento. Las skills de procedimiento la referencian, no la repiten.
- Ninguna regla de los seis `SKILL.md` originales puede desaparecer sin decisión explícita registrada.
- No se copian ni se duplican ficheros de referencia: se mueven con `git mv`.
- Nada imprescindible puede vivir en la capa específica de un host (`commands/`, hooks, definiciones de agente).
- El contenido procede del corpus versionado en `xone/`. No se inventa ni se deduce ninguna regla nueva durante la migración.

**User decisions (already made):**
- Opción A, cuatro puertas: una de conocimiento (`xone-development`) más `xone-project-generator`, `xone-review` y `xone-debugging`.
- Se mantiene el nombre `xone-development`; no se renombra a `xone-core`.
- Compatibilidad con Claude Code, OpenCode y posiblemente Codex.
- El consumidor es un agente experto, con activación automática de skills y sin medición previa.
- `xone-review` pierde sus anti-patrones y sus reglas por capa, y apunta a la puerta de conocimiento.
- Techo de 400 líneas como check que falla.
- Para Codex, `AGENTS.md` como vía principal y symlink como plan B, con comprobación empírica obligatoria antes de documentarlo como cierto.

---

### Task 1: Hacer recursivo el validador

**Goal:** Que `scripts/validate-skills.sh` encuentre referencias en subcarpetas, para que la migración no pueda dejar enlaces rotos ni huérfanas sin que el script lo vea.

**Files:**
- Modify: `scripts/validate-skills.sh` (bloque «Toda referencia del paquete debe estar enlazada desde su SKILL.md»)

**Acceptance Criteria:**
- [ ] El script recorre `references/**/*.md`, no solo el nivel plano.
- [ ] Sobre el layout actual de 9 skills el script sigue dando exit 0.
- [ ] Una referencia colocada en una subcarpeta y no enlazada se reporta como huérfana.

**Verify:** `scripts/validate-skills.sh` → `Validated 9 skills: frontmatter, size, reference links and OpenCode discovery.` con exit 0

**Steps:**

- [ ] **Step 1: Comprobar el estado de partida**

```bash
cd /Users/projects/xone-plugins-market
scripts/validate-skills.sh; echo "exit=$?"
```

Esperado: `Validated 9 skills…` y `exit=0`.

- [ ] **Step 2: Sustituir el bucle de huérfanas por uno recursivo**

En `scripts/validate-skills.sh`, reemplazar este bloque:

```bash
  # Toda referencia del paquete debe estar enlazada desde su SKILL.md.
  if [[ -d "$dir/references" ]]; then
    for ref in "$dir/references"/*.md; do
      [[ -e "$ref" ]] || continue
      base="$(basename "$ref")"
      if ! grep -q "references/$base" "$file"; then
        printf 'Orphaned reference (not linked from SKILL.md): %s\n' "$ref" >&2
        failures=$((failures + 1))
      fi
    done
  fi
```

por este:

```bash
  # Toda referencia del paquete debe estar enlazada desde su SKILL.md,
  # incluidas las que viven en subcarpetas por área.
  if [[ -d "$dir/references" ]]; then
    while IFS= read -r ref; do
      [[ -n "$ref" ]] || continue
      rel="${ref#$dir/}"
      if ! grep -q "$rel" "$file"; then
        printf 'Orphaned reference (not linked from SKILL.md): %s\n' "$ref" >&2
        failures=$((failures + 1))
      fi
    done < <(find "$dir/references" -type f -name '*.md' | sort)
  fi
```

La comprobación de enlaces rotos no necesita cambios: su patrón `(references/[^)#]*\.md` ya acepta rutas con subcarpetas.

- [ ] **Step 3: Verificar que sigue en verde sobre el layout actual**

```bash
scripts/validate-skills.sh; echo "exit=$?"
```

Esperado: `Validated 9 skills…` y `exit=0`.

- [ ] **Step 4: Comprobar que detecta una huérfana en subcarpeta**

```bash
mkdir -p plugins/xone-development/skills/xone-css/references/tmp
echo '# prueba' > plugins/xone-development/skills/xone-css/references/tmp/huerfana.md
scripts/validate-skills.sh; echo "exit=$?"
```

Esperado: `Orphaned reference (not linked from SKILL.md): …/tmp/huerfana.md` y `exit=1`.

- [ ] **Step 5: Limpiar la prueba y confirmar verde**

```bash
rm -rf plugins/xone-development/skills/xone-css/references/tmp
scripts/validate-skills.sh; echo "exit=$?"
```

Esperado: `exit=0`.

- [ ] **Step 6: Commit**

```bash
git add scripts/validate-skills.sh
git commit -m "Make reference checks recursive in validate-skills.sh"
```

---

### Task 2: Inventario de reglas como red de seguridad

**Goal:** Extraer a un fichero toda línea de regla de los seis `SKILL.md` de conocimiento, para poder comprobar después de la fusión que ninguna se ha perdido.

**Files:**
- Create: `<scratchpad>/extraer-reglas.py` (no se versiona)
- Create: `<scratchpad>/inventario-reglas.txt` (no se versiona)

**Acceptance Criteria:**
- [ ] El inventario contiene una entrada por cada viñeta, fila de tabla y punto numerado de los seis ficheros.
- [ ] Cada entrada lleva su fichero de origen, para poder rastrearla.
- [ ] El script imprime el total de entradas extraídas.

**Verify:** `python3 <scratchpad>/extraer-reglas.py` → imprime `N entradas extraídas de 6 ficheros` con N > 300

**Steps:**

- [ ] **Step 1: Escribir el extractor**

Guardar como `<scratchpad>/extraer-reglas.py` (sustituir `<scratchpad>` por el directorio de scratchpad de la sesión):

```python
#!/usr/bin/env python3
"""Extrae las lineas de regla de los SKILL.md de conocimiento.

De un solo uso: sirve de red de seguridad para la fusion. No se versiona.
"""
import re
from pathlib import Path

ROOT = Path("/Users/projects/xone-plugins-market")
SKILLS = ROOT / "plugins/xone-development/skills"
FUENTES = [
    "xone-development", "xone-xml-ui", "xone-javascript",
    "xone-css", "xone-data-integration", "xone-device",
]
SALIDA = Path(__file__).with_name("inventario-reglas.txt")


def normaliza(texto):
    texto = re.sub(r"\s+", " ", texto).strip()
    return texto


def extrae(path):
    lineas = path.read_text(encoding="utf-8").split("\n")
    fence = False
    fuera = []
    for linea in lineas:
        if linea.startswith("```"):
            fence = not fence
            continue
        if fence:
            continue
        s = linea.strip()
        if not s:
            continue
        es_vineta = s.startswith("- ") or s.startswith("* ")
        es_numerada = bool(re.match(r"^\d+\.\s", s))
        es_tabla = s.startswith("|") and not re.match(r"^\|[\s\-|:]+\|?$", s)
        if es_vineta or es_numerada or es_tabla:
            fuera.append(normaliza(s))
    return fuera


total = 0
with SALIDA.open("w", encoding="utf-8") as f:
    for nombre in FUENTES:
        path = SKILLS / nombre / "SKILL.md"
        for entrada in extrae(path):
            f.write(f"{nombre}\t{entrada}\n")
            total += 1

print(f"{total} entradas extraidas de {len(FUENTES)} ficheros -> {SALIDA}")
```

- [ ] **Step 2: Ejecutarlo**

```bash
python3 <scratchpad>/extraer-reglas.py
wc -l <scratchpad>/inventario-reglas.txt
```

Esperado: un total superior a 300 entradas (los seis ficheros suman 603 líneas, de las que buena parte son viñetas y tablas).

- [ ] **Step 3: Revisar una muestra para confirmar que extrae lo que debe**

```bash
head -5 <scratchpad>/inventario-reglas.txt
grep -c 'xone-xml-ui' <scratchpad>/inventario-reglas.txt
```

Esperado: entradas con formato `skill<TAB>texto`, y un recuento no nulo para cada skill.

- [ ] **Step 4: Sin commit**

El script y el inventario viven en el scratchpad y no se versionan, igual que el troceador de la v0.10.0.

---

### Task 3: Consolidar las seis puertas de conocimiento en una

**Goal:** Mover las 54 referencias a subcarpetas por área dentro de `xone-development`, fusionar los seis `SKILL.md` en uno por debajo de 400 líneas, y borrar los cinco directorios absorbidos.

**Files:**
- Modify: `plugins/xone-development/skills/xone-development/SKILL.md`
- Move: 49 ficheros desde `xone-xml-ui|xone-javascript|xone-css|xone-data-integration|xone-device/references/` a `xone-development/references/<área>/`
- Move: 5 ficheros desde `xone-development/references/` a `xone-development/references/fundamentos/`
- Delete: `plugins/xone-development/skills/{xone-xml-ui,xone-javascript,xone-css,xone-data-integration,xone-device}/`

**Acceptance Criteria:**
- [ ] `find plugins/xone-development/skills/xone-development/references -name '*.md' | wc -l` devuelve 54.
- [ ] Las seis subcarpetas contienen 5, 18, 16, 6, 5 y 4 ficheros respectivamente.
- [ ] Quedan cuatro directorios de skill.
- [ ] El `SKILL.md` fusionado tiene menos de 400 líneas.
- [ ] El validador da exit 0: ningún enlace roto, ninguna referencia huérfana.

**Verify:** `scripts/validate-skills.sh` → `Validated 4 skills…` con exit 0

**Steps:**

- [ ] **Step 1: Crear las subcarpetas y mover las referencias**

```bash
cd /Users/projects/xone-plugins-market/plugins/xone-development/skills
D=xone-development/references
mkdir -p $D/fundamentos $D/xml-ui $D/javascript $D/css $D/datos $D/device

# fundamentos: las 5 que ya estaban en la puerta de conocimiento
for f in conceptos-clave configuracion-app-xml-ini-mappings errores-comunes \
         navegacion-convenciones-y-primer-proyecto plataforma-y-anatomia-de-proyecto; do
  git mv $D/$f.md $D/fundamentos/$f.md
done

git mv xone-xml-ui/references/*.md            $D/xml-ui/
git mv xone-javascript/references/*.md        $D/javascript/
git mv xone-css/references/*.md               $D/css/
git mv xone-data-integration/references/*.md  $D/datos/
git mv xone-device/references/*.md            $D/device/
```

- [ ] **Step 2: Comprobar el recuento antes de seguir**

```bash
cd /Users/projects/xone-plugins-market
for a in fundamentos xml-ui javascript css datos device; do
  printf '%-12s %s\n' "$a" "$(ls plugins/xone-development/skills/xone-development/references/$a | wc -l | tr -d ' ')"
done
find plugins/xone-development/skills/xone-development/references -name '*.md' | wc -l
```

Esperado: `fundamentos 5`, `xml-ui 18`, `javascript 16`, `css 6`, `datos 5`, `device 4`, total `54`.

- [ ] **Step 3: Escribir el `SKILL.md` fusionado**

Reescribir `plugins/xone-development/skills/xone-development/SKILL.md` completo, en este orden y con este origen. **Todo el texto sale de los seis ficheros actuales; no se redacta ninguna regla nueva.**

| Sección | Origen | Tratamiento |
|---|---|---|
| Frontmatter | nuevo | `name: xone-development`. `description` que cubra las seis áreas: XML `.xne`, JavaScript del runtime, CSS, datos e integración, dispositivo y fundamentos de proyecto |
| Preámbulo | `xone-development` líneas 6-8 | Se conserva íntegro: no afirmar nada que no esté en las referencias |
| Siempre / Nunca | `xone-development` §Siempre y §Nunca | Se conservan íntegras |
| Sintaxis JavaScript | `xone-development` §Sintaxis JavaScript | Se conserva íntegra: sí / no / implementación custom |
| Unicidad y nombres | `xone-development` §Unicidad | Se conserva |
| Tipos de prop | `xone-development` §Tipos de prop | Se conserva la tabla. **Se borra** la lista equivalente de `xone-xml-ui` §Tipos de prop |
| Visibilidad | `xone-development` §Visibilidad | Se conserva la tabla de 4 bits. **Se borra** el párrafo equivalente de `xone-xml-ui` §Visibilidad |
| Ciclo de vida | `xone-development` §Ciclo de vida | Se conserva. Se fusiona con `xone-xml-ui` §Eventos en XML, que aporta los códigos `ANTIPATTERN_*` y la regla de `onclick` frente a `method` |
| Estructura XML | `xone-xml-ui` §Reglas estructurales, §Combo, §Contents, §Layout, §Macros | Se conservan. **Se borra** de ellas la repetición de `progid`, encoding y unicidad, ya cubiertas arriba |
| JavaScript | `xone-javascript` §Objetos globales, §Acceso a datos, §Controles, §Patrones críticos | Se conservan |
| CSS | `xone-css` §Archivos, §Cascada, §Selectores, §Unidades, §Colores, §Herencia, §Parser, §Estilos dinámicos | Se conservan, incluida la nota sobre la discrepancia de nombres de variantes |
| Datos | `xone-data-integration` §Modelo local, §Seguridad, §Integración | Se conservan. **Se borra** la repetición de `ID`/`ROWID`, ya cubierta arriba |
| Dispositivo | `xone-device` §Reglas críticas, §GPS | Se conservan |
| Anti-patrones | las seis tablas | Se fusionan en una sección con seis subtablas (XML, JavaScript, CSS, datos, dispositivo, creación de objetos). Se elimina cualquier fila repetida entre ellas |
| Referencias | nuevo | Índice con un bloque por área y una fila por fichero, con las rutas nuevas `references/<área>/<fichero>.md` |

Reglas de dedupe, en orden de prioridad:

1. Si dos ficheros dicen lo mismo, se conserva **la redacción más precisa**, no la más corta.
2. Si dos ficheros se contradicen, gana el corpus: comprobar en `xone/` antes de elegir. No resolver por criterio propio.
3. Las secciones «Para X, usa la skill Y» de las seis fuentes desaparecen: ya no hay a quién derivar dentro del conocimiento.
4. Los punteros entre skills que hoy cruzan carpetas pasan a rutas internas. Concretamente los tres que existen: el catálogo de eventos (`xone-javascript` → `xml-ui/eventos-*.md`), los códigos `sys-message` (`xone-data-integration` → `xml-ui/eventos-sistema-login-y-personalizados.md`) y los métodos de los controles (`xone-device` → `javascript/metodos-de-los-controles.md`).

- [ ] **Step 4: Comprobar el techo de 400 líneas**

```bash
wc -l plugins/xone-development/skills/xone-development/SKILL.md
```

Esperado: por debajo de 400. Si se pasa, bajar a la primera referencia del área correspondiente lo que sea detalle de un área concreta; no recortar reglas transversales ni anti-patrones.

- [ ] **Step 5: Borrar los cinco directorios absorbidos**

```bash
cd /Users/projects/xone-plugins-market
git rm -r -f plugins/xone-development/skills/xone-xml-ui \
             plugins/xone-development/skills/xone-javascript \
             plugins/xone-development/skills/xone-css \
             plugins/xone-development/skills/xone-data-integration \
             plugins/xone-development/skills/xone-device
ls plugins/xone-development/skills/
```

Esperado: cuatro directorios — `xone-debugging`, `xone-development`, `xone-project-generator`, `xone-review`.

- [ ] **Step 6: Validar**

```bash
scripts/validate-skills.sh; echo "exit=$?"
```

Esperado: `Validated 4 skills…` y `exit=0`. Si aparecen huérfanas, falta enlazarlas en el índice; si aparecen enlaces rotos, la ruta del índice no coincide con la subcarpeta.

- [ ] **Step 7: Commit**

```bash
git add -A plugins/xone-development/skills
git commit -m "Consolidate six knowledge skills into one door"
```

---

### Task 4: Comprobar que no se ha perdido ninguna regla

**Goal:** Verificar contra el inventario de la Task 2 que cada línea de regla de los seis `SKILL.md` originales sigue localizable en el resultado.

> **USER-ORDERED GATE — NON-SKIPPABLE.** This task was requested by the user in the current conversation. It MUST NOT be closed by walking around it, by declaring it "verified inline", or by substituting a cheaper check. Close only after every item in `acceptanceCriteria` has been re-validated independently, with output captured.

**Files:**
- Create: `<scratchpad>/comprobar-reglas.py` (no se versiona)
- Modify: `plugins/xone-development/skills/xone-development/SKILL.md` (solo si aparecen pérdidas que haya que recuperar)

**Acceptance Criteria:**
- [ ] El script informa del número de entradas del inventario localizadas y no localizadas.
- [ ] Toda entrada no localizada queda en una lista revisada explícitamente, con la decisión tomada para cada una: recuperada, o descartada con motivo.
- [ ] Ninguna regla se descarta por descuido: el conteo final de descartadas es cero, o cada descarte tiene motivo escrito.

**Verify:** `python3 <scratchpad>/comprobar-reglas.py` → `localizadas: N / no localizadas: M` con M = 0, o con las M entradas listadas y revisadas una a una

**Steps:**

- [ ] **Step 1: Escribir el comprobador**

Guardar como `<scratchpad>/comprobar-reglas.py`:

```python
#!/usr/bin/env python3
"""Comprueba que cada entrada del inventario sigue presente tras la fusion."""
import re
from pathlib import Path

ROOT = Path("/Users/projects/xone-plugins-market")
SKILL = ROOT / "plugins/xone-development/skills/xone-development"
INVENTARIO = Path(__file__).with_name("inventario-reglas.txt")

corpus = [(SKILL / "SKILL.md").read_text(encoding="utf-8")]
for ref in sorted((SKILL / "references").rglob("*.md")):
    corpus.append(ref.read_text(encoding="utf-8"))
texto = re.sub(r"\s+", " ", "\n".join(corpus))


def marcadores(entrada):
    """Trozos distintivos: literales entre backticks y palabras largas."""
    codigos = re.findall(r"`([^`]+)`", entrada)
    palabras = [w for w in re.findall(r"[A-Za-zÁÉÍÓÚáéíóúñÑ_]{7,}", entrada)]
    return codigos[:3] or palabras[:3]


faltan = []
total = 0
for linea in INVENTARIO.read_text(encoding="utf-8").split("\n"):
    if not linea.strip():
        continue
    total += 1
    origen, _, entrada = linea.partition("\t")
    ms = marcadores(entrada)
    if not ms:
        continue
    if not any(m in texto for m in ms):
        faltan.append((origen, entrada))

print(f"localizadas: {total - len(faltan)} / no localizadas: {len(faltan)}")
for origen, entrada in faltan:
    print(f"  [{origen}] {entrada[:150]}")
```

- [ ] **Step 2: Ejecutarlo**

```bash
python3 <scratchpad>/comprobar-reglas.py
```

- [ ] **Step 3: Revisar una a una las no localizadas**

Para cada entrada de la lista, decidir y **escribir la decisión**:

- Si es una regla real que se ha perdido: recuperarla en el `SKILL.md` fusionado o en la referencia del área correspondiente.
- Si es un puntero entre skills que ya no aplica («Para X, usa la skill Y»), una fila de tabla de índice o un encabezado: descartarla, anotando el motivo.

Volver a ejecutar el script tras cada recuperación.

- [ ] **Step 4: Confirmar el estado final**

```bash
python3 <scratchpad>/comprobar-reglas.py
wc -l plugins/xone-development/skills/xone-development/SKILL.md
scripts/validate-skills.sh; echo "exit=$?"
```

Esperado: la lista de no localizadas está vacía o solo contiene entradas descartadas con motivo escrito; el `SKILL.md` sigue por debajo de 400 líneas; el validador da exit 0.

- [ ] **Step 5: Commit, solo si hubo recuperaciones**

```bash
git add plugins/xone-development/skills/xone-development
git commit -m "Recover rules dropped during the knowledge merge"
```

---

### Task 5: Añadir el guardián de duplicados y el techo de tamaño

**Goal:** Añadir al validador dos comprobaciones que hoy no existen: que ninguna regla canónica esté escrita en más de un `SKILL.md`, y que la puerta de conocimiento no supere las 400 líneas. Debe fallar al añadirla, porque `xone-review` y `xone-debugging` todavía repiten reglas.

**Files:**
- Modify: `scripts/validate-skills.sh`

**Acceptance Criteria:**
- [ ] El script declara los marcadores canónicos en un array al principio, junto al resto de configuración.
- [ ] Falla si un marcador aparece en más de un `SKILL.md`, nombrando el marcador y los ficheros.
- [ ] Falla si el `SKILL.md` de `xone-development` supera las 400 líneas.
- [ ] Al ejecutarlo en este punto **falla**, señalando los marcadores duplicados en las skills de procedimiento.

**Verify:** `scripts/validate-skills.sh` → exit 1 con líneas `Duplicated canonical rule …`

**Steps:**

- [ ] **Step 1: Añadir la configuración de marcadores**

Tras la línea `name_pattern='^[a-z0-9]+(-[a-z0-9]+)*$'` en `scripts/validate-skills.sh`:

```bash
# Reglas canónicas que solo pueden estar escritas en un SKILL.md.
# Detectan duplicación literal, no una paráfrasis: son una red, no una prueba.
canonical_markers=(
  'Bitmask de 4 bits'
  'Los combos **no tienen tipo propio**'
  'Sintaxis del motor'
  '`progid` es opcional'
)
# Skill cuya SKILL.md tiene techo propio, más estricto que el general.
knowledge_skill='xone-development'
knowledge_max_lines=400
```

- [ ] **Step 2: Añadir el techo propio dentro del bucle de skills**

Junto a la comprobación de las 500 líneas:

```bash
  if [[ "$skill" == "$knowledge_skill" ]] && (( $(wc -l < "$file") > knowledge_max_lines )); then
    printf 'Knowledge skill exceeds its own budget (>%d lines): %s\n' "$knowledge_max_lines" "$file" >&2
    failures=$((failures + 1))
  fi
```

- [ ] **Step 3: Añadir el guardián de duplicados después del bucle**

Justo antes del bloque `if command -v opencode`:

```bash
# Guardián del invariante: una regla, un sitio.
for marker in "${canonical_markers[@]}"; do
  hits=()
  for dir in "$skills_dir"/*/; do
    f="${dir%/}/SKILL.md"
    [[ -f "$f" ]] || continue
    if grep -qF "$marker" "$f"; then
      hits+=("$(basename "${dir%/}")")
    fi
  done
  if (( ${#hits[@]} > 1 )); then
    printf 'Duplicated canonical rule "%s" in: %s\n' "$marker" "${hits[*]}" >&2
    failures=$((failures + 1))
  fi
done
```

- [ ] **Step 4: Ejecutar y confirmar que falla**

```bash
scripts/validate-skills.sh; echo "exit=$?"
```

Esperado: `exit=1` con al menos una línea `Duplicated canonical rule …` señalando `xone-development` y `xone-review`. Si no falla, los marcadores no coinciden con el texto real: ajustarlos a cadenas que existan literalmente en ambos ficheros antes de seguir.

- [ ] **Step 5: Commit**

```bash
git add scripts/validate-skills.sh
git commit -m "Add duplicate-rule guard and knowledge skill size ceiling"
```

---

### Task 6: Adelgazar `xone-review` y `xone-debugging`

**Goal:** Quitar de las skills de procedimiento las reglas que ahora viven en la puerta de conocimiento, dejando punteros, hasta que el guardián de la Task 5 pase.

**Files:**
- Modify: `plugins/xone-development/skills/xone-review/SKILL.md`
- Modify: `plugins/xone-development/skills/xone-debugging/SKILL.md`

**Acceptance Criteria:**
- [ ] `xone-review` conserva: precondiciones del CLI, flujo, los cuatro comandos, las dos tablas de códigos del validador, la checklist de entrega, las severidades y el formato de reporte.
- [ ] `xone-review` ya no contiene las secciones «Revisión XML/UI», «Revisión JavaScript», «Revisión CSS», «Revisión datos / integración», «Revisión device» ni la lista de 16 anti-patrones; en su lugar apunta a las tablas de `xone-development`.
- [ ] `xone-debugging` conserva el proceso y la tabla síntoma → causa, y ya no repite las reglas de `load`, `lock`/`unlock`, `MAP_` ni `visible`.
- [ ] El validador pasa: ningún marcador canónico aparece en más de un `SKILL.md`.

**Verify:** `scripts/validate-skills.sh` → `Validated 4 skills…` con exit 0

**Steps:**

- [ ] **Step 1: Ver qué marcadores están duplicados y dónde**

```bash
cd /Users/projects/xone-plugins-market
for m in 'Bitmask de 4 bits' 'Los combos **no tienen tipo propio**' 'Sintaxis del motor' '`progid` es opcional'; do
  echo "--- $m"
  grep -lF "$m" plugins/xone-development/skills/*/SKILL.md
done
```

- [ ] **Step 2: Recortar `xone-review`**

Eliminar las cinco secciones de revisión por capa y la lista de anti-patrones. Sustituirlas por un bloque único:

```markdown
## Qué revisar en cada capa

Las reglas y los anti-patrones de cada capa viven en la skill `xone-development`, que es donde se escriben una sola vez. Antes de marcar un hallazgo, contrástalo allí:

- Reglas transversales, tipos de prop, visibilidad, ciclo de vida y sintaxis del motor: `xone-development/SKILL.md`.
- Anti-patrones por área (XML, JavaScript, CSS, datos, dispositivo): sección «Anti-patrones» de `xone-development/SKILL.md`.
- Detalle de un atributo, una API o un valor admitido: el índice de referencias de `xone-development/SKILL.md`.

**No reportes como hallazgo nada que no puedas anclar al validador o a esas reglas.**
```

Mantener intactas las secciones de precondiciones, flujo, comandos, códigos del validador, checklist de entrega, severidades y reporte. La nota sobre el conflicto de `progid` entre el linter y la documentación **se mueve** a `xone-development` junto al resto de reglas de `progid`; en `xone-review` queda solo la mención de que el código `COLL_MISSING_PROGID` existe.

- [ ] **Step 3: Recortar `xone-debugging`**

Eliminar la sección `## Reglas` completa —sus cinco puntos están todos en la puerta de conocimiento— y sustituirla por:

```markdown
## Reglas

Las reglas de XOne que suelen estar detrás de estos síntomas (`load` frente a `before-edit`, `lock`/`unlock`, `MAP_` no persistente, `visible` estático) están en la skill `xone-development`. Aquí solo se diagnostica; la forma correcta se consulta allí.
```

Mantener el proceso, el bloque de comandos, el diagnóstico rápido por síntoma y el índice de sus dos referencias.

- [ ] **Step 4: Validar**

```bash
scripts/validate-skills.sh; echo "exit=$?"
```

Esperado: `Validated 4 skills…` y `exit=0`, sin líneas `Duplicated canonical rule`.

- [ ] **Step 5: Commit**

```bash
git add plugins/xone-development/skills/xone-review plugins/xone-development/skills/xone-debugging
git commit -m "Remove rules duplicated from the knowledge door"
```

---

### Task 7: Resolver el descubrimiento de skills en Codex

**Goal:** Dejar el repositorio utilizable desde Codex sin duplicar las skills, y confirmar empíricamente cuál de las dos vías funciona.

> **USER-ORDERED GATE — NON-SKIPPABLE.** This task was requested by the user in the current conversation. It MUST NOT be closed by walking around it, by declaring it "verified inline", or by substituting a cheaper check. Close only after every item in `acceptanceCriteria` has been re-validated independently, with output captured.

**Files:**
- Create: `AGENTS.md`
- Create (solo si la comprobación de `AGENTS.md` falla): `.codex/skills/` con symlinks
- Modify: `README.md` (sección de instalación)

**Acceptance Criteria:**
- [ ] Existe `AGENTS.md` en la raíz indicando dónde viven las skills.
- [ ] Se ha ejecutado `codex` contra el repositorio y se ha capturado su salida.
- [ ] Queda registrado si Codex enumera las cuatro skills por la vía de `AGENTS.md`: **sí** o **no**, con la salida que lo demuestra.
- [ ] Si la respuesta es **no**, existen los symlinks en `.codex/skills/` y se ha vuelto a comprobar con `codex`, capturando también esa salida.
- [ ] El README documenta la vía que **se ha comprobado que funciona**, no la que se suponía.

**Verify:** `codex` ejecutado contra el repo → salida capturada que enumera las cuatro skills (`xone-development`, `xone-project-generator`, `xone-review`, `xone-debugging`), por la vía de `AGENTS.md` o por la de symlinks

**Steps:**

- [ ] **Step 1: Crear `AGENTS.md`**

```markdown
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
```

- [ ] **Step 2: Comprobar si Codex las descubre por esa vía**

```bash
cd /Users/projects/xone-plugins-market
codex --version
codex exec "Lista las skills de XOne disponibles en este repositorio, por su nombre exacto." 2>&1 | tee /tmp/codex-agentsmd.txt
```

Leer la salida capturada. La pregunta a responder es concreta: **¿aparecen los cuatro nombres?**

- [ ] **Step 3: Si no aparecen, crear los symlinks y repetir**

```bash
mkdir -p .codex/skills
for s in xone-development xone-project-generator xone-review xone-debugging; do
  ln -sfn ../../plugins/xone-development/skills/$s .codex/skills/$s
done
ls -l .codex/skills/
codex exec "Lista las skills de XOne disponibles en este repositorio, por su nombre exacto." 2>&1 | tee /tmp/codex-symlinks.txt
```

- [ ] **Step 4: Documentar en el README solo lo comprobado**

En la sección de instalación, añadir el bloque de Codex describiendo **la vía que funcionó**, con una frase que diga cómo se comprobó. Si ninguna de las dos funcionó, escribirlo así de claro: «Codex: pendiente, ninguna de las dos vías enumeró las skills en la comprobación del <fecha>», y no afirmar compatibilidad.

- [ ] **Step 5: Commit**

```bash
git add AGENTS.md README.md
[ -d .codex ] && git add .codex
git commit -m "Add Codex skill discovery and document the verified path"
```

---

### Task 8: Actualizar documentación y versión

**Goal:** Dejar README, arquitectura, changelog y TODO coherentes con las cuatro skills, y subir la versión a `0.11.0` en los dos manifiestos.

**Files:**
- Modify: `README.md`
- Modify: `docs/ARCHITECTURE.md` (§4 taxonomía, §10 estructura, §10.1 reglas duplicadas, §13.4)
- Modify: `CHANGELOG.md`
- Modify: `docs/TODO.md`
- Modify: `plugins/xone-development/.claude-plugin/plugin.json`
- Modify: `.claude-plugin/marketplace.json`
- Modify: `plugins/xone-development/commands/xone-validate.md` (lista de skills que menciona)

**Acceptance Criteria:**
- [ ] Ninguna mención a `xone-xml-ui`, `xone-javascript`, `xone-css`, `xone-data-integration` ni `xone-device` como skills fuera del CHANGELOG histórico y de `xone/`.
- [ ] README describe cuatro skills y la estructura de subcarpetas por área.
- [ ] `ARCHITECTURE.md` §4 tiene cuatro entradas; §10 refleja el árbol nuevo; §10.1 sustituye la lista de reglas duplicadas por el invariante y el guardián; §13.4 queda cerrada.
- [ ] `CHANGELOG.md` tiene una entrada `0.11.0` con lo añadido, cambiado y eliminado.
- [ ] `docs/TODO.md` marca la tarea 7 como hecha.
- [ ] Ambos manifiestos declaran `0.11.0`.

**Verify:** `scripts/validate-skills.sh && claude plugin validate ./plugins/xone-development` → ambos en verde, y `grep -rn 'xone-xml-ui\|xone-javascript\|xone-css\|xone-data-integration\|xone-device' --include='*.md' --include='*.json' . | grep -v '^./xone/' | grep -v CHANGELOG` sin resultados

**Steps:**

- [ ] **Step 1: Subir la versión en los dos manifiestos**

```bash
cd /Users/projects/xone-plugins-market
python3 - <<'PY'
from pathlib import Path
for p in ['plugins/xone-development/.claude-plugin/plugin.json', '.claude-plugin/marketplace.json']:
    f = Path(p); s = f.read_text(encoding='utf-8')
    assert '"version": "0.10.0"' in s, p
    f.write_text(s.replace('"version": "0.10.0"', '"version": "0.11.0"'), encoding='utf-8')
    print('bump', p)
PY
```

- [ ] **Step 2: Actualizar el README**

Reducir la tabla de skills a cuatro filas, con las descripciones de la tabla «Decisión» del spec. En «Cómo está organizado el conocimiento», sustituir el árbol de ejemplo por el de subcarpetas por área. Añadir el bloque de Codex resultante de la Task 7.

- [ ] **Step 3: Actualizar `ARCHITECTURE.md`**

- §4: dejar cuatro entradas. Las secciones §4.2 a §4.6 (xml-ui, javascript, css, data-integration, device) se funden en la de `xone-development`, indicando que sus áreas pasan a ser subcarpetas de referencias.
- §10: sustituir el árbol por el de cuatro skills con subcarpetas.
- §10.1: sustituir el párrafo «Reglas duplicadas a propósito» por el invariante «una regla, un sitio» y la descripción del guardián del validador.
- §13.4: marcarla como resuelta, con la fecha y la opción elegida.

- [ ] **Step 4: Añadir la entrada del CHANGELOG**

```markdown
## [0.11.0] - <fecha>

### Cambiado

- De nueve skills a cuatro. `xone-xml-ui`, `xone-javascript`, `xone-css`,
  `xone-data-integration` y `xone-device` se fusionan en `xone-development`, cuya
  carpeta `references/` pasa a estar organizada en subcarpetas por área. Las tareas de
  XOne llegan cruzadas —una pantalla es `.xne` más evento más CSS— y con activación
  automática el caso a cubrir era que el agente abriese una sola puerta.
- Invariante nuevo: una regla se escribe una vez, en la puerta de conocimiento. Las
  skills de procedimiento la referencian. `xone-review` pierde sus anti-patrones y sus
  reglas por capa; `xone-debugging` deja de repetir las reglas de `load`, `lock`/`unlock`
  y `MAP_`.

### Añadido

- `AGENTS.md` para el descubrimiento de skills desde Codex.
- Dos comprobaciones en `scripts/validate-skills.sh`: techo de 400 líneas para la puerta
  de conocimiento, y guardián que falla si una regla canónica aparece en más de un
  `SKILL.md`.
```

- [ ] **Step 5: Actualizar `docs/TODO.md`**

Marcar la tarea 7 (consolidación de fronteras) como hecha, con la opción elegida. La tarea 6 (pruebas de activación) sigue pendiente, y su cobertura se simplifica: ya no hay que medir la elección entre seis skills de conocimiento, solo si el agente abre las referencias del índice.

- [ ] **Step 6: Comprobar que no quedan menciones obsoletas**

```bash
grep -rn 'xone-xml-ui\|xone-javascript\|xone-css\|xone-data-integration\|xone-device' \
  --include='*.md' --include='*.json' . \
  | grep -v '^./xone/' | grep -v CHANGELOG.md | grep -v docs/superpowers/ \
  || echo "sin menciones obsoletas"
```

- [ ] **Step 7: Validar todo**

```bash
scripts/validate-skills.sh; echo "exit=$?"
claude plugin validate ./plugins/xone-development
```

Esperado: `Validated 4 skills…`, `exit=0` y `✔ Validation passed`.

- [ ] **Step 8: Commit**

```bash
git add -A
git commit -m "Document the four-skill layout and bump to 0.11.0"
```
