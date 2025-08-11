#!/bin/bash
# filter-wrapper.sh - Smudge-only version (uses $FIDO2_PIN if set)

get_pin() {
    # If PIN is set in environment, use it
    if [ -n "${FIDO2_PIN:-}" ]; then
        echo "$FIDO2_PIN"
        return
    fi

    # Otherwise, ask via pinentry
    pin=$(pinentry-gtk-2 --title "FIDO2 PIN" --description "Bitte gib deinen FIDO2-PIN ein." <<EOF | grep ^D | cut -c3-
GETPIN
EOF
)
    echo "$pin"
}

# Since this is smudge-only, we only decrypt
PIN=$(get_pin)
if [ -z "$PIN" ]; then
    # If no PIN, pass through unchanged (encrypted)
    cat
    exit 0
fi

# Decrypt the content
./fido2-derive --mode=dec --pin="$PIN"

