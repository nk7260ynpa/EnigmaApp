## Why

EnigmaApp 存在三個需要修正的問題：重置按鈕未清除操作歷程、設定面板在視窗放大時排版錯亂、3D 模型尺寸比例與歷史原機差距過大。這些問題影響使用體驗與模擬器的歷史還原度。

## What Changes

- **修正重置按鈕行為**：按下重置時同步清除 `history` 陣列，使操作歷程面板歸零
- **修正設定面板排版**：為 Form、Picker、TextField 加入適當的寬度約束與佈局設定，防止視窗放大時元件過度拉伸
- **改善 3D 模型歷史準確度**：
  - 修正機體外殼比例（真實尺寸約 340×150×270mm，目前高度僅 60mm 過於扁平）
  - 增大轉子尺寸（真實直徑約 100mm，目前僅 50mm）
  - 增加機體細節：前蓋板翻蓋結構、轉子窗口金屬框、接線板面板傾斜角度
  - 增加按鍵圓環金屬邊框、燈板圓形玻璃罩等細節
  - 調整整體比例使各元件相對位置更符合歷史照片

## Capabilities

### New Capabilities

（無新增功能）

### Modified Capabilities

- `macos-app`: 修正重置按鈕需同步清除操作歷程的需求；修正設定面板在視窗縮放時的佈局穩定性
- `3d-simulation`: 修正 3D 模型尺寸比例與細節，提升歷史還原度

## Impact

- `Sources/EnigmaApp/ViewModels/SceneViewModel.swift`：resetPositions() 方法
- `Sources/EnigmaApp/Views/SettingsPanel.swift`：佈局約束
- `Sources/EnigmaApp/Scene/EnigmaSceneBuilder.swift`：3D 模型幾何體尺寸與材質
