# GitHub Actions Workflows

This repository uses GitHub Actions for comprehensive automated testing of the Ansible playbook across all supported operating systems and configurations.

## Available Workflows

### 1. Ansible CI Tests (`ansible-test.yml`)
**Runs on:** Every push and PR

Basic validation tests:
- YAML and Ansible linting
- Syntax validation
- Role structure verification
- Jinja2 template validation
- OS compatibility checks

**Duration:** ~5 minutes

---

### 2. Quick Test (`quick-test.yml`)
**Runs on:** Every push and PR

Quick syntax validation of the main playbook.

**Duration:** ~2 minutes

---

### 3. Amazon Linux 2023 Matrix (`test-al2023-matrix.yml`)
**Runs on:** Push/PR to main branches, manual trigger

Tests **18 combinations**:
- **PHP:** 8.1, 8.2, 8.3
- **Web Servers:** nginx, apache
- **Databases:** MariaDB 10.4, 10.5, 10.6

**Duration:** ~15-20 minutes

---

### 4. Amazon Linux 2 Matrix (`test-al2-matrix.yml`)
**Runs on:** Push/PR to main branches, manual trigger

Tests **32 combinations**:
- **PHP:** 7.4, 8.0, 8.1, 8.2
- **Web Servers:** nginx, apache
- **Databases:** MariaDB 10.5, 10.6, MySQL 5.7, 8.0

**Duration:** ~20-25 minutes

---

### 5. CentOS 7 Matrix (`test-centos7-matrix.yml`)
**Runs on:** Push/PR to main branches, manual trigger

Tests **32 combinations**:
- **PHP:** 7.4, 8.0, 8.1, 8.2 (via Remi repository)
- **Web Servers:** nginx, apache
- **Databases:** MariaDB 10.5, 10.6, MySQL 5.7, 8.0

**Duration:** ~20-25 minutes

---

### 6. Amazon Linux 2 Legacy (`test-al2-legacy.yml`)
**Runs on:** Push/PR to main branches, manual trigger

Tests **30 legacy combinations**:
- **PHP:** 5.6, 7.2, 7.3
- **Web Servers:** nginx, apache
- **Databases:** MariaDB 5.5, 10.2, 10.3, 10.4, MySQL 5.6

**Duration:** ~20 minutes

---

### 7. CentOS 7 Legacy (`test-centos7-legacy.yml`)
**Runs on:** Push/PR to main branches, manual trigger

Tests **60 legacy combinations**:
- **PHP:** 5.6, 7.0, 7.1, 7.2, 7.3 (via Remi repository)
- **Web Servers:** nginx, apache
- **Databases:** MariaDB 5.5, 10.2, 10.3, 10.4, MySQL 5.5, 5.6

**Duration:** ~30 minutes

---

### 8. All OS Test Summary (`test-all-summary.yml`)
**Runs on:** Push/PR to main branches, manual trigger

Provides a dashboard summary showing:
- Total test coverage across all OS
- Configuration examples
- Workflow verification

**Total Coverage:** 172 configuration combinations (82 modern + 90 legacy)

---

## Test Coverage Summary

### Modern Versions

| Operating System | PHP Versions | Web Servers | Databases | Total Tests |
|-----------------|-------------|-------------|-----------|-------------|
| Amazon Linux 2023 | 3 (8.1-8.3) | 2 | 3 (MariaDB) | **18** |
| Amazon Linux 2 | 4 (7.4, 8.0-8.2) | 2 | 4 (MariaDB+MySQL) | **32** |
| CentOS 7 | 4 (7.4, 8.0-8.2) | 2 | 4 (MariaDB+MySQL) | **32** |
| **Subtotal** | | | | **82** |

### Legacy Versions

| Operating System | PHP Versions | Web Servers | Databases | Total Tests |
|-----------------|-------------|-------------|-----------|-------------|
| Amazon Linux 2 (Legacy) | 3 (5.6, 7.2, 7.3) | 2 | 5 (Legacy) | **30** |
| CentOS 7 (Legacy) | 5 (5.6, 7.0-7.3) | 2 | 6 (Legacy) | **60** |
| **Subtotal** | | | | **90** |

### **GRAND TOTAL: 172 Configuration Combinations**

---

## What Gets Tested

Each matrix workflow validates:
- ✅ Ansible syntax for the configuration
- ✅ Role structure and file existence
- ✅ Template file presence
- ✅ Configuration variable validity
- ✅ Compatibility between OS, PHP, web server, and database

**Note:** These are syntax and structure tests. Full deployment testing (actually installing packages) requires Docker or real servers.

---

## Viewing Results

### In GitHub Actions Tab

1. Go to the [Actions tab](https://github.com/MacareuxDigital/ansible-c5-ma/actions)
2. Click on a workflow run
3. View individual job results organized by configuration
4. Check logs for details

### Example Job Names

You'll see clear job names like:
- `AL2023 | PHP 8.3 | nginx | mariadb-10.6`
- `AL2 | PHP 8.1 | apache | mysql-8.0`
- `CentOS7 | PHP 7.4 | nginx | mariadb-10.5`

This makes it easy to identify which specific configuration failed (if any).

---

## Running Workflows Manually

1. Go to Actions tab
2. Select a workflow (e.g., "Amazon Linux 2023 Matrix")
3. Click "Run workflow" button
4. Choose your branch
5. Click "Run workflow" to start

---

## When Do Workflows Run?

| Workflow | Feature Branches | Main Branches | Manual |
|----------|-----------------|---------------|---------|
| Ansible CI Tests | ✅ Always | ✅ Always | ✅ Yes |
| Quick Test | ✅ Always | ✅ Always | ✅ Yes |
| AL2023 Matrix | ❌ No | ✅ Yes | ✅ Yes |
| AL2 Matrix | ❌ No | ✅ Yes | ✅ Yes |
| CentOS7 Matrix | ❌ No | ✅ Yes | ✅ Yes |
| AL2 Legacy | ❌ No | ✅ Yes | ✅ Yes |
| CentOS7 Legacy | ❌ No | ✅ Yes | ✅ Yes |
| Test Summary | ❌ No | ✅ Yes | ✅ Yes |

**Main branches:** master, main, develop

This strategy keeps CI fast for feature branches while ensuring comprehensive testing before merges.

---

## Status Badges

Current status: [![Ansible Tests](https://github.com/MacareuxDigital/ansible-c5-ma/actions/workflows/ansible-test.yml/badge.svg)](https://github.com/MacareuxDigital/ansible-c5-ma/actions/workflows/ansible-test.yml)

Add to your README:
```markdown
![Ansible Tests](https://github.com/YOUR_USERNAME/ansible-c5-ma/workflows/Ansible%20CI%20Tests/badge.svg)
```

---

## Interpreting Results

### ✅ All Green
Your configuration is valid for all tested combinations. Safe to deploy.

### ❌ Some Failures
1. Click on the failed job
2. Read the error message
3. Common issues:
   - Syntax errors in playbook
   - Missing role files
   - Invalid configuration combinations
   - Template syntax errors

### ⚠️ Workflow File Missing
If you see "workflow file missing" errors, ensure all workflow YAML files are committed to `.github/workflows/`.

---

## Troubleshooting

### "No such file or directory" errors
- Make sure you're running workflows from the correct branch
- Check that role directories exist

### "Syntax check failed"
- Run locally: `ansible-playbook -i inventory.ini setup.yml --syntax-check`
- Fix syntax errors in the playbook or roles

### Workflows not running
- Check branch name matches trigger conditions
- Verify workflow YAML files are in `.github/workflows/`
- Check GitHub Actions is enabled in repository settings

---

## Local Testing

Before pushing, test locally:

```bash
cd prod-ansible-role

# Create test inventory
echo "[test]" > inventory-test.ini
echo "localhost ansible_connection=local" >> inventory-test.ini

# Run syntax check
ansible-playbook -i inventory-test.ini setup.yml --syntax-check
```

---

## Additional Resources

- [Detailed Testing Documentation](../TESTING.md)
- [Supported Versions Matrix](../../SUPPORTED_VERSIONS.md)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Ansible Documentation](https://docs.ansible.com/)

---

**Questions?** Open an issue or check the workflow logs for detailed output!
