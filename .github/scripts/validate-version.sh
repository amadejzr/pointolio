#!/bin/bash
set -euo pipefail

# validate-version.sh
# Validates that version in pubspec.yaml is properly incremented
# Usage: ./validate-version.sh

compare_versions() {
    IFS='.' read -ra V1 <<< "$1"
    IFS='.' read -ra V2 <<< "$2"

    # Compare major
    if [ "${V1[0]}" -gt "${V2[0]}" ]; then return 0; fi
    if [ "${V1[0]}" -lt "${V2[0]}" ]; then return 1; fi

    # Compare minor
    if [ "${V1[1]:-0}" -gt "${V2[1]:-0}" ]; then return 0; fi
    if [ "${V1[1]:-0}" -lt "${V2[1]:-0}" ]; then return 1; fi

    # Compare patch
    if [ "${V1[2]:-0}" -gt "${V2[2]:-0}" ]; then return 0; fi
    if [ "${V1[2]:-0}" -lt "${V2[2]:-0}" ]; then return 1; fi

    return 1
}

# Get current version
CURRENT_VERSION=$(grep "^version:" pubspec.yaml | sed 's/version:[[:space:]]*//' | tr -d '[:space:]')

if [ -z "$CURRENT_VERSION" ]; then
    echo "::error::Version not found in pubspec.yaml"
    exit 1
fi

# Get version from main branch
git fetch origin main
BASE_VERSION=$(git show origin/main:pubspec.yaml 2>/dev/null | grep "^version:" | sed 's/version:[[:space:]]*//' | tr -d '[:space:]' || echo "")

# Extract semantic versions
CURRENT_SEM_VER=$(echo "$CURRENT_VERSION" | cut -d'+' -f1)
BASE_SEM_VER=$(echo "$BASE_VERSION" | cut -d'+' -f1)

echo "Base version (main): $BASE_VERSION"
echo "Current version (PR): $CURRENT_VERSION"

# Check if version changed
if [ "$CURRENT_VERSION" = "$BASE_VERSION" ]; then
    echo "::error::❌ Version must be bumped in pubspec.yaml"
    echo "::error::Current: $CURRENT_VERSION | Main: $BASE_VERSION"
    exit 1
fi

# Check if version increased
if ! compare_versions "$CURRENT_SEM_VER" "$BASE_SEM_VER"; then
    echo "::error::❌ New version must be greater than current version"
    echo "::error::Base: $BASE_VERSION | Current: $CURRENT_VERSION"
    exit 1
fi

echo "✅ Version properly incremented: $BASE_VERSION → $CURRENT_VERSION"

# Output for GitHub Actions
if [ -n "${GITHUB_OUTPUT:-}" ]; then
    echo "version=$CURRENT_SEM_VER" >> "$GITHUB_OUTPUT"
    echo "current=$CURRENT_VERSION" >> "$GITHUB_OUTPUT"
    echo "base=$BASE_VERSION" >> "$GITHUB_OUTPUT"
fi
