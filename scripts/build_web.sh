#!/bin/bash
set -e

SOURCE_DIR="cdda-source"
OUTPUT_DIR="web-output"

echo "Starting CDDA WebAssembly build using official build scripts..."

# Build configuration
BUILD_TYPE="${BUILD_TYPE:-Release}"
BUILD_TILES="${BUILD_TILES:-true}"
BUILD_SOUND="${BUILD_SOUND:-true}"
BUILD_LOCALIZATION="${BUILD_LOCALIZATION:-false}"

echo "Build configuration:"
echo "  Type: $BUILD_TYPE"
echo "  Tiles: $BUILD_TILES"
echo "  Sound: $BUILD_SOUND"
echo "  Localization: $BUILD_LOCALIZATION"

# Use absolute path for source directory
SOURCE_ABS_PATH="$(pwd)/$SOURCE_DIR"
echo "Source directory: $SOURCE_ABS_PATH"

# Verify source directory exists
if [ ! -d "$SOURCE_ABS_PATH" ]; then
  echo "Error: Source directory not found at $SOURCE_ABS_PATH"
  exit 1
fi

# Change to source directory to use official build scripts
cd "$SOURCE_ABS_PATH"

# Check if official Emscripten build scripts exist
if [ ! -f "build-scripts/build-emscripten.sh" ]; then
  echo "Error: CDDA official Emscripten build script not found"
  echo "This version of CDDA may not include WebAssembly support"
  exit 1
fi

echo "Using official CDDA Emscripten build scripts..."

# Run the official build scripts
echo "Preparing web data..."
if [ -f "build-scripts/prepare-web-data.sh" ]; then
  chmod +x build-scripts/prepare-web-data.sh
  ./build-scripts/prepare-web-data.sh
else
  echo "Warning: prepare-web-data.sh not found, skipping..."
fi

echo "Building with Emscripten..."
chmod +x build-scripts/build-emscripten.sh
./build-scripts/build-emscripten.sh

echo "Preparing web bundle..."
if [ -f "build-scripts/prepare-web.sh" ]; then
  chmod +x build-scripts/prepare-web.sh
  ./build-scripts/prepare-web.sh
else
  echo "Warning: prepare-web.sh not found, skipping..."
fi

# Find the web output directory
WEB_OUTPUT_DIR=$(find "$SOURCE_ABS_PATH" -type d -name "web" | head -n1)
if [ -z "$WEB_OUTPUT_DIR" ]; then
  echo "Error: Could not find web output directory"
  exit 1
fi

echo "Found web output directory: $WEB_OUTPUT_DIR"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Copy web output files
echo "Copying web output files..."
cp -r "$WEB_OUTPUT_DIR"/* "$OUTPUT_DIR/"

echo "Build completed successfully!"
echo "Web output prepared in: $OUTPUT_DIR"
