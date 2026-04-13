# Flutter Development Environment - GlowUp AI
# This Dockerfile ensures consistent build environment across team members
# No version conflicts, no setup headaches

FROM ghcr.io/cirruslabs/flutter:3.24.0 AS flutter_build

WORKDIR /app

# Copy project files
COPY . .

# Get dependencies
RUN flutter pub get

# Build APK (release)
RUN flutter build apk --release

# Runtime stage - keeps image size manageable
FROM ubuntu:22.04

WORKDIR /app

# Install runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openjdk-11-jdk-headless \
    android-sdk \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy built APK from builder
COPY --from=flutter_build /app/build/app/outputs/flutter-apk/app-release.apk /app/

# Development stage - for coding
FROM ghcr.io/cirruslabs/flutter:3.24.0

LABEL maintainer="GlowUp Team"
LABEL description="GlowUp AI - Makeup Transfer Flutter App Development Environment"

WORKDIR /app

# Set environment variables
ENV FLUTTER_HOME=/opt/flutter
ENV PATH="$FLUTTER_HOME/bin:$PATH"
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

# Install system dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openjdk-11-jdk-headless \
    git \
    curl \
    unzip \
    zsh \
    openssh-client \
    vim \
    nano \
    && rm -rf /var/lib/apt/lists/*

# Copy project
COPY . .

# Get Flutter dependencies
RUN flutter pub get

# Pre-download Gradle dependencies
RUN cd android && \
    ./gradlew dependencies 2>/dev/null || true && \
    cd ..

# Accept Android SDK licenses
RUN echo "y" | sdkmanager --licenses 2>/dev/null || true

# Expose port for hot reload debugging
EXPOSE 50505 50506

# Default command
CMD ["/bin/bash"]
