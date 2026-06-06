#!/usr/bin/env bash
set -euo pipefail

# Vibe Code Game Studios Kit installer
# Clean install with backup for both new and existing projects.
# Installs the specialized game development agents, rules, and skills.

REPO="https://github.com/fanioz/Vibe-Code-Game-Studios.git"
TMPDIR="/tmp/vc-temp-$$"
BACKUP_DIR=".vibecode-backup"
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

cleanup() { rm -rf "$TMPDIR" 2>/dev/null; }
trap cleanup EXIT

echo ""
echo "  Vibe Code Game Studios Kit installer"
echo "  ─────────────────────────────────"
echo ""

# Clone kit to temp
echo "  Fetching kit..."
git clone --depth 1 --quiet "$REPO" "$TMPDIR"

# ══════════════════════════════════════════════════════
# Backup existing setup (if any)
# ══════════════════════════════════════════════════════
HAS_EXISTING=false
if [ -d ".claude" ] || [ -f "CLAUDE.md" ] || [ -d "CCGS Skill Testing Framework" ] || [ -d "design" ] || [ -d "docs" ] || [ -d "production" ]; then
  HAS_EXISTING=true
  echo -e "  ${YELLOW}Existing setup detected.${NC} Backing up..."
  mkdir -p "$BACKUP_DIR"

  # Back up specific config files to preserve user settings within .claude
  if [ -f ".claude/settings.json" ]; then
    mkdir -p "$BACKUP_DIR/user-config"
    cp ".claude/settings.json" "$BACKUP_DIR/user-config/settings.json"
    echo -e "    ${YELLOW}Backed up${NC} user settings.json"
  fi

  # Back up directories
  [ -d ".claude" ] && cp -R .claude "$BACKUP_DIR/.claude" && echo -e "    ${YELLOW}Backed up${NC} .claude/"
  
  # Back up root files
  [ -f "CLAUDE.md" ] && cp CLAUDE.md "$BACKUP_DIR/CLAUDE.md" && echo -e "    ${YELLOW}Backed up${NC} CLAUDE.md"
  [ -f "CONTRIBUTING.md" ] && cp CONTRIBUTING.md "$BACKUP_DIR/CONTRIBUTING.md"
  [ -f "README.md" ] && cp README.md "$BACKUP_DIR/README.md"
  [ -f "SECURITY.md" ] && cp SECURITY.md "$BACKUP_DIR/SECURITY.md"
  [ -f "UPGRADING.md" ] && cp UPGRADING.md "$BACKUP_DIR/UPGRADING.md"
  
  # Back up CCGS framework and docs
  [ -d "CCGS Skill Testing Framework" ] && cp -R "CCGS Skill Testing Framework" "$BACKUP_DIR/CCGS Skill Testing Framework"
  [ -d "design" ] && cp -R design "$BACKUP_DIR/design"
  [ -d "docs" ] && cp -R docs "$BACKUP_DIR/docs"
  [ -d "production" ] && cp -R production "$BACKUP_DIR/production"
  [ -d "src" ] && cp -R src "$BACKUP_DIR/src"

  echo -e "    Backup at: ${CYAN}$BACKUP_DIR/${NC}"
  echo ""
  
  # Clean slate for main kit directories to ensure clean install, 
  # but be careful not to delete user source code if this is an active project
  rm -rf .claude "CCGS Skill Testing Framework" design docs production
  [ -f "CLAUDE.md" ] && rm CLAUDE.md
fi

# ══════════════════════════════════════════════════════
# Install kit — direct copy
# ══════════════════════════════════════════════════════
echo "  Installing Game Studio kit files..."

# Copy dotfiles and directories (excluding .git)
# Using tar to copy everything excluding .git to handle hidden files well
(cd "$TMPDIR" && tar cf - --exclude='*.git*' .) | tar xf -

# Restore user settings if they existed
if [ "$HAS_EXISTING" = true ] && [ -f "$BACKUP_DIR/user-config/settings.json" ]; then
    echo "  Restoring user settings.json..."
    mkdir -p .claude
    cp "$BACKUP_DIR/user-config/settings.json" .claude/settings.json
fi

# ══════════════════════════════════════════════════════
# Gemini CLI Compatibility
# ══════════════════════════════════════════════════════
echo "  Setting up Gemini compatibility symlinks..."
ln -sfn .claude .gemini
[ -f "CLAUDE.md" ] && ln -sf CLAUDE.md GEMINI.md

cleanup

# ══════════════════════════════════════════════════════
# Summary
# ══════════════════════════════════════════════════════
AGENT_COUNT=$(ls .claude/agents/*.md 2>/dev/null | wc -l | tr -d ' ')
SKILL_COUNT=$(ls -d .claude/skills/*/ 2>/dev/null | wc -l | tr -d ' ')

echo ""
echo -e "  ${GREEN}Install complete.${NC}"
echo ""
echo -e "    ${CYAN}Agents${NC}:     $AGENT_COUNT"
echo -e "    ${CYAN}Skills${NC}:     $SKILL_COUNT"

if [ "$HAS_EXISTING" = true ]; then
  echo ""
  echo -e "  ${YELLOW}Previous setup backed up to ${CYAN}$BACKUP_DIR/${NC}"
  echo -e "  ${YELLOW}Your user settings were preserved.${NC}"
fi

echo ""
echo "  Next:"
echo "    1. Run your chosen agent system"
echo ""
