FROM golang:1.22-alpine as builder

ARG VERSION=unknown

# copy project
#COPY . /app

# set working directory
WORKDIR /app

# using goproxy if you have network issues
ENV GOPROXY=https://goproxy.cn,direct

# build
#RUN go build \
#    -ldflags "\
#    -X 'github.com/langgenius/dify-plugin-daemon/internal/manifest.VersionX=${VERSION}' \
#    -X 'github.com/langgenius/dify-plugin-daemon/internal/manifest.BuildTimeX=$(date -u +%Y-%m-%dT%H:%M:%S%z)'" \
#    -o /app/main cmd/server/main.go

# copy entrypoint.sh
#COPY dev-entrypoint.sh /app/dev-entrypoint.sh
#RUN chmod +x /app/dev-entrypoint.sh

FROM ubuntu:24.04

#COPY --from=builder /app/main /app/main
#COPY --from=builder /app/dev-entrypoint.sh /app/dev-entrypoint.sh

WORKDIR /app

# check build args
ARG PLATFORM=local

# 配置国内镜像源
RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list.d/ubuntu.sources \
    && sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list.d/ubuntu.sources


## Install python3.12 if PLATFORM is local
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y curl python3.12 python3.12-venv python3.12-dev python3-pip ffmpeg build-essential \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1;

# 安装基本的 shell 工具
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y bash curl && apt-get clean && rm -rf /var/lib/apt/lists/*

# preload tiktoken
ENV TIKTOKEN_CACHE_DIR=/app/.tiktoken

# Install dify_plugin to speedup the environment setup, test uv and preload tiktoken
RUN mv /usr/lib/python3.12/EXTERNALLY-MANAGED /usr/lib/python3.12/EXTERNALLY-MANAGED.bk \
    && python3 -m pip install -i https://pypi.tuna.tsinghua.edu.cn/simple/ uv \
    && uv pip install --system --index-url https://pypi.tuna.tsinghua.edu.cn/simple/ dify_plugin \
    && python3 -c "from uv._find_uv import find_uv_bin;print(find_uv_bin());" \
    && python3 -c "import tiktoken; tiktoken.get_encoding('gpt2').special_tokens_set; tiktoken.get_encoding('cl100k_base').special_tokens_set"

ENV PLATFORM=$PLATFORM
ENV GIN_MODE=release

# 复制文件到镜像中
COPY dev-entrypoint.sh /app/dev-entrypoint.sh
RUN chmod +x /app/dev-entrypoint.sh

# 使用 bash 作为默认命令，让挂载的文件可以正常工作
CMD ["bash", "-c", "if [ -f /app/dev-entrypoint.sh ]; then chmod +x /app/dev-entrypoint.sh && /app/dev-entrypoint.sh; else bash; fi"]
#CMD ["tail", "-f", "/dev/null"]
#ENTRYPOINT ["/app/dev-entrypoint.sh"]