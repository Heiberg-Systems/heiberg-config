#!/usr/bin/env bash
LAYOUT_DIR="$HOME/.config/konsole/layout"
PROJECTS=(sandbox eatingplan personalwebsite infrastructure workoutplan)

for p in "${PROJECTS[@]}"; do
  konsole --new-tab --layout "$LAYOUT_DIR/heiberg-${p}.json" &
done

wait
