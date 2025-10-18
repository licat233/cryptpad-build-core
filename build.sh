#!/usr/bin/env bash

set -euo pipefail

# 脚本所在目录（项目根）
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

mkdir -p cryptpad

# 可配置变量（不要硬编码路径）
PROJECT_DIR="$SCRIPT_DIR/cryptpad"
ONLYOFFICE_CONF_DIR="$PROJECT_DIR/onlyoffice-conf"
OO_DIST="$PROJECT_DIR/www/common/onlyoffice/dist"
ONLYOFFICE_PREPARED_DIR="$SCRIPT_DIR/onlyoffice"

# 克隆 CryptPad 存储库
unzip cryptpad.zip

# 进入 CryptPad 目录
cd cryptpad

# 切换到指定的版本分支
git checkout 2025.6.0

# 安装依赖项
npm ci
npm run install:components

## 安装 OnlyOffice 编辑器
#  创建目录和配置文件
mkdir -p "$ONLYOFFICE_CONF_DIR"
mkdir -p "$OO_DIST"

# 获取旧版本（v1, v2b, v4, v5, v6）——使用 onlyoffice-builds bare 仓库 + git worktree
cd "$ONLYOFFICE_CONF_DIR"
unzip "$ONLYOFFICE_PREPARED_DIR/onlyoffice-builds.git.zip"

# 然后对每个旧版本用对应 commit 检出到目标目录（示例列出 v1、v2b、v4、v5、v6 的命令；替换 commit 即可）：

# v1 (commit 4f370beb)
cd "$ONLYOFFICE_CONF_DIR/onlyoffice-builds.git"
git worktree add "$OO_DIST/v1" 4f370beb

# v2b (commit d9da72fd)
git worktree add "$OO_DIST/v2b" d9da72fd

# v4 (commit 6ebc6938)
git worktree add "$OO_DIST/v4" 6ebc6938

# v5 (commit 88a356f0)
git worktree add "$OO_DIST/v5" 88a356f0

# v6 (commit abd8a309)
git worktree add "$OO_DIST/v6" abd8a309

# 移除每个版本中不需要的 help/dictionaries
rm -rf "$OO_DIST/v1/web-apps/apps"/*/main/resources/help
rm -rf "$OO_DIST/v7/dictionaries"  # 如果存在

# 安装 v7
mkdir -p "$OO_DIST/v7"
cd "$OO_DIST/v7"
# 复制预先准备好的 onlyoffice-editor-v7.zip 到当前目录（预备文件位于脚本同级目录的 sibling onlyoffice 文件夹）
cp "$ONLYOFFICE_PREPARED_DIR/onlyoffice-editor-v7.zip" .
unzip onlyoffice-editor-v7.zip
rm onlyoffice-editor-v7.zip*
echo "v7.3.3.60+11" > ./.version

# 安装 v8
mkdir -p "$OO_DIST/v8"
cd "$OO_DIST/v8"
# 复制预先准备好的 onlyoffice-editor-v8.zip 到当前目录
cp "$ONLYOFFICE_PREPARED_DIR/onlyoffice-editor-v8.zip" .
unzip onlyoffice-editor-v8.zip
rm onlyoffice-editor-v8.zip*
echo "v8.3.3.23+4" > ./.version

# 安装 x2t wasm 包
mkdir -p "$OO_DIST/x2t"
cd "$OO_DIST/x2t"
# 复制预先准备好的 x2t.zip 到当前目录
cp "$ONLYOFFICE_PREPARED_DIR/x2t.zip" .
unzip x2t.zip
rm x2t.zip*
echo "v7.3+1" > ./.version

# 复制配置文件
cd "$PROJECT_DIR"
cp config/config.example.js config/config.js

mkdir -p customize
cp -r www/common/application_config_internal.js customize/application_config.js

# 条件安装
local METHOD=$1
if [ "$METHOD" == "docker" ]; then
    sed -i "s@//httpAddress: 'localhost'@httpAddress: '0.0.0.0'@" "$PROJECT_DIR/config/config.js"
    sed -i "s@installMethod: 'unspecified'@installMethod: 'docker'@" "$PROJECT_DIR/config/config.js"
else
    
fi

# 完成提示
echo "================ CryptPad 和 OnlyOffice 编辑器安装完成 ================"
# ...existing code...

