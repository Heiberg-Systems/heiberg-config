#!/usr/bin/env bash
LAYOUT_DIR="$HOME/.config/konsole/layout"
LAYOUTS=(heiberg-sandbox.json heiberg-eatingplan.json heiberg-personalwebsite.json heiberg-systemswebsite.json heiberg-idp.json heiberg-infrastructure.json heiberg-workoutplan.json heiberg.json)

BEFORE=$(wmctrl -l -x 2>/dev/null | grep -ci 'konsole')

konsole --layout "$LAYOUT_DIR/${LAYOUTS[0]}" &

# Wait for the new Konsole window to appear (up to 3s)
for i in $(seq 30); do
    sleep 0.1
    after=$(wmctrl -l -x 2>/dev/null | grep -ci 'konsole')
    [ "$after" -gt "$BEFORE" ] && break
done
sleep 0.3  # allow new window to gain focus

for layout in "${LAYOUTS[@]:1}"; do
    konsole --new-tab --layout "$LAYOUT_DIR/$layout"
done
