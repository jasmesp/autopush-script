#!/bin/bash

WATCH_DIR="."                      # Directory to watch
PUSH_INTERVAL=300                  # 5 minutes
TMP_FLAG=".pending_push"          # Marker for pending changes
LOG_PREFIX="[autocommit]"

cd "$WATCH_DIR" || exit 1
rm -f "$TMP_FLAG"

# Log function
log() {
  echo "$LOG_PREFIX $(date '+%H:%M:%S') — $1"
}

# Background: watch for changes and commit them
fswatch -0 -r "$WATCH_DIR" | while IFS= read -r -d "" file; do
  RELFILE="${file#./}"

  # Ignore certain patterns
  [[ "$RELFILE" == .git/* ]] && continue
  [[ "$RELFILE" == *.swp || "$RELFILE" == *.tmp || "$RELFILE" == *.DS_Store ]] && continue

  # Commit the change
  git add "$RELFILE" >/dev/null 2>&1
  git commit -m "Auto-commit: $RELFILE at $(date '+%Y-%m-%d %H:%M:%S')" >/dev/null 2>&1 && \
    log "Committed $RELFILE"

  touch "$TMP_FLAG"
done &
FSWATCH_PID=$!

# Background: push every $PUSH_INTERVAL if changes happened
while true; do
  sleep "$PUSH_INTERVAL"
  if [ -f "$TMP_FLAG" ]; then
    log "Pushing batched commits..."
    git push
    rm -f "$TMP_FLAG"
  else
    log "No new commits to push."
  fi
done

cleanup() {
  log 'Shutting down'
  kill $FSWATCH_PID 2>/dev/null
  exit
}
trap cleanup INT TERM EXIT