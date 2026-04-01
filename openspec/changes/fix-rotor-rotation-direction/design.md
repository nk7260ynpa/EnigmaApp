## Context

轉子圓柱體在 `buildRotor()` 中以 `eulerAngles.z = π/2` 設定為橫放。但 `updateRotorDisplays()` 使用 `SCNAction.rotateTo(x: angle, y: 0, z: 0)` 設定旋轉，這會將 eulerAngles 全部覆蓋（z 回到 0），破壞圓柱體的橫放姿態，導致旋轉方向與視覺效果錯誤。

## Goals / Non-Goals

**Goals:**

- 轉子在按鍵後正確地繞自身軸心旋轉（模擬真實 Enigma 轉子轉動）
- 拖曳操作的方向直覺正確

**Non-Goals:**

- 不改變轉子的 3D 幾何結構或外觀

## Decisions

### 修正方案：對轉子容器節點（rotorGroup）旋轉，而非轉子主體

**做法**：
- `buildRotor()` 中的 `rotor_display_\(index)` 是圓柱體主體，已設定 `eulerAngles.z = π/2` 不應被動畫覆蓋
- 改為在 `rotorGroup`（名稱 `rotor_\(index)`）上施加旋轉，繞 X 軸旋轉（因為橫放的圓柱體在父座標中的軸心沿 X 方向）
- 使用 SCNTransaction 直接設定 `eulerAngles.x`，而非 `SCNAction.rotateTo`，避免覆蓋子節點的其他角度

**理由**：分離「外殼姿態」與「轉子旋轉」到不同節點層級，互不干擾。

## Risks / Trade-offs

- 無明顯風險，僅修改動畫邏輯
