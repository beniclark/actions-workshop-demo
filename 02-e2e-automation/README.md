# Module 2 — End-to-End Workflow Automation

> **Duration:** ~60 minutes
> **Focus:** Complete CI/CD pipeline from lint through production deployment

---

## Learning Objectives

1. Build a multi-stage CI pipeline with lint, parallel tests, and Docker build
2. Implement a CD pipeline with progressive environment promotion and approval gates
3. Understand job outputs, artifacts, and concurrency groups for deployment safety
4. Combine CI/CD into a single workflow with conditional deployment gating

---

## OneFlow Context

> **This is what OneFlow provides as a standard pipeline.** The workflows in this module
> demonstrate the underlying GitHub Actions capabilities that power OneFlow. Understanding
> these primitives helps developers:
>
> - **Debug** pipeline failures by understanding what's happening under the hood
> - **Identify enhancements** they could contribute to the OneFlow framework
> - **Appreciate** why standardization matters at enterprise scale
>
> As you walk through these demos, think about which patterns are already in OneFlow,
> and which could be added as new capabilities.

---

## Talking Points

### 1. CI Pipeline — Build & Test (~20 min)

**Workflow file:** [`workflows/04-ci-build-test.yml`](workflows/04-ci-build-test.yml) | [Runnable version](../.github/workflows/04-ci-build-test.yml)
**Sample app:** [`app.py`](../app.py) (root level)

Key concepts to cover:

- **Multi-trigger strategy** — `push` to main and feature branches, `pull_request` to main, and `workflow_dispatch` for manual runs. Feature branch pushes trigger CI without deployment, while main-branch pushes can trigger the full pipeline.
- **Parallel job execution** — `lint`, `unit-tests`, and `integration-tests` all run in parallel (no `needs:` between them). This minimizes pipeline time. The `docker-build` job depends on all three via `needs: [lint, unit-tests, integration-tests]`.
- **Dependency caching** — `actions/cache` with `hashFiles('**/requirements.txt')` key stores pip packages between runs. The `restore-keys` fallback (`${{ runner.os }}-pip-`) provides partial cache hits even when dependencies change.
- **JUnit test reporting** — pytest generates `--junitxml=test-results/unit.xml` for structured test output. Uploaded as an artifact with `if: always()` so test results are available even when tests fail.
- **Integration test lifecycle** — The app is started in the background (`python app.py &`), health-checked, tested against real HTTP endpoints (`/health`, `/items`), then killed with `if: always()`. This tests the deployed application, not just the code. Critical for self-hosted runners to avoid orphan processes.
- **Docker build and verify** — Builds the image with a SHA-based tag, then starts a container, health-checks it, and tears it down. Proves the image works before any deployment.
- **Job outputs** — The Docker build step uses `$GITHUB_OUTPUT` to expose the `sha_short` tag for downstream consumption. This is how data flows between jobs.
- **Step summary** — The final job writes a CI Build Summary table to `GITHUB_STEP_SUMMARY` with app name, image tag, ref, and status of each stage.

> **Demo walkthrough:**
> 1. Open the workflow file — walk through the 4-job structure
> 2. Trigger via `workflow_dispatch` or push a commit to main
> 3. In the Actions UI, show lint/unit/integration running in parallel
> 4. Click into the integration test job: show app start, health check, endpoint tests, cleanup
> 5. Show the Docker build verification (container start, health check, teardown)
> 6. Show the CI summary in the step summary tab

---

### 2. CD Pipeline — Multi-Environment Deployment (~20 min)

**Workflow file:** [`workflows/05-cd-deploy.yml`](workflows/05-cd-deploy.yml) | [Runnable version](../.github/workflows/05-cd-deploy.yml)

Key concepts to cover:

- **`workflow_run` trigger** — Automatically fires when the CI workflow completes on main. The `if:` condition checks `github.event.workflow_run.conclusion == 'success'` to skip deployment when CI fails. Also supports `workflow_dispatch` for manual deployments with an optional image tag override.
- **Preflight job with outputs** — Resolves the image tag (from input or SHA), verifies the image exists, and exposes `image_tag` and `deploy_sha` as outputs consumed by all deploy jobs. This is a common pattern for pipeline initialization.
- **Progressive deployment** — Dev (deploys immediately, no protection) -> Staging (canary strategy — 10% -> 50% -> full rollout with error rate monitoring) -> Production (rolling update with max 25% unavailable, health check grace period).
- **Environment binding** — Each deploy job uses `environment: dev/staging/production` to bind to GitHub environments. This activates protection rules, scopes secrets, and creates deployment records visible in the repo.
- **Deployment strategies** — Dev uses a direct deploy. Staging demonstrates a canary deployment with phased rollout. Production uses a rolling update strategy. Explain that these strategies minimize risk at different stages.
- **Pre-deployment snapshot** — Production takes a snapshot before deploying, establishing a rollback point. The `if: failure()` step triggers automatic rollback when post-deployment verification fails.
- **Extended verification** — Staging checks response time against thresholds (45ms < 200ms), error rates (0.01% < 1%), and DB connectivity. These health metrics determine if promotion to production is safe.

> **Demo walkthrough:**
> 1. Explain the `workflow_run` trigger — "This fires automatically when CI passes"
> 2. Walk through the preflight job — image tag resolution and verification
> 3. Show progressive deployment: Dev (immediate) -> Staging (canary) -> Production (rolling)
> 4. If environments have protection rules, show the approval gate pausing the workflow
> 5. Highlight the rollback step on production — `if: failure()` triggers automatic rollback
> 6. Show the deployment summary in the step summary tab

**Key moment:** When the workflow pauses for production approval, pause the demo: "This is where governance meets automation. OneFlow enforces this consistently across all teams."

---

### 3. Full Pipeline — Everything Together (~20 min)

**Workflow file:** [`workflows/06-full-pipeline.yml`](workflows/06-full-pipeline.yml) | [Runnable version](../.github/workflows/06-full-pipeline.yml)

Key concepts to cover:

- **Single-file pipeline** — Complete CI/CD in one workflow file. Good for simpler projects where splitting into separate CI and CD workflows adds unnecessary complexity. Compare with the split approach in workflows 04+05.
- **Conditional deployment** — `deploy` boolean input controls whether deployment runs after build/test. `environment` choice input selects the target. This pattern gives operators control over the pipeline without modifying the workflow.
- **When to split vs combine** — Single-file pipelines are easier to understand and maintain for small teams. Split pipelines (separate CI and CD) scale better for larger teams where different people own build vs deploy, or where CD needs to trigger from multiple CI pipelines.

> **Demo walkthrough:**
> 1. Show how the full pipeline compares to the split CI/CD approach (workflows 04+05)
> 2. Trigger with `deploy: true` and `environment: dev`
> 3. Discuss: "When is a single-file pipeline appropriate vs splitting CI and CD?"

> **OneFlow context:** For most projects, you won't need to build this yourself — OneFlow handles the orchestration. But understanding the full picture helps when debugging pipeline issues or proposing new features for the framework.

---

## Pipeline Visualization

```
CI Pipeline (04):

  +-----------+
  |   Lint    |---\
  +-----------+    \
                    +----> +--------------+
  +-----------+   /        | Docker Build |
  | Unit Test |--/         +--------------+
  +-----------+   \       /
                    +----/
  +-----------+   /
  | Int. Test |--/
  +-----------+

CD Pipeline (05):

  +-----------+     +------------+     +---------+     +---------+
  | Preflight | --> | Deploy Dev | --> | Deploy  | --> | Deploy  |
  |           |     |            |     | Staging |     |  Prod   |
  +-----------+     +------------+     +---------+     +---------+
                                        (Canary)    (Rolling + Approval)
```

---

## Key Takeaways

1. **Parallel stages reduce CI time** — Lint, unit tests, and integration tests run simultaneously
2. **Job outputs connect pipeline stages** — Image tags, test results, and SHA values flow between jobs via `$GITHUB_OUTPUT`
3. **Environments provide deployment safety** — Protection rules, scoped secrets, and deployment tracking in the GitHub UI
4. **Progressive deployment reduces risk** — Each environment uses a strategy appropriate to its blast radius
5. **OneFlow encapsulates these patterns** — Standard pipelines reduce duplication and enforce consistency across teams

---

## Discussion Prompts

- What stages in this pipeline does your team currently skip? What's the impact?
- How could integration testing be standardized as a OneFlow stage?
- What additional stages would be valuable? (e.g., performance testing, security scanning, compliance)
- How do you handle rollbacks when a deployment fails?

---

## Preparation Checklist

- [ ] Sample app at the repository root (`app.py`, `requirements.txt`, `Dockerfile`, `tests/`)
- [ ] Self-hosted runner with Docker installed
- [ ] Environments configured: `dev`, `staging`, `production`
- [ ] `production` environment with required reviewers (optional, for approval gate demo)
- [ ] Port 5000 available on the runner (for integration test)
