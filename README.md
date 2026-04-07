# GitHub Actions Workshop — Enterprise Automation in Practice

> A hands-on workshop demonstrating GitHub Actions capabilities for enterprise teams
> using self-hosted runners, with a focus on patterns that power standard pipelines like **OneFlow**.

---

## Workshop Modules

| Module | Topic | Duration | Focus |
|--------|-------|----------|-------|
| 1 | [Fundamentals Refresher](01-fundamentals/) | ~30 min | Triggers, self-hosted runners, secrets, environments |
| 2 | [CI/CD Overview](02-e2e-automation/) | ~30 min | End-to-end pipeline (OneFlow-framed) |
| 3 | [Beyond CI/CD](03-beyond-cicd/) | ~60 min | Event-driven automation, AI tool integration, cross-team workflows |
| 4 | [Inner-Source & Reusable Workflows](03-reusable-required-workflows/) | ~45 min | Composable workflows, custom actions, governance gates |
| 5 | [Enterprise Governance](04-enterprise-patterns/) | ~30 min | Promotion, separation of concerns, pipeline guardrails |

**Total duration:** ~3.5 hours (including breaks and discussion)

---

## Key Themes

- **Self-hosted runners first** — Every workflow targets self-hosted runners. No GitHub-hosted runner content.
- **Beyond CI/CD** — Actions is an event platform, not just CI/CD. Demos cover issue triage, scheduled ops, cross-team integration, and AI tool automation.
- **Internal tool integration** — Custom composite actions wrap internal tools for inner-source consumption. No third-party marketplace dependencies needed.
- **OneFlow standard pipeline** — These demos show the underlying Actions capabilities that power OneFlow. Understanding the primitives helps developers debug, extend, and contribute to OneFlow.
- **Cross-team collaboration** — `repository_dispatch` and custom actions bridge silos between teams building AI tools, security scanners, and platform services.
- **Enterprise governance** — Secrets management, required workflows, CODEOWNERS, environment protection rules.

---

## Sample Application

A minimal Python Flask API used across all demos:

| Endpoint | Description |
|----------|-------------|
| `GET /health` | Health check with status and timestamp |
| `GET /api/items` | List all items |
| `POST /api/items` | Create an item (JSON body with `name`) |
| `GET /api/items/<id>` | Get a single item by ID |

### Run locally

```bash
pip install -r requirements.txt
python app.py              # Start server on port 5000
pytest tests/              # Run all tests
pytest tests/unit/         # Unit tests only
pytest tests/integration/  # Integration tests only
flake8 .                   # Lint
black --check .            # Format check
```

---

## Repository Structure

```
├── app.py                            # Flask API (health + items CRUD)
├── requirements.txt                  # Python dependencies
├── Dockerfile                        # Multi-stage Python build
├── setup.cfg                         # pytest and flake8 configuration
│
├── tests/
│   ├── unit/test_app.py              # Unit tests (pytest + test client)
│   └── integration/test_health.py    # Integration tests (HTTP against running server)
│
├── .github/
│   ├── CODEOWNERS                    # Platform team governance
│   ├── actions/
│   │   ├── setup-python-project/     # Composite action: Python setup
│   │   └── internal-tool-wrapper/    # Composite action: internal tool wrapper (inner-source)
│   └── workflows/                    # 19 runnable workflow files
│       ├── 01-basic-ci.yml                 # Module 1: Fundamentals
│       ├── 02-self-hosted-runner.yml
│       ├── 03-secrets-environments.yml
│       ├── 04-ci-build-test.yml            # Module 2: CI/CD Overview
│       ├── 05-cd-deploy.yml
│       ├── 06-full-pipeline.yml
│       ├── 07-reusable-build.yml           # Module 4: Reusable Workflows
│       ├── 08-reusable-security-scan.yml
│       ├── 09-reusable-deploy.yml
│       ├── 10-caller-orchestrator.yml
│       ├── 11-required-compliance.yml
│       ├── 12-environment-promotion.yml    # Module 5: Enterprise Governance
│       ├── 13-matrix-multi-service.yml
│       ├── 14-separation-of-concerns.yml
│       ├── 15-pipeline-guardrails.yml
│       ├── 16-issue-triage.yml             # Module 3: Beyond CI/CD
│       ├── 17-scheduled-ops.yml
│       ├── 18-cross-team-integration.yml
│       └── 19-ai-tool-integration.yml
│
├── 01-fundamentals/                  # Module 1 reference files + README
├── 02-e2e-automation/                # Module 2 reference files + README
├── 03-beyond-cicd/                   # Module 3 reference files + README (event-driven)
├── 03-reusable-required-workflows/   # Module 4 reference files + README
├── 04-enterprise-patterns/           # Module 5 reference files + README
│
├── scripts/
│   ├── deploy.sh                     # Mock deployment script
│   ├── smoke-test.sh                 # Mock smoke test script
│   ├── mock-ai-service.sh            # Mock internal AI code review API
│   └── send-dispatch.sh              # Helper: send repository_dispatch events
│
├── config/
│   ├── dev.env / staging.env / prod.env
│
└── docs/
    ├── presenter-guide.md            # Full facilitator guide with timing
    ├── oneflow-learning-opportunities.md  # OneFlow enhancement discussion
    └── required-workflows-setup.md        # Governance setup guide
```

> **Note:** Workflow files in `.github/workflows/` are the runnable versions. Each module
> folder contains reference copies in a `workflows/` subdirectory for easy browsing during the workshop.

---

## Environment Setup

### Prerequisites

| Requirement | Details |
|-------------|---------|
| Self-hosted runner | Registered with labels `[self-hosted, linux]` |
| Python | 3.12+ (or `actions/setup-python` will install) |
| Docker | For build and container job demos |
| pip | Comes with Python |

### GitHub Configuration

1. **Environments** — Create `dev`, `staging`, `production` in repo Settings > Environments
2. **Protection rules** — Add required reviewers to `production` environment
3. **Secrets** — Create a repository secret `DEPLOY_TOKEN` (any value for demo)
4. **Variables** — Optionally set `APP_NAME` and `APP_ENV` in repo Settings > Variables

### Verify Setup

```bash
# Clone and test locally
git clone <repo-url>
cd github-actions-demos
pip install -r requirements.txt
pytest tests/
flake8 .
```

---

## Workflow Quick Reference

| # | Workflow | Trigger | Key Pattern |
|---|---------|---------|-------------|
| 01 | Basic CI | push, PR, dispatch | Triggers, needs, permissions, artifacts |
| 02 | Self-Hosted Runner | dispatch | Labels, groups, container jobs, cleanup, security |
| 03 | Secrets & Environments | dispatch | Secret scoping, masking, env protection, OIDC |
| 04 | CI Build & Test | push, PR, dispatch | Lint, parallel tests, Docker build |
| 05 | CD Deploy | dispatch, call | Multi-environment deployment with gates |
| 06 | Full Pipeline | push, PR, dispatch | Complete CI/CD in one workflow |
| 07 | Reusable Build | call | workflow_call, typed inputs/outputs |
| 08 | Reusable Security Scan | call | Centralized scanning, severity threshold |
| 09 | Reusable Deploy | call | Dynamic environment, secret contracts |
| 10 | Caller Orchestrator | push, PR, dispatch | Caller composing 07+08+09 |
| 11 | Required Compliance | PR, call | Governance gate, license/audit compliance |
| 12 | Environment Promotion | dispatch | Manual promotion, hotfix bypass path |
| 13 | Matrix Multi-Service | PR, dispatch | Dynamic service detection, fan-out/fan-in |
| 14 | Separation of Concerns | dispatch | Team ownership model (App/Security/GRC/Platform) |
| 15 | Pipeline Guardrails | dispatch | Least-privilege, SHA pinning, immutable artifacts |
| 16 | Issue Triage | issues, issue_comment | Auto-label, team routing, welcome comments |
| 17 | Scheduled Ops | schedule (cron), dispatch | Repo health, dependency audit, stale issues |
| 18 | Cross-Team Integration | repository_dispatch | Typed events, cross-team payloads, bridging silos |
| 19 | AI Tool Integration | PR, dispatch | Internal AI service, composite action, inner-source |

---

## Additional Resources

- [Presenter Guide](docs/presenter-guide.md) — Detailed facilitation guide with timing and tips
- [OneFlow Enhancement Ideas](docs/oneflow-learning-opportunities.md) — Discussion document for wrap-up
- [Required Workflows Setup](docs/required-workflows-setup.md) — Governance configuration guide
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Reusable Workflows](https://docs.github.com/en/actions/using-workflows/reusing-workflows)
- [Repository Rulesets](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets)
