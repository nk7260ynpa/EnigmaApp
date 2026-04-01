# EnigmaApp

模擬二戰期間德軍 Enigma 密碼機的 macOS 原生應用程式。透過 3D 互動介面操作虛擬 Enigma 機器，體驗歷史上的加密與解密流程。

## 功能特色

- 忠實重現 Enigma 密碼機的外觀與運作機制
- 可互動的 3D 模擬操作（鍵盤、轉子、接線板）
- Metal GPU 加速渲染，支援 PBR 材質與即時光影
- 支援實體鍵盤輸入，同步觸發 3D 動畫
- 機器設定匯出/匯入

## 技術棧

| 類別 | 技術 |
|------|------|
| 平台 | macOS 14+ (Sonoma) |
| 語言 | Swift |
| UI 框架 | SwiftUI |
| 3D 引擎 | SceneKit |
| GPU 加速 | Metal |

## 專案架構

```text
EnigmaApp/
├── README.md
├── LICENSE
├── .gitignore
└── openspec/              # 專案規格文件
    ├── config.yaml        # OpenSpec 設定
    ├── project.md         # 專案定義
    ├── specs/             # 功能規格
    │   ├── enigma-engine.md   # 加密引擎規格
    │   ├── 3d-simulation.md   # 3D 模擬規格
    │   └── macos-app.md       # macOS 應用程式規格
    └── changes/           # 變更記錄
        └── archive/
```

## 授權條款

Apache License 2.0
