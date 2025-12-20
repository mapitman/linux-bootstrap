# QEMU Testing Setup for Ubuntu Bootstrap

For full system-level testing when Docker's limitations are too restrictive.

## Prerequisites

```bash
sudo apt-get install qemu-system-x86 qemu-utils cloud-image-utils
```

## Quick Start with Ubuntu Cloud Images

Ubuntu provides pre-built cloud images perfect for automated testing:

```bash
#!/bin/bash
# Download Ubuntu cloud image
wget https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img

# Create a larger disk (cloud images are small)
qemu-img create -f qcow2 -F qcow2 -b jammy-server-cloudimg-amd64.img ubuntu-test.qcow2 20G

# Create cloud-init config for auto-login
cat > user-data << EOF
#cloud-config
users:
  - name: testuser
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - ssh-rsa YOUR_SSH_KEY_HERE
    
packages:
  - curl
  - git

runcmd:
  - echo "Bootstrap test VM ready"
EOF

# Create metadata
cat > meta-data << EOF
instance-id: ubuntu-bootstrap-test
local-hostname: ubuntu-test
EOF

# Generate cloud-init ISO
cloud-localds seed.img user-data meta-data

# Start VM
qemu-system-x86_64 \
  -machine accel=kvm:tcg \
  -cpu host \
  -m 4096 \
  -nographic \
  -drive file=ubuntu-test.qcow2,format=qcow2 \
  -drive file=seed.img,format=raw \
  -net nic -net user,hostfwd=tcp::2222-:22

# Connect via SSH (from another terminal)
ssh -p 2222 testuser@localhost
```

## Automated Testing Script

Create `test/qemu/run-test.sh`:

```bash
#!/bin/bash
set -e

VM_NAME="ubuntu-bootstrap-test"
IMAGE="ubuntu-test.qcow2"

# Clean up previous test
rm -f "$IMAGE" seed.img

# Download fresh image
wget -O base.img https://cloud-images.ubuntu.com/jammy/current/jammy-server-cloudimg-amd64.img

# Create test disk
qemu-img create -f qcow2 -F qcow2 -b base.img "$IMAGE" 20G

# Generate cloud-init config
cat > user-data << 'EOF'
#cloud-config
users:
  - name: testuser
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    
packages:
  - curl
  - git
  - ca-certificates

runcmd:
  # Run the bootstrap script
  - sudo -u testuser bash -c 'cd /home/testuser && curl -fsSL https://raw.githubusercontent.com/mapitman/linux-bootstrap/main/ubuntu/install-essential-packages | bash'
  - echo "Bootstrap completed" > /tmp/bootstrap-done
  - poweroff
EOF

echo "instance-id: $VM_NAME" > meta-data
cloud-localds seed.img user-data meta-data

# Run VM (headless, auto-shutdown after bootstrap)
timeout 600 qemu-system-x86_64 \
  -machine accel=kvm:tcg \
  -cpu host \
  -m 2048 \
  -nographic \
  -drive file="$IMAGE",format=qcow2 \
  -drive file=seed.img,format=raw \
  -net nic -net user || true

echo "VM test completed"
```

## Pros and Cons

**Pros:**
- Full Ubuntu environment (systemd, kernel, all services)
- Tests exactly as it would run on bare metal
- Can test reboot behavior, kernel modules, etc.

**Cons:**
- Slow (several minutes per test)
- Requires more disk space (several GB per test)
- Not practical for CI/CD
- More complex setup

## When to Use QEMU Testing

Use QEMU testing when:
- Testing systemd service installation/configuration
- Testing kernel module loading
- Testing boot configuration changes
- Verifying the full end-to-end bootstrap experience
- Before releasing a major version

For regular development and CI/CD, stick with Docker testing.
