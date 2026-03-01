# VRC-Notifier

**VRChat 好友状态监控与通知工具 | VRChat Friend Status Monitor & Notification Tool**

[![Node.js](https://img.shields.io/badge/Node.js-18+-339933?style=flat&logo=node.js&logoColor=white)](https://nodejs.org/)
[![Express](https://img.shields.io/badge/Express-4.x-000000?style=flat&logo=express&logoColor=white)](https://expressjs.com/)
[![SQLite](https://img.shields.io/badge/SQLite-3-003B57?style=flat&logo=sqlite&logoColor=white)](https://sqlite.org/)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?style=flat&logo=docker&logoColor=white)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

<p align="center">
  <a href="./README.md">中文</a> | <a href="./README_EN.md">English</a>
</p>

安全可靠的后台监控工具，实时追踪好友在线状态变化

A secure and reliable background monitoring tool that tracks friend online status changes in real-time

---

## 技术栈 | Tech Stack

| 层级 | 技术 | 说明 | Layer | Technology | Description |
|------|------|------|-------|------------|-------------|
| **后端** | Node.js + Express | RESTful API 服务 | **Backend** | Node.js + Express | RESTful API service |
| **数据库** | SQLite3 | 轻量级本地数据存储 | **Database** | SQLite3 | Lightweight local data storage |
| **前端** | 原生 HTML + CSS + JS | 响应式 Web 界面 | **Frontend** | Native HTML + CSS + JS | Responsive Web UI |
| **定时任务** | node-cron | 周期性状态检查 | **Scheduler** | node-cron | Periodic status checks |
| **邮件服务** | Nodemailer | SMTP 邮件发送 | **Email** | Nodemailer | SMTP email sending |
| **HTTP 客户端** | Axios + tough-cookie | VRChat API 通信 | **HTTP Client** | Axios + tough-cookie | VRChat API communication |

---

## 核心功能 | Core Features

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

- **Smart Friend Monitoring** - Selectively monitor specific friends instead of entire friend list
- **Status-Only Mode** - Monitor all friends' online status without world tracking
- **Email Notifications** - Support custom SMTP server for real-time status alerts
- **Gotify Push** - Support open-source push platform Gotify for mobile notifications
- **Webhook Notifications** - Support custom Webhook callbacks for WeChat Work, DingTalk, Discord, etc.
- **World Polling** - Smart polling mechanism to track friends' world changes (standard mode)
- **API Protection** - Multi-layer rate limiting to avoid triggering official API restrictions
- **Debounce Mechanism** - Prevent false positives from server jitter
- **Beautiful UI** - Modern Web UI with dark/light theme support
- **Docker Support** - One-click deployment with Docker Compose

---

## 快速开始 | Quick Start

### 环境要求 | Requirements

- Node.js 18.0 或更高版本 | Node.js 18.0 or higher
- 支持的平台 | Supported platforms: Windows / macOS / Linux

### 安装步骤 | Installation

#### 方式一：直接运行 | Method 1: Run Directly

```bash
# 克隆仓库 | Clone repository
git clone https://github.com/shanyaojinjn/vrc-notifier.git
cd vrc-notifier

# 安装依赖 | Install dependencies
npm install

# 启动服务 | Start service
npm start
```

#### 方式二：Docker 部署（推荐）| Method 2: Docker Deployment (Recommended)

1. **创建项目目录并进入 | Create project directory**

```bash
mkdir vrc-notifier && cd vrc-notifier
```

2. **创建 `docker-compose.yml` 文件 | Create `docker-compose.yml`**

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
      # 数据持久化存储 | Data persistence
      - ./data:/app/data
    networks:
      - vrc-network

networks:
  vrc-network:
    driver: bridge
```

3. **启动服务 | Start service**

```bash
docker-compose up -d
```

4. **访问服务 | Access service**

打开浏览器访问 | Open browser: http://localhost:5270

**注意事项 | Notes:**
- 数据将保存在 `./data` 目录中，请确保该目录有写入权限
- Data will be saved in `./data` directory, ensure write permissions
- 如需停止服务，运行 `docker-compose down`
- To stop service, run `docker-compose down`
- 查看日志：`docker-compose logs -f`
- View logs: `docker-compose logs -f`

---

## API 安全与限流保护 | API Security & Rate Limiting

实现了**多层限流保护系统**，严格遵循 VRChat 官方 API 规范：

A **multi-layer rate limiting protection system** is implemented, strictly following VRChat official API specifications:

### 分级限流策略（保守设计）| Tiered Rate Limiting (Conservative Design)

```javascript
// 实际限流配置（严格低于官方限制，留有安全余量）
// Actual rate limiting configuration (strictly below official limits with safety margin)
const API_RATE_LIMITS = {
  userProfile: { maxRequests: 1, windowMs: 60 * 1000 },   // 用户资料：≤1次/分钟 | User profile: ≤1/min
  friendStatus: { maxRequests: 2, windowMs: 60 * 1000 },  // 好友状态：≤2次/分钟（官方5次）| Friend status: ≤2/min (official: 5)
  worldInfo: { maxRequests: 6, windowMs: 60 * 1000 }      // 世界信息：≤6次/分钟（官方10次）| World info: ≤6/min (official: 10)
};
```

**VRChat 官方建议频率 vs 我们的限制：| VRChat Official vs Our Limits:**

| API 类型 | API Type | 官方建议 | Official | 我们的限制 | Our Limit | 安全余量 | Safety Margin |
|---------|---------|---------|---------|-----------|---------|---------|--------------|
| 用户资料 | User Profile | ≤1次/分钟 | ≤1/min | 1次/分钟 | 1/min | 100%合规 | 100% Compliant |
| 好友状态 | Friend Status | ≤5次/分钟 | ≤5/min | 2次/分钟 | 2/min | 60%余量 | 60% Margin |
| 世界信息 | World Info | ≤10次/分钟 | ≤10/min | 6次/分钟 | 6/min | 40%余量 | 40% Margin |

### 全局限流保护 | Global Rate Limit Protection

当检测到限流触发时，系统会自动进入**全局暂停模式**：

When rate limiting is detected, the system automatically enters **global pause mode**:

- 自动暂停所有 API 请求 60 秒 | Auto-pause all API requests for 60 seconds
- 向用户发送警告通知 | Send warning notifications to users
- 前端显示实时限流状态 | Frontend displays real-time rate limit status

### 智能缓存策略 | Smart Caching Strategy

| 缓存类型 | Cache Type | 缓存时间 | Duration | 说明 | Description |
|---------|-----------|---------|---------|------|-------------|
| 好友状态 | Friend Status | 30秒 | 30s | 减少频繁查询好友列表 | Reduce frequent friend list queries |
| 世界信息 | World Info | 10分钟 | 10min | 避免重复查询同一世界名称 | Avoid duplicate world name queries |
| 好友列表 | Friend List | 1年 | 1 year | 永久缓存，直到手动刷新 | Permanent cache until manual refresh |

### 防抖动机制 | Debounce Mechanism

为了避免 VRChat 服务器偶尔返回不完整数据导致的误判，我们实现了**防抖动机制**：

To prevent false positives from incomplete data returned by VRChat servers, we implemented a **debounce mechanism**:

- 需要连续 3 次检测状态一致才确认变化 | Requires 3 consecutive consistent status checks to confirm change
- 避免单次 API 异常触发误报 | Prevents false alerts from single API anomalies
- 真实状态变化最多延迟 30 秒 | Real status changes delayed by max 30 seconds

---

## 用户隐私保护 | User Privacy Protection

### 数据安全 | Data Security

1. **本地存储 | Local Storage** - 所有数据（包括登录凭证）均存储在本地 SQLite 数据库 | All data (including login credentials) stored locally in SQLite database
2. **加密存储 | Encrypted Storage** - 敏感信息（如 SMTP 密码、Cookie 数据）使用 AES-256-CBC 加密 | Sensitive info encrypted with AES-256-CBC
3. **Cookie管理 | Cookie Management** - 用户的 VRChat 登录会话独立管理 | VRChat login sessions managed independently
4. **无数据上传 | No Data Upload** - 不会将任何数据上传到第三方服务器 | No data uploaded to third-party servers

### "记住我"功能安全说明 | "Remember Me" Security

- Cookie 数据使用 AES-256-CBC 加密存储 | Cookie data encrypted with AES-256-CBC
- 加密密钥存储在服务器环境变量中 | Encryption key stored in server environment variables
- 即使数据库文件被复制，也无法解密 Cookie | Even if database is copied, Cookie cannot be decrypted
- 密码永远不会被保存（保存的是加密后的会话令牌，而非密码本身）| Passwords are never saved (only encrypted session tokens)

### 单人使用设计 | Single-User Design

**VRC-Notifier 是一个专为个人设计的工具，不支持多账户管理功能。**

**VRC-Notifier is designed for personal use only and does not support multi-account management.**

我们**刻意不实现**多账户管理功能，主要基于以下安全考量：

We **intentionally do not implement** multi-account management for the following security reasons:

1. **用户数据隐私 | User Data Privacy** - VRChat 账户包含大量个人社交数据，不应被他人访问或控制 | VRChat accounts contain personal social data that should not be accessed by others
2. **会话安全风险 | Session Security Risk** - 多账户管理需要在服务器端存储多个用户的登录凭证，增加安全风险 | Multi-account management increases security risks
3. **责任边界明确 | Clear Responsibility** - 单人使用模式明确了安全责任的边界 | Single-user mode clarifies security responsibility boundaries

### 与 VRChat 游戏的兼容性 | VRChat Game Compatibility

⚠️ **重要限制 | Important Limitation**：本工具**无法与 VRChat 游戏客户端同时运行**。

This tool **cannot run simultaneously with the VRChat game client**.

VRChat 的安全机制不允许同一账号同时在多个地方保持登录状态。如需监控好友状态，请保持游戏关闭状态。

VRChat's security mechanism does not allow the same account to be logged in from multiple places simultaneously. To monitor friend status, please keep the game closed.

---

## 通知类型 | Notification Types

| 变化类型 | Change Type | 触发条件 | Trigger Condition | 通知方式 | Notification Method |
|---------|------------|---------|------------------|---------|-------------------|
| **上线通知** | Online | 好友从离线 → 在线 | Friend offline → online | 立即发送 | Immediate (Email/Gotify/Webhook) |
| **下线通知** | Offline | 好友从在线 → 离线 | Friend online → offline | 立即发送 | Immediate (Email/Gotify/Webhook) |
| **状态变化** | Status Change | 好友在 active/join me/ask me/busy 之间切换 | Status changes between states | 立即发送 | Immediate (Email/Gotify/Webhook) |
| **世界切换** | World Change | 好友在同一个状态内切换世界 | Friend changes world within same status | 批量发送 | Batch (Email/Gotify/Webhook) |

---

## 开源协议 | License

本项目基于 [MIT](LICENSE) 协议开源。

This project is open-sourced under the [MIT](LICENSE) license.

---

## 致谢 | Acknowledgments

- [VRChat API](https://vrchatapi.github.io/) - 提供 API 文档支持 | API documentation support
- [Gotify](https://gotify.net/) - 开源推送服务 | Open-source push service
- [Node.js](https://nodejs.org/) - 运行时环境 | Runtime environment

---

## 相关链接 | Links

- **作者主页 | Author**: [https://shany.cc/](https://shany.cc/)
- **项目博客 | Blog**: [https://blog.shany.cc/archives/vrc-notifier](https://blog.shany.cc/archives/vrc-notifier)
- **问题反馈 | Issues**: [https://github.com/shanyaojinjn/vrc-notifier/issues](https://github.com/shanyaojinjn/vrc-notifier/issues)

---

Made with ❤️ for VRChat Community
