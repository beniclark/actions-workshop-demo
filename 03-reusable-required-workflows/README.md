# Module 3 — Reusable & Required Workflows

> **Duration:** ~45 minutes
> **Focus:** Eliminate duplication with reusable workflows, enforce standards with required workflows

---

## Learning Objectives

1. Create reusable workflows with `workflow_call` and typed input/output contracts
2. Compose reusable workflows into complete pipelines via caller workflows
3. Understand secret passing strategies (`secrets: inherit` vs explicit declarations)
4. Enforce organizational standards with required workflows and governance gates

---

## OneFlow Context

> **This composable pattern is how OneFlow works internally.** OneFlow provides reusable
> CI, security, and deployment workflows that teams consume through a thin caller workflow.
> Understanding this architecture helps developers:
>
> - See how new reusable stages could be contributed to OneFlow
> - Understand the input/output contracts that make reusable workflows reliable
> - Appreciate the governance model that required workflows enable

---

## Talking Points

### 1. Reusable Build Workflow (~10 min)

**Workflow file:** [`workflows/07-reusable-build.yml`](workflows/07-reusable-build.yml) | [Runnable version](../.github/workflows/07-reusable-build.yml)

Key concepts to cover:

- **`workflow_call` trigger** — This is what makes a workflow reusable. It cannot be triggered directly from the Actions UI or by events — it can only be called from another workflow using `uses:`. Think of it as defining a function that other workflows invoke.
- **Typed inputs** — `app_name` (string, required), `python_version` (string, default "3.12"), `run_tests` (boolean). Inputs create a clear contract between the reusable workflow and its callers. The `type:` field enforces validation — passing a string where a boolean is expected will fail.
- **Optional inputs with defaults** — `working_directory`, `dockerfile_path`, and `python_version` all have defaults. This keeps the caller simple for standard cases while allowing customization when needed.
- **Secrets block** — `secrets: { registry_url: { required: false } }` declares what credentials the workflow needs. This is the secret contract — callers know exactly which secrets to provide.
- **Output contracts** — `outputs: { image_tag, test_passed }` exposes results to the caller. The caller accesses these via `needs.<job-id>.outputs.image_tag`. This is how data flows back from reusable workflows.

> **Demo walkthrough:**
> 1. Open the workflow — highlight `on: workflow_call` and the inputs block
> 2. Explain: "This workflow can't be triggered directly. It's a building block."
> 3. Walk through the typed inputs: show how defaults reduce boilerplate for callers
> 4. Point out the outputs block: "This is how the build result gets back to the caller"

---

### 2. Reusable Security Scan (~10 min)

**Workflow file:** [`workflows/08-reusable-security-scan.yml`](workflows/08-reusable-security-scan.yml) | [Runnable version](../.github/workflows/08-reusable-security-scan.yml)

Key concepts to cover:

- **Output contracts** — The `outputs:` block exposes `scan-result` (pass/fail) and `vulnerabilities-found` to callers. This is how reusable workflows communicate results back. The caller can use these outputs in `if:` conditions to gate downstream jobs.
- **Configurable severity threshold** — The `severity-threshold` input lets callers set their risk tolerance (e.g., `high` vs `critical`) without modifying the scan workflow. One workflow, many policies.
- **Centralized security gate** — One scan workflow used across all repositories ensures consistent security standards. When the security team updates the scan logic, every consuming repository gets the update automatically — no PRs to individual repos.
- **Scan stages** — The workflow runs dependency audit, license checking, and a SAST placeholder in sequence. In production, these would call real tools (`npm audit`, `snyk`, `semgrep`, etc.).

> **Demo walkthrough:**
> 1. Show the outputs block and how it maps to job outputs
> 2. Explain the configurable severity threshold: "Different teams can set different thresholds"
> 3. Discuss: "OneFlow could provide this as a standard security stage — one update, every repo benefits"

---

### 3. Reusable Deployment Workflow (~10 min)

**Workflow file:** [`workflows/09-reusable-deploy.yml`](workflows/09-reusable-deploy.yml) | [Runnable version](../.github/workflows/09-reusable-deploy.yml)

Key concepts to cover:

- **Dynamic environment binding** — `environment: { name: ${{ inputs.target-environment }} }` binds the job to whichever environment the caller specifies. One workflow handles dev, staging, and production deployments — the same code, different configuration. The environment determines which secrets are available and which protection rules apply.
- **Required secrets** — The `secrets:` block with `required: true` ensures callers provide necessary credentials. This is the secret contract. If a caller forgets to pass `deploy_token`, the workflow fails immediately with a clear error rather than failing mid-deployment.
- **`secrets: inherit` vs explicit** — `inherit` passes all caller secrets through automatically. Explicit declarations are more secure and self-documenting — you can see exactly what credentials the workflow needs by reading the `secrets:` block. Prefer explicit for production workflows.
- **Input validation** — A `validate` job checks inputs before deployment begins. Catching bad inputs early prevents wasted runner time and partial deployments.
- **Deployment flow** — validate -> deploy -> smoke-test. The smoke test verifies the deployment succeeded, providing fast feedback before promoting to the next environment.

> **Demo walkthrough:**
> 1. Show the dynamic environment binding — "One workflow deploys to any environment"
> 2. Compare `secrets: inherit` vs explicit secret passing — discuss security trade-offs
> 3. Walk through the validate -> deploy -> smoke-test flow

---

### 4. The Orchestrator / Caller Workflow (~10 min)

**Workflow file:** [`workflows/10-caller-orchestrator.yml`](workflows/10-caller-orchestrator.yml) | [Runnable version](../.github/workflows/10-caller-orchestrator.yml)

Key concepts to cover:

- **Composition via `uses:`** — The caller invokes reusable workflows (07, 08, 09) using `uses: ./.github/workflows/07-reusable-build.yml`. Each `uses:` entry is a complete job that delegates to the reusable workflow. The caller provides inputs and secrets; the reusable workflow does the work.
- **Parallel execution** — Build (07) runs first, then Security (08) runs after build completes to scan the built artifacts. Deploy (09) requires both to pass. If security scanning didn't depend on the build output, they could run in parallel.
- **Sequential deployment** — The deploy job uses the reusable deploy workflow (09) with different inputs for each environment. In a full pipeline, you'd have deploy-dev -> deploy-staging -> deploy-prod as separate jobs.
- **Compact vs monolithic** — Compare the size of this caller workflow to the full pipeline in Module 2. Same pipeline capabilities, fraction of the code. The reusable workflows contain the implementation details; the caller just orchestrates.
- **This is the OneFlow pattern** — OneFlow provides reusable CI, security, and deploy workflows. Teams write a thin caller like this one. When OneFlow updates a stage, every consuming team gets the update automatically.

```
10-caller-orchestrator.yml
  +-- calls -> 07-reusable-build.yml          (build stage)
  +-- calls -> 08-reusable-security-scan.yml   (security gate)
  +-- calls -> 09-reusable-deploy.yml          (deployment)
```

> **Demo walkthrough:**
> 1. Show how compact the caller is compared to the full pipeline in Module 2
> 2. Trigger the workflow — show the nested workflow visualization in the Actions UI
> 3. Highlight the `with:` blocks passing inputs and the `secrets:` blocks passing credentials
> 4. **Key message:** "This is exactly how OneFlow works. You write a thin caller; OneFlow provides the reusable stages."

---

### 5. Required Compliance & Governance (~10 min)

**Workflow file:** [`workflows/11-required-compliance.yml`](workflows/11-required-compliance.yml) | [Runnable version](../.github/workflows/11-required-compliance.yml)

Key concepts to cover:

- **Required workflows** — Org admins can mandate specific workflows run on all PRs via repository rulesets. No team can skip or modify them. The workflow triggers on `pull_request` and also supports `workflow_call` with a `strict_mode` input for reuse.
- **License compliance** — Checks dependency licenses against an approved list (MIT, Apache-2.0, BSD, ISC) and a blocked list (GPL-3.0, AGPL-3.0, SSPL). In production, use tools like `license_finder`, `fossa`, or `pip-licenses` to scan real dependency trees.
- **Security policy checks** — Verifies that required governance files exist in the repository: `SECURITY.md`, `CODEOWNERS`, and `README.md`. These are organizational hygiene checks that ensure every repo meets a minimum documentation standard.
- **Code quality gate** — PR size check that warns when file count exceeds a threshold. Large PRs are harder to review and more likely to introduce bugs. Also audits workflow permissions for overly broad token access.
- **Audit trail** — Generates a compliance record with full metadata: repository, PR number, author, SHA, timestamp, and all gate results. In production, POST this payload to an internal audit/SIEM system for compliance reporting.
- **Compliance summary** — All gate results rendered in `GITHUB_STEP_SUMMARY` as a table for visibility. Reviewers can see compliance status at a glance without reading logs.

> **Demo walkthrough:**
> 1. Open a PR to trigger the workflow
> 2. Walk through the gates: license check -> security policy -> code quality -> audit trail
> 3. Show the compliance summary in the step summary tab
> 4. Navigate to repo Settings > Rulesets: explain how required workflows are configured at the org level
> 5. Discuss: "Which of these gates should be required across all repos?"
> 6. Reference `docs/required-workflows-setup.md` for detailed setup instructions

---

## Reusable Workflow Limitations

Important constraints to mention during the workshop:

| Limitation | Details |
|-----------|---------|
| Max nesting depth | 4 levels (caller -> reusable -> reusable -> reusable) |
| Max workflow calls | 20 unique reusable workflows per workflow file |
| Environment variables | Caller `env:` is NOT passed to reusable workflows — use inputs instead |
| `GITHUB_TOKEN` permissions | Inherited from caller, not set in the reusable workflow |
| Trigger restriction | `workflow_call` workflows cannot have other triggers (except when combined with `pull_request` for dual-use) |

---

## Key Takeaways

1. **Reusable workflows eliminate duplication** — Write once, call from many repositories
2. **Input/output contracts** — Typed inputs and outputs create reliable interfaces between workflows
3. **Required workflows enforce governance** — Org admins ensure consistent quality and security across all repositories
4. **Separation of concerns** — Scanning, enforcement, and deployment are independent, composable pieces
5. **This is the OneFlow model** — Reusable workflows are the foundation of standard pipelines

---

## Discussion Prompts

- What reusable workflows would your team benefit from? (CI, security, deploy, notifications?)
- How could you contribute a new reusable stage to OneFlow?
- What governance gates should be required across all repositories?
- How do you balance standardization with team-specific customization?

---

## Preparation Checklist

- [ ] Self-hosted runner available with `[self-hosted, linux]` labels
- [ ] GitHub environments created: `dev`, `staging`, `production`
- [ ] A repository secret named `DEPLOY_TOKEN` (any value) for the deploy workflow
- [ ] Optional: repository ruleset configured to demonstrate required workflows
- [ ] Reference: `docs/required-workflows-setup.md` for ruleset setup instructions
