#!/usr/bin/env bash
# install-orchestrator.sh
#
# Check out the Copilot product-development orchestrator and install its
# template files into the directory from which this script is run.
#
# USAGE
#   # Run directly from a clone of this repo:
#   ./install-orchestrator.sh [--include-docs]
#
#   # Or pipe straight from GitHub (no prior clone needed):
#   curl -fsSL https://raw.githubusercontent.com/64BitAsura/copilot-product-development-orchestrator/main/install-orchestrator.sh | bash
#   curl -fsSL https://raw.githubusercontent.com/64BitAsura/copilot-product-development-orchestrator/main/install-orchestrator.sh | bash -s -- --include-docs
#
# ARGUMENTS
#   --include-docs  Also copy the docs/knowledge/ skeleton    (optional flag)
#
# PREREQUISITES
#   - git
#
# WHAT GETS INSTALLED
#   .github/agents/                          — all 17 custom agent definitions
#   .github/scripts/                         — shared helper scripts (including CRAP tool setup)
#   .github/workflows/copilot-setup-steps.yml — Copilot environment setup
#   docs/knowledge/                          — knowledge harness skeleton (--include-docs only)
#
# EXAMPLE
#   cd ~/projects/myapp
#   curl -fsSL https://raw.githubusercontent.com/64BitAsura/copilot-product-development-orchestrator/main/install-orchestrator.sh | bash

set -euo pipefail

# ── constants ─────────────────────────────────────────────────────────────────

ORCHESTRATOR_REPO="64BitAsura/copilot-product-development-orchestrator"
ORCHESTRATOR_URL="https://github.com/${ORCHESTRATOR_REPO}.git"

# ── helpers ───────────────────────────────────────────────────────────────────

info() { echo "[info]  $*"; }
ok()   { echo "[ok]    $*"; }
err()  { echo "[error] $*" >&2; exit 1; }

# ── argument parsing ──────────────────────────────────────────────────────────

INCLUDE_DOCS=false

for arg in "$@"; do
  case "$arg" in
    --include-docs) INCLUDE_DOCS=true ;;
    --*) err "Unknown flag: $arg" ;;
  esac
done

# ── prerequisites ─────────────────────────────────────────────────────────────

command -v git >/dev/null 2>&1 || err "git is required but not found on PATH."

# ── clone orchestrator into a temp directory ──────────────────────────────────

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

info "Checking out ${ORCHESTRATOR_REPO} …"
git clone --depth=1 --quiet "$ORCHESTRATOR_URL" "$WORK_DIR/src"

SRC="$WORK_DIR/src"
AGENTS_SRC="$SRC/.github/agents"
SCRIPTS_SRC="$SRC/.github/scripts"
SETUP_SRC="$SRC/.github/workflows/copilot-setup-steps.yml"
DOCS_SRC="$SRC/docs/knowledge"

[ -d "$AGENTS_SRC" ] || err "Agent folder not found in cloned repo: $AGENTS_SRC"
[ -d "$SCRIPTS_SRC" ] || err "Scripts folder not found in cloned repo: $SCRIPTS_SRC"
[ -f "$SETUP_SRC"  ] || err "Setup workflow not found in cloned repo: $SETUP_SRC"
if $INCLUDE_DOCS; then
  [ -d "$DOCS_SRC" ] || err "docs/knowledge not found in cloned repo: $DOCS_SRC"
fi

# ── install into the current working directory ────────────────────────────────

DEST_DIR="$(pwd)"

info "Installing agent definitions into ${DEST_DIR}/.github/agents/ …"
mkdir -p "$DEST_DIR/.github/agents"
cp "$AGENTS_SRC"/*.agent.md "$DEST_DIR/.github/agents/"

info "Installing helper scripts into ${DEST_DIR}/.github/scripts/ …"
mkdir -p "$DEST_DIR/.github/scripts"
cp "$SCRIPTS_SRC"/* "$DEST_DIR/.github/scripts/"

info "Installing copilot-setup-steps.yml into ${DEST_DIR}/.github/workflows/ …"
mkdir -p "$DEST_DIR/.github/workflows"
cp "$SETUP_SRC" "$DEST_DIR/.github/workflows/copilot-setup-steps.yml"

if $INCLUDE_DOCS; then
  info "Installing docs/knowledge skeleton into ${DEST_DIR}/docs/knowledge/ …"
  mkdir -p "$DEST_DIR/docs"
  cp -r "$DOCS_SRC" "$DEST_DIR/docs/knowledge"
fi

# ── done ──────────────────────────────────────────────────────────────────────

ok "Orchestrator installed into: ${DEST_DIR}"
echo ""
echo "Next steps:"
echo "  1. Review the files under .github/agents/ and .github/workflows/."
if $INCLUDE_DOCS; then
  echo "  2. Fill in docs/knowledge/ with your product details (vision, tech stack, schema, etc.)."
  echo "  3. Open a GitHub issue, assign it to Copilot, and select the 'orchestrator' agent."
else
  echo "  2. Open a GitHub issue, assign it to Copilot, and select the 'orchestrator' agent."
  echo "  Tip: Re-run with --include-docs to also install the knowledge harness skeleton."
fi
echo ""
echo "  See https://github.com/${ORCHESTRATOR_REPO}#quick-start for the full setup guide."
