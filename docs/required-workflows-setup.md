# Required Workflows — Setup Guide

> Step-by-step instructions for configuring required workflows via organization rulesets.

---

## Prerequisites

- Organization admin access (GitHub Enterprise Cloud or Server)
- A centrally managed workflow file (e.g., `11-required-compliance.yml`)
- The workflow must be in a repository accessible to target repositories

---

## Setup Steps

### 1. Create the Required Workflow

Place your compliance/governance workflow in a central repository (e.g., `org/.github` or `org/pipeline-templates`). The workflow must have `on: pull_request` or `on: workflow_call` as a trigger.

### 2. Configure the Ruleset

1. Go to **Organization Settings** > **Repository** > **Rulesets**
2. Click **New ruleset** > **New branch ruleset**
3. Name it (e.g., "Required compliance checks")
4. Under **Target repositories**, select:
   - **All repositories**, or
   - Specific repositories by name/pattern/visibility
5. Under **Branch targeting**, select the default branch
6. Under **Rules**, enable **Require workflows to pass**
7. Click **Add workflow** and select your compliance workflow
8. Set enforcement to **Evaluate** first (monitor without blocking)

### 3. Rollout Strategy

| Phase | Enforcement | Scope | Duration |
|-------|-------------|-------|----------|
| Pilot | Evaluate | 3-5 volunteer repos | 2 weeks |
| Expand | Evaluate | All non-critical repos | 2 weeks |
| Enforce pilot | Active | Original pilot repos | 1 week |
| Full rollout | Active | All target repos | Ongoing |

---

## Required Workflows vs Required Status Checks

| | Required Workflows | Required Status Checks |
|---|---|---|
| **Scope** | Org-level rulesets | Per-repo branch protection |
| **Management** | Central (org admins) | Distributed (repo admins) |
| **What's enforced** | Specific workflow files | Named check results |
| **Override** | Org admin only | Repo admin (if configured) |
| **Best for** | Organization-wide governance | Repo-specific quality gates |

Use both together: required workflows for org-wide governance, required status checks for repo-specific gates.

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Workflow doesn't appear as selectable | Ensure it has `on: pull_request` trigger and is in an accessible repo |
| Rule evaluates but doesn't block | Switch enforcement from Evaluate to Active |
| PRs blocked unexpectedly | Check ruleset targeting — may be matching repos you didn't intend |
| Runner failures | Verify self-hosted runners are online and have correct labels |

---

## Best Practices

- **Version your required workflows** — Use tags (e.g., `@v1`) so updates don't break consumers unexpectedly
- **Keep required workflows fast** — Long-running required checks slow down every PR across the org
- **Use Evaluate mode first** — Monitor for false positives before enforcing
- **Document exceptions** — If a repo needs an exception, document why and set an expiry date
- **Assign ownership** — One team should own the required workflow and its evolution
