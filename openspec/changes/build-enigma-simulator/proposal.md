## Why

EnigmaApp 目前僅有專案定義與規格文件，尚無任何可執行的程式碼。需要完成從 Xcode 專案建立到全部功能實作的完整開發，讓使用者能透過 3D 互動介面操作一台虛擬的二戰德軍 Enigma 密碼機。

## What Changes

- 建立 Swift Package Manager 專案結構，設定 SwiftUI 應用程式入口與 Metal 渲染管線
- 實作 Enigma 加密引擎（轉子系統、反射器、接線板、完整加密流程）
- 建構 3D Enigma 密碼機場景（SceneKit + Metal GPU 加速渲染）
- 實作所有互動操作（鍵盤按壓、轉子旋轉、接線板連線、視角控制）
- 建立 macOS 應用程式 UI（設定面板、操作面板、選單列、鍵盤快捷鍵）
- 加入單元測試驗證加密引擎正確性（29 項測試，含歷史測試向量）
- 提供 run.sh 啟動腳本，將 SPM executable 包裝為 .app bundle 以正常啟動 macOS GUI
- 提供 project.yml（XcodeGen 設定），可選擇生成 .xcodeproj 進行開發

## Capabilities

### New Capabilities

- `enigma-engine`: Enigma 密碼機核心加密/解密邏輯，含轉子系統、反射器、接線板
- `3d-simulation`: SceneKit 3D 模型建構、Metal GPU 加速渲染、互動操作與動畫系統
- `macos-app`: macOS 原生應用程式架構，含視窗管理、設定面板、選單列與鍵盤快捷鍵

### Modified Capabilities

（無既有功能需修改）

## Impact

- 新增 Swift Package（Package.swift）與 XcodeGen 設定（project.yml）
- 3D 模型以程式碼生成幾何體（SCNBox、SCNCylinder 等），不依賴外部 3D 資源檔
- 依賴 macOS 14+ SDK（SceneKit、Metal、SwiftUI）
- 無外部第三方依賴
- 啟動方式：執行 `./run.sh` 建構 release 版本並包裝為 .app bundle 啟動（解決 SPM executable 無法正常顯示 macOS 視窗的問題）
