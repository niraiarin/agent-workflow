#!/usr/bin/env bash
set -euo pipefail

# install-submodule.sh — Build & install agent-workflow from a submodule
#
# Intended to be run from the parent project:
#   ./agent-workflow/install-submodule.sh --platform claude-code
#
# This script:
#   1. Runs build.sh to regenerate build/ from the latest source skills
#   2. Delegates to install.sh to copy built files into the parent project

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

usage() {
  cat <<'USAGE'
Usage: install-submodule.sh --platform <name> [options]

Builds platform files from source and installs them into the parent project.

Options:
  --platform <name>   (required) bob | claude-code | codex-cli | gemini-cli | vibe-local
  --version <tag>     Version string to record (default: git tag or "dev")
  --prefix <path>     Installation target directory (default: parent of this submodule)
  --skip-build        Skip build.sh and use existing build/ output
  -h, --help          Show this help

Examples:
  ./agent-workflow/install-submodule.sh --platform claude-code
  ./agent-workflow/install-submodule.sh --platform bob --prefix /path/to/project
USAGE
  exit 1
}

die() { echo "ERROR: $*" >&2; exit 1; }

# ---------- Argument parsing ----------

PLATFORM=""
VERSION=""
PREFIX=""
SKIP_BUILD=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --platform)     PLATFORM="$2"; shift 2 ;;
    --version)      VERSION="$2"; shift 2 ;;
    --prefix)       PREFIX="$2"; shift 2 ;;
    --skip-build)   SKIP_BUILD=true; shift ;;
    -h|--help)      usage ;;
    *)              die "Unknown option: $1" ;;
  esac
done

[[ -z "$PLATFORM" ]] && { echo "ERROR: --platform is required."; usage; }

# Default prefix: parent directory of the submodule
if [[ -z "$PREFIX" ]]; then
  PREFIX="$(cd "$SCRIPT_DIR/.." && pwd)"
fi

# ---------- Validate ----------

[[ -f "$SCRIPT_DIR/build.sh" ]] || die "build.sh not found in $SCRIPT_DIR. Is this the agent-workflow repo?"
[[ -f "$SCRIPT_DIR/install.sh" ]] || die "install.sh not found in $SCRIPT_DIR."

# ---------- Build ----------

if [[ "$SKIP_BUILD" == false ]]; then
  echo "=== Building platform: $PLATFORM ==="
  echo ""
  (cd "$SCRIPT_DIR" && bash build.sh "$PLATFORM")
  echo ""
else
  echo "=== Skipping build (--skip-build) ==="
  [[ -d "$SCRIPT_DIR/build/$PLATFORM" ]] || die "build/$PLATFORM does not exist. Run without --skip-build first."
fi

# ---------- Install ----------

echo "=== Installing to $PREFIX ==="
echo ""
INSTALL_ARGS=(--platform "$PLATFORM" --prefix "$PREFIX")
[[ -n "$VERSION" ]] && INSTALL_ARGS+=(--version "$VERSION")
bash "$SCRIPT_DIR/install.sh" "${INSTALL_ARGS[@]}"
