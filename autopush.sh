#!/bin/bash

WATCH_DIR="."                      # Directory to watch
PUSH_INTERVAL=300                  # 5 minutes
TMP_FLAG="/tmp/autopush_pending_$(basename "$PWD")"

rm -f .git/index.lock .git/HEAD.lock .git/packed-refs.lock .git/AUTO_MERGE.lock 2>/dev/null

cd "$WATCH_DIR" || exit 1
echo "memory-watch running (PID $$). Ctrl-C to stop."
rm -f "$TMP_FLAG"

# Log function
log() {
  echo "$LOG_PREFIX $(date '+%H:%M:%S') — $1"
}

# Background: watch for changes and commit them
fswatch -0 -r --exclude '\.git' --exclude 'tmp_obj_' --exclude '\.lock$' "$WATCH_DIR" | while IFS= read -r -d "" file; do
  [[ "$file" == *".git/"* ]] || [[ "$file" == *"tmp_obj_"* ]] || [[ "$file" == *.lock ]] && continue

  # Skip if it's a directory
  if [ -d "$file" ]; then
    log "Skipping directory: $file"
    continue
  fi

  RELFILE="${file#./}"

  # Ignore temp/internal files
  if [[ "$RELFILE" == .git/* ]] || [[ "$RELFILE" == *.swp ]] || [[ "$RELFILE" == *.tmp ]] || \
     [[ "$RELFILE" == *.DS_Store ]] || [[ "$RELFILE" == tmp_obj_* ]] || [[ "$RELFILE" == *.lock ]] || \
     [[ "$RELFILE" == "$(basename "$TMP_FLAG")" ]] || [[ "$RELFILE" == "autopush-errors.log" ]]; then
    log "Ignoring temp/internal file: $RELFILE"
    continue
  fi

  # Commit the change
  if git add "$RELFILE" >/dev/null 2>&1 && \
     git commit -m "auto: $(basename "$RELFILE") $(date '+%F %T')" >/dev/null 2>&1; then
    echo "Committed $(basename "$RELFILE") at $(date '+%H:%M:%S')"
    touch "$TMP_FLAG"
  fi

done &
FSWATCH_PID=$!

# Background: push every $PUSH_INTERVAL if changes happened
while true; do
  sleep "$PUSH_INTERVAL"
  if [[ -e "$TMP_FLAG" ]]; then
    if git push; then
      echo "Pushed at $(date '+%H:%M:%S')"
    else
      log "❌ Push failed — check autopush-errors.log for details"
    fi
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