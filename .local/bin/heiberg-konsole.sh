#!/usr/bin/env bash
LAYOUT_DIR="$HOME/.config/konsole/layout"
LAYOUTS=(heiberg-sandbox.json heiberg-eatingplan.json heiberg-personalwebsite.json heiberg-systemswebsite.json heiberg-idp.json heiberg-infrastructure.json heiberg-workoutplan.json heiberg.json)

konsole --layout "$LAYOUT_DIR/${LAYOUTS[0]}" &
KONSOLE_PID=$!

# Wait until this specific Konsole window appears (up to 5s)
for i in $(seq 50); do
    sleep 0.1
    wmctrl -l -p 2>/dev/null | awk '{print $3}' | grep -qx "$KONSOLE_PID" && break
done

for layout in "${LAYOUTS[@]:1}"; do
    konsole --new-tab --layout "$LAYOUT_DIR/$layout"
done
