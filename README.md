# macosscript

🦞 一个给 **macOS** 用的 OpenClaw 管理脚本。  
它不是把 Linux 脚本硬搬过来，而是按 macOS 的环境重新整理的一版：尽量保留原来的菜单习惯，同时把在 macOS 上真正能跑通的部分接好、理顺、收拢。

---

## 🙏 致谢

这个项目的菜单思路、交互习惯和部分设计方向，参考并致谢原作者的相关脚本思路。  
我这里做的是 **macOS 场景下的适配与重构**，不是拿来冒充原创起家。  
原作者仓库：

🔗 https://github.com/kejilion/sh

---

## ✨ 这个仓库是干什么的

如果你在 macOS 上折腾 OpenClaw，很多面向 Linux 的脚本会默认依赖：

- `apt` / `dnf`
- `systemd`
- Linux 风格的服务管理
- VPS / 面板 / 反代思路

这些东西在 macOS 上本来就不通用。  
所以这个仓库做的事情很直接：**把 OpenClaw 常用管理能力整理成一套更适合 macOS 的菜单脚本**。

目标不是"表面能跑"，而是：

- ✅ 能安装
- ✅ 能管理
- ✅ 能维护
- ✅ 少踩平台差异的坑

---

## 👤 适合谁

这个仓库更适合下面这些人：

- 想在 **macOS** 上跑 OpenClaw 的人
- 不想自己手改一堆 Linux 脚本的人
- 想保留菜单式交互，而不是全靠手敲命令的人
- 想把 OpenClaw 的常见管理动作集中到一个入口里的人

如果你本来就是在 Linux / VPS 上跑原版脚本，那你大概率还是更适合直接用原作者那套。  
这个仓库主要解决的是 **macOS 使用场景**。 🍎

---

## 🧩 现在能做什么

目前这套脚本已经覆盖了 OpenClaw 的一批常见管理动作：

### 🚀 基础管理
- 环境自检（检测 Homebrew、Node.js、npm、Xcode CLT 等）
- 安装 OpenClaw
- 启动 / 停止 / 重启 Gateway
- 查看状态与日志
- 更新 OpenClaw
- 卸载 OpenClaw

### 🤖 模型与 API 管理
- 查看当前 provider 列表
- 交互式添加 API provider（自动拉取模型列表）
- 同步 API 供应商模型列表
- 切换 API 协议类型（openai-completions / openai-responses）
- 删除 provider
- 检查 API 连通性
- API 厂商推荐
- 切换默认模型

### 🧱 插件与技能管理
- 安装 / 卸载 / 启用 / 禁用 / 更新插件
- 安装 / 卸载 / 启用 / 禁用 / 更新技能
- 查看已安装的插件和技能

### 🤖 机器人连接对接
- 添加 / 断开 Telegram Bot
- 添加 / 断开 Discord Bot
- 添加 / 断开 Slack Bot
- 添加 / 断开飞书 Bot
- 查看已连接机器人状态

### 🌐 WebUI 与连接配置
- 读取本地 WebUI 地址
- 查看 / 管理 `allowedOrigins`
- 打开本地 WebUI
- 处理常见连接入口

### 🧠 Memory 管理
- 查看 Memory 状态
- 触发索引更新
- 索引修复
- QMD / Local / Auto 三种方案切换

### 🔐 权限管理
- 标准安全模式
- 开发增强模式
- 完全开放模式
- 恢复默认策略
- 运行安全审计
- 恢复上次权限备份

### 🧠 多智能体管理
- 查看智能体
- 新增 / 删除智能体
- 新增 / 移除路由绑定
- 查看会话概况
- 健康检查

### 💾 备份与还原
- 记忆全量备份
- 项目备份
- 还原备份（自动先备份当前状态）
- 删除备份文件

### 🍎 macOS 专属处理
- 使用 `launchctl` 做开机自启（自动创建目录，失败自动 sudo 重试）
- 移除开机自启
- 用 macOS 的方式处理目录、启动和本地运行入口

### ⌨️ 快捷别名
- **首次运行引导**：自动弹出欢迎界面，引导设置快捷别名（支持字母、数字、下划线、连字符任意组合）
- **别名管理**：随时修改或删除别名
- 设置后在任意终端输入别名即可启动脚本

---

## 📺 启动信息头

每次启动脚本时，顶部会自动显示：

```
╔═══════════════════════════════════════════════════════════╗
║  🦞 OPENCLAW macOS 管理工具                              ║
╠═══════════════════════════════════════════════════════════╣
║  脚本版本: v0.3.1-modular
║  安装状态: ✅ 已安装
║  运行状态: ✅ 运行中
║  程序版本: x.x.x
╚═══════════════════════════════════════════════════════════╝
```

一目了然地看到当前安装和运行状态。

---

## ⚡ 快速开始

### 方式一：一键运行（推荐）

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/mjj0001/macosscript/main/scripts/install.sh)
```

> 💡 如果国内网络下载慢，脚本已内置镜像加速和超时重试机制。

### 方式二：手动运行主脚本

```bash
git clone https://github.com/mjj0001/macosscript.git
cd macosscript
chmod +x openclaw-macos-kejilion-rebuild.sh
./openclaw-macos-kejilion-rebuild.sh
```

### 方式三：设置快捷别名后使用

首次运行脚本时会自动引导设置别名（如 `ocm`），之后在任意终端：

```bash
ocm
```

---

## 📁 项目结构

```
macosscript/
├── openclaw-macos-kejilion-rebuild.sh   # 主脚本（菜单入口）
├── scripts/
│   └── install.sh                       # 一键安装 / 运行入口（含镜像加速）
├── lib/
│   ├── common.sh                        # 通用函数、首次运行引导、别名管理
│   ├── core.sh                          # 核心功能：安装/启动/停止/更新/卸载/launchctl
│   ├── api.sh                           # API 管理：添加/同步/切换/删除 provider
│   ├── bot.sh                           # 机器人对接：Telegram/Discord/Slack/飞书
│   ├── plugin.sh                        # 插件管理：安装/卸载/启用/禁用/更新
│   ├── skill.sh                         # 技能管理：安装/卸载/启用/禁用/更新
│   ├── memory.sh                        # Memory 管理：索引/方案切换/修复
│   ├── admin.sh                         # 权限管理 + 多智能体管理
│   └── backup.sh                        # 备份与还原
├── docs/
│   └── USAGE.md                         # 使用说明
└── LICENSE                              # MIT 许可
```

---

## 🛠 设计思路

这个仓库不是追求"逐行复制原脚本"，而是追求：

1. **保留原来那种菜单式管理体验**
2. **把 Linux 专属部分替换成更适合 macOS 的实现**
3. **优先保证可用性，而不是硬凑形式一致**
4. **模块化拆分，便于维护和扩展**

说白了就是一句话：  
**不是照搬，是按 macOS 重新落地。**

---

## ⚠️ 需要提前知道的事

- 这不是 Linux 原脚本的原样照搬版
- 某些依赖 Linux 面板、Nginx 反代、systemd 的能力，不会原封不动复刻
- 某些功能在 macOS 上能做"等价替代"，但实现方式会不同
- 如果 OpenClaw 上游本身有改动，这个脚本也可能需要跟着调整

所以更准确地说，这个仓库是：  
**一个面向 macOS 的 OpenClaw 管理脚本适配重构版**。 🧰

---

## 📌 适用建议

如果你要的是：

- 在 macOS 上方便管理 OpenClaw
- 把常见操作集中进一个脚本
- 减少平台差异带来的折腾

那这个仓库就适合你。 ✅

如果你要的是：

- 完全原汁原味的 Linux 行为
- 深度依赖 Linux 服务器生态的那套体验

那还是建议直接看原作者仓库。 👇

## 🙏 致谢

这个项目的菜单思路、交互习惯和部分设计方向，参考并致谢原作者的相关脚本思路。  
我这里做的是 **macOS 场景下的适配与重构**，不是拿来冒充原创起家。  
原作者仓库：

🔗 https://github.com/kejilion/sh

---

## ✨ 这个仓库是干什么的

如果你在 macOS 上折腾 OpenClaw，很多面向 Linux 的脚本会默认依赖：

- `apt` / `dnf`
- `systemd`
- Linux 风格的服务管理
- VPS / 面板 / 反代思路

这些东西在 macOS 上本来就不通用。  
所以这个仓库做的事情很直接：**把 OpenClaw 常用管理能力整理成一套更适合 macOS 的菜单脚本**。

目标不是“表面能跑”，而是：

- ✅ 能安装
- ✅ 能管理
- ✅ 能维护
- ✅ 少踩平台差异的坑

---

## 👤 适合谁

这个仓库更适合下面这些人：

- 想在 **macOS** 上跑 OpenClaw 的人
- 不想自己手改一堆 Linux 脚本的人
- 想保留菜单式交互，而不是全靠手敲命令的人
- 想把 OpenClaw 的常见管理动作集中到一个入口里的人

如果你本来就是在 Linux / VPS 上跑原版脚本，那你大概率还是更适合直接用原作者那套。  
这个仓库主要解决的是 **macOS 使用场景**。 🍎

---

## 🧩 现在能做什么

目前这套脚本已经覆盖了 OpenClaw 的一批常见管理动作：

### 🚀 基础管理
- 安装 OpenClaw
- 启动 / 停止 Gateway
- 查看状态与日志
- 更新 OpenClaw
- 卸载 OpenClaw

### 🤖 模型与 API 管理
- 查看当前 provider 列表
- 交互式添加 API provider
- 拉取并写入 `/models`
- 切换 API 协议类型
- 删除 provider
- 切换默认模型

### 🧱 插件与技能管理
- 安装 / 启用 / 禁用 / 卸载插件
- 安装 / 卸载技能
- 重载后自动重启相关服务

### 🌐 WebUI 与连接配置
- 读取本地 WebUI 地址
- 查看 / 管理 `allowedOrigins`
- 打开本地 WebUI
- 处理常见连接入口

### 🧠 Memory 管理
- 查看 Memory 状态
- 触发索引更新
- 索引修复
- QMD / Local / Auto 三种方案切换

### 🔐 权限管理
- 标准安全模式
- 开发增强模式
- 完全开放模式
- 恢复默认策略
- 运行安全审计

### 🧠 多智能体管理
- 查看智能体
- 新增 / 删除智能体
- 新增 / 移除路由绑定
- 查看会话概况
- 健康检查

### 💾 备份与还原
- 记忆备份
- 项目备份
- 还原备份
- 删除备份文件

### 🍎 macOS 专属处理
- 使用 `launchctl` 做开机自启
- 用 macOS 的方式处理目录、启动和本地运行入口

---

## ⚡ 快速开始

### 方式一：一键运行（推荐）

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/mjj0001/macosscript/main/scripts/install.sh)
```

### 方式二：手动运行主脚本

```bash
chmod +x openclaw-macos-kejilion-rebuild.sh
./openclaw-macos-kejilion-rebuild.sh
```

---

## 📁 项目结构

- `openclaw-macos-kejilion-rebuild.sh`：主脚本
- `scripts/install.sh`：一键安装 / 运行入口
- `docs/USAGE.md`：使用说明
- `LICENSE`：MIT 许可

---

## 🛠 设计思路

这个仓库不是追求“逐行复制原脚本”，而是追求：

1. **保留原来那种菜单式管理体验**
2. **把 Linux 专属部分替换成更适合 macOS 的实现**
3. **优先保证可用性，而不是硬凑形式一致**

说白了就是一句话：  
**不是照搬，是按 macOS 重新落地。**

---

## ⚠️ 需要提前知道的事

- 这不是 Linux 原脚本的原样照搬版
- 某些依赖 Linux 面板、Nginx 反代、systemd 的能力，不会原封不动复刻
- 某些功能在 macOS 上能做“等价替代”，但实现方式会不同
- 如果 OpenClaw 上游本身有改动，这个脚本也可能需要跟着调整

所以更准确地说，这个仓库是：  
**一个面向 macOS 的 OpenClaw 管理脚本适配重构版**。 🧰

---

## 📌 适用建议

如果你要的是：

- 在 macOS 上方便管理 OpenClaw
- 把常见操作集中进一个脚本
- 减少平台差异带来的折腾

那这个仓库就适合你。 ✅

如果你要的是：

- 完全原汁原味的 Linux 行为
- 深度依赖 Linux 服务器生态的那套体验

那还是建议直接看原作者仓库。 👇

---
