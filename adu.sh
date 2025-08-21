#!/bin/bash

# 函数：显示帮助信息
show_help() {
    echo "用法: $0 [目录路径] [深度] [选项]"
    echo "选项:"
    echo "  -h, --help     显示帮助信息"
    echo "  -s, --submit   将结果保存到文件"
    echo "示例:"
    echo "  $0 /home 3     计算/home目录下深度为3的目录大小"
    echo "  $0 /var 2 -s   计算/var目录下深度为2的目录大小并保存结果"
}

# 函数：计算目录大小
calculate_dir_size() {
    local dir=${1:-/}
    local depth=${2:-5}
    local submit=${3:-false}
    local result_file="dir_size_$(date '+%Y%m%d_%H%M%S').txt"
    
    # 排除非查找目录
    local exclude_dir=$(df |awk 'NR>1 {print $6}' | grep -wv ${dir} | awk '{print "--exclude="$1""}')
    
    echo -e "\033[1;34m$(date '+%Y-%m-%d %H:%M:%S.%N' | cut -b 1-23) 正在计算目录${dir}的大小，深度为${depth}\033[0m"
    echo -e "\033[1;31m时间可能较长，请耐心等待……\033[0;33m"
    
    # 使用du命令计算目录大小，并根据深度进行过滤，排除非查找目录
    if [ "$submit" = true ]; then
        echo "计算开始时间: $(date '+%Y-%m-%d %H:%M:%S')" > "$result_file"
        echo "目录: $dir" >> "$result_file"
        echo "深度: $depth" >> "$result_file"
        echo "----------------------------------------" >> "$result_file"
        du -h --max-depth=${depth} ${exclude_dir} ${dir} 2>/dev/null | awk '$1~/G$/{print $0}' | tee -a "$result_file"
        echo "----------------------------------------" >> "$result_file"
        echo "计算结束时间: $(date '+%Y-%m-%d %H:%M:%S')" >> "$result_file"
        echo -e "\033[1;32m结果已保存到文件: $result_file \033[0m"
    else
        du -h --max-depth=${depth} ${exclude_dir} ${dir} 2>/dev/null | awk '$1~/G$/{print $0}'
    fi
    
    echo -e "\033[1;32m$(date '+%Y-%m-%d %H:%M:%S.%N' | cut -b 1-23) 目录大小计算结束 \033[0m"
}

# 解析命令行参数
main() {
    local dir="/"
    local depth=5
    local submit=false
    
    # 处理参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -s|--submit)
                submit=true
                shift
                ;;
            *)
                if [[ -z "$dir" || "$dir" == "/" ]]; then
                    dir=$1
                elif [[ -z "$depth" || "$depth" == 5 ]]; then
                    depth=$1
                fi
                shift
                ;;
        esac
    done
    
    calculate_dir_size "$dir" "$depth" "$submit"
}

# 执行主函数
main "$@"
