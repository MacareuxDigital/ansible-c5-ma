# Docker Testing for Ansible Playbook

This directory contains Docker setup for locally testing the Ansible playbook against Amazon Linux 2023.

## Prerequisites

1. **Docker Desktop** - Install from https://www.docker.com/products/docker-desktop
2. **Ansible** - Install with `pip install ansible`
3. **sshpass** (optional but recommended) - Install with `brew install hudochenkov/sshpass/sshpass`

## Quick Start

1. **Start the test environment:**
   ```bash
   ./docker-test.sh
   ```

2. **Run the Ansible playbook:**
   ```bash
   ansible-playbook -i host.docker.local.yml setup.yml
   ```

## Manual Setup

### 1. Build and Start Container

```bash
docker-compose up -d --build
```

### 2. Verify Container is Running

```bash
docker-compose ps
```

### 3. Test SSH Connection

```bash
ssh -p 2222 ec2-user@127.0.0.1
# Password: testpassword
```

### 4. Test Ansible Connection

```bash
ansible -i host.docker.local.yml all -m ping
```

### 5. Run Playbook

```bash
ansible-playbook -i host.docker.local.yml setup.yml
```

## Important Notes

### Setup.yml Configuration for Docker

When testing with Docker, update `setup.yml` with these settings:

```yaml
isDocker: "yes"
vhost_domain: "test.local"
server_name: "test.local"
```

The `isDocker: "yes"` setting will:
- Skip systemd service starts
- Skip firewall configuration
- Skip certain system-level configurations

### Limitations

Docker testing has some limitations compared to a real VM/EC2 instance:

1. **Systemd services** - Some services may not start properly in containers
2. **Networking** - Port binding works differently
3. **Kernel modules** - Container shares host kernel
4. **Performance** - May differ from actual hardware

### Accessing the Test Site

Since nginx will run inside the container, you can:

1. **Access via localhost:**
   ```bash
   # Add to /etc/hosts
   echo "127.0.0.1 test.local" | sudo tee -a /etc/hosts
   
   # Access site (if nginx is configured to listen on host port)
   curl http://test.local:8080
   ```

2. **Exec into container:**
   ```bash
   docker exec -it al2023-ansible-test bash
   curl http://localhost
   ```

## Useful Commands

### View Container Logs
```bash
docker-compose logs -f
```

### SSH into Container
```bash
ssh -p 2222 ec2-user@127.0.0.1
```

### Execute Command in Container
```bash
docker exec -it al2023-ansible-test bash
```

### Check Services Status
```bash
docker exec -it al2023-ansible-test systemctl status nginx
docker exec -it al2023-ansible-test systemctl status php-fpm
docker exec -it al2023-ansible-test systemctl status mariadb
```

### Stop and Remove Container
```bash
docker-compose down
```

### Rebuild Container
```bash
docker-compose down
docker-compose up -d --build
```

### Clean Up Everything
```bash
docker-compose down -v
docker system prune -a
```

## Troubleshooting

### SSH Connection Refused
Wait a few more seconds for SSH to start:
```bash
docker-compose logs al2023-test
```

### Ansible Connection Fails
Check if sshpass is installed:
```bash
brew install hudochenkov/sshpass/sshpass
```

### Services Won't Start
Check if container has systemd running:
```bash
docker exec -it al2023-ansible-test systemctl status
```

### Port Already in Use
Change the port in `docker-compose.yml`:
```yaml
ports:
  - "2223:22"  # Change from 2222 to 2223
```

## Differences from Production

Key differences when testing with Docker vs EC2:

1. **No real systemd** - Services may behave differently
2. **Network isolation** - Container networking is different
3. **File permissions** - May differ from EC2
4. **Resource limits** - Container has different resource constraints
5. **Security context** - Privileged mode needed for systemd

## Best Practices

1. **Test incrementally** - Run playbook in parts using tags
2. **Check logs** - Always review docker-compose logs
3. **Use snapshots** - Commit container state before major changes
4. **Clean regularly** - Remove containers and rebuild frequently
5. **Verify manually** - SSH in and check configurations

## CI/CD Integration

You can use this Docker setup in CI/CD pipelines:

```yaml
# Example GitHub Actions
- name: Test Ansible Playbook
  run: |
    docker-compose up -d --build
    sleep 10
    ansible-playbook -i host.docker.local.yml setup.yml
```
