#!/bin/bash

# 图片文件夹位置
PICTURES_DIR="$(xdg-user-dir PICTURES)"
# 文件保存目录（默认是图片文件夹里的Screenshots文件夹）
SAVE_DIR="$PICTURES_DIR/Screenshots"

# 确保保存目录存在
mkdir -p "$SAVE_DIR"
# 动态生成文件名
FILE_NAME="$(date +'%Y-%m-%d-%H%M%S.png')"
# 保存文件的完整路径
SAVE_PATH="$SAVE_DIR/$FILE_NAME"
EDITED_SAVE_PATH="$SAVE_DIR/Edited-$FILE_NAME"

# 1.选择区域，如果取消则退出脚本。
SELECTION=$(slurp)
if [ -z "$SELECTION" ]; then
    exit 0
fi

# 2.用将slurp的区域传给grim进行截图，然后把grim的标准输出通过管道符传给tee的标准输入。tee把数据保存为文件的同时通过>(wl-copy)让系统分配一个“伪文件”让wl-copy读取它，由此传给剪贴板。（此时将源截图文件保存并复制到剪贴板）。
# 紧接着再用管道符把tee的stdout送到swappy的stdin进行编辑。

grim -g "$SELECTION" - | tee "$SAVE_PATH" >(wl-copy) | swappy -f - -o - | tee "$EDITED_SAVE_PATH" | wl-copy

# 3.创建指向最新文件的链接

ln -s $SAVE_PATH $SAVE_DIR/Latest
ln -s $EDITED_SAVE_PATH $SAVE_DIR/Edited-latest
