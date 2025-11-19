# Project "Opsfolio" - The Evolved Interview App.

  ### Opsfolio: From Interview Task → DevSecOps Mastery.
  ### This repository demonstrates how a simple technical interview assessment app became a professional-ready, security-hardened DevSecOps portfolio project.

  - In short: it started as an __interview assessment task__, now it’s my __Opsfolio__: a hands-on reflection of how I can build, secure, and deploy software.

# Project Overview

This project demonstrates a fully automated secured CI/CD pipeline for a custom web application using modern DevSecOps and GitOps practices with a **SHIFT-LEFT** Approach. The environment uses a local K3s Kubernetes cluster orchestrated with ArgoCD and ArgoCD Image Updater 


## Simulating an Enterprise On-Prem Environment on My Windows 11 Machine

### A DevSecOps Story of Tunnels, Clusters, Security, and Observability

There’s something about building things __from scratch__ that forces you to understand them at a deeper level.
For this project, I wanted to go beyond “deploying a simple app on Kubernetes.”

As initially __required__ by the Organization's take home assessment, I wanted to __simulate a full on-prem enterprise environment__ — but on my Windows 11 laptop.

Not cloud (Atleast that wasn't permitted in the assessment).
Not managed Kubernetes. (Neither was this allowed)
__Local. Raw. Hands-on. Real.__ (Only Local, ZERO-COST, Manual approach)

My aim wasn’t just to deploy.
My aim was to orchestrate, secure, monitor, expose, observe, and manage the entire environment like it was running in a real company’s private datacenter.

To achieve that, I brought together:

  - Windows 11 + WSL (Ubuntu)

  - K3s (lightweight on-prem Kubernetes)

  - ArgoCD + ArgoCD Image Updater (GitOps)

  - Kustomize

  - Prometheus + Grafana + Alertmanager with SMTP email alerts

  - Kubeseal + SealedSecrets (enterprise-grade secret management)

  - Ngrok Agent in Kubernetes (reverse proxy + geo-IP restriction + traffic inspection)

  - OpenLens (cluster GUI)

This README tells the story of how I built it, why I built it, and how each part fits into real-world DevSecOps practices.


[Live App Link](https://unstoical-carmelina-diphyodont.ngrok-free.dev/)

``` 
   ⚠️ Note:
            This application is exposed using Ngrok, which creates a secure tunnel from my local wsl + K3s cluster to the public internet.
            As this environment runs locally, the demo URL may be offline when my workstation is not active (e.g., in sleep mode) 

            However, all configuration manifests, screenshots, and monitoring dashboards (Grafana, Prometheus, ArgoCD, Ngrok) have been fully documented and can be easily reproduced using the provided Kubernetes manifests and Helm configurations.

            Lastly, this application with all its dependencies will not be left on my Machine for long or in the future (thus, the documentations), as it was an assessment project, which i chose to extend, and is complete but consumes resources.
```


# 1. The Local On-Prem Simulation: Windows 11 + WSL + K3s

Everything starts on my Windows 11 workstation.

## Why simulate on-prem?

Because many European companies still run on-prem clusters, hybrid environments, or private networks.
If I can build, manage, secure, and observe Kubernetes on my laptop, then doing it on cloud or on physical servers is trivial.

## Why WSL + Ubuntu? 

WSL gives me the flexibility of Linux while keeping my Windows environment intact for:

  - VSCode

  - Browser monitoring dashboards

  - Screenshot collections

  - Local development workflows

  - Ubuntu inside WSL acts like the on-prem host server for the cluster.

## Why K3s?

K3s is lightweight, blazing fast, and perfect for:

  - Local simulation

  - Edge/on-prem testing

  - GitOps learning

  - Continuous deployment workflows

In the real world, companies use K3s for IoT, edge devices, retail locations, factories, and more.
Perfect choice for a “mini-datacenter” on my machine.


# 2. Kubernetes Structure: Namespaces, Deployments, Services, Policies

Inside K3s, I structured my environment like a real enterprise setup:

```
k3s cluster
 ├── argocd namespace
 ├── monitoring namespace (prometheus, grafana)
 ├── interview-app namespace
 ├── ngrok-operator namespace
 ├── sealed-secrets namespace
 ```

## Deployments & Services

I deployed:

  - The Application (My Portfolio app)

  - Ngrok Agent

  - Monitoring stack

  - ArgoCD

  - Image Updater

  - SealedSecrets Controller

Everything was configured declaratively!  No manual `kubectl apply` after ArgoCD was installed, afterall ArgoCD is meant to "Deploy things".

## Why this matters

This foundation simulates how companies structure workloads for:

  - Security isolation

  - GitOps separation

  - Logical boundaries

  - Easier RBAC

  - Clear cluster governance


# 3. Enterprise-Grade Secrets: Kubeseal + SealedSecrets

## The Problem

I didn’t want to push:

  - SMTP passwords

  - Ngrok authtokens

  - ArgoCD credentials

  - Any sensitive data

…into GitHub.

## The Solution: SealedSecrets

Bitnami SealedSecrets encrypts secrets with the cluster’s public key.
Only the controller inside the cluster can decrypt them.

This means:

  - The Git repo contains only encrypted secrets

  - Even if leaked, they are useless

  - Perfect for GitOps + Zero-Trust setups

I used SealedSecrets for:

  - Ngrok Authtoken

  - Gmail SMTP auth

  - ArgoCD Git HTTPS credentials (for Image Updater)

## Why this is real-world DevSecOps

Enterprises frequently use sealed, encrypted, or vaulted secrets:

  - SealedSecrets (clusters)

  - Vault (multi-cloud)

  - SOPS + KMS/GPG

  - AWS Secrets Manager

This demonstrates complete awareness of:

  - Secrets lifecycle

  - GitOps security challenges

  - Real-world compliance expectations (HIPAA / PCI / ISO27001)


  # 4. GitOps Deployment: ArgoCD + Image Updater

One of my main goals was automation.

Once my manifests were in Git:

  - ArgoCD continuously watched them

  - Any commit = automatic deployment

  - Any image update = automatic sync

  - Any drift = auto-self-heal

ArgoCD Image Updater connected everything:

  - Watches GHCR for new image tags

  - Applies semantic versioning rules

  - Writes updated manifests back to Git

  - ArgoCD redeploys sealed versions

## Why businesses love GitOps

  - Predictable

  - Auditable

  - Repeatable

  - No manual intervention

  - Faster disaster recovery

  - Fewer human errors

This entire stack mirrors real company GitOps workflows.


# 5. Kustomize: Managing Overlays & Patches

Kustomize let me define:

  - Base manifests

  - Overlays for different environments

  - Resource limits

  - Patches for ArgoCD annotations

  - Label/namespace management

This is essential for scaling environments like:

  - dev

  - staging

  - production

  - QA

  - testing


  # 6. Ngrok Agent Inside Kubernetes

**_Reverse Proxy + WAF + Traffic Inspection + Geo-IP Controls_**

This was one of the most interesting parts of the project.

Instead of exposing my app with:

  - NodePort

  - LoadBalancer

  - Port forwarding

…I deployed **Ngrok as a Kubernetes Pod**.

This allowed me to:

  - Make my local on-prem cluster reachable globally

  - Add geo-IP blocking

  - Inspect HTTP traffic

  - Enforce rate-limiting

  - Add security restrictions similar to Cloudflare WAF

  - Test security policies from outside my local network

**Everything was declaratively deployed via ArgoCD**, including the SealedSecret containing the Ngrok authtoken.

## Why this matters for business

Companies use Cloudflare, Akamai, F5, Kong, Traefik Enterprise, etc.
Ngrok gave me a smaller version of:

  - Reverse proxy

  - WAF

  - Traffic routing

  - Endpoint protection

  - Secure public exposure

As I did not want to spend a "dime" on the assessment project, i stuck to Ngrok - Perfect for realistic QA testing.


# 7. Observability Layer: Prometheus + Grafana + Alertmanager (with Email)

No Kubernetes project is complete without observability.

I deployed:

  - Prometheus for metrics

  - Grafana for dashboards

  - Alertmanager for alerts

I configured:

  - Pod CPU/memory alerts

  - Node resource alerts

  - Application health alerts

  - Email notifications (via Gmail SMTP) to my personal email.

Secrets were stored using SealedSecrets.

## Why monitoring matters

In a real company, this allows:

  - Fast troubleshooting

  - SLO/SLA measurement

  - Proactive alerting

  - Production reliability

  - Better decision-making

I used OpenLens to visualize cluster resources in real time.


# 8. OpenLens by Rancher: My Local Kubernetes Control Tower

OpenLens by Rancher acted as the GUI or visual “command center” for:

  - Logs

  - Events

  - Workloads

  - Secrets

  - Health checks

It made debugging quicker and helped with verifying the GitOps pipeline.


# 9. What This Entire Project Proves (From a DevSecOps Perspective)

This project shows I can:

  - Build an on-prem-like Kubernetes environment
  - Secure it using encryption, WAF, secrets, and policies
  - Monitor it using modern observability tooling
  - Automate it using GitOps
  - Expose it securely to the internet
  - Manage deployments the same way enterprises do
  - Integrate CI → CD → GitOps → Monitoring → WAF into one flow

This isn’t just a “project.”
This is a **hands-on recreation of how real companies operate their internal infrastructure**.


# Final Thoughts

If the cloud is the future, then on-prem is the past that refuses to die.
Companies still run hybrid networks, private clusters, or local data centers.
This project allowed me to simulate that world—while blending it with modern DevSecOps pipelines.

With:

  - Secure tunnel exposure

  - WAF protection

  - GitOps auto-sync

  - Automated image updates

  - Enterprise secrets management

  - Real-time monitoring

  - Kubernetes orchestration

…I turned my Windows laptop into a **miniature enterprise platform**.

The screenshots, manifests, dashboards, and logs all tell one story:

**I can design, secure, deploy, automate, and observe a complete Kubernetes ecosystem end-to-end.**


# Screenshots

### 1. App Live
Shows the live deployment of the interview-app running on Kubernetes, accessible through the Ngrok tunnel service.
![App Live](/screenshots/App_live.png)

### 2. WSL Win11
Displays the Windows Subsystem for Linux (WSL) setup on Windows 11 used for the local development environment.
![WSL Win11](/screenshots/WSL_Win11.png)

## K3s Cluster:

### 3. All pods Across All Namespaces
This screenshot shows all pods running in my cluster across all namespaces. You can see both the interview-app pods in the default namespace and the ngrok-agent and ngrok-operator pods in the ngrok-operator namespace. It confirms that all components of the project are deployed successfully
![All Pods](/screenshots/SHOW_ALL_NAME_SPACE.png)

### 4. All Services Across All Namespaces
Here I display all Kubernetes services. The interview-app NodePort service is visible, along with internal services for ngrok-agent and ngrok-operator. This ensures traffic routing is correctly configured in the cluster.
![All Services](/screenshots/SHOW_ALL_SERVICES.png)

### 5 Deployments in Namespaces
This screenshot shows the deployments in the namespaces. You can verify the number of replicas, container images, and current pod status. It shows that ngrok-agent and interview-app deployments are running as expected.
![Deployments](/screenshots/SHOW_DEPLOYMENT_IN_NS.png)

### 6. Pod Details.
Here we inspect the details of a specific pod. This includes the pod’s labels, node assignment, container configuration, and recent events. It’s useful to verify environment variables, volumes, and network connectivity for debugging purposes.
![Pod Details](/screenshots/SHOW_POD_DETAILS.png)

### 7 Pod Logs
This screenshot shows logs from the ngrok-agent pod. It confirms the ngrok tunnel is established and provides the live public URL for external access to the application. Logs also help in troubleshooting connection issues.
![Pod Logs](/screenshots/SHOW_POD_LOGS.png)

### 8. Sealed Secrets
SealedSecrets are used to store sensitive data in the cluster safely. This screenshot shows the ngrok-secret and interview-app-auth SealedSecrets applied in the ngrok-operator namespace.
![SealedSecrets](/screenshots/SHOW_SEALED_SECRETS.png)

### 9. K8s Secrets
This screenshot shows decrypted Kubernetes secrets available in the cluster. They are derived from the SealedSecrets and used by pods to authenticate with ngrok or other services.
![Secrets](/screenshots/SHOW_SECRETS.png)

### 10. K8s Services with Ports
Here we describe the services along with their port mappings, ClusterIP, and selectors. This verifies that the interview-app NodePort and internal ngrok services are correctly routing traffic.
![Services with Ports](/screenshots/SHOW_SERVICES_WITH_PORTS.png)

## PROMETHEUS AND GRAFANA

### 11. GRAFANA DASHBOARD
Shows the dashboard of Grafana for Observability and Telemetry
![GRAFANA DASHBOARD](/screenshots/GRAFANA_DASHBOARD.png)

### 12. GRAFANA SVC
Shows the serevices associated with Grafana
![Services with Grafana](/screenshots/GRAFANA_SVC.png)

### 13. GRAFANA LIVE VISUAL
Shows the live visual representation of a service health in Grafana
![Services with Ports](/screenshots/GRAFANA_VIZ.png)

### 14. MONITORING PODS
Pods associated with the monitoring namespace for Grafana & Prometheus
![Services with Ports](/screenshots/MONITORING_PODS.png)

### 15. PROMETHEUS PORT
Port use to access prometheus server running
![Services with Ports](/screenshots/PROMETHEUS_PORT.png)

### 16. PROMETHEUS SERVER RUNNING
Live Prometheus Server Running and Accessed
![Services with Ports](/screenshots/PROMETHEUS_SERVER.png)

### 17. ArgoCD App
Displays the ArgoCD application view for the CardMarket assessment project.
![ArgoCD App](/screenshots/ArgoCD_App.png)

### 18. ArgoCD
Shows the ArgoCD dashboard with all deployed applications.
![ArgoCD](/screenshots/ArgoCD.png)

## Ngrok

### 19. Ngrok Local UI Inspect
Shows the ngrok agent local UI inspecting the live tunnel and traffic.
![Ngrok Local UI Inspect](/screenshots/Ngrok_(Local_UI_Inspect).png)

### 20. Ngrok Local UI Port Forward to Local Host
Demonstrates how the ngrok tunnel forwards traffic from the public URL to the local Kubernetes service.
![Ngrok Port Forward](/screenshots/Ngrok(Local_UI_Port_Forward_to_Local_Host).png)

### 21. Ngrok Local UI Status Report
Shows the current status of the ngrok tunnel and connected endpoints.
![Ngrok Status Report](/screenshots/Ngrok_(Local_UI_Status_Report).png)

### 22. Ngrok Endpoint
Displays the ngrok public endpoint that exposes the local app to the internet.
![Ngrok Endpoint](/screenshots/Ngrok_Endpoint.png)

### 23. Ngrok Terminal
Shows the terminal output of the ngrok agent container inside Kubernetes.
![Ngrok Terminal](/screenshots/Ngrok_Terminal.png)

### 24. Ngrok Traffic Inspector
Displays traffic details for requests passing through the ngrok tunnel.
![Ngrok Traffic Inspector](/screenshots/Ngrok_Traffic_Inspector.png)