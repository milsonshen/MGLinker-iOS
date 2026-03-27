# 使用免费Apple开发者账号配置GitHub Actions

## 步骤概览

1. 注册Apple开发者账号（免费）
2. 创建App ID和App Group
3. 创建证书和描述文件
4. 配置GitHub仓库
5. 触发构建并下载

## 详细步骤

### 第一步：注册Apple开发者账号（免费）

1. 访问 https://developer.apple.com
2. 点击 "Account" 登录您的Apple ID
3. 如果未注册过开发者，会提示注册
4. 选择 "Individual" 类型
5. 同意协议并完成注册（免费）

### 第二步：创建App ID

1. 登录 https://developer.apple.com/account
2. 进入 "Certificates, Identifiers & Profiles"
3. 点击 "Identifiers" → "+"
4. 选择 "App IDs" → "Continue"
5. 选择 "App" → "Continue"
6. 填写信息：
   - Description: MG Linker
   - Bundle ID: Explicit
   - Bundle ID: com.mglinker.app
7. 在 "Capabilities" 中勾选：
   - App Groups
   - Push Notifications（可选）
8. 点击 "Continue" → "Register"

### 第三步：创建App Group

1. 在 "Certificates, Identifiers & Profiles" 中
2. 点击 "Identifiers" → "App Groups"
3. 点击 "+" 创建新的App Group
4. 填写信息：
   - Description: MG Linker Group
   - Identifier: group.com.mglinker.app
5. 点击 "Continue" → "Register"

### 第四步：关联App Group到App ID

1. 返回 "Identifiers" → "App IDs"
2. 点击刚才创建的 "com.mglinker.app"
3. 在 "App Groups" 部分点击 "Configure"
4. 选择 "group.com.mglinker.app"
5. 点击 "Continue" → "Save"

### 第五步：创建证书（使用Windows）

由于没有macOS，使用OpenSSL创建证书签名请求：

```powershell
# 1. 安装OpenSSL（如果未安装）
# 下载：https://slproweb.com/products/Win32OpenSSL.html

# 2. 生成私钥和CSR
openssl req -new -newkey rsa:2048 -nodes -keyout private.key -out csr.csr -subj "/emailAddress=your@apple.id/CN=MG Linker/C=CN"

# 3. 将csr.csr文件保存好
```

### 第六步：在Apple Developer网站创建证书

1. 进入 "Certificates, Identifiers & Profiles"
2. 点击 "Certificates" → "+"
3. 选择 "Apple Development"
4. 点击 "Continue"
5. 上传刚才生成的 `csr.csr` 文件
6. 点击 "Continue" → "Download"
7. 保存下载的 `.cer` 文件（如：development.cer）

### 第七步：转换证书格式

```powershell
# 1. 将.cer转换为.pem
openssl x509 -in development.cer -inform DER -out development.pem -outform PEM

# 2. 将私钥和证书合并为.p12
openssl pkcs12 -export -out certificate.p12 -inkey private.key -in development.pem -password pass:您的密码

# 3. 记住这个密码，后面需要用到
```

### 第八步：创建描述文件

1. 进入 "Profiles" → "+"
2. 选择 "iOS App Development"
3. 选择App ID: com.mglinker.app
4. 选择证书（刚才创建的）
5. 选择测试设备（需要添加您的iOS设备UDID）
6. 填写名称：MG Linker Development
7. 点击 "Continue" → "Download"
8. 保存 `.mobileprovision` 文件

### 第九步：获取Base64编码

```powershell
# 编码描述文件
[Convert]::ToBase64String([IO.File]::ReadAllBytes("path/to/MG_Linker_Development.mobileprovision"))

# 编码证书
[Convert]::ToBase64String([IO.File]::ReadAllBytes("path/to/certificate.p12"))
```

### 第十步：获取团队ID

1. 在 https://developer.apple.com/account 页面
2. 找到 "Membership" 部分
3. 复制 "Team ID"（如：A1B2C3D4E5）

### 第十一步：配置GitHub Secrets

1. 进入您的GitHub仓库
2. 点击 "Settings" → "Secrets and variables" → "Actions"
3. 点击 "New repository secret"
4. 添加以下secrets：

| Name | Value |
|------|-------|
| PROVISIONING_PROFILE | 描述文件的Base64编码 |
| SIGNING_CERTIFICATE | 证书的Base64编码 |
| SIGNING_CERTIFICATE_PASSWORD | 证书密码 |
| DEVELOPMENT_TEAM | 团队ID |

### 第十二步：更新Xcode项目配置

需要修改 `MGLinker.xcodeproj/project.pbxproj` 文件中的Bundle Identifier：

1. 打开 `project.pbxproj` 文件
2. 搜索 `PRODUCT_BUNDLE_IDENTIFIER`
3. 将所有 `com.mglinker.app` 替换为您的实际Bundle ID（如果不同）
4. 保存并推送到GitHub

### 第十三步：触发构建

1. 推送代码到GitHub
2. 进入仓库 → Actions
3. 点击 "Build MG Linker iOS"
4. 点击 "Run workflow" → "Run workflow"
5. 等待构建完成（约10-15分钟）

### 第十四步：下载并安装

1. 构建完成后，进入Actions页面
2. 点击最新的工作流运行
3. 在 "Artifacts" 部分下载 "MG-Linker-iOS"
4. 解压获得 `.ipa` 和 `.tipa` 文件
5. 使用巨魔安装 `.tipa` 文件

### 第十五步：信任开发者证书

1. 首次打开应用会提示 "未受信任的企业级开发者"
2. 进入 设置 → 通用 → VPN与设备管理
3. 找到您的开发者证书并信任
4. 重新打开应用

## 注意事项

1. **免费账号限制**：每7天需要重新安装应用
2. **设备限制**：每台设备需要单独注册UDID
3. **证书有效期**：免费证书有效期7天
4. **描述文件**：需要包含所有测试设备的UDID

## 常见问题

### Q: 如何获取iOS设备的UDID？
A: 使用iTunes或第三方工具（如 https://udid.io）

### Q: 构建失败提示证书错误？
A: 检查证书和描述文件是否匹配，Bundle ID是否正确

### Q: 应用闪退？
A: 检查App Groups配置是否正确

### Q: 如何延长安装有效期？
A: 必须购买付费开发者账号（$99/年）

## 下一步

完成以上步骤后，您应该能够成功构建并安装MG Linker iOS版本。