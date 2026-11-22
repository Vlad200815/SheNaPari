#!/usr/bin/env bash
# The demo: the backend on this Mac behind one permanent public address
# (an ngrok static domain), so the apps work from any network — the
# university's Wi-Fi, a phone's hotspot, mobile data — without a rebuild.
#
#   scripts/demo.sh          # backend (if not running) + the tunnel; Ctrl+C stops both
#
# Once: an ngrok account, `ngrok config add-authtoken <token>`, a free static
# domain (dashboard → Domains), and mobile/shenapari/env/demo.json with it
# (copy env/demo.example.json). Then build the apps with «SheNaPari (демо)» /
# «ШеНаПарі Кухня (демо)».
set -euo pipefail
cd "$(dirname "$0")/.."

CONFIG=mobile/shenapari/env/demo.json
PORT=5041
if [[ ! -f $CONFIG ]]; then
  echo "No $CONFIG: copy env/demo.example.json and put your ngrok domain in it." >&2
  exit 1
fi
URL=$(python3 -c "import json;print(json.load(open('$CONFIG'))['API_BASE_URL'])")
DOMAIN=${URL#https://}
DOMAIN=${DOMAIN%/}
if ! ngrok config check >/dev/null 2>&1; then
  echo "ngrok has no auth token yet: ngrok config add-authtoken <token>" >&2
  exit 1
fi

BACKEND_PID=
if lsof -nP -iTCP:$PORT -sTCP:LISTEN >/dev/null 2>&1; then
  echo "Backend already on :$PORT"
else
  echo "Starting the backend on :$PORT (log: backend/demo.log)…"
  dotnet run --project backend/src/ShenaPari.Api --launch-profile http > backend/demo.log 2>&1 &
  BACKEND_PID=$!
  for _ in $(seq 1 60); do
    curl -s -o /dev/null "http://localhost:$PORT/ping" && break
    sleep 1
  done
fi
trap '[[ -n $BACKEND_PID ]] && kill $BACKEND_PID 2>/dev/null' EXIT

echo "Public address: $URL"
ngrok http --url="$DOMAIN" $PORT
