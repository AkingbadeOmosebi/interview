# Opsfolio – Automated DevSecOps Pipeline for EKS Infrastructure (Extension of My Interview-App Project) or The Cloud Path.

This project is the Cloud infrastructure and DevSecOps arm of my **Interview-App** project.

### Deployment & Destroy Workflows
![Terraform Deploy EKS](https://github.com/AkingbadeOmosebi/Opsfolio-Interview-App/actions/workflows/terraform-deploy-eks-tfsec.yaml/badge.svg)
![Terraform Destroy](https://github.com/AkingbadeOmosebi/Opsfolio-Interview-App/actions/workflows/terraform-destroy.yml/badge.svg)

### Security Scanning
![TFSec Scan](https://github.com/AkingbadeOmosebi/Opsfolio-Interview-App/actions/workflows/terraform-deploy-eks-tfsec.yaml/badge.svg?query=branch=main)

### Cost Estimation
![Infracost](https://img.shields.io/badge/Infracost-checked-green?logo=infracost)


```
                               +------------------------------------------------+
                               |  CI / DevSecOps (Shared by Local and Cloud)    |
                               |------------------------------------------------|
                               |  - GitLeaks (Secret Scan)                      |
                               |  - Megalinter (Code Linting)                   |
                               |  - SonarCloud (SAST)                           |
                               |  - Snyk (SCA & Vulnerabilities)                |
                               |  - Trivy (Container Scan)                      |
                               |  - Docker Build & Push to GHCR                 |
                               |  - Semantic Release                            |
                               +---------------------+--------------------------+
                                                     |
                                                     |
                   +---------------------------------+-----------------------------------+
                   |                                                                     |
        +----------+----------+                                              +----------+-----------------+
        |      Local / On-Prem|                                              |         Cloud / AWS EKS    |
        |  WSL + K3s Prototype|                                              |  Terraform + OIDC + EKS    |
        |---------------------|                                              |----------------------------|
        |  Continuous Deploy  |                                              |  Infrastructure as Code    |
        |  via ArgoCD         |                                              |  - Terraform Cloud State   |
        |  - Watches Repo     |                                              |  - EKS Cluster / Nodegroups|
        |  - Deploys K3s      |                                              |  - IAM Roles & OIDC RBAC   |
        |  - Image Updater    |                                              |  - TFsec Security Scan     |
        |  - Security & Sync  |                                              |  - Infracost Cost Checks   |
        +----------+----------+                                              +----------+-----------------+
                   |                                                                     |
     +-------------+-------------+                                         +-------------+--------------------+
     |                           |                                         |                                  |
+----v---------+         +-----v----------------+                        +-----v--------+            +-----v-------------+
| K3s          |         | SealedSecrets        |                        |   EKS Nodes  |            |    RBAC / OIDC    |
| Cluster      |         | & Secrets Mgmt       |                        | - Deploy Pods|            | - IAM Role Mapping|
| - Namespaces |         | - Grafana Admin      |                        | - Services   |            | - GitHub OIDC Role|
| - Deployments|         | - Alertmanager       |                        +--------------+            +-------------------+
| - Services   |         | - DB & API Keys      |                           ^
+----+---------+         +------+---------------+                           |
     |                           |                                          |
     v                           v                                          |
+----+--------+           +------+-------+                                  |
| Prometheus  |           | Grafana Dash |                                  |
| - Metrics   |           | - Visualizes |                                  |
|   Collection|           |   Prometheus |                                  |
| - Node/Pod  |           |   & App Dash |                                  |
|   Metrics   |           +--------------+                                  |
+-------------+               |                                             |
                              v                                             |
                      +-------+--------+                                    |
                      | Alertmanager   |                                    |
                      | - Config Alerts|                                    |
                      | - Email/Webhook|                                    |
                      +----------------+                                    |
                              |                                             |
                              v                                             |
                       +------+-----------+                                 |
                       | Ngrok / Tunnel   |                                 |
                       | - Expose Local   |                                 |
                       | - Traffic Logging|                                 |
                       | - Optional Geo IP|                                 |
                       |   Restrictions   |                                 |
                       +------------------+                                 |
                              |                                             |
                              v                                             |
                        +-----+----------+                                  |
                        | Public Access  |                                  |
                        | - Interview App|                                  |
                        | - QA / Client  |                                  |
                        | - Secure Tunnel|                                  |
                        +----------------+                                  |
                                                                 +-----------+-------------------+
                                                                 | Cloud Possibilities           |
                                                                 | - GitOps via ArgoCD           |
                                                                 | - Observability & Alert       |
                                                                 |   replication (Prom/Grafana)  |
                                                                 | - Sealed Secrets / KMS        |
                                                                 | - CI/CD replication           |
                                                                 | - Terraform Cloud             |
                                                                 |   - State Management          |
                                                                 |   - Outputs / Destroy         |
                                                                 | - TFsec Security Scan         |
                                                                 | - Infracost & AutoFix         |
                                                                 +-------------------------------+
```


I built this to show what a real production-ready cloud platform looks like when automated end-to-end using modern DevOps, GitOps, and FinOps tooling.

The stack includes:

  -  Terraform (Infrastructure-as-Code)

  -  Terraform Cloud (remote backend + team governance)

  -  GitHub Actions (CI/CD automation)

  -  OpenID Connect (OIDC) (secure, keyless AWS deployment)

  -  AWS EKS (managed Kubernetes)

  -  TFsec (IaC security scanning)

  -  Infracost (FinOps insight + cost guardrails)


 ## 1. Why These Tools Matter (Short, Practical Introductions)

 Terraform – Standardized, Repeatable Infrastructure

Terraform lets companies define infrastructure as code, commit it to Git, and version it like software.
No guessing, no “snowflake servers,” no manual mistakes.

In this project, Terraform provisions:

   - VPC

   - Subnets

   - NAT gateway

   - EKS Cluster

   - Node groups

   - KMS encryption

   - IAM roles

   - Networking and security boundaries

This is exactly how modern companies run cloud infrastructure at scale.


### Terraform Cloud – Managed State + Governance

Instead of storing state locally or in S3, I used Terraform Cloud for:

  -  Remote state

  -  State locking

  -  Drift detection

  -  Full apply/destroy history

  -  Policy enforcement

This is what real engineering teams use when multiple DevOps engineers collaborate on infrastructure.


### GitHub Actions – Automated IaC Deployment Pipeline

  - The pipeline:

  -  runs every push

  - formats Terraform

  -  scans for security findings (TFsec)

  -  checks for cost impact (Infracost)

  -  deploys securely to AWS using OIDC

  -  manages Terraform state through Terraform Cloud

This mimics a real production CI/CD environment where infrastructure changes must pass through automated gates.


### OIDC – Keyless AWS Authentication

Traditional CI/CD workflows store long-term AWS keys in the repo’s secrets.
That’s risky.

  -  I implemented GitHub → AWS OIDC federation, meaning:

  -  no AWS access keys are stored anywhere

  -  short-lived credentials rotate automatically

  -  AWS trusts GitHub via IAM conditions and audience claims

This is exactly what AWS recommends for enterprise DevSecOps pipelines.


### EKS – Managed Kubernetes

The result of the pipeline is a fully deployed EKS cluster, ready for:

  - workloads

  - microservices

  - GitOps (ArgoCD)

  - application deployment

I connected it with:

  - Kubeconfig commands

  - AWS-auth mappings

  - Auto-managed node groups

The EKS dashboard shows the cluster running successfully.


TFsec – Infrastructure Security Scanning

Before Terraform applies anything, TFsec checks for:

  - missing encryption

  - public exposure

  - weak IAM policies

  - misconfigured security groups

  - dangerous defaults

This matters for companies because it **shifts security left** — catching vulnerabilities before they ever hit AWS (Assuming you eventually chose to fix it).


### Infracost – FinOps, Cost Visibility & Auto Pull-Request Reviews

Infracost prevents companies from being hit with surprise AWS bills.
It:

  - analyzes Terraform changes

  - shows the exact cost difference

  - comments automatically on pull requests

  - recommends cheaper alternatives

  - shows dashboards and Explorer results

This ensures infrastructure decisions are not just “technically correct,” but also financially smart.


## 2. Project Workflow (How Everything Comes Together)

Below is the end-to-end flow of the pipeline.

### Step 1 – Developer pushes a change to GitHub

This triggers the GitHub Actions pipeline:

```
- terraform fmt
- terraform init
- terraform validate
- tfsec security scan
- infracost cost-check
- terraform plan
- terraform apply (if merged)
```

### Step 2 – GitHub Authenticates to AWS via OIDC

No static credentials.
AWS issues short-lived tokens only when GitHub meets the right conditions:

  - correct repo

  - correct branch

  - correct workflow

This removes the need for secrets. A huge DevSecOps or security win.


### Step 3 – Terraform Cloud handles state + lifecycle

Terraform Cloud:

  - stores the state

  - locks state during apply

  - records outputs

  - keeps a full history of changes

This gives a production-grade IaC environment.


### Step 4 – Terraform builds the EKS stack

The modules create:

  - VPC

  - private/public subnets

  - NAT gateway

  - EKS cluster

  - KMS encryption

  - IAM roles

  - Node groups

Once finished, I can run:

```
aws eks update-kubeconfig ...
```

and access my cluster


### Step 5 – TFsec scans

Before deployment, TFsec checks for vulnerabilities.
I allowed all critical and medium security issues flagged to be shown for demo, to showcase functionality and to direct security conerns.

Note: These vulnerability severities should be fixed in production, like in this case, especially **CRITICAL**, **HIGH**, and **MEDIUM**.

Screenshots include:

  - TFsec results in HTML Format


### Step 6 – Infracost FinOps visibility

Infracost provides:

  - cost breakdown

  - cost diffs per PR

  - dashboards

  - savings recommendations

  - auto PR comments (fixed after switching to v1.25)


### Step 7 – Destroy Pipeline w/ Kill-Switch

I built a controlled destroy workflow using:

  - a special workflow

  - a kill-switch variable (for intentionality, or verification)

  - environment protections

This ensures infrastructure cannot be accidentally destroyed.

Screenshots include:

  - destroy status

  - destroy kill-switch

  - cloud state cleanup


## 3. The Struggles, Failures, and Fixes (Realistic Engineering Story)

This wasn’t a “smooth, perfect first try” project.
There were real engineering issues—just like in production.


❌ Issue: OIDC role missing permissions

The cluster failed to create with:

`AccessDeniedException: eks:CreateCluster not authorized`

Fix:
Expanded the OIDC IAM policy to allow required EKS, IAM, and KMS actions.


❌ Issue: Terraform Destroy failing due to KMS permissions

Destroy was stuck on:

`kms:ScheduleKeyDeletion not authorized`

Fix:
Added kms:ScheduleKeyDeletion for the destroy role.
After that, destroy succeeded.


❌ Issue: Infracost v2 broke the pipeline

GitHub Actions couldn’t find:
`action.yml`

Fix:
Switched to the correct version:
`infracost/action@v1`


❌ Issue: TFsec initially skipped

Due to caching and artifact leftovers.

Fix:
Changed the action version & cleaned workflow configuration.


❌ Issue: EKS creation failed due to IAM conditions

Resolved by adding trust policy conditions for:

  - repo

  - ref

  - audience


These struggles to me reflect the real work of DevOps:

  - diagnosing IAM

  - fixing OIDC

  - validating Terraform

  - ensuring state safety

  - securing CI/CD

  - optimizing cost and security gates


## 4. Outcome

By the end of the project, I had:

  - a full DevSecOps pipeline

  - EKS deployed through GitHub Actions → AWS OIDC

  - security scanning

  - cost scanning & auto PR reviews

  - controlled destroy automation

  - terraform cloud governance

  - enterprise-grade workflows

This project shows:

  - DevOps

  - DevSecOps

  - FinOps

  - IaC

  - Cloud architecture

  - Secured CI/CD

  - Kubernetes foundations

  - AWS engineering

All of this comes together into one practical, real-world deliverable.
And it naturally extends from the earlier work I built for the original interview assessment requirements, where I ran the entire application stack locally on WSL + K3s to simulate a fully operational Kubernetes environment without incurring cloud costs.

On the local side, I implemented production-grade features such as:

  - **GitOps with ArgoCD and ArgoCD Image Updater** for automated deployments and image version tracking

  - **Prometheus + Grafana** for monitoring, observability, and email-based alerting and notification

  - **Kubeseal / SealedSecrets** for encrypted secret management and secure configuration workflows

  - **Ngrok Tunnel + Ngrok WAF** for secure external exposure, Geo-IP restrictions, access policies, and request monitoring

  - **Kustomize overlays** for environment-specific configuration management

These local capabilities mirror the same practices that organizations adopt on the cloud side (and can easily be migrated to cloud-native equivalents such as **_Cloudflare WAF, cloud Load Balancers, HTTPS termination, custom domains,_** etc.).

Running them on my local K3s environment allowed me to prototype and validate production workflows—GitOps, observability, security, and controlled external exposure, while keeping the project cost-effective.

This makes the entire project a complete demonstration of the end-to-end lifecycle of a modern application platform: from local Kubernetes development ->> to DevSecOps automation ->> to secure IaC-driven cloud infrastructure.


## 5 Screenshots & What They Represent

| A visual walkthrough of the pipeline, automation, FinOps insights, EKS provisioning, OIDC integration, and security validation.


### 1. EKS-clusters – Successful Cluster Provisioning

Shows the EKS cluster created entirely via Terraform Cloud + GitHub OIDC.
This confirms that the workflow authenticated correctly, applied the Terraform plan, and built the Kubernetes control plane as expected.

![EKS Clusters](/infrastructure/screenshots/EKS-clusters.png)


### 2. EKS-dashboard – Operational Kubernetes Control Plane

A snapshot from the AWS Console confirming that the cluster is healthy, active, and accessible.
This validates that networking, IAM, and OIDC trust relationships are all functioning.

![EKS Dashboard](/infrastructure/screenshots/EKS-dashboard.png)


### 3. Infracost-dashboard – FinOps Cost Visibility

Infracost’s project dashboard showing real-time cost predictions for each Terraform run.
This gives teams the ability to catch unexpected cloud spending before deployment.

![Infracost Dashboard](/infrastructure/screenshots/Infracost-dashboard.png)


### 4. Infracost-AutoFix-PR-request – Automated Cost-Saving Pull Request

Infracost automatically opened a PR recommending a cheaper resource configuration.
This demonstrates autonomous FinOps and governance-as-code.

![Infracost Autofix PR Request](/infrastructure/screenshots/Infracost-AutoFix-PR-request.png)


### 5. Infracost-FinOps-Savings-Solution – Cost Optimization Insights

Breakdown of the potential savings from Infracost’s recommendations.
Helps engineering teams justify changes with actual numbers, not guesswork.

![Infracost FinOps Savings Solution](/infrastructure/screenshots/Infracost-FinOps-Savings-Solution.png)


### 6. Infracost-issue-explorer-dashboard. – Cost Risk Explorer

A central place to analyze cost-impacting resources, risky configurations, and potential overspending trends.

![Infracost Issue Explorer Dashboard](/infrastructure/screenshots/Infracost-issue-explorer-dashboard.png)


### 7. Terraform-cloud-states – Remote State Management

Terraform Cloud state file view.
Ensures secure, versioned, team-friendly state management without storing anything locally.

![Terraform Cloud States](/infrastructure/screenshots/Terraform-cloud-states.png)


### 8. Terraform-cloud-outputs / Terraform-cloud-output-2 – Terraform Outputs

Shows the real-time outputs provided by Terraform Cloud after a successful run — including the kubeconfig command and EKS metadata.

![Terraform Cloud Output](/infrastructure/screenshots/Terraform-cloud-output-2.png)


### 9. Terraform-Oidc-role-summary – GitHub OIDC IAM Role

Summary of the IAM role created for GitHub Actions.
This proves passwordless, keyless, and secure OIDC trust configuration for CI/CD.

![Terraform OIDC Role Summary](/infrastructure/screenshots/Terraform-Oidc-role-summary.png)


### 10. TFsec-results – Security Scan Report

Results from TFsec running inside GitHub Actions.
Shows that IaC was scanned for misconfigurations and vulnerabilities before any deployment.

![TFsec Results](/infrastructure/screenshots/TFsec-results.png)


### 11. Terraform-destroy-killswitch – Manual Approval Before Destruction

A safety control created in Terraform Cloud that prevents accidental infrastructure destruction.
Useful for governance, compliance, and production environments.

![Terraform Destroy Killswitch](/infrastructure/screenshots/Terraform-destroy-killswitch.png)


### 12. Terraform-destroy-status – Successful & Controlled Tear-Down

Proof that the infrastructure was destroyed cleanly under managed conditions, verifying full lifecycle control (build → deploy → destroy).

![Terraform Destroy Status](/infrastructure/screenshots/Terraform-destroy-status.png)



## Conclusion & Summary

This project represents more than just “getting Terraform and EKS to work.” It is a fully-realized, end-to-end DevOps/DevSecOps workflow that pulls together infrastructure provisioning, continuous delivery, cost visibility, security scanning, OIDC-based identity, and real-world operational thinking.

It started as an extension of my original  **Interview App**, which I first ran locally inside WSL + K3s. On that setup, I explored a wide scope of operational practices, GitOps with ArgoCD, image automation with ArgoCD Image Updater, sealed secrets with Kubeseal, observability with Prometheus & Grafana, email alerting, ngrok tunneling with WAF policies, geo-restriction experiments, and kustomize-based configuration layers.

This portfolio project takes those exact same concepts and elevates them into the cloud with AWS, Terraform, OIDC, EKS, Infracost, TFsec, and Terraform Cloud.

What was once a local, interview-only prototype is now a production-style IaC pipeline demonstrating:

  - Cloud infrastructure provisioning

AWS EKS cluster, VPC, nodegroups, and IAM roles fully automated with Terraform.

  - GitHub Actions CI/CD

Secure, keyless deployments using GitHub OIDC.

  -  Security & Compliance

TFsec scanning, IAM least-privilege logic, and cluster RBAC.

  - FinOps Awareness

Infracost integration, cost estimates, savings recommendations, and AutoFix PRs.

  - State Management & Governance

Terraform Cloud remote state, workspace management, and destroy-safety controls.

  - Operational Storytelling

Screenshots, dashboards, and documented workflow give hiring managers clarity into the end-to-end process.

Throughout the build, the pipeline faced real-world issues — from IAM misconfigurations to KMS permission failures and module conflicts, which were deliberately debugged, documented, and resolved in a maintainable way. This is exactly the kind of problem-solving expected in modern Cloud/DevOps environments.

In the end, this work demonstrates that I can:

  - Build infrastructure from scratch

  - Secure it properly

  - Automate it with modern DevOps tooling

  - Observe and monitor it

  - Integrate cost-control and security checks

  - And tie all of it together in a coherent, deliverable system

This project is now a complete, interview-ready showcase of __DevOps, DevSecOps, Cloud Architecture, IaC maturity, and operational thinking__ — all connected back to the original assessment Interview App evolution.

It shows not only what I can build, but how I think about cloud systems: securely, cost-consciously, and with production-minded practices.