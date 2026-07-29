## What changed

<!-- Short summary of the change and the business reason. -->

## Salesforce impact

- [ ] Apex classes changed
- [ ] LWC changed
- [ ] Custom objects / fields changed
- [ ] Permission sets or sharing rules changed

## Code review checklist

- [ ] Queries are bulkified (no SOQL or DML inside loops)
- [ ] `with sharing` is used unless there is a documented reason not to
- [ ] CRUD and FLS are enforced before read/write of records
- [ ] No dynamic SOQL built from unescaped user input
- [ ] No hardcoded credentials, endpoints, or record IDs
- [ ] No PII or secrets written to debug logs
- [ ] Apex tests assert real behavior (not just execute code for coverage)

## Testing

<!-- How was this validated? Include org type and test results. -->

## Rollback plan

<!-- How do we revert safely if this causes an incident? -->
