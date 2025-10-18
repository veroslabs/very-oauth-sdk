# Maven Publishing Guide for VeryOauthSDK

This guide explains how to publish the VeryOauthSDK Android library to Maven Central.

## Prerequisites

1. **Sonatype OSSRH Account**: You need an account on [Sonatype OSSRH](https://s01.oss.sonatype.org/)
2. **GPG Key**: For signing the artifacts
3. **Gradle**: Version 7.4.2 or higher

## Setup

### 1. Sonatype OSSRH Account Setup

1. Create an account at [Sonatype OSSRH](https://s01.oss.sonatype.org/)
2. Create a new project ticket for `com.veryoauthsdk` group ID
3. Wait for approval (usually takes a few hours to a day)

### 2. GPG Key Setup

```bash
# Generate a new GPG key
gpg --gen-key

# List your keys
gpg --list-secret-keys

# Export your public key
gpg --armor --export your_key_id > public_key.asc

# Upload the public key to a keyserver
gpg --keyserver keyserver.ubuntu.com --send-keys your_key_id
```

### 3. Environment Variables

Set the following environment variables or add them to your `~/.gradle/gradle.properties`:

```properties
# OSSRH credentials
ossrhUsername=your_sonatype_username
ossrhPassword=your_sonatype_password

# GPG signing
signing.keyId=your_gpg_key_id
signing.password=your_gpg_key_password
signing.secretKeyRingFile=/path/to/your/secret.gpg
```

## Publishing Process

### 1. Build the Library

```bash
cd android/veryoauthsdk
./gradlew clean build
```

### 2. Generate Documentation

```bash
./gradlew dokkaHtml
```

### 3. Publish to Staging Repository

```bash
./gradlew publishReleasePublicationToSonatypeRepository
```

### 4. Close and Release

After successful upload to staging:

1. Go to [Sonatype OSSRH](https://s01.oss.sonatype.org/)
2. Navigate to "Staging Repositories"
3. Find your uploaded repository
4. Select it and click "Close"
5. Wait for validation to complete
6. Click "Release" to publish to Maven Central

## Usage

Once published, users can add the dependency to their `build.gradle`:

```gradle
dependencies {
    implementation 'com.veryoauthsdk:veryoauthsdk:1.0.0'
}
```

## Repository Configuration

The library will be available at:

- **Maven Central**: `https://repo1.maven.org/maven2/`
- **Sonatype OSSRH**: `https://s01.oss.sonatype.org/content/repositories/releases/`

## Troubleshooting

### Common Issues

1. **Authentication Failed**: Check your OSSRH credentials
2. **Signing Failed**: Verify your GPG key configuration
3. **Validation Failed**: Ensure all required metadata is present in the POM

### Gradle Commands

```bash
# Check if everything is configured correctly
./gradlew publishReleasePublicationToSonatypeRepository --dry-run

# Publish to local Maven repository for testing
./gradlew publishToMavenLocal

# Clean and rebuild
./gradlew clean build publishReleasePublicationToSonatypeRepository
```

## Version Management

To update the version:

1. Update `versionName` in `build.gradle`
2. Update `version` in the publishing configuration
3. Create a new Git tag
4. Follow the publishing process

## Security Notes

- Never commit credentials to version control
- Use environment variables or secure credential storage
- Keep your GPG key secure and backed up
