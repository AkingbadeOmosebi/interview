# Opsfolio Architecture Components Guide

This guide provides detailed explanations of each component in the Opsfolio DevSecOps architecture, how they work together, and best practices for managing them.

---

## Table of Contents

1. [Source Control & Version Management](#1-source-control--version-management)
2. [Shift-Left Security Pipeline](#2-shift-left-security-pipeline)
3. [Build, Scan & Release Pipeline](#3-build-scan--release-pipeline)
4. [Container Registry](#4-container-registry)
5. [GitOps Continuous Deployment](#5-gitops-continuous-deployment)
6. [Local Environment (K3s)](#6-local-environment-k3s)
7. [Observability Stack](#7-observability-stack)
8. [Secrets Management](#8-secrets-management)
9. [Cloud Infrastructure (AWS EKS)](#9-cloud-infrastructure-aws-eks)
10. [Terraform & Infrastructure as Code](#10-terraform--infrastructure-as-code)
11. [Cost Management (FinOps)](#11-cost-management-finops)
12. [Workflow Integration](#12-workflow-integration)

---

## 1. Source Control & Version Management

### GitHub Repository Structure

**Location**: `github.com/AkingbadeOmosebi/interview` (ArgoCD uses `interview.git`)

**Purpose**: Single source of truth for all code, infrastructure, and configuration.

### Directory Structure

```
/
├── app/                          # Static HTML application (nginx-served)
│   ├── index.js                  # Main application entry point
│   ├── package.json              # Dependencies
│   └── public/                   # Static assets
│
├── k8s/                          # Kubernetes manifests
│   ├── deployment.yaml           # Application deployment
│   ├── service.yaml              # K8s service definition
│   ├── argocd.yaml              # ArgoCD application config
│   ├── monitoring/              # Prometheus, Grafana configs
│   ├── secrets/                 # SealedSecrets
│   └── ngrok-agent-deployment.yaml
│
├── infrastructure/               # Terraform IaC
│   ├── main.tf                  # Primary infrastructure definition
│   ├── provider.tf              # AWS provider config
│   ├── variables.tf             # Input variables
│   └── outputs.tf               # Output values
│
├── .github/workflows/           # CI/CD pipeline definitions
│   ├── security-analysis.yml    # Security scanning workflows
│   ├── build-scan-release.yml   # Build & release pipeline
│   ├── quality-checks.yml       # Code quality checks
│   ├── terraform-deploy-eks-tfsec.yaml
│   └── terraform-destroy.yml
│
├── docs/                        # Documentation
│   ├── local-onprem-setup.md
│   ├── cloud-infrastructure-setup.md
│   └── architecture-*.md
│
└── README.md                    # Project overview
```

### Best Practices

- **Branch Protection**: Main branch requires PR reviews, passing CI checks
- **Conventional Commits**: Semantic Release uses commit messages for versioning
- **Signed Commits**: Optional but recommended for security
- **PR Templates**: Ensure consistent information in pull requests

### Commit Message Format

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types**:
- `feat`: New feature (bumps minor version)
- `fix`: Bug fix (bumps patch version)
- `docs`: Documentation changes
- `chore`: Maintenance tasks
- `ci`: CI/CD changes
- `refactor`: Code refactoring
- `test`: Adding tests
- `perf`: Performance improvements

**BREAKING CHANGE**: In footer bumps major version

---

## 2. Shift-Left Security Pipeline

### Overview

Security checks run **before** code is merged, catching vulnerabilities early in the development lifecycle.

**Workflow File**: `.github/workflows/security-analysis.yml`

### Components

#### 2.1 GitLeaks - Secret Scanning

**Purpose**: Detect exposed secrets, API keys, passwords, tokens in code.

**Workflow**: `.github/workflows/ci-git-leaks.yml`

**What it scans**:
- Git commit history
- File contents
- Configuration files
- Environment variable definitions

**Example detections**:
- AWS access keys
- GitHub tokens
- Database passwords
- Private keys
- API tokens

**Configuration**: Default rules, can be customized with `.gitleaks.toml`

**Action on detection**: ❌ Blocks the pipeline

**Remediation**:
```bash
# If secret is committed
git reset --soft HEAD~1  # Undo commit
# Remove secret from code
git add .
git commit -m "fix: remove exposed secret"

# If already pushed
# 1. Remove secret and commit
# 2. Rotate the compromised credential immediately
# 3. Consider using git-filter-repo to rewrite history
```

#### 2.2 MegaLinter - Multi-Language Linting

**Purpose**: Enforce code quality, style consistency, and best practices across multiple languages.

**Workflow**: `.github/workflows/ci-mega-linter.yml`

**Configuration**: `.mega-linter.yml`

**Linters included**:
- **JavaScript/Node.js**: ESLint, Prettier
- **HTML**: HTMLHint
- **CSS**: StyleLint
- **Markdown**: markdownlint
- **YAML**: yamllint
- **Dockerfile**: hadolint
- **Shell scripts**: shellcheck
- **Copy-paste detection**: jscpd
- **Spell checking**: cspell

**Output**: Detailed report with file-by-file issues

**Severity levels**:
- 🔴 ERROR: Blocks pipeline
- 🟡 WARNING: Logged but doesn't block

**Best practices**:
- Run locally before commit: `npx mega-linter-runner --flavor javascript`
- Fix auto-fixable issues: MegaLinter can auto-fix many issues
- Review reports in GitHub Actions artifacts

#### 2.3 SonarCloud - SAST (Static Application Security Testing)

**Purpose**: Deep code analysis for security vulnerabilities, code smells, bugs, and technical debt.

**Workflow**: `.github/workflows/ci-sonarcloud-security.yaml`

**Configuration**: `sonar-project.properties`

**Analysis types**:

1. **Security Vulnerabilities**:
   - SQL injection risks
   - XSS (Cross-Site Scripting) vulnerabilities
   - Insecure cryptography
   - Path traversal
   - Code injection

2. **Code Smells**:
   - Maintainability issues
   - Complexity problems
   - Duplicated code
   - Cognitive complexity

3. **Bugs**:
   - Null pointer exceptions
   - Resource leaks
   - Logic errors

4. **Test Coverage**:
   - Percentage of code covered by tests
   - Missing test cases

**Quality Gates**:
```
New Code:
- Coverage ≥ 80%
- Duplicated Lines ≤ 3%
- Maintainability Rating = A
- Reliability Rating = A
- Security Rating = A
```

**Dashboard**: https://sonarcloud.io/project/overview?id=akingbade_interview_portfolio

**Action on failure**: ❌ Blocks merge if quality gate fails

#### 2.4 Snyk - Software Composition Analysis (SCA)

**Purpose**: Detect vulnerabilities in third-party dependencies (npm packages).

**Workflow**: `.github/workflows/ci-snyk.yml`

**What it scans**:
- `package.json` / `package-lock.json`
- Direct dependencies
- Transitive (nested) dependencies
- Container base images
- Infrastructure as Code (Terraform)

**Vulnerability database**:
- CVE database
- Snyk's proprietary vulnerability DB
- Real-time updates

**Severity levels**:
- 🔴 CRITICAL: Immediate action required
- 🔴 HIGH: Should fix soon
- 🟡 MEDIUM: Consider fixing
- ⚪ LOW: Nice to have

**Auto-remediation**:
- Snyk can create PRs with dependency updates
- Suggests version upgrades that fix vulnerabilities

**Example output**:
```
✗ High severity vulnerability found in lodash
  Description: Prototype Pollution
  Info: https://snyk.io/vuln/SNYK-JS-LODASH-590103
  Introduced through: app@1.0.0 > lodash@4.17.15
  Fixed in: lodash@4.17.21
```

**Integration**: Badge in README shows current vulnerability status

#### 2.5 Code Linting & Spell Checking

**ESLint**: JavaScript/Node.js linting
- Configuration: `eslint.config.js`
- Enforces coding standards
- Catches potential bugs

**CSpell**: Spell checking in code comments and docs
- Configuration: `.cspell.json`
- Custom dictionary for technical terms
- Prevents typos in documentation

### Security Pipeline Workflow

```
1. Developer pushes code / creates PR
         ↓
2. GitHub webhook triggers security workflows (parallel execution)
         ↓
3. All security checks run simultaneously:
   - GitLeaks scanning
   - MegaLinter running
   - SonarCloud analyzing
   - Snyk scanning dependencies
   - ESLint + CSpell checking
         ↓
4a. ALL PASS ✅ → PR can be merged
4b. ANY FAIL ❌ → PR blocked, developer must fix issues
         ↓
5. Repeat until all checks pass
```

### Viewing Results

- **GitHub Actions**: Check "Actions" tab for detailed logs
- **Pull Request**: Status checks show pass/fail for each scanner
- **SonarCloud**: Detailed analysis at sonarcloud.io
- **Snyk**: Vulnerability details at snyk.io
- **Badges**: README shows real-time status

---

## 3. Build, Scan & Release Pipeline

### Overview

After security checks pass, the application is built, scanned, and released automatically.

**Workflow File**: `.github/workflows/build-scan-release.yml`

### Pipeline Stages

#### 3.1 Docker Build

**Dockerfile**: `app/Dockerfile`

**Multi-stage build**:

```dockerfile
# Stage 1: Build stage
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .

# Stage 2: Runtime stage
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app .
USER node
EXPOSE 3000
CMD ["node", "index.js"]
```

**Benefits**:
- Smaller final image (no build tools)
- Reduced attack surface
- Faster image pulls
- Better layer caching

**Build command**:
```bash
docker build -t interview-app:latest .
```

**Best practices**:
- Use specific base image versions (not `latest`)
- Run as non-root user (`USER node`)
- Use `.dockerignore` to exclude unnecessary files
- Minimize layers (combine RUN commands)

#### 3.2 Trivy Container Scan

**Purpose**: Scan Docker images for OS and dependency vulnerabilities.

**Scan types**:
1. **OS Packages**: Alpine Linux package vulnerabilities
2. **Application Dependencies**: Node.js package vulnerabilities
3. **Misconfigurations**: Dockerfile best practices

**Severity thresholds**:
```yaml
# Pipeline blocks on:
- CRITICAL: Always blocks
- HIGH: Blocks by default
- MEDIUM: Warning (configurable)
- LOW: Info only
```

**Example output**:
```
Total: 5 (CRITICAL: 1, HIGH: 2, MEDIUM: 2, LOW: 0)

┌────────────┬────────────────┬──────────┬───────────┬──────────────┐
│  Library   │ Vulnerability  │ Severity │  Status   │    Title     │
├────────────┼────────────────┼──────────┼───────────┼──────────────┤
│ openssl    │ CVE-2023-12345 │ CRITICAL │   fixed   │ Buffer Over  │
│            │                │          │           │ flow         │
└────────────┴────────────────┴──────────┴───────────┴──────────────┘
```

**Remediation**:
- Update base image to latest patched version
- Update affected packages
- Apply workarounds if patches unavailable

#### 3.3 Push to GitHub Container Registry (GHCR)

**Registry**: `ghcr.io/akingbadeomosebi/interview-app`

**Authentication**: GitHub token (automatic in Actions)

**Tagging strategy**:

```bash
# Semantic version from release
ghcr.io/akingbadeomosebi/interview-app:3.0.5

# Also tag as latest
ghcr.io/akingbadeomosebi/interview-app:latest

# Git commit SHA (for traceability)
ghcr.io/akingbadeomosebi/interview-app:sha-c3b1fb7
```

**Push command**:
```bash
echo ${{ secrets.GITHUB_TOKEN }} | docker login ghcr.io -u ${{ github.actor }} --password-stdin
docker tag interview-app:latest ghcr.io/akingbadeomosebi/interview-app:v3.0.5
docker push ghcr.io/akingbadeomosebi/interview-app:v3.0.5
```

**Benefits of GHCR**:
- Free for public repos
- Integrated with GitHub Actions
- Fine-grained access control
- High availability
- Fast CDN-backed downloads

#### 3.4 Semantic Release

**Purpose**: Automated versioning and changelog generation based on commit messages.

**Configuration**: `.releaserc.js`

**Process**:

1. **Analyze Commits**: Reads all commits since last release
2. **Determine Version Bump**:
   - `feat:` → Minor version bump (1.0.0 → 1.1.0)
   - `fix:` → Patch version bump (1.0.0 → 1.0.1)
   - `BREAKING CHANGE:` → Major version bump (1.0.0 → 2.0.0)
3. **Generate Changelog**: Creates CHANGELOG.md with all changes
4. **Create Git Tag**: Tags commit with new version
5. **GitHub Release**: Creates release with notes
6. **Update Files**: Updates VERSION.txt, package.json

**Example CHANGELOG.md**:
```markdown
## [3.0.5](https://github.com/.../compare/v3.0.4...v3.0.5) (2025-11-23)

### Bug Fixes

* convert CRLF to LF line endings for workflows ([9ff4bd9](commit-sha))
* house-keeping ([46ec55d](commit-sha))
```

**Configuration example**:
```javascript
module.exports = {
  branches: ['main'],
  plugins: [
    '@semantic-release/commit-analyzer',
    '@semantic-release/release-notes-generator',
    '@semantic-release/changelog',
    '@semantic-release/github',
    '@semantic-release/git'
  ]
};
```

**Benefits**:
- No manual version management
- Consistent versioning across team
- Automatic changelog generation
- Clear release history
- Traceability from code to production

### Complete Build Pipeline Flow

```
┌─────────────────────────────────────────────┐
│ 1. Checkout code                            │
└──────────────────┬──────────────────────────┘
                   ↓
┌─────────────────────────────────────────────┐
│ 2. Build Docker image                       │
│    docker build -t app:latest .             │
└──────────────────┬──────────────────────────┘
                   ↓
┌─────────────────────────────────────────────┐
│ 3. Scan with Trivy                          │
│    trivy image --severity HIGH,CRITICAL app │
└──────────────────┬──────────────────────────┘
                   ↓
         ┌─────────┴─────────┐
         │  Vulnerabilities? │
         └─────────┬─────────┘
                   │
        ┌──────────┴──────────┐
        │ YES ❌              │ NO ✅
        ↓                     ↓
  ┌──────────┐      ┌─────────────────┐
  │ FAIL     │      │ 4. Run Semantic │
  │ Pipeline │      │    Release      │
  └──────────┘      └────────┬────────┘
                             ↓
                    ┌────────────────────┐
                    │ 5. Tag image with  │
                    │    version         │
                    └────────┬───────────┘
                             ↓
                    ┌────────────────────┐
                    │ 6. Push to GHCR    │
                    └────────┬───────────┘
                             ↓
                    ┌────────────────────┐
                    │ 7. Create GitHub   │
                    │    Release         │
                    └────────────────────┘
```

---

## 4. Container Registry

### GitHub Container Registry (GHCR)

**URL**: https://ghcr.io
**Repository**: `ghcr.io/akingbadeomosebi/interview-app`

### Features

1. **Version Management**:
   - Semantic versioning (v3.0.5, v3.0.4, etc.)
   - Latest tag for most recent
   - SHA tags for commit traceability

2. **Access Control**:
   - Public (for this project)
   - Can be made private
   - Fine-grained permissions via GitHub

3. **Integration**:
   - Native GitHub Actions support
   - Automatic authentication
   - Pull from K8s clusters

### Pulling Images

```bash
# Public image (no auth needed)
docker pull ghcr.io/akingbadeomosebi/interview-app:v3.0.5

# In Kubernetes deployment.yaml
spec:
  containers:
  - name: interview-app
    image: ghcr.io/akingbadeomosebi/interview-app:v3.0.5
```

### Image Lifecycle

1. **Build**: Created in CI pipeline
2. **Scan**: Trivy vulnerability scan
3. **Push**: Uploaded to GHCR
4. **Tag**: Multiple tags applied
5. **Deploy**: Pulled by ArgoCD
6. **Monitor**: ArgoCD Image Updater watches for new versions
7. **Cleanup**: Old images can be pruned (retention policy)

### Best Practices

- **Immutable Tags**: Never overwrite existing tags (except `latest`)
- **Small Images**: Use Alpine-based images
- **Vulnerability Scanning**: Regularly rescan old images
- **Retention Policy**: Keep last N versions, delete old ones
- **Layer Caching**: Structure Dockerfile to maximize caching

---

## 5. GitOps Continuous Deployment

### ArgoCD Overview

**Purpose**: Continuous deployment using GitOps principles.

**GitOps Definition**: Git as the single source of truth for declarative infrastructure and applications.

**Installation**: Running in K3s cluster (local) and can be deployed to EKS (cloud).

### ArgoCD Application Configuration

**File**: `k8s/argocd.yaml`

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: interview-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/AkingbadeOmosebi/interview.git
    targetRevision: main
    path: k8s
  destination:
    server: https://kubernetes.default.svc
    namespace: default
  syncPolicy:
    automated:
      prune: true      # Delete resources not in Git
      selfHeal: true   # Revert manual changes
    syncOptions:
    - CreateNamespace=true
```

### Key Concepts

#### 5.1 Declarative Configuration

Everything defined in Git manifests:
- Deployments
- Services
- ConfigMaps
- Secrets (sealed)
- Ingress rules

**Benefit**: Infrastructure/applications can be recreated from Git alone.

#### 5.2 Auto-Sync

ArgoCD continuously monitors Git repo:
- Polls every 3 minutes (default)
- Webhook for instant updates (optional)
- Detects manifest changes
- Automatically applies changes to cluster

#### 5.3 Self-Heal

If someone manually modifies cluster:
```bash
kubectl scale deployment interview-app --replicas=5
```

ArgoCD detects drift and reverts to Git definition (replicas: 2).

**Benefit**: Prevents configuration drift, ensures consistency.

#### 5.4 Prune

When resources are removed from Git:
- ArgoCD deletes them from cluster
- Keeps cluster in sync with Git
- No orphaned resources

### ArgoCD Image Updater

**Purpose**: Automatically update image tags in Git when new versions are pushed to registry.

**Configuration**: Annotations in `deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: interview-app
  annotations:
    argocd-image-updater.argoproj.io/image-list: interview-app=ghcr.io/akingbadeomosebi/interview-app
    argocd-image-updater.argoproj.io/interview-app.update-strategy: semver
    argocd-image-updater.argoproj.io/write-back-method: git
spec:
  template:
    spec:
      containers:
      - name: interview-app
        image: ghcr.io/akingbadeomosebi/interview-app:v3.0.4  # Will be updated
```

**How it works**:

1. Image Updater polls GHCR every 2 minutes
2. Detects new semantic version (v3.0.5)
3. Compares with current version (v3.0.4)
4. Updates `deployment.yaml` in Git
5. Creates commit: `build: automatic image update to v3.0.5`
6. ArgoCD detects Git change
7. Syncs new version to cluster
8. Deployment rolls out new pods

**Update strategies**:
- `semver`: Follow semantic versioning (default)
- `latest`: Always use latest tag
- `digest`: Use image digest for immutability
- `name`: Custom tag pattern matching

### ArgoCD UI

**Access**:
```bash
# Port forward to access locally
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

**Dashboard features**:
- Application health status
- Sync status (synced vs out-of-sync)
- Resource tree visualization
- Event logs
- Manual sync button
- Rollback to previous versions
- Diff view (Git vs cluster)

### GitOps Workflow

```
Developer workflow:
1. Modify k8s/deployment.yaml (e.g., change replica count)
2. Commit and push to GitHub
3. ArgoCD detects change within 3 minutes
4. ArgoCD syncs changes to K3s cluster
5. Kubernetes rolls out changes
6. Developer verifies via ArgoCD UI or kubectl

Automated workflow (image update):
1. CI pipeline builds new image v3.0.5
2. Pushes to GHCR
3. ArgoCD Image Updater detects new version
4. Updates deployment.yaml in Git
5. ArgoCD syncs to cluster
6. New version deployed automatically
```

---

## 6. Local Environment (K3s)

### Overview

**K3s**: Lightweight Kubernetes distribution perfect for local development, testing, and CI/CD.

**Platform**: WSL2 (Windows Subsystem for Linux) on local machine

**Benefits**:
- Fast startup (~30 seconds)
- Low resource usage (512MB RAM minimum)
- Production-equivalent API
- Cost-free testing environment

### K3s Installation

```bash
# Install K3s on WSL2
curl -sfL https://get.k3s.io | sh -

# Verify installation
sudo k3s kubectl get nodes

# Configure kubectl
mkdir ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $USER ~/.kube/config
```

### Cluster Configuration

**Components**:
- **Control Plane**: Single node (master)
- **Worker**: Same node (all-in-one)
- **Storage**: Local path provisioner
- **Networking**: Flannel CNI
- **Load Balancer**: Klipper (built-in)

### Namespaces

```
default          → Application workloads
argocd           → ArgoCD components
monitoring       → Prometheus, Grafana, Alertmanager
kube-system      → K3s system components, SealedSecrets
ngrok            → Ngrok agent
```

### Application Deployment

**File**: `k8s/deployment.yaml`

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: interview-app
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: interview-app
  template:
    metadata:
      labels:
        app: interview-app
    spec:
      containers:
      - name: interview-app
        image: ghcr.io/akingbadeomosebi/interview-app:v3.0.5
        ports:
        - containerPort: 3000
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        livenessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 30
          periodSeconds: 10
          timeoutSeconds: 5
          failureThreshold: 3
        readinessProbe:
          httpGet:
            path: /
            port: 8080
          initialDelaySeconds: 10
          periodSeconds: 5
          timeoutSeconds: 3
          failureThreshold: 3
```

**Key features**:
- **Replicas: 2**: High availability, rolling updates
- **Resource limits**: Prevent resource exhaustion
- **Probes**: Kubernetes restarts unhealthy pods
- **Labels**: Service discovery

### Service Definition

**File**: `k8s/service.yaml`

```yaml
apiVersion: v1
kind: Service
metadata:
  name: interview-app-service
  namespace: default
spec:
  type: NodePort
  ports:
  - name: http
    port: 8080
    targetPort: 8080
    nodePort: 31080
    protocol: TCP
  selector:
    app: interview-app
```

**Service types**:
- **NodePort**: Accessible on node IP:port (used for local K3s)
- **ClusterIP**: Internal only
- **LoadBalancer**: External load balancer (AWS ELB in cloud)

### Accessing the Application

**Within cluster**:
```bash
kubectl run -it --rm debug --image=alpine --restart=Never -- sh
wget -qO- interview-app-service.default.svc.cluster.local
```

**Port forward** (local testing):
```bash
kubectl port-forward svc/interview-app-service 8080:80
# Access at http://localhost:8080
```

**Via Ngrok** (public access):
See section on Ngrok below.

### Managing K3s

**Common commands**:

```bash
# View all resources
kubectl get all -A

# Check pod logs
kubectl logs -f deployment/interview-app

# Describe pod (debugging)
kubectl describe pod <pod-name>

# Execute command in pod
kubectl exec -it <pod-name> -- sh

# View events
kubectl get events --sort-by='.lastTimestamp'

# Restart deployment (force new pods)
kubectl rollout restart deployment/interview-app

# View rollout status
kubectl rollout status deployment/interview-app

# Rollback to previous version
kubectl rollout undo deployment/interview-app
```

---

## 7. Observability Stack

### Overview

**Components**:
- **Prometheus**: Metrics collection and alerting
- **Grafana**: Metrics visualization
- **Alertmanager**: Alert routing and notifications

**Namespace**: `monitoring`

### 7.1 Prometheus

**Purpose**: Time-series database for metrics.

**Installation**: `k8s/monitoring/prometheus-app.yaml`

**Architecture**:
```
Prometheus Server
├── Scrapes metrics from targets (pull model)
├── Stores time-series data (15 days retention)
├── Evaluates alerting rules
└── Serves PromQL queries
```

**Metrics sources**:

1. **Kubernetes Metrics**:
   - Node CPU, memory, disk
   - Pod resource usage
   - Container metrics
   - K8s API server metrics

2. **Application Metrics**:
   - HTTP requests/second
   - Response times
   - Error rates
   - Custom business metrics

**Scrape configuration**:
```yaml
scrape_configs:
  - job_name: 'kubernetes-pods'
    kubernetes_sd_configs:
    - role: pod
    relabel_configs:
    - source_labels: [__meta_kubernetes_pod_annotation_prometheus_io_scrape]
      action: keep
      regex: true
```

**Prometheus UI**:
```bash
kubectl port-forward -n monitoring svc/prometheus 9090:9090
# Access at http://localhost:9090
```

**Example PromQL queries**:

```promql
# CPU usage by pod
sum(rate(container_cpu_usage_seconds_total[5m])) by (pod)

# Memory usage
container_memory_usage_bytes{pod=~"interview-app.*"}

# HTTP request rate
rate(http_requests_total[1m])

# 95th percentile response time
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))
```

**Alert rules**:
```yaml
groups:
  - name: application
    rules:
    - alert: HighErrorRate
      expr: rate(http_requests_total{status="500"}[5m]) > 0.05
      for: 5m
      labels:
        severity: critical
      annotations:
        summary: "High error rate detected"
        description: "Error rate is {{ $value }} req/s"
```

### 7.2 Grafana

**Purpose**: Visualization and dashboards for Prometheus data.

**Installation**: Deployed in monitoring namespace

**Access**:
```bash
kubectl port-forward -n monitoring svc/grafana 3000:3000

# Get admin password (from SealedSecret)
kubectl get secret -n monitoring grafana-admin-secret -o jsonpath='{.data.password}' | base64 -d
```

**Pre-configured dashboards**:

1. **K3s Cluster Overview**:
   - Node CPU/Memory/Disk usage
   - Pod count
   - Cluster health
   - Resource utilization

2. **Application Metrics**:
   - Request rate
   - Error rate
   - Response times (p50, p95, p99)
   - Active connections

3. **Pod Performance**:
   - CPU usage per pod
   - Memory usage per pod
   - Network I/O
   - Restarts

**Dashboard import**:
```
Settings → Data Sources → Add Prometheus
URL: http://prometheus:9090

Dashboards → Import
Enter dashboard ID:
- 1860: Node Exporter Full
- 6417: Kubernetes Cluster
- 315: Kubernetes Cluster Monitoring
```

**Creating custom dashboard**:
1. Dashboard → Add Panel
2. Enter PromQL query
3. Choose visualization (graph, gauge, stat, table)
4. Set thresholds and alerts
5. Save dashboard

### 7.3 Alertmanager

**Purpose**: Handle alerts from Prometheus, route to appropriate channels.

**Installation**: `k8s/notification/alert-manager.yaml`

**Configuration**:
```yaml
route:
  group_by: ['alertname', 'cluster', 'service']
  group_wait: 10s
  group_interval: 10s
  repeat_interval: 12h
  receiver: 'default'
  routes:
  - match:
      severity: critical
    receiver: 'email-critical'
  - match:
      severity: warning
    receiver: 'slack-warnings'

receivers:
  - name: 'default'
    webhook_configs:
    - url: 'http://webhook.example.com/alerts'

  - name: 'email-critical'
    email_configs:
    - to: 'ops-team@example.com'
      from: 'alertmanager@example.com'
      smarthost: 'smtp.gmail.com:587'
      auth_username: 'alerts@example.com'
      auth_password: '<secret>'

  - name: 'slack-warnings'
    slack_configs:
    - api_url: 'https://hooks.slack.com/services/xxx'
      channel: '#alerts'
      text: '{{ range .Alerts }}{{ .Annotations.summary }}{{ end }}'
```

**Alert flow**:
```
1. Prometheus evaluates rules
2. Alert triggered (condition met for duration)
3. Prometheus sends to Alertmanager
4. Alertmanager groups alerts
5. Routes to appropriate receiver
6. Notification sent (email, Slack, PagerDuty, etc.)
7. Alert resolved when condition clears
```

**Alertmanager UI**:
```bash
kubectl port-forward -n monitoring svc/alertmanager 9093:9093
# Access at http://localhost:9093
```

**Silencing alerts**:
- Temporarily mute alerts during maintenance
- Configure in UI or via API
- Specify duration and matching criteria

### Observability Best Practices

1. **Four Golden Signals**:
   - **Latency**: Request/response time
   - **Traffic**: Requests per second
   - **Errors**: Error rate
   - **Saturation**: Resource utilization

2. **Metrics to monitor**:
   - Application: Response time, error rate, throughput
   - Infrastructure: CPU, memory, disk, network
   - Business: User signups, transactions, conversions

3. **Alert guidelines**:
   - Alert on symptoms, not causes
   - Make alerts actionable
   - Include runbook links
   - Set appropriate thresholds
   - Avoid alert fatigue

4. **Dashboard design**:
   - Start with overview, drill down
   - Use consistent color schemes
   - Show trends over time
   - Include SLO/SLA indicators

---

## 8. Secrets Management

### Overview

**Challenge**: Store sensitive data (passwords, API keys) securely in Git.

**Solution**: Sealed Secrets (Bitnami)

### Architecture

```
Developer Machine:
  ├── Create K8s Secret (plaintext)
  ├── Encrypt with kubeseal CLI
  └── Get SealedSecret (encrypted YAML)
         ↓
  Git Repository:
  ├── Store SealedSecret (safe to commit)
         ↓
  K8s Cluster:
  ├── ArgoCD deploys SealedSecret
  ├── Sealed Secrets Controller detects
  ├── Decrypts using cluster private key
  └── Creates K8s Secret (plaintext, in-cluster only)
         ↓
  Application:
  └── Mounts Secret as env var or volume
```

### Installation

```bash
# Install Sealed Secrets controller
kubectl apply -f https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/controller.yaml

# Install kubeseal CLI
wget https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.24.0/kubeseal-linux-amd64
sudo install -m 755 kubeseal-linux-amd64 /usr/local/bin/kubeseal
```

### Creating Sealed Secrets

**Step 1**: Create normal K8s secret (don't commit!)

```bash
kubectl create secret generic grafana-admin-secret \
  --from-literal=username=admin \
  --from-literal=password='SuperSecure123!' \
  --dry-run=client \
  -o yaml > secret.yaml
```

**Step 2**: Encrypt with kubeseal

```bash
kubeseal < secret.yaml > sealed-secret.yaml

# Or pipe directly
kubectl create secret generic grafana-admin-secret \
  --from-literal=username=admin \
  --from-literal=password='SuperSecure123!' \
  --dry-run=client \
  -o yaml | kubeseal > k8s/secrets/grafana-admin-secret.yaml
```

**Step 3**: Commit sealed secret to Git

```bash
git add k8s/secrets/grafana-admin-secret.yaml
git commit -m "feat: add Grafana admin credentials"
git push
```

**Sealed secret YAML**:
```yaml
apiVersion: bitnami.com/v1alpha1
kind: SealedSecret
metadata:
  name: grafana-admin-secret
  namespace: monitoring
spec:
  encryptedData:
    username: AgBX7VzK...encrypted-base64...
    password: AgCY9mPw...encrypted-base64...
  template:
    metadata:
      name: grafana-admin-secret
      namespace: monitoring
```

### Using Secrets in Pods

**Environment variables**:
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: grafana
spec:
  template:
    spec:
      containers:
      - name: grafana
        env:
        - name: GF_SECURITY_ADMIN_USER
          valueFrom:
            secretKeyRef:
              name: grafana-admin-secret
              key: username
        - name: GF_SECURITY_ADMIN_PASSWORD
          valueFrom:
            secretKeyRef:
              name: grafana-admin-secret
              key: password
```

**Volume mount**:
```yaml
spec:
  template:
    spec:
      containers:
      - name: app
        volumeMounts:
        - name: secrets
          mountPath: "/etc/secrets"
          readOnly: true
      volumes:
      - name: secrets
        secret:
          secretName: grafana-admin-secret
```

### Security Features

1. **Asymmetric Encryption**:
   - Public key: Used by kubeseal CLI (safe to share)
   - Private key: Stays in cluster only (never leaves)

2. **Namespace-scoped**:
   - SealedSecret can only be decrypted in specific namespace
   - Prevents accidental deployment to wrong namespace

3. **Name-scoped** (optional):
   - Further restrict to specific secret name

4. **Rotation**:
```bash
# Get current sealed secret
kubectl get sealedsecret grafana-admin-secret -o yaml > old.yaml

# Create new secret with updated password
kubectl create secret generic grafana-admin-secret \
  --from-literal=username=admin \
  --from-literal=password='NewPassword456!' \
  --dry-run=client \
  -o yaml | kubeseal > k8s/secrets/grafana-admin-secret.yaml

# Commit and let ArgoCD sync
```

### Secrets in This Project

| Secret Name | Namespace | Contains |
|------------|-----------|----------|
| grafana-admin-secret | monitoring | Grafana admin user/pass |
| alertmanager-config | monitoring | SMTP credentials, API keys |
| ngrok-authtoken | ngrok | Ngrok authentication token |
| db-credentials | default | Database connection string (if applicable) |

### Best Practices

1. **Never commit plaintext secrets to Git**
2. **Use Sealed Secrets for GitOps**
3. **Rotate secrets regularly**
4. **Limit secret access** (RBAC)
5. **Audit secret usage**
6. **Use different secrets per environment**
7. **Consider external secret managers** for production:
   - AWS Secrets Manager + External Secrets Operator
   - HashiCorp Vault
   - Azure Key Vault

---

## 9. Cloud Infrastructure (AWS EKS)

### Overview

**Purpose**: Production-ready, managed Kubernetes on AWS.

**Managed by**: Terraform (Infrastructure as Code)

**Location**: `infrastructure/` directory

### AWS Components

#### 9.1 VPC (Virtual Private Cloud)

**CIDR**: `10.0.0.0/16`

**Subnets**:
```
Public Subnets (for Load Balancers):
├── eu-central-1a: 10.0.1.0/24
└── eu-central-1b: 10.0.2.0/24

Private Subnets (for EKS Nodes):
├── eu-central-1a: 10.0.10.0/24
└── eu-central-1b: 10.0.11.0/24
```

**Internet Gateway**: Allows public subnet outbound access

**NAT Gateway**: Allows private subnet outbound access (for pulling images, etc.)

**Why private subnets?**:
- Worker nodes not directly exposed to internet
- Enhanced security
- Controlled egress via NAT

#### 9.2 IAM Roles & OIDC

**GitHub OIDC Provider**:
```hcl
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
}
```

**Benefits**:
- No long-lived AWS access keys
- Temporary credentials per workflow run
- Automatic rotation
- Scope-limited permissions

**Trust policy**:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com",
          "token.actions.githubusercontent.com:sub": "repo:AkingbadeOmosebi/interview:ref:refs/heads/main"
        }
      }
    }
  ]
}
```

**EKS Cluster Role**: Permissions for EKS control plane

**Node Group Role**: Permissions for worker nodes (ECR, CloudWatch, EBS)

#### 9.3 EKS Cluster

**Configuration**:
```hcl
resource "aws_eks_cluster" "main" {
  name     = "opsfolio-eks"
  role_arn = aws_iam_role.eks_cluster.arn
  version  = "1.29"

  vpc_config {
    subnet_ids              = concat(aws_subnet.private[*].id, aws_subnet.public[*].id)
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks.arn
    }
    resources = ["secrets"]
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}
```

**Features**:
- **Managed Control Plane**: AWS manages master nodes
- **High Availability**: Multi-AZ control plane
- **Secrets Encryption**: KMS-encrypted etcd
- **CloudWatch Logs**: Cluster audit logs
- **VPC Integration**: Secure networking

#### 9.4 EKS Node Group

**Configuration**:
```hcl
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "opsfolio-nodes"
  node_role_arn   = aws_iam_role.eks_nodes.arn
  subnet_ids      = aws_subnet.private[*].id

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  instance_types = ["t3.small"]

  remote_access {
    ec2_ssh_key = "my-keypair"  # Optional SSH access
  }

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

**Auto-scaling**:
- Horizontal Pod Autoscaler (HPA): Scale pods based on CPU/memory (not enabled for demo)
- Cluster Autoscaler: Add/remove nodes based on pending pods (not enabled for demo)
- Single node deployment (cost-optimized for portfolio demo)
- Production would use: Min 2, Max 4+ for high availability

**Instance selection**:
- `t3.small`: 2 vCPU, 2GB RAM
- Burstable performance
- Cost-effective for dev/demo (single node for cost control)
- Production may scale to larger `t3.small` clusters, `m5.large` or spot instances

#### 9.5 Application Load Balancer (ALB)

**Automatically created** when K8s Service type is LoadBalancer.

**AWS Load Balancer Controller**:
- Manages ALB/NLB creation
- Configured via K8s annotations
- Integrates with Target Groups
- Supports WAF, SSL termination

**Service configuration**:
```yaml
apiVersion: v1
kind: Service
metadata:
  name: interview-app-service
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "external"
    service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: "ip"
    service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 3000
  selector:
    app: interview-app
```

**Features**:
- Multi-AZ load balancing
- Health checks
- SSL termination (with ACM certificate)
- WAF integration (optional)
- Access logs to S3

**Custom domain** (optional):
```
1. Register domain in Route 53
2. Create ACM certificate for domain
3. Add annotation to service:
   service.beta.kubernetes.io/aws-load-balancer-ssl-cert: arn:aws:acm:...
4. Create Route 53 alias record:
   opsfolio.yourdomain.com → ALB DNS
```

### Deploying to EKS

**Option 1: kubectl** (manual)
```bash
# Configure kubectl
aws eks update-kubeconfig --name opsfolio-eks --region eu-central-1

# Apply manifests
kubectl apply -f k8s/
```

**Option 2: ArgoCD** (GitOps, recommended)
```bash
# Install ArgoCD to EKS
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Create application (same as local)
kubectl apply -f k8s/argocd.yaml
```

### Accessing EKS Application

**Via Load Balancer**:
```bash
# Get ALB DNS
kubectl get svc interview-app-service
# NAME                    TYPE           EXTERNAL-IP
# interview-app-service   LoadBalancer   a1b2c3-123456.eu-central-1.elb.amazonaws.com

# Access application
curl http://a1b2c3-123456.eu-central-1.elb.amazonaws.com
```

**Via kubectl port-forward** (debugging):
```bash
kubectl port-forward svc/interview-app-service 8080:80
```

### EKS Cost Optimization

1. **Node Auto-scaling**: Scale down during off-hours
2. **Spot Instances**: Up to 90% discount for interruptible workloads
3. **Right-sizing**: Use smallest instance that meets requirements
4. **Reserved Instances**: Commit to 1-3 years for 30-60% discount
5. **Fargate** (alternative): Serverless, pay-per-pod (no node management)

**Monthly cost estimate**:
```
EKS Control Plane: $73/month
t3.small node (1): ~$15/month
NAT Gateway: ~$35/month
Load Balancer: ~$20/month
Total: ~$188/month (can be reduced with spot instances)
```

---

## 10. Terraform & Infrastructure as Code

### Overview

**Directory**: `infrastructure/`

**Purpose**: Define, version, and automate AWS infrastructure.

**State Management**: Terraform Cloud (remote backend)

### File Structure

```
infrastructure/
├── main.tf          # Primary resource definitions
├── provider.tf      # AWS provider configuration
├── variables.tf     # Input variables
├── outputs.tf       # Output values (cluster endpoint, etc.)
├── versions.tf      # Terraform version constraints
└── terraform.tfvars # Variable values (gitignored)
```

### Key Resources

**main.tf**:
```hcl
# VPC
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "opsfolio-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["eu-central-1a", "eu-central-1b"]
  private_subnets = ["10.0.10.0/24", "10.0.11.0/24"]
  public_subnets  = ["10.0.1.0/24", "10.0.2.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = false  # High availability
  enable_dns_hostnames = true

  tags = {
    "kubernetes.io/cluster/opsfolio-eks" = "shared"
  }
}

# EKS Cluster
module "eks" {
  source = "terraform-aws-modules/eks/aws"

  cluster_name    = "opsfolio-eks"
  cluster_version = "1.29"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  eks_managed_node_groups = {
    main = {
      desired_size = 2
      min_size     = 2
      max_size     = 4

      instance_types = ["t3.small"]
      capacity_type  = "ON_DEMAND"  # or "SPOT" for cost savings
    }
  }
}
```

**provider.tf**:
```hcl
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  # Remote state in Terraform Cloud
  backend "remote" {
    organization = "opsfolio"

    workspaces {
      name = "opsfolio-eks"
    }
  }
}

provider "aws" {
  region = var.aws_region

  # Assume role via OIDC (in GitHub Actions)
  # No access keys needed!
}
```

**variables.tf**:
```hcl
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "eu-central-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "opsfolio-eks"
}

variable "node_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.small"
}
```

**outputs.tf**:
```hcl
output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_certificate_authority_data" {
  description = "Base64 encoded certificate data"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}
```

### Terraform Cloud Setup

**Why Terraform Cloud?**:
- Remote state storage (no local state files)
- State locking (prevent concurrent applies)
- Version history
- Collaboration features
- Secrets management

**Setup**:
1. Create account at app.terraform.io
2. Create organization: "opsfolio"
3. Create workspace: "opsfolio-eks"
4. Configure workspace:
   - Execution Mode: Remote
   - Terraform Version: 1.6.x
   - Variables: Set AWS region, cluster name, etc.
5. Generate API token
6. Store in GitHub secret: `TF_API_TOKEN`

**GitHub Actions integration**:
```yaml
- name: Setup Terraform
  uses: hashicorp/setup-terraform@v2
  with:
    cli_config_credentials_token: ${{ secrets.TF_API_TOKEN }}

- name: Terraform Init
  run: terraform init

- name: Terraform Plan
  run: terraform plan

- name: Terraform Apply
  run: terraform apply -auto-approve
```

### Terraform Workflow

**Local development**:
```bash
cd infrastructure/

# Initialize
terraform init

# Validate syntax
terraform validate

# Format code
terraform fmt

# Preview changes
terraform plan

# Apply changes (with approval)
terraform apply

# Destroy resources (careful!)
terraform destroy
```

**CI/CD workflow** (automated):
```
1. Developer modifies infrastructure/*.tf
2. Commits and creates PR
3. GitHub Actions runs:
   a. terraform validate
   b. tfsec security scan
   c. terraform plan
   d. Infracost estimate
   e. Posts plan and cost to PR comment
4. Reviewer approves PR
5. Merge to main
6. GitHub Actions runs:
   a. terraform apply (auto-approved)
7. Resources created/updated in AWS
8. Outputs saved in Terraform Cloud
```

### Terraform Best Practices

1. **Use Modules**: Reusable, community-vetted (terraform-aws-modules)
2. **Remote State**: Never commit state files
3. **Variable Files**: Separate config from code
4. **Version Pinning**: Lock provider versions
5. **Plan Before Apply**: Always review changes
6. **Workspaces**: Separate environments (dev, staging, prod)
7. **Tagging**: Tag all resources for cost allocation
8. **Documentation**: Comment complex resources

---

## 11. Cost Management (FinOps)

### Infracost

**Purpose**: Estimate cloud costs before deployment, prevent surprise bills.

**Integration**: Runs in Terraform pipeline

**Workflow File**: `.github/workflows/terraform-deploy-eks-tfsec.yaml`

### How It Works

```yaml
- name: Setup Infracost
  uses: infracost/actions/setup@v2
  with:
    api-key: ${{ secrets.INFRACOST_API_KEY }}

- name: Generate Infracost JSON
  run: infracost breakdown --path=infrastructure --format=json --out-file=/tmp/infracost.json

- name: Post Infracost Comment
  uses: infracost/actions/comment@v1
  with:
    path: /tmp/infracost.json
    behavior: update
```

### Example Output

**PR Comment**:
```markdown
## Monthly Cost Estimate

### ✏️ Changes Summary

| Resource | Monthly Cost | Change |
|----------|--------------|--------|
| aws_eks_cluster.main | $73.00 | +$73.00 |
| aws_eks_node_group.main (t3.small x1) | $15.00 | +$15.00 |
| aws_nat_gateway.main (x2) | $65.00 | +$65.00 |
| aws_lb.application | $20.00 | +$20.00 |
| **Total** | **$218.00** | **+$218.00 (+100%)** |

### 💰 Cost Optimization Opportunities

- Consider using Spot instances for node group (save ~70%)
- Use single NAT gateway for non-production (save $32.50/mo)
- Enable auto-scaling to scale down during off-hours

[View detailed breakdown →](https://dashboard.infracost.io/...)
```

### Cost Control Strategies

1. **Threshold Alerts**:
```yaml
- name: Check Cost Threshold
  run: |
    cost=$(jq -r '.totalMonthlyCost' /tmp/infracost.json)
    if (( $(echo "$cost > 500" | bc -l) )); then
      echo "::error::Cost exceeds $500/month threshold!"
      exit 1
    fi
```

2. **Approval Required**: High-cost changes require manager approval

3. **Environment-specific budgets**:
   - Dev: $100/month
   - Staging: $300/month
   - Production: $1000/month

### AWS Cost Explorer

**Additional monitoring**:
- Enable AWS Cost Explorer
- Set budget alerts in AWS Budgets
- Create cost allocation tags
- Use AWS Cost Anomaly Detection

**Example tags**:
```hcl
resource "aws_instance" "example" {
  # ...
  tags = {
    Environment = "production"
    Project     = "opsfolio"
    ManagedBy   = "terraform"
    CostCenter  = "engineering"
    Owner       = "devops-team"
  }
}
```

### Cost Optimization Checklist

- [ ] Right-size instances (don't over-provision)
- [ ] Use auto-scaling (scale down when idle)
- [ ] Leverage spot instances (70-90% savings)
- [ ] Use reserved instances for predictable workloads
- [ ] Delete unused resources (old snapshots, orphaned EBS volumes)
- [ ] Use S3 lifecycle policies (move to Glacier)
- [ ] Enable CloudWatch alarms for billing
- [ ] Review cost reports monthly
- [ ] Tag all resources for accountability

---

## 12. Workflow Integration

### Complete DevSecOps Flow

```
┌─────────────────────────────────────────────────────────────┐
│ 1. DEVELOPER COMMITS CODE                                   │
│    git commit -m "feat: add new feature"                    │
│    git push origin main                                     │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. GITHUB WEBHOOK TRIGGERS CI/CD                            │
│    Multiple workflows start in parallel                     │
└────────────────────┬────────────────────────────────────────┘
                     │
         ┌───────────┴──────────────┐
         │                          │
         ↓                          ↓
┌────────────────────┐    ┌─────────────────────┐
│ SECURITY PIPELINE  │    │ QUALITY CHECKS      │
│ - GitLeaks         │    │ - ESLint            │
│ - MegaLinter       │    │ - Prettier          │
│ - SonarCloud       │    │ - CSpell            │
│ - Snyk             │    │ - Unit tests        │
└────────┬───────────┘    └──────────┬──────────┘
         │                           │
         └───────────┬───────────────┘
                     │
                     ↓
         ┌───────────────────────┐
         │   ALL CHECKS PASS?    │
         └───────────┬───────────┘
                     │
          ┌──────────┴──────────┐
          │                     │
        ❌ NO                 ✅ YES
          │                     │
          ↓                     ↓
    ┌──────────┐    ┌──────────────────────┐
    │  FAIL    │    │ BUILD & RELEASE      │
    │  BLOCK   │    │ - Docker build       │
    │  MERGE   │    │ - Trivy scan         │
    └──────────┘    │ - Push to GHCR       │
                    │ - Semantic Release   │
                    └──────────┬───────────┘
                               │
                               ↓
                    ┌──────────────────────┐
                    │ NEW VERSION RELEASED │
                    │ ghcr.io/.../app:v3.0.5│
                    └──────────┬───────────┘
                               │
               ┌───────────────┴───────────────┐
               │                               │
               ↓                               ↓
    ┌──────────────────────┐        ┌──────────────────────┐
    │ LOCAL DEPLOYMENT     │        │ CLOUD DEPLOYMENT     │
    │                      │        │ (if triggered)       │
    │ ArgoCD Image Updater │        │                      │
    │ detects new version  │        │ Terraform workflow   │
    │         ↓            │        │ if infra changed     │
    │ Updates deployment   │        │         ↓            │
    │ in Git               │        │ - TFsec scan         │
    │         ↓            │        │ - Infracost estimate │
    │ ArgoCD syncs         │        │ - Terraform apply    │
    │         ↓            │        │         ↓            │
    │ K3s deploys new pods │        │ EKS cluster updated  │
    │         ↓            │        │         ↓            │
    │ Prometheus scrapes   │        │ Deploy app to EKS    │
    │ Grafana shows        │        │         ↓            │
    │         ↓            │        │ ALB routes traffic   │
    │ Alertmanager ready   │        │         ↓            │
    │         ↓            │        │ CloudWatch monitors  │
    │ Ngrok exposes        │        │                      │
    └──────────────────────┘        └──────────────────────┘
```

### GitHub Actions Workflows

**All workflows**: `.github/workflows/`

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| security-analysis.yml | Push, PR | GitLeaks, MegaLinter, SonarCloud, Snyk |
| quality-checks.yml | Push, PR | ESLint, tests, code formatting |
| build-scan-release.yml | Push to main | Docker build, Trivy, push to GHCR, Semantic Release |
| terraform-deploy-eks-tfsec.yaml | Manual, push (infra/) | TFsec, Infracost, Terraform apply |
| terraform-destroy.yml | Manual only | Destroy AWS resources (with confirmation) |
| House-keeping.yml | Scheduled (weekly) | Dependency updates, cleanup |

### Workflow Best Practices

1. **Parallel Execution**: Run independent jobs concurrently
2. **Caching**: Cache dependencies (npm, terraform providers)
3. **Secrets Management**: Use GitHub Secrets, never hardcode
4. **Status Checks**: Require workflows to pass before merge
5. **Manual Approvals**: For destructive operations (destroy, prod deploy)
6. **Notifications**: Slack/email on failure
7. **Workflow Reusability**: Use reusable workflows for common tasks
8. **Branch Protection**: Enforce workflow success

### Monitoring Workflow Execution

**GitHub Actions UI**:
- View workflow runs
- Download logs
- Re-run failed jobs
- See execution time
- Cost breakdown (for private repos)

**Badges in README**:
- Real-time status
- Click to view workflow details
- Shows last run status

---

## Conclusion

This architecture demonstrates a comprehensive DevSecOps implementation covering:

✅ **Security**: Shift-left security with multiple scanning layers
✅ **Automation**: Fully automated CI/CD pipelines
✅ **GitOps**: Git as single source of truth
✅ **Observability**: Comprehensive monitoring and alerting
✅ **Cost Control**: FinOps practices with Infracost
✅ **Infrastructure as Code**: Versioned, reviewable infrastructure
✅ **Scalability**: K3s for local, EKS for production
✅ **Zero-Trust**: OIDC authentication, no long-lived credentials
✅ **Documentation**: Every component documented and explainable

This project showcases production-ready DevSecOps practices suitable for enterprise environments and demonstrates mastery of modern cloud-native technologies.

---

## Additional Resources

- **Project README**: `/README.md`
- **Local Setup Guide**: `/docs/local-onprem-setup.md`
- **Cloud Setup Guide**: `/docs/cloud-infrastructure-setup.md`
- **CI/CD Workflows**: `/docs/Secure-Continous-Integration-Workflows.md`
- **GitHub Repository**: https://github.com/AkingbadeOmosebi/interview

---

**Last Updated**: 2025-11-23
**Author**: Akingbade Omosebi
**Project**: Opsfolio DevSecOps Portfolio
