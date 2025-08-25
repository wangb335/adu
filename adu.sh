#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
RESET='\033[0m'

# 函数：显示帮助信息
show_help() {
    echo -e "${BOLD}${CYAN}=== ADU - 高级目录使用率工具 ===${RESET}"
    echo -e "${YELLOW}用法:${RESET} $0 ${GREEN}[目录路径]${RESET} ${BLUE}[深度]${RESET} ${PURPLE}[选项]${RESET}"
    echo -e "${BOLD}选项:${RESET}"
    echo -e "  ${GREEN}-h, --help${RESET}     显示帮助信息"
    echo -e "  ${GREEN}-s, --submit${RESET}   将结果保存到文件"
    echo -e "${BOLD}示例:${RESET}"
    echo -e "  ${CYAN}$0 /home 3${RESET}     计算/home目录下深度为3的目录大小"
    echo -e "  ${CYAN}$0 /var 2 -s${RESET}   计算/var目录下深度为2的目录大小并保存结果"
}

# 函数：计算目录大小
calculate_dir_size() {
    local dir=${1:-/}
    local depth=${2:-5}
    local submit=${3:-false}
    local result_file="dir_size_$(date '+%Y%m%d_%H%M%S').txt"
    
    # 排除非查找目录
    local exclude_dir=$(df |awk 'NR>1 {print $6}' | grep -wv ${dir} | awk '{print "--exclude="$1""}')
    
    echo -e "${BOLD}${BLUE}$(date '+%Y-%m-%d %H:%M:%S.%N' | cut -b 1-23)${RESET} ${CYAN}正在计算目录${BOLD}${YELLOW}${dir}${RESET}${CYAN}的大小，深度为${BOLD}${YELLOW}${depth}${RESET}"
    echo -e "${BOLD}${RED}时间可能较长，请耐心等待……${RESET}"
    
    # 使用du命令计算目录大小，并根据深度进行过滤，排除非查找目录
    if [ "$submit" = true ]; then
        echo -e "${PURPLE}=== 开始计算目录大小 ===${RESET}"
        echo "计算开始时间: $(date '+%Y-%m-%d %H:%M:%S')" > "$result_file"
        echo "目录: $dir" >> "$result_file"
        echo "深度: $depth" >> "$result_file"
        echo "----------------------------------------" >> "$result_file"
        
        # 使用彩色输出并保存到文件
        du -h --max-depth=${depth} ${exclude_dir} ${dir} 2>/dev/null | awk -v green="${GREEN}" -v reset="${RESET}" -v bold="${BOLD}" '$1~/G$/{printf "%s%s%s %s\n", bold, green, $1, $2; print $0 > "'"$result_file.tmp"'"}' 
        cat "$result_file.tmp" >> "$result_file"
        rm -f "$result_file.tmp"
        
        echo "----------------------------------------" >> "$result_file"
        echo "计算结束时间: $(date '+%Y-%m-%d %H:%M:%S')" >> "$result_file"
        echo -e "${BOLD}${GREEN}结果已保存到文件: ${UNDERLINE}$result_file${RESET}"
    else
        echo -e "${PURPLE}=== 目录大小计算结果 ===${RESET}"
        du -h --max-depth=${depth} ${exclude_dir} ${dir} 2>/dev/null | awk -v green="${GREEN}" -v yellow="${YELLOW}" -v reset="${RESET}" -v bold="${BOLD}" '$1~/G$/{printf "%s%s%s %s%s%s\n", bold, green, $1, yellow, $2, reset}'
    fi
    
    echo -e "${BOLD}${GREEN}$(date '+%Y-%m-%d %H:%M:%S.%N' | cut -b 1-23) 目录大小计算结束${RESET}"
    echo -e "${CYAN}======================================${RESET}"
}

# 解析命令行参数
main() {
    local dir="/"
    local depth=5
    local submit=false
    
    echo -e "${BOLD}${CYAN}ADU - 高级目录使用率工具 ${PURPLE}v1.1${RESET}"
    echo -e "${YELLOW}======================================${RESET}"
    
    # 处理参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -s|--submit)
                submit=true
                echo -e "${CYAN}启用结果保存模式${RESET}"
                shift
                ;;
            *)
                if [[ -z "$dir" || "$dir" == "/" ]]; then
                    dir=$1
                    echo -e "${GREEN}目标目录: ${BOLD}$dir${RESET}"
                elif [[ -z "$depth" || "$depth" == 5 ]]; then
                    depth=$1
                    echo -e "${GREEN}搜索深度: ${BOLD}$depth${RESET}"
                fi
                shift
                ;;
        esac
    done
    
    # 显示默认值
    if [[ "$dir" == "/" ]]; then
        echo -e "${GREEN}目标目录: ${BOLD}$dir ${YELLOW}(默认)${RESET}"
    fi
    
    if [[ "$depth" == 5 ]]; then
        echo -e "${GREEN}搜索深度: ${BOLD}$depth ${YELLOW}(默认)${RESET}"
    fi
    
    echo -e "${YELLOW}======================================${RESET}"
    calculate_dir_size "$dir" "$depth" "$submit"
}

# 执行主函数
main "$@"
