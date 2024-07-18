#!/bin/bash

# Define the Dockerfile path
DOCKERFILE="Dockerfile"

# Extract the SWIPL_VERSION from the Dockerfile using sed
SWIPL_VERSION=$(sed -n 's/^.*SWIPL_VERSION=\([^ ]*\).*$/\1/p' "$DOCKERFILE")

# Extract the Java Lambda Image version from the Dockerfile using sed
LAMBDA_VERSION=$(sed -n 's/^.*JAVA_VERSION=\([^ ]*\).*$/\1/p' "$DOCKERFILE")

# Concatenate the versions
VERSION="${SWIPL_VERSION}-java${LAMBDA_VERSION}"

# Output the concatenated version
echo "$VERSION"