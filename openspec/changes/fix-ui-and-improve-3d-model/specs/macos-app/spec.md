## MODIFIED Requirements

### Requirement: 操作面板

系統 SHALL 提供操作面板，包含文字輸入區、輸出顯示區、重置按鈕與歷史記錄。

#### Scenario: 重置轉子並清除歷程

- **WHEN** 使用者點擊重置按鈕
- **THEN** 所有轉子 SHALL 回到初始位置設定，且輸入文字、輸出文字、操作歷程記錄 SHALL 全部清除

#### Scenario: 文字批次加密

- **WHEN** 使用者在文字輸入區輸入明文
- **THEN** 系統 SHALL 逐字加密並在輸出顯示區即時顯示密文

#### Scenario: 歷史記錄

- **WHEN** 使用者完成一次加密操作
- **THEN** 輸入/輸出對 SHALL 記錄於歷史記錄中

### Requirement: 設定面板

系統 SHALL 提供設定面板，允許使用者配置轉子選擇、轉子順序、初始位置、環設定、反射器選擇與接線板設定。設定面板 SHALL 可作為側邊欄顯示。

#### Scenario: 設定面板佈局穩定性

- **WHEN** 使用者調整視窗大小（包含放大至全螢幕）
- **THEN** 設定面板 SHALL 維持穩定的佈局，Picker 與 TextField 不得過度拉伸，文字排版不得錯亂

#### Scenario: 開啟設定面板

- **WHEN** 使用者從檢視選單選擇「顯示設定面板」
- **THEN** 設定面板 SHALL 以側邊欄形式顯示

#### Scenario: 設定即時生效

- **WHEN** 使用者修改任何設定
- **THEN** 3D 場景 SHALL 即時反映設定變更
