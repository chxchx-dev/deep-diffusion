#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
ERRORS=0

pass() { echo "OK: $*"; }
fail() { echo "FAIL: $*" >&2; ERRORS=$((ERRORS + 1)); }

required_files=(
  AGENTS.md
  CLAUDE.md
  docs/README.md
  docs/ARCHITECTURE.md
  docs/RULES.md
  docs/DECISIONS.md
  docs/RISKS.md
  docs/BACKLOG.md
  docs/SECURITY.md
  docs/DEVELOPMENT.md
  docs/ai/PROJECT_STATE.md
  docs/ai/DOCUMENTATION_MAP.md
  docs/archive/HISTORY.md
  workflows/FEATURE.md
  workflows/BUGFIX.md
  workflows/ARCHITECTURE_CHANGE.md
  workflows/SECURITY_REVIEW.md
  workflows/RELEASE.md
  workflows/DOCS_SYNC.md
  workflows/README.md
)

for path in "${required_files[@]}"; do
  if [[ -f "${ROOT_DIR}/${path}" ]]; then
    pass "archivo ${path}"
  else
    fail "falta ${path}"
  fi
done

for path in docs/ai/agents/architect.md docs/ai/agents/implementer.md \
  docs/ai/agents/debugger.md docs/ai/agents/reviewer.md \
  docs/ai/agents/security-reviewer.md; do
  if [[ -f "${ROOT_DIR}/${path}" ]]; then
    pass "rol ${path}"
  else
    fail "falta ${path}"
  fi
done

if [[ -x "${ROOT_DIR}/tools/verify-project.sh" ]]; then
  pass "doctor de proyecto ejecutable"
else
  fail "tools/verify-project.sh no es ejecutable"
fi

if python3 - "${ROOT_DIR}" <<'PY'
import re
import subprocess
import sys
from pathlib import Path

root = Path(sys.argv[1])
markdown = [
    path for path in root.rglob("*.md")
    if ".git" not in path.parts
    and "vendor" not in path.parts
    and "node_modules" not in path.parts
    and "dist" not in path.parts
    and "build" not in path.parts
]
errors = []
pattern = re.compile(r"\[[^\]]+\]\(([^)#]+)(?:#[^)]*)?\)")
for source in markdown:
    for target in pattern.findall(source.read_text(encoding="utf-8")):
        if target.startswith(("http://", "https://", "mailto:")):
            continue
        resolved = (source.parent / target).resolve()
        if not resolved.exists():
            errors.append(f"{source.relative_to(root)} -> {target}")
if errors:
    raise SystemExit("enlaces rotos:\n" + "\n".join(errors))

tracked = subprocess.run(
    ["git", "-C", str(root), "ls-files", "-z"],
    check=True,
    capture_output=True,
    text=False,
).stdout.decode().split("\0")
forbidden = []
for path in tracked:
    if not path:
        continue
    parts = set(Path(path).parts)
    if {"node_modules", "dist", "build"} & parts:
        forbidden.append(path)
    if Path(path).name in {'.env', '.env.local', '.env.production'}:
        forbidden.append(path)
env_examples = [
    path for path in root.rglob("*")
    if path.is_file()
    and path.name.endswith(".env.example")
    and ".git" not in path.parts
    and "vendor" not in path.parts
    and "node_modules" not in path.parts
    and "dist" not in path.parts
    and "build" not in path.parts
]
for path in env_examples:
    forbidden.append(str(path.relative_to(root)))
if forbidden:
    raise SystemExit("estado generado, secreto o archivo .env.example:\n" + "\n".join(forbidden))
print(f"{len(markdown)} documentos Markdown revisados; enlaces válidos")
PY
then
  pass "enlaces y archivos versionados"
else
  fail "enlaces o archivos versionados"
fi

if rg -n --hidden -g '!vendor/**' -g '!web/node_modules/**' \
  -g '!web/dist/**' -g '!docs/archive/**' \
  '(docs/(PLAN|INFORME-TECNICO)\.md|src/App\.vue|src/main\.ts($|[^x]))' \
  "${ROOT_DIR}" >/tmp/deep-diffusion-doctor-stale.txt 2>/dev/null; then
  cat /tmp/deep-diffusion-doctor-stale.txt >&2
  fail "referencias a archivos retirados"
else
  pass "sin referencias a archivos retirados"
fi

if [[ ! -e "${ROOT_DIR}/LICENSE" ]]; then
  pass "sin licencia MIT propia en la raíz"
else
  fail "sigue presente la licencia propia de la raíz"
fi

if [[ "${ERRORS}" -ne 0 ]]; then
  echo "Doctor fallido: ${ERRORS} problema(s)." >&2
  exit 1
fi
echo "Doctor completo."
