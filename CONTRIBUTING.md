# Contributing — Code Review Principles

These are the review standards for the Outdoor Media Salesforce codebase. They exist so review is
consistent, fast, and focused on risk rather than personal style.

## 1. Review for risk, not taste

Reviewers should prioritize, in order:

1. **Security** — injection, sharing/CRUD/FLS enforcement, secret handling
2. **Correctness** — does it do what the ticket says, including edge cases
3. **Governor limits** — bulkification, SOQL/DML in loops, heap and CPU
4. **Maintainability** — naming, structure, dead code
5. **Style** — handled by linters, not humans

## 2. Small, single-purpose pull requests

A PR should do one thing. Large PRs get shallow reviews. If a change touches more than
~400 lines of Apex, split it.

## 3. Every PR has an owner and a required reviewer

`CODEOWNERS` routes review automatically. Payments, crypto, and pipeline changes always
require a second reviewer.

## 4. Automation gates before human review

The following must pass before a human spends time on review:

- Salesforce validate-only deploy
- Apex tests (`RunLocalTests`)
- CodeQL (LWC JavaScript + GitHub Actions workflows)
- Salesforce Code Analyzer / PMD (Apex)

## 5. Apex-specific review rules

| Rule | Why it matters |
|------|----------------|
| No SOQL/DML inside loops | Governor limits; fails at scale, not in dev |
| Use bind variables, never string concatenation in SOQL | Prevents SOQL injection |
| Declare `with sharing` by default | Record-level security is not automatic in Apex |
| Check `isAccessible()` / `isUpdateable()` before read/write | FLS and CRUD are not enforced in Apex |
| Use Named Credentials, never hardcoded keys | Secrets in source are permanent once committed |
| Never log PII, card data, or tokens | Debug logs are widely readable |
| Tests must assert, not just execute | Coverage without assertions proves nothing |

## 6. Comments should be actionable

Say what to change and why. Prefer "use a bind variable here to prevent SOQL injection"
over "this looks wrong."

## 7. Definition of done

- All required checks green
- All review conversations resolved
- No new code scanning alerts of severity High or above
