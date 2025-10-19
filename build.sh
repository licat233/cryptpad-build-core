#!/usr/bin/env bash

set -euo pipefail

# 脚本所在目录（项目根）
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

# 可配置变量（不要硬编码路径）
PROJECT_DIR="$SCRIPT_DIR/cryptpad"
ONLYOFFICE_CONF_DIR="$PROJECT_DIR/onlyoffice-conf"
OO_DIST="$PROJECT_DIR/www/common/onlyoffice/dist"
DOWNLOADS_DIR="$SCRIPT_DIR/downloads"
RUN_FUNC="main" # 默认执行主函数
if [ $# -ge 1 ]; then
    RUN_FUNC="$1"
fi

init(){
    case "$RUN_FUNC" in
        "main")
            main "$@"
            ;;
        "auto_config")
            auto_config "$@"
            ;;
        "install_cryptpad")
            install_cryptpad "$@"
            ;;
        "install_onlyoffice")
            install_onlyoffice "$@"
            ;;
        "install_node_modules")
            install_node_modules "$@"
            ;;
        "-h"|"--help")
            echo "用法: $0 [函数名]"
            echo "可用函数:"
            echo "  main                 执行完整安装和配置流程（默认）"
            echo "  auto_config          仅执行自动配置部分"
            echo "  install_cryptpad     仅安装 CryptPad"
            echo "  install_onlyoffice   仅安装 OnlyOffice 编辑器各版本"
            echo "  install_node_modules 仅安装 Node.js 依赖项"
            ;;
        *)
            main "$@"
            ;;
    esac
}

main(){
    
    install_cryptpad "$@"

    auto_config "$@"

    install_onlyoffice "$@"

    install_node_modules "$@"

    # 完成提示
    print_message "success" "=================== 全 部 安 装 完 成 ==================="
}

auto_config(){
    cd "$PROJECT_DIR"
    update_application_config
    update_config_js
    update_customize_pages
    update_customize_pages_index
    update_common_ui_elements
    update_onlyoffice_inner
    print_message "success" "********** 代码已全部配置完成 **********"
}


update_onlyoffice_inner(){
    local INNER_PATH="$PROJECT_DIR/www/common/onlyoffice/inner.js"
    local old_str="if (!privateData.isEmbed) {"
    local new_str="if (false\&\&!privateData.isEmbed) {"
    replace_text "$INNER_PATH" "$old_str" "$new_str"
    print_message "success" "*************** /www/common/onlyoffice/inner.js 更改完成 ***************"
}

update_common_ui_elements(){
    local UI_ELEMENTS_PATH="$PROJECT_DIR/www/common/common-ui-elements.js"
    local old_str="var todo = function () {"
    local new_str="var todo = function (e) {\n\t\t\tcrowdfundingState = true;\n\t\t\treturn;"
    replace_text "$UI_ELEMENTS_PATH" "$old_str" "$new_str"
    local old_str="'class': 'cp-toolbar-about fa fa-info',"
    local new_str="'hidden':true,\n\t\t\t\t'class': 'cp-toolbar-about fa fa-info'"
    replace_text "$UI_ELEMENTS_PATH" "$old_str" "$new_str"
    local old_str="'href': 'https://docs.cryptpad.org',"
    local new_str="'hidden':true,\n\t\t\t\t'href': '/',"
    replace_text "$UI_ELEMENTS_PATH" "$old_str" "$new_str"

    print_message "success" "*************** www/common/common-ui-elements.js 更改完成 ***************"

}

update_customize_pages_index(){
    local INDEX_PATH="$PROJECT_DIR/customize.dist/pages/index.js"
    local old_str="h('a', {href:\"/contact.html\"}, Msg.contact),"
    local new_str="h('a', {href:\"/contact.html\",hidden:true}, Msg.contact),"
    replace_text "$INDEX_PATH" "$old_str" "$new_str"

    print_message "success" "*************** customize.dist/pages/index.js 更改完成 ***************"

}

update_customize_pages(){
    local PAGES_PATH="$PROJECT_DIR/customize.dist/pages.js"
    local old_str="Pages.infopageFooter = function () {"
    local new_str="Pages.infopageFooter = function (e) {\n\t   return null;"
    replace_text "$PAGES_PATH" "$old_str" "$new_str"
    local old_str2="h('a.nav-item.nav-link', { href: 'https://docs.cryptpad.org'},"
    local new_str2="h('a.nav-item.nav-link', { href: 'https://docs.cryptpad.org', hidden: true},"
    replace_text "$PAGES_PATH" "$old_str2" "$new_str2"

    print_message "success" "*************** customize.dist/pages.js 更改完成 ***************"

}

update_application_config(){
    mkdir -p "$PROJECT_DIR/customize"
    local APP_CONF_INN_PATH="$PROJECT_DIR/www/common/application_config_internal.js"
    local APP_CONF_PATH="$PROJECT_DIR/customize/application_config.js"
     # 先判断application_config.js文件是否存在，若不存在则从application_config_internal.js复制一份
    if [ ! -f "$APP_CONF_PATH" ]; then
        cp -f "$APP_CONF_INN_PATH" "$APP_CONF_PATH"
    fi
    # 定义要替换的旧内容和新内容
    # 加盐
    replace_text "$APP_CONF_PATH" "AppConfig.loginSalt = '';" "AppConfig.loginSalt = 'licat23333';"

    # 设置默认语言为中文,且禁止未注册用户使用
    local old_str="return AppConfig;"
    local new_str="AppConfig.registeredOnlyTypes = AppConfig.availablePadTypes; 
AppConfig.availableLanguages = ['zh', 'en']
try {
    var LS_LANG = 'CRYPTPAD_LANG';
    var defaultLang = 'zh';
    if (!localStorage.getItem(LS_LANG)) {
        localStorage.setItem(LS_LANG, defaultLang);
    }
} catch (error) {
    console.error('设置默认中文语言出错：', error)
}
return AppConfig"

    # 处理换行符
    new_str=$(line_break_concat "$new_str")

    replace_text "$APP_CONF_PATH" "$old_str" "$new_str"

    print_message "success" "*************** customize/application_config.js 更改完成 ***************"

}

update_config_js(){
    INSTALL_METHOD=docker  # 可选值：docker 或 unspecified
    local CONFIG_PATH="$PROJECT_DIR/config/config.js"
    # 先判断config.js文件是否存在，若不存在则从config.example.js复制一份
    if [ ! -f "$CONFIG_PATH" ]; then
        cp -f "$PROJECT_DIR/config/config.example.js" "$CONFIG_PATH"
    fi
    # 定义要替换的旧内容和新内容
    if [ "$INSTALL_METHOD" == "docker" ]; then
        replace_text "$CONFIG_PATH" "//httpAddress: 'localhost'" "httpAddress: '0.0.0.0'"
        replace_text "$CONFIG_PATH" "installMethod: 'unspecified'," "removeDonateButton: true,\n\tinstallMethod: 'docker',"
    else
        replace_text "$CONFIG_PATH" "installMethod: 'unspecified'," "removeDonateButton: true,\n\tinstallMethod: 'unspecified'"
    fi

    print_message "success" "*************** /config/config.js 更改完成 ***************"
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

    print_message "success" "*************** CryptPad 安装完成 ***************"
 
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

    print_message "success" "*************** OnlyOffice 编辑器各版本安装完成 ***************"
}


install_node_modules(){
    cd "$PROJECT_DIR"
    # 安装依赖项
    npm ci
    npm run install:components

    print_message "success" "*************** Node.js 依赖项安装完成 ***************"
}

# 处理字符串换行符
# 参数：$1 多行字符串，$2 分隔符（可选，默认 \n\t）
# 返回值：拼接后的单行字符串，换行符替换为 \n\t
line_break_concat() {
    #参数检查
    if [ -z "$1" ]; then
        print_message "error" "line_break_concat 函数需要至少一个参数"
        return 1
    fi
    # 分隔符默认值
    local separator="${2:-\\n\t}"
    local joined="$1"
    # 使用 tr 和 sed 进行转换
    joined=$(echo "$1" | tr '\n' '@' | sed "s/@/${separator}/g" | sed "s/${separator}$//")
    # 先将换行符转为临时标记（如 @），再替换为 \n
    joined=$(echo "$joined" | tr '\n' '@' | sed 's/@/\\n/g' | sed 's/[\t\n]*$//' )
    joined=$(echo "$joined" | sed 's/\\n\t$//')
    echo "$joined"
}

# 文本替换函数
# 参数：$1 目标文件路径，$2 要替换的旧字符，$3 替换后的新字符, $4 全局替换（可选，默认false）
replace_text() {
    local file_path="$1"
    local old_str="$2"
    local new_str="$3"
    local global_replace="${4:-false}"
    local sed_exit_code=0

    # 检查参数是否完整，至少有 3 个参数
    if [ $# -lt 3 ]; then
        print_message "error" "参数数量不正确"
        print_message "info" "使用方法: replace_text <文件路径> <旧字符> <新字符>"
        return 1
    fi

    # 先检查 $old_str 是否为空（避免空字符串导致的误判）
    if [ -z "$old_str" ]; then
        print_message "error" "旧字符不能为空"
        return 1
    fi

    # 检查文件是否存在
    if [ ! -f "$file_path" ]; then
        print_message "error" "文件 $file_path 不存在"
        return 1
    fi

    # 检查文件是否可写
    if [ ! -w "$file_path" ]; then
        print_message "error" "文件 $file_path 不可写"
        return 1
    fi

    local count_total=0
    # 检查是否有需要替换的内容（避免无意义操作）
    if ! grep -F -- "$old_str" "$file_path" >/dev/null 2>&1; then
        print_message "warning" "文件 $file_path 中未找到 '$old_str'，无需替换"
        return 0
    fi

    # 统计总匹配次数（按实际出现次数）
    count_total=$(grep -Fo -- "$old_str" "$file_path" | wc -l)
    # 如果存在多处，需要提示用户
    if [ "$count_total" -gt 1 ]; then
        print_message "info" "文件 $file_path 中找到 '$old_str'，共 $count_total 处匹配"
        # 判断当前是否为全局匹配
        if [ "$global_replace" != "true" ]; then
            print_message "warning" "警告：文件 $file_path 中找到多处 '$old_str'，但未启用全局替换"
            print_message "warning" "  建议启用全局替换以确保所有目标内容均被替换"
            print_message "warning" "  为保护文件安全性，当前不做任何替换操作"
            return 2
        fi
    fi

    # 判断是否为全局替换
    local global_replace_flag=""
    if [ "$global_replace" == "true" ]; then
        global_replace_flag="g"
    fi
    # 判断操作系统类型，使用对应的 sed 语法并捕获退出码
    if [[ "$(uname)" == "Darwin" ]]; then
        # macOS 系统：sed -i 需要加空备份扩展名
        sed -i '' "s@${old_str}@${new_str}@${global_replace_flag}" "$file_path"
        sed_exit_code=$?
    else
        # Linux 系统：sed -i 直接使用（无备份）
        sed -i "s@${old_str}@${new_str}@${global_replace_flag}" "$file_path"
        sed_exit_code=$?
    fi

    # 检查 sed 命令执行结果
    if [ $sed_exit_code -ne 0 ]; then
        print_message "error" "替换操作失败(sed 命令执行出错)"
        return $sed_exit_code
    fi

    print_message "success" "在文件 $file_path 中完成替换"
    print_message "info" "  旧内容: $old_str \n\t-> 新内容: $new_str"
    return 0
}

# 打印格式化消息的函数
# 参数：$1 消息类型(info, success, warning, error)，$2 消息内容
print_message() {
    local type="$1"
    local message="$2"
    local icon=""
    local color=""
    local RED='\033[0;31m'
    local GREEN='\033[0;32m'
    local YELLOW='\033[1;33m'
    local BLUE='\033[0;34m'
    local NC='\033[0m'
    local INFO_ICON="ℹ️"
    local SUCCESS_ICON="✅"
    local WARNING_ICON="⚠️"
    local ERROR_ICON="❌"
    
    # 根据类型设置图标和颜色
    case "$type" in
        "info")
            icon="$INFO_ICON"
            color="$BLUE"
            ;;
        "success")
            icon="$SUCCESS_ICON"
            color="$GREEN"
            ;;
        "warning")
            icon="$WARNING_ICON"
            color="$YELLOW"
            ;;
        "error")
            icon="$ERROR_ICON"
            color="$RED"
            ;;
        *)
            icon="$INFO_ICON"
            color="$BLUE"
            type="info"
            ;;
    esac
    
    # 使用tr命令进行大小写转换（兼容bash 3.x及以下版本）
    local type_upper=$(echo "$type" | tr '[:lower:]' '[:upper:]')
    
    # 打印格式化的消息
    echo -e "${color}${icon} [${type_upper}] ${message}${NC}"
}

init "$@"