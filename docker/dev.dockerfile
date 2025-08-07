FROM golang:1.22-alpine as builder

# Install build dependencies
RUN apk add --no-cache git

# Set working directory
WORKDIR /app

# Install Go tools for development
RUN go install github.com/go-delve/delve/cmd/dlv@latest

FROM ubuntu:24.04

# 配置国内镜像源
RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list \
    && sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list

# Install system dependencies
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y \
    curl \
    python3.12 \
    python3.12-venv \
    python3.12-dev \
    python3-pip \
    ffmpeg \
    build-essential \
    git \
    vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

# Install Go
RUN curl -L https://go.dev/dl/go1.22.0.linux-amd64.tar.gz | tar -C /usr/local -xzf -
ENV PATH=$PATH:/usr/local/go/bin
ENV GOPATH=/go
ENV PATH=$PATH:$GOPATH/bin

# 配置Go代理以加速依赖下载
ENV GOPROXY=https://goproxy.cn,direct
ENV GOSUMDB=sum.golang.google.cn

# Install Go tools for development
RUN go install github.com/go-delve/delve/cmd/dlv@latest

# Install Python dependencies
ENV TIKTOKEN_CACHE_DIR=/app/.tiktoken

# Install dify_plugin and preload tiktoken
RUN mv /usr/lib/python3.12/EXTERNALLY-MANAGED /usr/lib/python3.12/EXTERNALLY-MANAGED.bk \
    && python3 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple/ uv \
    && uv pip install --system --index-url https://pypi.tuna.tsinghua.edu.cn/simple/ dify_plugin \
    && python3 -c "from uv._find_uv import find_uv_bin;print(find_uv_bin());" \
    && python3 -c "import tiktoken; tiktoken.get_encoding('gpt2').special_tokens_set; tiktoken.get_encoding('cl100k_base').special_tokens_set"

# Set working directory
WORKDIR /app

# Set environment variables
ENV PLATFORM=local
ENV GIN_MODE=debug
ENV PYTHON_INTERPRETER_PATH=/usr/bin/python3

# Create a development entrypoint script
RUN echo '#!/bin/bash\n\
echo "Starting development environment..."\n\
echo "Current directory: $(pwd)"\n\
echo "Go version: $(go version)"\n\
echo "Python version: $(python3 --version)"\n\
echo "Available commands:"\n\
echo "  - go run ./cmd/server     # Run the server"\n\
echo "  - go build ./cmd/server   # Build the server"\n\
echo "  - dlv debug ./cmd/server  # Debug the server"\n\
echo "  - go mod download         # Download dependencies"\n\
echo "  - go mod tidy             # Tidy dependencies"\n\
echo ""\n\
echo "Starting bash shell..."\n\
exec bash' > /app/dev-entrypoint.sh && chmod +x /app/dev-entrypoint.sh

# Default command
CMD ["/app/dev-entrypoint.sh"]
