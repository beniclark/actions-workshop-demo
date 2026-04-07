# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repository Is

A workshop demo repository for a customer (Visa) training on GitHub Actions. It contains a sample Python Flask API and 19 GitHub Actions workflow files organized across 5 workshop modules. The workflows are **demo material** — they are meant to be read, presented, and triggered manually during the workshop, not production CI/CD.

Critical constraints:
- **Self-hosted runners only** — every workflow uses `runs-on: [self-hosted, linux]`. Never use `ubuntu-latest` or other GitHub-hosted runners.
- **Dual-placement pattern** — runnable workflows live in `.github/workflows/`. Each module folder (`01-fundamentals/`, etc.) has a `workflows/` subdirectory with **identical reference copies**. When editing a workflow, **update both locations**.
- **OneFlow framing** — Visa's internal pipeline standard. Workflows are positioned as "building blocks of OneFlow." Preserve this framing in all content.
- **Keep the app simple** — `app.py` is intentionally minimal (in-memory CRUD + health check). Don't add databases, auth, or complexity — it exists to give workflows something to build/test/deploy.
- **Scripts are mock** — `scripts/deploy.sh`, `scripts/smoke-test.sh`, `scripts/mock-ai-service.sh`, and `scripts/send-dispatch.sh` simulate with echo/sleep. They don't touch real infrastructure.

## Commands

```bash
pip install -r requirements.txt   # Install dependencies
python app.py                     # Start Flask server on PORT (default 5000)
pytest tests/                     # All tests
pytest tests/unit/                # Unit tests only
pytest tests/integration/         # Integration tests only
flake8 .                          # Lint (max-line-length=120)
black --check .                   # Format check
```

## Architecture

- **Workflow numbering**: 01-03 (Fundamentals), 04-06 (E2E Pipeline), 07-11 (Reusable Workflows), 12-15 (Enterprise Patterns), 16-19 (Beyond CI/CD). Preserve this scheme.
- **Dual-placement**: Runnable workflows in `.github/workflows/`; reference copies in each module's `workflows/` subdirectory. Both must stay in sync.
- **Reusable workflows**: 07/08/09 use `workflow_call`; 10 is the caller that composes them.
- **Event-driven workflows**: 16-19 use non-CI triggers (`issues`, `schedule`, `repository_dispatch`, `pull_request`).
- **Composite actions**: `.github/actions/setup-python-project/action.yml` bundles checkout + Python setup + pip install. `.github/actions/internal-tool-wrapper/action.yml` wraps an internal tool (inner-source pattern).
- **Environments**: `dev`, `staging`, `production` — production requires reviewers. Config in `config/{dev,staging,prod}.env`.
- **CODEOWNERS**: `@platform-team` owns workflows/actions; `@security-team` co-owns Dockerfile.
- **Sample app**: `app.py` is the Flask API (health check + items CRUD). Tests in `tests/unit/` and `tests/integration/`.

## Conventions

- Module READMEs (`01-fundamentals/README.md`, etc.) are **presenter guides** with timing, talking points, and demo walkthroughs — not standard code docs. Preserve their voice and structure.
- Dockerfile uses multi-stage build with `python:3.12-slim`, runs as non-root `appuser`.
- `APP_VERSION` env var controls version display; passed as Docker build ARG.
- Prod uses port 8080; dev/staging use 5000.

## Documentation Map

| Document | Covers |
|----------|--------|
| README.md | Workshop overview, module table, repo structure, setup |
| docs/presenter-guide.md | 3.5h agenda, pre-flight checklist, module delivery |
| docs/oneflow-learning-opportunities.md | Workshop-to-OneFlow contribution mapping |
| docs/required-workflows-setup.md | Org ruleset config, rollout strategy, troubleshooting |
| .github/copilot-instructions.md | Copilot-specific guidance (overlaps with this file) |
