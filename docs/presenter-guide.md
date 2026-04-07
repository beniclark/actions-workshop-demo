# Presenter Guide — GitHub Actions Workshop

> **Total Duration:** ~3.5 hours (including breaks and discussion)
> **Format:** Live demo + discussion, not slides-heavy
> **Audience:** Developers and platform engineers familiar with CI/CD basics

---

## Agenda Overview

| Time | Module | Duration | Focus |
|------|--------|----------|-------|
| 0:00 | Welcome & Setup | 10 min | Introductions, verify repo access, runner status |
| 0:10 | Module 1: Fundamentals | 30 min | Triggers, runners, secrets, environments |
| 0:40 | Module 2: CI/CD Overview | 30 min | Full CI/CD pipeline (OneFlow-framed) |
| 1:10 | Break | 10 min | |
| 1:20 | Module 3: Beyond CI/CD | 60 min | Event-driven, scheduled, cross-team, AI tools |
| 2:20 | Break | 10 min | |
| 2:30 | Module 4: Inner-Source & Reusable Workflows | 45 min | workflow_call, custom actions, composition |
| 3:15 | Break | 10 min | |
| 3:25 | Module 5: Enterprise Governance | 30 min | Separation of concerns, guardrails |
| 3:55 | Wrap-Up & OneFlow Discussion | 20 min | OneFlow enhancement ideas, Q&A |

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

### Module 1: Fundamentals (30 min)

**Opening:** "Let's start with the building blocks. Even if you've used Actions before, we'll cover patterns specific to self-hosted runners and enterprise secret management. This is a refresher — we'll move quickly so we can focus on the non-CI capabilities."

**Demo order:**
1. `01-basic-ci.yml` — Walk through syntax, trigger it, show the UI
2. `02-self-hosted-runner.yml` — Runner labels, container jobs, diagnostics
3. `03-secrets-environments.yml` — Env precedence, secret masking, OIDC overview

**Pacing note:** Keep this brisk. The audience already knows CI/CD — this is context-setting, not deep teaching. If the audience is advanced, spend 5 min here and move on.

**OneFlow tie-in:** "OneFlow standardizes these patterns — runner selection, secret management, cleanup. Understanding them helps you debug and contribute."

---

### Module 2: CI/CD Overview (30 min)

**Opening:** "You already have OneFlow for CI/CD across 3,000+ repos. Rather than spend time on what you know, let's quickly see the underlying primitives — then move to the capabilities beyond CI/CD."

**Demo order:**
1. `04-ci-build-test.yml` — CI with lint, parallel tests (quick walkthrough)
2. `06-full-pipeline.yml` — Combined CI/CD in one workflow (show but don't deep-dive)
3. Brief mention of `05-cd-deploy.yml` — Multi-environment CD concept

**Pacing note:** This is a 30-min overview, not a deep dive. The audience has OneFlow — they don't need to build CI/CD from scratch. Show the patterns, connect to OneFlow, then move to Module 3 where the new content lives.

**OneFlow tie-in:** "This is what OneFlow gives you out of the box. The next module shows what Actions can do *beyond* what OneFlow covers."

**Key moment:** When showing the full pipeline, say: "OneFlow handles all of this. Now let's look at what else Actions can do."

---

### Module 3: Beyond CI/CD (60 min) ⭐ Core Module

**Opening:** "This is the heart of today's workshop. Actions is an event platform — not just CI/CD. We're going to look at four workflows that solve real problems you can't solve with a build pipeline: issue triage, scheduled operations, cross-team integration, and internal AI tool automation."

**Demo order:**
1. `16-issue-triage.yml` (~15 min) — Event-driven issue classification and routing
2. `17-scheduled-ops.yml` (~10 min) — Cron-driven repo health checks and dependency audits
3. `18-cross-team-integration.yml` (~15 min) — `repository_dispatch` bridging team silos
4. `19-ai-tool-integration.yml` (~20 min) — Internal AI service + composite action pattern

**Key transitions:**
- After 16: "We just automated something that was manual email/Slack work. No CI involved."
- After 17: "This runs every Monday by itself. What manual tasks does your team do weekly?"
- After 18: "This is how you bridge silo'd teams without meetings. Team A sends an event, Team B reacts."
- After 19: "This is the full pattern: an AI tool built by one team, wrapped as an action, available to all 3,000 repos."

**OneFlow tie-in:** "These patterns complement OneFlow. `repository_dispatch` lets internal tools integrate with pipelines without modifying OneFlow itself. Custom composite actions become shared building blocks that any team's pipeline can consume."

**Key moment (workflow 19):** Walk through the composite action anatomy in `.github/actions/internal-tool-wrapper/`. "One team builds this, publishes it. Every other team gets it with a single `uses:` line. No Security Assessment needed — it's internal."

---

### Module 4: Inner-Source & Reusable Workflows (45 min)

**Opening:** "In Module 3 we built a composite action from scratch. Now let's see the full reusable workflow pattern — how OneFlow actually works under the hood, and how you can contribute your own reusable pieces."

**Demo order:**
1. `07-reusable-build.yml` — Show the workflow_call contract
2. `08-reusable-security-scan.yml` — Output contracts, centralized scanning
3. `09-reusable-deploy.yml` — Dynamic environments, secret contracts
4. `10-caller-orchestrator.yml` — Compose 07+08+09 into a full pipeline
5. `11-required-compliance.yml` — Governance enforcement with license/audit

**Key moment:** When showing `10-caller-orchestrator.yml`, compare its size to the full pipeline in Module 2. "Same pipeline, fraction of the code."

**Inner-source tie-in:** "This is the inner-source contribution model. You build a reusable workflow, publish it, and every team benefits. The composite action from Module 3 is the same pattern at a smaller scale."

---

### Module 5: Enterprise Governance (30 min)

**Opening:** "The last module covers enterprise-scale governance — the architectural decisions and guardrails that matter when hundreds of teams share infrastructure."

**Demo order:**
1. `12-environment-promotion.yml` — Manual promotion with approval (brief)
2. `14-separation-of-concerns.yml` — Team ownership model (strong OneFlow tie-in)
3. `15-pipeline-guardrails.yml` — 7 guardrails for deployment security

**Pacing note:** Workflow 13 (matrix multi-service) is available for reference but can be skipped in the interest of time. Mention it as "available for self-study."

**Key moment (workflow 14):** "This is the OneFlow model — centralized stages, distributed consumption." Let it sink in.

**Key moment (workflow 15):** Compare SHA-pinned `actions/checkout@<sha>` vs `@v4`. "If someone moves the v4 tag to malicious code, what happens?"

---

### Wrap-Up: OneFlow Discussion (20 min)

**Reference:** `docs/oneflow-learning-opportunities.md`

**Facilitation approach:**
1. Recap the 5 modules in 2 minutes — emphasize the non-CI capabilities from Module 3
2. Open the OneFlow learning opportunities doc on screen
3. Walk through 3-4 enhancement areas, asking for input
4. Highlight: "The event-driven patterns from Module 3 and the inner-source actions from Module 4 are things you can start building tomorrow."
5. Close with: "OneFlow is an inner-source project. These ideas can become pull requests. And the non-CI automation doesn't need OneFlow at all — any team can adopt it today."

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
