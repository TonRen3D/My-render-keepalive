# Render Keepalive — GitHub Actions 定时唤醒

> 每 22 分钟自动 Ping 一次 Render 后端，防止免费版服务休眠。

## 原理

Render 免费版 Web Service 在 **15 分钟无入站请求**后会自动休眠，下次访问需要 30-60 秒冷启动。

本项目通过 GitHub Actions 的定时任务（cron），每 22 分钟向你的 Render 后端发送一次 HTTP 请求，保持服务持续运行。

## 快速开始

### 1. Fork 本仓库

点击右上角 **Fork** 按钮，将本仓库复制到你的 GitHub 账号下。

### 2. 配置 Render 地址

1. 进入 Fork 后的仓库页面
2. 点击 **Settings** → 左侧 **Secrets and variables** → **Actions**
3. 点击 **New repository secret**
4. 填写：
   - **Name**: `RENDER_URL`
   - **Secret**: 你的 Render 后端地址，例如 `https://my-backend.onrender.com`
5. 点击 **Add secret** 保存

### 3. 启用 Actions

1. 点击仓库顶部的 **Actions** 标签
2. 如果提示禁用，点击 **I understand my workflows, go ahead and enable them**
3. 左侧选择 **Ping Render Keepalive** 工作流
4. 点击 **Run workflow** 手动触发一次，验证配置是否正确

### 4. 验证

- 手动触发后，查看工作流运行日志
- 显示 `✅ Ping 成功` 即配置正确
- 之后每 22 分钟自动执行一次

## 配置说明

### 定时频率

当前配置为每 **22 分钟** 一次：

```yaml
schedule:
  - cron: '*/22 * * * *'
```

如需修改频率，编辑 `.github/workflows/ping-render.yml` 中的 cron 表达式：

| 频率 | cron 表达式 | 每天次数 | 每月分钟数(估算) | 免费额度 |
|------|------------|---------|----------------|---------|
| 每5分钟 | `*/5 * * * *` | 288 | ~8640 | ❌ 超额 |
| 每10分钟 | `*/10 * * * *` | 144 | ~4320 | ❌ 超额 |
| 每15分钟 | `*/15 * * * *` | 96 | ~2880 | ❌ 超额 |
| 每20分钟 | `*/20 * * * *` | 72 | ~2160 | ⚠️ 接近 |
| **每22分钟** | `*/22 * * * *` | 65 | ~1950 | ✅ 推荐 |
| 每25分钟 | `*/25 * * * *` | 58 | ~1740 | ✅ 安全 |
| 每30分钟 | `*/30 * * * *` | 48 | ~1440 | ✅ 安全 |

> ⚠️ **GitHub Actions 免费额度**：公开仓库无限，私有仓库每月 2000 分钟。
> 每次运行最少计费 1 分钟。**每22分钟一次约消耗 1950 分钟/月，刚好在免费额度内**。
> Render 休眠阈值是15分钟，考虑到 GitHub cron 调度可能有5-15分钟延迟，22分钟间隔在大多数情况下能保持唤醒。
> 如果发现 Render 仍频繁休眠，可降低到每20分钟（约2160分钟/月，略微超额）。

### Ping 端点

默认 Ping `{RENDER_URL}/api/products`，这是 fansky-shop 项目的轻量端点。

如果你的后端没有这个端点，可以修改工作流中的 `PING_URL`：

```yaml
PING_URL="${URL}"  # Ping 根路径
# 或
PING_URL="${URL}/health"  # Ping 健康检查端点
```

> 即使返回 404 也能唤醒 Render，因为 Render 是根据**入站请求**判断活跃度的，与响应状态码无关。

## 注意事项

### GitHub Actions 调度延迟

GitHub 的 cron 调度**不保证精确执行**，实际可能延迟 5-15 分钟。这是正常现象，不影响防休眠效果（Render 休眠阈值是15分钟）。

### 60天无活动自动禁用

如果仓库超过 60 天没有任何活动（commit、PR、issue 等），GitHub 会自动禁用 scheduled workflows。

解决方法：
- 偶尔向仓库提交一次空 commit
- 或手动触发一次工作流

### Render 冷启动

第一次 Ping 可能超时（Render 正在从休眠中启动），这是正常的。工作流配置了 2 次重试，通常第二次会成功。

### 多后端支持

如果需要同时 Ping 多个 Render 服务：

1. 在 Secrets 中添加 `RENDER_URL_2`、`RENDER_URL_3` 等
2. 在工作流中添加多个 Ping 步骤，或使用 matrix 策略

## 项目结构

```
render-keepalive/
├── .github/
│   └── workflows/
│       └── ping-render.yml    # GitHub Actions 工作流
├── .gitignore
└── README.md                   # 本文件
```

## 常见问题

**Q: 工作流显示成功，但 Render 还是休眠了？**
A: 检查 GitHub Actions 的实际运行时间，可能调度延迟超过了15分钟。可以降低间隔到每10分钟。

**Q: 如何查看 Ping 历史？**
A: 进入仓库 Actions 标签，点击每次运行记录查看详细日志。

**Q: 可以用这个 Ping 其他平台吗？**
A: 可以，修改 `RENDER_URL` 为任意需要保持唤醒的 URL 即可（如 Railway、Fly.io 等）。

**Q: 手动触发怎么操作？**
A: Actions → 选择 "Ping Render Keepalive" → 右侧 "Run workflow" → 选择分支 → 点击 "Run workflow"。

## License

MIT
