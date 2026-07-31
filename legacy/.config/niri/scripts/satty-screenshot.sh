#!/usr/bin/env bash

# 声明一个变量，值是wl-paste输出的当前剪贴板的数据
CLIPNOW=$(wl-paste)

# 启动niri截图
niri msg action screenshot

# 循环，不断地打印当前剪贴板数据，和之间声明的变量里的数据进行对比，如果相等则循环继续，不相等则循环结束。
while [ "$(wl-paste)" = "$CLIPNOW" ]; do
  sleep .05
done

# 将新的剪贴板内容的数据传给satty打开
wl-paste | satty -f -
