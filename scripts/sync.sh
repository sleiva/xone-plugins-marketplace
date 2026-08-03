#!/usr/bin/env bash
set -euo pipefail

# Sincroniza las skills canonicas (plugins/xone-development/skills) hacia
# .opencode/skills para que Claude Code y OpenCode compartan el mismo contenido.
# Falla (exit 1) si hay divergencia tras copiar.

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/plugins/xone-development/skills"
DST="$ROOT/.opencode/skills"

if [ ! -d "$SRC" ]; then
  echo "ERROR: no existe la fuente canónica: $SRC" >&2
  exit 1
fi

mkdir -p "$DST"

cp -R "$SRC"/. "$DST"/

failed=0
for skill in "$SRC"/*/; do
  name="$(basename "$skill")"
  for file in "$skill"SKILL.md; do
    if [ -f "$file" ]; then
      if ! cmp -s "$file" "$DST/$name/SKILL.md"; then
        echo "ERROR: divergencia en $name/SKILL.md" >&2
        failed=1
      fi
    fi
  done
done

if [ "$failed" -ne 0 ]; then
  echo "ERROR: las copias de OpenCode divergen de la fuente canónica." >&2
  exit 1
fi

echo "OK: skills sincronizadas de $SRC a $DST"
