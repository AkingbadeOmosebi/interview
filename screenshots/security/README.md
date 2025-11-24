# Security Screenshots Directory

This directory contains screenshots demonstrating the security scanning results of the Opsfolio Interview App.

## Required Screenshots

Add the following screenshots to this directory:

### 1. `gitleaks-clean.png`
**Content**: GitLeaks scan showing no secrets detected
- Show the clean scan result from GitHub Actions
- Highlight: "No leaks found" or similar message
- Include: Files scanned count

### 2. `megalinter-results.png`
**Content**: MegaLinter summary results
- Show the overall linter results table
- Include: Total linters run, errors, warnings
- Highlight: Overall PASS status despite warnings

### 3. `sonarcloud-dashboard.png`
**Content**: SonarCloud project dashboard
- Show: Security rating, Reliability rating, Maintainability rating
- Include: Bugs count, Code smells count
- Highlight: A rating for security

### 4. `snyk-fixed-vulnerabilities.png`
**Content**: Snyk scan showing vulnerability fixes
- **IMPORTANT**: Show BEFORE and AFTER comparison if possible
- Highlight: Critical and High vulnerabilities fixed
- Show: Current status with 0 critical/high issues

### 5. `trivy-clean-scan.png`
**Content**: Trivy container scan results
- Show: 0 vulnerabilities found
- Include: Base image (nginx:1.29.3-alpine)
- Highlight: PASS status

### 6. `tfsec-issues.png`
**Content**: TFsec infrastructure scan results
- Show: All 6 issues listed
- Highlight: 3 Critical, 3 High severity
- Include: Issue codes and descriptions

## How to Add Screenshots

### From GitHub Actions (Recommended)

1. Navigate to your GitHub repository
2. Go to **Actions** tab
3. Select a recent workflow run (e.g., "Security Analysis")
4. Click on the specific job (e.g., "GitLeaks", "Snyk")
5. Scroll to the relevant step output
6. Take a screenshot of the results
7. Save to this directory with the appropriate filename

### From Local Runs (Alternative)

```bash
# GitLeaks
gitleaks detect --source . --verbose

# MegaLinter (via Docker)
docker run --rm -v $(pwd):/tmp/lint oxsecurity/megalinter:v7

# Snyk
snyk test

# Trivy
trivy image ghcr.io/akingbadeomosebi/interview-app:latest

# TFsec
tfsec infrastructure/
```

## Screenshot Requirements

- **Format**: PNG (preferred) or JPG
- **Resolution**: At least 1920x1080 for clarity
- **Content**: Focus on the results, crop unnecessary UI
- **Text**: Ensure text is readable (use zoom if needed)
- **Annotations**: Optional but helpful (arrows, highlights)

## Image Optimization

Keep file sizes reasonable:

```bash
# Install imagemagick if needed
sudo apt-get install imagemagick

# Optimize screenshots
mogrify -resize 1920x1080\> -quality 85 *.png
```

## Updating the Documentation

After adding screenshots, the main documentation will automatically reference them:
- See: `/docs/secure-cicd-workflows.md`

## Example Screenshot Locations

```
screenshots/security/
├── README.md                        # This file
├── gitleaks-clean.png              # ← Add this
├── megalinter-results.png          # ← Add this
├── sonarcloud-dashboard.png        # ← Add this
├── snyk-fixed-vulnerabilities.png  # ← Add this
├── trivy-clean-scan.png            # ← Add this
└── tfsec-issues.png                # ← Add this
```

## Status

- [x] Directory structure created
- [ ] gitleaks-clean.png
- [ ] megalinter-results.png
- [ ] sonarcloud-dashboard.png
- [ ] snyk-fixed-vulnerabilities.png
- [ ] trivy-clean-scan.png
- [ ] tfsec-issues.png

## Questions?

If you need help with:
- Taking screenshots: Check the GitHub Actions logs
- Image formats: PNG works best for text/terminal output
- File sizes: Aim for under 500KB per screenshot
