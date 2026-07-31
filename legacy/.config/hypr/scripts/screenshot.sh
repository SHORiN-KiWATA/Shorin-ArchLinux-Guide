#!/bin/bash
PICTURES_DIR="$(xdg-user-dir PICTURES)"
SAVE_DIR="$PICTURES_DIR/Screenshots"
FILE_NAME="$(date +'%Y-%m-%d-%H%M%S.png')"
SAVE_PATH="$SAVE_DIR/$FILE_NAME"

mkdir -p "$SAVE_DIR"
grim -g "$(slurp)" - | tee $SAVE_PATH >(wl-copy)

