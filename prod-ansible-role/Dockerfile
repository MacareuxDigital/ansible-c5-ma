# Amazon Linux 2023 Docker image for Ansible testing
FROM amazonlinux:2023

# Install required packages
RUN dnf install -y \
    openssh-server \
    python3 \
    sudo \
    which \
    hostname \
    procps-ng \
    && dnf clean all

# Configure SSH
RUN ssh-keygen -A && \
    mkdir -p /var/run/sshd && \
    sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Create ec2-user (standard AWS user)
RUN useradd -m -s /bin/bash ec2-user && \
    echo "ec2-user:testpassword" | chpasswd && \
    echo "ec2-user ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set root password for testing
RUN echo "root:rootpassword" | chpasswd

# Create startup script
RUN echo '#!/bin/bash' > /start.sh && \
    echo '/usr/sbin/sshd -D' >> /start.sh && \
    chmod +x /start.sh

# Expose SSH port
EXPOSE 22

# Start SSH
CMD ["/start.sh"]
