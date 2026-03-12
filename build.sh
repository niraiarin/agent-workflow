#!/usr/bin/env bash
set -euo pipefail

# Build platform-specific skill distributions from the canonical source (.claude/skills/)
#
# Usage: ./build.sh [platform...]
#   ./build.sh              # build all platforms
#   ./build.sh claude-code  # build only claude-code
#   ./build.sh bob gemini-cli  # build specific platforms

REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$REPO_ROOT/.claude/skills"
BUILD_DIR="$REPO_ROOT/build"
PLATFORMS_DIR="$REPO_ROOT/platforms"

ALL_PLATFORMS=(bob claude-code codex-cli gemini-cli vibe-local)
PLATFORMS=("${@:-${ALL_PLATFORMS[@]}}")

# Get description from SKILL.md (YAML frontmatter or inline "Description:" line)
get_description() {
  local skill_md="$1"
  # Try YAML frontmatter first
  local desc
  desc=$(sed -n '/^---$/,/^---$/p' "$skill_md" | grep '^description:' | sed 's/^description: *//; s/^"//; s/"$//')
  if [[ -n "$desc" ]]; then
    echo "$desc"
    return
  fi
  # Fallback: inline "Description: ..." line
  grep -m1 '^Description:' "$skill_md" | sed 's/^Description: *//' || echo ""
}

# Check if file has YAML frontmatter (starts with ---)
has_frontmatter() {
  [[ "$(head -1 "$1")" == "---" ]]
}

# Get skill body (everything after YAML frontmatter, or full content for non-frontmatter files)
get_body() {
  local skill_md="$1"
  if has_frontmatter "$skill_md"; then
    awk 'BEGIN{n=0} /^---$/{n++; next} n>=2{print}' "$skill_md"
  else
    cat "$skill_md"
  fi
}

# Strip subagent blocks (```...Task tool:...``` or similar multi-line code blocks with subagent content)
strip_subagent_blocks() {
  awk '
    /^\*\*For complex verification strategies\*\*/ { skip=1; next }
    skip && /^```$/ { count++ }
    skip && count>=2 { skip=0; count=0; next }
    skip { next }
    { print }
  '
}

# Convert subagent syntax from claude-code to bob XML format
convert_subagent_xml() {
  sed \
    -e 's/^Task tool:/<new_task>/' \
    -e 's/^  subagent_type: "Explore"/<mode>Advanced<\/mode>/' \
    -e 's/^  prompt: |/<message>/' \
    -e '/^```$/{ N; s/^```\n$/<\/message>\n<\/new_task>/; }'
}

# Wrap content in TOML format for Gemini
wrap_toml() {
  local description="$1"
  local body="$2"
  printf 'description = "%s"\n\nprompt = """\n%s\n"""\n' "$description" "$body"
}

# Build a single platform
build_platform() {
  local platform="$1"
  local config="$PLATFORMS_DIR/$platform/config.json"

  if [[ ! -f "$config" ]]; then
    echo "SKIP: No config.json for $platform"
    return
  fi

  local format skills_dir file_ext
  format=$(python3 -c "import json; print(json.load(open('$config'))['format'])")
  skills_dir=$(python3 -c "import json; print(json.load(open('$config'))['skills_dir'])")
  file_ext=$(python3 -c "import json; print(json.load(open('$config'))['file_extension'])")

  local exclude_skills
  exclude_skills=$(python3 -c "import json; print(' '.join(json.load(open('$config')).get('exclude_skills', [])))")

  local static_files
  static_files=$(python3 -c "import json; print(' '.join(json.load(open('$config')).get('static_files', [])))")

  local platform_build="$BUILD_DIR/$platform"
  rm -rf "$platform_build"
  mkdir -p "$platform_build/$skills_dir"

  # Copy static files
  for sf in $static_files; do
    if [[ -f "$PLATFORMS_DIR/$platform/$sf" ]]; then
      cp "$PLATFORMS_DIR/$platform/$sf" "$platform_build/$sf"
    fi
  done

  # Handle override format (vibe-local: use pre-authored files directly)
  if [[ "$format" == "override" ]]; then
    local override_src
    override_src=$(python3 -c "import json; print(json.load(open('$config')).get('override_source', ''))")
    if [[ -n "$override_src" && -d "$REPO_ROOT/$override_src" ]]; then
      cp "$REPO_ROOT/$override_src"/* "$platform_build/$skills_dir/"
    fi
    echo "OK: $platform (override)"
    return
  fi

  # Process each source skill
  for skill_dir in "$SOURCE_DIR"/wf-*/; do
    local skill_name
    skill_name=$(basename "$skill_dir")
    local skill_md="$skill_dir/SKILL.md"

    [[ ! -f "$skill_md" ]] && continue

    # Check exclusions
    if echo "$exclude_skills" | grep -qw "$skill_name"; then
      continue
    fi

    local description body
    description=$(get_description "$skill_md")
    body=$(get_body "$skill_md")

    case "$format" in
      subdir-skill)
        # Claude Code / Codex CLI: skill-name/SKILL.md
        local strip
        strip=$(python3 -c "import json; print(json.load(open('$config')).get('strip_subagent_blocks', False))")
        mkdir -p "$platform_build/$skills_dir/$skill_name"
        if [[ "$strip" == "True" ]]; then
          {
            echo "---"
            echo "description: \"$description\""
            echo "---"
            echo ""
            echo "$body" | strip_subagent_blocks
          } > "$platform_build/$skills_dir/$skill_name/$file_ext"
        else
          cp "$skill_md" "$platform_build/$skills_dir/$skill_name/$file_ext"
        fi
        ;;

      flat-md)
        # Bob: flat commands/skill-name.md with argument-hint
        local arg_hint
        arg_hint=$(python3 -c "import json; print(json.load(open('$config')).get('frontmatter_extras', {}).get('argument-hint', ''))")
        {
          echo "---"
          echo "description: \"$description\""
          [[ -n "$arg_hint" ]] && echo "argument-hint: $arg_hint"
          echo "---"
          echo ""
          echo "$body"
        } > "$platform_build/$skills_dir/${skill_name}${file_ext}"
        ;;

      toml)
        # Gemini: commands/skill-name.toml
        local clean_body
        clean_body=$(echo "$body" | strip_subagent_blocks)
        wrap_toml "$description" "$clean_body" > "$platform_build/$skills_dir/${skill_name}${file_ext}"
        ;;
    esac
  done

  echo "OK: $platform"
}

echo "Building platform distributions..."
echo "Source: $SOURCE_DIR"
echo "Output: $BUILD_DIR"
echo ""

for platform in "${PLATFORMS[@]}"; do
  build_platform "$platform"
done

echo ""
echo "Build complete."
