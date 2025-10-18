#!/usr/bin/env bash

set -euo pipefail

# 脚本所在目录（项目根）
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)
mkdir -p "$SCRIPT_DIR/downloads"
cd "$SCRIPT_DIR/downloads"

# 下载criptpad.zip
# 如果不存在，则下载
if [ ! -f "$SCRIPT_DIR/downloads/cryptpad.zip" ]; then
    git clone -b 2025.6.0 --depth 1 https://github.com/cryptpad/cryptpad.git "$SCRIPT_DIR/downloads/cryptpad";
    zip -r "cryptpad.zip" "cryptpad"
fi 

if [ ! -f "$SCRIPT_DIR/downloads/onlyoffice-builds.zip" ]; then
    git clone --bare https://github.com/cryptpad/onlyoffice-builds.git "$SCRIPT_DIR/downloads/onlyoffice-builds"
    zip -r "onlyoffice-builds.zip" "onlyoffice-builds"
fi

if [ ! -f "$SCRIPT_DIR/downloads/onlyoffice-editor-v7.zip" ]; then
    curl "https://github.com/cryptpad/onlyoffice-editor/releases/download/v7.3.3.60+11/onlyoffice-editor.zip" --location --output "$SCRIPT_DIR/downloads/onlyoffice-editor-v7.zip";
fi

if [ ! -f "$SCRIPT_DIR/downloads/onlyoffice-editor-v8.zip" ]; then
    curl "https://github.com/cryptpad/onlyoffice-editor/releases/download/v8.3.3.23+4/onlyoffice-editor.zip" --location --output "$SCRIPT_DIR/downloads/onlyoffice-editor-v8.zip";
fi

if [ ! -f "$SCRIPT_DIR/downloads/x2t.zip" ]; then
    curl "https://github.com/cryptpad/onlyoffice-x2t-wasm/releases/download/v7.3+1/x2t.zip" --location --output "$SCRIPT_DIR/downloads/x2t.zip";
fi

if [ ! -f "$SCRIPT_DIR/downloads/onlyoffice-editor-latest.zip" ]; then
    curl "https://github.com/cryptpad/onlyoffice-editor/releases/download/v8.3.3.23+5/onlyoffice-editor.zip" --location --output "$SCRIPT_DIR/downloads/onlyoffice-editor-latest.zip";
fi 


echo "所有文件已下载到 $SCRIPT_DIR/downloads 目录下。";