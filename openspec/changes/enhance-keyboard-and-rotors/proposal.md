## Why

目前 3D 場景中鍵盤上的字母標籤過小難以辨識，轉子僅為簡單圓柱體缺乏真實感。需要提升這兩個核心元件的視覺品質，使模擬器更接近歷史 Enigma 機器的外觀。

## What Changes

- **鍵盤字母改善**：將 SCNText 字母標籤改為使用貼圖平面（SCNPlane），增大字體並以白色文字置於黑色按鍵表面中央，確保在 3D 視角下清晰可讀
- **轉子逼真度提升**：
  - 增加指輪（Finger Wheel）— 轉子外圈的鋸齒/凹槽邊緣，用於手動旋轉
  - 增加中心軸轂（Hub）— 轉子中心的金屬軸孔
  - 增加表面刻度標記 — 26 個位置刻線環繞轉子邊緣
  - 為三個轉子使用不同色調以利區分

## Capabilities

### New Capabilities

（無新增功能）

### Modified Capabilities

- `3d-simulation`: 改善鍵盤字母顯示方式與轉子外觀細節

## Impact

- `Sources/EnigmaApp/Scene/EnigmaSceneBuilder.swift`：`buildKey()` 與 `buildRotor()` 方法
