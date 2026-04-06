# Project Guidelines

## What This Is

A GitHub Actions workshop demo repo (4 modules, 15 workflows) with a sample Python Flask API. Workflows are **teaching material**, not production CI/CD. See [README.md](../README.md) for orientation and [docs/presenter-guide.md](../docs/presenter-guide.md) for facilitation details.

## Critical Constraints

- **Self-hosted runners only** — every workflow uses `runs-on: [self-hosted, linux]`. Never use `ubuntu-latest` or other GitHub-hosted runners.
- **Dual-placement pattern** — runnable workflows live in `.github/workflows/`. Each module folder (`01-fundamentals/`, etc.) has a `workflows/` subdirectory with **identical reference copies**. When editing a workflow, **update both locations**.
- **OneFlow framing** — Visa's internal pipeline standard. Workflows are positioned as "building blocks of OneFlow." Preserve this framing in all content.
- **Keep the app simple** — `app.py` is intentionally minimal (in-memory CRUD + health check). Don't add databases, auth, or complexity — it exists to give workflows something to build/test/deploy.
- **Scripts are mock** — `scripts/deploy.sh` and `scripts/smoke-test.sh` simulate with echo/sleep. They don't touch real infrastructure.

## Build and Test

```bash
pip install -r requirements.txt   # Install dependencies
pytest tests/                     # All tests
pytest tests/unit/                # Unit tests only
pytest tests/integration/         # Integration tests only
flake8 .                          # Lint (max-line-length=120)
black --check .                   # Format check
```

## Architecture

- **Workflow numbering**: 01-03 (Fundamentals), 04-06 (E2E Pipeline), 07-11 (Reusable Workflows), 12-15 (Enterprise Patterns). Preserve this scheme.
- **Reusable workflows**: 07/08/09 use `workflow_call`; 10 is the caller that composes them.
- **Composite action**: `.github/actions/setup-python-project/action.yml` bundles checkout + Python setup + pip install.
- **Environments**: `dev`, `staging`, `production` — production requires reviewers. Config in `config/{dev,staging,prod}.env`.
- **CODEOWNERS**: `@platform-team` owns workflows/actions; `@security-team` co-owns Dockerfile.

## Conventions

- Module READMEs (`01-fundamentals/README.md`, etc.) are **presenter guides** with timing, talking points, and demo walkthroughs — not standard code docs. Preserve their voice and structure.
- Dockerfile uses multi-stage build with `python:3.12-slim`, runs as non-root `appuser`.
- `APP_VERSION` env var controls version display; passed as Docker build ARG.
- Prod uses port 8080; dev/staging use 5000.

## Documentation Map

| Document | Covers |
|----------|--------|
| [README.md](../README.md) | Workshop overview, module table, repo structure, setup |
| [docs/presenter-guide.md](../docs/presenter-guide.md) | 3.5h agenda, pre-flight checklist, module delivery |
| [docs/oneflow-learning-opportunities.md](../docs/oneflow-learning-opportunities.md) | Workshop-to-OneFlow contribution mapping |
| [docs/required-workflows-setup.md](../docs/required-workflows-setup.md) | Org ruleset config, rollout strategy, troubleshooting |
| [CLAUDE.md](../CLAUDE.md) | Claude Code-specific guidance (overlaps with this file) |
