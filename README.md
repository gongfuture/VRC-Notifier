# VRC-Notifier

**VRChat 好友状态监控与通知工具**

[![Node.js](https://img.shields.io/badge/Node.js-18+-339933?style=flat&logo=node.js&logoColor=white)](https://nodejs.org/)
[![Express](https://img.shields.io/badge/Express-4.x-000000?style=flat&logo=express&logoColor=white)](https://expressjs.com/)
[![SQLite](https://img.shields.io/badge/SQLite-3-003B57?style=flat&logo=sqlite&logoColor=white)](https://sqlite.org/)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?style=flat&logo=docker&logoColor=white)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

<p align="center">
  <b>中文</b> | <a href="./README_EN.md">English</a>
</p>

安全可靠的后台监控工具，实时追踪好友在线状态变化

---

## 核心功能

- **智能好友监控** - 选择性监控指定好友，而非全部好友列表
- **仅监控状态模式** - 无限制监控所有好友的在线状态，不监控世界变化
- **邮件通知** - 支持自定义 SMTP 服务器，实时接收状态变化通知
- **Gotify 推送** - 支持开源推送平台 Gotify，手机实时接收通知
- **Webhook 通知** - 支持自定义 Webhook 回调，可对接企业微信、钉钉、Discord 等第三方平台
- **世界轮询** - 智能轮询机制追踪好友所在世界变化（标准模式）
- **API 保护** - 多层限流保护机制，确保不触发官方 API 限制
- **防抖动机制** - 避免服务器抖动导致的误判，确保通知准确性
- **精美界面** - 现代化 Web UI，支持明暗主题切换
- **Docker 支持** - 一键部署，支持 Docker Compose

---

## 快速开始

### 环境要求

- Node.js 18.0 或更高版本
- 支持的平台：Windows / macOS / Linux

### 安装步骤

#### 方式一：直接运行

```bash
# 克隆仓库
git clone https://github.com/shanyaojinjn/vrc-notifier.git
cd vrc-notifier

# 安装依赖
npm install

# 启动服务
npm start
```

#### 方式二：Docker 部署（推荐）

1. **创建项目目录并进入**

```bash
mkdir vrc-notifier && cd vrc-notifier
```

2. **创建 `docker-compose.yml` 文件**

```yaml
version: '3.8'

services:
  vrc-notifier:
    image: shanyaojin/vrc-notifier:latest
    container_name: vrc-notifier
    restart: unless-stopped
    ports:
      - "5270:5270"
    volumes:
      # 数据持久化存储
      - ./data:/app/data
    networks:
      - vrc-network

networks:
  vrc-network:
    driver: bridge
```
##### 选项 2：使用国内镜像（推荐，速度更快）

1. **创建项目目录并进入**

```bash
mkdir vrc-notifier && cd vrc-notifier
```

2. **创建 `docker-compose.yml` 文件**

```yaml
version: '3.8'

services:
  vrc-notifier:
    image: crpi-tj1a3tjj9c5r6p8g.cn-hangzhou.personal.cr.aliyuncs.com/vrc-notifier/vrc-notifier:latest
    container_name: vrc-notifier
    restart: unless-stopped
    ports:
      - "5270:5270"
    volumes:
      # 数据持久化存储
      - ./data:/app/data
    networks:
      - vrc-network

networks:
  vrc-network:
    driver: bridge
```

3. **启动服务**

```bash
docker-compose up -d
```

4. **访问服务**

打开浏览器访问 http://localhost:5270 即可使用。

**注意事项：**
- 数据将保存在 `./data` 目录中，请确保该目录有写入权限
- 如需停止服务，运行 `docker-compose down`
- 查看日志：`docker-compose logs -f`

---

## API 安全与限流保护

实现了**多层限流保护系统**，严格遵循 VRChat 官方 API 规范：

### 分级限流策略（保守设计）

```javascript
// 实际限流配置（严格低于官方限制，留有安全余量）
const API_RATE_LIMITS = {
  userProfile: { maxRequests: 1, windowMs: 60 * 1000 },   // 用户资料：≤1次/分钟
  friendStatus: { maxRequests: 2, windowMs: 60 * 1000 },  // 好友状态：≤2次/分钟（官方5次）
  worldInfo: { maxRequests: 6, windowMs: 60 * 1000 }      // 世界信息：≤6次/分钟（官方10次）
};
```

**VRChat 官方建议频率 vs 我们的限制：**

| API 类型 | 官方建议 | 我们的限制 | 安全余量 |
|---------|---------|-----------|---------|
| 用户资料 | ≤1次/分钟 | 1次/分钟 | 100%合规 |
| 好友状态 | ≤5次/分钟 | 2次/分钟 | 60%余量 |
| 世界信息 | ≤10次/分钟 | 6次/分钟 | 40%余量 |

### 全局限流保护

当检测到限流触发时，系统会自动进入**全局暂停模式**：

- 自动暂停所有 API 请求 60 秒
- 向用户发送警告通知
- 前端显示实时限流状态

### 智能缓存策略

| 缓存类型 | 缓存时间 | 说明 |
|---------|---------|------|
| 好友状态 | 30秒 | 减少频繁查询好友列表 |
| 世界信息 | 10分钟 | 避免重复查询同一世界名称 |
| 好友列表 | 1年 | 永久缓存，直到手动刷新 |

### 防抖动机制

为了避免 VRChat 服务器偶尔返回不完整数据导致的误判，我们实现了**防抖动机制**：

- 需要连续 3 次检测状态一致才确认变化
- 避免单次 API 异常触发误报
- 真实状态变化最多延迟 30 秒

---

## 用户隐私保护

### 数据安全

1. **本地存储** - 所有数据（包括登录凭证）均存储在本地 SQLite 数据库
2. **加密存储** - 敏感信息（如 SMTP 密码、Cookie 数据）使用 AES-256-CBC 加密
3. **Cookie管理** - 用户的 VRChat 登录会话独立管理
4. **无数据上传** - 不会将任何数据上传到第三方服务器

### "记住我"功能安全说明

- Cookie 数据使用 AES-256-CBC 加密存储
- 加密密钥存储在服务器环境变量中
- 即使数据库文件被复制，也无法解密 Cookie
- 密码永远不会被保存（保存的是加密后的会话令牌，而非密码本身）

### 单人使用设计

**VRC-Notifier 是一个专为个人设计的工具，不支持多账户管理功能。**

我们**刻意不实现**多账户管理功能，主要基于以下安全考量：

1. **用户数据隐私** - VRChat 账户包含大量个人社交数据，不应被他人访问或控制
2. **会话安全风险** - 多账户管理需要在服务器端存储多个用户的登录凭证，增加安全风险
3. **责任边界明确** - 单人使用模式明确了安全责任的边界

### 与 VRChat 游戏的兼容性

⚠️ **重要限制**：本工具**无法与 VRChat 游戏客户端同时运行**。

VRChat 的安全机制不允许同一账号同时在多个地方保持登录状态。如需监控好友状态，请保持游戏关闭状态。

---

## 通知类型

| 变化类型 | 触发条件 | 通知方式 |
|---------|---------|---------|
| **上线通知** | 好友从离线 → 在线 | 立即发送（邮件/Gotify/Webhook） |
| **下线通知** | 好友从在线 → 离线 | 立即发送（邮件/Gotify/Webhook） |
| **状态变化** | 好友在 active/join me/ask me/busy 之间切换 | 立即发送（邮件/Gotify/Webhook） |
| **世界切换** | 好友在同一个状态内切换世界 | 批量发送（邮件/Gotify/Webhook） |

---

## 开源协议

本项目基于 [MIT](LICENSE) 协议开源。

---

## 致谢

- [VRChat API](https://vrchatapi.github.io/) - 提供 API 文档支持
- [Gotify](https://gotify.net/) - 开源推送服务
- [Node.js](https://nodejs.org/) - 运行时环境

---

## 相关链接

- **作者主页**: [https://shany.cc/](https://shany.cc/)
- **项目博客**: [https://blog.shany.cc/archives/vrc-notifier](https://blog.shany.cc/archives/vrc-notifier)
- **问题反馈**: [https://github.com/shanyaojinjn/vrc-notifier/issues](https://github.com/shanyaojinjn/vrc-notifier/issues)

---

Made with ❤️ for VRChat Community
