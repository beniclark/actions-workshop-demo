# Presenter Guide — GitHub Actions Workshop

> **Total Duration:** ~3.5 hours (including breaks and discussion)
> **Format:** Live demo + discussion, not slides-heavy
> **Audience:** Developers and platform engineers familiar with CI/CD basics

---

## Agenda Overview

| Time | Module | Duration | Focus |
|------|--------|----------|-------|
| 0:00 | Welcome & Setup | 10 min | Introductions, verify repo access, runner status |
| 0:10 | Module 1: Fundamentals | 45 min | Triggers, runners, secrets, environments |
| 0:55 | Break | 10 min | |
| 1:05 | Module 2: E2E Pipeline | 60 min | Full CI/CD pipeline, integration testing |
| 2:05 | Break | 10 min | |
| 2:15 | Module 3: Reusable Workflows | 45 min | workflow_call, composition, governance |
| 3:00 | Break | 10 min | |
| 3:10 | Module 4: Enterprise Patterns | 60 min | Promotion, matrix, separation of concerns, guardrails |
| 4:10 | Wrap-Up & OneFlow Discussion | 20 min | OneFlow enhancement ideas, Q&A |

---

## Pre-Flight Checklist

Run through this checklist 30 minutes before the workshop:

### Infrastructure
- [ ] Self-hosted runner online with labels `[self-hosted, linux]`
- [ ] Runner has Python 3.12+ available (or actions/setup-python will install)
- [ ] Runner has Docker and Docker Buildx installed
- [ ] Runner has network access to GitHub and PyPI
- [ ] Port 5000 available on the runner (for integration test demo)

### Repository Configuration
- [ ] Repository cloned/forked for the workshop
- [ ] GitHub environments created: `dev`, `staging`, `production`
- [ ] `production` environment has required reviewers configured
- [ ] At least one repository secret created (e.g., `DEPLOY_TOKEN`)
- [ ] Repository variables configured (optional: `APP_NAME`, `APP_ENV`)

### Pre-Run Workflows
- [ ] Run `01-basic-ci.yml` once to populate Actions history
- [ ] Open a test PR with a feature branch for guardrails demo (Module 4)

### Presenter Setup
- [ ] Two browser tabs: repo code view + Actions tab
- [ ] Terminal with repo cloned locally (for live edits if needed)
- [ ] Each module README open for reference (talking points, demo steps)

---

## Module Delivery Guide

### Module 1: Fundamentals (45 min)

**Opening:** "Let's start with the building blocks. Even if you've used Actions before, we'll cover patterns specific to self-hosted runners and enterprise secret management."

**Demo order:**
1. `01-basic-ci.yml` — Walk through syntax, trigger it, show the UI
2. `02-self-hosted-runner.yml` — Runner labels, container jobs, diagnostics
3. `03-secrets-environments.yml` — Env precedence, secret masking, full 3-tier deployment, OIDC

**OneFlow tie-in:** "OneFlow standardizes these patterns — runner selection, secret management, cleanup. Understanding them helps you debug and contribute."

---

### Module 2: E2E Pipeline (60 min)

**Opening:** "Now let's see these pieces come together in a real deployment pipeline."

**Demo order:**
1. `04-ci-build-test.yml` — CI with lint, parallel tests, Docker build
2. `05-cd-deploy.yml` — Multi-environment CD with progressive gates
3. `06-full-pipeline.yml` — Combined CI/CD in one workflow

**OneFlow tie-in:** "This is what OneFlow gives you out of the box. Understanding the primitives means you can propose enhancements."

**Key moment:** When showing the approval gate on production deployment, pause and discuss: "This is where governance meets automation. OneFlow can enforce this consistently."

---

### Module 3: Reusable Workflows (45 min)

**Opening:** "Module 2 showed a complete pipeline in one file. Now let's see how to break it into reusable, composable pieces — this is how OneFlow actually works."

**Demo order:**
1. `07-reusable-build.yml` — Show the workflow_call contract
2. `08-reusable-security-scan.yml` — Output contracts, centralized scanning
3. `09-reusable-deploy.yml` — Dynamic environments, secret contracts
4. `10-caller-orchestrator.yml` — Compose 07+08+09 into a full pipeline
5. `11-required-compliance.yml` — Governance enforcement with license/audit

**Key moment:** When showing `10-caller-orchestrator.yml`, compare its size to the full pipeline in Module 2. "Same pipeline, fraction of the code."

---

### Module 4: Enterprise Patterns (60 min)

**Opening:** "The last module covers patterns for operating at scale — the architectural decisions and guardrails that matter when hundreds of teams share infrastructure."

**Demo order:**
1. `12-environment-promotion.yml` — Manual promotion with approval
2. `13-matrix-multi-service.yml` — Dynamic matrix, fan-out/fan-in
3. `14-separation-of-concerns.yml` — Team ownership model (strong OneFlow tie-in)
4. `15-pipeline-guardrails.yml` — 7 guardrails for deployment security

**Key moment (workflow 14):** "This is the OneFlow model — centralized stages, distributed consumption." Let it sink in.

**Key moment (workflow 15):** Compare SHA-pinned `actions/checkout@<sha>` vs `@v4`. "If someone moves the v4 tag to malicious code, what happens?"

---

### Wrap-Up: OneFlow Discussion (20 min)

**Reference:** `docs/oneflow-learning-opportunities.md`

**Facilitation approach:**
1. Recap the 4 modules in 2 minutes
2. Open the OneFlow learning opportunities doc on screen
3. Walk through 3-4 enhancement areas, asking for input
4. Close with: "OneFlow is an inner-source project. These ideas can become pull requests."

---

## Handling Difficult Situations

| Situation | Response |
|-----------|----------|
| Runner goes offline | Switch to walking through YAML files and the Actions UI from a previous run |
| Workflow takes too long | Show a previous completed run while current one executes |
| Audience is very advanced | Skip fundamentals quickly, spend more time on enterprise patterns and OneFlow discussion |
| Audience is newer | Slow down on Module 1, keep Module 4 as discussion rather than live demo |

---

## Post-Workshop

- Share the repository link with attendees
- Point them to the section READMEs for self-paced review
- Direct OneFlow contribution interest to the OneFlow team
- Collect feedback on which patterns resonated most
