#!/usr/bin/env bash

set -euo pipefail

# 脚本所在目录（项目根）
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

# 可配置变量（不要硬编码路径）
PROJECT_DIR="$SCRIPT_DIR/cryptpad"
ONLYOFFICE_CONF_DIR="$PROJECT_DIR/onlyoffice-conf"
OO_DIST="$PROJECT_DIR/www/common/onlyoffice/dist"
DOWNLOADS_DIR="$SCRIPT_DIR/downloads"
INSTALL_METHOD=unspecified  # 默认安装方法
if [ $# -ge 1 ]; then
    INSTALL_METHOD="$1"
fi
RUN_FUNC="main" # 默认执行主函数
if [ $# -ge 2 ]; then
    RUN_FUNC="$2"
fi

init(){
    case "$RUN_FUNC" in
        "main")
            main "$@"
            ;;
        "auto_config")
            auto_config
            ;;
        "install_cryptpad")
            install_cryptpad
            ;;
        "install_onlyoffice")
            install_onlyoffice
            ;;
        "install_node_modules")
            install_node_modules
            ;;
        *)
            main "$@"
            ;;
    esac
}

main(){
    
    install_cryptpad

    auto_config

    install_onlyoffice

    install_node_modules

    # 完成提示
    echo "=================== 全 部 安 装 完 成 ==================="
}

auto_config(){
    cd "$PROJECT_DIR"
    update_application_config
    echo ""
    update_config_js
    echo ""
    update_customize_pages
    echo "" 
    update_customize_pages_index
    echo "" 
    update_common_ui_elements
    echo "" 
    update_onlyoffice_inner
    echo "" 
    echo "********** 代码已全部配置完成 **********"
}


update_onlyoffice_inner(){
    local INNER_PATH="$PROJECT_DIR/www/common/onlyoffice/inner.js"
    local old_str="if (!privateData.isEmbed) {"
    local new_str="if (false\&\&!privateData.isEmbed) {"
    replace_text "$INNER_PATH" "$old_str" "$new_str"
    echo ""
    echo "*************** /www/common/onlyoffice/inner.js 更改完成 ***************"
}

update_common_ui_elements(){
    local UI_ELEMENTS_PATH="$PROJECT_DIR/www/common/common-ui-elements.js"
    local old_str="var todo = function () {"
    local new_str="var todo = function (e) {crowdfundingState = true;return;"
    replace_text "$UI_ELEMENTS_PATH" "$old_str" "$new_str"
    local old_str="'class': 'cp-toolbar-about fa fa-info',"
    local new_str="'hidden':true,'class': 'cp-toolbar-about fa fa-info'"
    replace_text "$UI_ELEMENTS_PATH" "$old_str" "$new_str"
    local old_str="'href': 'https://docs.cryptpad.org',"
    local new_str="'hidden':true,'href': '/',"
    replace_text "$UI_ELEMENTS_PATH" "$old_str" "$new_str"
    echo ""
    echo "*************** www/common/common-ui-elements.js 更改完成 ***************"
}

update_customize_pages_index(){
    local INDEX_PATH="$PROJECT_DIR/customize.dist/pages/index.js"
    local old_str="h('a', {href:\"/contact.html\"}, Msg.contact),"
    local new_str="h('a', {href:\"/contact.html\",hidden:true}, Msg.contact),"
    replace_text "$INDEX_PATH" "$old_str" "$new_str"

    echo ""
    echo "*************** customize.dist/pages/index.js 更改完成 ***************"
}

update_customize_pages(){
    local PAGES_PATH="$PROJECT_DIR/customize.dist/pages.js"
    local old_str="Pages.infopageFooter = function () {"
    local new_str="Pages.infopageFooter = function (e) { return null;"
    replace_text "$PAGES_PATH" "$old_str" "$new_str"
    local old_str2="h('a.nav-item.nav-link', { href: 'https://docs.cryptpad.org'},"
    local new_str2="h('a.nav-item.nav-link', { href: 'https://docs.cryptpad.org', hidden: true},"
    replace_text "$PAGES_PATH" "$old_str2" "$new_str2"

    echo ""
    echo "*************** customize.dist/pages.js 更改完成 ***************"
}

update_application_config(){
    local APP_CONF_PATH="$PROJECT_DIR/www/common/application_config_internal.js"
    # 定义要替换的旧内容和新内容
    local OLD_STR="return AppConfig;"

    local NEW_STR="AppConfig.availableLanguages = ['zh', 'en']; try { var LS_LANG = 'CRYPTPAD_LANG'; var defaultLang = 'zh'; if (!localStorage.getItem(LS_LANG)) { localStorage.setItem(LS_LANG, defaultLang); } } catch (error) { console.error('设置默认中文语言出错：', error); } AppConfig.loginSalt = 'licat2333'; AppConfig.registeredOnlyTypes = AppConfig.availablePadTypes; return AppConfig"

    # 调用替换函数（文件路径替换为你的实际文件路径）
    replace_text "$APP_CONF_PATH" "$OLD_STR" "$NEW_STR"

    mkdir -p "$PROJECT_DIR/customize"
    cp -f "$PROJECT_DIR/www/common/application_config_internal.js" "$PROJECT_DIR/customize/application_config.js"

    echo ""
    echo "*************** /www/common/application_config_internal.js 更改完成 ***************"
}

update_config_js(){
    local CONFIG_PATH="$PROJECT_DIR/config/config.example.js"
    # 定义要替换的旧内容和新内容
    if [ "$INSTALL_METHOD" == "docker" ]; then
        replace_text "$CONFIG_PATH" "//httpAddress: 'localhost'" "httpAddress: '0.0.0.0'"
        replace_text "$CONFIG_PATH" "installMethod: 'unspecified'," "removeDonateButton: true,installMethod: 'docker',"
    else
        replace_text "$CONFIG_PATH" "installMethod: 'unspecified'," "removeDonateButton: true,installMethod: 'unspecified'"
    fi

    cp -f "$PROJECT_DIR/config/config.example.js" "$PROJECT_DIR/config/config.js"

    echo "*************** /config/config.example.js 更改完成 ***************"
}

# 安装 CryptPad
install_cryptpad() {
    cd "$SCRIPT_DIR"
    # 清空目录，谨慎，建议保留用户数据
    # rm -rf "$SCRIPT_DIR/cryptpad/"
    # 解压并覆盖
    unzip -o "$DOWNLOADS_DIR/cryptpad.zip"
    # 重命名目录
    # mv  "$SCRIPT_DIR/cryptpad-2025.6.0" "$SCRIPT_DIR/cryptpad"
    # 进入 CryptPad 目录
    cd cryptpad

    # 切换到指定的版本分支
    git checkout 2025.6.0
    mkdir -p data/{blob,block,data,files} customize onlyoffice-dist onlyoffice-conf
    echo "*************** CryptPad 安装完成 ***************"
}

## 安装 OnlyOffice 编辑器
install_onlyoffice() {
    cd "$PROJECT_DIR"
    #  创建目录和配置文件
    mkdir -p "$ONLYOFFICE_CONF_DIR"
    mkdir -p "$OO_DIST"

    # 获取旧版本（v1, v2b, v4, v5, v6）——使用 onlyoffice-builds bare 仓库 + git worktree
    cd "$ONLYOFFICE_CONF_DIR"
    if [ -d "$ONLYOFFICE_CONF_DIR/onlyoffice-builds" ]; then
        rm -rf "$ONLYOFFICE_CONF_DIR/onlyoffice-builds"
    fi
    unzip -o "$DOWNLOADS_DIR/onlyoffice-builds.zip"

    # 然后对每个旧版本用对应 commit 检出到目标目录（示例列出 v1、v2b、v4、v5、v6 的命令；替换 commit 即可）：
    cd "$ONLYOFFICE_CONF_DIR/onlyoffice-builds"

    # v1 (commit 4f370beb)
    # 如果目标目录已存在，则先删除以避免冲突
    if [ -d "$OO_DIST/v1" ]; then
        rm -rf "$OO_DIST/v1"
    fi
    git worktree add -f "$OO_DIST/v1" 4f370beb
    echo "4f370beb" > "$OO_DIST/v1/.commit"
    # 移除版本中不需要的 help/dictionaries
    rm -rf "$OO_DIST/v1/web-apps/apps/documenteditor/main/resources/help"
    rm -rf "$OO_DIST/v1/web-apps/apps/presentationeditor/main/resources/help" 
    rm -rf "$OO_DIST/v1/web-apps/apps/spreadsheeteditor/main/resources/help"

    # v2b (commit d9da72fd)
    # 如果目标目录已存在，则先删除以避免冲突
    if [ -d "$OO_DIST/v2b" ]; then
        rm -rf "$OO_DIST/v2b"
    fi
    git worktree add -f "$OO_DIST/v2b" d9da72fd
    echo "d9da72fd" > "$OO_DIST/v2b/.commit"
    # 移除版本中不需要的 help/dictionaries
    rm -rf "$OO_DIST/v2b/web-apps/apps/documenteditor/main/resources/help"
    rm -rf "$OO_DIST/v2b/web-apps/apps/presentationeditor/main/resources/help" 
    rm -rf "$OO_DIST/v2b/web-apps/apps/spreadsheeteditor/main/resources/help"

    # v4 (commit 6ebc6938)
    # 如果目标目录已存在，则先删除以避免冲突
    if [ -d "$OO_DIST/v4" ]; then
        rm -rf "$OO_DIST/v4"
    fi
    git worktree add -f "$OO_DIST/v4" 6ebc6938
    echo "6ebc6938" > "$OO_DIST/v4/.commit"
    # 移除版本中不需要的 help/dictionaries
    rm -rf "$OO_DIST/v4/web-apps/apps/documenteditor/main/resources/help"
    rm -rf "$OO_DIST/v4/web-apps/apps/presentationeditor/main/resources/help" 
    rm -rf "$OO_DIST/v4/web-apps/apps/spreadsheeteditor/main/resources/help"

    # v5 (commit 88a356f0)
    # 如果目标目录已存在，则先删除以避免冲突
    if [ -d "$OO_DIST/v5" ]; then
        rm -rf "$OO_DIST/v5"
    fi
    git worktree add -f "$OO_DIST/v5" 88a356f0
    echo "88a356f0" > "$OO_DIST/v5/.commit"
    # 移除版本中不需要的 help/dictionaries
    rm -rf "$OO_DIST/v5/web-apps/apps/documenteditor/main/resources/help"
    rm -rf "$OO_DIST/v5/web-apps/apps/presentationeditor/main/resources/help" 
    rm -rf "$OO_DIST/v5/web-apps/apps/spreadsheeteditor/main/resources/help"

    # v6 (commit abd8a309)
    # 如果目标目录已存在，则先删除以避免冲突
    if [ -d "$OO_DIST/v6" ]; then
        rm -rf "$OO_DIST/v6"
    fi
    git worktree add -f "$OO_DIST/v6" abd8a309
    echo "abd8a309" > "$OO_DIST/v6/.commit"
    # 移除版本中不需要的 help/dictionaries
    rm -rf "$OO_DIST/v6/web-apps/apps/documenteditor/main/resources/help"
    rm -rf "$OO_DIST/v6/web-apps/apps/presentationeditor/main/resources/help" 
    rm -rf "$OO_DIST/v6/web-apps/apps/spreadsheeteditor/main/resources/help"

    # 安装 v7
    # 如果目标目录已存在，则先删除以避免冲突
    if [ -d "$OO_DIST/v7" ]; then
        rm -rf "$OO_DIST/v7"
    fi
    mkdir -p "$OO_DIST/v7"
    cd "$OO_DIST/v7"
    unzip -o "$DOWNLOADS_DIR/onlyoffice-editor-v7.zip"
    echo "v7.3.3.60+11" > ./.version
    # v7 移除每个版本中不需要的 help/dictionaries
    rm -rf "$OO_DIST/v7/web-apps/apps/documenteditor/main/resources/help"
    rm -rf "$OO_DIST/v7/web-apps/apps/presentationeditor/main/resources/help" 
    rm -rf "$OO_DIST/v7/web-apps/apps/spreadsheeteditor/main/resources/help"
    rm -rf "$OO_DIST/v7/web-apps/apps/common/main/resources/help/"
    rm -rf "$OO_DIST/v7/web-apps/apps"/*/main/resources/help
    rm -rf "$OO_DIST/v7/dictionaries" 

    # 安装 v8
    # 如果目标目录已存在，则先删除以避免冲突
    if [ -d "$OO_DIST/v8" ]; then
        rm -rf "$OO_DIST/v8"
    fi
    mkdir -p "$OO_DIST/v8"
    cd "$OO_DIST/v8"
    unzip -o "$DOWNLOADS_DIR/onlyoffice-editor-latest.zip"
    echo "v8.3.3.23+5" > ./.version

    # 安装 x2t wasm 包
    # 如果目标目录已存在，则先删除以避免冲突
    if [ -d "$OO_DIST/x2t" ]; then
        rm -rf "$OO_DIST/x2t"
    fi
    mkdir -p "$OO_DIST/x2t"
    cd "$OO_DIST/x2t"
    unzip -o "$DOWNLOADS_DIR/x2t.zip"
    echo "v7.3+1" > ./.version

    rm -rf "$ONLYOFFICE_CONF_DIR/onlyoffice-builds"

    echo "*************** OnlyOffice 编辑器各版本安装完成 ***************"
}


install_node_modules(){
    cd "$PROJECT_DIR"
    # 安装依赖项
    npm ci
    npm run install:components

    echo "*************** Node.js 依赖项安装完成 ***************"
}

# 文本替换函数
# 参数：$1 目标文件路径，$2 要替换的旧字符，$3 替换后的新字符
replace_text() {
    local file_path="$1"
    local old_str="$2"
    local new_str="$3"

    # 检查参数是否完整
    if [ $# -ne 3 ]; then
        echo "错误：参数数量不正确"
        echo "使用方法: replace_text <文件路径> <旧字符> <新字符>"
        return 1
    fi

    # 检查文件是否存在
    if [ ! -f "$file_path" ]; then
        echo "错误：文件 $file_path 不存在"
        return 1
    fi

    # 判断操作系统类型，使用对应的 sed 语法
    if [[ "$(uname)" == "Darwin" ]]; then
        # macOS 系统：sed -i 需要加空备份扩展名
        sed -i '' "s@${old_str}@${new_str}@" "$file_path"
    else
        # Linux 系统：sed -i 直接使用（无备份）
        sed -i "s@${old_str}@${new_str}@" "$file_path"
    fi

    echo "已在文件 $file_path 中: "
    echo "$old_str"
    echo " -> "
    echo "$new_str"
}

init "$@"