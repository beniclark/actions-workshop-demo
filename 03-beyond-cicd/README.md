# Module 3 — Beyond CI/CD: Event-Driven Automation

> **Duration:** ~60 minutes
> **Focus:** Non-CI workflow triggers, event-driven automation, internal tool integration, cross-team collaboration

---

## Learning Objectives

1. Use event-based triggers (`issues`, `issue_comment`, `schedule`, `repository_dispatch`) to automate operational tasks
2. Build workflows that bridge team silos by reacting to events from other teams and internal tools
3. Integrate internal AI and developer tools into the Actions platform without third-party dependencies
4. Create composite actions that wrap internal tools for inner-source consumption

---

## OneFlow Context

> **Note:** OneFlow handles CI/CD pipelines across 3,000+ repos. But Actions can do much more.
> This module showcases capabilities *outside* the CI/CD pipeline — event-driven automation,
> internal tool integration, and cross-team workflows that complement OneFlow rather than
> replace it. These patterns let teams extend their automation beyond build-test-deploy.

---

## Talking Points

### 1. Issue Triage Automation (~15 min)

**Workflow file:** [`workflows/16-issue-triage.yml`](workflows/16-issue-triage.yml) | [Runnable version](../.github/workflows/16-issue-triage.yml)

Key concepts to cover:

- **Event triggers beyond push/PR** — `issues: [opened, labeled]` and `issue_comment: [created]` react to project management events, not code changes. Actions is an event platform, not just a CI tool.
- **Auto-labeling with keyword matching** — The workflow scans issue title and body for keywords (error, crash, bug → `bug`; feature, request → `enhancement`; how, help → `question`; vulnerability, CVE → `security`). This replaces manual triage work.
- **Team routing** — Based on the auto-applied label, the workflow assigns the issue to the appropriate team and sets an SLA expectation. Shows how workflows can encode process knowledge.
- **Welcome comments** — A templated response is posted automatically when an issue is created. Shows how to use the `github.event.issue` context to personalize responses. Reduces response time to zero.
- **Step summaries as reports** — Each job writes to `GITHUB_STEP_SUMMARY` with statistics. The summary tab becomes a triage dashboard showing classification results, routing decisions, and SLAs.

> **Demo walkthrough:**
> 1. Open the workflow file — highlight the `issues` and `issue_comment` triggers
> 2. Create a new issue with the title "Bug: Application crashes on startup" — watch the auto-label
> 3. Show the Actions run: auto-label job classifies it as `bug`, route job assigns to the team
> 4. Show the welcome comment posted automatically on the issue
> 5. Use `workflow_dispatch` to demonstrate the manual trigger with a custom issue number
> 6. Discuss: What triage rules would you automate in your repos?

---

### 2. Scheduled Operations (~10 min)

**Workflow file:** [`workflows/17-scheduled-ops.yml`](workflows/17-scheduled-ops.yml) | [Runnable version](../.github/workflows/17-scheduled-ops.yml)

Key concepts to cover:

- **Cron triggers** — `schedule: cron: "0 9 * * 1"` runs every Monday at 9 AM UTC. Actions supports any cron expression. Show how this replaces manual "Monday morning health check" routines.
- **Repository governance checks** — The workflow audits 8 governance items: README, LICENSE, CODEOWNERS, branch protection, issue templates, dependabot, security policy, and CI workflows. Generates a health score (0-8). This is operational automation that runs itself.
- **Dependency freshness auditing** — `pip list --outdated` generates a report of stale dependencies. In production, this could open issues for packages more than N versions behind.
- **Stale issue detection** — Identifies issues untouched for N days. Simulated in demo; in production, the `actions/stale` action or a custom script would close or label them.
- **Dashboard via GITHUB_STEP_SUMMARY** — The final job combines all reports into a Markdown dashboard. The summary tab becomes a weekly operations report that anyone can check.

> **Demo walkthrough:**
> 1. Trigger via `workflow_dispatch` (don't wait for the cron schedule)
> 2. Show the 4-job pipeline: health check → dependency audit → stale issues → dashboard
> 3. Click into the summary tab — walk through the governance score and dependency report
> 4. Discuss: What operational tasks does your team do manually every week? Could they be cron workflows?

---

### 3. Cross-Team Integration (~15 min)

**Workflow file:** [`workflows/18-cross-team-integration.yml`](workflows/18-cross-team-integration.yml) | [Runnable version](../.github/workflows/18-cross-team-integration.yml)

Key concepts to cover:

- **`repository_dispatch` trigger** — External events sent via the GitHub API. Any system (another workflow, a CLI tool, a webhook) can trigger this workflow by POSTing to `/repos/{owner}/{repo}/dispatches`. The `types` filter allows routing different events to different logic.
- **Event-typed routing** — The workflow accepts `tool-completed`, `model-updated`, and `scan-finished` event types. Each triggers different processing logic. This is how teams communicate: Team A finishes a task and dispatches an event; Team B's workflow picks it up.
- **Cross-team payload** — `client_payload` carries structured data between teams. The workflow parses `source_team`, `event_type`, and custom fields. This is the contract between teams.
- **Bridging silo'd tools** — The key customer scenario: an ML team updates a model, a data team runs a scan, a security team completes an audit — each dispatches an event that downstream teams react to. No meetings, no tickets, no manual handoffs.
- **Sending events** — The `scripts/send-dispatch.sh` helper shows how to trigger this workflow from another repo or CLI. Uses `gh api` or `curl` with a PAT.

> **Demo walkthrough:**
> 1. Open the workflow file — highlight the `repository_dispatch` trigger and event types
> 2. Use `workflow_dispatch` to simulate a `model-updated` event from the ML team
> 3. Walk through the event processing: receive → type-specific handling → notification
> 4. Show the ASCII architecture diagram in the step summary
> 5. Show `scripts/send-dispatch.sh` — explain how Team A would trigger this from their workflow
> 6. Discuss: What cross-team handoffs happen in your org? Could `repository_dispatch` replace them?

---

### 4. Internal AI Tool Integration (~20 min)

**Workflow file:** [`workflows/19-ai-tool-integration.yml`](workflows/19-ai-tool-integration.yml) | [Runnable version](../.github/workflows/19-ai-tool-integration.yml)

Key concepts to cover:

- **Actions as integration glue** — The workflow calls an internal AI code review service, processes the results, and posts findings back to the PR. Actions is the glue between the tool (owned by the ML team) and the developer workflow (PR review).
- **No third-party actions needed** — The entire integration uses shell scripts and the composite action. No marketplace actions required, no Security Assessment process, no external dependencies. This matters for enterprises with strict security policies.
- **Custom composite action** — The `internal-tool-wrapper` action (`.github/actions/internal-tool-wrapper/`) wraps an internal CLI tool. One team builds and maintains the action; other teams consume it with `uses: ./.github/actions/internal-tool-wrapper`. This is the inner-source pattern.
- **Structured output parsing** — The mock AI service returns JSON with findings. The workflow parses this with `grep`/`sed` and passes data between jobs via `outputs`. Shows how to build machine-readable interfaces between tools and workflows.
- **PR-triggered automation** — `pull_request: [opened, synchronize]` means every PR gets an AI review automatically. Developers don't need to do anything — the AI review is integrated into their existing workflow.

> **Demo walkthrough:**
> 1. Open the workflow file — highlight the three jobs: AI review, composite action, report
> 2. Open `.github/actions/internal-tool-wrapper/action.yml` — walk through the composite action anatomy
> 3. Trigger via `workflow_dispatch` with different review scopes (full, security-only, style-only)
> 4. Show the step summary: architecture diagram, patterns list, and "Why This Matters for Visa" section
> 5. Open `scripts/mock-ai-service.sh` — show how it simulates the internal API
> 6. Discuss: What internal tools could your teams wrap as composite actions?

---

## Key Takeaways

1. **Actions is an event platform** — Not just CI/CD. Issues, comments, schedules, and external events are all triggers for automation
2. **Internal tools > third-party actions** — Wrapping internal tools as composite actions avoids Security Assessment overhead and keeps everything within your control
3. **Cross-team events bridge silos** — `repository_dispatch` lets teams communicate through automation instead of meetings and tickets
4. **Operational automation runs itself** — Governance checks, dependency audits, and triage workflows replace manual weekly tasks

---

## Discussion Prompts

- What operational tasks does your team do manually on a recurring basis? Could they be cron workflows?
- Which internal tools (AI, security scanning, compliance checking) could be wrapped as custom actions?
- How do teams in your org communicate handoffs today? Could `repository_dispatch` automate any of them?
- What issue triage rules would be most valuable to automate?

---

## Preparation Checklist

- [ ] Self-hosted runner registered with labels `[self-hosted, linux]`
- [ ] GitHub CLI (`gh`) installed on the runner for dispatch demos
- [ ] A few test issues in the repo for the triage demo
- [ ] `scripts/mock-ai-service.sh` and `scripts/send-dispatch.sh` have execute permissions
