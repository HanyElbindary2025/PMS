#!/bin/bash
set -e

# Download and install Flutter
echo "Downloading Flutter..."
curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.1-stable.tar.xz | tar -xJ

# Add Flutter to PATH
export PATH=$PATH:$PWD/flutter/bin

# Configure Flutter for web
echo "Configuring Flutter for web..."
flutter config --enable-web

# Get dependencies
echo "Getting dependencies..."
flutter pub get

# Build web app
echo "Building web app..."
flutter build web --release --web-renderer html --base-href=/
