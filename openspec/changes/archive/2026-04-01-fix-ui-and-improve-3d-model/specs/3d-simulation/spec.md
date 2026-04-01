## MODIFIED Requirements

### Requirement: 3D 場景建構

系統 SHALL 使用 SceneKit 建構完整的 Enigma 密碼機 3D 場景，包含機體外殼、鍵盤、燈板、轉子、接線板與反射器。場景 SHALL 使用 Metal 作為渲染後端。3D 模型的尺寸比例 SHALL 盡可能符合歷史 Wehrmacht Enigma I 實機。

#### Scenario: 場景載入

- **WHEN** 應用程式啟動
- **THEN** 3D Enigma 密碼機場景 SHALL 正確載入並顯示於主視窗

#### Scenario: Metal 渲染啟用

- **WHEN** 3D 場景渲染時
- **THEN** SceneKit SHALL 使用 Metal API 作為渲染後端

### Requirement: 機體外殼模型

系統 SHALL 渲染 Enigma 密碼機的木質箱體外殼。外殼尺寸比例 SHALL 接近歷史實機（約 340×130×270mm），具有可辨識的上蓋板結構（打開角度約 25°）。

#### Scenario: 外殼尺寸比例

- **WHEN** 3D 場景載入完成
- **THEN** 機體外殼 SHALL 呈現接近歷史實機的高度比例，不得過於扁平

#### Scenario: 上蓋板結構

- **WHEN** 3D 場景載入完成
- **THEN** 機體 SHALL 具有可辨識的後方上蓋板，呈現打開狀態

### Requirement: 轉子模型與操作

系統 SHALL 渲染 3 個可旋轉的轉子，顯示當前字母位置。轉子直徑 SHALL 接近歷史實機比例（約 100mm），三個轉子 SHALL 緊密排列。轉子窗口 SHALL 具有金屬框與玻璃視窗細節。

#### Scenario: 轉子尺寸比例

- **WHEN** 3D 場景載入完成
- **THEN** 轉子大小 SHALL 與機體外殼成合理比例，直徑接近歷史實機

#### Scenario: 轉子窗口細節

- **WHEN** 3D 場景載入完成
- **THEN** 每個轉子上方 SHALL 具有金屬框視窗，顯示當前字母

#### Scenario: 拖曳設定轉子位置

- **WHEN** 使用者上下拖曳轉子
- **THEN** 轉子 SHALL 旋轉至對應字母位置，帶有旋轉動畫

### Requirement: 鍵盤模型與互動

系統 SHALL 渲染 26 個可互動的字母按鍵。按鍵 SHALL 具有圓環金屬邊框細節。

#### Scenario: 按鍵外觀

- **WHEN** 3D 場景載入完成
- **THEN** 每個按鍵 SHALL 具有可辨識的圓環金屬邊框

#### Scenario: 點擊按鍵觸發加密

- **WHEN** 使用者點擊 3D 鍵盤上的字母按鍵
- **THEN** 系統 SHALL 執行加密並顯示結果，同時播放按鍵按壓動畫

### Requirement: 燈板模型與回饋

系統 SHALL 渲染 26 個字母燈泡。每個燈泡 SHALL 具有圓形底座燈罩細節。

#### Scenario: 燈泡外觀

- **WHEN** 3D 場景載入完成
- **THEN** 每個燈泡 SHALL 具有可辨識的圓形底座燈罩

#### Scenario: 燈泡亮起

- **WHEN** 加密結果為某字母
- **THEN** 對應燈泡 SHALL 亮起並帶有 Bloom 發光效果
