#!/usr/bin/env bash
set -euo pipefail

# Firebase / FlutterFire bootstrap helper for this repository.
# This script is idempotent for repeated setup on a new machine.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "[1/5] Checking flutter"
flutter --version >/dev/null

echo "[2/5] Checking Firebase CLI"
if ! command -v firebase >/dev/null 2>&1; then
  echo "Firebase CLI not found. Install with: npm install -g firebase-tools"
  exit 1
fi

echo "[3/5] Checking FlutterFire CLI"
if ! command -v flutterfire >/dev/null 2>&1; then
  echo "FlutterFire CLI not found. Install with:"
  echo "  dart pub global activate flutterfire_cli"
  echo "If needed, add to PATH:"
  echo "  export PATH=\"\$PATH:\$HOME/.pub-cache/bin\""
  exit 1
fi

echo "[4/5] Ensuring dependencies"
flutter pub get

echo "[5/5] Running FlutterFire configure"
echo "You may be prompted to select a Firebase project and platforms."
flutterfire configure

echo
echo "Done. Verify generated file:"
echo "  lib/firebase_options.dart"
echo "Then run:"
echo "  flutter run"

