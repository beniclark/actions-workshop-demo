# Module 4 — Enterprise-Scale Workflow Design Patterns

> **Duration:** ~60 minutes
> **Focus:** Patterns for maintainability, security, scalability, and governance at enterprise scale

---

## Learning Objectives

1. Implement environment promotion with approval gates and concurrency controls
2. Use dynamic matrix strategies for multi-service builds with fan-out/fan-in
3. Design modular pipelines with clear team ownership and separation of concerns
4. Apply deployment pipeline guardrails for defense-in-depth (SHA pinning, immutable artifacts, least privilege)

---

## OneFlow Context

> **Which of these patterns should be adopted or expanded in OneFlow?** This module
> presents design patterns that enhance pipeline quality at scale. As you walk through
> each pattern, consider:
>
> - Is this already in OneFlow? If not, should it be?
> - Could this be contributed as an optional stage or configuration?
> - How would this improve the developer experience for OneFlow users?

---

## Talking Points

### 1. Environment Promotion Strategy (~15 min)

**Workflow file:** [`workflows/12-environment-promotion.yml`](workflows/12-environment-promotion.yml) | [Runnable version](../.github/workflows/12-environment-promotion.yml)

Key concepts to cover:

- **Manual promotion via `workflow_dispatch`** — Operators explicitly choose which image tag to promote and which environment to start from using `choice` inputs. This gives humans control over when code moves between environments, rather than relying on fully automated promotion.
- **`start_from` input** — The `choice` input (dev/staging/production) controls which deployment stages execute. Starting from `staging` skips dev; starting from `production` goes straight to prod. This handles both standard promotions and emergency hotfixes.
- **Concurrency controls** — `concurrency: { group: promotion-${{ github.repository }}, cancel-in-progress: false }` prevents overlapping promotions to the same environment. `cancel-in-progress: false` means a running deployment is never killed mid-rollout — new runs queue until the current one finishes.
- **Promotion tracking** — A unique promotion ID (`promo-YYYYMMDDHHMMSS-NNNN`) is generated for audit trail purposes. This ID links the artifact validation, all deployment stages, and the final summary for end-to-end traceability.
- **Environment-specific configuration** — Each environment has different settings (replicas, CPU, memory, log level) without code changes. The workflow reads these from environment-scoped variables, keeping configuration separate from code.
- **Approval gates** — Environment protection rules pause the workflow until a reviewer approves. Production requires 2 reviewers plus a wait timer. This is configured in the GitHub UI, not in the workflow file — the workflow just binds to the environment.
- **Automatic rollback** — Production deployment includes a rollback step that triggers on failure. If post-deployment verification fails, the previous version is automatically restored.

> **Demo walkthrough:**
> 1. Trigger via `workflow_dispatch`, selecting `staging` and an image tag
> 2. Show the promotion ID in the validate-artifact job
> 3. Walk through the environment-specific configuration differences
> 4. If protection rules are configured, show the approval gate pausing the workflow
> 5. Discuss: when is manual promotion appropriate vs fully automated?

> **Pattern:** Environment promotion should be the *only* path to production. No manual deployments, no SSH-and-deploy. Everything through the pipeline.

---

### 2. Matrix Strategy — Multi-Service Builds (~15 min)

**Workflow file:** [`workflows/13-matrix-multi-service.yml`](workflows/13-matrix-multi-service.yml) | [Runnable version](../.github/workflows/13-matrix-multi-service.yml)

Key concepts to cover:

- **Dynamic matrix generation** — The `detect-changes` job uses `git diff` to determine which services changed, then outputs a JSON matrix consumed by the build job. This means only changed services are built, saving runner time. All services are defined with metadata: directory, runtime (python/node/go), and port.
- **`fromJSON()` for dynamic matrices** — `strategy: { matrix: ${{ fromJSON(needs.detect-changes.outputs.matrix) }} }` converts the JSON string into a matrix. This is the key mechanism for runtime-generated matrices — you can't achieve this with static YAML.
- **`fail-fast: false`** — All matrix jobs complete even if one fails. Essential for understanding the full scope of breakage rather than stopping at the first failure. Without this, a Python build failure would cancel the Node and Go builds.
- **Runtime-specific build steps** — The workflow detects the service runtime (Python, Node, Go) and runs the appropriate build commands. Each service gets its own parallel job with the right toolchain.
- **Fan-in integration gate** — The `integration-gate` job depends on all matrix builds via `needs: build`. It only passes if every service built successfully. This single status check tells you whether the entire monorepo is healthy, even though individual services were built in parallel.
- **Force-build override** — The `force_all` boolean input rebuilds all services regardless of what changed. Useful for full rebuilds after dependency updates or infrastructure changes.

> **Demo walkthrough:**
> 1. Show the detect-changes job: how git diff produces a JSON matrix
> 2. Trigger the workflow and show parallel build jobs in the Actions UI
> 3. Explain `fail-fast: false`: "One failure doesn't cancel the others"
> 4. Show the integration-gate fan-in job collecting results from all builds
> 5. Discuss: multi-service CI for teams with monorepos — when to use matrix vs separate workflows

> **When to use matrix vs. separate workflows:**
> - Matrix: Same pipeline logic, different parameters (services, OS, language versions)
> - Separate workflows: Fundamentally different build processes per service

---

### 3. Separation of Concerns / Team Ownership (~15 min)

**Workflow file:** [`workflows/14-separation-of-concerns.yml`](workflows/14-separation-of-concerns.yml) | [Runnable version](../.github/workflows/14-separation-of-concerns.yml)

Key concepts to cover:

- **Team ownership model** — Each pipeline stage is owned by a different team: App Team (build and test), Security Team (vulnerability scanning), GRC Team (compliance validation), Platform Team (deployment and infrastructure). Each team is responsible for the quality and maintenance of their stage.
- **Independent development** — In a full implementation, each stage would be a reusable workflow that can be developed, tested, and versioned independently by the owning team. The App Team can update build logic without touching security scanning, and vice versa.
- **Central update propagation** — When a team updates their reusable workflow, ALL consumer repos get the update automatically on the next run. No individual PRs needed. This is how the Security Team can roll out a new vulnerability scanner to every repo in the organization with a single change.
- **Required workflow enforcement** — Compliance stages (GRC, Security) can be enforced via org rulesets so they can't be bypassed. Application teams must pass these gates, but they don't own or maintain the gate logic.
- **Thin orchestrators** — Application teams write a small caller workflow that composes centrally-maintained stages. The caller says *what* to build and *where* to deploy; the platform provides the *how*.
- **Summary with ownership mapping** — The workflow generates a table mapping each stage to its owning team, making the boundaries explicit and auditable.

> **Demo walkthrough:**
> 1. Trigger via `workflow_dispatch` and walk through the 4 stages (build -> security -> compliance -> deploy)
> 2. Highlight the ownership boundaries — what each team owns vs doesn't own
> 3. Show the summary table mapping stages to teams
> 4. Discuss: "This is the OneFlow model — centralized stages, distributed consumption"

> **OneFlow connection:** This is exactly how OneFlow works. Platform, security, and compliance teams maintain their stages centrally. App teams compose them via thin callers. Understanding this helps developers see where they can contribute enhancements.

---

### 4. Pipeline Guardrails — Defense in Depth (~15 min)

**Workflow file:** [`workflows/15-pipeline-guardrails.yml`](workflows/15-pipeline-guardrails.yml) | [Runnable version](../.github/workflows/15-pipeline-guardrails.yml)

Key concepts — 7 guardrails for deployment pipeline security:

| # | Guardrail | Implementation | Why It Matters |
|---|-----------|----------------|----------------|
| 1 | **Least-privilege permissions** | Explicit `permissions:` block — only `contents: read` and `deployments: write` | Limits blast radius if a step is compromised or a dependency is malicious. Everything not listed is denied. |
| 2 | **Concurrency control** | `concurrency:` group per environment with `cancel-in-progress: false` | Prevents overlapping deployments that could leave infrastructure in an inconsistent state. Queues rather than cancels. |
| 3 | **Timeout enforcement** | `timeout-minutes:` on every job (5, 10, 30 min) | Prevents runaway jobs on self-hosted runners from consuming resources indefinitely. Critical for shared runner pools. |
| 4 | **Input validation** | Regex checks on app name (alphanumeric + hyphens), image tag format (`name:sha`), environment enum | Catches bad inputs early before they cause partial deployments or confusing errors downstream. |
| 5 | **Immutable artifacts** | Same artifact promoted through all environments — digest and signature verification | Ensures what you tested is what you deploy. Prevents "works in staging, breaks in prod" caused by different builds. |
| 6 | **SHA-pinned actions** | `actions/checkout@11bd71901bbe5b1630ceea73d27597364c9af683` not just `@v4` | Prevents supply chain attacks where someone moves a tag to malicious code. A SHA is immutable — it always points to the same code. |
| 7 | **CODEOWNERS protection** | `.github/CODEOWNERS` requires platform team review on workflow changes | Prevents unauthorized pipeline modifications. Combined with branch protection, this ensures workflow changes go through the right team. |

> **Demo walkthrough:**
> 1. Walk through the workflow YAML, pointing out each guardrail inline (they're labeled with comments)
> 2. Highlight the SHA-pinned checkout action vs tag-only pinning — "If someone moves the v4 tag to malicious code, what happens?"
> 3. Show the input validation job — regex patterns for app name and image tag format
> 4. Show the `.github/CODEOWNERS` file and explain how it combines with branch protection
> 5. Trigger the workflow and show the validation -> verification -> deploy progression
> 6. Show the summary table listing all 7 guardrails

> **Key distinction:** This workflow covers **deployment pipeline security** — defense-in-depth for your CI/CD infrastructure. It is about protecting the pipeline itself, not just the code that flows through it.

---

## Enterprise Workflow Design Principles

| Principle | Description |
|-----------|-------------|
| **Immutable artifacts** | Build once; promote the same artifact through environments |
| **Least privilege** | Every workflow declares minimal `permissions:` |
| **Separation of concerns** | Build, test, scan, deploy are independent stages owned by different teams |
| **Centralized templates** | Reusable workflows in a shared repo, versioned with tags |
| **Defense in depth** | Required workflows + environment protections + CODEOWNERS + SHA pinning |
| **Observability** | Every pipeline generates `GITHUB_STEP_SUMMARY` reports |
| **Idempotency** | Pipelines can be safely re-run without side effects |

---

## Key Takeaways

1. **Environment promotion needs guardrails** — Concurrency groups, approval gates, promotion IDs, and automatic rollback
2. **Dynamic matrix strategies reduce duplication** — One definition, many parallel configurations, only build what changed
3. **Separation of concerns scales teams** — Clear ownership boundaries let teams move independently while maintaining consistency
4. **Defense-in-depth protects pipelines** — Layered guardrails (permissions, pinning, validation, immutability) prevent supply chain and configuration attacks
5. **OneFlow embodies these patterns** — Contributing enhancements to OneFlow amplifies the impact across the organization

---

## Discussion Prompts

- Which of these patterns would have the highest impact if added to OneFlow?
- How does your team draw ownership boundaries in the pipeline today? Could clearer separation of concerns help?
- Which of the 7 pipeline guardrails are you already using? Which ones are missing?
- How do you handle environment promotion today — fully automated, manual, or a mix?
- Should OneFlow enforce SHA-pinned actions by default?

---

## Preparation Checklist

- [ ] Self-hosted runner available with `[self-hosted, linux]` labels
- [ ] GitHub environments created with protection rules (for promotion demo)
- [ ] Docker available on the runner (for build stages)
- [ ] `.github/CODEOWNERS` file configured (for guardrails demo)
- [ ] At least one previous workflow run completed (for showing the Actions UI)
