# MGLinker iOS

上汽名爵/荣威iOS桌面小组件应用

## 功能概述

- 车辆状态监控（续航、油量/电量、车门锁状态、车内温度、胎压等）
- 远程车控（锁车/解锁、开启后备箱、寻车、空调控制、座椅加热、车窗控制）
- 桌面小组件（WidgetKit，多种尺寸）
- 蓝牙数字钥匙（靠近自动解锁、离开自动落锁）
- 灵动岛（Live Activities，状态栏悬浮显示车辆状态）
- 适用车型：MG7、MG5、MG4、荣威D7、荣威D5X等上汽名爵/荣威系列车型

## 技术架构

| 技术 | 版本/说明 |
|------|----------|
| 开发语言 | Swift 5.9 |
| UI 框架 | SwiftUI |
| 目标 SDK | iOS 16.0+ |
| 构建工具 | Xcode 15+ |
| 网络库 | URLSession (原生) |
| JSON 解析 | Codable (原生) |
| 异步处理 | Swift Concurrency (async/await) |
| 后台任务 | BackgroundTasks |
| 小组件 | WidgetKit |
| 蓝牙 | CoreBluetooth |
| 灵动岛 | ActivityKit |
| 数据持久化 | UserDefaults + SwiftData (iOS 17+) |
| 设计规范 | 遵循 iOS 设计规范，支持深色模式 |

## 项目结构

```
MGLinker-iOS/
├── MGLinker/                    # 主应用
│   ├── App/                     # 应用入口和配置
│   ├── Models/                  # 数据模型
│   ├── Views/                   # SwiftUI 视图
│   ├── ViewModels/              # 视图模型
│   ├── Services/                # 网络和业务逻辑服务
│   ├── Extensions/              # 扩展
│   └── Resources/               # 资源文件
├── MGLinkerWidget/              # WidgetKit 小组件扩展
├── MGLinkerLiveActivity/        # Live Activity 扩展
└── MGLinkerKit/                 # 共享框架（可选）
```

## 开发计划

1. ✅ 项目搭建和基础架构
2. ✅ API 接口对接（车辆状态、远程控制）
3. ✅ 主界面 SwiftUI 实现
4. ✅ WidgetKit 桌面小组件
5. ✅ 蓝牙功能（CoreBluetooth）
6. ✅ 灵动岛功能（Live Activities）
7. ✅ 数据持久化和后台任务
8. ✅ 测试和调试
9. ✅ 打包为 .ipa 文件用于巨魔安装

## 安装说明

1. 下载 MGLinker.ipa 文件
2. 使用巨魔（TrollStore）安装
3. 打开应用，输入手机号码登录
4. 配置车辆信息
5. 添加桌面小组件

## 许可证

Apache License 2.0