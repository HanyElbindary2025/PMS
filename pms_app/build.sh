#!/bin/bash
set -e

# Download and install Flutter
echo "Downloading Flutter..."
curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.1-stable.tar.xz | tar -xJ

# Add Flutter to PATH
export PATH=$PATH:$PWD/flutter/bin

# Fix git ownership issues
echo "Fixing git ownership..."
git config --global --add safe.directory $PWD/flutter
git config --global --add safe.directory $PWD

# Configure Flutter for web and disable analytics
echo "Configuring Flutter for web..."
flutter config --enable-web --no-analytics

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Build web app
echo "Building web app..."
flutter build web --release --web-renderer html --base-href=/
