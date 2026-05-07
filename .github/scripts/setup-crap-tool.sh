#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="${GITHUB_WORKSPACE:-$(pwd)}"
BIN_DIR="${HOME}/.local/bin"
SCRIPT_PATH="${REPO_ROOT}/.github/scripts/crap_tool.py"
CONFIG_PATH="${REPO_ROOT}/.copilot/crap/config.json"

mkdir -p "${BIN_DIR}"
cp "${SCRIPT_PATH}" "${BIN_DIR}/crap-tool"
chmod +x "${BIN_DIR}/crap-tool"
export PATH="${BIN_DIR}:${PATH}"

python3 "${SCRIPT_PATH}" setup --repo-root "${REPO_ROOT}" --output "${CONFIG_PATH}" >/dev/null
echo "CRAP tool configured at ${CONFIG_PATH}"
