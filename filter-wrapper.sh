o#!/bin/bash

PIN_FILE="/tmp/fido2_pin_cache"

get_pin() {
  if [ -f "$PIN_FILE" ]; then
    cat "$PIN_FILE"
    return
  fi

  pin=$(pinentry-gtk-2 --title "FIDO2 PIN" --description "Bitte gib deinen FIDO2-PIN ein." <<EOF | grep ^D | cut -c3-
GETPIN
EOF
)
  if [ -n "$pin" ]; then
    echo "$pin" > "$PIN_FILE"
  fi
  echo "$pin"
}

if [ $# -ne 1 ]; then
  echo "Usage: $0 [encrypt|decrypt]" >&2
  exit 1
fi

MODE=$1
PIN=$(get_pin)

if [ -z "$PIN" ]; then
  echo "No PIN provided, aborting." >&2
  exit 1
fi

if [ "$MODE" = "encrypt" ]; then
  ./fido2-derive --mode=enc --pin="$PIN"
elif [ "$MODE" = "decrypt" ]; then
  ./fido2-derive --mode=dec --pin="$PIN"
else
  echo "Invalid mode: $MODE" >&2
  exit 1
fi


