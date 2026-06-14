#!/usr/bin/env bash
# Links all skills from ~/.ai-me/skills/ into each AI tool's skills directory.
# Tools: Claude, Gemini, Copilot
# Usage: ./link-skills.sh [--dry-run] [--unlink]

set -euo pipefail

SKILLS_SRC="$HOME/.ai-me/skills"
DRY_RUN=false
UNLINK=false

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --unlink)  UNLINK=true  ;;
    --help)
      echo "Usage: link-skills.sh [--dry-run] [--unlink]"
      echo "  --dry-run  Show what would be done without making changes"
      echo "  --unlink   Remove all managed symlinks instead of creating them"
      exit 0 ;;
  esac
done

TARGETS=(
  "$HOME/.claude/skills"
  "$HOME/.gemini/skills"
  "$HOME/.copilot/skills"
)

linked=0
skipped=0
removed=0
errors=0

log()    { echo "[link-skills] $*"; }
ok()     { echo "  ✓ $*"; }
skip()   { echo "  - $*"; }
err()    { echo "  ✗ $*" >&2; }
drylog() { echo "  ~ (dry-run) $*"; }

for target_dir in "${TARGETS[@]}"; do
  tool=$(basename "$(dirname "$target_dir")" | sed 's/^\.//')
  log "── $tool → $target_dir"

  if [ ! -d "$target_dir" ]; then
    if $DRY_RUN; then
      drylog "would create $target_dir"
    else
      mkdir -p "$target_dir"
      ok "created $target_dir"
    fi
  fi

  for skill_path in "$SKILLS_SRC"/*/; do
    [ -d "$skill_path" ] || continue
    skill_name=$(basename "$skill_path")
    skill_path="${skill_path%/}"  # strip trailing slash for consistent readlink comparison
    link="$target_dir/$skill_name"

    if $UNLINK; then
      if [ -L "$link" ] && [ "$(readlink "$link")" = "$skill_path" ]; then
        if $DRY_RUN; then
          drylog "would remove $link"
        else
          rm "$link"
          ok "removed $skill_name"
          ((removed++)) || true
        fi
      else
        skip "$skill_name (not a managed symlink, skipping)"
        ((skipped++)) || true
      fi
      continue
    fi

    # Already correctly linked
    if [ -L "$link" ] && [ "$(readlink "$link")" = "$skill_path" ]; then
      skip "$skill_name (already linked)"
      ((skipped++)) || true
      continue
    fi

    # Exists but wrong target or not a symlink
    if [ -e "$link" ] || [ -L "$link" ]; then
      err "$skill_name exists at $link but is not a managed symlink — skipping"
      ((errors++)) || true
      continue
    fi

    # Create symlink
    if $DRY_RUN; then
      drylog "would link $skill_name → $skill_path"
    else
      ln -s "$skill_path" "$link"
      ok "linked $skill_name"
      ((linked++)) || true
    fi
  done

  echo
done

log "done — linked: $linked, skipped: $skipped, errors: $errors$([ "$UNLINK" = true ] && echo ", removed: $removed" || true)"

if [ "$errors" -gt 0 ]; then
  exit 1
fi
