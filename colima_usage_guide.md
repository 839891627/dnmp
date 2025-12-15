# Colima 使用指南

本文档旨在帮助您了解和使用 Colima 作为 Docker Desktop 的轻量级替代方案。

## 什么是 Colima？

Colima 是一个轻量级的容器运行时，专为 macOS 和 Linux 设计。它提供了与 Docker Desktop 类似的功能，但资源占用更少，启动速度更快。

## 安装 Colima

### 前提条件
确保您已安装 Homebrew。如果没有，请先安装：
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 安装步骤
```bash
# 安装 Colima
brew install colima

# 安装 Docker CLI 工具（注意：这只是 CLI，不是 Docker Desktop）
brew install docker docker-compose
```

## 启动 Colima

### 基本启动
```bash
# 启动 Colima（使用默认配置）
colima start
```

### 自定义配置启动
```bash
# 启动 Colima 并指定资源配置
colima start --cpu 2 --memory 2 --disk 10
```

### 带代理配置启动（适用于网络受限环境）
```bash
# 设置代理环境变量
export https_proxy=http://127.0.0.1:6152
export http_proxy=http://127.0.0.1:6152
export all_proxy=socks5://127.0.0.1:6153

# 使用代理启动 Colima
colima start
```

## 常用 Colima 命令

### 状态管理
```bash
# 检查 Colima 状态
colima status

# 详细状态信息
colima status --verbose

# 停止 Colima
colima stop

# 重启 Colima
colima restart

# 删除 Colima 实例
colima delete
```

### 配置管理
```bash
# 查看当前配置
colima ssh -- cat /etc/colima/colima.yaml

# 编辑配置文件
colima ssh -- nano /etc/colima/colima.yaml
```

## Docker 环境配置

### 设置 Docker Socket 环境变量
为了让 Docker CLI 能够连接到 Colima，需要设置环境变量：

```bash
# 临时设置（当前会话有效）
export DOCKER_HOST=unix:///Users/$(whoami)/.colima/default/docker.sock

# 永久设置（添加到 shell 配置文件）
echo 'export DOCKER_HOST=unix:///Users/$(whoami)/.colima/default/docker.sock' >> ~/.zshrc
source ~/.zshrc
```

### 验证 Docker 连接
```bash
# 检查 Docker 版本
docker version

# 运行测试容器
docker run --rm hello-world
```

## 使用您的 PHP 开发环境

### 启动服务
```bash
# 进入项目目录
cd /Users/$(whoami)/php/dnmp

# 启动所有服务
docker-compose up -d

# 启动特定服务
docker-compose up -d nginx php72 mysql redis
```

### 管理服务
```bash
# 查看运行中的容器
docker-compose ps

# 查看服务日志
docker-compose logs

# 停止服务
docker-compose down

# 重启特定服务
docker-compose restart nginx
```

## 资源优化优势

使用 Colima 相比 Docker Desktop 的优势：

1. **更低的资源占用**：CPU 和内存使用量显著减少
2. **更快的启动时间**：启动速度通常比 Docker Desktop 快
3. **更好的性能**：在某些场景下性能表现更优
4. **更小的安装包**：安装文件更小，占用磁盘空间更少

## 故障排除

### 网络连接问题
如果遇到镜像下载失败的问题：

1. 确认代理设置是否正确
2. 尝试使用不同的网络环境
3. 手动拉取镜像：
   ```bash
   docker pull php:7.2-fpm
   docker pull nginx:alpine
   docker pull mysql:8.0
   docker pull redis:7-alpine
   ```

### 权限问题
如果遇到权限问题：

1. 确保 Docker socket 路径正确
2. 检查用户权限：
   ```bash
   ls -la /Users/$(whoami)/.colima/default/docker.sock
   ```

### 服务启动失败
如果服务启动失败：

1. 查看详细日志：
   ```bash
   docker-compose logs [service_name]
   ```
2. 检查配置文件是否有语法错误
3. 确认端口没有被占用

## 常见问题解答

### Q: 如何在开机时自动启动 Colima？
A: 可以使用 launchd 创建自启动服务，或者在 shell 配置文件中添加启动命令。

### Q: Colima 支持 Docker Compose 吗？
A: 是的，Colima 完全支持 Docker Compose，您可以像使用 Docker Desktop 一样使用它。

### Q: 如何升级 Colima？
A: 使用 Homebrew 升级：
```bash
brew upgrade colima
```

### Q: 如何查看 Colima 的资源使用情况？
A: 可以通过以下命令查看：
```bash
colima status --verbose
```

## 参考资料

- [Colima GitHub 仓库](https://github.com/abiosoft/colima)
- [Docker CLI 文档](https://docs.docker.com/engine/reference/commandline/cli/)
- [Docker Compose 文档](https://docs.docker.com/compose/)