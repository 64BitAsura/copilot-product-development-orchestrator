#!/usr/bin/env bash
# export-orchestrator.sh
#
# Export the Copilot product-development orchestrator into any GitHub repository
# and open a pull request there.
#
# USAGE
#   ./export-orchestrator.sh <target_repo> [branch] [--include-docs]
#
# ARGUMENTS
#   target_repo     Target repository in "owner/repo" format  (required)
#   branch          Branch to create in the target repo       (default: add-copilot-orchestrator)
#   --include-docs  Also copy the docs/knowledge/ skeleton    (optional flag)
#
# PREREQUISITES
#   - git
#   - gh  (GitHub CLI, already authenticated: `gh auth login`)
#   The authenticated user (or token) must have push access to <target_repo>.
#
# EXAMPLE
#   ./export-orchestrator.sh myorg/myproject
#   ./export-orchestrator.sh myorg/myproject my-branch --include-docs

set -euo pipefail

# ── helpers ──────────────────────────────────────────────────────────────────

usage() {
  sed -n '/^# USAGE/,/^$/p' "$0" | grep -v '^#!' | sed 's/^# \{0,2\}//'
  exit 1
}

info()  { echo "[info]  $*"; }
ok()    { echo "[ok]    $*"; }
err()   { echo "[error] $*" >&2; exit 1; }

# ── argument parsing ─────────────────────────────────────────────────────────

TARGET_REPO="${1:-}"
BRANCH="${2:-add-copilot-orchestrator}"
INCLUDE_DOCS=false

# Support --include-docs in any position after the first argument
for arg in "${@:2}"; do
  case "$arg" in
    --include-docs) INCLUDE_DOCS=true ;;
    --*) err "Unknown flag: $arg" ;;
  esac
done

[ -z "$TARGET_REPO" ] && usage

# ── locate the orchestrator source ──────────────────────────────────────────

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTS_SRC="$SCRIPT_DIR/.github/agents"
SCRIPTS_SRC="$SCRIPT_DIR/.github/scripts"
SETUP_SRC="$SCRIPT_DIR/.github/workflows/copilot-setup-steps.yml"
DOCS_SRC="$SCRIPT_DIR/docs/knowledge"

[ -d "$AGENTS_SRC" ]   || err "Agent folder not found: $AGENTS_SRC"
[ -d "$SCRIPTS_SRC" ]  || err "Scripts folder not found: $SCRIPTS_SRC"
[ -f "$SETUP_SRC" ]    || err "Setup workflow not found: $SETUP_SRC"
if $INCLUDE_DOCS; then
  [ -d "$DOCS_SRC" ]   || err "docs/knowledge folder not found: $DOCS_SRC"
fi

# ── derive source repo / sha (best-effort, used in commit message) ──────────

SOURCE_REPO=$(git -C "$SCRIPT_DIR" remote get-url origin 2>/dev/null \
  | sed 's|.*github\.com[:/]\(.*\)\.git|\1|;s|.*github\.com[:/]\(.*\)|\1|' \
  || echo "unknown")
SOURCE_SHA=$(git -C "$SCRIPT_DIR" rev-parse --short HEAD 2>/dev/null || echo "unknown")

# ── clone target repo into a temp directory ──────────────────────────────────

WORK_DIR=$(mktemp -d)
trap 'rm -rf "$WORK_DIR"' EXIT

info "Cloning $TARGET_REPO …"
gh repo clone "$TARGET_REPO" "$WORK_DIR/target" -- --depth=1 --no-single-branch

cd "$WORK_DIR/target"

git config user.name  "$(git config --global user.name  2>/dev/null || echo 'export-orchestrator')"
git config user.email "$(git config --global user.email 2>/dev/null || echo 'export-orchestrator@localhost')"

# ── create or reset the export branch ────────────────────────────────────────

if git ls-remote --exit-code --heads origin "$BRANCH" &>/dev/null; then
  info "Branch '$BRANCH' already exists remotely — checking it out."
  git checkout "$BRANCH"
else
  info "Creating branch '$BRANCH'."
  git checkout -b "$BRANCH"
fi

# ── copy files ────────────────────────────────────────────────────────────────

info "Copying agent definitions …"
mkdir -p .github/agents
cp "$AGENTS_SRC"/*.agent.md .github/agents/

info "Copying helper scripts …"
mkdir -p .github/scripts
cp "$SCRIPTS_SRC"/* .github/scripts/

info "Copying copilot-setup-steps.yml …"
mkdir -p .github/workflows
cp "$SETUP_SRC" .github/workflows/copilot-setup-steps.yml

if $INCLUDE_DOCS; then
  info "Copying docs/knowledge skeleton …"
  mkdir -p docs
  cp -r "$DOCS_SRC" docs/knowledge
fi

# ── commit and push ───────────────────────────────────────────────────────────

git add .

if git diff --cached --quiet; then
  ok "Nothing to commit — target repo is already up to date."
else
  DOCS_LINE=""
  $INCLUDE_DOCS && DOCS_LINE=$'\n          - docs/knowledge/ — knowledge harness skeleton'

  git commit -m "feat: add Copilot product-development orchestrator

Exported from https://github.com/${SOURCE_REPO} @ ${SOURCE_SHA}

Includes:
- .github/agents/ — all 17 custom agent definitions
- .github/scripts/ — helper scripts including CRAP tool setup
- .github/workflows/copilot-setup-steps.yml — Copilot environment setup${DOCS_LINE}"

  info "Pushing branch '$BRANCH' to $TARGET_REPO …"
  git push origin "$BRANCH"
  ok "Branch pushed."
fi

# ── open pull request ─────────────────────────────────────────────────────────

DEFAULT_BRANCH=$(gh repo view "$TARGET_REPO" --json defaultBranchRef --jq '.defaultBranchRef.name')

DOCS_ROW=""
$INCLUDE_DOCS && DOCS_ROW=$'\n| `docs/knowledge/` | Knowledge harness skeleton — fill in with your product details |'

PR_BODY="## What is this?

This PR adds the **Copilot Product-Development Orchestrator** — a multi-agent pipeline that transforms a GitHub issue into production-ready code.

Exported from [\`${SOURCE_REPO}\`](https://github.com/${SOURCE_REPO}) at commit \`${SOURCE_SHA}\`.

## What's included

| Path | Purpose |
|------|---------|
| \`.github/agents/\` | 17 custom agent definitions (bootstrap, orchestrator, refinement, design, planning, performance, security, coding, linting, tester, review, documentation, build, local-deployment, e2e, design-review, back-tracker) |
| \`.github/scripts/\` | Helper scripts including CRAP tool setup and the portable \`crap-tool\` CLI |
| \`.github/workflows/copilot-setup-steps.yml\` | Installs all agent dependencies (Node.js, Python, Playwright, Docker, GitHub CLI) |${DOCS_ROW}

## Next steps

1. Merge this PR.
2. Fill in \`docs/knowledge/\` with your product details (vision, features, tech stack, schema, etc.).
3. Open a GitHub issue, assign it to Copilot, and select the **\`orchestrator\`** agent.

> See the [full setup guide](https://github.com/${SOURCE_REPO}#quick-start) for details."

info "Opening pull request in $TARGET_REPO …"
if gh pr create \
  --repo "$TARGET_REPO" \
  --head "$BRANCH" \
  --base "$DEFAULT_BRANCH" \
  --title "feat: add Copilot product-development orchestrator" \
  --body "$PR_BODY"; then
  ok "Pull request created."
else
  ok "PR creation skipped — a pull request for this branch may already exist."
fi
