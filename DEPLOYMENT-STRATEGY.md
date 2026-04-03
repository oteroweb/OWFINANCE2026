# OWFINANCE2026 Deployment & Branch Strategy

**Version:** 1.0
**Date:** 2026-04-03
**Status:** Active

---

## 📐 Repository Architecture

OWFINANCE2026 uses a **monorepo + git submodules** structure with 3 interconnected repositories:

```
OWFINANCE2026 (central orchestrator)
├── OWFinanceFrontend2025/ (submodule)
│   ├── src/components/
│   ├── src/layouts/
│   ├── src/pages/
│   ├── src/stores/
│   └── package.json (npm)
│
└── OWFINANCEBackend2025/ (submodule)
    ├── src/routes/
    ├── src/controllers/
    ├── src/models/
    ├── src/middleware/
    └── package.json (npm)
```

**Why submodules?**
- Independent versioning per repository
- Each repo can have its own release cycle
- Central OWFINANCE2026 tracks exact commits
- Clear separation of concerns (backend/frontend/ops)

---

## 🌍 Environment Strategy

### Four-Environment Pipeline

```
LOCAL (Development)
    ↓ (git push origin feature/xxx)
DEV (Integration)
    ↓ (PR merge to dev branch)
STAGING (Testing)
    ↓ (Release candidate, sign-off)
PROD (Live)
```

### Environment Details

| Environment | Branch | URL | Deployment | Trigger | Deploy Time |
|-------------|--------|-----|------------|---------|-------------|
| **LOCAL** | `feature/*` / `bugfix/*` | localhost:3000 | Manual (npm run dev) | Developer | Instant |
| **DEV** | `dev` | appfinanzasdev.blockshift.website | CI/CD | Merge to dev | ~5 min |
| **STAGING** | `staging` | appfinanzas-staging.blockshift.website | CI/CD | Merge to staging | ~5 min |
| **PROD** | `master` | appfinanzas.blockshift.website | Manual approval | Git tag + CI/CD | ~10 min |

---

## 🌳 Branch Structure & Workflow

### Main Branches (Protected)

```
master
├── Stable production code
├── Deployed to: PROD
├── Create PRs from: staging
├── Protection: Require 1+ approvals, tests pass
└── Tag: v*.*.* (semantic versioning)

dev
├── Integration branch (daily builds)
├── Deployed to: DEV
├── Create PRs from: feature/*, bugfix/*
├── Protection: Require tests pass, no manual approvals
└── Auto-deploy on merge

staging
├── Release candidate
├── Deployed to: STAGING
├── Create PRs from: dev
├── Protection: Require 1+ approvals
└── Auto-deploy on merge, requires sign-off
```

### Feature Branches

```
feature/ofb-001-header-lite
feature/ofb-002-bottom-nav
feature/ofb-029-fab-sheet
feature/pro-layout-integration

bugfix/fix-responsive-header
hotfix/critical-auth-bug
```

**Branch naming:**
- `feature/{ticket-code}-{description}` for new features
- `bugfix/{description}` for bug fixes
- `hotfix/{description}` for production urgent fixes

---

## 🔄 Workflow: From Code to Production

### Step 1: Local Development (Developer)

```bash
# Start from master
git checkout master
git pull origin master

# Create feature branch
git checkout -b feature/ofb-001-header-lite

# Work on changes
npm run dev
# ... edit components, test locally
git add -A
git commit -m "feat: implement header lite component"

# Keep branch up to date with dev
git fetch origin
git rebase origin/dev
```

### Step 2: Push & Create PR to DEV (Developer)

```bash
# Push feature branch
git push origin feature/ofb-001-header-lite

# Create PR in GitHub
# - Base: dev
# - Head: feature/ofb-001-header-lite
# - Title: "feat: implement header lite component (OFB-001)"
# - Description: Link to ticket, acceptance criteria, testing notes
```

**Automated on PR:**
- Tests run (ESLint, TypeScript, unit tests)
- Build verification
- Lighthouse performance report
- Code coverage report

### Step 3: PR Review & Merge to DEV

```bash
# Reviewer checks:
- Code quality (ESLint/Prettier)
- Test coverage
- Performance impact
- TypeScript strictness
- Accessibility compliance

# When approved:
git checkout dev
git pull origin dev
git merge --no-ff feature/ofb-001-header-lite
git push origin dev

# DEV environment auto-deploys (CI/CD)
```

**Auto-deployment to DEV:**
- Triggers on merge to dev
- Runs full test suite
- Builds frontend & backend
- Deploys to appfinanzasdev.blockshift.website
- Slack notification to #deployments

### Step 4: Integration Testing (QA/Team)

```
Deploy to DEV
↓
Team tests in DEV environment
- Visual regression testing
- Cross-device testing
- API integration testing
- Performance baseline
↓
If issues: Create bugfix PRs against dev
If OK: Ready for staging
```

### Step 5: Promote to STAGING (Tech Lead)

```bash
# Create PR from dev → staging
git checkout staging
git pull origin staging
git merge --no-ff dev
git push origin staging

# STAGING auto-deploys
# - Full test suite runs
# - Performance regression check
# - Security scan
# - Slack notification to leadership
```

### Step 6: Sign-Off & Deploy to PROD (Manager/Tech Lead)

```bash
# Create PR from staging → master
git checkout master
git pull origin master
git merge --no-ff staging
git push origin master

# Create release tag
git tag -a v1.2.3 -m "Release v1.2.3: OWFINANCE2026 Phase 1"
git push origin v1.2.3

# Manual trigger to deploy to PROD (via GitHub Actions UI or CLI)
# - Final security scan
# - Smoke tests in PROD
# - Slack notification to on-call
```

---

## 🔗 Submodule Synchronization

### How Submodules Work

Parent repo (OWFINANCE2026) tracks exact commits:

```
OWFINANCE2026/
├── .gitmodules
│   ├── [submodule "OWFinanceFrontend2025"]
│   │   path = OWFinanceFrontend2025
│   │   url = git@github.com:your-org/OWFinanceFrontend2025.git
│   │
│   └── [submodule "OWFINANCEBackend2025"]
│       path = OWFINANCEBackend2025
│       url = git@github.com:your-org/OWFINANCEBackend2025.git
│
└── .git/config (stores exact commit SHAs)
```

### Updating Submodules

**Local Development:**
```bash
# Clone with submodules
git clone --recurse-submodules <repo-url>

# Update all submodules to latest commits
git submodule update --init --recursive

# Work in submodule
cd OWFinanceFrontend2025
git checkout feature/ofb-001-header-lite
# ... make changes
git add -A
git commit -m "feat: header component"
git push origin feature/ofb-001-header-lite

# Return to parent
cd ..

# Parent repo will show submodule as "modified"
git status
# modified:   OWFinanceFrontend2025 (new commits)

# Commit the submodule reference update
git add OWFinanceFrontend2025
git commit -m "chore: update frontend submodule to latest"
git push origin feature/branch-name
```

**When merging feature → dev:**
1. Feature PR in parent repo (OWFINANCE2026) has submodule changes
2. PR is merged to dev
3. Parent repo now points to new frontend/backend commits
4. CI/CD uses those commits to build in DEV
5. When staging/prod are deployed, they use the parent repo's commit references

---

## 🚀 CI/CD Automation (GitHub Actions)

### Key Workflows

#### `test.yml` - On every PR and push

```yaml
trigger: [push, pull_request]
steps:
  - ESLint (lint all .js/.ts/.vue)
  - TypeScript compiler (strict mode)
  - Unit tests (Jest)
  - Build verification (webpack/vite)
  - Lighthouse performance audit
  - Code coverage report
```

#### `dev-deploy.yml` - On merge to dev

```yaml
trigger: [push to dev]
steps:
  - Checkout with submodules
  - Install dependencies (npm ci)
  - Run tests
  - Build frontend (npm run build)
  - Build backend (npm run build)
  - Deploy to DEV
  - Run smoke tests
  - Slack notification
```

#### `staging-deploy.yml` - On merge to staging

```yaml
trigger: [push to staging]
steps:
  - Same as dev-deploy
  - Deploy to STAGING
  - Security scan (OWASP, dependency audit)
  - Performance regression check
```

#### `prod-deploy.yml` - On version tag

```yaml
trigger: [tag v*.*.*]
steps:
  - Final security scan
  - Deploy to PROD (with canary if available)
  - Health checks
  - Notification to on-call
```

---

## 📊 Status Checking

### Check Status of All Repos

```bash
# From OWFINANCE2026 root

# What commits are we using?
git log --oneline -1 OWFinanceFrontend2025
git log --oneline -1 OWFINANCEBackend2025

# What branch is each submodule on?
cd OWFinanceFrontend2025
git branch -a
git log --oneline -3

# Any uncommitted changes?
git status

# Which commits are deployed where?
# Check GitHub Actions logs or Slack deployment notifications
```

### Check What's Deployed

```bash
# Clone deployment info from CI/CD service
# Example: Last 5 deployments
curl https://your-ci.example.com/api/deployments?limit=5 \
  -H "Authorization: Bearer $CI_TOKEN"

# Or check git tags (last 5 releases)
git describe --tags --always
git log --oneline -5 master
```

---

## 🔒 Rollback Strategy

### If Production Breaks

```bash
# Step 1: Identify the broken commit
git log --oneline master | head -5
# Output:
# abc1234 Release v1.2.3 (broken)
# def5678 Release v1.2.2 (last stable)

# Step 2: Revert the commit
git revert abc1234 -m 1  # -m 1 for merge commits
git push origin master

# Step 3: OR reset to previous tag (more aggressive)
git reset --hard def5678
git tag v1.2.4-rollback
git push origin master --force-with-lease

# Step 4: Trigger PROD deployment of rollback commit
# (via GitHub Actions UI)

# Step 5: Post-incident
# - Create GitHub issue for RCA
# - Link to failed PR
# - Add tests to prevent regression
```

---

## 📋 Checklist: From Feature to Production

- [ ] **Local**
  - [ ] Feature branch created from `dev`
  - [ ] Changes tested locally (npm run dev)
  - [ ] Tests pass (`npm run test`)
  - [ ] TypeScript strict, no errors
  - [ ] ESLint passes, Prettier formatted
  - [ ] Commit messages follow convention

- [ ] **PR to DEV**
  - [ ] PR description links to ticket (OFB-001, etc.)
  - [ ] Acceptance criteria documented
  - [ ] Testing notes included
  - [ ] Screenshots/videos if UI change
  - [ ] Lighthouse report shows no regression
  - [ ] Code review approved

- [ ] **Merge to DEV**
  - [ ] CI/CD pipeline passes
  - [ ] Auto-deployed to DEV
  - [ ] Team QA testing completes
  - [ ] No blockers found

- [ ] **Promote to STAGING**
  - [ ] PR from dev → staging approved
  - [ ] Auto-deployed to STAGING
  - [ ] Leadership sign-off received
  - [ ] No security/compliance issues

- [ ] **Release to PROD**
  - [ ] PR from staging → master approved
  - [ ] Git tag created (v*.*.*)
  - [ ] Auto-deployed to PROD
  - [ ] Smoke tests pass
  - [ ] Slack notification sent
  - [ ] Monitoring alerts configured

---

## 🎯 Quick Reference: Common Tasks

### I want to work on OFB-002

```bash
git checkout dev
git pull origin dev
git checkout -b feature/ofb-002-bottom-nav
# ... make changes ...
git push origin feature/ofb-002-bottom-nav
# Create PR in GitHub (base: dev)
```

### I need to add a hotfix to production

```bash
git checkout master
git pull origin master
git checkout -b hotfix/critical-bug-fix
# ... fix the bug ...
git push origin hotfix/critical-bug-fix
# Create PR in GitHub (base: master)
```

### I want to see what's in DEV right now

```bash
git log --oneline dev | head -10
# Or check the DEV environment URL
# appfinanzasdev.blockshift.website
```

### I want to merge backend changes to frontend

```bash
# In OWFinanceFrontend2025
git fetch origin
git merge origin/dev  # Merge latest backend API changes

# OR if backend is in OWFINANCEBackend2025 submodule
cd ../OWFINANCEBackend2025
git log --oneline -5
# Note the commit SHA
cd ../OWFinanceFrontend2025
# Update your API client to use new endpoints
```

---

## 📞 Support & Escalation

### Issues by Type

| Issue | Action | Escalate To |
|-------|--------|-------------|
| Tests failing on PR | Fix code, push to same branch | Tech Lead |
| Merge conflict | Resolve locally, push to branch | Tech Lead |
| DEV deployment failed | Check CI/CD logs, revert PR if needed | DevOps |
| Performance regression | Check Lighthouse report, optimize | Frontend Lead |
| Production is down | Trigger rollback immediately | On-Call Manager |
| Security issue found | Create urgent hotfix PR | Security Lead |

---

## 🔄 Continuous Improvement

Review this strategy every sprint:
- Are deployments taking too long?
- Are there blockers in the pipeline?
- Should we adjust branch protection rules?
- Do we need additional environments?
- Are notification/alerting working?

---

**Last Updated:** 2026-04-03
**Next Review:** 2026-04-17 (end of sprint)
