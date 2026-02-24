#!/usr/bin/env bash
set -euo pipefail

# RevenueCat dart-define launcher for local development.
# Usage examples:
#   RC_TEST_STORE_KEY=test_xxx bash scripts/run_with_revenuecat.sh
#   RC_ANDROID_PUBLIC_SDK_KEY=goog_xxx RC_IOS_PUBLIC_SDK_KEY=appl_xxx \
#     bash scripts/run_with_revenuecat.sh
#   RC_TEST_STORE_KEY=test_xxx bash scripts/run_with_revenuecat.sh -d emulator-5554

RC_ENTITLEMENT_CLOUD="${RC_ENTITLEMENT_CLOUD:-cloud}"
RC_ENTITLEMENT_REPORT="${RC_ENTITLEMENT_REPORT:-report}"
RC_OFFERING_CLOUD="${RC_OFFERING_CLOUD:-cloud}"
RC_OFFERING_REPORT="${RC_OFFERING_REPORT:-report}"

RC_ANDROID_PUBLIC_SDK_KEY="${RC_ANDROID_PUBLIC_SDK_KEY:-}"
RC_IOS_PUBLIC_SDK_KEY="${RC_IOS_PUBLIC_SDK_KEY:-}"
RC_TEST_STORE_KEY="${RC_TEST_STORE_KEY:-}"

if [[ -z "${RC_ANDROID_PUBLIC_SDK_KEY}" && -n "${RC_TEST_STORE_KEY}" ]]; then
  RC_ANDROID_PUBLIC_SDK_KEY="${RC_TEST_STORE_KEY}"
fi

if [[ -z "${RC_IOS_PUBLIC_SDK_KEY}" && -n "${RC_TEST_STORE_KEY}" ]]; then
  RC_IOS_PUBLIC_SDK_KEY="${RC_TEST_STORE_KEY}"
fi

if [[ -z "${RC_ANDROID_PUBLIC_SDK_KEY}" && -z "${RC_IOS_PUBLIC_SDK_KEY}" ]]; then
  cat <<'EOF'
RevenueCat SDK key is missing.

Set one of:
  RC_TEST_STORE_KEY=test_xxx
or:
  RC_ANDROID_PUBLIC_SDK_KEY=...
  RC_IOS_PUBLIC_SDK_KEY=...

Example:
  RC_TEST_STORE_KEY=test_xxx bash scripts/run_with_revenuecat.sh
EOF
  exit 1
fi

echo "Running Flutter with RevenueCat defines..."
echo "  RC_ENTITLEMENT_CLOUD=${RC_ENTITLEMENT_CLOUD}"
echo "  RC_ENTITLEMENT_REPORT=${RC_ENTITLEMENT_REPORT}"
echo "  RC_OFFERING_CLOUD=${RC_OFFERING_CLOUD}"
echo "  RC_OFFERING_REPORT=${RC_OFFERING_REPORT}"
if [[ -n "${RC_TEST_STORE_KEY}" ]]; then
  echo "  Using Test Store key fallback: yes"
fi

flutter run \
  --dart-define=RC_ANDROID_PUBLIC_SDK_KEY="${RC_ANDROID_PUBLIC_SDK_KEY}" \
  --dart-define=RC_IOS_PUBLIC_SDK_KEY="${RC_IOS_PUBLIC_SDK_KEY}" \
  --dart-define=RC_ENTITLEMENT_CLOUD="${RC_ENTITLEMENT_CLOUD}" \
  --dart-define=RC_ENTITLEMENT_REPORT="${RC_ENTITLEMENT_REPORT}" \
  --dart-define=RC_OFFERING_CLOUD="${RC_OFFERING_CLOUD}" \
  --dart-define=RC_OFFERING_REPORT="${RC_OFFERING_REPORT}" \
  "$@"
