#!/bin/bash

# Dify Plugin Daemon 开发环境启动脚本

set -e

echo "🚀 启动 Dify Plugin Daemon 开发环境..."

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装，请先安装 Docker"
    exit 1
fi

# 检查 docker-compose 是否安装
if ! command -v docker-compose &> /dev/null; then
    echo "❌ docker-compose 未安装，请先安装 docker-compose"
    exit 1
fi

# 检查 .env 文件是否存在
if [ ! -f .env ]; then
    echo "📝 创建 .env 文件..."
    cp .env.example .env
    echo "⚠️  请编辑 .env 文件，配置数据库和Redis连接信息"
fi

# 构建并启动开发容器
echo "🔨 构建开发容器..."
docker-compose -f docker-compose.dev.yml build

echo "📦 启动开发容器..."
docker-compose -f docker-compose.dev.yml up -d

echo "✅ 开发环境已启动！"
echo ""
echo "📋 使用说明："
echo "1. 进入容器: docker exec -it dify-plugin-daemon-dev bash"
echo "2. 在容器内运行: go run ./cmd/server"
echo "3. 调试模式: dlv debug ./cmd/server"
echo "4. 查看日志: docker-compose -f docker-compose.dev.yml logs -f"
echo "5. 停止环境: docker-compose -f docker-compose.dev.yml down"
echo ""
echo "🌐 应用将在 http://localhost:5002 运行"
echo "🔧 调试端口: 2345"
echo ""
echo "💡 提示："
echo "- 源代码已挂载到容器内，修改本地文件会实时同步"
echo "- 使用 host.docker.internal 访问宿主机服务"
echo "- 如需修改环境变量，请编辑 docker-compose.dev.yml 文件"
