# Module 1 — GitHub Actions Fundamentals Refresher

> **Duration:** ~45 minutes
> **Focus:** Workflow syntax, self-hosted runners, secrets management, and environment configuration

---

## Learning Objectives

1. Understand workflow triggers, job dependencies, and step execution
2. Configure and manage self-hosted runners with labels and runner groups
3. Implement secrets management best practices (scoping, masking, OIDC)
4. Use GitHub environments for deployment protection and scoped configuration

---

## OneFlow Context

> **Note:** OneFlow standardizes many of the runner, secret, and environment patterns
> shown in this module. Understanding these fundamentals helps developers troubleshoot
> pipeline issues and appreciate why OneFlow makes the choices it does.

---

## Talking Points

### 1. Workflow Syntax Deep Dive (~15 min)

**Workflow file:** [`workflows/01-basic-ci.yml`](workflows/01-basic-ci.yml) | [Runnable version](../.github/workflows/01-basic-ci.yml)

Key concepts to cover:

- **Triggers (`on:`)** — `push`, `pull_request`, `workflow_dispatch` with typed inputs. Explain that triggers define *when* workflows run and that `workflow_dispatch` enables manual execution with parameters. The `choice` input type creates a dropdown in the UI, and `paths-ignore` prevents unnecessary runs for documentation-only changes.
- **Permissions** — The `permissions: contents: read` block restricts the GITHUB_TOKEN to only what's needed. Default token permissions are often too broad for enterprise use. Always follow the principle of least privilege.
- **Environment variables** — Workflow-level `env:` is available to all jobs. Show the `vars` context (`${{ vars.APP_NAME }}`) for non-sensitive configuration stored in repo/org settings. Distinguish between `env` (workflow-defined) and `vars` (UI-defined).
- **Job dependencies (`needs:`)** — Creates a DAG (Directed Acyclic Graph). `lint` -> `build` -> `test` -> `summary` runs sequentially. Without `needs`, jobs run in parallel by default. The `summary` job uses `if: always()` to run even when upstream jobs fail.
- **`uses:` vs `run:`** — `uses:` invokes a pre-built action (e.g., `actions/checkout@v4`). `run:` executes shell commands. Always pin actions to a version to prevent breaking changes.
- **Caching** — `actions/cache` with `hashFiles('**/requirements.txt')` key stores pip dependencies between runs. The `restore-keys` fallback provides partial cache hits when the exact key doesn't match.
- **Artifacts** — `actions/upload-artifact` persists build output between jobs and after workflow completion. Downstream jobs use `actions/download-artifact` to retrieve it. Set `retention-days` to control storage costs.
- **Step summary** — `GITHUB_STEP_SUMMARY` renders markdown in the Actions UI. The workflow writes a table with app name, ref, SHA, and test status — great for pipeline reports visible without digging into logs.

> **Demo walkthrough:**
> 1. Open the workflow file and walk through each section
> 2. Trigger the workflow via `workflow_dispatch` — select a log level from the dropdown
> 3. Show the Actions UI: job DAG visualization, log output, artifacts tab
> 4. Show the context information step — explain `github.*` context expressions
> 5. Click into the summary tab to show the rendered markdown report

---

### 2. Self-Hosted Runners (~15 min)

**Workflow file:** [`workflows/02-self-hosted-runner.yml`](workflows/02-self-hosted-runner.yml) | [Runnable version](../.github/workflows/02-self-hosted-runner.yml)

Key concepts to cover:

- **Label matching** — `runs-on: [self-hosted, linux]` requires a runner with ALL specified labels. Use labels for OS, architecture, and capability targeting (e.g., `[self-hosted, gpu]` or `[self-hosted, high-memory]`).
- **Runner groups** — Organize runners into groups to control which repositories can use which runners. Essential for cost allocation, security isolation, and separating production from development workloads.
- **Real system diagnostics** — The workflow runs `uname -a`, `nproc`, `free -h`, `df -h`, `docker --version`, and connectivity checks against `api.github.com`. Useful for verifying runner capacity and troubleshooting. Controlled by the `run_diagnostics` boolean input.
- **Container jobs on self-hosted** — The `container: { image: node:20-slim }` directive runs all steps inside a Docker container on the runner. This provides consistent environments, dependency isolation, clean state every run, and easy local reproduction. Requires Docker installed on the runner.
- **Security hardening** — The summary job renders a checklist table covering: ephemeral runners, no public repos, runner groups, least privilege, network segmentation, keeping runners updated, audit logs, and workspace cleanup. These are the baseline security practices for self-hosted runners.
- **Why self-hosted?** — Network access to internal systems, compliance requirements (data residency), cost control for high-volume CI, custom tooling and hardware (GPUs, specific OS versions).

> **Demo walkthrough:**
> 1. Trigger the workflow with `run_diagnostics: true` — show real system stats in logs
> 2. Walk through the 4 jobs: runner info, label strategies, container job, security checklist
> 3. Highlight the container job: "Same runner, but steps execute inside `node:20-slim`"
> 4. Navigate to org Settings > Actions > Runners: show runner groups and access controls
> 5. Show the security checklist rendered in the step summary tab
> 6. Discuss: ephemeral vs persistent runners — trade-offs for your environment

---

### 3. Secrets & Environment Management (~15 min)

**Workflow file:** [`workflows/03-secrets-environments.yml`](workflows/03-secrets-environments.yml) | [Runnable version](../.github/workflows/03-secrets-environments.yml)

Key concepts to cover:

- **Secret hierarchy** — Environment secrets > Repository secrets > Organization secrets. When names collide, the most specific level wins. This allows org-wide defaults with per-environment overrides.
- **Configuration variables (`vars`)** — Non-sensitive config at org/repo/environment level. Use `vars` for feature flags, region names, and app config. Use `secrets` for tokens, passwords, and API keys. Never store sensitive data in variables — they are visible to anyone with read access.
- **Secret masking** — GitHub automatically masks secret values in logs. Use `::add-mask::$DYNAMIC_SECRET` for dynamically generated sensitive values. Even with masking, avoid printing secrets — they can leak via encoded forms (base64, URL encoding).
- **Full 3-tier environment progression** — Dev (no protection, deploys immediately) -> Staging (requires approval before deployment) -> Production (strictest protection rules). Show how selecting `target_env: production` triggers all 3 tiers with progressive gates.
- **Environment protection rules** — The workflow shows a summary table: Dev has no rules, Staging requires 1 reviewer, Production requires 2 reviewers plus a wait timer and branch restrictions. These rules are configured in Settings > Environments.
- **OIDC authentication** — The recommended alternative to long-lived credentials. Short-lived tokens scoped to the specific workflow run. Requires `permissions: id-token: write`. The workflow includes commented-out Azure/AWS login examples and renders an OIDC vs Static Secrets comparison table in the step summary.
- **Self-hosted runner cleanup** — On persistent runners, always delete files containing secrets. Unlike ephemeral runners, the workspace persists between jobs.

> **Demo walkthrough:**
> 1. Show the secrets-demo job: walk through the hierarchy explanation and `::add-mask::` pattern
> 2. Show the variables context demo: distinguish `vars.*` from `secrets.*`
> 3. Trigger with `target_env: production` to show all 3 tiers deploying with progressive gates
> 4. Navigate to Settings > Environments in the repo: show protection rules side-by-side
> 5. Show the OIDC comparison table (Static Secrets vs OIDC Tokens) in the step summary
> 6. Discuss OIDC: when to use it, which cloud providers support it

---

## Key Takeaways

1. **Explicit permissions** — Always set `permissions:` to restrict the GITHUB_TOKEN to the minimum needed
2. **Self-hosted runner hygiene** — Clean workspaces, use container jobs for isolation, and keep runner software updated
3. **Secret scoping** — Use environment secrets for deployment credentials; use OIDC where possible to eliminate stored secrets entirely
4. **Environments are more than secrets** — They provide protection rules, deployment tracking, and branch policies

---

## Discussion Prompts

- How does your team currently manage runner access? Could runner groups improve isolation?
- What secrets could be replaced with OIDC token authentication?
- Are there environment protection rules (required reviewers, wait timers) that would improve your deployment safety?

---

## Preparation Checklist

- [ ] At least one self-hosted runner registered with labels `[self-hosted, linux]`
- [ ] At least one runner group configured (e.g., `workshop-runners`)
- [ ] A repository secret created: `DEMO_SECRET` (any value) for the masking demo
- [ ] GitHub environments created: `dev`, `staging`, `production`
- [ ] `staging` environment configured with a protection rule (optional, for live demo)
- [ ] Repository variable: `APP_NAME` = `workshop-demo`
