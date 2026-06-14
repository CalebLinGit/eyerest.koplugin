[English](README.md) | 简体中文

# 护眼提醒 — KOReader 护眼休息提醒插件

护眼提醒会在你用 [KOReader](https://github.com/koreader/koreader) 阅读时提醒你抬头、让眼睛歇一歇，这样在
Kindle、Kobo 或其它墨水屏设备上长时间阅读也不会让眼睛酸胀。它是 [Stretchly](https://hovancik.net/stretchly/)
风格的休息提醒，核心是 **20-20-20 法则**：用短暂的*迷你休息*和周期性的*长休息*，按你**实际阅读的时长**来计时。
它还内置一个一次性的**睡眠定时器**，适合睡前阅读。相比 KOReader 自带的 *Read timer*，这是一个番茄钟式的增强替代。

## 演示

休息到点时，会有一个全屏倒计时盖住页面——可以跳过、推迟，或（严格模式下）安静地等它结束：

<p align="center">
  <img src="assets/mini-break.gif" alt="迷你休息倒计时" width="360">
</p>

其余时候它都不打扰你：

|  |  |
| :--: | :--: |
| <img src="assets/status-bar.png" width="300"><br>**状态栏** —— 距下次休息的时间（`N分钟后☕`），显示在顶栏和底栏 | <img src="assets/menu.png" width="300"><br>**菜单** —— 启用、立即休息、设睡眠定时、重置；标题内嵌显示下次休息 |
| <img src="assets/settings.png" width="300"><br>**设置** —— 间隔与时长可精确到秒、长休息节奏、严格模式、推迟 | <img src="assets/sleep-timer.png" width="300"><br>**睡眠定时器** —— 一次性的睡前提醒，结束本次阅读 |

> 界面截图为英文版；安装后插件会自动跟随 KOReader 的界面语言显示中文。

## 与自带 Read timer 的区别

| | Read timer | 护眼提醒 |
|---|---|---|
| 设置 | 闹钟和/或间隔，外加自动开始/停止 | 一个 *启用休息提醒* 开关 |
| 计时 | 墙上时间，含发呆时间 | 只在打开书本时计时；关书和休眠时暂停 |
| 休息界面 | 可随手关掉的消息弹窗 | 全屏倒计时，忽略误触 |
| 操作 | —— | 跳过、推迟，或用严格模式强制 |
| 休息层级 | 基础 | 迷你休息 + 周期性长休息 |
| 睡眠定时 | 墙上时间闹钟 | 一次性倒计时 → 全屏「该睡觉了」提醒 |
| 每次休息的墨水屏刷新 | 每秒一次 | 约 5 次（分段倒计时） |

## 安装

护眼提醒是一个 `eyerest.koplugin` 文件夹，放进 KOReader 的 `plugins/` 目录即可。

**下载发布版（推荐）：** 从 [最新 release](https://github.com/CalebLinGit/eyerest.koplugin/releases/latest)
下载 `eyerest.koplugin.zip`，解压后把 `eyerest.koplugin` 文件夹放进 KOReader 的 `plugins/` 目录，使路径为
`…/koreader/plugins/eyerest.koplugin/`。该压缩包只含插件运行所需的文件。

**Kindle / 远程设备**（先在 KOReader 里开启 *Tools → SSH server*）：

```sh
scp -P <端口> -i <你的密钥> -r eyerest.koplugin \
  root@<设备IP>:/mnt/us/koreader/plugins/
```

> 直接 clone 仓库也行，但会带上插件用不到的开发文件（`tests/`、`assets/`）。可运行 `./package.sh`
> 自己生成干净的 `eyerest.koplugin.zip`。

**然后关掉自带的 Read timer** —— 两者共用同一个菜单位置，同时只能开一个：

1. **Tools → Plugin management** → 取消勾选 **Read timer**。
2. 重启 KOReader。

护眼提醒会出现在 **Tools → 护眼提醒** 下。无需改动任何 KOReader 文件。

## 使用

所有功能都在 **Tools → 护眼提醒** 下（菜单项内嵌显示下次休息时间）：

<p align="center">
  <img src="assets/menu-entry.png" alt="Tools 菜单下的护眼提醒" width="360">
</p>

- **启用休息提醒** —— 总开关。
- **立即休息** —— 立刻进入一次迷你休息或长休息。
- **睡眠定时器** —— 一次性倒计时（比如一小时）；到点后全屏提醒你停止阅读。与护眼休息相互独立。
- **重置循环** —— 重新开始循环。
- **设置：**

| 设置项 | 说明 |
|--------|------|
| 迷你休息间隔 | 两次迷你休息之间的阅读时长 |
| 迷你休息时长 | 一次迷你休息的长度（分 : 秒） |
| 长休息：每 N 次迷你休息 | 进入长休息前的迷你休息次数（0 = 关） |
| 长休息时长 | 一次长休息的长度（分 : 秒） |
| 严格模式 | 隐藏「跳过 / 再读一会儿」，休息必须等结束 |
| 推迟 | 「再读一会儿」推迟多久 |
| 在顶栏 / 底栏显示倒计时 | 在状态栏显示距下次休息的时间 |

## 许可

灵感来自 [Stretchly](https://hovancik.net/stretchly/)，基于 [KOReader](https://github.com/koreader/koreader)
构建。以 GNU Affero 通用公共许可证 v3.0（AGPL-3.0）授权——见 [LICENSE](LICENSE)。版权所有 © 2026 Caleb Lin。
