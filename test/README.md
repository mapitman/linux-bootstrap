# Testing Strategy for Bootstrap Scripts

This directory contains automated testing infrastructure for the Ubuntu and Debian bootstrap scripts using Docker and QEMU.

## Quick Start

### Option 1: Docker

Docker provides fast, lightweight testing for package installation validation.

### Ubuntu interactive testing

```bash
docker build -f test/docker/Dockerfile.ubuntu -t ubuntu-bootstrap-test .
docker run -it --rm ubuntu-bootstrap-test
```

Inside the container:

```bash
cd linux-bootstrap
bash ubuntu/install-essential-packages
```

### Ubuntu automated testing

```bash
docker build -f test/docker/Dockerfile.ubuntu-noninteractive -t ubuntu-bootstrap-test:auto .
docker run --rm ubuntu-bootstrap-test:auto
```

### Debian automated testing

```bash
docker build -f test/docker/Dockerfile.debian-noninteractive -t debian-bootstrap-test:auto .
docker run --rm debian-bootstrap-test:auto
```

### Versioned test images

```bash
# Ubuntu
docker build --build-arg UBUNTU_VERSION=24.04 -f test/docker/Dockerfile.ubuntu-noninteractive -t ubuntu-bootstrap-test:24.04 .
docker build --build-arg UBUNTU_VERSION=25.10 -f test/docker/Dockerfile.ubuntu-noninteractive -t ubuntu-bootstrap-test:25.10 .

# Debian
docker build --build-arg DEBIAN_VERSION=bookworm -f test/docker/Dockerfile.debian-noninteractive -t debian-bootstrap-test:bookworm .
docker build --build-arg DEBIAN_VERSION=trixie -f test/docker/Dockerfile.debian-noninteractive -t debian-bootstrap-test:trixie .
```

### Option 2: QEMU

QEMU provides a full VM environment for testing system-level changes that Docker cannot replicate.

```bash
# See test/qemu/README.md for setup instructions
```

## Local Commands

Use the wrapper script:

```bash
./test/run-tests.sh auto
./test/run-tests.sh all
./test/run-tests.sh debian
./test/run-tests.sh debian-all
./test/run-tests.sh syntax
```

Or use the Makefile:

```bash
make test
make test-all
make test-debian
make test-debian-all
make test-syntax
```

## CI Workflows

The repository includes dedicated distro test workflows:

- `.github/workflows/test-ubuntu.yml`
- `.github/workflows/test-debian.yml`

They build Docker images and run the non-interactive installer tests for supported Ubuntu and Debian versions.

## Limitations

Docker is suitable for package-installation validation and syntax checks, but not for full workstation bootstrap behavior that depends on interactive auth flows or full init/system services.

For example, Debian CI tests target `debian/install-packages` rather than `debian/bootstrap`, because the full bootstrap sources interactive helpers such as SSH key generation and GitHub auth.

## Recommended Workflow

1. Run `bash scripts/check.sh` for repo-wide syntax validation.
2. Run `make test-debian` for a quick Debian smoke test.
3. Run `make test-debian-all` before merging Debian-specific changes.
4. Use QEMU only if you need to validate behavior Docker cannot represent.

## Future Enhancements

- Add Fedora, Arch, and Pop!_OS Docker test coverage.
- Add smoke tests that verify key installed tools are actually runnable.
- Add non-interactive bootstrap modes for currently interactive distro flows.
