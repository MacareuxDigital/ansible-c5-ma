#!/bin/bash
set -e

echo "=== Docker Ansible Testing Setup ==="

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "Error: Docker is not running. Please start Docker and try again."
    exit 1
fi

# Build and start container
echo "Building and starting Amazon Linux 2023 container..."
docker-compose up -d --build

# Wait for container to be ready
echo "Waiting for container to initialize..."
sleep 10

# Wait for SSH to be ready
echo "Waiting for SSH service..."
for i in {1..30}; do
    if ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p 2222 ec2-user@127.0.0.1 -o ConnectTimeout=2 "echo 'SSH Ready'" 2>/dev/null; then
        echo "SSH is ready!"
        break
    fi
    echo "Waiting... ($i/30)"
    sleep 2
done

# Install sshpass if needed (for Ansible password authentication)
if ! command -v sshpass &> /dev/null; then
    echo ""
    echo "WARNING: sshpass is not installed. You'll need it for password-based SSH."
    echo "Install it with: brew install hudochenkov/sshpass/sshpass"
    echo ""
fi

# Test connection
echo ""
echo "Testing Ansible connection..."
if ansible -i host.docker.local.yml all -m ping; then
    echo ""
    echo "✓ Docker container is ready for Ansible testing!"
    echo ""
    echo "Container details:"
    echo "  - Hostname: test.local"
    echo "  - SSH Port: 2222"
    echo "  - User: ec2-user"
    echo "  - Password: testpassword"
    echo ""
    echo "Run playbook with:"
    echo "  ansible-playbook -i host.docker.local.yml setup.yml"
    echo ""
    echo "SSH into container:"
    echo "  ssh -p 2222 ec2-user@127.0.0.1"
    echo ""
    echo "View logs:"
    echo "  docker-compose logs -f"
    echo ""
    echo "Stop container:"
    echo "  docker-compose down"
else
    echo ""
    echo "✗ Connection test failed. Check the logs:"
    echo "  docker-compose logs"
fi
