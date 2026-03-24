# macosscript

给 macOS 用的 OpenClaw 管理脚本。  
不是把 Linux 脚本硬搬过来，而是按 macOS 的环境重新整理了一版，尽量保留原来的菜单习惯，同时把能真正跑通的部分接上。

## 适合谁

如果你在 macOS 上想要一个更顺手的 OpenClaw 菜单脚本，这个仓库就是干这个的。

## 能做什么

- 安装、启动、停止 OpenClaw
- 管理 API 和默认模型
- 管理插件、技能
- 查看和处理 WebUI 配置
- 管理 Memory / 索引
- 管理权限策略
- 管理多智能体
- 做备份与还原
- 配置 launchctl 开机自启

## 快速开始

### 一键运行

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/mjj0001/macosscript/main/scripts/install.sh)
```

### 本地运行

```bash
chmod +x openclaw-macos-kejilion-rebuild.sh
./openclaw-macos-kejilion-rebuild.sh
```

## 项目结构

- `openclaw-macos-kejilion-rebuild.sh`：主脚本
- `scripts/install.sh`：一键安装 / 运行入口
- `docs/USAGE.md`：使用说明

## 说明

这不是 Linux 原脚本的原样照搬版。  
有些能力在 macOS 和 Linux 上的实现方式本来就不一样，所以这里做的是 **macOS 适配重构版**，目标是：能用、顺手、少踩坑。

## 致谢

这个项目的交互思路和菜单风格，参考并致谢原作者的相关脚本思路。  
原作者仓库放最后，方便直接过去看：  
https://github.com/kejilion/sh
