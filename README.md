# Outdoor Media Salesforce Demo

Demo repository for Outdoor Media Group showing **code review principles** and
**Salesforce CI/CD pipelines** on GitHub.

> **This repository contains intentionally vulnerable code.** It exists only to demonstrate
> code review and code scanning. Do not deploy any of it to a real org.

## What this demonstrates

| Ask | Where it shows up |
|-----|-------------------|
| Code review principles | `CONTRIBUTING.md`, `.github/CODEOWNERS`, PR template, Copilot code review on the open PR |
| Salesforce CI/CD | `.github/workflows/pr-validate.yml`, `.github/workflows/deploy-production.yml` |
| Security scanning | `.github/workflows/codeql.yml`, `.github/workflows/apex-static-analysis.yml` |

## Important: CodeQL and Apex

**CodeQL does not support Apex.** That is a real product limitation and worth stating plainly
in the room. This repo handles it the way a real customer would:

- **CodeQL** scans the **LWC JavaScript** and the **GitHub Actions workflows** (both supported).
- **Apex** is scanned by **Salesforce Code Analyzer (PMD)**, which emits SARIF that is uploaded
  to GitHub code scanning.

Both feed the **same Security tab**, so the developer experience is one queue of alerts
regardless of which engine found the issue.

## Repository layout

```
force-app/main/default/
  classes/          Apex controllers, services, batch, tests
  lwc/              Lightning Web Components (JavaScript)
.github/
  workflows/        CodeQL, Apex PMD scan, PR validation, production deploy
  CODEOWNERS        Routes required reviewers
```

## Planted issues (for the demo)

**Apex** — detected by PMD / Copilot review:
- SOQL injection via string concatenation (`BillboardSearchController`)
- `without sharing` on controllers that expose record data
- Missing CRUD/FLS enforcement before DML
- SOQL and DML inside loops (`LeaseContractService`, `LeaseRenewalBatch`)
- Hardcoded API key/secret and cleartext HTTP endpoint (`PaymentGatewayService`)
- Card number written to debug logs
- Weak crypto: MD5 digest and a static IV
- Open redirect and unescaped HTML (`AdvertiserPortalController`)
- Tests with no meaningful assertions

**JavaScript** — detected by CodeQL:
- DOM XSS via `innerHTML` with URL-derived input
- Incomplete URL substring sanitization (`indexOf('outdoormedia.com')`)
- Hardcoded token used as a bearer credential
- Insecure randomness used for a session identifier
- Client-side unvalidated redirect

**GitHub Actions** — detected by CodeQL:
- Script injection from `pull_request_target` using untrusted PR title/body in `run:`

## Suggested demo flow (25 min)

1. **Start in the PR.** Show required checks running: validate-only deploy, Apex tests,
   CodeQL, PMD.
2. **Show Copilot code review** commenting on the Apex changes in the diff.
3. **Open the Security tab.** Show CodeQL alerts (JS + Actions) and PMD alerts (Apex)
   side by side.
4. **Show CODEOWNERS + branch protection** forcing the right reviewer on payments code.
5. **Show the deploy pipeline** and the `production` environment approval gate.
6. **Close on adoption:** wave-1 Copilot team and the security KPI GHAS would anchor.

## Before the demo — enable code scanning

This repository uses **advanced setup** for code scanning: a custom CodeQL workflow plus a
Salesforce Code Analyzer (PMD) job that uploads SARIF.

On a **public** repository, code scanning and secret scanning are available at no cost, so
both workflows upload results to the Security tab with no extra configuration.

> **Gotcha:** making a repository public can auto-enable CodeQL **default setup**, which then
> rejects this repo's custom workflow with *"CodeQL analyses from advanced configurations
> cannot be processed when the default setup is enabled."* Default setup and advanced setup
> are mutually exclusive. Turn default setup off under
> **Settings → Advanced Security → Code scanning → CodeQL analysis**, or via the API:
>
> ```bash
> gh api -X PATCH repos/OWNER/REPO/code-scanning/default-setup -f state='not-configured'
> ```

On a **private** repository, uploading results requires **GitHub Advanced Security**. If it is
not enabled, both scanners still run and still find issues — they fail only on the final
"upload to code scanning" step. Enable Advanced Security directly on the repository rather
than applying a security configuration that forces code scanning *default* setup, since a
default-setup configuration will not attach to a repository already running advanced setup.

### Current state

| Piece | Status |
|-------|--------|
| Salesforce PR validation pipeline | Working |
| Deploy pipeline + environment gate | Working |
| Copilot code review on the PR | Working — **4 inline findings** |
| CodeQL analysis (LWC JavaScript + Actions) | Working — **6 alerts** (3 critical, 3 high) |
| Apex PMD scan | Working — **104 violations** on the PR, 81 on `main` |
| Secret scanning + push protection | Enabled |

## Setup notes

The pipelines are written to run without a connected org — org-dependent steps skip cleanly
if `SF_SANDBOX_AUTH_URL` / `SF_PRODUCTION_AUTH_URL` secrets are absent, so the demo works
without wiring a real Salesforce org first.
