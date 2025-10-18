# Artagon Parent Security

This directory contains security-related files for verifying the integrity of the Artagon BOM and dependencies.

## Files

### bom-checksums.csv
Contains SHA-256 and SHA-512 checksums for the artagon-bom artifact.

**Format**: `GroupId:ArtifactId:Version,SHA-256,SHA-512`

**Purpose**: Verify that the BOM hasn't been tampered with during dependency resolution.

**Update Process**:
1. When artagon-bom is updated, rebuild it with `mvn clean verify`
2. Copy the checksums from `artagon-bom/security/artagon-bom-checksums.csv`
3. Update this file with the new checksums in the correct format

### dependency-checksums.csv (optional)
Contains checksums for all compile-scope dependencies.

**Purpose**: Verify integrity of all transitive dependencies.

**Generation**: Run `mvn dependency:list -DoutputFile=security/dependency-checksums.csv`

### pgp-trusted-keys.list (optional)
Contains PGP key fingerprints for verifying artifact signatures.

**Format**:
```
org.artagon:* = <key-fingerprint>
```

## Security Profiles

### artagon-oss-security
Activates comprehensive security checks:
- Vulnerability scanning with OSSIndex
- Checksum verification
- PGP signature verification (when configured)

**Usage**: `mvn verify -Partagon-oss-security`

### artagon-oss-release
Enforces security checks before release:
- Signs artifacts with GPG
- Verifies all dependencies
- Generates checksums

## Best Practices

1. **Always verify checksums** when updating artagon-bom version
2. **Use PGP signing** for releases
3. **Run security profile** in CI/CD pipeline
4. **Update checksums** immediately after BOM changes
5. **Never commit** credentials or private keys to this directory
