#!/usr/bin/env bash
set -euo pipefail

# install.sh — Install agent-workflow skills into a target project
#
# Usage:
#   ./install.sh --platform claude-code                              # local (from build/)
#   curl -sL https://raw.githubusercontent.com/niraiarin/agent-workflow/main/install.sh \
#     | sh -s -- --platform claude-code                              # remote (GitHub Releases)

VERSION=""
PLATFORM=""
PREFIX="."
GITHUB_REPO="niraiarin/agent-workflow"

# ---------- Helpers ----------

usage() {
  cat <<'USAGE'
Usage: install.sh --platform <name> [--version <tag>] [--prefix <path>]

Options:
  --platform <name>   (required) bob | claude-code | codex-cli | gemini-cli | vibe-local
  --version <tag>     GitHub Release tag (default: latest). Ignored in local mode.
  --prefix <path>     Installation target directory (default: .)

Modes:
  Local mode:   When build/ directory exists (e.g. inside a submodule), files are copied from it.
  Remote mode:  Otherwise, a tarball is downloaded from GitHub Releases.
USAGE
  exit 1
}

die() { echo "ERROR: $*" >&2; exit 1; }

# Detect if stdin is a terminal (interactive) or piped (curl | sh)
is_interactive() { [ -t 0 ]; }

# Prompt user for conflict resolution.
# $1 = description, $2 = allowed choices string
# Returns: s (skip), b (backup+overwrite), a (append, only for root config)
prompt_conflict() {
  local desc="$1" choices="$2" default="b"
  if ! is_interactive; then
    echo "$default"
    return
  fi
  echo ""
  echo "Conflict: $desc already exists."
  echo "  [s]kip  [b]ackup+overwrite${choices}"
  printf "  Choice [b]: "
  read -r choice </dev/tty
  choice="${choice:-b}"
  if [[ "$choices" == *"$choice"* || "$choice" == "s" || "$choice" == "b" ]]; then
    echo "$choice"
  else
    echo "$default"
  fi
}

backup_file() {
  local file="$1"
  local backup="${file}.bak.$(date +%Y%m%d%H%M%S)"
  cp -a "$file" "$backup"
  echo "  Backed up → $backup"
}

# ---------- Platform mapping (hardcoded, no config.json dependency) ----------

platform_skills_dir() {
  case "$1" in
    claude-code) echo ".claude/skills" ;;
    codex-cli)   echo ".codex/skills" ;;
    bob)         echo ".bob/commands" ;;
    gemini-cli)  echo ".gemini/commands" ;;
    vibe-local)  echo ".vibe-local/skills" ;;
    *)           die "Unknown platform: $1" ;;
  esac
}

platform_root_config() {
  case "$1" in
    claude-code) echo "CLAUDE.md" ;;
    codex-cli)   echo "AGENTS.md" ;;
    bob)         echo "AGENTS.md" ;;
    gemini-cli)  echo "GEMINI.md" ;;
    vibe-local)  echo "" ;;  # no root config
    *)           die "Unknown platform: $1" ;;
  esac
}

# The name of the root config file inside the build tarball/directory
build_root_config() {
  case "$1" in
    claude-code) echo "CLAUDE.md" ;;
    codex-cli)   echo "AGENTS.md" ;;
    bob)         echo "AGENTS.md" ;;
    gemini-cli)  echo "GEMINI.md" ;;
    vibe-local)  echo "" ;;
    *)           die "Unknown platform: $1" ;;
  esac
}

# The skills subdirectory name inside the build output
build_skills_subdir() {
  case "$1" in
    claude-code) echo "skills" ;;
    codex-cli)   echo "skills" ;;
    bob)         echo "commands" ;;
    gemini-cli)  echo "commands" ;;
    vibe-local)  echo "skills" ;;
    *)           die "Unknown platform: $1" ;;
  esac
}

# ---------- Argument parsing ----------

while [[ $# -gt 0 ]]; do
  case "$1" in
    --platform)  PLATFORM="$2"; shift 2 ;;
    --version)   VERSION="$2"; shift 2 ;;
    --prefix)    PREFIX="$2"; shift 2 ;;
    -h|--help)   usage ;;
    *)           die "Unknown option: $1" ;;
  esac
done

[[ -z "$PLATFORM" ]] && { echo "ERROR: --platform is required."; usage; }

# Validate platform
case "$PLATFORM" in
  bob|claude-code|codex-cli|gemini-cli|vibe-local) ;;
  *) die "Unsupported platform: $PLATFORM. Must be one of: bob, claude-code, codex-cli, gemini-cli, vibe-local" ;;
esac

# Resolve prefix to absolute path
PREFIX="$(cd "$PREFIX" 2>/dev/null && pwd)" || die "Directory does not exist: $PREFIX"

# ---------- Source resolution ----------

SCRIPT_DIR="$(cd "$(dirname "$0")" 2>/dev/null && pwd)" || SCRIPT_DIR=""
TMPDIR_CLEANUP=""
BUILD_SRC=""

if [[ -n "$SCRIPT_DIR" && -d "$SCRIPT_DIR/build/$PLATFORM" ]]; then
  # Local mode: build/ exists (submodule or cloned repo)
  MODE="local"
  BUILD_SRC="$SCRIPT_DIR/build/$PLATFORM"
  echo "Mode: local (using build/$PLATFORM)"

  # Determine version from git tag if available
  if [[ -z "$VERSION" ]]; then
    VERSION="$(cd "$SCRIPT_DIR" && git describe --tags --abbrev=0 2>/dev/null || echo "dev")"
  fi
else
  # Remote mode: download from GitHub Releases
  MODE="remote"
  echo "Mode: remote (downloading from GitHub Releases)"

  if [[ -z "$VERSION" || "$VERSION" == "latest" ]]; then
    VERSION="$(curl -sL "https://api.github.com/repos/$GITHUB_REPO/releases/latest" \
      | grep '"tag_name"' | head -1 | sed 's/.*"tag_name": *"//; s/".*//')" \
      || die "Failed to fetch latest release tag"
    [[ -z "$VERSION" ]] && die "No releases found. Create a GitHub Release first."
  fi

  TARBALL_URL="https://github.com/$GITHUB_REPO/releases/download/$VERSION/agent-workflow-${PLATFORM}-${VERSION}.tar.gz"
  TMPDIR_CLEANUP="$(mktemp -d)"
  BUILD_SRC="$TMPDIR_CLEANUP/$PLATFORM"

  echo "Downloading $TARBALL_URL ..."
  mkdir -p "$BUILD_SRC"
  curl -sL "$TARBALL_URL" | tar xz -C "$BUILD_SRC" --strip-components=1 \
    || die "Failed to download tarball. Check that release $VERSION exists and contains $PLATFORM."
fi

# ---------- Install ----------

SKILLS_TARGET="$PREFIX/$(platform_skills_dir "$PLATFORM")"
ROOT_CONFIG="$(platform_root_config "$PLATFORM")"
BUILD_SKILLS="$(build_skills_subdir "$PLATFORM")"
BUILD_ROOT_CFG="$(build_root_config "$PLATFORM")"
INSTALLED_FILES=()

echo ""
echo "Installing agent-workflow ($VERSION) for $PLATFORM"
echo "  Target: $PREFIX"
echo ""

# 1. Skills directory
if [[ -d "$BUILD_SRC/$BUILD_SKILLS" ]]; then
  if [[ -d "$SKILLS_TARGET" ]]; then
    choice="$(prompt_conflict "$SKILLS_TARGET" "")"
    case "$choice" in
      s) echo "  Skipped skills directory." ;;
      *)
        backup_file "$SKILLS_TARGET"
        rm -rf "$SKILLS_TARGET"
        mkdir -p "$(dirname "$SKILLS_TARGET")"
        cp -r "$BUILD_SRC/$BUILD_SKILLS" "$SKILLS_TARGET"
        INSTALLED_FILES+=("$SKILLS_TARGET/")
        ;;
    esac
  else
    mkdir -p "$(dirname "$SKILLS_TARGET")"
    cp -r "$BUILD_SRC/$BUILD_SKILLS" "$SKILLS_TARGET"
    INSTALLED_FILES+=("$SKILLS_TARGET/")
  fi
fi

# 2. Root config file
if [[ -n "$ROOT_CONFIG" && -f "$BUILD_SRC/$BUILD_ROOT_CFG" ]]; then
  TARGET_CFG="$PREFIX/$ROOT_CONFIG"
  if [[ -f "$TARGET_CFG" ]]; then
    choice="$(prompt_conflict "$TARGET_CFG" "  [a]ppend")"
    case "$choice" in
      s) echo "  Skipped $ROOT_CONFIG." ;;
      a)
        echo "" >> "$TARGET_CFG"
        cat "$BUILD_SRC/$BUILD_ROOT_CFG" >> "$TARGET_CFG"
        echo "  Appended to $ROOT_CONFIG."
        INSTALLED_FILES+=("$TARGET_CFG (appended)")
        ;;
      *)
        backup_file "$TARGET_CFG"
        cp "$BUILD_SRC/$BUILD_ROOT_CFG" "$TARGET_CFG"
        INSTALLED_FILES+=("$TARGET_CFG")
        ;;
    esac
  else
    cp "$BUILD_SRC/$BUILD_ROOT_CFG" "$TARGET_CFG"
    INSTALLED_FILES+=("$TARGET_CFG")
  fi
fi

# 3. Create .agents/ directory (convention for issue tracking)
if [[ ! -d "$PREFIX/.agents" ]]; then
  mkdir -p "$PREFIX/.agents"
  INSTALLED_FILES+=("$PREFIX/.agents/")
fi

# 4. Record version
echo "$VERSION" > "$PREFIX/.agent-workflow-version"
INSTALLED_FILES+=("$PREFIX/.agent-workflow-version")

# ---------- Cleanup ----------

if [[ -n "$TMPDIR_CLEANUP" ]]; then
  rm -rf "$TMPDIR_CLEANUP"
fi

# ---------- Summary ----------

echo ""
echo "=== Installation complete ==="
echo ""
echo "Platform:  $PLATFORM"
echo "Version:   $VERSION"
echo "Target:    $PREFIX"
echo ""
echo "Installed files:"
for f in "${INSTALLED_FILES[@]}"; do
  echo "  $f"
done
echo ""
echo "Next steps:"
ROOT_CFG_NAME="$(platform_root_config "$PLATFORM")"
if [[ -n "$ROOT_CFG_NAME" ]]; then
  echo "  1. Edit $ROOT_CFG_NAME to add project-specific rules"
else
  echo "  1. Add project-specific rules to your agent config"
fi
echo "  2. Run: /wf-01-define-gates <issue-identifier>"
echo ""
