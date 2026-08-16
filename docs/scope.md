# Capstone Scope Document

## Problem Statement
KijaniKiosk currently lacks a controlled multi-environment delivery path that validates application changes in an isolated staging environment before production promotion. This creates a risk that faulty changes can reach production without first being validated against staging configuration, application health checks, and runtime behaviour. This capstone will introduce a reproducible staging environment, automated staging validation, monitoring, and an approval-controlled production deployment while integrating the Week 10 serverless receipt chain.

## Track
**Track A — Infrastructure-First**

## What I Will Build
1. **Staging infrastructure:** Provision an isolated `kijani-staging` Kubernetes namespace using Terraform and configure it with Ansible.
2. **Staging application:** Deploy `kk-payments` using the existing Deployment design with staging-specific configuration, including a different `DB_HOST` from production.
3. **Controlled CI/CD:** Update Jenkins so a merge to `main` deploys to staging, runs a smoke test, and only then presents the production approval gate.
4. **Runtime monitoring:** Add a committed monitoring signal for `kk-payments` error rate and demonstrate the signal during testing.
5. **Serverless integration:** Connect staging `kk-payments` to `kk-payments-receipts-staging` and demonstrate successful processing by the Week 10 receipt chain.

## What Is Out of Scope
- **Track B's `kk-analytics` function:** excluded because this project follows Track A and the fourth-function serverless extension belongs to Track B.
- **Rewriting `kk-payments`:** the capstone extends the existing application rather than replacing its business logic.
- **Full migration to a new cloud production platform:** excluded because the capstone focuses on controlled staging-to-production delivery and integration of the existing platform components.

## Success Criteria
1. A merge to `main` triggers Jenkins, deploys `kk-payments` to `kijani-staging`, and completes a successful smoke test before production approval becomes available.
2. After successful staging validation, an authorized human can approve production deployment, with the approval reason and approver recorded in the pipeline evidence.
3. A staging payment produces a receipt event in `kk-payments-receipts-staging`, and the Week 10 serverless receipt chain processes that event successfully.

## Architecture Diagram
See `kijanikiosk-capstone-architecture.png`.
