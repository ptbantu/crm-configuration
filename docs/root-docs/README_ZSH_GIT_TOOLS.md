# Zsh Git 分支显示工具

## 安装

### 方法 1：添加到 `.zshrc`

```bash
# 在 ~/.zshrc 文件末尾添加：
source ~/.zsh_git_tools
```

### 方法 2：直接使用

```bash
# 加载工具
source ~/.zsh_git_tools

# 或者直接运行
~/.zsh_git_tools
```

## 使用方法

### 1. 显示当前分支（简单）

```bash
gb
# 或
git-branch
```

输出示例：
```
master
```

### 2. 显示详细分支信息

```bash
gbi
# 或
git-branch-info
```

输出示例：
```
📦 Git 分支信息:
  分支: master
  提交: a1b2c3d
  状态: ✅ 工作区干净
  远程:
    ⬆️  领先: 2 个提交
```

### 3. 在 Prompt 中显示分支

编辑 `~/.zshrc`，添加：

```zsh
# 加载工具
source ~/.zsh_git_tools

# 在 prompt 右侧显示分支
setopt PROMPT_SUBST
RPROMPT='$(git-branch-prompt)'
```

或者使用完整版本（参考 `.zshrc.example`）：

```zsh
source ~/.zsh_git_tools
PROMPT='%F{blue}%~%f $(git_prompt_info) %# '
```

### 4. 快速切换分支

```bash
gsw feature/new-feature
# 或
git-switch-branch feature/new-feature
```

## 可用命令和别名

| 命令 | 别名 | 说明 |
|------|------|------|
| `git-branch` | `gb` | 显示当前分支名 |
| `git-branch-info` | `gbi` | 显示详细分支信息 |
| `git-branch-prompt` | `gbp` | 返回用于 prompt 的分支字符串 |
| `git-switch-branch` | `gsw` | 快速切换分支 |

## 命令行参数

直接运行脚本时可以使用参数：

```bash
~/.zsh_git_tools          # 显示当前分支
~/.zsh_git_tools info     # 显示详细信息
~/.zsh_git_tools prompt   # 返回 prompt 字符串
~/.zsh_git_tools switch <branch>  # 切换分支
```

## 示例配置

查看 `~/.zshrc.example` 获取完整的配置示例。

## 提示

- 工具会自动检测是否在 Git 仓库中
- 如果不在 Git 仓库中，会显示相应提示
- 分支状态颜色：
  - 🟢 绿色：工作区干净
  - 🟡 黄色：有未提交的更改
  - 🔵 青色：领先远程提交
  - 🔴 红色：落后远程提交

