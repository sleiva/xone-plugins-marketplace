#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
skills_dir="$root/plugins/xone-development/skills"
expected=(
  xone-development
  xone-xml-ui
  xone-javascript
  xone-css
  xone-data-integration
  xone-device
  xone-verification
  xone-debugging
  xone-review
)

failures=0
for skill in "${expected[@]}"; do
  file="$skills_dir/$skill/SKILL.md"
  if [[ ! -f "$file" ]]; then
    printf 'Missing: %s\n' "$file" >&2
    failures=$((failures + 1))
    continue
  fi

  frontmatter=$(awk 'NR == 1 { in_frontmatter = ($0 == "---"); next } in_frontmatter && $0 == "---" { exit } in_frontmatter { print }' "$file")
  name=$(printf '%s\n' "$frontmatter" | awk -F': ' '$1 == "name" { print $2; exit }')
  description=$(printf '%s\n' "$frontmatter" | awk -F': ' '$1 == "description" { sub(/^[^:]*: /, ""); print; exit }')

  if [[ "$name" != "$skill" ]]; then
    printf 'Invalid name in %s: %s\n' "$file" "${name:-<missing>}" >&2
    failures=$((failures + 1))
  fi
  if [[ -z "$description" ]]; then
    printf 'Missing description in %s\n' "$file" >&2
    failures=$((failures + 1))
  fi
  if (( $(wc -l < "$file") >= 500 )); then
    printf 'Skill is too long: %s\n' "$file" >&2
    failures=$((failures + 1))
  fi
done

if [[ ! -d "$skills_dir" ]]; then
  printf 'Missing skills directory: %s\n' "$skills_dir" >&2
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

printf 'Validated %d skills and OpenCode discovery.\n' "${#expected[@]}"
