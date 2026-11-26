#!/bin/bash
# 双击这个文件：重新生成进度页并在浏览器里打开
cd "$(dirname "$0")" || exit 1
python3 scripts/progress.py && open "进行中.html"
