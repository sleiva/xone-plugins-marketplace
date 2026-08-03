#!/usr/bin/env bash
# Valida las skills del plugin xone-development.
#
# Comprueba lo que se puede romper sin que nadie se entere:
#   - frontmatter: `name` presente y coincidente con el directorio, `description` no vacía
#   - tamaño del SKILL.md (límite recomendado de Agent Skills)
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
  if (( $(wc -l < "$file") >= 500 )); then
    printf 'SKILL.md is too long (>=500 lines): %s\n' "$file" >&2
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
      if ! grep -q "$rel" "$file"; then
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

printf 'Validated %d skills: frontmatter, size, reference links and OpenCode discovery.\n' "$skills"
