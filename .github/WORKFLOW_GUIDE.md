# GitHub Actions Workflow Guide

## 🎯 Quick Reference

### What You'll See in GitHub Actions Tab

When you open the **Actions** tab, you'll see these workflows organized clearly:

```
📋 Ansible CI Tests              [Always runs - 5 min]
📋 Quick Test                     [Always runs - 8 min]
📦 Amazon Linux 2023 Matrix       [Main branches - 15 min]
📦 Amazon Linux 2 Matrix          [Main branches - 30 min]
📦 CentOS 7 Matrix                [Main branches - 45 min]
📊 All OS Matrix - Summary        [Main branches - 60 min]
```

---

## 📊 Visual Workflow Structure

```
┌─────────────────────────────────────────────────────────────┐
│                    Pull Request Created                      │
└────────────────────────┬────────────────────────────────────┘
                         │
            ┌────────────┴────────────┐
            │                         │
    ┌───────▼──────┐         ┌───────▼──────┐
    │ Basic CI     │         │ Quick Test   │
    │ Tests        │         │ (6 configs)  │
    │              │         │              │
    │ • Lint       │         │ • AL2023     │
    │ • Syntax     │         │ • AL2        │
    │ • Templates  │         │ • CentOS7    │
    │ • Structure  │         │              │
    └───────┬──────┘         └───────┬──────┘
            │                        │
            │ ✅ Pass                 │ ✅ Pass
            │                        │
            └────────────┬───────────┘
                         │
         ┌───────────────▼───────────────┐
         │   Ready for Full Matrix?      │
         │   (main/master branches)      │
         └───────────────┬───────────────┘
                         │
          ┌──────────────┼──────────────┐
          │              │              │
   ┌──────▼─────┐ ┌─────▼──────┐ ┌────▼─────┐
   │ AL2023     │ │ AL2        │ │ CentOS7  │
   │ Matrix     │ │ Matrix     │ │ Matrix   │
   │            │ │            │ │          │
   │ 18 combos  │ │ 48 combos  │ │ 90 combos│
   └──────┬─────┘ └─────┬──────┘ └────┬─────┘
          │             │              │
          └──────────┬──┴──────────────┘
                     │
              ┌──────▼──────┐
              │  Summary    │
              │  Report     │
              │             │
              │ 156 total   │
              │ tests       │
              └──────┬──────┘
                     │
              ┌──────▼──────┐
              │ Post to PR  │
              │ ✅ Results   │
              └─────────────┘
```

---

## 🎨 How It Looks in GitHub Actions

### Main Actions Tab View

```
┌──────────────────────────────────────────────────────────────┐
│  All workflows                                      [Filters] │
├──────────────────────────────────────────────────────────────┤
│                                                                │
│  ✅ Ansible CI Tests                              3m 24s      │
│     main  #123  •  Basic validation passed                    │
│                                                                │
│  ✅ Quick Test                                    7m 45s      │
│     main  #123  •  6/6 configurations passed                  │
│                                                                │
│  🔄 Amazon Linux 2023 Matrix                     Running      │
│     main  #123  •  15/18 jobs complete                        │
│                                                                │
│  📅 Amazon Linux 2 Matrix                        Queued       │
│     main  #123  •  Waiting for available runner               │
│                                                                │
│  📅 CentOS 7 Matrix                              Queued       │
│     main  #123  •  Waiting for available runner               │
│                                                                │
└──────────────────────────────────────────────────────────────┘
```

### Matrix Workflow Detailed View

When you click on a matrix workflow (e.g., "Amazon Linux 2023 Matrix"):

```
┌──────────────────────────────────────────────────────────────┐
│  Amazon Linux 2023 - Full Stack Matrix              #123     │
├──────────────────────────────────────────────────────────────┤
│                                                                │
│  Jobs (18)                                                     │
│  ├─ ✅ AL2023 | PHP 8.1 | nginx | mariadb-10.6      45s      │
│  ├─ ✅ AL2023 | PHP 8.1 | nginx | mariadb-10.5      43s      │
│  ├─ ✅ AL2023 | PHP 8.1 | nginx | mariadb-10.4      44s      │
│  ├─ ✅ AL2023 | PHP 8.1 | apache | mariadb-10.6     46s      │
│  ├─ ✅ AL2023 | PHP 8.1 | apache | mariadb-10.5     45s      │
│  ├─ ✅ AL2023 | PHP 8.1 | apache | mariadb-10.4     47s      │
│  ├─ ✅ AL2023 | PHP 8.2 | nginx | mariadb-10.6      44s      │
│  ├─ ✅ AL2023 | PHP 8.2 | nginx | mariadb-10.5      45s      │
│  ├─ ✅ AL2023 | PHP 8.2 | nginx | mariadb-10.4      46s      │
│  ├─ ✅ AL2023 | PHP 8.2 | apache | mariadb-10.6     48s      │
│  ├─ ✅ AL2023 | PHP 8.2 | apache | mariadb-10.5     46s      │
│  ├─ ✅ AL2023 | PHP 8.2 | apache | mariadb-10.4     45s      │
│  ├─ ✅ AL2023 | PHP 8.3 | nginx | mariadb-10.6      47s      │
│  ├─ ✅ AL2023 | PHP 8.3 | nginx | mariadb-10.5      44s      │
│  ├─ ✅ AL2023 | PHP 8.3 | nginx | mariadb-10.4      46s      │
│  ├─ ✅ AL2023 | PHP 8.3 | apache | mariadb-10.6     45s      │
│  ├─ ✅ AL2023 | PHP 8.3 | apache | mariadb-10.5     48s      │
│  ├─ ✅ AL2023 | PHP 8.3 | apache | mariadb-10.4     47s      │
│  │                                                             │
│  └─ ✅ AL2023 Matrix Summary                        10s      │
│                                                                │
│  Total duration: 15m 32s                                      │
└──────────────────────────────────────────────────────────────┘
```

### PR Comment (Auto-posted)

```markdown
## 🧪 Ansible Matrix Test Results

All configuration combinations have been tested:

| Operating System | Status | Combinations |
|-----------------|--------|--------------|
| Amazon Linux 2023 | ✅ | 18 |
| Amazon Linux 2 | ✅ | 48 |
| CentOS 7 | ✅ | 90 |

**Total combinations tested:** 156

### Test Coverage
- ✅ PHP versions: 5.6, 7.0-7.4, 8.0-8.3
- ✅ Web servers: Apache, NGINX
- ✅ Databases: MariaDB 10.4-10.6, MySQL 5.7-8.0
- ✅ Operating systems: AL2, AL2023, CentOS 7

[View detailed results →](link)
```

---

## 🚦 Workflow Decision Tree

### "Which workflow will run for my commit?"

```
Your Commit
    │
    ├─ On feature/* branch?
    │   └─ Yes → ansible-test.yml + quick-test.yml
    │
    ├─ On develop branch?
    │   └─ Yes → ansible-test.yml + quick-test.yml + all matrix workflows
    │
    ├─ On main/master branch?
    │   └─ Yes → ALL workflows (full suite)
    │
    └─ Pull Request?
        └─ Yes → ansible-test.yml + quick-test.yml
                  (matrix workflows if target is main/master)
```

### "What gets tested?"

```
Basic CI Test (ansible-test.yml)
    ├─ ✅ YAML syntax
    ├─ ✅ Ansible syntax
    ├─ ✅ Role structure
    └─ ✅ Template syntax

Quick Test (quick-test.yml)
    ├─ ✅ 2 AL2023 configs (most common)
    ├─ ✅ 2 AL2 configs (production standard)
    └─ ✅ 2 CentOS7 configs (legacy support)

Full Matrix (per OS)
    └─ ✅ Every combination of:
        ├─ All supported PHP versions
        ├─ Both web servers (nginx + apache)
        └─ All database versions
```

---

## 📱 Monitoring Your Tests

### 1. Real-time Monitoring

**GitHub Actions Tab:**
- See all workflows running
- Click any workflow for details
- View logs in real-time
- Download artifacts

**Example URL:**
```
https://github.com/YOUR_USERNAME/ansible-c5-ma/actions
```

### 2. Status Badges (Optional)

Add to your main README.md:

```markdown
![Basic CI](https://github.com/YOUR_USERNAME/ansible-c5-ma/workflows/Ansible%20CI%20Tests/badge.svg)
![Quick Test](https://github.com/YOUR_USERNAME/ansible-c5-ma/workflows/Quick%20Test/badge.svg)
```

Result:
```
[✓ Basic CI]  [✓ Quick Test]  [✓ AL2023 Matrix]
```

### 3. Email Notifications

GitHub automatically sends emails when:
- ❌ Your workflow fails
- ✅ Previously failing workflow succeeds
- 📝 Someone comments on your PR

Configure in: **Settings → Notifications → Actions**

---

## 🎓 Common Scenarios

### Scenario 1: Daily Development

**You push to feature branch**

```
1. Push commit to feature/new-role
2. Wait ~13 minutes (5 + 8)
   ├─ ansible-test.yml runs (5 min)
   └─ quick-test.yml runs (8 min)
3. Both pass ✅
4. Continue development
```

**What you see:**
- 2 green checkmarks in GitHub
- Email if any fail
- PR is ready for review

---

### Scenario 2: Testing Specific OS

**You modified MariaDB configuration**

```
1. Go to Actions tab
2. Click "Amazon Linux 2023 Matrix"
3. Click "Run workflow"
4. Select your branch
5. Click "Run workflow"
6. Wait ~15 minutes
7. See 18 test results
```

**What you see:**
- 18 individual job results
- Easy to spot which combo failed
- Detailed logs for debugging

---

### Scenario 3: Pre-merge Check

**You created PR to main**

```
1. Create PR: feature/new-role → main
2. Automatic triggers:
   ├─ ansible-test.yml (5 min)
   ├─ quick-test.yml (8 min)
   └─ test-all-summary.yml (60 min)
3. Wait for all to complete
4. Review auto-posted comment
5. Merge if all pass ✅
```

**What you see:**
- Multiple workflows running
- Progress bars for each
- Final summary comment on PR
- Green "All checks passed" badge

---

## 🔍 Reading Test Results

### Success ✅

```
================================================
✅ Amazon Linux 2023 Test Passed
================================================
Configuration:
  - OS: Amazon Linux 2023
  - PHP: 8.3
  - Web Server: nginx
  - Database: mariadb-10.6
================================================
```

### Failure ❌

```
TASK [mariadb_server : Install MariaDB] **********
fatal: [localhost]: FAILED! => {
    "msg": "MariaDB 11.0 is not supported"
}
```

**What to do:**
1. Click on the failed job
2. Read the error message
3. Find the line number in logs
4. Fix the issue
5. Push new commit (tests run again)

---

## 💡 Pro Tips

### 1. **Use Labels for PRs**

Add labels to skip unnecessary tests:
- `skip-ci` - Skip all tests (emergency only)
- `quick-only` - Run only quick tests
- `full-matrix` - Force full matrix on feature branch

### 2. **Manual Workflow Runs**

Test before pushing:
1. Push to your branch
2. Run workflow manually on your branch
3. Fix issues
4. Then create PR

### 3. **Parallel Development**

Multiple developers can:
- Push to different branches
- All workflows run in parallel
- GitHub queues jobs automatically
- No conflicts

### 4. **Check Logs Efficiently**

Use the search in logs:
- Click on failed job
- Press `Ctrl+F` (or `Cmd+F`)
- Search for "FAILED" or "ERROR"
- Jump to relevant sections

---

## 📋 Checklist for Contributors

Before pushing:
- [ ] Ran `ansible-playbook setup.yml --syntax-check` locally
- [ ] Tested changes in Docker (if applicable)
- [ ] Updated relevant documentation
- [ ] Checked no secrets in commits

After pushing:
- [ ] Verify ansible-test.yml passes (5 min)
- [ ] Verify quick-test.yml passes (8 min)
- [ ] Review any warnings in logs
- [ ] Respond to PR comments

Before merging:
- [ ] All matrix tests pass
- [ ] PR has been reviewed
- [ ] Documentation is updated
- [ ] CHANGELOG is updated (if applicable)

---

## 🆘 Troubleshooting

### "Workflow not triggered"

**Check:**
- Branch name matches trigger pattern
- Workflow file has correct syntax
- GitHub Actions is enabled in repo settings

### "All jobs failing"

**Common causes:**
- Syntax error in setup.yml
- Missing required role
- Template syntax error

**Fix:**
- Check the first failure
- Often same issue across all jobs
- Fix once, retrigger all

### "One specific combo fails"

**Example:** "AL2 + PHP 7.2 + MySQL 8.0 fails"

**Debug:**
1. Look at successful similar combo (e.g., PHP 7.3)
2. Compare differences
3. Check version compatibility
4. Update matrix if unsupported

### "Too slow"

**Optimize:**
- Use `quick-test.yml` for development
- Full matrix only for main branches
- Consider reducing matrix size
- Remove unsupported combinations

---

## 📞 Getting Help

1. **Check workflow logs** - Most issues are clear in logs
2. **Search GitHub Issues** - Others may have same problem
3. **Review this guide** - Covers most scenarios
4. **Open an issue** - Include workflow run link

**Include in issue:**
- Workflow name
- Job name that failed
- Error message
- Branch name
- Link to workflow run

---

## 🎉 Success Indicators

You know everything is working when:

✅ PR has green checkmarks
✅ Summary comment posted automatically
✅ All 156 combinations pass
✅ No warnings in logs
✅ Merge button is green
✅ Team is confident in deployment

---

**Happy Testing! 🚀**

The workflows are designed to be clear and easy to monitor. Check the Actions tab regularly and you'll always know the status of your configurations!
