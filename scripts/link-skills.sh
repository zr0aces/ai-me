#!/usr/bin/env bash
# Links all skills from ~/.ai-me/skills/ into each AI tool's skills directory.
# Tools: Claude, Gemini, Copilot
# Usage: ./link-skills.sh [--dry-run] [--unlink|--clean]

set -euo pipefail

SKILLS_SRC="$HOME/.ai-me/skills"
DRY_RUN=false
UNLINK=false
CLEAN=false

for arg in "$@"; do
  case "$arg" in
    --dry-run) DRY_RUN=true ;;
    --unlink)  UNLINK=true  ;;
    --clean)   CLEAN=true   ;;
    --help)
      echo "Usage: link-skills.sh [--dry-run] [--unlink|--clean]"
      echo "  --dry-run  Show what would be done without making changes"
      echo "  --unlink   Remove symlinks for skills that still exist in $SKILLS_SRC"
      echo "  --clean    Remove EVERY managed symlink, including ones whose source"
      echo "             skill was deleted (--unlink can't see those). Run this"
      echo "             before a plain relink to guarantee no stale links remain:"
      echo "               link-skills.sh --clean && link-skills.sh"
      exit 0 ;;
  esac
done

if $UNLINK && $CLEAN; then
  echo "[link-skills] --unlink and --clean are mutually exclusive" >&2
  exit 1
fi

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

if $CLEAN; then
  for target_dir in "${TARGETS[@]}"; do
    tool=$(basename "$(dirname "$target_dir")" | sed 's/^\.//')
    log "── $tool → $target_dir"

    [ -d "$target_dir" ] || { skip "$target_dir does not exist"; echo; continue; }

    for link in "$target_dir"/*; do
      [ -L "$link" ] || continue
      link_name=$(basename "$link")
      # resolve() falls back to the raw readlink target for broken/relative
      # symlinks that `realpath -e` would otherwise refuse to resolve.
      resolved=$(realpath -e "$link" 2>/dev/null || readlink "$link")
      case "$resolved" in
        "$SKILLS_SRC"/*)
          if $DRY_RUN; then
            drylog "would remove $link_name"
          else
            rm "$link"
            ok "removed $link_name"
            ((removed++)) || true
          fi
          ;;
        *)
          skip "$link_name (not a managed symlink, skipping)"
          ((skipped++)) || true
          ;;
      esac
    done
    echo
  done

  log "clean done — removed: $removed, skipped: $skipped"
  exit 0
fi

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
