# Project "Opsfolio" - The Evolved Interview App.

  - Opsfolio: From Interview Task → DevSecOps Mastery.
  - This repository demonstrates how a simple technical interview assessment app became **a professional-ready, security-hardened DevSecOps portfolio project.**

   | In short: it started as an interview task, now it’s my Opsfolio: a hands-on reflection of how I can build, secure, and deploy and operate modern software systems.


# 📌 Project Highlights

  - Full DevSecOps Pipeline: Local K3s → Cloud AWS EKS

  - Security-First: GitLeaks, Megalinter, SonarCloud, Snyk, TFsec, Trivy, SealedSecrets

  - CI/CD Automation: GitHub Actions, ArgoCD, ArgoCD Image Updater (GitOps)

  - Observability & Monitoring: Prometheus, Grafana, Alertmanager, OpenLens by Rancher

  - Secrets & Sensitive Data Management: Kubeseal + SealedSecrets, Terraform Cloud + OIDC

  - FinOps Awareness: Infracost cost estimation & PR feedback


## 🛡️ Security & CI/CD Pipeline

### Pipeline Status
[![Gitleaks](https://github.com/AkingbadeOmosebi/Opsfolio-Interview-App/actions/workflows/ci-git-leaks.yml/badge.svg)](https://github.com/AkingbadeOmosebi/Opsfolio-Interview-App/actions/workflows/ci-git-leaks.yml)
[![MegaLinter](https://github.com/AkingbadeOmosebi/Opsfolio-Interview-App/actions/workflows/ci-mega-linter.yml/badge.svg)](https://github.com/AkingbadeOmosebi/Opsfolio-Interview-App/actions/workflows/ci-mega-linter.yml)
[![SonarCloud](https://github.com/AkingbadeOmosebi/Opsfolio-Interview-App/actions/workflows/ci-sonarcloud-security.yaml/badge.svg)](https://github.com/AkingbadeOmosebi/Opsfolio-Interview-App/actions/workflows/ci-sonarcloud-security.yaml)
[![Snyk Security](https://github.com/AkingbadeOmosebi/Opsfolio-Interview-App/actions/workflows/ci-snyk.yml/badge.svg)](https://github.com/AkingbadeOmosebi/Opsfolio-Interview-App/actions/workflows/ci-snyk.yml)
[![Docker Build & Push](https://github.com/AkingbadeOmosebi/Opsfolio-Interview-App/actions/workflows/ci-docker-build-&-push-trivy-scan.yml/badge.svg)](https://github.com/AkingbadeOmosebi/Opsfolio-Interview-App/actions/workflows/ci-docker-build-&-push-trivy-scan.yml)

### Security Metrics
[![Quality Gate Status](https://sonarcloud.io/api/project_badges/measure?project=akingbade_interview_portfolio&metric=alert_status)](https://sonarcloud.io/summary/new_code?id=akingbade_interview_portfolio)
[![Security Rating](https://sonarcloud.io/api/project_badges/measure?project=akingbade_interview_portfolio&metric=security_rating)](https://sonarcloud.io/summary/new_code?id=akingbade_interview_portfolio)
[![Vulnerabilities](https://sonarcloud.io/api/project_badges/measure?project=akingbade_interview_portfolio&metric=vulnerabilities)](https://sonarcloud.io/summary/new_code?id=akingbade_interview_portfolio)
[![Known Vulnerabilities](https://snyk.io/test/github/AkingbadeOmosebi/Opsfolio-Interview-App/badge.svg)](https://snyk.io/test/github/AkingbadeOmosebi/Opsfolio-Interview-App)

### Code Quality
[![Bugs](https://sonarcloud.io/api/project_badges/measure?project=akingbade_interview_portfolio&metric=bugs)](https://sonarcloud.io/summary/new_code?id=akingbade_interview_portfolio)
[![Code Smells](https://sonarcloud.io/api/project_badges/measure?project=akingbade_interview_portfolio&metric=code_smells)](https://sonarcloud.io/summary/new_code?id=akingbade_interview_portfolio)
[![Coverage](https://sonarcloud.io/api/project_badges/measure?project=akingbade_interview_portfolio&metric=coverage)](https://sonarcloud.io/summary/new_code?id=akingbade_interview_portfolio)
[![Duplicated Lines (%)](https://sonarcloud.io/api/project_badges/measure?project=akingbade_interview_portfolio&metric=duplicated_lines_density)](https://sonarcloud.io/summary/new_code?id=akingbade_interview_portfolio)

### Release & Container
[![semantic-release: conventional-commits](https://img.shields.io/badge/semantic--release-conventional--commits-e10079?logo=semantic-release)](https://github.com/semantic-release/semantic-release)
[![Docker Image](https://img.shields.io/badge/docker-ghcr.io-blue?logo=docker)](https://github.com/AkingbadeOmosebi/Opsfolio-Interview-App/pkgs/container/interview-app)


# Cloud Side

### Deployment & Destroy Workflows
![Terraform Deploy EKS](https://github.com/AkingbadeOmosebi/Opsfolio-Interview-App/actions/workflows/terraform-deploy-eks-tfsec.yaml/badge.svg)
![Terraform Destroy](https://github.com/AkingbadeOmosebi/Opsfolio-Interview-App/actions/workflows/terraform-destroy.yml/badge.svg)

### Security Scanning
![TFSec Scan](https://github.com/AkingbadeOmosebi/Opsfolio-Interview-App/actions/workflows/terraform-deploy-eks-tfsec.yaml/badge.svg?query=branch=main)

### Cost Estimation
![Infracost](https://img.shields.io/badge/Infracost-checked-green?logo=infracost)



# 📂 Documentation & Architecture Guides

All key processes are documented in the docs/ directory for a professional, enterprise-style walkthrough.

| Topic                      | Description                                                                                  | Link                                                   |
| -------------------------- | -------------------------------------------------------------------------------------------- | ------------------------------------------------------ |
| Local On-Prem Setup        | How I built a full Kubernetes + GitOps + DevSecOps environment locally using WSL + K3s       | [View](/docs/local-onprem-setup.md)                    |
| Cloud Infrastructure Setup | Terraform-driven AWS EKS cluster, OIDC authentication, TFsec, Infracost, and CI/CD           | [View](/docs/cloud-infrastructure-setup.md)             |
| Secure CI/CD Workflows     | End-to-end CI/CD automation with ArgoCD, GitHub Actions, Image Updater, and GitOps practices | [View](/docs/Secure-Continous-Integration-Workflows.md) |


 | These guides provide **step-by-step details, architecture diagrams, and workflow explanations**, highlighting real-world DevSecOps practices.


# Project Architecture (ASCII DIAGRAM)

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
      


   ### [Live Demo Information](https://unstoical-carmelina-diphyodont.ngrok-free.dev/)

```
        ⚠️ Note:
                The live URL may be offline when the local machine is sleeping as it was configured with Ngrok, and will soon be decomissioned. Full manifests, dashboards, and screenshots are documented in the repository.
```

  - Local/Prototype: Validate deployments, GitOps, observability, and security on a cost-free local cluster.

  - Cloud/Production: Extend the same concepts to a fully automated, secure, and cost-aware cloud environment.

This dual approach **demonstrates mastery of both on-prem and cloud DevSecOps workflows** — exactly the skillset expected for senior-level roles.


# Key Skills Demonstrated

  - DevSecOps & GitOps

  - Kubernetes & K3s orchestration

  - Terraform + EKS IaC

  - CI/CD automation, image versioning (Semantic Release) & ChangeLogs

  - Secrets management & Zero-Trust design

  - Observability (Prometheus + Grafana)

  - Cost-conscious engineering (Infracost)

  - Problem-solving in realistic deployment scenario


# 📝 Summary

Opsfolio is more than a portfolio project — it’s a senior-level engineering showcase:

  - Demonstrates full end-to-end infrastructure lifecycle from local development → CI/CD → cloud production

  - Implements industry-standard security and compliance practices

  - Integrates observability, GitOps automation, and cost control

  - Provides professional documentation for every step, tool, and workflow

 | This README, together with the ```docs/``` directory, **tells the story of how I approach, solve, and execute complex DevSecOps projects**, making it an interview-ready portfolio that reflects production-level thinking.