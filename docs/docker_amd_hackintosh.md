# Docker Installation Guide for AMD Hackintosh without VT-d

## Prerequisites and System Requirements

### Hardware Requirements

- AMD Hackintosh system running macOS 10.15+ (Catalina or newer)
- At least 4GB RAM (8GB+ recommended)
- 10GB+ free disk space
- System WITHOUT VT-d support

### Software Requirements

- Homebrew package manager
- Xcode Command Line Tools
- Terminal access with administrator privileges

## Installation Methods

### Method 1: Docker via Lima (Recommended for AMD Hackintosh)

Lima provides a lightweight VM solution that works well on AMD systems without VT-d.

#### Step 1: Install Prerequisites

```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Lima and Docker CLI
brew install lima docker docker-compose

# Install QEMU (required for Lima)
brew install qemu

# Install socket_vmnet for Lima networking (REQUIRED)
brew install socket_vmnet

# Configure socket_vmnet with proper permissions
sudo brew services start socket_vmnet
```

#### Step 2: Create Lima VM Configuration

```bash
# Create Lima configuration directory
mkdir -p ~/.lima

# Create Docker VM configuration
cat > ~/.lima/docker.yaml << 'EOF'
vmType: "qemu"
images:
  - location: "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
    arch: "x86_64"

cpus: 2
memory: "4GiB"
disk: "100GiB"

# Hackintosh-friendly QEMU settings
qemu:
  machine:
    type: "q35"
  cpu:
    type: "qemu64"
  args:
    - "-accel"
    - "tcg"
    - "-no-hpet"
    - "-rtc"
    - "base=utc,driftfix=slew"

mounts:
  - location: "~"
    writable: true
  - location: "/tmp/lima"
    writable: true

networks:
  - lima: user-v2

provision:
  - mode: system
    script: |
      #!/bin/bash
      set -eux -o pipefail
      export DEBIAN_FRONTEND=noninteractive

      # Update system
      apt-get update
      apt-get upgrade -y

      # Install Docker
      curl -fsSL https://get.docker.com -o get-docker.sh
      sh get-docker.sh

      # Add user to docker group
      usermod -aG docker ${USER}

      # Install Docker Compose
      curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
      chmod +x /usr/local/bin/docker-compose

      # Enable and start Docker service
      systemctl enable docker
      systemctl start docker

probes:
  - mode: readiness
    description: docker to be ready
    script: |
      #!/bin/bash
      set -eux -o pipefail
      if ! timeout 30s bash -c "until command -v docker >/dev/null 2>&1; do sleep 3; done"; then
        echo >&2 "docker is not installed yet"
        exit 1
      fi
      if ! timeout 30s bash -c "until pgrep dockerd; do sleep 3; done"; then
        echo >&2 "dockerd is not running"
        exit 1
      fi
EOF
```

#### Step 3: Start Lima VM (Corrected Method)

```bash
# First, let's use the built-in Docker template and then customize it
limactl create --name=docker template://docker

# Stop the process if it started automatically
limactl stop docker 2>/dev/null || true

# Now apply our custom configuration
cp ~/.lima/docker.yaml ~/.lima/docker/lima.yaml

# Start the Docker VM with our configuration
limactl start docker

# Wait for VM to be ready (this may take 5-10 minutes)
limactl list
```

**Alternative Method (if above doesn't work):**

```bash
# Delete any existing docker instance
limactl delete docker --force 2>/dev/null || true

# Create with Docker template directly
limactl create --name=docker --template=docker --cpus=2 --memory=4

# Start the instance
limactl start docker
```

#### Step 4: Configure Docker Client

```bash
# Create Docker context for Lima
docker context create lima-docker --docker "host=unix:///Users/${USER}/.lima/docker/sock/docker.sock"

# Set Lima as default context
docker context use lima-docker

# Test Docker installation
docker --version
docker run hello-world
```

#### Step 5: Create Docker Aliases (Optional)

```bash
# Add to ~/.zshrc or ~/.bash_profile
echo 'alias docker="lima nerdctl"' >> ~/.zshrc
echo 'alias docker-compose="lima docker-compose"' >> ~/.zshrc

# Reload shell configuration
source ~/.zshrc
```

### Method 2: Alternative with Podman (Lighter Alternative)

If Lima proves problematic, Podman offers another containerization solution.

#### Step 1: Install Podman

```bash
# Install Podman via Homebrew
brew install podman

# Initialize Podman machine
podman machine init --cpus 2 --memory 4096 --disk-size 60

# Start Podman machine
podman machine start

# Set up Docker compatibility
echo 'alias docker="podman"' >> ~/.zshrc
source ~/.zshrc
```

#### Step 2: Install Podman Compose

```bash
# Install podman-compose for Docker Compose compatibility
pip3 install podman-compose

# Create alias for docker-compose
echo 'alias docker-compose="podman-compose"' >> ~/.zshrc
source ~/.zshrc
```

## Configuration and Optimization

### Performance Tuning for AMD Systems

#### Step 1: Optimize Lima VM Settings

```bash
# Edit Lima configuration for better performance
cat > ~/.lima/docker.yaml << 'EOF'
# ... (previous configuration) ...

# AMD-specific optimizations
cpus: 4  # Increase based on your CPU cores
memory: "6GiB"  # Increase if you have more RAM

# Enable KVM acceleration (if supported)
qemu:
  machine:
    type: "q35"
  cpu:
    type: "host"
  display:
    type: "none"
EOF
```

#### Step 2: Set Resource Limits

```bash
# Create resource limits script
cat > ~/docker-limits.sh << 'EOF'
#!/bin/bash

# Set Docker daemon limits
lima sudo tee /etc/docker/daemon.json << 'DOCKER_EOF'
{
  "storage-driver": "overlay2",
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  },
  "default-ulimits": {
    "memlock": {
      "hard": -1,
      "soft": -1
    },
    "nofile": {
      "hard": 65536,
      "soft": 65536
    }
  }
}
DOCKER_EOF

# Restart Docker service
lima sudo systemctl restart docker
EOF

chmod +x ~/docker-limits.sh
~/docker-limits.sh
```

## Testing and Verification

### Step 1: Basic Docker Tests

```bash
# Test Docker functionality
docker --version
docker info
docker run --rm hello-world

# Test resource usage
docker run --rm alpine:latest echo "Docker is working!"
```

### Step 2: Docker Compose Test

```bash
# Create test compose file
mkdir -p ~/docker-test
cd ~/docker-test

cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  nginx:
    image: nginx:alpine
    ports:
      - "8080:80"
    volumes:
      - ./html:/usr/share/nginx/html

  redis:
    image: redis:alpine
    ports:
      - "6379:6379"
EOF

# Create test HTML file
mkdir -p html
echo "<h1>Docker Compose Test</h1>" > html/index.html

# Test Docker Compose
docker-compose up -d
docker-compose ps
docker-compose logs

# Test in browser: http://localhost:8080
curl http://localhost:8080

# Clean up
docker-compose down
```

## Troubleshooting

### Common Issues and Solutions

#### Issue 1: Lima VM Won't Start

```bash
# Check Lima status
limactl list

# View Lima logs
limactl show-log docker

# Restart Lima
limactl stop docker
limactl start docker
```

#### Issue 2: Docker Commands Fail

```bash
# Check Docker context
docker context ls

# Reset Docker context
docker context use lima-docker

# Test connection
docker version
```

#### Issue 3: Performance Issues

```bash
# Increase VM resources
limactl stop docker
# Edit ~/.lima/docker.yaml to increase CPU/memory
limactl start docker
```

#### Issue 4: Port Binding Issues

```bash
# Check if ports are available
lsof -i :8080

# Use different ports in docker-compose.yml
# Change "8080:80" to "8081:80"
```

## Advanced Configuration

### Setting Up Development Environment

```bash
# Create development docker-compose template
mkdir -p ~/docker-dev-template
cd ~/docker-dev-template

cat > docker-compose.dev.yml << 'EOF'
version: '3.8'
services:
  app:
    build: .
    volumes:
      - .:/app
      - /app/node_modules
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
    command: npm run dev

  db:
    image: postgres:13
    environment:
      POSTGRES_DB: devdb
      POSTGRES_USER: dev
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"

volumes:
  postgres_data:
EOF
```

### Performance Monitoring Script

```bash
cat > ~/monitor-docker.sh << 'EOF'
#!/bin/bash

echo "=== Docker System Info ==="
docker system df

echo -e "\n=== Running Containers ==="
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo -e "\n=== Resource Usage ==="
docker stats --no-stream

echo -e "\n=== Lima VM Status ==="
limactl list
EOF

chmod +x ~/monitor-docker.sh
```

## Maintenance and Updates

### Regular Maintenance Tasks

```bash
# Clean up Docker resources
docker system prune -a

# Update Lima
brew upgrade lima

# Update Docker images
docker images --format "table {{.Repository}}\t{{.Tag}}" | grep -v REPOSITORY | while read repo tag; do
  docker pull "$repo:$tag"
done

# Restart Lima VM monthly
limactl stop docker
limactl start docker
```

## Notes for AMD Hackintosh Users

1. **VT-d Limitation**: This setup works around the lack of VT-d by using Lima's QEMU-based virtualization
2. **Performance**: Expect 10-15% performance overhead compared to native Docker
3. **Memory Usage**: Lima VM will use dedicated RAM (4-6GB recommended)
4. **Compatibility**: Most Docker containers will work, but some may have AMD-specific issues
5. **Updates**: Keep Lima and Docker components updated for best compatibility

## Security Considerations

- Lima VM runs with user-level permissions
- Docker daemon runs inside VM, isolated from host
- Consider using Docker secrets for sensitive data
- Regularly update base images and Lima components

This setup provides a fully functional Docker environment on your AMD Hackintosh system without requiring VT-d support.
