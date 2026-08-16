# KijaniKiosk Capstone Test Plan

## Purpose

This test plan verifies that a fresh user can understand and operate the KijaniKiosk Track A capstone using the repository documentation and that the staging-to-production delivery workflow behaves as designed.

## 1. Fresh Setup

1. Clone the repository.
2. Follow the README prerequisites and setup instructions.
3. Start Minikube.
4. Apply the Terraform staging infrastructure.
5. Run the Ansible staging configuration.
6. Confirm that the `kijani-staging` namespace and staging ConfigMap exist.

Expected result: the staging environment is reproducible from the documented setup steps.

## 2. Happy Path

1. Trigger the Jenkins pipeline.
2. Confirm build and lint complete successfully.
3. Confirm tests execute.
4. Confirm the Docker image is built.
5. Confirm Kubernetes access is verified.
6. Confirm the application deploys to `kijani-staging`.
7. Confirm the staging smoke test returns a healthy response.
8. Confirm the production approval gate appears only after the smoke test passes.
9. Approve the production deployment.
10. Confirm the approval reason appears in the Jenkins build log.
11. Confirm the production rollout completes successfully.

Expected result: the application moves from build to staging validation and then to production only after explicit human approval.

## 3. Failure Path

1. Introduce a controlled application or deployment fault.
2. Trigger the Jenkins pipeline.
3. Observe where the pipeline stops.
4. Confirm production deployment does not proceed when the required validation fails.
5. Restore the correct configuration.
6. Re-run the pipeline and confirm it returns to success.

Expected result: a failed validation prevents unsafe promotion to production.

## 4. Runtime Verification

1. Confirm staging Pods are Running and Ready.
2. Call the `/health` endpoint.
3. Submit a valid payment request.
4. Submit an invalid payment request.
5. Inspect structured application logs.
6. Run the payment error-rate monitoring script.

Expected result: successful and failed payment requests produce structured logs and the monitoring check detects an error rate above the configured 5% threshold when the test data exceeds that threshold.

## 5. AI Governance Review

1. Read `docs/ai-governance-log.md`.
2. Confirm each entry identifies the AI tool, task, supplied context, output, correct elements, incorrect elements, human changes, and governance control.
3. Confirm the log demonstrates human review rather than accepting AI output automatically.

Expected result: the AI-assisted infrastructure decisions have an auditable human review trail.
