#!/usr/bin/env bash
# Valida las skills del plugin xone-development.
#
# Comprueba lo que se puede romper sin que nadie se entere:
#   - frontmatter: `name` presente y coincidente con el directorio, `description` no vacía
#   - frontmatter: parseo YAML real (no una extracción con awk) que produzca `name` y `description`
#   - tamaño del SKILL.md (límite recomendado de Agent Skills)
#   - techo propio, más estricto, para el SKILL.md de la puerta de conocimiento
#   - que ninguna regla de contenido esté parafraseada en más de un SKILL.md (guardián de duplicados)
#   - que todo enlace a references/ resuelva, tanto desde el SKILL.md como los enlaces
#     relativos que hay dentro de los propios ficheros de references/
#   - que toda referencia esté enlazada desde su SKILL.md (nada huérfano en el paquete)
#   - que OpenCode pueda enumerar las skills
#
# Las skills se descubren desde el sistema de ficheros: añadir una skill nueva no
# requiere tocar este script, y una skill sin documentar no pasa desapercibida.
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skills_dir="$root/plugins/xone-development/skills"

if [[ ! -d "$skills_dir" ]]; then
  printf 'Missing skills directory: %s\n' "$skills_dir" >&2
  exit 1
fi

failures=0
skills=0
name_pattern='^[a-z0-9]+(-[a-z0-9]+)*$'

# Skill cuya SKILL.md es la puerta de conocimiento: techo propio, más estricto
# que el límite general de 500 líneas, para forzar que crezca por referencias
# y no por acumulación de prosa.
knowledge_skill='xone-development'
knowledge_max_lines=400

# Guardián del invariante "una regla, un sitio": tras el merge no queda
# duplicación literal entre la puerta de conocimiento y las skills de
# procedimiento, solo paráfrasis. Dos líneas de contenido (sin frontmatter,
# sin encabezados, sin bloques de código) de más de N caracteres que comparten
# más del umbral de sus tokens significativos, en SKILL.md distintos, se
# tratan como la misma regla escrita dos veces. Es una heurística de
# paráfrasis, no una prueba exacta: puede marcar frases genéricas que
# comparten vocabulario de dominio sin ser la misma regla.
dup_min_line_length=35
dup_min_token_length=5
dup_overlap_threshold=0.65
# Piso de tokens significativos por línea: sin él, una línea con un único
# token largo (p. ej. una fila de checklist que solo menciona "colección")
# empata al 100% con cualquier otra línea que contenga esa misma palabra,
# por puro azar de vocabulario compartido, no por repetir una regla. Tres
# tokens es el piso más bajo que sigue distinguiendo coincidencia real de
# coincidencia de una sola palabra de dominio. (Con este piso: 111 pares;
# sin él: 132.)
dup_min_significant_tokens=3

# Lista de excepciones del guardián de duplicados: pares concretos que el
# heurístico marca pero que un reviewer humano ya determinó que NO son la
# misma regla escrita dos veces (falso positivo) o que quedan fuera del
# invariante "una regla, un sitio" (p. ej. un aviso operativo del CLI que no
# vive en la puerta de conocimiento). Cada entrada se ata a un fragmento de
# texto de cada línea, no a un número de línea, para no desincronizarse
# cuando los ficheros cambien de tamaño. Formato por entrada, campos
# separados por ` ||| `:
#   skill_a ||| fragmento_a ||| skill_b ||| fragmento_b ||| razón
# El orden de skill_a/skill_b no importa: se comprueba en ambos sentidos.
#
# Sé parco: esta lista es la única forma sancionada de silenciar el
# guardián, y una lista larga es exactamente cómo un guardián se neutraliza
# en silencio. Si hace falta una décima entrada, es señal de que falta
# quitar duplicación real, no de que falta una excepción más.
dup_allowlist_entries=(
  'xone-debugging ||| Pantalla vacía ||| xone-development ||| Solo en el segundo y siguientes ||| Diagnóstico por síntoma (xone-debugging:29): enumera qué comprobar sin afirmar el valor correcto de ninguna regla; la fila del door es la regla en sí. Mismo vocabulario de dominio, dos roles distintos.'
  'xone-debugging ||| --db-path` debe apuntar a una **copia** de la BD ||| xone-review ||| de la base de datos: el simulador puede mutarla ||| Aviso operativo de `--db-path` sobre el CLI xone-simulator: no es una regla de XOne que deba vivir en la puerta de conocimiento.'
  'xone-debugging ||| Pantalla vacía ||| xone-review ||| Pantalla vacía → XML ||| Mismo diagnóstico rápido por síntoma repetido en debugging y review (cada skill lo necesita en su propio flujo); no afirma valores de las reglas subyacentes.'
  'xone-development ||| mappings-y-colecciones-separadas.md ||| xone-project-generator ||| Archivos de configuración (`app.xml`, `app.ini`, `mappings.xne`) ||| Fila del índice de referencias del door vs. bullet de capacidades del generador: coincidencia de nombres de fichero, no regla duplicada.'
  'xone-development ||| plantillas-y-funciones-utilitarias.md ||| xone-project-generator ||| Funciones JavaScript globales ||| Fila del índice de referencias del door vs. tabla de ficheros de configuración del generador: coincidencia de vocabulario, no regla duplicada.'
  'xone-development ||| dinamicos-cascada-y-componentes.md ||| xone-project-generator ||| viewmodes de mapa y calendario ||| Dos filas de índice/TOC en ficheros distintos: coincidencia de vocabulario de dominio (mapas, calendario), no regla duplicada.'
  'xone-development ||| Para crear un proyecto completo desde cero ||| xone-review ||| Para diagnosticar un fallo a partir de su síntoma, usa ||| Frase de cierre que enlaza unas skills con otras (puntero de navegación), no una regla de XOne.'
  'xone-development ||| Conflicto conocido sin resolver ||| xone-review ||| Coll con `objname` pero sin `progid` ||| El door nombra el código `COLL_MISSING_PROGID` para registrar el conflicto linter/documentación (única fuente de esa advertencia); xone-review nombra el mismo código en su tabla de códigos del validador (dato ya exigido como contenido a conservar). Los dos necesariamente citan el mismo identificador de código; no es la regla de XOne repetida, es una fila de tabla de códigos y una nota de conflicto sobre esa fila.'
)

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

dup_allowlist_file="$tmp_dir/dup_allowlist.tsv"
printf '%s\n' "${dup_allowlist_entries[@]}" > "$dup_allowlist_file"

have_python3=0
if command -v python3 >/dev/null 2>&1; then
  have_python3=1
fi

have_pyyaml=0
if (( have_python3 )) && python3 -c 'import yaml' >/dev/null 2>&1; then
  have_pyyaml=1
fi

if (( ! have_python3 )); then
  printf 'Warning: python3 is not installed; skipped duplicate-rule check and frontmatter YAML parse.\n' >&2
elif (( ! have_pyyaml )); then
  printf 'Warning: pyyaml is not installed; skipped frontmatter YAML parse.\n' >&2
fi

if (( have_pyyaml )); then
  cat > "$tmp_dir/check_frontmatter.py" <<'PY'
import sys

import yaml

try:
    data = yaml.safe_load(sys.stdin.read())
except Exception as exc:
    print('invalid YAML: ' + str(exc))
    sys.exit(1)

if not isinstance(data, dict):
    print('frontmatter is empty or not a mapping')
    sys.exit(1)

missing = []
for key in ('name', 'description'):
    value = data.get(key)
    if not isinstance(value, str) or not value.strip():
        missing.append(key)

if missing:
    print('missing or empty field(s): ' + ', '.join(missing))
    sys.exit(1)
PY
fi

if (( have_python3 )); then
  cat > "$tmp_dir/check_duplicates.py" <<'PY'
import re
import sys
from pathlib import Path

skills_dir = Path(sys.argv[1])
min_line_len = int(sys.argv[2])
min_token_len = int(sys.argv[3])
threshold = float(sys.argv[4])
min_significant_tokens = int(sys.argv[5])
allowlist_path = Path(sys.argv[6]) if len(sys.argv) > 6 else None

token_re = re.compile(r'[`\w]{%d,}' % min_token_len)


def load_allowlist(path):
    """Excepciones por contenido: skill_a ||| fragmento_a ||| skill_b ||| fragmento_b ||| razón."""
    entries = []
    if path is None or not path.exists():
        return entries
    for raw in path.read_text(encoding='utf-8').split('\n'):
        raw = raw.strip()
        if not raw:
            continue
        parts = [p.strip() for p in raw.split('|||')]
        if len(parts) != 5:
            print('Malformed dup_allowlist entry (expected 5 fields separated by |||): ' + raw, file=sys.stderr)
            continue
        skill_a, sub_a, skill_b, sub_b, reason = parts
        entries.append({
            'skill_a': skill_a, 'sub_a': sub_a,
            'skill_b': skill_b, 'sub_b': sub_b,
            'reason': reason, 'used': False,
        })
    return entries


def match_allowlist(entries, skill1, text1, skill2, text2):
    # Comparación insensible a mayúsculas: el fragmento de la excepción es
    # texto libre copiado de la skill, no una expresión regular, y no debería
    # dejar de coincidir solo porque una frase empieza con mayúscula en un
    # sitio y en minúscula en otro.
    text1_low, text2_low = text1.lower(), text2.lower()
    for entry in entries:
        sub_a_low, sub_b_low = entry['sub_a'].lower(), entry['sub_b'].lower()
        forward = (skill1 == entry['skill_a'] and sub_a_low in text1_low
                   and skill2 == entry['skill_b'] and sub_b_low in text2_low)
        backward = (skill2 == entry['skill_a'] and sub_a_low in text2_low
                    and skill1 == entry['skill_b'] and sub_b_low in text1_low)
        if forward or backward:
            entry['used'] = True
            return entry
    return None


def content_lines(path):
    """Content lines only: no frontmatter, no headings, no fenced code."""
    out = []
    in_frontmatter = False
    past_frontmatter = False
    fence = False
    for i, raw in enumerate(path.read_text(encoding='utf-8').split('\n'), 1):
        stripped = raw.strip()
        if not past_frontmatter:
            if i == 1 and stripped == '---':
                in_frontmatter = True
                continue
            if in_frontmatter:
                if stripped == '---':
                    in_frontmatter = False
                    past_frontmatter = True
                continue
            past_frontmatter = True
        if stripped.startswith('```'):
            fence = not fence
            continue
        if fence:
            continue
        s = re.sub(r'\s+', ' ', raw).strip()
        if not s or s.startswith('#'):
            continue
        if len(s) <= min_line_len:
            continue
        out.append((i, s))
    return out


def tokens(s):
    return set(token_re.findall(s.lower()))


allow_entries = load_allowlist(allowlist_path)

files = sorted(skills_dir.glob('*/SKILL.md'))
lines_by_file = {f: content_lines(f) for f in files}
tokens_by_file = {
    f: [(ln, s, tokens(s)) for ln, s in lines_by_file[f]] for f in files
}

found = 0
for i, f1 in enumerate(files):
    for f2 in files[i + 1:]:
        for ln1, s1, t1 in tokens_by_file[f1]:
            if len(t1) < min_significant_tokens:
                continue
            for ln2, s2, t2 in tokens_by_file[f2]:
                if len(t2) < min_significant_tokens:
                    continue
                overlap = len(t1 & t2)
                ratio = max(overlap / len(t1), overlap / len(t2))
                if ratio > threshold:
                    skill1, skill2 = f1.parent.name, f2.parent.name
                    entry = match_allowlist(allow_entries, skill1, s1, skill2, s2)
                    if entry is not None:
                        print('Allowlisted duplicate (%.0f%% overlap) — %s' % (ratio * 100, entry['reason']))
                        print('  %s:%d: %s' % (skill1, ln1, s1))
                        print('  %s:%d: %s' % (skill2, ln2, s2))
                        continue
                    found += 1
                    print('Duplicated canonical rule (%.0f%% token overlap):' % (ratio * 100))
                    print('  %s:%d: %s' % (skill1, ln1, s1))
                    print('  %s:%d: %s' % (skill2, ln2, s2))

# Anti-rot: una excepción que ya no coincide con nada es una excepción que
# alguien debería borrar (la duplicación que justificaba ya no existe, o el
# texto cambió). No hacemos fallar el build por esto: es una señal para
# limpiar la lista, no una regresión.
for entry in allow_entries:
    if not entry['used']:
        print(
            'Warning: dup_allowlist entry never matched (consider removing it): '
            '%s ||| %s ||| %s ||| %s' % (entry['skill_a'], entry['sub_a'], entry['skill_b'], entry['sub_b']),
            file=sys.stderr,
        )

sys.exit(1 if found else 0)
PY
fi

for dir in "$skills_dir"/*/; do
  dir="${dir%/}"
  skill="$(basename "$dir")"
  file="$dir/SKILL.md"

  if [[ ! -f "$file" ]]; then
    printf 'Missing SKILL.md: %s\n' "$dir" >&2
    failures=$((failures + 1))
    continue
  fi
  skills=$((skills + 1))

  frontmatter=$(awk 'NR == 1 { in_fm = ($0 == "---"); next } in_fm && $0 == "---" { exit } in_fm { print }' "$file")
  name=$(printf '%s\n' "$frontmatter" | awk '/^name:/ { sub(/^name:[[:space:]]*/, ""); print; exit }')
  description=$(printf '%s\n' "$frontmatter" | awk '/^description:/ { sub(/^description:[[:space:]]*/, ""); print; exit }')

  if [[ "$name" != "$skill" ]]; then
    printf 'Invalid name in %s: %s (expected %s)\n' "$file" "${name:-<missing>}" "$skill" >&2
    failures=$((failures + 1))
  fi
  if [[ ! "$skill" =~ $name_pattern ]]; then
    printf 'Skill name does not match %s: %s\n' "$name_pattern" "$skill" >&2
    failures=$((failures + 1))
  fi
  if [[ -z "$description" ]]; then
    printf 'Missing description in %s\n' "$file" >&2
    failures=$((failures + 1))
  fi

  # Parseo YAML real del frontmatter: la extracción awk de arriba no detecta
  # un frontmatter que no es YAML válido (p. ej. un `description:` sin
  # comillas que contenga ": "), y ese fallo hace que la skill no cargue.
  if (( have_pyyaml )); then
    if yaml_error=$(printf '%s\n' "$frontmatter" | PYTHONIOENCODING=utf-8 python3 "$tmp_dir/check_frontmatter.py" 2>&1); then
      :
    else
      printf 'Frontmatter is not valid YAML in %s: %s\n' "$file" "$yaml_error" >&2
      failures=$((failures + 1))
    fi
  fi

  if (( $(wc -l < "$file") >= 500 )); then
    printf 'SKILL.md is too long (>=500 lines): %s\n' "$file" >&2
    failures=$((failures + 1))
  fi
  if [[ "$skill" == "$knowledge_skill" ]] && (( $(wc -l < "$file") > knowledge_max_lines )); then
    printf 'Knowledge skill exceeds its own budget (>%d lines): %s\n' "$knowledge_max_lines" "$file" >&2
    failures=$((failures + 1))
  fi

  # Todo enlace a references/ debe resolver.
  while read -r link; do
    [[ -z "$link" ]] && continue
    if [[ ! -f "$dir/$link" ]]; then
      printf 'Broken reference link in %s: %s\n' "$file" "$link" >&2
      failures=$((failures + 1))
    fi
  done < <(grep -o '(references/[^)#]*\.md' "$file" 2>/dev/null | sed 's/^(//' | sort -u)

  # Toda referencia del paquete debe estar enlazada desde su SKILL.md,
  # incluidas las que viven en subcarpetas por área.
  if [[ -d "$dir/references" ]]; then
    while IFS= read -r ref; do
      [[ -n "$ref" ]] || continue
      rel="${ref#$dir/}"
      if ! grep -qF -- "($rel" "$file"; then
        printf 'Orphaned reference (not linked from SKILL.md): %s\n' "$ref" >&2
        failures=$((failures + 1))
      fi
    done < <(find "$dir/references" -type f -name '*.md' | sort)
  fi

  # Todo enlace relativo dentro de un fichero de references/ debe resolver,
  # no solo los enlaces que SKILL.md hace hacia references/ (arriba). Esto
  # cubre el caso real que lo motivó: al mover las 54 referencias de
  # xone-development un nivel más profundo (subcarpetas por área), sus
  # cabeceras `[../SKILL.md](../SKILL.md)` dejaron de resolver y ningún check
  # existente lo detectaba, porque ninguno mira dentro de los propios
  # ficheros de referencia.
  if [[ -d "$dir/references" ]]; then
    while IFS= read -r ref; do
      [[ -n "$ref" ]] || continue
      ref_dir="$(dirname "$ref")"
      while read -r link; do
        [[ -z "$link" ]] && continue
        case "$link" in
          http://*|https://*|mailto:*|\#*|/*) continue ;;
        esac
        link_path="${link%%#*}"
        [[ -z "$link_path" ]] && continue
        # Solo rutas relativas a un fichero .md: descarta placeholders de
        # sintaxis Markdown citados como ejemplo (p. ej. `[texto](url)` en
        # una tabla que documenta el propio formato Markdown), que no son
        # enlaces reales y no deben tratarse como ruta rota.
        [[ "$link_path" == *.md ]] || continue
        if [[ ! -f "$ref_dir/$link_path" ]]; then
          printf 'Broken relative link inside reference file %s: %s\n' "$ref" "$link" >&2
          failures=$((failures + 1))
        fi
      done < <(grep -o '\]([^)]*)' "$ref" 2>/dev/null | sed -E 's/^\]\(//; s/\)$//' | sort -u)
    done < <(find "$dir/references" -type f -name '*.md' | sort)
  fi
done

if (( skills == 0 )); then
  printf 'No skills found in %s\n' "$skills_dir" >&2
  exit 1
fi

# Guardián del invariante: una regla, un sitio. A diferencia de una lista de
# marcadores literales, esto detecta paráfrasis: tras el merge no queda
# duplicación byte-idéntica entre la puerta de conocimiento y las skills de
# procedimiento, solo reformulación de la misma regla.
#
# 2>&1 y PYTHONIOENCODING=utf-8 no son opcionales: sin ellos, un traceback
# (p. ej. un UnicodeEncodeError al imprimir texto en español bajo un locale
# sin UTF-8, como CI o cron) se iría por stderr sin capturar, dup_pairs
# quedaría en 0 y el script saldría con éxito sin haber comprobado nada.
if (( have_python3 )); then
  if dup_output=$(PYTHONIOENCODING=utf-8 python3 "$tmp_dir/check_duplicates.py" "$skills_dir" "$dup_min_line_length" "$dup_min_token_length" "$dup_overlap_threshold" "$dup_min_significant_tokens" "$dup_allowlist_file" 2>&1); then
    dup_status=0
  else
    dup_status=$?
  fi
  # Se imprime siempre que haya algo que mostrar (pares permitidos, avisos de
  # entradas de la allowlist que ya no coinciden con nada), no solo cuando el
  # guardián falla: si no, esas señales quedan invisibles en una ejecución
  # que pasa.
  if [[ -n "$dup_output" ]]; then
    printf '%s\n' "$dup_output" >&2
  fi
  if (( dup_status != 0 )); then
    dup_pairs=$(printf '%s\n' "$dup_output" | grep -c '^Duplicated canonical rule' || true)
    # Salida no vacía y exit != 0 pero ningún par reconocido: el bloque python
    # falló de otra forma (traceback, error de invocación). No lo tratamos
    # como éxito: cuenta como al menos un fallo.
    if (( dup_pairs == 0 )); then
      dup_pairs=1
    fi
    failures=$((failures + dup_pairs))
  fi
fi

if command -v opencode >/dev/null 2>&1; then
  if ! (cd "$root" && opencode debug skill >/dev/null 2>&1); then
    printf 'OpenCode could not enumerate skills.\n' >&2
    failures=$((failures + 1))
  fi
else
  printf 'Warning: opencode is not installed; skipped discovery check.\n' >&2
fi

if (( failures > 0 )); then
  printf '%d validation error(s)\n' "$failures" >&2
  exit 1
fi

# El mensaje de éxito solo puede nombrar lo que realmente se ejecutó: si
# python3/pyyaml/opencode faltan, esas comprobaciones se saltaron con un
# warning más arriba, no pasaron.
ran='frontmatter (name/description), size (incl. knowledge-skill ceiling)'
if (( have_pyyaml )); then
  ran="$ran, frontmatter YAML parse"
fi
if (( have_python3 )); then
  ran="$ran, duplicate-rule guard"
fi
ran="$ran, reference links (incl. links inside references)"
if command -v opencode >/dev/null 2>&1; then
  ran="$ran, OpenCode discovery"
fi
printf 'Validated %d skills: %s.\n' "$skills" "$ran"
