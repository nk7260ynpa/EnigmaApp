## ADDED Requirements

### Requirement: 應用程式主視窗

系統 SHALL 以 SwiftUI WindowGroup 建立主視窗，顯示 3D Enigma 密碼機場景。視窗 SHALL 支援縮放與全螢幕模式。

#### Scenario: 應用程式啟動

- **WHEN** 使用者啟動 EnigmaApp
- **THEN** 主視窗 SHALL 開啟並顯示 3D Enigma 密碼機場景

#### Scenario: 視窗縮放

- **WHEN** 使用者調整視窗大小
- **THEN** 3D 場景 SHALL 自適應視窗尺寸

#### Scenario: 全螢幕模式

- **WHEN** 使用者進入全螢幕模式
- **THEN** 3D 場景 SHALL 填滿整個螢幕

### Requirement: 設定面板

系統 SHALL 提供設定面板，允許使用者配置轉子選擇、轉子順序、初始位置、環設定、反射器選擇與接線板設定。設定面板 SHALL 可作為側邊欄顯示。

#### Scenario: 開啟設定面板

- **WHEN** 使用者從檢視選單選擇「顯示設定面板」
- **THEN** 設定面板 SHALL 以側邊欄形式顯示

#### Scenario: 轉子選擇

- **WHEN** 使用者在設定面板中選擇轉子
- **THEN** 系統 SHALL 提供 Rotor I–V 的選項，並允許設定三個轉子的順序

#### Scenario: 反射器選擇

- **WHEN** 使用者在設定面板中選擇反射器
- **THEN** 系統 SHALL 提供 Reflector B 與 Reflector C 的選項

#### Scenario: 設定即時生效

- **WHEN** 使用者修改任何設定
- **THEN** 3D 場景 SHALL 即時反映設定變更

### Requirement: 操作面板

系統 SHALL 提供操作面板，包含文字輸入區、輸出顯示區、重置按鈕與歷史記錄。

#### Scenario: 文字批次加密

- **WHEN** 使用者在文字輸入區輸入明文
- **THEN** 系統 SHALL 逐字加密並在輸出顯示區即時顯示密文

#### Scenario: 重置轉子

- **WHEN** 使用者點擊重置按鈕
- **THEN** 所有轉子 SHALL 回到初始位置設定

#### Scenario: 歷史記錄

- **WHEN** 使用者完成一次加密操作
- **THEN** 輸入/輸出對 SHALL 記錄於歷史記錄中

### Requirement: 選單列

系統 SHALL 提供完整的 macOS 選單列，包含檔案、編輯、檢視與說明選單。

#### Scenario: 匯出設定

- **WHEN** 使用者選擇檔案 > 匯出設定（或按 ⌘E）
- **THEN** 系統 SHALL 將當前機器設定匯出為 JSON 檔案

#### Scenario: 匯入設定

- **WHEN** 使用者選擇檔案 > 匯入設定（或按 ⌘I）
- **THEN** 系統 SHALL 載入 JSON 檔案並套用機器設定

#### Scenario: 複製加密結果

- **WHEN** 使用者選擇編輯 > 複製加密結果
- **THEN** 系統 SHALL 將最新的加密輸出複製到剪貼簿

#### Scenario: 檢視選單

- **WHEN** 使用者開啟檢視選單
- **THEN** SHALL 包含切換設定面板顯示與重置視角選項

### Requirement: 實體鍵盤輸入

系統 SHALL 支援實體鍵盤 A–Z 按鍵輸入，同步觸發 3D 鍵盤按壓動畫與加密操作。

#### Scenario: 鍵盤輸入加密

- **WHEN** 使用者按下實體鍵盤的字母 H
- **THEN** 3D 場景中的 H 按鍵 SHALL 播放按壓動畫，同時執行加密並亮起對應燈泡

#### Scenario: 鍵盤與 3D 互動一致

- **WHEN** 使用者依序使用實體鍵盤與 3D 點擊輸入相同字母序列
- **THEN** 兩種方式的加密結果 SHALL 完全一致

### Requirement: 鍵盤快捷鍵

系統 SHALL 支援以下鍵盤快捷鍵：⌘R 重置轉子位置、⌘E 匯出設定、⌘I 匯入設定。

#### Scenario: ⌘R 重置

- **WHEN** 使用者按下 ⌘R
- **THEN** 所有轉子 SHALL 回到初始位置設定

#### Scenario: ⌘E 匯出

- **WHEN** 使用者按下 ⌘E
- **THEN** 系統 SHALL 開啟匯出設定對話框

#### Scenario: ⌘I 匯入

- **WHEN** 使用者按下 ⌘I
- **THEN** 系統 SHALL 開啟匯入設定對話框

### Requirement: 設定持久化

系統 SHALL 使用 Codable + JSON 格式序列化機器設定，支援匯出為檔案與從檔案匯入。

#### Scenario: 設定匯出格式

- **WHEN** 匯出機器設定
- **THEN** 輸出 SHALL 為可讀的 JSON 檔案，包含轉子選擇、順序、位置、環設定、反射器與接線板配對

#### Scenario: 設定匯入驗證

- **WHEN** 匯入 JSON 設定檔
- **THEN** 系統 SHALL 驗證設定合法性（轉子不重複、接線板無衝突），非法設定 SHALL 提示錯誤
