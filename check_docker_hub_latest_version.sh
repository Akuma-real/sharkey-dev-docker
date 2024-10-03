#!/bin/bash

# 检查并安装 jq
if ! command -v jq &> /dev/null; then
    echo "jq 未安装。正在安装..."
    # 检查操作系统类型
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    else
        echo "无法检测到操作系统，手动安装 jq。"
        exit 1
    fi

    # 根据操作系统安装 jq
    case "$OS" in
        ubuntu|debian)
            sudo apt-get update
            sudo apt-get install -y jq
            ;;
        centos|rhel)
            sudo yum install -y epel-release
            sudo yum install -y jq
            ;;
        fedora)
            sudo dnf install -y jq
            ;;
        *)
            echo "不支持的操作系统，请手动安装 jq。"
            exit 1
            ;;
    esac
fi

# 检查 jq 是否安装成功
if ! command -v jq &> /dev/null; then
    echo "jq 安装失败，请手动安装。"
    exit 1
fi

repository="juneink/sharkey"

# 从 Docker Hub 获取标签信息
response=$(curl -s "https://hub.docker.com/v2/repositories/$repository/tags/")

# 检查响应是否为空
if [ -z "$response" ]; then
    echo "无法从 Docker Hub 获取数据"
    exit 1
fi

# 提取 latest 标签的信息
latest_info=$(echo "$response" | jq -r '.results[] | select(.name=="latest")')

# 检查是否找到了 latest 标签
if [ -z "$latest_info" ]; then
    echo "未找到 'latest' 标签"
    exit 1
fi

# 获取 latest 标签的Digest
latest_digest=$(echo "$latest_info" | jq -r '.digest')

# 查找与 latest 标签Digest相同的所有标签，并排除 latest
matching_tags=$(echo "$response" | jq -r --arg digest "$latest_digest" '.results[] | select(.digest==$digest and .name!="latest") | .name')

# 显示结果
echo "与 'latest' 标签相同Digest的其他版本号："
echo "$matching_tags"
