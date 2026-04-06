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
