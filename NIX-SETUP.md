# Nix Development Environment Setup

## Overview

Artagon Parent provides a reproducible development environment using [Nix](https://nixos.org/), a declarative package manager that ensures all developers have identical development dependencies regardless of their host operating system.

**Benefits:**
- ✅ **Reproducible**: Same versions of Java, Maven, and tools across all environments
- ✅ **Isolated**: No conflicts with system-installed packages
- ✅ **Cross-platform**: Works on Linux, macOS, and NixOS
- ✅ **Declarative**: Environment defined in version-controlled files
- ✅ **No Docker needed**: Native performance without containerization

## Quick Start

### Prerequisites

Install Nix (works on Linux and macOS):

```bash
# Official installer
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Or use the official Nix installer
sh <(curl -L https://nixos.org/nix/install) --daemon
```

### Using the Development Shell

**Enter the default development environment (JDK 17):**
```bash
nix develop
```

**Use JDK 21 for testing:**
```bash
nix develop .#jdk21
```

**Run commands without entering the shell:**
```bash
# Run Maven build
nix develop -c mvn verify

# Run security verification
nix develop -c mvn -P artagon-oss-security verify

# Update security baselines
nix develop -c ./scripts/update-dependency-security.sh -u
```

## Available Environments

The `nix/flake.nix` defines multiple development shells:

### Default Shell (JDK 17)
```bash
nix develop
# or explicitly:
nix develop .#default
```

**Includes:**
- Java 17 (JDK)
- Maven
- GPG (for PGP signature verification)
- OpenSSL (for SHA checksums)
- Git, curl, jq, yq-go
- Pandoc (documentation)

### JDK 21 Shell
```bash
nix develop .#jdk21
```

Test compatibility with newer Java versions.

### CI Shell
```bash
nix develop .#ci
```

Minimal environment for continuous integration with only essential tools.

## What's Included

### Java & Build Tools
- **JDK 17** (default) or JDK 21
- **Maven 3.x** - Build automation
- **Maven wrapper** helper script

### Security Tools
- **GPG** - PGP signature verification for dependencies
- **OpenSSL** - SHA-256/SHA-512 checksum generation

### Utilities
- **Git** + Git LFS
- **curl** - Download artifacts
- **jq** - JSON processing
- **yq-go** - YAML processing
- **Pandoc** - Documentation conversion

## Common Workflows

### Daily Development

```bash
# Enter development shell
nix develop

# Build project
mvn verify

# Run with security checks
mvn -P artagon-oss-security verify

# Run tests
mvn test

# Clean build
mvn clean install
```

### Security Baseline Management

```bash
# Update dependency security baselines
nix develop -c ./scripts/update-dependency-security.sh -u

# Verify baselines are current
nix develop -c ./scripts/update-dependency-security.sh -v

# Run full security verification
nix develop -c mvn -P artagon-oss-security verify
```

### Release Preparation

```bash
# Enter shell
nix develop

# Verify baselines
./scripts/update-dependency-security.sh -v

# Run release build
mvn -P artagon-oss-release,artagon-oss-security clean verify
```

## Direnv Integration (Optional)

[direnv](https://direnv.net/) automatically loads the Nix environment when you `cd` into the project directory.

### Setup

1. **Install direnv:**
   ```bash
   # On macOS
   brew install direnv

   # Or via Nix
   nix profile install nixpkgs#direnv
   ```

2. **Configure your shell:**
   ```bash
   # For bash, add to ~/.bashrc:
   eval "$(direnv hook bash)"

   # For zsh, add to ~/.zshrc:
   eval "$(direnv hook zsh)"
   ```

3. **Create `.envrc` in project root:**
   ```bash
   use flake
   ```

4. **Allow the directory:**
   ```bash
   direnv allow
   ```

Now the Nix environment activates automatically when you enter the directory!

## File Structure

```
artagon-parent/
├── nix/
│   ├── flake.nix         # Nix flake definition (modern)
│   ├── shell.nix         # Legacy shell.nix (compatibility)
│   └── README.md         # Detailed Nix patterns and examples
├── .envrc                # Optional: direnv configuration
└── flake.lock            # Lock file (committed to version control)
```

### `nix/flake.nix`

Modern Nix flake defining:
- Multiple development shells (default, jdk17, jdk21, ci)
- Build checks (maven-compile, scripts-executable)
- Code formatter

### `nix/shell.nix`

Legacy format for older Nix versions. Provides same environment as flake.

### `nix/README.md`

Comprehensive guide with:
- Detailed Nix patterns for Maven/Java projects
- Advanced configuration examples
- CI/CD integration
- Troubleshooting

## Advanced Usage

### Running Checks

```bash
# Run all defined checks
nix flake check

# Run specific check
nix build .#checks.x86_64-linux.maven-compile
```

### Code Formatting

```bash
# Format code
nix fmt

# Or explicitly
nix run .#formatter
```

### Update Dependencies

```bash
# Update all Nix flake inputs
nix flake update

# Update specific input
nix flake update nixpkgs
```

### Pure Shell (No System Dependencies)

```bash
# Completely isolated from system
nix develop --pure

# Verify no system dependencies leak in
nix develop --pure -c env | grep -i path
```

## CI/CD Integration

### GitHub Actions

```yaml
name: Build with Nix
on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: recursive

      - uses: cachix/install-nix-action@v25
        with:
          github_access_token: ${{ secrets.GITHUB_TOKEN }}

      - name: Build
        run: nix develop -c mvn verify

      - name: Security Check
        run: nix develop .#ci -c mvn -P artagon-oss-security verify
```

### GitLab CI

```yaml
build:
  image: nixos/nix:latest
  script:
    - nix develop -c mvn verify
    - nix develop -c mvn -P artagon-oss-security verify
```

## Troubleshooting

### Nix Not Found

**Error**: `nix: command not found`

**Solution**: Install Nix or ensure it's in your PATH:
```bash
# Add to ~/.bashrc or ~/.zshrc
if [ -e ~/.nix-profile/etc/profile.d/nix.sh ]; then
  . ~/.nix-profile/etc/profile.d/nix.sh
fi
```

### Flakes Not Enabled

**Error**: `experimental Nix feature 'nix-command' is disabled`

**Solution**: Enable flakes in `~/.config/nix/nix.conf`:
```
experimental-features = nix-command flakes
```

### Java Version Mismatch

**Issue**: Wrong Java version inside shell

**Solution**: Check JAVA_HOME is set:
```bash
echo $JAVA_HOME
java -version
```

### Maven Dependencies Not Downloading

**Issue**: Network or proxy issues

**Solution**: Configure Maven proxy in `~/.m2/settings.xml` or use:
```bash
# Download dependencies first
nix develop -c mvn dependency:go-offline

# Then build offline
nix develop -c mvn --offline verify
```

### Submodule Not Initialized

**Issue**: `.common/artagon-common` is empty

**Solution**: Initialize submodules:
```bash
git submodule update --init --recursive
```

## Performance Tips

1. **Use direnv**: Automatically loads environment, faster than manual `nix develop`

2. **Binary cache**: Nix downloads pre-built binaries instead of building locally:
   ```bash
   # Already enabled by default
   nix-channel --list
   ```

3. **Garbage collection**: Remove unused packages to save disk space:
   ```bash
   nix-collect-garbage -d
   ```

4. **Maven cache**: Nix respects `~/.m2/repository`, so dependencies persist

5. **Offline mode**: After first build, use `mvn --offline` for faster rebuilds

## Migration from Traditional Setup

### Before (Manual Setup)
```bash
# Install Java manually
brew install openjdk@17

# Install Maven manually
brew install maven

# Install GPG manually
brew install gnupg

# Manage versions manually
# Deal with conflicts
# Different setups on different machines
```

### After (Nix)
```bash
# Single command
nix develop

# Everything installed automatically
# Exact same setup everywhere
# No system pollution
```

## Resources

- **Nix/flake.nix** - Project's Nix flake configuration
- **Nix/README.md** - Detailed Nix patterns and examples
- [Nix Documentation](https://nixos.org/manual/nix/stable/)
- [Nix Flakes](https://nixos.wiki/wiki/Flakes)
- [Zero to Nix](https://zero-to-nix.com/) - Beginner-friendly guide
- [Nix Pills](https://nixos.org/guides/nix-pills/) - Deep dive tutorial

## Quick Reference

| Command | Description |
|---------|-------------|
| `nix develop` | Enter default dev shell (JDK 17) |
| `nix develop .#jdk21` | Use JDK 21 shell |
| `nix develop .#ci` | Minimal CI environment |
| `nix develop -c CMD` | Run command in shell |
| `nix flake check` | Run all checks |
| `nix flake update` | Update dependencies |
| `nix fmt` | Format code |
| `direnv allow` | Enable auto-loading (with direnv) |

## Support

For Nix-specific issues:
- Check `nix/README.md` for detailed patterns
- See [Nix Discourse](https://discourse.nixos.org/)
- Join [Nix Community Discord](https://discord.gg/RbvHtGa)

For artagon-parent issues:
- Open an issue in the repository
- See general documentation in `.common/artagon-common/docs/`
