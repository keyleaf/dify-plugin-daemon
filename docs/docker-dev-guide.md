# Docker 开发环境使用指南

## 概述

这个开发环境使用 Docker 容器来运行 Dify Plugin Daemon，解决了在 macOS 上无法使用某些数据库驱动的问题。

## 缓存卷说明

### 1. python-cache
- **挂载路径**: `/app/.tiktoken`
- **作用**: 缓存 tiktoken 模型文件
- **好处**: 
  - 避免每次启动都重新下载 tiktoken 模型
  - 大幅提升容器启动速度
  - 模型文件约 50MB，下载耗时较长

### 2. go-mod-cache  
- **挂载路径**: `/go/pkg/mod`
- **作用**: 缓存 Go 模块依赖
- **好处**:
  - 避免重复下载 Go 依赖包
  - 加速 `go mod download` 过程
  - 节省网络带宽和时间

### 3. go-build-cache
- **挂载路径**: `/root/.cache/go-build`
- **作用**: 缓存 Go 编译中间文件
- **好处**:
  - 加速后续编译过程
  - 避免重复编译相同的包
  - 提升开发效率

## 使用方法

### 1. 启动开发环境
```bash
# 使用便捷脚本
./scripts/dev-docker.sh

# 或手动启动
docker-compose -f docker-compose.dev.yml up -d
```

### 2. 进入容器
```bash
docker exec -it dify-plugin-daemon-dev bash
```

### 3. 在容器内开发
```bash
# 下载依赖
go mod download

# 运行应用
go run ./cmd/server

# 调试模式
dlv debug ./cmd/server

# 构建应用
go build ./cmd/server
```

### 4. 查看缓存卷
```bash
# 查看所有卷
docker volume ls

# 查看特定卷的详细信息
docker volume inspect dify-plugin-daemon_go-mod-cache
docker volume inspect dify-plugin-daemon_python-cache
docker volume inspect dify-plugin-daemon_go-build-cache
```

### 5. 清理缓存（如需要）
```bash
# 停止容器
docker-compose -f docker-compose.dev.yml down

# 删除卷（会丢失缓存）
docker volume rm dify-plugin-daemon_go-mod-cache
docker volume rm dify-plugin-daemon_python-cache  
docker volume rm dify-plugin-daemon_go-build-cache
```

## 网络配置

### 访问宿主机服务
- **PostgreSQL**: `host.docker.internal:5432`
- **Redis**: `host.docker.internal:6379`
- **Dify API**: `http://host.docker.internal:5001`

### 端口映射
- **应用端口**: `5002:5002`
- **调试端口**: `2345:2345`

## 环境变量

主要环境变量在 `docker-compose.dev.yml` 中配置：

```yaml
environment:
  - PLATFORM=local
  - GIN_MODE=debug
  - PYTHON_INTERPRETER_PATH=/usr/bin/python3
  - DB_HOST=host.docker.internal
  - REDIS_HOST=host.docker.internal
  # ... 其他配置
```

## 故障排除

### 1. 缓存卷权限问题
```bash
# 重新创建容器
docker-compose -f docker-compose.dev.yml down
docker-compose -f docker-compose.dev.yml up -d
```

### 2. 网络连接问题
确保宿主机服务正在运行：
- PostgreSQL 服务
- Redis 服务
- Dify API 服务

### 3. 端口冲突
检查端口是否被占用：
```bash
lsof -i :5002
lsof -i :2345
```

## 性能优化

1. **使用缓存卷**: 避免重复下载依赖
2. **挂载源代码**: 实时同步代码修改
3. **使用 host 网络**: 减少网络开销
4. **调试模式**: 启用热重载和调试功能
