#!/usr/bin/env bash

set -euo pipefail

# 脚本所在目录（项目根）
SCRIPT_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" &>/dev/null && pwd)

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
    print_message "info" "  旧内容: '$old_str' \n\t-> 新内容: '$new_str'"
    return 0
}

# 示例用法
# print_message "info" "这是一条信息提示"
# print_message "success" "操作成功完成"
# print_message "warning" "请注意，这是一个警告"
# print_message "error" "发生错误，请检查"


# 多行字符串拼接函数
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

old_str='return AppConfig;'

text="AppConfig.registeredOnlyTypes = AppConfig.availablePadTypes; 
AppConfig.availableLanguages = ['zh', 'en']
try {
    var LS_LANG = 'CRYPTPAD_LANG';
    var defaultLang = 'zh';
    if (!localStorage.getItem(LS_LANG)) {
        localStorage.setItem(LS_LANG, defaultLang);
    }
} catch (error) {
    console.error('设置默认中文语言出错：', error)
}"

# 用new_str变量接收结果
# new_str=$(line_break_concat "$text")

# echo $new_str

# print_message "info" "替换前的内容：\n$new_str"

# replace_text "$SCRIPT_DIR/demo.js" "$old_str" "$new_str"

# result=$(echo "$text" | sed -e ':a' -e '/^\n*$/ { $d; N; ba' -e '}' -e 's/[\t\n]*$//')
# print_message "info" "$result"