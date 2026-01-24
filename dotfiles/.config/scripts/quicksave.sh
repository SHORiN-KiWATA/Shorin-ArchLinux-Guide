#!/bin/bash

# 提权但是使用here-doc，不显示代码内容
if pkexec bash << 'EOF'; then
    snapper -c root create --description "quicksave" --cleanup-algorithm number
    snapper -c root cleanup number
    snapper -c home create --description "quicksave" --cleanup-algorithm number
    snapper -c home cleanup number
EOF
    notify-send "Quicksaved: Success"
else
    notify-send -u critical "Quicksaved: Failed!"
fi
