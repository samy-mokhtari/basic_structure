#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "[1/5] Backend: create venv + install tools"
python -m venv "$ROOT/backend/.venv"

# Cross-platform venv python path
if [ -f "$ROOT/backend/.venv/Scripts/python.exe" ]; then
    PY="$ROOT/backend/.venv/Scripts/python.exe"
else
    PY="$ROOT/backend/.venv/bin/python"
fi

"$PY" -m pip install -U pip
"$PY" -m pip install -U pre-commit ruff pytest

echo "[2/5] Frontend: install node dependencies (if package.json exists)"
if [ -f "$ROOT/frontend/package.json" ]; then
    (cd "$ROOT/frontend" && npm install)
else
    echo "  - Skipped: frontend/package.json not found"
fi

echo "[3/5] pre-commit: migrate config (safe) + install hooks"
"$PY" -m pre_commit migrate-config || true
"$PY" -m pre_commit install
"$PY" -m pre_commit install --hook-type pre-push

echo "[4/5] pre-commit: initial run (optional but useful)"
"$PY" -m pre_commit run --all-files || true
"$PY" -m pre_commit run --hook-stage pre-push --all-files || true

echo "[5/5] Done."
echo "Next: commit your changes; hooks will run automatically on commit/push."
