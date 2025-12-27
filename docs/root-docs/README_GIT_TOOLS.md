# Git 工具使用说明

## 文件说明

- `~/.git_tools` - Git 工具核心文件（兼容 bash 和 zsh）
- `~/.zshrc` - Zsh 配置文件（已集成 Git 工具）
- `~/.bashrc` - Bash 配置文件（已集成 Git 工具）

## 功能特性

### 1. 显示当前分支
```bash
gb              # 显示当前分支名
git-branch      # 完整命令
```

### 2. 显示详细分支信息
```bash
gbi             # 显示详细分支信息
git-branch-info # 完整命令
```

输出示例：
```
📦 Git 分支信息:
  分支: dev
  提交: 6dcb88f
  状态: ✅ 工作区干净
  远程:
    ⬆️  领先: 10 个提交
```

### 3. 快速切换分支
```bash
gsw <branch-name>           # 快速切换分支
git-switch-branch <branch-name>  # 完整命令
```

### 4. Git 常用命令别名

| 别名 | 完整命令 | 说明 |
|------|---------|------|
| `gst` | `git status` | 查看状态 |
| `gco` | `git checkout` | 切换分支 |
| `gsw` | `git switch` | 切换分支（新方式）|
| `gbr` | `git branch` | 查看分支 |
| `gba` | `git branch -a` | 查看所有分支 |
| `glog` | `git log --oneline --graph --decorate` | 查看日志 |
| `gdiff` | `git diff` | 查看差异 |
| `gadd` | `git add` | 添加文件 |
| `gcm` | `git commit -m` | 提交 |
| `gpush` | `git push` | 推送 |
| `gpull` | `git pull` | 拉取 |

## Prompt 集成

### Zsh
分支信息自动显示在 prompt 右侧（RPROMPT）

### Bash
分支信息自动显示在 prompt 中路径后面

## 使用方法

### 首次使用
1. 重新打开终端，或运行：
   ```bash
   source ~/.zshrc    # zsh
   source ~/.bashrc   # bash
   ```

2. 进入 Git 仓库目录，prompt 会自动显示分支信息

### 测试
```bash
# 进入 Git 仓库
cd /path/to/git/repo

# 查看当前分支
gb

# 查看详细信息
gbi

# 切换分支
gsw main
```

## 注意事项

1. 别名在交互式 shell 中才能使用（正常终端使用）
2. 函数在所有情况下都可以使用（包括脚本中）
3. 如果 prompt 不显示分支，检查配置文件是否正确加载

## 故障排除

### 别名不工作
使用完整函数名：
```bash
git-branch      # 而不是 gb
git-branch-info # 而不是 gbi
```

### Prompt 不显示分支
检查配置文件是否加载：
```bash
# zsh
echo $RPROMPT

# bash
echo $PS1
```

如果为空，重新加载配置：
```bash
source ~/.zshrc  # 或 source ~/.bashrc
```
