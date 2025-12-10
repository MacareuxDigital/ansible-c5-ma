# GitHub Actions Workflows

This directory contains comprehensive CI/CD workflows that test all combinations of PHP, MySQL/MariaDB, Apache/NGINX, and Linux versions for the Concrete CMS Ansible playbook.

## 📋 Workflow Overview

### 1. **ansible-test.yml** - Basic CI Tests
**Triggers:** All pushes and PRs
- ✅ YAML and Ansible linting
- ✅ Syntax validation
- ✅ Role structure validation
- ✅ Jinja2 template validation
- ✅ OS compatibility checks

**Duration:** ~5 minutes
**Status:** Always runs

---

### 2. **quick-test.yml** - Common Configuration Tests
**Triggers:** All pushes and PRs

Tests the 6 most popular configuration combinations:
1. Amazon Linux 2023 + PHP 8.3 + NGINX + MariaDB 10.6
2. Amazon Linux 2023 + PHP 8.2 + Apache + MariaDB 10.6
3. Amazon Linux 2 + PHP 8.1 + NGINX + MySQL 8.0
4. Amazon Linux 2 + PHP 7.4 + Apache + MariaDB 10.5
5. CentOS 7 + PHP 8.1 + NGINX + MariaDB 10.6
6. CentOS 7 + PHP 7.4 + Apache + MySQL 5.7

**Duration:** ~8 minutes
**Purpose:** Fast feedback for common use cases

---

### 3. **test-al2023-matrix.yml** - Amazon Linux 2023 Matrix
**Triggers:** Push/PR to main branches, manual

Tests **18 combinations**:
- **PHP:** 8.1, 8.2, 8.3
- **Web Server:** nginx, apache
- **Database:** MariaDB 10.4, 10.5, 10.6

**Duration:** ~15 minutes
**Use case:** Validating latest Amazon Linux support

---

### 4. **test-al2-matrix.yml** - Amazon Linux 2 Matrix
**Triggers:** Push/PR to main branches, manual

Tests **48 combinations**:
- **PHP:** 7.2, 7.3, 7.4, 8.0, 8.1, 8.2
- **Web Server:** nginx, apache
- **Database:** MariaDB 10.5, 10.6, MySQL 5.7, 8.0

**Duration:** ~30 minutes
**Use case:** Most common production environment

---

### 5. **test-centos7-matrix.yml** - CentOS 7 Matrix
**Triggers:** Push/PR to main branches, manual

Tests **90 combinations**:
- **PHP:** 5.6, 7.0, 7.1, 7.2, 7.3, 7.4, 8.0, 8.1, 8.2 (via Remi)
- **Web Server:** nginx, apache
- **Database:** MariaDB 10.4, 10.5, 10.6, MySQL 5.7, 8.0

**Duration:** ~45 minutes
**Use case:** Legacy system support

---

### 6. **test-all-summary.yml** - Consolidated Summary
**Triggers:** Push/PR to main branches, manual

Orchestrates all matrix tests and provides a unified summary:
- Runs all 3 OS-specific matrix workflows
- Generates consolidated test report
- Posts summary to PRs automatically
- **Total:** 156 configuration combinations tested

**Duration:** ~45-60 minutes (runs in parallel)
**Purpose:** Complete validation before merge

---

## 🚀 Usage

### Viewing Test Results

1. Go to your repository on GitHub
2. Click the **Actions** tab
3. Select a workflow from the left sidebar
4. View the results in an easy-to-read matrix format

Each workflow displays results grouped by configuration:
```
✅ AL2023 | PHP 8.3 | nginx | mariadb-10.6
✅ AL2023 | PHP 8.3 | apache | mariadb-10.6
✅ AL2023 | PHP 8.2 | nginx | mariadb-10.6
...
```

### Running Workflows Manually

1. Go to **Actions** tab
2. Select a workflow (e.g., "Amazon Linux 2023 - Full Stack Matrix")
3. Click **Run workflow** button
4. Select branch
5. Click **Run workflow**

### PR Workflow

When you create a pull request:
1. **ansible-test.yml** runs immediately (basic validation)
2. **quick-test.yml** runs immediately (6 common configs)
3. **test-all-summary.yml** runs for main branches
4. A summary comment is posted to your PR with results

---

## 🎯 Which Workflow Should I Use?

| Scenario | Workflow | When to Use |
|----------|----------|-------------|
| Quick validation during development | `quick-test.yml` | Every commit |
| Testing specific OS support | `test-al2023-matrix.yml`<br>`test-al2-matrix.yml`<br>`test-centos7-matrix.yml` | When modifying OS-specific roles |
| Pre-merge validation | `test-all-summary.yml` | Before merging to main |
| Basic syntax/structure check | `ansible-test.yml` | Always (automatic) |

---

## 📊 Test Matrix Details

### Total Coverage: 156 Combinations

| OS | PHP Versions | Web Servers | Databases | Total |
|----|-------------|-------------|-----------|-------|
| **Amazon Linux 2023** | 3 (8.1-8.3) | 2 | 3 (MariaDB) | **18** |
| **Amazon Linux 2** | 6 (7.2-8.2) | 2 | 4 (MariaDB+MySQL) | **48** |
| **CentOS 7** | 9 (5.6-8.2) | 2 | 5 (MariaDB+MySQL) | **90** |

### Supported Configurations

#### PHP Versions
- **5.6** (CentOS 7 only)
- **7.0, 7.1, 7.2, 7.3, 7.4** (AL2, CentOS 7)
- **8.0, 8.1, 8.2** (AL2, AL2023, CentOS 7)
- **8.3** (AL2023 only)

#### Web Servers
- **NGINX** - All versions
- **Apache** - All versions

#### Databases
- **MariaDB:** 10.4, 10.5, 10.6
- **MySQL:** 5.7, 8.0

#### Operating Systems
- **Amazon Linux 2023** (latest)
- **Amazon Linux 2** (stable)
- **CentOS 7** (legacy support)

---

## 🔧 Customization

### Adding New Test Combinations

Edit the `matrix` section in the relevant workflow:

```yaml
strategy:
  fail-fast: false
  matrix:
    php: ['8.1', '8.2', '8.3', '8.4']  # Add new version
    webserver: ['nginx', 'apache']
    database: ['mariadb-10.6', 'mariadb-11.0']  # Add new database
```

### Skipping Matrix Tests

To disable matrix tests temporarily (e.g., during development):

1. Comment out the workflow trigger:
```yaml
on:
  # push:
  #   branches: [ main, master ]
  workflow_dispatch:  # Keep manual trigger
```

2. Or add a condition:
```yaml
jobs:
  al2023-matrix:
    if: github.event_name == 'workflow_dispatch'  # Only manual runs
```

### Adding New OS Support

1. Create a new workflow file: `.github/workflows/test-<OS>-matrix.yml`
2. Copy structure from existing OS workflow
3. Update OS-specific variables
4. Add to `test-all-summary.yml`

---

## 🐛 Troubleshooting

### Test Failures

#### Syntax Check Failures
```
Error: Syntax check failed
```
**Fix:** Run locally: `ansible-playbook setup.yml --syntax-check`

#### Template Validation Failures
```
Error: Template syntax error in roles/nginx/templates/vhost.conf.j2
```
**Fix:** Validate Jinja2 syntax in the template file

#### Matrix Job Failures
```
Error: MariaDB 10.7 configuration failed
```
**Fix:** Check if the version is supported in `setup.yml`

### Common Issues

**Issue:** Workflow doesn't trigger on push
- **Solution:** Check branch names in workflow triggers

**Issue:** Matrix takes too long
- **Solution:** Use `quick-test.yml` for development, full matrix for PRs

**Issue:** Too many parallel jobs
- **Solution:** GitHub limits concurrent jobs (usually 20). Jobs will queue.

---

## 📈 Performance

### Workflow Duration

| Workflow | Duration | Parallel Jobs | Cost* |
|----------|----------|---------------|-------|
| ansible-test.yml | ~5 min | 4 | Low |
| quick-test.yml | ~8 min | 6 | Low |
| test-al2023-matrix.yml | ~15 min | 18 | Medium |
| test-al2-matrix.yml | ~30 min | 48 | High |
| test-centos7-matrix.yml | ~45 min | 90 | High |
| test-all-summary.yml | ~60 min | 156 | Highest |

*Cost: GitHub Actions minutes consumption

### Optimization Tips

1. **Use caching:** Python dependencies are cached
2. **Run quick tests first:** Fail fast on common issues
3. **Limit full matrix:** Only run on main branches
4. **Use manual triggers:** For testing specific OS combinations

---

## 🔒 Security

### Best Practices

- ✅ No secrets in workflow files
- ✅ Minimal permissions (read-only by default)
- ✅ Pull request approval required before merge
- ✅ Protected branches with status checks
- ✅ Syntax-only validation (no actual server deployment)

### Setting Up Branch Protection

1. Go to **Settings** → **Branches**
2. Add rule for `main` and `master`
3. Require status checks:
   - ✅ Basic CI Tests
   - ✅ Quick Test
   - ✅ (Optional) Full Matrix Tests

---

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Ansible Documentation](https://docs.ansible.com/)
- [Testing Ansible](https://www.ansible.com/blog/testing-ansible-roles-with-docker)
- [Matrix Strategy Guide](https://docs.github.com/en/actions/using-jobs/using-a-matrix-for-your-jobs)

---

## 🤝 Contributing

When adding new features or roles:

1. Update relevant workflow matrix
2. Test locally first
3. Run quick-test.yml manually
4. Verify all combinations pass
5. Update this README if needed

---

## 📝 Changelog

### 2025-12-10
- ✨ Added comprehensive matrix testing for all OS combinations
- ✨ Created separate workflows for each OS
- ✨ Added consolidated summary workflow
- ✨ Added quick test workflow for common configurations
- 📝 Created comprehensive documentation

---

## 💡 Tips

1. **Start with quick-test.yml** during development
2. **Use OS-specific workflows** when changing OS-related roles
3. **Run full matrix** before major releases
4. **Monitor the Actions tab** - results are easy to read!
5. **Check PR comments** for automatic test summaries

---

**Questions?** Open an issue or check the GitHub Actions logs for detailed output!
