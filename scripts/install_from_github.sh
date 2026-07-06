#!/usr/bin/env bash

set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/ujvu/monthly-assessment-skill.git}"
BRANCH="${BRANCH:-main}"
INSTALL_DIR="${INSTALL_DIR:-$HOME/.hermes/skills/productivity/monthly-assessment}"
LINK_AGENTS_SKILL="${LINK_AGENTS_SKILL:-0}"
CHECK_COMPANION_SKILLS="${CHECK_COMPANION_SKILLS:-1}"

log() {
  printf '%s\n' "$*"
}

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    log "缺少依赖: $1"
    exit 1
  fi
}

need_cmd git

check_skill() {
  local label="$1"
  local path="$2"
  if [[ -f "$path" ]]; then
    log "已检测到辅助技能: $label -> $path"
  else
    log "未检测到辅助技能: $label -> $path"
  fi
}

PARENT_DIR="$(dirname "$INSTALL_DIR")"
mkdir -p "$PARENT_DIR"

if [[ -d "$INSTALL_DIR/.git" ]]; then
  log "检测到已有 Git 仓库，开始更新: $INSTALL_DIR"
  git -C "$INSTALL_DIR" fetch origin "$BRANCH"
  git -C "$INSTALL_DIR" checkout "$BRANCH"
  git -C "$INSTALL_DIR" reset --hard "origin/$BRANCH"
elif [[ -e "$INSTALL_DIR" ]]; then
  BACKUP_DIR="${INSTALL_DIR}.bak.$(date +%Y%m%d%H%M%S)"
  log "检测到同名目录但不是 Git 仓库，备份到: $BACKUP_DIR"
  mv "$INSTALL_DIR" "$BACKUP_DIR"
  log "开始克隆: $REPO_URL"
  git clone --branch "$BRANCH" "$REPO_URL" "$INSTALL_DIR"
else
  log "开始克隆: $REPO_URL"
  git clone --branch "$BRANCH" "$REPO_URL" "$INSTALL_DIR"
fi

test -f "$INSTALL_DIR/SKILL.md"
test -f "$INSTALL_DIR/README.md"
test -f "$INSTALL_DIR/references/月考核作业.md"
test -f "$INSTALL_DIR/scripts/gen_batch.py"
test -f "$INSTALL_DIR/scripts/append_motion_table.sh"
chmod +x "$INSTALL_DIR/scripts/"*.sh || true

if [[ "$LINK_AGENTS_SKILL" == "1" ]]; then
  mkdir -p "$HOME/.agents/skills/monthly-assessment"
  ln -sfn "$INSTALL_DIR/SKILL.md" "$HOME/.agents/skills/monthly-assessment/SKILL.md"
  log "已建立 ~/.agents/skills/monthly-assessment/SKILL.md 软链接"
fi

if [[ "$CHECK_COMPANION_SKILLS" == "1" ]]; then
  check_skill "officecli" "$HOME/.hermes/skills/officecli/SKILL.md"
  check_skill "officecli-recipes" "$HOME/.hermes/skills/productivity/officecli-recipes/SKILL.md"
  check_skill "document-processing" "$HOME/.hermes/skills/document/document-processing/SKILL.md"
  check_skill "pdf-tools" "$HOME/.hermes/skills/productivity/pdf-tools/SKILL.md"
fi

log "安装完成: $INSTALL_DIR"
log "可读取入口: $INSTALL_DIR/SKILL.md"
