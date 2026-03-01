# VRC-Notifier

**VRChat Friend Status Monitor & Notification Tool**

[![Node.js](https://img.shields.io/badge/Node.js-18+-339933?style=flat&logo=node.js&logoColor=white)](https://nodejs.org/)
[![Express](https://img.shields.io/badge/Express-4.x-000000?style=flat&logo=express&logoColor=white)](https://expressjs.com/)
[![SQLite](https://img.shields.io/badge/SQLite-3-003B57?style=flat&logo=sqlite&logoColor=white)](https://sqlite.org/)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?style=flat&logo=docker&logoColor=white)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

<p align="center">
  <a href="./README.md">中文</a> | <b>English</b>
</p>

A secure and reliable background monitoring tool that tracks friend online status changes in real-time

---

## Core Features

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

## Quick Start

### Requirements

- Node.js 18.0 or higher
- Supported platforms: Windows / macOS / Linux

### Installation

#### Method 1: Run Directly

```bash
# Clone repository
git clone https://github.com/shanyaojinjn/vrc-notifier.git
cd vrc-notifier

# Install dependencies
npm install

# Start service
npm start
```

#### Method 2: Docker Deployment (Recommended)

1. **Create project directory**

```bash
mkdir vrc-notifier && cd vrc-notifier
```

2. **Create `docker-compose.yml`**

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
      # Data persistence
      - ./data:/app/data
    networks:
      - vrc-network

networks:
  vrc-network:
    driver: bridge
```

3. **Start service**

```bash
docker-compose up -d
```

4. **Access service**

Open browser: http://localhost:5270

**Notes:**
- Data will be saved in `./data` directory, ensure write permissions
- To stop service, run `docker-compose down`
- View logs: `docker-compose logs -f`

---

## API Security & Rate Limiting

A **multi-layer rate limiting protection system** is implemented, strictly following VRChat official API specifications:

### Tiered Rate Limiting (Conservative Design)

```javascript
// Actual rate limiting configuration (strictly below official limits with safety margin)
const API_RATE_LIMITS = {
  userProfile: { maxRequests: 1, windowMs: 60 * 1000 },   // User profile: ≤1/min
  friendStatus: { maxRequests: 2, windowMs: 60 * 1000 },  // Friend status: ≤2/min (official: 5)
  worldInfo: { maxRequests: 6, windowMs: 60 * 1000 }      // World info: ≤6/min (official: 10)
};
```

**VRChat Official vs Our Limits:**

| API Type | Official | Our Limit | Safety Margin |
|---------|---------|-----------|--------------|
| User Profile | ≤1/min | 1/min | 100% Compliant |
| Friend Status | ≤5/min | 2/min | 60% Margin |
| World Info | ≤10/min | 6/min | 40% Margin |

### Global Rate Limit Protection

When rate limiting is detected, the system automatically enters **global pause mode**:

- Auto-pause all API requests for 60 seconds
- Send warning notifications to users
- Frontend displays real-time rate limit status

### Smart Caching Strategy

| Cache Type | Duration | Description |
|-----------|---------|-------------|
| Friend Status | 30s | Reduce frequent friend list queries |
| World Info | 10min | Avoid duplicate world name queries |
| Friend List | 1 year | Permanent cache until manual refresh |

### Debounce Mechanism

To prevent false positives from incomplete data returned by VRChat servers, we implemented a **debounce mechanism**:

- Requires 3 consecutive consistent status checks to confirm change
- Prevents false alerts from single API anomalies
- Real status changes delayed by max 30 seconds

---

## User Privacy Protection

### Data Security

1. **Local Storage** - All data (including login credentials) stored locally in SQLite database
2. **Encrypted Storage** - Sensitive info encrypted with AES-256-CBC
3. **Cookie Management** - VRChat login sessions managed independently
4. **No Data Upload** - No data uploaded to third-party servers

### "Remember Me" Security

- Cookie data encrypted with AES-256-CBC
- Encryption key stored in server environment variables
- Even if database is copied, Cookie cannot be decrypted
- Passwords are never saved (only encrypted session tokens)

### Single-User Design

**VRC-Notifier is designed for personal use only and does not support multi-account management.**

We **intentionally do not implement** multi-account management for the following security reasons:

1. **User Data Privacy** - VRChat accounts contain personal social data that should not be accessed by others
2. **Session Security Risk** - Multi-account management increases security risks
3. **Clear Responsibility** - Single-user mode clarifies security responsibility boundaries

### VRChat Game Compatibility

⚠️ **Important Limitation**: This tool **cannot run simultaneously with the VRChat game client**.

VRChat's security mechanism does not allow the same account to be logged in from multiple places simultaneously. To monitor friend status, please keep the game closed.

---

## Notification Types

| Change Type | Trigger Condition | Notification Method |
|------------|------------------|-------------------|
| **Online** | Friend offline → online | Immediate (Email/Gotify/Webhook) |
| **Offline** | Friend online → offline | Immediate (Email/Gotify/Webhook) |
| **Status Change** | Status changes between states | Immediate (Email/Gotify/Webhook) |
| **World Change** | Friend changes world within same status | Batch (Email/Gotify/Webhook) |

---

## License

This project is open-sourced under the [MIT](LICENSE) license.

---

## Acknowledgments

- [VRChat API](https://vrchatapi.github.io/) - API documentation support
- [Gotify](https://gotify.net/) - Open-source push service
- [Node.js](https://nodejs.org/) - Runtime environment

---

## Links

- **Author**: [https://shany.cc/](https://shany.cc/)
- **Blog**: [https://blog.shany.cc/archives/vrc-notifier](https://blog.shany.cc/archives/vrc-notifier)
- **Issues**: [https://github.com/shanyaojinjn/vrc-notifier/issues](https://github.com/shanyaojinjn/vrc-notifier/issues)

---

Made with ❤️ for VRChat Community
