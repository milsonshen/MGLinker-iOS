# 使用 GitHub Actions 编译 MG Linker iOS

## 方案概述

由于您没有 macOS 设备，可以使用 GitHub Actions（免费）在云端 macOS 环境中编译 iOS 应用。

## 前提条件

1. GitHub 账号（免费）
2. Apple 开发者账号（免费即可，用于真机调试）
3. 本地生成的证书和描述文件

## 详细步骤

### 第一步：创建 GitHub 仓库

1. 登录 GitHub（https://github.com）
2. 点击 "New repository"
3. 仓库名：`MGLinker-iOS`
4. 选择 "Private"（推荐）
5. 点击 "Create repository"

### 第二步：上传代码

1. 下载 GitHub Desktop（https://desktop.github.com）或使用 Git 命令行
2. 克隆仓库到本地
3. 将 `D:\迅雷下载\MGLinker-iOS` 中的所有文件复制到仓库目录
4. 提交并推送代码

### 第三步：配置 Apple 证书和描述文件

#### 1. 在 Windows 上生成证书

由于没有 macOS，需要使用以下方法之一：

**方法 A：使用 OpenSSL（推荐）**
```bash
# 安装 OpenSSL（如果未安装）
# 下载：https://slproweb.com/products/Win32OpenSSL.html

# 生成证书签名请求 (CSR)
openssl req -new -newkey rsa:2048 -nodes -keyout private.key -out csr.csr -subj "/emailAddress=your@email.com/CN=MG Linker/C=CN"

# 在 Apple Developer 网站创建证书并下载
```

**方法 B：借用 Mac 设备**
- 借用朋友的 Mac 临时生成证书
- 或使用虚拟机安装 macOS（注意：违反 Apple 许可协议）

#### 2. 在 Apple Developer 网站创建证书

1. 登录 https://developer.apple.com
2. 进入 "Certificates, Identifiers & Profiles"
3. 创建 "Apple Development" 证书
4. 下载证书文件（.cer）

#### 3. 创建 App ID 和描述文件

1. 创建 App ID：`com.mglinker.app`
2. 启用 App Groups 功能
3. 创建 App Group：`group.com.mglinker.app`
4. 创建描述文件（Provisioning Profile）

### 第四步：配置 GitHub Secrets

在 GitHub 仓库设置中添加以下 Secrets：

1. 进入仓库 → Settings → Secrets and variables → Actions
2. 添加以下 secrets：

| Secret 名称 | 说明 |
|------------|------|
| `PROVISIONING_PROFILE` | 描述文件的 Base64 编码 |
| `SIGNING_CERTIFICATE` | .p12 证书文件的 Base64 编码 |
| `SIGNING_CERTIFICATE_PASSWORD` | .p12 证书密码 |
| `DEVELOPMENT_TEAM` | Apple 开发者团队 ID |

#### 如何获取 Base64 编码

在 Windows PowerShell 中：
```powershell
# 编码描述文件
[Convert]::ToBase64String([IO.File]::ReadAllBytes("path/to/profile.mobileprovision"))

# 编码证书
[Convert]::ToBase64String([IO.File]::ReadAllBytes("path/to/certificate.p12"))
```

### 第五步：触发构建

1. 推送代码到 GitHub
2. 进入仓库 → Actions → "Build MG Linker iOS"
3. 点击 "Run workflow"（手动触发）
4. 等待构建完成（约 10-15 分钟）

### 第六步：下载构建结果

1. 构建完成后，进入 Actions 页面
2. 点击最新的工作流运行
3. 在 "Artifacts" 部分下载 "MG-Linker-iOS"
4. 解压后获得 `.ipa` 和 `.tipa` 文件

### 第七步：使用巨魔安装

1. 将 `.tipa` 文件传输到 iOS 设备
2. 使用巨魔打开并安装
3. 首次运行需要信任开发者证书

## 常见问题

### Q1: 没有 Apple 开发者账号怎么办？
A: 可以使用免费 Apple ID，但每 7 天需要重新安装应用。

### Q2: 构建失败怎么办？
A: 检查 Actions 日志，常见原因：
- 证书或描述文件配置错误
- Bundle Identifier 不匹配
- App Groups 未正确配置

### Q3: 可以自动构建吗？
A: 是的，工作流已配置为每次推送到 main 分支时自动构建。

### Q4: 如何更新应用？
A: 修改代码后推送到 GitHub，自动触发新构建。

## 备选方案

### 方案 1：使用云端 Mac 服务
- **MacinCloud**：https://www.macincloud.com（约 $1/小时）
- **MacStadium**：https://www.macstadium.com
- **AWS EC2 Mac**：https://aws.amazon.com/ec2/mac/

### 方案 2：使用跨平台编译工具
- **React Native**：需要重写代码
- **Flutter**：需要重写代码
- **Xamarin**：需要重写代码

### 方案 3：使用第三方打包服务
- **Appcircle**：https://appcircle.io
- **Bitrise**：https://bitrise.io
- **CircleCI**：https://circleci.com

## 注意事项

1. **安全性**：不要将证书密码提交到代码库
2. **费用**：GitHub Actions 免费额度有限（2000 分钟/月）
3. **合规性**：确保遵守 Apple 开发者协议
4. **测试**：建议在真机上充分测试

## 技术支持

如遇到问题，请检查：
1. GitHub Actions 日志
2. Apple Developer 网站配置
3. 证书和描述文件是否匹配