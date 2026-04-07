# OneFlow — Learning Opportunities and Enhancement Ideas

> This document maps the workshop demo patterns to potential OneFlow enhancements.
> Use it during the workshop wrap-up to facilitate discussion about contributing
> to the OneFlow framework.

---

## How to Use This Document

Each section below covers a pattern demonstrated in the workshop. For each pattern:
- **What it does** — Brief description of the capability
- **Workshop demo** — Which workflow file demonstrates it
- **Discussion prompt** — A question for the audience

---

## 1. Reusable Workflow Composition

**What it does:** Break a monolithic pipeline into reusable, composable workflows with typed input/output contracts.

**Workshop demo:** [`10-caller-orchestrator.yml`](../.github/workflows/10-caller-orchestrator.yml)

**Discussion prompt:** How could OneFlow make it easier for teams to compose standard stages with custom stages? Could there be a "plugin" model where teams add custom reusable workflows alongside OneFlow's standard ones?

---

## 2. End-to-End CI/CD Pipeline

**What it does:** Automate the entire software delivery lifecycle — lint, test, build, deploy — through progressive environments with gates.

**Workshop demo:** [`04-ci-build-test.yml`](../.github/workflows/04-ci-build-test.yml), [`05-cd-deploy.yml`](../.github/workflows/05-cd-deploy.yml)

**Discussion prompt:** What additional stages (integration testing, performance testing, compliance checks) should OneFlow offer as standard pipeline stages?

---

## 3. Environment Promotion with Approval Gates

**What it does:** Manual, controlled promotion between environments with approval gates, concurrency controls, and audit trails.

**Workshop demo:** [`12-environment-promotion.yml`](../.github/workflows/12-environment-promotion.yml)

**Discussion prompt:** How does OneFlow handle environment promotion today? Could the manual promotion pattern (with hotfix bypass) be offered as an alternative deployment strategy?

---

## 4. Matrix Strategy for Multi-Service Repos

**What it does:** Dynamic matrix that detects changed services and builds only those in parallel, with fan-in for deployment gating.

**Workshop demo:** [`13-matrix-multi-service.yml`](../.github/workflows/13-matrix-multi-service.yml)

**Discussion prompt:** For teams with monorepos or multiple services, should OneFlow offer dynamic service detection and parallel builds as a configuration option?

---

## 5. Composite Actions for Shared Setup

**What it does:** Bundle common setup steps (checkout, language setup, dependency install) into a reusable action that runs within the caller's job.

**Workshop demo:** [`.github/actions/setup-python-project/action.yml`](../.github/actions/setup-python-project/action.yml)

**Discussion prompt:** Does OneFlow provide composite actions for common setup patterns? Could language-specific setup actions (Python, Node, Java) be published as part of the OneFlow ecosystem?

---

## 6. Required Workflows for Governance

**What it does:** Org admins enforce specific workflows on all PRs via repository rulesets. No team can bypass them.

**Workshop demo:** [`11-required-compliance.yml`](../.github/workflows/11-required-compliance.yml)

**Discussion prompt:** Which checks should be required across all repositories? Security scanning? License compliance? PR formatting? How does OneFlow enforce these today?

---

## 7. Separation of Concerns / Team Ownership

**What it does:** Structure pipelines so each stage is owned by a different team (App, Security, GRC, Platform). Central updates propagate automatically.

**Workshop demo:** [`14-separation-of-concerns.yml`](../.github/workflows/14-separation-of-concerns.yml)

**Discussion prompt:** How are pipeline stage responsibilities divided in your organization today? Could clearer ownership boundaries reduce bottlenecks and improve accountability?

---

## 8. Pipeline Guardrails / Defense-in-Depth

**What it does:** Apply layered security and reliability guardrails: least-privilege permissions, concurrency controls, timeout enforcement, input validation, immutable artifacts, SHA-pinned actions, CODEOWNERS protection.

**Workshop demo:** [`15-pipeline-guardrails.yml`](../.github/workflows/15-pipeline-guardrails.yml)

**Discussion prompt:** Which of the 7 pipeline guardrails are already built into OneFlow? Which are missing? Should OneFlow enforce SHA-pinned actions by default?

---

## 9. Event-Driven Issue Triage Automation

**What it does:** Automatically classify, label, and route issues based on content analysis. Posts welcome comments and sets SLA expectations. Reacts to `issues` and `issue_comment` events — no CI/CD triggers involved.

**Workshop demo:** [`16-issue-triage.yml`](../.github/workflows/16-issue-triage.yml)

**Discussion prompt:** What triage rules are currently handled manually by your team? Could keyword classification (or an internal ML model) automate intake across repos? Should OneFlow publish a standard triage workflow that teams can configure with their own routing rules?

---

## 10. Scheduled Operational Automation

**What it does:** Cron-driven workflows that run governance checks, dependency audits, and stale issue reports on a schedule. Generates dashboards via `GITHUB_STEP_SUMMARY`. Replaces manual "Monday morning check-in" routines.

**Workshop demo:** [`17-scheduled-ops.yml`](../.github/workflows/17-scheduled-ops.yml)

**Discussion prompt:** What operational tasks does your team perform on a recurring basis? Could repo health scores be aggregated org-wide to give leadership a governance dashboard? Should OneFlow offer a standard "repo health" reusable workflow?

---

## 11. Cross-Team Integration via `repository_dispatch`

**What it does:** Bridges team silos using `repository_dispatch` events. When one team's tool completes (AI model updated, scan finished, tool run complete), it sends an event that triggers workflows in other repos. No shared infrastructure — just an API call.

**Workshop demo:** [`18-cross-team-integration.yml`](../.github/workflows/18-cross-team-integration.yml)

**Discussion prompt:** What cross-team handoffs happen through meetings or tickets today? Could `repository_dispatch` automate them? Could OneFlow publish standard event types (e.g., `scan-complete`, `model-promoted`) so that teams have a shared vocabulary for cross-team events?

---

## 12. Internal AI Tool Integration & Custom Actions

**What it does:** Wraps internal tools (AI code review, security scanners, compliance checkers) as custom composite actions. Any team consumes them with a single `uses:` line — no third-party marketplace dependency, no Security Assessment process.

**Workshop demo:** [`19-ai-tool-integration.yml`](../.github/workflows/19-ai-tool-integration.yml) + [`.github/actions/internal-tool-wrapper/`](../.github/actions/internal-tool-wrapper/action.yml)

**Discussion prompt:** Which internal tools are used by multiple teams but integrated differently each time? Could wrapping them as composite actions in an org-level repository give every team access instantly? This is the inner-source model: build once, use everywhere.

---

## Contributing to OneFlow

OneFlow is an inner-source project. Contributions are welcome from across the organization.

**How to get started:**
1. Identify a pattern from this workshop that would benefit your team
2. Check the OneFlow repository for existing issues or discussions
3. Propose the enhancement (issue or RFC)
4. Implement and submit a pull request
5. Work with the OneFlow maintainers on review and adoption

**What makes a good OneFlow contribution:**
- Solves a problem multiple teams face (not just one team's use case)
- Configurable — teams can opt in/out or customize behavior
- Well-documented with clear input/output contracts
- Tested — includes workflow tests or validation
- Backwards compatible — doesn't break existing OneFlow consumers
