## Why

3D 場景中轉子旋轉方向不正確。轉子圓柱體以 `eulerAngles.z = π/2` 橫放（軸心指向 X 方向），但旋轉動畫使用 `rotateTo(x: angle)` 繞 X 軸旋轉，導致旋轉方向與預期不符。此外 `rotateTo` 會覆蓋轉子的初始 eulerAngles，破壞圓柱體的橫放姿態。

## What Changes

- **修正轉子旋轉動畫**：不使用 `rotateTo`（會覆蓋所有 eulerAngles），改為直接設定轉子容器節點的旋轉角度，在正確的軸上旋轉
- **修正拖曳方向對應**：確保上下拖曳對應轉子字母的遞增/遞減方向

## Capabilities

### New Capabilities

（無新增功能）

### Modified Capabilities

- `3d-simulation`: 修正轉子旋轉動畫的旋轉軸與方向

## Impact

- `Sources/EnigmaApp/ViewModels/SceneViewModel.swift`：`updateRotorDisplays()` 方法
