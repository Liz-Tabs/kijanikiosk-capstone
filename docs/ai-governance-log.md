# AI Governance Log

This log records representative AI-assisted infrastructure decisions that were reviewed by a human before being applied to the KijaniKiosk project. The entries focus on security and governance checks rather than documenting every use of AI.

## Entry 1 — Terraform AWS Region

**1. AI tool / date**  
ChatGPT — 16 August 2026

**2. Change / context**  
AI-assisted Terraform configuration for the KijaniKiosk staging receipt-storage infrastructure.

**3. What the AI produced**  
The initial Terraform configuration used `us-east-1` for the AWS provider and S3 resources.

**4. What the AI got wrong or missed**  
The region was not suitable for the AWS environment being used. Terraform's first apply failed with `AuthorizationHeaderMalformed` and AWS reported that `eu-north-1` was the expected region.

**5. Human verification**  
The AWS error was checked directly rather than treating the generated configuration as authoritative. Terraform was then re-planned after changing the region to `eu-north-1`.

**6. Human change / decision**  
The Terraform AWS resources were changed to `eu-north-1`. The plan was reviewed before the infrastructure was applied.

**7. Governance control applied**  
**Control 6 — Data classification and residency.** The deployment region was explicitly checked instead of accepting an AI/default region.

**8. Evidence / outcome**  
Terraform successfully created the staging receipt bucket in `eu-north-1`, with the final resource named `kk-payments-receipts-staging-840986438351`.

---

## Entry 2 — S3 Receipt Infrastructure Security Review

**1. AI tool / date**  
ChatGPT — 16 August 2026

**2. Change / context**  
AI-assisted Terraform configuration for the staging S3 receipt bucket and Lambda receipt processor.

**3. What the AI produced**  
The proposed infrastructure included an S3 bucket, Lambda function, IAM role/policy, S3-to-Lambda permission, and S3 object-created notification.

**4. What the AI got wrong or missed**  
The generated infrastructure required human security review rather than being accepted as production-ready by default. In particular, the IAM permissions and S3 security controls had to be checked against the project's governance requirements.

**5. Human verification**  
The final Terraform configuration was reviewed against the governance checklist. The IAM policy was checked to ensure the Lambda only required `s3:GetObject` access to the staging receipt bucket. The S3 bucket was also checked for encryption and public-access protection.

**6. Human change / decision**  
The final configuration used a dedicated Lambda IAM role with limited S3 read access, blocked public access to the bucket, and AES256 server-side encryption.

**7. Governance control applied**  
**Control 1 — Least privilege.** IAM permissions were limited to the operations required by the receipt processor.  
**Control 2 — Encryption at rest and in transit.** Server-side encryption was enabled and the bucket was not exposed publicly.

**8. Evidence / outcome**  
Terraform successfully created the bucket, encryption configuration, IAM role/policy, Lambda function, Lambda permission, and S3 notification. A test receipt subsequently triggered the Lambda successfully, and CloudWatch logs confirmed that the receipt was processed.
