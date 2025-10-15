# Cardmarket CI/CD & GitOps Project Assessment Documentation #

# Project Overview

This project demonstrates a fully automated CI/CD pipeline for a custom web application using modern DevOps and GitOps practices. The pipeline includes linting, code quality checks, containerized builds, vulnerability scanning, and automated deployment with semantic versioning and redundancy checks. The environment uses a local K3s Kubernetes cluster orchestrated with ArgoCD and ArgoCD Image Updater.


   * Main Objectives:

    - Build and maintain a secure, containerized web application (HTML/CSS/JS).

    - Implement robust CI/CD pipelines with GitHub Actions and GitOps with ArgoCD.

    - Ensure automated and reproducible deployment using GitOps principles.

    - Keep the container registry clean with semantic versioning and change detection.

    - Enable external access to the cluster for testing and security hardening.



1. Application Setup

   - Technology: Custom HTML, CSS, JS application.

   - Development Environment: VSCode on Windows 11 with WSL + Ubuntu.

   - Containerization: Docker, for consistent environment across local and CI/CD.

   * Steps:

     - Initialize the application in VSCode.

     - Structure the app in a directory called app/.

     - Ensure the application can run locally via index.html and supporting assets.

   * Tools:

        Visual Studio Code — IDE for development.

        Docker — containerization platform.

Why:

 - Docker ensures that the app runs identically across all environments, avoiding “it works on my machine” issues.



2. Continuous Integration (CI) Pipeline
2.1. Megalinter

   -  Purpose: Catch linting errors in HTML, CSS, and JS before code progresses.

   -  Configuration: Integrated as a GitHub Action.

   -  Outcome: Enforces coding standards, preventing syntax and style issues.




* 2.2. SonarCloud

   - Purpose: Analyze code quality, test coverage, and maintainability metrics.

   - Integration: GitHub Action triggered after Megalinter.

   - Outcome: Provides a dashboard to visualize code health.


Why:

 - SonarCloud adds a quality gate before Docker build, ensuring only healthy code is packaged.



2.3. Docker Build and Trivy Scan

Purpose: Containerize the application and scan for vulnerabilities.

Semantic Versioning (SemVer): 1.0.<github.run_number> used for patch version increments.

Redundancy Check: Build occurs only if app code changed, using Git diff check.

* GitHub Actions Step Example:

    - name: Check if app code changed
    run: |
        git fetch --depth=2
        if git diff --quiet HEAD^ HEAD -- ./app; then
        echo "No changes in app, skipping Docker build and Trivy scan."
        exit 0
        fi


Trivy Scan:

 - Fail workflow if vulnerabilities detected to prevent insecure images from being pushed.

Why:

 - This ensures only secure and updated container images are deployed, minimizing risk.



2.4. Docker Push to GitHub Container Registry (GHCR)

 - Purpose: Store container images in a secure registry.

 - SemVer and SHA Tags: latest, SHA, and 1.0.x tags for version traceability.

 - Redundancy Check: Push only if there are actual changes in app code.


  * Workflow Details:

    - Login to GHCR using a personal access token (GHCR_PAT).

    - Rebuild image in the push workflow since CI runners are ephemeral.

    - Push only if app code changed, reducing unnecessary storage usage.




3. Infrastructure Setup


 - OS & Environment: Windows 11, WSL, Ubuntu.

 - Kubernetes Cluster: K3s managed locally with Rancher for orchestration.

 - Deployment Replicas: 2 replicas for high availability.

 - Service: Exposes container via NodePort.

 - Access: ngrok was used for external testing and network hardening.


* Why K3s:

 - Lightweight, fast, and compatible with ArgoCD for GitOps deployment.

 - Easy to deploy locally on Windows with WSL.


4. Continuous Deployment (CD) via GitOps

* 4.1. ArgoCD

  - Purpose: Automates syncing of Git repository with Kubernetes cluster.

  -  Configuration: Deployment manifest and service synced automatically.

  -  Sync Options: prune: true, selfHeal: true for automated management.



* 4.2. ArgoCD Image Updater

  - Purpose: Automatically updates deployment images in Git and/or cluster.

  - Update Strategy: semver:~1.0 — picks the latest patch version.

  - Write-Back Method: git — commits updated image tags back to repository.

  - Secret: GitHub PAT stored as Kubernetes secret in argocd namespace.

* Example Application Annotation:

        annotations:
            argocd-image-updater.argoproj.io/image-list: interview-app=ghcr.io/akingbadeomosebi/interview-app
            argocd-image-updater.argoproj.io/interview-app.update-strategy: semver:~1.0
            argocd-image-updater.argoproj.io/interview-app.force-update: "true"
            argocd-image-updater.argoproj.io/write-back-method: git
            argocd-image-updater.argoproj.io/git-https-username-secret: argocd-image-updater-git
            argocd-image-updater.argoproj.io/git-https-password-secret: argocd-image-updater-git


* Why git write-back:

  - Keeps Git repository as source of truth.

  - Deployment history is preserved.

  - Enables reproducible rollbacks.



* 4.3. Deployment.yaml & Kustomize

      - Deployment replicas: 2 for HA.

      -  RollingUpdate strategy: maxUnavailable=0, maxSurge=1.

      - Resource limits: CPU and memory configured to prevent cluster overload.

      - Image tag placeholder: :latest or :1.0.x updated automatically by Image Updater.

    * Kustomize:

      - Manages overlays and customization for cluster manifests.

      - Enables ArgoCD to apply consistent deployment updates.


* 4.4. External Access & Hardening

     - ngrok WAF allows secure testing from outside your local network and other potential endpoint security, traffic policy, SSH public keys, IP Restrictions, Certificate authorizations, Traffic inspection,  implementations.

     - Use case: For QA testing and simulating public access.



5. Semantic Versioning and Redundancy Prevention

 * Semantic Versioning (SemVer): 1.0.<github.run_number> for patch updates.

 * Redundancy Prevention:

    - Docker images are only built/pushed when actual app code changes are detected.

    - Reduces registry storage usage.

Improves reproducibility and traceability.

6. Summary of CI/CD Flow

  - Developer pushes code → triggers Megalinter → SonarCloud → Docker Build & Trivy scan.

  - Docker images are tagged with SHA, latest, and SemVer.

  - If scan passes and code changed → Docker image pushed to GHCR.

  - ArgoCD Image Updater detects new SemVer image → commits updated image tag to Git.

  - ArgoCD syncs cluster → new deployment applied with rolling update strategy.

  - Application accessible externally via ngrok for testing/hardening.


7. Challenges Faced

* Redundant image builds:

  - Initially, every workflow run created new images even when code did not change.

  - Solved by Git diff check before Docker build.

* Ephemeral CI runners:

  - Docker images from build workflow did not persist to push workflow.

  - Solved by rebuilding image in push workflow.

* Git write-back authentication:

  - Needed GitHub PAT to commit image updates.

  - Ensured correct secret creation and permissions in argocd namespace.

* Semantic versioning integration:

  - Needed to automate patch increments without pushing unnecessary tags.

  - Solved using GitHub run number + code change detection.

* Local cluster access:

  - Exposing K3s cluster externally required ngrok and security considerations.

8. References and Links

Tool	                    Purpose                                         	Documentation

VSCode	                    Development	                                        https://code.visualstudio.com/

Docker	                    Containerization	                                https://docs.docker.com/get-docker/

Megalinter	                Linting	                                            https://nvuillam.github.io/mega-linter/

SonarCloud	                Code quality (SAST)                                 https://sonarcloud.io/documentation/

GHCR	                    Container registry	                                https://docs.github.com/en/packages/wrking-with-a-github-packages-registry/working-with-the-container-registry

Trivy	                    Security scan	                                    https://github.com/aquasecurity/trivy-action

K3s	                        Kubernetes cluster	                                https://k3s.io/

Rancher	                    Cluster management	                                https://rancher.com/

ArgoCD	                    GitOps deployment	                                https://argo-cd.readthedocs.io/en/stable/

ArgoCD Image Updater    	Auto image update	                                https://argocd-image-updater.readthedocs.io/en/stable/

Kustomize	                Manifest customization                          	https://kubectl.docs.kubernetes.io/references/kustomize/

ngrok	                    External access (WAF, like CLoudFlare)              https://ngrok.com/docs