#!/usr/bin/env bash
LAYOUT_DIR="$HOME/.config/konsole/layout"
LAYOUTS=(heiberg-sandbox.json heiberg-eatingplan.json heiberg-personalwebsite.json heiberg-systemswebsite.json heiberg-idp.json heiberg-infrastructure.json heiberg-workoutplan.json heiberg.json)

# Open first layout in a new Konsole window (no --new-tab)
konsole --layout "$LAYOUT_DIR/${LAYOUTS[0]}" &
sleep 1

# Add remaining layouts as tabs in that new window
for layout in "${LAYOUTS[@]:1}"; do
  konsole --new-tab --layout "$LAYOUT_DIR/$layout" &
  sleep 0.2
done

wait
