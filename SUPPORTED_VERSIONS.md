# Supported Versions

This document lists all supported combinations of operating systems, PHP versions, web servers, and databases for the Concrete CMS Ansible playbook.

## Operating Systems

| OS | Status | Notes |
|----|--------|-------|
| **Amazon Linux 2023** | ✅ Fully Supported | Latest, recommended for new deployments |
| **Amazon Linux 2** | ✅ Fully Supported | Stable, production-ready |
| **Amazon Linux 1** | ⚠️ Limited Support | Legacy, use AL2/AL2023 instead |
| **CentOS 7** | ✅ Supported | Via Remi repository |
| **CentOS 6** | ⚠️ Legacy Support | EOL, migrate to newer OS |

---

## PHP Versions

### Amazon Linux 2023

| PHP Version | Status | Package Manager | Notes |
|------------|--------|-----------------|-------|
| **8.5** | ✅ Supported | dnf (native) | Latest (if available) |
| **8.4** | ✅ Supported | dnf (native) | Latest stable |
| **8.3** | ✅ Recommended | dnf (native) | Current stable |
| **8.2** | ✅ Supported | dnf (native) | Stable |
| **8.1** | ✅ Supported | dnf (native) | LTS |

**Configuration:** Set `php_version_amznlinux2023: "php8.4"` in `setup.yml`

### Amazon Linux 2

| PHP Version | Status | Package Manager | Notes |
|------------|--------|-----------------|-------|
| **8.2** | ✅ Supported | yum (Remi) | Latest for AL2 |
| **8.1** | ✅ Supported | yum (Remi) | LTS |
| **8.0** | ✅ Supported | yum (Remi) | Active |
| **7.4** | ✅ Supported | yum (Amazon Extras) | Stable |
| **7.3** | ✅ Supported | yum (Amazon Extras) | Legacy |
| **7.2** | ✅ Supported | yum (Amazon Extras) | Legacy |
| **5.6** | ⚠️ Legacy | yum (Remi) | EOL, not recommended |

**Configuration:** Set `php_version_amznlinux2: "php8.1"` in `setup.yml`

**Note:** PHP 8.0+ requires Remi repository. PHP 5.6 requires Remi.

### CentOS 7

| PHP Version | Status | Package Manager | Notes |
|------------|--------|-----------------|-------|
| **8.2** | ✅ Supported | yum (Remi) | Latest |
| **8.1** | ✅ Supported | yum (Remi) | LTS |
| **8.0** | ✅ Supported | yum (Remi) | Active |
| **7.4** | ✅ Supported | yum (Remi) | Stable |
| **7.3** | ✅ Supported | yum (Remi) | Legacy |
| **7.2** | ✅ Supported | yum (Remi) | Legacy |
| **7.1** | ⚠️ Legacy | yum (Remi) | EOL |
| **7.0** | ⚠️ Legacy | yum (Remi) | EOL |
| **5.6** | ⚠️ Legacy | yum (Remi) | EOL |

**Configuration:**
- Set `centos_phprepo: "remi"`
- Set `php_version_remi: "php81"` in `setup.yml`

---

## Web Servers

| Web Server | Status | All OS | Notes |
|-----------|--------|--------|-------|
| **NGINX** | ✅ Recommended | Yes | Better performance, recommended |
| **Apache** | ✅ Supported | Yes | Traditional, fully supported |

**Configuration:** Set `webserver_handle: "nginx"` or `"apache"` in `setup.yml`

---

## Databases

### MariaDB

| Version | AL2023 | AL2 | CentOS7 | Notes |
|---------|--------|-----|---------|-------|
| **11.5** | ✅ | ✅ | ✅ | Latest LTS |
| **11.4** | ✅ | ✅ | ✅ | LTS |
| **10.11** | ✅ | ✅ | ✅ | Stable LTS |
| **10.6** | ✅ | ✅ | ✅ | LTS, recommended |
| **10.5** | ✅ Native | ✅ Native | ✅ | LTS |
| **10.4** | ✅ | ✅ | ✅ | Older LTS |
| **5.5** | ❌ | ✅ | ✅ | Legacy, not recommended |

**Configuration for AL2023:**
- **10.5:** Native AL2023 packages (fastest, recommended)
  ```yaml
  db_environment: "mariadb"
  mariadb_repo: "10.5"
  ```
- **10.6+:** Official MariaDB repository
  ```yaml
  db_environment: "mariadb"
  mariadb_repo: "11.4"
  ```

**Note:** MariaDB official repository does not support ARM64 (aarch64) architecture yet.

### MySQL

| Version | AL2023 | AL2 | CentOS7 | Notes |
|---------|--------|-----|---------|-------|
| **8.0** | ✅ | ✅ | ✅ | Latest, recommended |
| **5.7** | ✅ | ✅ | ✅ | Legacy support |
| **5.6** | ❌ | ⚠️ | ⚠️ | EOL, not recommended |

**Configuration:**
```yaml
db_environment: "mysql"
mysql_repo: "80"  # for MySQL 8.0
```

---

## Recommended Combinations

### For New Projects (2025)

**Production:**
```yaml
# Amazon Linux 2023 + PHP 8.4 + NGINX + MariaDB 11.4
aws_awslinux: "2023"
php_version_amznlinux2023: "php8.4"
webserver_handle: "nginx"
db_environment: "mariadb"
mariadb_repo: "11.4"
```

**Alternative (MySQL):**
```yaml
# Amazon Linux 2023 + PHP 8.3 + NGINX + MySQL 8.0
aws_awslinux: "2023"
php_version_amznlinux2023: "php8.4"
webserver_handle: "nginx"
db_environment: "mysql"
mysql_repo: "80"
```

### For Existing AL2 Projects

```yaml
# Amazon Linux 2 + PHP 8.1 + NGINX + MariaDB 10.5
aws_awslinux: "2"
php_version_amznlinux2: "php8.1"
webserver_handle: "nginx"
db_environment: "mariadb"
mariadb_repo: "10.5"
```

### For Legacy CentOS 7

```yaml
# CentOS 7 + PHP 7.4 + Apache + MariaDB 10.5
aws_awslinux: "no"
centos_version: "7"
centos_phprepo: "remi"
php_version_remi: "php74"
webserver_handle: "apache"
db_environment: "mariadb"
mariadb_repo: "10.5"
```

---

## Architecture Support

| Architecture | AL2023 | AL2 | CentOS7 | Notes |
|-------------|--------|-----|---------|-------|
| **x86_64 (amd64)** | ✅ | ✅ | ✅ | Full support |
| **aarch64 (ARM64)** | ✅ | ✅ | ⚠️ | MariaDB repo limited, Remi not available |

**Configuration:** Set `cpu_arch: "x86_64"` or `"aarch64"` in `setup.yml`

**ARM64 Limitations:**
- MariaDB official repository does not support ARM64 (as of 2025)
- Use native AL2023/AL2 MariaDB 10.5 packages instead
- Remi PHP repository does not support ARM64

---

## Concrete CMS Compatibility

| Concrete CMS | PHP Requirement | Recommended Stack |
|-------------|----------------|-------------------|
| **9.x (9.4.5)** | PHP 7.4 - 8.4 | AL2023 + PHP 8.4 + MariaDB 10.6 |
| **8.x** | PHP 7.2 - 8.1 | AL2 + PHP 8.1 + MariaDB 10.5 |

### Important PHP 8.5 Note

**⚠️ PHP 8.5 is NOT yet supported by Concrete CMS 9.x**

While this Ansible playbook supports PHP 8.5 for general web server setups, Concrete CMS 9.4.5 does **not yet support PHP 8.5**.

- ✅ **Supported PHP versions for Concrete CMS 9.x:** 7.4, 8.0, 8.1, 8.2, 8.3, 8.4
- ❌ **Not supported for Concrete CMS:** PHP 8.5

**Automatic Validation:**
The playbook includes an automatic compatibility check that will prevent installation if you try to use PHP 8.5 with Concrete CMS. The check validates PHP versions across all supported operating systems (AL2023, AL2, CentOS7).

**For PHP 8.5 testing:**
If you want to test PHP 8.5 for non-Concrete CMS applications, set:
```yaml
c5_upload: "no"
c5_migration: "no"
```

Reference: [Concrete CMS System Requirements](https://documentation.concretecms.org/developers/introduction/system-requirements)

---

## Testing Status

All combinations are validated using automated GitHub Actions workflows:

- ✅ **Basic CI Tests**: Syntax, linting, templates
- ✅ **Quick Tests**: Common configurations
- ✅ **Matrix Tests**: AL2023 with all PHP/web/DB combinations

View test results: [GitHub Actions](https://github.com/MacareuxDigital/ansible-c5-ma/actions)

---

## Migration Paths

### From Amazon Linux 1 to 2023

1. Launch new AL2023 instance
2. Use this Ansible with AL2023 configuration
3. Migrate data using concrete5_migration role
4. Test thoroughly before switching DNS

### From Amazon Linux 2 to 2023

1. Update `aws_awslinux: "2023"` in setup.yml
2. Update `php_version_amznlinux2023: "php8.4"`
3. Test on new instance first
4. Migrate using standard process

### From CentOS 7 to Amazon Linux 2023

1. Launch new AL2023 instance
2. Use AL2023 configuration
3. Export/import databases
4. Migrate files and test

---

## Version Support Policy

- ✅ **Fully Supported**: Actively tested, recommended for production
- ⚠️ **Legacy Support**: Works but not recommended for new projects
- ❌ **Not Supported**: Will not work or not tested

We recommend using the latest stable versions:
- **OS:** Amazon Linux 2023
- **PHP:** 8.3
- **Web Server:** NGINX
- **Database:** MariaDB 10.6 or MySQL 8.0

---

## Questions?

- Check [README.md](README.md) for setup instructions
- See [.github/TESTING.md](.github/TESTING.md) for testing details
- Open an issue on GitHub for support

**Last Updated:** December 2025
