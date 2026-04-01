# EnigmaApp

模擬二戰期間德軍 Enigma 密碼機的 macOS 原生應用程式。透過 3D 互動介面操作虛擬 Enigma 機器，體驗歷史上的加密與解密流程。

## 功能特色

- 忠實重現 Enigma 密碼機的外觀與運作機制
- 可互動的 3D 模擬操作（鍵盤、轉子、接線板）
- Metal GPU 加速渲染，支援 PBR 材質與即時光影
- 支援實體鍵盤輸入，同步觸發 3D 動畫
- 機器設定匯出/匯入（JSON 格式）
- 歷史準確的加密引擎（通過已知測試向量驗證）

## 技術棧

| 類別 | 技術 |
|------|------|
| 平台 | macOS 14+ (Sonoma) |
| 語言 | Swift 6.0 |
| UI 框架 | SwiftUI |
| 3D 引擎 | SceneKit |
| GPU 加速 | Metal |
| 建構工具 | Swift Package Manager |
| 測試框架 | Swift Testing |

## 專案架構

```text
EnigmaApp/
├── Package.swift              # Swift Package 定義
├── project.yml                # XcodeGen 專案設定
├── Sources/
│   ├── EnigmaCore/            # 加密引擎核心模組
│   │   ├── Rotor.swift            # 轉子模型（5 種歷史轉子）
│   │   ├── Reflector.swift        # 反射器模型（B、C）
│   │   ├── Plugboard.swift        # 接線板模型
│   │   ├── EnigmaMachine.swift    # 完整加密機器
│   │   └── MachineConfiguration.swift  # 設定序列化
│   └── EnigmaApp/             # macOS 應用程式
│       ├── App/
│       │   └── EnigmaApp.swift        # 應用程式入口
│       ├── Scene/
│       │   ├── EnigmaSceneView.swift  # SceneKit SwiftUI 包裝
│       │   └── EnigmaSceneBuilder.swift # 3D 場景建構器
│       ├── ViewModels/
│       │   └── SceneViewModel.swift   # 場景 ViewModel
│       └── Views/
│           ├── ContentView.swift      # 主視窗
│           ├── SettingsPanel.swift     # 設定面板
│           ├── OperationPanel.swift    # 操作面板
│           └── EnigmaCommands.swift   # 選單列
├── Tests/
│   └── EnigmaCoreTests/
│       └── EnigmaCoreTests.swift  # 29 項單元測試
├── openspec/                  # 專案規格文件
│   ├── config.yaml
│   ├── project.md
│   ├── specs/
│   └── changes/
├── README.md
└── LICENSE
```

## 建構與執行

```bash
# 建構專案
swift build

# 執行測試
swift test

# 以 Xcode 開啟（需安裝 xcodegen）
xcodegen generate
open EnigmaApp.xcodeproj
```

## 快捷鍵

| 快捷鍵 | 功能 |
|--------|------|
| A–Z | 加密字母（同步觸發 3D 動畫） |
| ⌘R | 重置轉子位置 |
| ⌘E | 匯出設定 |
| ⌘I | 匯入設定 |

## 授權條款

Apache License 2.0
