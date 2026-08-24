#!/bin/bash
# ============================================================
#  Render Keepalive 一键上传到 GitHub 脚本
#
#  使用方法：
#  1. 在 GitHub 上创建一个空仓库（不要勾选 README）
#  2. 复制仓库地址，例如: https://github.com/你的用户名/render-keepalive.git
#  3. 运行: bash setup.sh https://github.com/你的用户名/render-keepalive.git
# ============================================================

set -e

REPO_URL="$1"

if [ -z "$REPO_URL" ]; then
  echo "❌ 请提供 GitHub 仓库地址"
  echo "用法: bash setup.sh https://github.com/你的用户名/render-keepalive.git"
  exit 1
fi

echo "========================================"
echo "  Render Keepalive 上传到 GitHub"
echo "========================================"
echo "仓库地址: $REPO_URL"
echo ""

# 初始化 Git
if [ ! -d ".git" ]; then
  echo "📦 初始化 Git 仓库..."
  git init
  git branch -M main
else
  echo "✅ Git 已初始化"
fi

# 添加所有文件
echo "📄 添加文件..."
git add -A

# 提交
echo "💾 提交代码..."
git commit -m "init: Render Keepalive - 每12分钟定时唤醒" || echo "（无变更，跳过提交）"

# 添加远程仓库
if git remote get-url origin &>/dev/null; then
  echo "🔄 更新远程仓库地址..."
  git remote set-url origin "$REPO_URL"
else
  echo "🔗 添加远程仓库..."
  git remote add origin "$REPO_URL"
fi

# 推送
echo "🚀 推送到 GitHub..."
git push -u origin main

echo ""
echo "========================================"
echo "  ✅ 上传完成！"
echo "========================================"
echo ""
echo "下一步："
echo "1. 打开仓库: $REPO_URL"
echo "2. 进入 Settings → Secrets and variables → Actions"
echo "3. 添加 Secret: RENDER_URL = 你的Render后端地址"
echo "4. 进入 Actions → 启用工作流 → 手动运行一次验证"
echo ""
