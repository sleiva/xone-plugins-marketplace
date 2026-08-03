#!/usr/bin/env bash
# Valida las skills del plugin xone-development.
#
# Comprueba lo que se puede romper sin que nadie se entere:
#   - frontmatter: `name` presente y coincidente con el directorio, `description` no vacía
#   - frontmatter: parseo YAML real (no una extracción con awk) que produzca `name` y `description`
#   - tamaño del SKILL.md (límite recomendado de Agent Skills)
#   - techo propio, más estricto, para el SKILL.md de la puerta de conocimiento
#   - que ninguna regla de contenido esté parafraseada en más de un SKILL.md (guardián de duplicados)
#   - que todo enlace a references/ resuelva
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

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

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

# Piso de tokens significativos por línea. Sin este piso, una línea con un
# único token largo (p. ej. una fila de checklist que solo menciona
# "colección") empata al 100% con cualquier otra línea que contenga esa
# misma palabra, por puro azar de vocabulario compartido, no por repetir
# una regla. Tres tokens es el piso más bajo que sigue distinguiendo
# coincidencia real de coincidencia de una sola palabra de dominio.
min_significant_tokens = 3

token_re = re.compile(r'[`\w]{%d,}' % min_token_len)


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
                    found += 1
                    print('Duplicated canonical rule (%.0f%% token overlap):' % (ratio * 100))
                    print('  %s:%d: %s' % (f1.parent.name, ln1, s1))
                    print('  %s:%d: %s' % (f2.parent.name, ln2, s2))

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
    if yaml_error=$(printf '%s\n' "$frontmatter" | python3 "$tmp_dir/check_frontmatter.py" 2>&1); then
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
done

if (( skills == 0 )); then
  printf 'No skills found in %s\n' "$skills_dir" >&2
  exit 1
fi

# Guardián del invariante: una regla, un sitio. A diferencia de una lista de
# marcadores literales, esto detecta paráfrasis: tras el merge no queda
# duplicación byte-idéntica entre la puerta de conocimiento y las skills de
# procedimiento, solo reformulación de la misma regla.
if (( have_python3 )); then
  if ! dup_output=$(python3 "$tmp_dir/check_duplicates.py" "$skills_dir" "$dup_min_line_length" "$dup_min_token_length" "$dup_overlap_threshold"); then
    printf '%s\n' "$dup_output" >&2
    dup_pairs=$(printf '%s\n' "$dup_output" | grep -c '^Duplicated canonical rule' || true)
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

printf 'Validated %d skills: frontmatter (incl. YAML parse), size (incl. knowledge-skill ceiling), duplicate-rule guard, reference links and OpenCode discovery.\n' "$skills"
