## ADDED Requirements

### Requirement: 3D 場景建構

系統 SHALL 使用 SceneKit 建構完整的 Enigma 密碼機 3D 場景，包含機體外殼、鍵盤、燈板、轉子、接線板與反射器。場景 SHALL 使用 Metal 作為渲染後端。

#### Scenario: 場景載入

- **WHEN** 應用程式啟動
- **THEN** 3D Enigma 密碼機場景 SHALL 正確載入並顯示於主視窗

#### Scenario: Metal 渲染啟用

- **WHEN** 3D 場景渲染時
- **THEN** SceneKit SHALL 使用 Metal API 作為渲染後端

### Requirement: 機體外殼模型

系統 SHALL 渲染 Enigma 密碼機的木質箱體外殼，使用 PBR 材質呈現木質紋理質感。

#### Scenario: 外殼渲染

- **WHEN** 3D 場景載入完成
- **THEN** 機體外殼 SHALL 以木質材質渲染，具有合理的尺寸比例

### Requirement: 鍵盤模型與互動

系統 SHALL 渲染 26 個可互動的字母按鍵。使用者點擊按鍵 SHALL 觸發加密操作與按壓動畫。

#### Scenario: 點擊按鍵觸發加密

- **WHEN** 使用者點擊 3D 鍵盤上的字母 A 按鍵
- **THEN** 系統 SHALL 執行加密並顯示結果，同時播放按鍵按壓動畫

#### Scenario: 按鍵回彈動畫

- **WHEN** 按鍵按壓動畫完成
- **THEN** 按鍵 SHALL 自動回彈至原始位置

### Requirement: 燈板模型與回饋

系統 SHALL 渲染 26 個字母燈泡。加密結果對應的燈泡 SHALL 亮起並帶有發光效果。

#### Scenario: 燈泡亮起

- **WHEN** 加密結果為字母 X
- **THEN** 燈板上的 X 燈泡 SHALL 亮起，使用 Bloom 後處理效果呈現發光

#### Scenario: 燈泡熄滅

- **WHEN** 下一次按鍵觸發新的加密
- **THEN** 前一個亮起的燈泡 SHALL 漸變熄滅

### Requirement: 轉子模型與操作

系統 SHALL 渲染 3 個可旋轉的轉子，顯示當前字母位置。使用者 SHALL 可拖曳旋轉轉子設定初始位置。

#### Scenario: 轉子顯示當前位置

- **WHEN** 轉子位置為 M
- **THEN** 轉子模型 SHALL 顯示字母 M 於可見位置

#### Scenario: 拖曳設定轉子位置

- **WHEN** 使用者上下拖曳轉子
- **THEN** 轉子 SHALL 旋轉至對應字母位置，帶有旋轉動畫

#### Scenario: 按鍵後轉子自動旋轉

- **WHEN** 加密操作觸發轉子旋轉
- **THEN** 對應轉子 SHALL 播放旋轉動畫至新位置

### Requirement: 接線板模型與操作

系統 SHALL 渲染接線板面板，顯示 26 個字母插孔與連線狀態。使用者 SHALL 可透過拖曳操作設定字母對交換。

#### Scenario: 顯示連線狀態

- **WHEN** 接線板設定 A-B 交換
- **THEN** 接線板上 A 與 B 插孔之間 SHALL 顯示連線

#### Scenario: 拖曳建立連線

- **WHEN** 使用者從字母 C 插孔拖曳至字母 D 插孔
- **THEN** 系統 SHALL 建立 C-D 交換配對並顯示連線

### Requirement: 視角控制

系統 SHALL 支援使用者透過滑鼠/觸控板旋轉、縮放與平移檢視 3D 模型。

#### Scenario: 旋轉視角

- **WHEN** 使用者拖曳空白區域
- **THEN** 3D 場景視角 SHALL 圍繞模型旋轉

#### Scenario: 縮放視角

- **WHEN** 使用者使用滾輪或捏合手勢
- **THEN** 3D 場景 SHALL 放大或縮小

#### Scenario: 平移視角

- **WHEN** 使用者按住 Option 鍵並拖曳
- **THEN** 3D 場景 SHALL 平移

### Requirement: PBR 材質渲染

系統 SHALL 使用 PBR 材質渲染 3D 模型，呈現金屬、玻璃、木質等不同質感。

#### Scenario: 材質區分

- **WHEN** 3D 場景渲染完成
- **THEN** 按鍵 SHALL 呈現金屬/塑膠質感，外殼 SHALL 呈現木質質感，燈板 SHALL 呈現玻璃質感

### Requirement: 即時光影效果

系統 SHALL 支援動態光源、陰影與環境光遮蔽效果。

#### Scenario: 動態陰影

- **WHEN** 3D 場景渲染時
- **THEN** 各元件 SHALL 根據光源位置投射陰影

#### Scenario: 環境光遮蔽

- **WHEN** 3D 場景渲染時
- **THEN** 模型凹陷處與交接處 SHALL 呈現環境光遮蔽效果

### Requirement: 渲染效能

系統 SHALL 在 Apple Silicon Mac 上維持 60 FPS 的渲染幀率。

#### Scenario: 幀率達標

- **WHEN** 3D 場景正常運作（含互動操作）
- **THEN** 渲染幀率 SHALL 穩定 ≥ 60 FPS

### Requirement: 動畫系統

系統 SHALL 提供流暢的動畫效果，包含按鍵按壓回彈、轉子旋轉（含進位連動）、燈泡亮滅漸變與接線板拖曳回饋。

#### Scenario: 動畫流暢度

- **WHEN** 任何動畫播放時
- **THEN** 動畫 SHALL 流暢無卡頓，與渲染幀率同步
