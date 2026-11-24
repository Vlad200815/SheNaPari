#!/usr/bin/env bash
# The demo: the backend on this Mac behind one permanent public address
# (an ngrok static domain), so the apps work from any network — the
# university's Wi-Fi, a phone's hotspot, mobile data — without a rebuild.
#
#   scripts/demo.sh          # backend (if not running) + the tunnel + sign-in codes;
#                            # Ctrl+C stops both
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
# ngrok runs in the background: its full-screen view would wipe anything
# printed over it. This window shows the address and the sign-in codes
# instead; the request list is still at http://127.0.0.1:4040.
ngrok http --url="$DOMAIN" $PORT --log=stdout > backend/ngrok.log 2>&1 &
NGROK_PID=$!
trap 'kill $NGROK_PID 2>/dev/null; [[ -n $BACKEND_PID ]] && kill $BACKEND_PID 2>/dev/null' EXIT

for _ in $(seq 1 20); do
  curl -s http://127.0.0.1:4040/api/tunnels | grep -q "$DOMAIN" && break
  if ! kill -0 $NGROK_PID 2>/dev/null; then
    echo "ngrok stopped, see backend/ngrok.log:" >&2
    tail -5 backend/ngrok.log >&2
    exit 1
  fi
  sleep 1
done

echo
echo "Public address: $URL"
echo "Requests:       http://127.0.0.1:4040"
if [[ -z $BACKEND_PID ]]; then
  echo "(The backend was already running, so its codes go to its own console.)"
fi
echo "Sign-in codes appear below. Ctrl+C stops everything."
echo
touch backend/demo.log
tail -n 0 -f backend/demo.log | grep --line-buffered "SMS to"
