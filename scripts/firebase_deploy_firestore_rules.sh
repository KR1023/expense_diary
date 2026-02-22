#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if ! command -v firebase >/dev/null 2>&1; then
  echo "Firebase CLI not found. Install with: npm install -g firebase-tools"
  exit 1
fi

if [[ ! -f "firestore.rules" ]]; then
  echo "firestore.rules not found in repo root."
  exit 1
fi

PROJECT_ID="${1:-}"

if [[ -n "$PROJECT_ID" ]]; then
  echo "Selecting Firebase project: $PROJECT_ID"
  firebase use "$PROJECT_ID"
else
  echo "No project ID passed. Using current Firebase CLI active project."
  echo "Tip: ./scripts/firebase_deploy_firestore_rules.sh <project-id>"
fi

echo "Deploying Firestore rules from firebase.json -> firestore.rules"
firebase deploy --only firestore:rules

echo "Done."

