#!/usr/bin/env bash
# Sports Gear Checkout — 127.0.0.1:4350
#   ./run.sh          start (idempotent)
#   ./run.sh stop     stop
#   ./run.sh status   status
#   ./run.sh restart  stop + start
#   ./run.sh test     smoke
set -euo pipefail
cd "$(dirname "$0")"
PORT="${PORT:-4350}"
PIDF=data/server.pid
LOG=data/server.log
mkdir -p data out

status() {
  if [[ -f "$PIDF" ]] && kill -0 "$(cat "$PIDF")" 2>/dev/null; then
    if curl -sf "http://127.0.0.1:$PORT/api/health" >/dev/null; then
      echo "running on http://127.0.0.1:$PORT/ (pid $(cat "$PIDF"))"
      return 0
    fi
  fi
  echo "not running"
  return 1
}

start() {
  if status >/dev/null 2>&1; then status; return 0; fi
  rm -f "$PIDF"
  # Free stale listener on this port only (cwd-scoped app)
  if command -v ss >/dev/null 2>&1; then
    pids=$(ss -ltnp "sport = :$PORT" 2>/dev/null | grep -oP 'pid=\K[0-9]+' || true)
    for p in $pids; do
      cwd=$(readlink -f "/proc/$p/cwd" 2>/dev/null || true)
      if [[ "$cwd" == "$(pwd)" ]]; then kill "$p" 2>/dev/null || true; fi
    done
  fi
  setsid nohup python3 server.py >>"$LOG" 2>&1 < /dev/null &
  echo $! > "$PIDF"
  for i in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
    if curl -sf "http://127.0.0.1:$PORT/api/health" >/dev/null; then
      status
      return 0
    fi
    sleep 0.2
  done
  echo "failed to start — see $LOG" >&2
  return 1
}

stop() {
  if [[ -f "$PIDF" ]]; then
    kill "$(cat "$PIDF")" 2>/dev/null || true
    rm -f "$PIDF"
  fi
  if command -v ss >/dev/null; then
    pid=$(ss -ltnp "sport = :$PORT" 2>/dev/null | sed -n 's/.*pid=\([0-9]*\).*/\1/p' | head -1 || true)
    if [[ -n "${pid:-}" ]]; then
      cwd=$(readlink -f "/proc/$pid/cwd" 2>/dev/null || true)
      if [[ "$cwd" == "$(pwd)" ]]; then kill "$pid" 2>/dev/null || true; fi
    fi
  fi
  echo stopped
}

case "${1:-start}" in
  start) start ;;
  stop) stop ;;
  restart) stop; start ;;
  status) status ;;
  test) start; bash smoke_test.sh ;;
  *) echo "usage: $0 start|stop|restart|status|test"; exit 2 ;;
esac
