#!/usr/bin/env bash
LAYOUT_DIR="$HOME/.config/konsole/layout"
LAYOUTS=(heiberg-sandbox.json heiberg-eatingplan.json heiberg-personalwebsite.json heiberg-systemswebsite.json heiberg-idp.json heiberg-infrastructure.json heiberg-workoutplan.json heiberg-tally.json heiberg-stay.json heiberg-testjourneys.json heiberg.json)

BEFORE_IDS=$(wmctrl -l -x 2>/dev/null | grep -i 'konsole' | awk '{print $1}' | sort)

konsole --layout "$LAYOUT_DIR/${LAYOUTS[0]}" &

# Wait for the new Konsole window and capture its ID
NEW_WIN=""
for i in $(seq 30); do
    sleep 0.1
    CURRENT_IDS=$(wmctrl -l -x 2>/dev/null | grep -i 'konsole' | awk '{print $1}' | sort)
    if [ -n "$BEFORE_IDS" ]; then
        NEW_WIN=$(comm -13 <(echo "$BEFORE_IDS") <(echo "$CURRENT_IDS") | head -1)
    else
        NEW_WIN=$(echo "$CURRENT_IDS" | head -1)
    fi
    [ -n "$NEW_WIN" ] && break
done

# Focus the new window so --new-tab targets it, not an existing Konsole window
[ -n "$NEW_WIN" ] && wmctrl -i -a "$NEW_WIN"
sleep 0.3

for layout in "${LAYOUTS[@]:1}"; do
    konsole --new-tab --layout "$LAYOUT_DIR/$layout"
done
