# Artagon Parent POM - Codex/Copilot Code Patterns

## Project Type
Maven Parent POM for JVM projects with security verification

## Primary Language
- XML (Maven POM)
- Bash (wrapper scripts)

## Maven POM Patterns

### Parent POM Definition
```xml
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0
                             http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>org.artagon</groupId>
    <artifactId>artagon-parent</artifactId>
    <version>2.0.0-SNAPSHOT</version>
    <packaging>pom</packaging>

    <name>Artagon Parent POM</name>
    <description>Parent POM for Artagon JVM projects</description>
</project>
```

### Property Definitions
```xml
<properties>
    <!-- Java version -->
    <maven.compiler.source>17</maven.compiler.source>
    <maven.compiler.target>17</maven.compiler.target>
    <maven.compiler.release>17</maven.compiler.release>

    <!-- Encoding -->
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>

    <!-- Test control -->
    <skipTests>false</skipTests>
    <skipITs>true</skipITs>

    <!-- Dependency versions -->
    <junit.version>5.11.4</junit.version>
    <assertj.version>3.27.3</assertj.version>
    <mockito.version>5.15.2</mockito.version>
    <slf4j.version>2.0.16</slf4j.version>
    <logback.version>1.5.15</logback.version>

    <!-- Plugin versions -->
    <maven-compiler-plugin.version>3.14.0</maven-compiler-plugin.version>
    <maven-surefire-plugin.version>3.5.2</maven-surefire-plugin.version>
    <checksum-maven-plugin.version>1.11</checksum-maven-plugin.version>
    <pgpverify-maven-plugin.version>1.18.2</pgpverify-maven-plugin.version>
</properties>
```

### Dependency Management
```xml
<dependencyManagement>
    <dependencies>
        <!-- Testing -->
        <dependency>
            <groupId>org.junit.jupiter</groupId>
            <artifactId>junit-jupiter</artifactId>
            <version>${junit.version}</version>
            <scope>test</scope>
        </dependency>

        <dependency>
            <groupId>org.assertj</groupId>
            <artifactId>assertj-core</artifactId>
            <version>${assertj.version}</version>
            <scope>test</scope>
        </dependency>

        <dependency>
            <groupId>org.mockito</groupId>
            <artifactId>mockito-core</artifactId>
            <version>${mockito.version}</version>
            <scope>test</scope>
        </dependency>

        <!-- Logging -->
        <dependency>
            <groupId>org.slf4j</groupId>
            <artifactId>slf4j-api</artifactId>
            <version>${slf4j.version}</version>
        </dependency>

        <dependency>
            <groupId>ch.qos.logback</groupId>
            <artifactId>logback-classic</artifactId>
            <version>${logback.version}</version>
        </dependency>
    </dependencies>
</dependencyManagement>
```

### Plugin Management
```xml
<build>
    <pluginManagement>
        <plugins>
            <!-- Compiler Plugin -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>${maven-compiler-plugin.version}</version>
                <configuration>
                    <release>${maven.compiler.release}</release>
                    <compilerArgs>
                        <arg>-Xlint:all</arg>
                        <arg>-parameters</arg>
                    </compilerArgs>
                </configuration>
            </plugin>

            <!-- Surefire Plugin (Unit Tests) -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-surefire-plugin</artifactId>
                <version>${maven-surefire-plugin.version}</version>
                <configuration>
                    <skipTests>${skipTests}</skipTests>
                    <argLine>-Xmx1024m</argLine>
                </configuration>
            </plugin>

            <!-- Failsafe Plugin (Integration Tests) -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-failsafe-plugin</artifactId>
                <version>${maven-surefire-plugin.version}</version>
                <configuration>
                    <skipITs>${skipITs}</skipITs>
                </configuration>
                <executions>
                    <execution>
                        <goals>
                            <goal>integration-test</goal>
                            <goal>verify</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </pluginManagement>
</build>
```

### Profile Pattern
```xml
<profiles>
    <!-- Developer Profile (Active by Default) -->
    <profile>
        <id>artagon-oss-dev</id>
        <activation>
            <activeByDefault>true</activeByDefault>
        </activation>
        <properties>
            <skipITs>true</skipITs>
        </properties>
    </profile>

    <!-- Security Profile -->
    <profile>
        <id>artagon-oss-security</id>
        <build>
            <plugins>
                <!-- Security verification plugins -->
            </plugins>
        </build>
    </profile>

    <!-- Release Profile -->
    <profile>
        <id>artagon-oss-release</id>
        <build>
            <plugins>
                <!-- Release plugins -->
            </plugins>
        </build>
    </profile>
</profiles>
```

### exec-maven-plugin for Script Execution
```xml
<plugin>
    <groupId>org.codehaus.mojo</groupId>
    <artifactId>exec-maven-plugin</artifactId>
    <version>3.5.0</version>
    <executions>
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
    </executions>
</plugin>
```

### checksum-maven-plugin for Dependency Verification
```xml
<plugin>
    <groupId>net.nicoulaj.maven.plugins</groupId>
    <artifactId>checksum-maven-plugin</artifactId>
    <version>${checksum-maven-plugin.version}</version>
    <executions>
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
                <quiet>false</quiet>
            </configuration>
        </execution>
    </executions>
</plugin>
```

### pgpverify-maven-plugin for Signature Verification
```xml
<plugin>
    <groupId>org.simplify4u.plugins</groupId>
    <artifactId>pgpverify-maven-plugin</artifactId>
    <version>${pgpverify-maven-plugin.version}</version>
    <executions>
        <execution>
            <goals>
                <goal>check</goal>
            </goals>
            <configuration>
                <keysMapLocation>${project.basedir}/security/com.artagon-artagon-parent-pgp-trusted-keys.list</keysMapLocation>
                <scope>compile</scope>
                <failNoSignature>false</failNoSignature>
                <verifyPomFiles>false</verifyPomFiles>
            </configuration>
        </execution>
    </executions>
</plugin>
```

### maven-source-plugin for Sources JAR
```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-source-plugin</artifactId>
    <version>3.3.1</version>
    <executions>
        <execution>
            <id>attach-sources</id>
            <goals>
                <goal>jar-no-fork</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

### maven-javadoc-plugin for Javadoc JAR
```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-javadoc-plugin</artifactId>
    <version>3.11.2</version>
    <executions>
        <execution>
            <id>attach-javadocs</id>
            <goals>
                <goal>jar</goal>
            </goals>
        </execution>
    </executions>
    <configuration>
        <quiet>true</quiet>
        <doclint>none</doclint>
    </configuration>
</plugin>
```

### maven-gpg-plugin for Artifact Signing
```xml
<plugin>
    <groupId>org.apache.maven.plugins</groupId>
    <artifactId>maven-gpg-plugin</artifactId>
    <version>3.2.7</version>
    <executions>
        <execution>
            <id>sign-artifacts</id>
            <phase>verify</phase>
            <goals>
                <goal>sign</goal>
            </goals>
            <configuration>
                <gpgArguments>
                    <arg>--pinentry-mode</arg>
                    <arg>loopback</arg>
                </gpgArguments>
            </configuration>
        </execution>
    </executions>
</plugin>
```

### build-helper-maven-plugin for Artifact Attachment
```xml
<plugin>
    <groupId>org.codehaus.mojo</groupId>
    <artifactId>build-helper-maven-plugin</artifactId>
    <version>3.6.0</version>
    <executions>
        <execution>
            <id>attach-security-files</id>
            <phase>package</phase>
            <goals>
                <goal>attach-artifact</goal>
            </goals>
            <configuration>
                <artifacts>
                    <artifact>
                        <file>${project.basedir}/security/com.artagon-artagon-parent-dependency-checksums.csv</file>
                        <type>csv</type>
                        <classifier>dependency-checksums</classifier>
                    </artifact>
                    <artifact>
                        <file>${project.basedir}/security/com.artagon-artagon-parent-pgp-trusted-keys.list</file>
                        <type>list</type>
                        <classifier>pgp-trusted-keys</classifier>
                    </artifact>
                </artifacts>
            </configuration>
        </execution>
    </executions>
</plugin>
```

### nexus-staging-maven-plugin for OSSRH Deployment
```xml
<plugin>
    <groupId>org.sonatype.plugins</groupId>
    <artifactId>nexus-staging-maven-plugin</artifactId>
    <version>1.7.0</version>
    <extensions>true</extensions>
    <configuration>
        <serverId>ossrh</serverId>
        <nexusUrl>https://s01.oss.sonatype.org/</nexusUrl>
        <autoReleaseAfterClose>false</autoReleaseAfterClose>
    </configuration>
</plugin>
```

### ossindex-maven-plugin for Vulnerability Scanning
```xml
<plugin>
    <groupId>org.sonatype.ossindex.maven</groupId>
    <artifactId>ossindex-maven-plugin</artifactId>
    <version>3.2.0</version>
    <executions>
        <execution>
            <id>audit-dependencies</id>
            <phase>verify</phase>
            <goals>
                <goal>audit</goal>
            </goals>
        </execution>
    </executions>
</plugin>
```

## Security Profile Complete Pattern

```xml
<profile>
    <id>artagon-oss-security</id>
    <build>
        <plugins>
            <!-- 1. Verify Security File Checksums (validate phase) -->
            <plugin>
                <groupId>org.codehaus.mojo</groupId>
                <artifactId>exec-maven-plugin</artifactId>
                <executions>
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
                </executions>
            </plugin>

            <!-- 2. Verify Dependency Checksums (verify phase) -->
            <plugin>
                <groupId>net.nicoulaj.maven.plugins</groupId>
                <artifactId>checksum-maven-plugin</artifactId>
                <executions>
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
                </executions>
            </plugin>

            <!-- 3. Verify PGP Signatures (verify phase) -->
            <plugin>
                <groupId>org.simplify4u.plugins</groupId>
                <artifactId>pgpverify-maven-plugin</artifactId>
                <executions>
                    <execution>
                        <goals>
                            <goal>check</goal>
                        </goals>
                        <configuration>
                            <keysMapLocation>${project.basedir}/security/com.artagon-artagon-parent-pgp-trusted-keys.list</keysMapLocation>
                            <scope>compile</scope>
                        </configuration>
                    </execution>
                </executions>
            </plugin>

            <!-- 4. Audit Vulnerabilities (verify phase) -->
            <plugin>
                <groupId>org.sonatype.ossindex.maven</groupId>
                <artifactId>ossindex-maven-plugin</artifactId>
                <executions>
                    <execution>
                        <id>audit-dependencies</id>
                        <phase>verify</phase>
                        <goals>
                            <goal>audit</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
</profile>
```

## Release Profile Complete Pattern

```xml
<profile>
    <id>artagon-oss-release</id>
    <build>
        <plugins>
            <!-- Include all security plugins from artagon-oss-security -->

            <!-- Attach Sources -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-source-plugin</artifactId>
                <executions>
                    <execution>
                        <id>attach-sources</id>
                        <goals>
                            <goal>jar-no-fork</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>

            <!-- Attach Javadocs -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-javadoc-plugin</artifactId>
                <executions>
                    <execution>
                        <id>attach-javadocs</id>
                        <goals>
                            <goal>jar</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>

            <!-- Sign Artifacts -->
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-gpg-plugin</artifactId>
                <executions>
                    <execution>
                        <id>sign-artifacts</id>
                        <phase>verify</phase>
                        <goals>
                            <goal>sign</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>

            <!-- Attach Security Files -->
            <plugin>
                <groupId>org.codehaus.mojo</groupId>
                <artifactId>build-helper-maven-plugin</artifactId>
                <executions>
                    <execution>
                        <id>attach-security-files</id>
                        <phase>package</phase>
                        <goals>
                            <goal>attach-artifact</goal>
                        </goals>
                        <configuration>
                            <artifacts>
                                <artifact>
                                    <file>${project.basedir}/security/com.artagon-artagon-parent-dependency-checksums.csv</file>
                                    <type>csv</type>
                                    <classifier>dependency-checksums</classifier>
                                </artifact>
                                <artifact>
                                    <file>${project.basedir}/security/com.artagon-artagon-parent-pgp-trusted-keys.list</file>
                                    <type>list</type>
                                    <classifier>pgp-trusted-keys</classifier>
                                </artifact>
                            </artifacts>
                        </configuration>
                    </execution>
                </executions>
            </plugin>

            <!-- OSSRH Deployment -->
            <plugin>
                <groupId>org.sonatype.plugins</groupId>
                <artifactId>nexus-staging-maven-plugin</artifactId>
                <extensions>true</extensions>
                <configuration>
                    <serverId>ossrh</serverId>
                    <nexusUrl>https://s01.oss.sonatype.org/</nexusUrl>
                    <autoReleaseAfterClose>false</autoReleaseAfterClose>
                </configuration>
            </plugin>
        </plugins>
    </build>

    <!-- Distribution Management -->
    <distributionManagement>
        <snapshotRepository>
            <id>ossrh</id>
            <url>https://s01.oss.sonatype.org/content/repositories/snapshots</url>
        </snapshotRepository>
        <repository>
            <id>ossrh</id>
            <url>https://s01.oss.sonatype.org/service/local/staging/deploy/maven2/</url>
        </repository>
    </distributionManagement>
</profile>
```

## Bash Wrapper Script Pattern

```bash
#!/usr/bin/env bash
set -euo pipefail

# Locate project root and shared script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
COMMON_SCRIPT="${PROJECT_ROOT}/.common/artagon-common/scripts/security/update-dependency-security.sh"

# Verify shared script exists
if [[ ! -x "${COMMON_SCRIPT}" ]]; then
    echo "ERROR: Shared script not found at ${COMMON_SCRIPT}" >&2
    echo "Ensure artagon-common submodule is initialized:" >&2
    echo "  git submodule update --init --recursive" >&2
    exit 1
fi

# Forward all arguments to shared script with project root
exec "${COMMON_SCRIPT}" --project-root "${PROJECT_ROOT}" "$@"
```

## Common Command Patterns

```bash
# Developer build
mvn verify

# Security build
mvn -P artagon-oss-security verify

# Release build
mvn -P artagon-oss-release,artagon-oss-security clean verify

# Deploy snapshot
mvn -P artagon-oss-release,artagon-oss-security clean deploy

# Update security baselines
./scripts/update-dependency-security.sh --update

# Verify security baselines
./scripts/update-dependency-security.sh --verify

# Skip tests
mvn verify -DskipTests

# Run single test
mvn test -Dtest=MyTest

# Debug Maven
mvn -X verify

# Update dependencies
mvn versions:display-dependency-updates

# Update plugins
mvn versions:display-plugin-updates
```

## File Naming Conventions

### Security Baseline Files
```
{groupId}-{artifactId}-dependency-checksums.csv
{groupId}-{artifactId}-dependency-checksums.csv.sha256
{groupId}-{artifactId}-dependency-checksums.csv.sha512
{groupId}-{artifactId}-pgp-trusted-keys.list
{groupId}-{artifactId}-pgp-trusted-keys.list.sha256
{groupId}-{artifactId}-pgp-trusted-keys.list.sha512
```

### Example for com.artagon:artagon-parent
```
com.artagon-artagon-parent-dependency-checksums.csv
com.artagon-artagon-parent-dependency-checksums.csv.sha256
com.artagon-artagon-parent-dependency-checksums.csv.sha512
com.artagon-artagon-parent-pgp-trusted-keys.list
com.artagon-artagon-parent-pgp-trusted-keys.list.sha256
com.artagon-artagon-parent-pgp-trusted-keys.list.sha512
```

## Project-Specific Conventions

1. **Profiles**: artagon-oss-{dev,security,release,ci,benchmark}
2. **Properties**: Use version properties for all dependency and plugin versions
3. **Security files**: Maven coordinate-based naming
4. **Scripts**: Wrappers delegate to artagon-common
5. **Documentation**: Reference common docs via relative paths
6. **Phase binding**: validate (security files) → verify (dependencies)
7. **Java version**: 17 minimum (configurable via properties)
8. **Encoding**: UTF-8 everywhere
