# 构建阶段
FROM mcr.microsoft.com/devcontainers/javascript-node:18-bullseye AS builder

WORKDIR /app

COPY package*.json ./

# 安装依赖（包含编译 native 模块）
RUN npm ci --only=production

# 运行阶段 - 使用更小的基础镜像
FROM node:18-slim

# 安裝必要組件、SQLite 运行时库与 curl
RUN apt-get update && apt-get install -y \
    sqlite3 \
    libsqlite3-0 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 下載 Shoutrrr CLI 
ARG SHOUTRRR_VERSION=v0.14.0
RUN TARGETARCH=$(dpkg --print-architecture) && \
    case "${TARGETARCH}" in \
      amd64) ARCH="x86_64" ;; \
      arm64) ARCH="arm64" ;; \
      *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac && \
    FILE="shoutrrr_linux_${ARCH}_${SHOUTRRR_VERSION#v}.tar.gz" && \
    GITHUB_URL="https://github.com/nicholas-fedor/shoutrrr/releases/download/${SHOUTRRR_VERSION}/${FILE}" && \
    MIRROR_URL="https://ghfast.top/${GITHUB_URL}" && \
    echo "Downloading shoutrrr ${SHOUTRRR_VERSION} for ${ARCH}..." && \
    (curl -sL --fail -o shoutrrr.tar.gz "${GITHUB_URL}" || \
     (echo "Direct download failed, trying mirror..." && curl -sL --fail -o shoutrrr.tar.gz "${MIRROR_URL}")) && \
    tar -xzf shoutrrr.tar.gz shoutrrr && \
    chmod +x shoutrrr && \
    mv shoutrrr /usr/local/bin/ && \
    rm shoutrrr.tar.gz

WORKDIR /app

# 从构建阶段复制依赖
COPY --from=builder /app/node_modules ./node_modules

# 复制应用代码
COPY . .

EXPOSE 5270

VOLUME ["/app/data"]

CMD ["node", "server.js"]
