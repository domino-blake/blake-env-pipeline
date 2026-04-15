#!/usr/bin/env bash
# Usage: DOMINO_API_HOST=https://... DOMINO_API_KEY=... DOMINO_ENVIRONMENT_ID=... bash test_api.sh
set -euo pipefail

: "${DOMINO_API_HOST:?set DOMINO_API_HOST}"
: "${DOMINO_API_KEY:?set DOMINO_API_KEY}"
: "${DOMINO_ENVIRONMENT_ID:?set DOMINO_ENVIRONMENT_ID}"

WHEEL_URL="${WHEEL_URL:-https://github.com/domino-blake/blake-env-pipeline/releases/download/v0.17.0/demo_pkg-0.17.0-py3-none-any.whl}"

echo "=== Step 1: Get latest revision ID ==="
curl --silent \
  --url "$DOMINO_API_HOST/api/environments/v1/environments/$DOMINO_ENVIRONMENT_ID" \
  --header "X-Domino-Api-Key: $DOMINO_API_KEY" \
  --output /tmp/env.json
LATEST_REVISION_ID=$(python3 -c "import json; data=json.load(open('/tmp/env.json')); print(data['environment']['latestRevision']['id'])")
echo "Latest revision ID: $LATEST_REVISION_ID"

echo ""
echo "=== Step 2: Create new revision (following active revision of env) ==="
PAYLOAD=$(python3 -c "
import json
print(json.dumps({
  'newEnvironmentRevision': {
    'supportsPackagePersistence': True,
    'baseRevision': {'followActiveRevisionOf': '$DOMINO_ENVIRONMENT_ID'},
    'workspaceTools': '',
    'supportedClusters': [],
    'dockerfileInstructions': 'RUN pip install --no-cache-dir $WHEEL_URL',
    'environmentVariables': {},
    'preSetupScript': '',
    'postSetupScript': '',
    'preRunScript': '',
    'postRunScript': '',
    'dockerArguments': [],
    'summary': '',
    'skipCache': False,
    'shouldUseVpn': False
  }
}))
")
echo "Payload: $PAYLOAD"

HTTP_STATUS=$(curl --silent --output /tmp/post.json --write-out "%{http_code}" \
  --request POST \
  --url "$DOMINO_API_HOST/v4/environments/$DOMINO_ENVIRONMENT_ID/environmentRevision" \
  --header "X-Domino-Api-Key: $DOMINO_API_KEY" \
  --header "Content-Type: application/json" \
  --data "$PAYLOAD")

echo "HTTP status: $HTTP_STATUS"
cat /tmp/post.json | python3 -m json.tool
