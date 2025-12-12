# Automated Testing with GitHub Actions

This repository includes comprehensive automated testing for the Ansible playbook using GitHub Actions. The CI/CD pipeline ensures that all changes are validated before deployment.

## Overview

The testing pipeline includes multiple test stages:

1. **Lint Tests** - Code quality and best practices
2. **Syntax Tests** - Ansible syntax validation
3. **Matrix Tests** - Multiple configuration combinations
4. **Docker Integration Tests** - Full playbook execution in containers
5. **Idempotence Tests** - Ensure playbooks can run multiple times safely

## GitHub Actions Workflow

The workflow is defined in `.github/workflows/ansible-test.yml` and runs automatically on:

- Push to `main`, `master`, or `develop` branches
- Pull requests to these branches
- Manual trigger via workflow_dispatch

### Test Jobs

#### 1. Ansible Lint
Validates YAML syntax and Ansible best practices using:
- `yamllint` - YAML syntax and style checking
- `ansible-lint` - Ansible-specific linting

**Note:** Lint failures are non-blocking (warnings only) to allow flexibility during development.

#### 2. Syntax Check
Runs `ansible-playbook --syntax-check` to validate playbook syntax without execution.

#### 3. Amazon Linux 2023 Matrix Tests
Tests multiple configuration combinations:
- **PHP Versions:** php8.1, php8.2, php8.3
- **Web Servers:** nginx, apache
- **Databases:** mariadb, mysql

This creates 18 test combinations (3 × 2 × 2) to ensure compatibility across different stacks.

**What it tests:**
- Role structure validation
- Jinja2 template syntax
- Variable validation

#### 4. Docker Integration Test
Runs the complete Ansible playbook in a Docker container:
- Builds Amazon Linux 2023 container
- Sets up SSH access
- Runs playbook in check mode (dry-run)
- Validates no critical errors occur

**Container Details:**
- OS: Amazon Linux 2023
- SSH Port: 2222
- User: ec2-user
- Password: testpassword

#### 5. Idempotence Test
Ensures playbooks are idempotent (safe to run multiple times):
- Runs playbook twice
- Verifies second run makes no changes
- Uploads test logs as artifacts

**Important:** This test may show warnings if certain tasks are not fully idempotent, but won't fail the build.

## Running Tests Locally

### Prerequisites
```bash
# Install required tools
pip install ansible ansible-lint yamllint

# macOS: Install Docker Desktop
# https://www.docker.com/products/docker-desktop

# Install sshpass (for Ansible password authentication)
brew install hudochenkov/sshpass/sshpass
```

### Run Lint Tests
```bash
# YAML linting
yamllint -d "{extends: default, rules: {line-length: {max: 200}}}" setup.yml

# Ansible linting
ansible-lint setup.yml
```

### Run Syntax Check
```bash
ansible-playbook setup.yml --syntax-check
```

### Run Docker Integration Test
```bash
# Start container
docker-compose up -d --build

# Wait for SSH
sleep 10

# Test connection
ansible -i host.docker.local.yml all -m ping

# Run playbook (dry-run)
ansible-playbook -i host.docker.local.yml setup.yml --check

# Run playbook (actual execution)
ansible-playbook -i host.docker.local.yml setup.yml

# Cleanup
docker-compose down -v
```

### Run Idempotence Test
```bash
# Start container
docker-compose up -d --build
sleep 10

# First run
ansible-playbook -i host.docker.local.yml setup.yml | tee first_run.log

# Second run
ansible-playbook -i host.docker.local.yml setup.yml | tee second_run.log

# Check for changes
grep "changed=" second_run.log

# Cleanup
docker-compose down -v
```

## Test Configuration

### Matrix Testing Variables
The matrix tests use a minimal configuration to validate role structure and templates. You can modify the test variables in `.github/workflows/ansible-test.yml` under the `test-amazon-linux-2023` job.

### Docker Testing Variables
Docker integration tests use the variables defined in `setup.yml` with `isDocker: "yes"`. This setting skips certain configurations that don't work well in containers:
- Systemd service starts
- Firewall configuration
- System-level kernel modifications

## Viewing Test Results

### GitHub Actions UI
1. Go to your repository on GitHub
2. Click "Actions" tab
3. Select a workflow run
4. View individual job results

### Test Artifacts
The idempotence test uploads logs as artifacts:
- `first_run.log` - First playbook execution
- `second_run.log` - Second playbook execution

Download these from the GitHub Actions workflow run page.

## Troubleshooting

### Test Failures

#### Lint Failures
- Review the specific linting rule that failed
- Update code to follow best practices
- Or adjust `.ansible-lint` config if needed

#### Syntax Errors
- Check YAML indentation (use spaces, not tabs)
- Validate Jinja2 template syntax
- Ensure all variables are defined

#### Docker Integration Failures
- Check container logs: `docker-compose logs`
- Verify SSH connectivity: `ssh -p 2222 ec2-user@127.0.0.1`
- Review Ansible verbose output in GitHub Actions logs

#### Idempotence Failures
- Identify which tasks changed on second run
- Use handlers instead of always-run tasks
- Add conditionals to check if changes are needed
- Consider if the task is inherently non-idempotent (e.g., downloading latest version)

### Common Issues

#### SSH Connection Timeout
```bash
# Increase wait time in workflow
sleep 15  # instead of 10
```

#### Permission Denied
```bash
# Verify sudo access in container
docker exec -it al2023-ansible-test sudo -l
```

#### Service Start Failures
When testing in Docker, some services won't start properly. Use `isDocker: "yes"` to skip these.

## CI/CD Best Practices

### Before Committing
1. Run local tests first
2. Test in Docker environment
3. Review lint warnings
4. Ensure documentation is updated

### Pull Requests
- All tests must pass before merging
- Review test logs in GitHub Actions
- Address any warnings or failures

### Adding New Roles
When adding new roles:
1. Add role to validation list in `test-amazon-linux-2023` job
2. Test with different variable combinations
3. Verify idempotence
4. Update documentation

### Extending Tests
To add new test scenarios:
1. Edit `.github/workflows/ansible-test.yml`
2. Add new matrix combinations
3. Create additional test jobs if needed
4. Document changes in this file

## Performance Considerations

### Test Duration
- Lint: ~2 minutes
- Syntax: ~1 minute
- Matrix tests: ~3-5 minutes per combination
- Docker integration: ~10-15 minutes
- Idempotence: ~20-30 minutes

**Total estimated time:** 30-45 minutes for complete test suite

### Optimization Tips
- Use `fail-fast: false` in matrix to see all failures
- Cache Python dependencies to speed up setup
- Skip optional tests during development
- Run full suite only on main branches

## Manual Trigger

You can manually trigger the test workflow:

1. Go to "Actions" tab on GitHub
2. Select "Ansible Playbook Tests"
3. Click "Run workflow"
4. Select branch
5. Click "Run workflow" button

## Future Improvements

Potential enhancements to the test suite:

- [ ] Add Amazon Linux 2 container tests
- [ ] Add CentOS 7/8 container tests
- [ ] Test concrete5 installation and migration
- [ ] Add security scanning (e.g., trivy, ansible-vault)
- [ ] Performance testing with different instance sizes
- [ ] Test with external RDS database
- [ ] Add notification on test failures
- [ ] Create test coverage reports

## Resources

- [Ansible Documentation](https://docs.ansible.com/)
- [Ansible Lint Rules](https://ansible-lint.readthedocs.io/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Testing Ansible Roles](https://www.ansible.com/blog/testing-ansible-roles-with-docker)
