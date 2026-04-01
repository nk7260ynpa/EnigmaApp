## MODIFIED Requirements

### Requirement: 鍵盤模型與互動

系統 SHALL 渲染 26 個可互動的字母按鍵。每個按鍵 SHALL 具有圓環金屬邊框，且按鍵表面 SHALL 清晰顯示對應的字母標籤。字母標籤 SHALL 使用貼圖方式渲染，確保在各種 3D 視角下皆可辨識。

#### Scenario: 按鍵字母可讀性

- **WHEN** 使用者從預設攝影機視角檢視 3D 鍵盤
- **THEN** 所有 26 個按鍵上的字母 SHALL 清晰可辨識

#### Scenario: 斜角度字母可讀性

- **WHEN** 使用者旋轉至斜角度檢視鍵盤
- **THEN** 按鍵字母 SHALL 仍保持合理的可讀性

#### Scenario: 點擊按鍵觸發加密

- **WHEN** 使用者點擊 3D 鍵盤上的字母按鍵
- **THEN** 系統 SHALL 執行加密並顯示結果，同時播放按鍵按壓動畫

### Requirement: 轉子模型與操作

系統 SHALL 渲染 3 個可旋轉的轉子，顯示當前字母位置。轉子 SHALL 具備以下歷史特徵：指輪（外圈鋸齒邊緣）、中心軸轂、26 個刻度標記。三個轉子 SHALL 使用不同色調以利區分。

#### Scenario: 轉子指輪可辨識

- **WHEN** 3D 場景載入完成
- **THEN** 每個轉子外圈 SHALL 具有可辨識的鋸齒/凹槽結構

#### Scenario: 轉子中心軸轂

- **WHEN** 3D 場景載入完成
- **THEN** 每個轉子中心 SHALL 具有可辨識的金屬軸孔結構

#### Scenario: 轉子刻度標記

- **WHEN** 3D 場景載入完成
- **THEN** 每個轉子側面 SHALL 具有 26 個等距刻度標記

#### Scenario: 轉子色調區分

- **WHEN** 3D 場景載入完成
- **THEN** 左、中、右三個轉子 SHALL 使用不同的金屬色調

#### Scenario: 拖曳設定轉子位置

- **WHEN** 使用者上下拖曳轉子
- **THEN** 轉子 SHALL 旋轉至對應字母位置，帶有旋轉動畫
