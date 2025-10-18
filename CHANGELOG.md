# Changelog - artagon-parent

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1] - 2025-10-18

### Initial Release

#### Added
- Parent POM with comprehensive build configuration
- Import of artagon-bom 1.0.0 for dependency management
- Java 25 support with advanced compiler configuration
- JVM performance tuning configurations:
  - Low-latency profile with ZGC
  - High-throughput profile with G1GC
  - Incubator module support (jdk.incubator.vector)
- Comprehensive annotation processor configuration:
  - Jilt (builder generation)
  - Auto-service (service provider generation)
  - Guava (utility annotation processing)
  - JMH (benchmark generation)
  - Truffle DSL (language implementation)
- Maven plugin management for all essential plugins
- Security infrastructure:
  - PGP signature verification
  - Checksum generation and verification
  - OWASP vulnerability scanning
  - Sonatype OSS Index integration
  - SpotBugs security analysis
- Multiple build profiles:
  - `artagon-oss-dev` - Development (active by default)
  - `artagon-oss-release` - Release to Maven Central
  - `artagon-oss-ci` - CI/CD with integration tests
  - `artagon-oss-security` - Security scanning
  - `artagon-oss-benchmark` - JMH benchmarking
- GPG signing for artifact publishing
- Nexus staging plugin for Maven Central deployment
- Git integration for build metadata
- Source and Javadoc attachment
- License header management (LGPL v3)

#### Configuration
- Compiler settings with preview features and linting
- Surefire parallel test execution (4 threads)
- Failsafe integration test configuration
- JAR manifest with build metadata (timestamp, SCM revision, branch)
- Dependency tree and list generation
- Maven enforcer rules:
  - Java version enforcement (25+)
  - Maven version enforcement (3.8.0+)
  - Banned dependencies (vulnerable versions)
  - Dependency convergence
  - Bytecode version validation
  - Duplicate class detection
- Reproducible builds configuration

#### Documentation
- Comprehensive POM metadata
- Developer information
- License configuration
- SCM details
- Distribution management for OSSRH

---

## Version History

- **1** - Initial release with Java 25 support and comprehensive build infrastructure
