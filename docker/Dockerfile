FROM ubuntu:24.04

WORKDIR /app

# check build args
ARG PLATFORM=local

# 配置国内镜像源
RUN sed -i 's/archive.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list.d/ubuntu.sources \
    && sed -i 's/security.ubuntu.com/mirrors.aliyun.com/g' /etc/apt/sources.list.d/ubuntu.sources


## Install python3.12 if PLATFORM is local
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y curl python3.12 python3.12-venv python3.12-dev python3-pip ffmpeg build-essential telnet \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1;

# 安装 Go 1.22
COPY ./docs/go1.22.0.linux-amd64.tar.gz ./
RUN rm -rf /usr/local/go \
    && tar -C /usr/local -xzf go1.22.0.linux-amd64.tar.gz \
    && rm go1.22.0.linux-amd64.tar.gz

# 设置 Go 环境变量
ENV GOPROXY=https://goproxy.cn,direct
ENV PATH=$PATH:/usr/local/go/bin
ENV GOPATH=/go
ENV GOBIN=$GOPATH/bin

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