## Context

EnigmaApp 是一個全新的 macOS 原生應用程式，目前僅有專案定義與規格文件，無任何程式碼。需要從零開始建構完整的應用程式，包含加密引擎、3D 渲染場景與 macOS UI 架構。

目標平台為 macOS 14+ (Apple Silicon)，使用 Swift + SwiftUI + SceneKit + Metal 技術棧。

## Goals / Non-Goals

**Goals:**

- 建立可維護的 Xcode 專案結構，清晰分離各模組職責
- 實作歷史準確的 Enigma 加密引擎，通過已知測試向量驗證
- 建構可互動的 3D 場景，使用 Metal 加速達到 60 FPS
- 提供完整的 macOS 應用程式體驗（選單列、快捷鍵、設定管理）

**Non-Goals:**

- 不支援 Enigma M4（海軍四轉子版本），僅實作標準三轉子 Wehrmacht 版本
- 不支援 iOS / iPadOS / visionOS 平台
- 不實作網路功能（多人模擬通訊）
- 不提供教學模式或逐步動畫解說（未來可擴充）

## Decisions

### 1. 架構模式：MVVM + 模組化

**選擇**：採用 MVVM 架構，將專案分為三個核心模組

- `EnigmaCore`：純邏輯加密引擎（無 UI 依賴），可獨立測試
- `EnigmaScene`：SceneKit 3D 場景建構與互動邏輯
- `EnigmaApp`：SwiftUI 應用程式殼層，整合上述模組

**替代方案**：
- 單一模組（Monolith）：簡單但難以測試與維護
- TCA (The Composable Architecture)：過度工程化，引入不必要的第三方依賴

**理由**：MVVM 是 SwiftUI 的自然搭配，模組化確保加密引擎可獨立驗證，3D 場景邏輯與 UI 層解耦。

### 2. 3D 場景建構：程式碼生成幾何體

**選擇**：使用 SceneKit 程式碼（SCNBox、SCNCylinder 等基礎幾何體）組合建構 Enigma 機器模型

**替代方案**：
- 匯入外部 3D 模型檔（.usdz / .obj）：需要 3D 建模工具，增加資源管理複雜度
- RealityKit：更現代但對精細 UI 互動的控制力不如 SceneKit

**理由**：程式碼生成幾何體不需要外部建模工具，開發者可完全掌控每個元件的位置與互動行為。SceneKit 在 macOS 上成熟穩定，搭配 Metal 渲染後端可獲得優秀效能。

### 3. 狀態管理：ObservableObject + Combine

**選擇**：使用 `@Observable` (Swift 5.9 Observation framework) 管理應用程式狀態

- `EnigmaMachine`：加密引擎狀態（轉子位置、接線板設定等）
- `SceneViewModel`：3D 場景互動狀態
- `AppState`：應用程式全域狀態（視窗設定、歷史記錄）

**替代方案**：
- 舊版 `@ObservedObject` / `@StateObject`：macOS 14 已支援 Observation framework，新 API 更簡潔
- 第三方狀態管理（Redux-like）：不必要的複雜度

**理由**：Observation framework 是 Apple 推薦的最新狀態管理方式，效能更好且語法更直覺。

### 4. 設定持久化：Codable + JSON 檔案

**選擇**：機器設定使用 `Codable` 結構序列化為 JSON，支援匯出/匯入

**替代方案**：
- UserDefaults：不適合結構化的機器設定
- Core Data：過度工程化

**理由**：JSON 檔案可讀性好，便於使用者分享設定，Codable 整合自然。

### 5. 單元測試策略：XCTest + 歷史測試向量

**選擇**：使用 XCTest 框架，針對 EnigmaCore 模組撰寫完整單元測試

- 使用已知的歷史 Enigma 測試向量驗證正確性
- 測試加密/解密對稱性
- 測試轉子旋轉與進位機制（含雙重進位）
- 測試接線板替換邏輯

**理由**：加密引擎是應用程式的核心，必須確保邏輯正確性。歷史測試向量提供可靠的驗證基準。

### 6. 啟動方式：run.sh 包裝 .app bundle

**選擇**：提供 `run.sh` 腳本，建構 release 版本後將 executable 包裝為 .app bundle（含 Info.plist），再以 `open` 指令啟動

**替代方案**：
- 直接執行 `.build/debug/EnigmaApp`：SPM executable 缺少 app bundle 結構，macOS 無法正常顯示 SwiftUI 視窗
- 使用 XcodeGen 生成 .xcodeproj：依賴額外工具安裝，且 Homebrew 環境可能有問題

**理由**：SPM executable target 不產生 .app bundle，導致 macOS 無法將其識別為 GUI 應用程式（不顯示 Dock 圖示、不開啟視窗）。run.sh 零依賴地解決此問題，同時保留 project.yml 供需要 Xcode 專案的場景使用。

## Risks / Trade-offs

- **程式碼生成 3D 模型的視覺品質有限** → 使用 PBR 材質與精細的光影設定提升質感，未來可替換為專業 3D 模型
- **SceneKit 已非 Apple 主力發展框架** → 在 macOS 上仍然穩定且功能完整，且比 RealityKit 在 macOS 上更成熟
- **3D 互動（拖曳轉子、接線板連線）實作複雜度高** → 分階段開發，先實作鍵盤互動，再逐步加入轉子與接線板操作
- **歷史準確性驗證需要可靠的測試資料** → 使用多組已公開的 Enigma 測試向量交叉驗證
- **SPM executable 不產生 .app bundle** → run.sh 腳本包裝解決，未來可遷移至正式 Xcode 專案
