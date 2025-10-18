# Artagon Parent POM - Claude Agent Context

## Project Overview

**artagon-parent** is a Maven parent POM that centralizes build configuration, dependency management, and security policy for all Artagon JVM projects. It enforces reproducible builds through multi-layered dependency verification.

**Key Purpose:**
- Provide consistent build configuration across all Artagon projects
- Enforce dependency integrity via checksum and PGP verification
- Manage plugin versions and configurations
- Define build profiles for different scenarios (dev, CI, security, release)
- Ensure reproducible builds

## Project Structure

```
artagon-parent/
├── .agents/                    # Agent-specific context files
│   ├── claude/                 # Claude Code context
│   └── codex/                  # GitHub Copilot context
├── .common/                    # Git submodule
│   └── artagon-common/        # Shared scripts and docs
├── pom.xml                     # Parent POM definition
├── security/                   # Security baseline files
│   ├── com.artagon-artagon-parent-dependency-checksums.csv
│   ├── com.artagon-artagon-parent-dependency-checksums.csv.sha256
│   ├── com.artagon-artagon-parent-dependency-checksums.csv.sha512
│   ├── com.artagon-artagon-parent-pgp-trusted-keys.list
│   ├── com.artagon-artagon-parent-pgp-trusted-keys.list.sha256
│   ├── com.artagon-artagon-parent-pgp-trusted-keys.list.sha512
│   └── README.md
├── scripts/                    # Project wrapper scripts
│   └── update-dependency-security.sh
├── licenses/                   # License texts
├── CHANGELOG.md               # Version history
├── RELEASE-GUIDE.md           # Release process
└── README.md                  # Project documentation
```

## Maven Coordinates

```xml
<groupId>org.artagon</groupId>
<artifactId>artagon-parent</artifactId>
<version>2.0.0-SNAPSHOT</version>
<packaging>pom</packaging>
```

## Build Profiles

### artagon-oss-dev (Active by Default)

**Purpose:** Developer defaults for local builds

**Activation:** Active by default
```xml
<activeByDefault>true</activeByDefault>
```

**Configuration:**
- Unit tests enabled
- Integration tests skipped (`skipITs=true`)
- No security verification
- Fast feedback for developers

**Usage:**
```bash
mvn verify
```

### artagon-oss-security

**Purpose:** Security auditing and verification

**Activation:** Manual (`-P artagon-oss-security`)

**Security Checks:**
1. **Verify security file checksums** (validate phase)
   - Runs `verify-checksums.sh` via exec-maven-plugin
   - Verifies `.sha256` and `.sha512` for baseline files
   - Fails immediately if checksums don't match

2. **Verify dependency checksums** (verify phase)
   - Uses checksum-maven-plugin
   - Checks all compile-scope dependencies
   - Compares against `dependency-checksums.csv`

3. **Verify PGP signatures** (verify phase)
   - Uses pgpverify-maven-plugin
   - Validates against `pgp-trusted-keys.list`
   - Allows `noKey` entries for unsigned dependencies

4. **OSS Index audit** (verify phase)
   - Scans for known vulnerabilities
   - Reports security issues in dependencies

**Usage:**
```bash
mvn -P artagon-oss-security verify
```

### artagon-oss-release

**Purpose:** Pre-release packaging and verification

**Activation:** Manual (`-P artagon-oss-release`)

**Features:**
- Includes all security checks from artagon-oss-security
- Attaches sources JAR
- Attaches javadoc JAR
- Signs artifacts with GPG
- Stages to Nexus OSSRH
- Attaches security baseline files with classifiers

**Attached Artifacts:**
- `*-sources.jar`
- `*-javadoc.jar`
- `*-dependency-checksums.csv` (classifier: dependency-checksums)
- `*-pgp-trusted-keys.list` (classifier: pgp-trusted-keys)
- All with `.asc` signatures

**Usage:**
```bash
mvn -P artagon-oss-release,artagon-oss-security clean verify
```

### artagon-oss-ci

**Purpose:** Continuous integration defaults

**Activation:** Manual (`-P artagon-oss-ci`)

**Configuration:**
- Integration tests enabled (`skipITs=false`)
- Enforcer plugin strict mode
- No security verification (run separately in CI)

**Usage:**
```bash
mvn -P artagon-oss-ci verify
```

### artagon-oss-benchmark

**Purpose:** JMH benchmarking support

**Activation:** Property (`-Dartagon.benchmarks=true`)

**Features:**
- Adds JMH dependencies
- Configures JMH annotation processor
- Builds benchmark JAR

**Usage:**
```bash
mvn -Dartagon.benchmarks=true verify
```

## Security Verification Layers

### Layer 1: Security Baseline File Integrity (validate phase)

**Purpose:** Ensure baseline files haven't been tampered with

**Implementation:**
```xml
<plugin>
    <groupId>org.codehaus.mojo</groupId>
    <artifactId>exec-maven-plugin</artifactId>
    <execution>
        <id>verify-security-file-checksums</id>
        <phase>validate</phase>
        <goals>
            <goal>exec</goal>
        </goals>
        <configuration>
            <executable>${project.basedir}/.common/artagon-common/scripts/security/verify-checksums.sh</executable>
            <arguments>
                <argument>--security-dir</argument>
                <argument>${project.basedir}/security</argument>
                <argument>com.artagon-artagon-parent-dependency-checksums.csv</argument>
                <argument>com.artagon-artagon-parent-pgp-trusted-keys.list</argument>
            </arguments>
        </configuration>
    </execution>
</plugin>
```

**What it does:**
- Runs in validate phase (before any other build steps)
- Verifies SHA-256 and SHA-512 checksums for baseline files
- Uses trusted script from artagon-common submodule
- Fails build immediately if any checksum doesn't match

### Layer 2: Dependency Checksum Verification (verify phase)

**Purpose:** Ensure all dependencies match expected checksums

**Implementation:**
```xml
<plugin>
    <groupId>net.nicoulaj.maven.plugins</groupId>
    <artifactId>checksum-maven-plugin</artifactId>
    <execution>
        <id>verify-dependency-checksums</id>
        <phase>verify</phase>
        <goals>
            <goal>check</goal>
        </goals>
        <configuration>
            <csvSummaryFile>${project.basedir}/security/com.artagon-artagon-parent-dependency-checksums.csv</csvSummaryFile>
            <scopes>
                <scope>compile</scope>
            </scopes>
            <transitive>true</transitive>
            <failOnError>true</failOnError>
        </configuration>
    </execution>
</plugin>
```

**What it does:**
- Uses verified baseline from Layer 1
- Checks all compile-scope dependencies (including transitives)
- Compares SHA-256 against CSV baseline
- Fails if any dependency is missing or has different checksum

### Layer 3: PGP Signature Verification (verify phase)

**Purpose:** Validate cryptographic signatures of dependencies

**Implementation:**
```xml
<plugin>
    <groupId>org.simplify4u.plugins</groupId>
    <artifactId>pgpverify-maven-plugin</artifactId>
    <execution>
        <goals>
            <goal>check</goal>
        </goals>
        <configuration>
            <keysMapLocation>${project.basedir}/security/com.artagon-artagon-parent-pgp-trusted-keys.list</keysMapLocation>
            <scope>compile</scope>
        </configuration>
    </execution>
</plugin>
```

**What it does:**
- Uses verified baseline from Layer 1
- Validates PGP signatures against trusted fingerprints
- Allows `noKey` entries for dependencies without public keys
- Fails if signature is invalid or key is untrusted

## Dependency Management

### Testing Stack
- JUnit Jupiter 5.11.4
- AssertJ 3.27.3
- Mockito 5.15.2

### Logging Stack
- SLF4J 2.0.16
- Logback 1.5.15

### Benchmarking Stack
- JMH 1.37

**Usage in Child Projects:**
```xml
<parent>
    <groupId>org.artagon</groupId>
    <artifactId>artagon-parent</artifactId>
    <version>2.0.0-SNAPSHOT</version>
</parent>

<dependencies>
    <!-- No version needed - managed by parent -->
    <dependency>
        <groupId>org.junit.jupiter</groupId>
        <artifactId>junit-jupiter</artifactId>
        <scope>test</scope>
    </dependency>
</dependencies>
```

## Plugin Management

### Key Plugins

**Build Plugins:**
- maven-compiler-plugin: Java compilation
- maven-surefire-plugin: Unit tests
- maven-failsafe-plugin: Integration tests
- maven-jar-plugin: JAR packaging

**Security Plugins:**
- checksum-maven-plugin: Dependency checksum verification
- pgpverify-maven-plugin: PGP signature verification
- maven-gpg-plugin: Artifact signing
- ossindex-maven-plugin: Vulnerability scanning
- exec-maven-plugin: Security script execution

**Release Plugins:**
- maven-source-plugin: Source JAR attachment
- maven-javadoc-plugin: Javadoc JAR attachment
- nexus-staging-maven-plugin: OSSRH deployment

## Security Baseline Files

### File Naming Convention

**Pattern:** `{groupId}-{artifactId}-{type}.{ext}`

**Files:**
- `com.artagon-artagon-parent-dependency-checksums.csv`
- `com.artagon-artagon-parent-pgp-trusted-keys.list`

**Checksum Files:**
- `*.sha256` - SHA-256 checksum of baseline file
- `*.sha512` - SHA-512 checksum of baseline file

### Dependency Checksums CSV Format

```csv
artifactName,files
org.junit.jupiter:junit-jupiter:jar:5.11.4,SHA-256-HASH
org.slf4j:slf4j-api:jar:2.0.16,SHA-256-HASH
```

### PGP Trusted Keys List Format

```
org.junit.jupiter:junit-jupiter:jar:5.11.4 = 0xPGP-FINGERPRINT
org.slf4j:slf4j-api:jar:2.0.16 = noKey
```

### Updating Security Baselines

**After any dependency change:**
```bash
# Regenerate baselines
./scripts/update-dependency-security.sh --update

# Review changes
git diff security/

# Commit updates
git add security/
git commit -m "Update dependency security baselines"
```

**Before release:**
```bash
# Verify baselines are current
./scripts/update-dependency-security.sh --verify

# Run security build
mvn -P artagon-oss-security verify
```

## Common Maven Commands

### Development
```bash
# Default developer build
mvn verify

# Clean build
mvn clean verify

# Skip tests
mvn verify -DskipTests

# Run specific test
mvn test -Dtest=MyTest
```

### Security Verification
```bash
# Security audit only
mvn -P artagon-oss-security verify

# Clean security build
mvn -P artagon-oss-security clean verify
```

### Release
```bash
# Full release build with security checks
mvn -P artagon-oss-release,artagon-oss-security clean verify

# Deploy to OSSRH
mvn -P artagon-oss-release,artagon-oss-security clean deploy
```

### CI
```bash
# CI build with integration tests
mvn -P artagon-oss-ci verify

# CI with security
mvn -P artagon-oss-ci,artagon-oss-security verify
```

## Release Workflow

### Prerequisites
1. All changes committed and pushed
2. Security baselines up to date
3. CHANGELOG.md updated
4. Version numbers finalized

### Release Steps

1. **Verify security baselines:**
   ```bash
   ./scripts/update-dependency-security.sh --verify
   ```

2. **Run full security build:**
   ```bash
   mvn -P artagon-oss-security clean verify
   ```

3. **Run release build:**
   ```bash
   mvn -P artagon-oss-release,artagon-oss-security clean verify
   ```

4. **Deploy to OSSRH:**
   ```bash
   mvn -P artagon-oss-release,artagon-oss-security clean deploy
   ```

5. **Tag release:**
   ```bash
   git tag -a v2.0.0 -m "Release version 2.0.0"
   git push origin v2.0.0
   ```

## Integration with artagon-common

### Submodule Path
```
.common/artagon-common/
```

### Used Resources

**Scripts:**
- `.common/artagon-common/scripts/security/update-dependency-security.sh`
- `.common/artagon-common/scripts/security/verify-checksums.sh`

**Documentation:**
- `.common/artagon-common/docs/SECURITY-SCRIPTS.md`
- `.common/artagon-common/docs/RELEASE-GUIDE.md`
- `.common/artagon-common/docs/DEPLOYMENT.md`
- `.common/artagon-common/docs/licensing/`

### Wrapper Script Pattern

`scripts/update-dependency-security.sh`:
```bash
#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
COMMON_SCRIPT="${PROJECT_ROOT}/.common/artagon-common/scripts/security/update-dependency-security.sh"

if [[ ! -x "${COMMON_SCRIPT}" ]]; then
    echo "ERROR: Shared script not found at ${COMMON_SCRIPT}" >&2
    echo "Ensure artagon-common submodule is initialized:" >&2
    echo "  git submodule update --init --recursive" >&2
    exit 1
fi

exec "${COMMON_SCRIPT}" --project-root "${PROJECT_ROOT}" "$@"
```

## Properties

### Customization Properties
```xml
<properties>
    <!-- Java version -->
    <maven.compiler.source>17</maven.compiler.source>
    <maven.compiler.target>17</maven.compiler.target>

    <!-- Encoding -->
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>

    <!-- Test control -->
    <skipTests>false</skipTests>
    <skipITs>true</skipITs>

    <!-- Dependency versions -->
    <junit.version>5.11.4</junit.version>
    <slf4j.version>2.0.16</slf4j.version>
    <logback.version>1.5.15</logback.version>
</properties>
```

### Override in Child Projects
```xml
<properties>
    <!-- Enable integration tests -->
    <skipITs>false</skipITs>

    <!-- Use different Java version -->
    <maven.compiler.source>21</maven.compiler.source>
    <maven.compiler.target>21</maven.compiler.target>
</properties>
```

## Important Considerations

### When Modifying pom.xml:

1. **Adding Dependencies:**
   - Add to `<dependencyManagement>` section
   - Specify exact version
   - Update security baselines: `./scripts/update-dependency-security.sh --update`
   - Verify: `mvn -P artagon-oss-security verify`
   - Commit both pom.xml and security files together

2. **Updating Versions:**
   - Change version in `<dependencyManagement>`
   - Regenerate security baselines
   - Test thoroughly
   - Review security baseline diffs

3. **Modifying Profiles:**
   - Test each profile independently
   - Ensure security profiles still work
   - Document changes in CHANGELOG.md

4. **Plugin Configuration:**
   - Add to `<pluginManagement>` for version control
   - Configure in `<build><plugins>` or profile-specific sections
   - Always specify version

### Security Best Practices:

1. **Never manually edit security baseline files**
2. **Always verify before releases**: `--verify` mode
3. **Commit security baselines separately** from functional changes
4. **Review all security baseline diffs** carefully
5. **Run security profile in CI** builds
6. **Update submodules regularly** for script fixes

### Build Phase Execution Order:

1. **validate** - Verify security file checksums
2. **compile** - Compile source code
3. **test** - Run unit tests
4. **package** - Create JAR
5. **integration-test** - Run integration tests
6. **verify** - Run all verifications (checksum, PGP, OSS Index)
7. **install** - Install to local repository
8. **deploy** - Deploy to remote repository

## Troubleshooting

### Security Verification Failures

**Error:** "SHA-256 checksum mismatch"
- **Cause:** Dependency changed or baseline out of date
- **Fix:** `./scripts/update-dependency-security.sh --update`

**Error:** "PGP signature verification failed"
- **Cause:** Invalid signature or untrusted key
- **Fix:** Review `pgp-trusted-keys.list`, possibly add `noKey` entry

**Error:** "Shared script not found"
- **Cause:** artagon-common submodule not initialized
- **Fix:** `git submodule update --init --recursive`

### Build Failures

**Error:** "Unknown lifecycle phase"
- **Cause:** Typo in Maven command
- **Fix:** Check profile names and phases

**Error:** "Plugin version not found"
- **Cause:** Missing version in plugin configuration
- **Fix:** Add version to `<pluginManagement>`

## Quick Reference

### Most Used Commands
```bash
# Developer build
mvn verify

# Security build
mvn -P artagon-oss-security verify

# Release build
mvn -P artagon-oss-release,artagon-oss-security clean verify

# Update security baselines
./scripts/update-dependency-security.sh --update

# Verify baselines
./scripts/update-dependency-security.sh --verify
```

### Key Files
- `pom.xml` - Parent POM definition
- `security/*.csv` - Dependency checksums
- `security/*.list` - PGP trusted keys
- `scripts/update-dependency-security.sh` - Wrapper script
- `CHANGELOG.md` - Version history
- `RELEASE-GUIDE.md` - Release instructions
