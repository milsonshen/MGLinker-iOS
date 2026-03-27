# MG Linker iOS 构建说明

## 前提条件

1. macOS 系统（推荐 macOS Ventura 或更高版本）
2. Xcode 15 或更高版本
3. Apple 开发者账号（免费账号即可，用于真机调试）
4. 巨魔（TrollStore）已安装在 iOS 设备上

## 构建步骤

### 1. 克隆或下载项目

```bash
cd MGLinker-iOS
```

### 2. 配置项目

1. 打开 `MGLinker.xcodeproj`
2. 选择主应用 Target（MGLinker）
3. 在 "Signing & Capabilities" 中：
   - 选择您的开发团队
   - 修改 Bundle Identifier（确保唯一）
   - 添加 App Groups 权限：`group.com.mglinker.app`
4. 对小组件和 Live Activity Target 重复相同操作

### 3. 添加 App Groups

1. 在 Apple Developer 网站创建 App Group
2. 在 Xcode 中为每个 Target 添加 App Groups 权限
3. 确保所有 Target 使用相同的 App Group 标识符

### 4. 构建和运行

1. 选择真机设备（非模拟器）
2. 点击运行按钮（或按 Cmd+R）
3. 首次运行需要信任开发者证书：
   - 设置 → 通用 → VPN与设备管理 → 信任开发者

### 5. 打包为 .tipa 文件

使用提供的构建脚本：

```bash
chmod +x build.sh
./build.sh
```

或者手动打包：

1. 在 Xcode 中，选择 Product → Archive
2. 完成后，在 Organizer 中选择归档
3. 点击 "Distribute App"
4. 选择 "Ad Hoc"
5. 导出到文件夹
6. 将生成的 .ipa 文件重命名为 .tipa

### 6. 使用巨魔安装

1. 将 .tipa 文件传输到 iOS 设备
2. 使用巨魔打开 .tipa 文件
3. 点击安装
4. 首次打开应用时，授予必要权限

## 注意事项

1. **Bundle Identifier**：必须唯一，建议使用反向域名格式
2. **App Groups**：必须正确配置，否则小组件无法共享数据
3. **权限**：应用需要蓝牙、位置、通知等权限
4. **API Token**：需要从官方 APP 抓取有效的 ACCESS_TOKEN
5. **车型支持**：目前支持名爵和荣威系列车型

## 故障排除

### 1. 构建失败
- 检查 Xcode 版本是否符合要求
- 清理构建文件夹（Product → Clean Build Folder）
- 检查签名配置

### 2. 小组件不更新
- 检查 App Groups 配置
- 确认 ACCESS_TOKEN 有效
- 检查网络连接

### 3. 蓝牙连接失败
- 确认车辆支持蓝牙数字钥匙
- 检查蓝牙权限设置
- 确保车辆蓝牙处于可发现模式

### 4. 灵动岛不显示
- 确认 iOS 版本 ≥ 16.1
- 检查 Live Activity 权限
- 在设置中启用灵动岛功能

## 版本信息

- 当前版本：1.0
- 支持 iOS：16.0+
- 开发语言：Swift 5.9
- UI 框架：SwiftUI

## 许可证

Apache License 2.0