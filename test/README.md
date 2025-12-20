# Testing Strategy for Ubuntu Bootstrap Scripts

This directory contains automated testing infrastructure for the Ubuntu bootstrap scripts using Docker and QEMU.

## Quick Start

### Option 1: Docker (Recommended for Quick Testing)

Docker provides fast, lightweight testing ideal for package installation validation.

**Interactive Testing:**
```bash
# Build the test image
docker build -f test/docker/Dockerfile.ubuntu -t ubuntu-bootstrap-test .

# Run interactively to manually test scripts
docker run -it --rm ubuntu-bootstrap-test

# Inside the container, test individual scripts:
cd linux-bootstrap
bash ubuntu/install-essential-packages
```

**Automated Testing:**
```bash
# Build and run non-interactive tests
docker build -f test/docker/Dockerfile.ubuntu-noninteractive -t ubuntu-bootstrap-test-auto .
docker run --rm ubuntu-bootstrap-test-auto
```

**Test Different Ubuntu Versions:**
```bash
# Ubuntu 22.04 LTS
docker build --build-arg UBUNTU_VERSION=22.04 -f test/docker/Dockerfile.ubuntu -t ubuntu-bootstrap-test:22.04 .

# Ubuntu 24.04 LTS
docker build --build-arg UBUNTU_VERSION=24.04 -f test/docker/Dockerfile.ubuntu -t ubuntu-bootstrap-test:24.04 .
```

### Option 2: QEMU (For Full System Testing)

QEMU provides a complete VM environment for testing system-level changes that Docker can't replicate (systemd, kernel modules, etc.).

```bash
# See test/qemu/README.md for QEMU setup instructions
```

## Testing Approaches

### 1. Unit Testing (Individual Scripts)

Test each script independently:

```bash
docker run -it --rm ubuntu-bootstrap-test bash -c "
  cd linux-bootstrap && \
  bash ubuntu/install-essential-packages && \
  echo 'Essential packages installed successfully'
"
```

### 2. Integration Testing (Full Bootstrap)

Test the complete bootstrap flow (requires handling interactive prompts):

```bash
# Create a script with automated responses
cat > test-full-bootstrap.sh << 'EOF'
#!/bin/bash
# Simulate user responses: n for dev, n for desktop, n for media, n for optical
echo -e "n\nn\nn\nn" | bash ubuntu/bootstrap
EOF

docker run -it --rm -v $(pwd)/test-full-bootstrap.sh:/tmp/test.sh ubuntu-bootstrap-test bash /tmp/test.sh
```

### 3. GitHub Actions CI/CD

Add `.github/workflows/test-ubuntu.yml` to automatically test on every push:

```yaml
name: Test Ubuntu Bootstrap

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        ubuntu-version: ['20.04', '22.04', '24.04']
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Build test image
        run: |
          docker build \
            --build-arg UBUNTU_VERSION=${{ matrix.ubuntu-version }} \
            -f test/docker/Dockerfile.ubuntu-noninteractive \
            -t ubuntu-bootstrap-test .
      
      - name: Run tests
        run: docker run --rm ubuntu-bootstrap-test
```

## Docker vs QEMU: When to Use Each

| Feature | Docker | QEMU |
|---------|--------|------|
| **Speed** | Fast (seconds) | Slow (minutes) |
| **Isolation** | Process-level | Full VM |
| **Systemd** | Limited support | Full support |
| **Kernel Modules** | Host kernel only | Full kernel |
| **Use Case** | Package installation testing | Full system configuration |
| **CI/CD** | ✅ Ideal | ❌ Too slow |

**Recommendation:** 
- Use **Docker** for 95% of testing (package installs, script syntax, basic functionality)
- Use **QEMU** only when testing systemd services, kernel modules, or boot configuration

## Limitations and Workarounds

### Docker Limitations

1. **Interactive Prompts**: Scripts with `read -p` need automation or modification
   - **Workaround**: Use `echo` piping or create non-interactive variants
   
2. **Systemd**: Some systemd operations won't work in Docker
   - **Workaround**: Mock systemd commands or skip in tests
   
3. **Privileged Operations**: Some hardware/kernel operations unavailable
   - **Workaround**: Use `--privileged` flag or test in QEMU

### Testing Interactive Scripts

For scripts with prompts, create test wrappers:

```bash
# Automatically answer "yes" to all prompts
yes | bash ubuntu/bootstrap

# Provide specific answers
echo -e "y\nn\ny" | bash ubuntu/bootstrap
```

Or modify scripts to support environment variables:

```bash
# In the script:
if [[ -n "$CI" ]]; then
  # Non-interactive mode
  REPLY="n"
else
  read -p "Install development tools? " -n 1 -r
  echo
fi
```

## Recommended Testing Workflow

1. **Local Development**: 
   ```bash
   # Quick syntax check
   bash -n ubuntu/bootstrap
   shellcheck ubuntu/bootstrap
   
   # Test in Docker
   docker build -f test/docker/Dockerfile.ubuntu -t ubuntu-bootstrap-test .
   docker run -it --rm ubuntu-bootstrap-test
   ```

2. **Before Commit**:
   ```bash
   # Run automated tests
   docker build -f test/docker/Dockerfile.ubuntu-noninteractive -t test .
   docker run --rm test
   ```

3. **CI Pipeline**:
   - Automated Docker tests on every push
   - Test multiple Ubuntu versions (20.04, 22.04, 24.04)

4. **Major Changes**:
   - Full QEMU VM test with clean Ubuntu ISO
   - Manual verification on physical hardware

## Future Enhancements

- [ ] Add GitHub Actions CI workflow
- [ ] Create QEMU automated testing with cloud-init
- [ ] Add test coverage for all distros (Fedora, Arch, Pop!_OS)
- [ ] Create non-interactive mode for all bootstrap scripts
- [ ] Add smoke tests to verify installed packages work
- [ ] Create test fixtures for different user scenarios
