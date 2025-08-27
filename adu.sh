#!/bin/bash
#
#********************************************************
#author(作者):         Archangel
#version(版本):        2025-08-27
#description(描述):    高级目录使用率工具
#date(时间):           2025年8月11日 星期六 18时23分05秒
#FileName(文件名):     adu.sh
#description(描述):    高级目录使用率工具
#********************************************************
#定义颜色参数
function echo_color() {
  #定义颜色函数变量
  var_color=${1}
  #定义颜色函数参数
  content_str=${2}
  #定义颜色时间参数
  date_time=$(date "+%Y-%m-%d %H:%M:%S.%N" | cut -b 1-23)
  #清空默认值
  content_echo_str=""
  #定义颜色变量
  error_color="\033[1;5;41m"              #红底背景红字带闪烁,致命错误
  failed_color="\033[1;31m"               #红色字体,执行错误信息
  warn_color="\033[1;33m"                 #黄色字体,警号信息
  succ_color="\033[1;32m"                 #绿色字体,执行正确信息
  info_color="\033[1;34m"                 #蓝色字体,提示信息
  violet_color='\033[1;35m'               #紫色字体,信息
  blue_underline_color='\033[47;34m'      #蓝色带下滑线,信息
  dark_green_underline_color='\033[4;36m' #深绿色带下滑线,信息
  red_twinkle='\033[5;31m'                #红字带闪烁,致命错误
  #定义颜色结束变量
  RES='\033[0m'

  ## 判断参数1是否是空字符串
  if [ "x${content_str}" == "x" ]; then
    return
  else
    content_str="[${date_time}] ${content_str} ${RES}"
  fi

  #定义输出串
  case ${var_color} in
  error) #error
    content_echo_str="${error_color}${content_str}"
    ;;
  failed) #failed
    content_echo_str="${failed_color}${content_str}"
    ;;
  warning) #warning
    content_echo_str="${warn_color}${content_str}"
    ;;
  success) #success
    content_echo_str="${succ_color}${content_str}"
    ;;
  info) #info
    content_echo_str="${info_color}${content_str}"
    ;;
  violet) #violet
    content_echo_str="${violet_color}${content_str}"
    ;;
  blue_underline) #blue_underline
    content_echo_str="${blue_underline_color}${content_str}"
    ;;
  dark_green_underline) #dark_green_underline
    content_echo_str="${dark_green_underline_color}${content_str}"
    ;;
  red_twinkle) #red_twinkle
    content_echo_str="${red_twinkle_color}${content_str}"
    ;;
  esac
  ## 打印输出,并输出至文件 ${FeiShu_Content}
  echo -e "${content_echo_str}" | tee -a ${FeiShu_Content}
  #        echo_color error                  红底背景红字带闪烁,致命错误
  #        echo_color failed                 红色字体,执行错误信息
  #        echo_color warning                黄色字体,警号信息
  #        echo_color success                绿色字体,执行正确信息
  #        echo_color info                   蓝色字体,提示信息
  #        echo_color violet                 紫色字体,信息
  #        echo_color blue_underline         蓝色带下滑线,信息
  #        echo_color dark_green_underline   深绿色带下滑线,信息
  #        echo_color red_twinkle            红字带闪烁,致命错误
}

# 函数：显示帮助信息
show_help() {
    echo_color info "=== ADU - 高级目录使用率工具 ==="
    echo_color warning "用法: $0 [目录路径] [深度] [选项]"
    echo_color info "选项:"
    echo_color success "  -h, --help     显示帮助信息"
    echo_color success "  -s, --submit   将结果保存到文件"
    echo_color info "示例:"
    echo_color info "  $0 /home 3     计算/home目录下深度为3的目录大小"
    echo_color info "  $0 /var 2 -s   计算/var目录下深度为2的目录大小并保存结果"
}

# 函数：计算目录大小
calculate_dir_size() {
    local dir=${1:-/}
    local depth=${2:-5}
    local submit=${3:-false}
    local result_file="dir_size_$(date '+%Y%m%d_%H%M%S').txt"

    # 排除非查找目录
    local exclude_dir=$(df |awk 'NR>1 {print $6}' | grep -wv ${dir} | awk '{print "--exclude="$1""}')

    echo_color info "正在计算目录 ${dir} 的大小，深度为 ${depth}"
    echo_color warning "时间可能较长，请耐心等待……"

    # 使用du命令计算目录大小，并根据深度进行过滤，排除非查找目录
    if [ "$submit" = true ]; then
        echo_color violet "=== 开始计算目录大小 ==="
        echo "计算开始时间: $(date '+%Y-%m-%d %H:%M:%S')" > "$result_file"
        echo "目录: $dir" >> "$result_file"
        echo "深度: $depth" >> "$result_file"
        echo "----------------------------------------" >> "$result_file"

        # 使用du命令计算目录大小并保存结果
        du -h --max-depth=${depth} ${exclude_dir} ${dir} 2>/dev/null | awk '$1~/G$/{print $0}' > "$result_file.tmp"

        # 显示结果并保存到文件
        while read -r line; do
            size=$(echo "$line" | awk '{print $1}')
            path=$(echo "$line" | awk '{print $2}')
            echo_color success "$size $path"
            echo "$line" >> "$result_file"
        done < "$result_file.tmp"
        rm -f "$result_file.tmp"

        echo "----------------------------------------" >> "$result_file"
        echo "计算结束时间: $(date '+%Y-%m-%d %H:%M:%S')" >> "$result_file"
        echo_color success "结果已保存到文件: $result_file"
    else
        echo_color violet "=== 目录大小计算结果 ==="
        # 使用du命令计算目录大小并显示结果
        du -h --max-depth=${depth} ${exclude_dir} ${dir} 2>/dev/null \
        | awk '$1 ~ /(G$|M$|K$)/ {print $1" "$2}' \
        | while read -r size path; do
            if [[ "$size" =~ G$ ]]; then
            # 数值绿色粗体，路径黄色（用 echo_color 输出整行，需在 echo_color 中支持传入颜色 key）
            echo_color failed "${size} ${path}"
            elif [[ "$size" =~ M$ ]]; then
            # 用 info 或 warning 颜色
            echo_color warning "${size} ${path}"
            else
            # 用 success 颜色
            echo_color success "${size} ${path}"
            fi
        done

    fi

    echo_color success "目录大小计算结束"
    echo_color info "======================================"
}

# 解析命令行参数
main() {
    local dir="/"
    local depth=5
    local submit=false

    echo_color info "ADU - 高级目录使用率工具 v1.1"
    echo_color warning "======================================"

    # 处理参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -s|--submit)
                submit=true
                echo_color info "启用结果保存模式"
                shift
                ;;
            *)
                if [[ -z "$dir" || "$dir" == "/" ]]; then
                    dir=$1
                    echo_color success "目标目录: $dir"
                elif [[ -z "$depth" || "$depth" == 5 ]]; then
                    depth=$1
                    echo_color success "搜索深度: $depth"
                fi
                shift
                ;;
        esac
    done

    # 显示默认值
    if [[ "$dir" == "/" ]]; then
        echo_color success "目标目录: $dir (默认)"
    fi

    if [[ "$depth" == 5 ]]; then
        echo_color success "搜索深度: $depth (默认)"
    fi

    echo_color warning "======================================"
    calculate_dir_size "$dir" "$depth" "$submit"
}

# 执行主函数
main "$@"