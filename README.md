# macosscript

🦞 一个给 **macOS** 用的 OpenClaw 管理脚本。按 macOS 环境重新整理，保留菜单式交互习惯，把 Linux 专属部分替换为 macOS 实现。

> 参考并致谢原作者：https://github.com/kejilion/sh

---

## ✨ 功能一览

| 模块 | 功能 |
|------|------|
| 🚀 基础管理 | 环境自检、安装、启停 Gateway、日志查看、更新、卸载 |
| 🤖 API 管理 | 添加/同步/切换/删除 provider、连通性检查、模型切换 |
| 🧱 插件与技能 | 安装/卸载/启用/禁用/更新 |
| 🔗 机器人对接 | Telegram / Discord / Slack / 飞书 |
| 🌐 WebUI | 地址查看、allowedOrigins 管理、一键打开 |
| 🧠 Memory | 索引更新/修复、QMD/Local/Auto 方案切换 |
| 🔐 权限管理 | 标准/开发/完全开放模式、安全审计 |
| 🤖 多智能体 | 增删智能体、路由绑定、会话概况、健康检查 |
| 💾 备份还原 | 配置/记忆/项目备份、还原、删除 |
| 🍎 macOS 专属 | launchctl 开机自启、目录/启动适配 |
| ⌨️ 快捷别名 | 首次引导设置、随时修改/删除 |
| 🔄 脚本更新 | 自动检查更新，支持 git 和直下两种模式 |

---

## ⚡ 快速开始

**方式一：一键运行**
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/mjj0001/macosscript/main/scripts/install.sh)
```

**方式二：手动运行**
```bash
git clone https://github.com/mjj0001/macosscript.git
cd macosscript
chmod +x openclaw-macos-kejilion-rebuild.sh
./openclaw-macos-kejilion-rebuild.sh
```

**方式三：快捷别名**

首次运行会自动引导设置别名（如 `ocm`），之后任意终端输入别名即可启动。

---

## 📁 项目结构

```
macosscript/
├── openclaw-macos-kejilion-rebuild.sh   # 主脚本（菜单入口）
├── scripts/install.sh                   # 一键运行入口（含镜像加速）
├── lib/
│   ├── common.sh                        # 通用函数、首次引导、别名管理
│   ├── core.sh                          # 安装/启停/更新/卸载/launchctl
│   ├── api.sh                           # API provider 管理
│   ├── bot.sh                           # 机器人对接
│   ├── plugin.sh                        # 插件管理
│   ├── skill.sh                         # 技能管理
│   ├── memory.sh                        # Memory 管理
│   ├── admin.sh                         # 权限 + 多智能体
│   └── backup.sh                        # 备份与还原
└── LICENSE                              # MIT
```

---

## 💡 设计原则

1. 保留菜单式管理体验
2. Linux 专属部分替换为 macOS 实现
3. 优先可用性，不硬凑形式
4. 模块化拆分，便于维护

**不是照搬，是按 macOS 重新落地。**

---

## ⚠️ 注意

- 不依赖 `apt`/`dnf`/`systemd`/Nginx 反代等 Linux 专属组件
- 如果 OpenClaw 上游有改动，脚本可能需要同步调整
