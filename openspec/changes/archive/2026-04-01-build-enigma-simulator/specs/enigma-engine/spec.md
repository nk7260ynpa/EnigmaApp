## ADDED Requirements

### Requirement: 轉子線路對應表

系統 SHALL 內建歷史上的 5 種 Wehrmacht Enigma 轉子（Rotor I–V），每種轉子 SHALL 具有固定的 26 字母線路對應表與缺口位置（Notch Position）。

#### Scenario: 轉子線路正確性

- **WHEN** 使用 Rotor I 且輸入字母 A（位置為 0，Ring Setting 為 0）
- **THEN** 正向通過轉子後輸出字母 SHALL 符合歷史 Rotor I 線路表（EKMFLGDQVZNTOWYHXUSPAIBRCJ）

#### Scenario: 各轉子缺口位置正確

- **WHEN** 查詢各轉子的缺口位置
- **THEN** Rotor I 缺口為 Q，Rotor II 缺口為 E，Rotor III 缺口為 V，Rotor IV 缺口為 J，Rotor V 缺口為 Z

### Requirement: 轉子選擇與排列

系統 SHALL 允許使用者從 5 種轉子中選擇 3 個並設定其排列順序（由左至右）。同一種轉子不可重複使用。

#### Scenario: 選擇 3 個不同轉子

- **WHEN** 使用者選擇 Rotor III、Rotor I、Rotor II 作為左、中、右轉子
- **THEN** 系統 SHALL 接受此設定並按指定順序配置轉子

#### Scenario: 拒絕重複轉子

- **WHEN** 使用者嘗試將同一種轉子用於多個位置
- **THEN** 系統 SHALL 拒絕此設定並提示錯誤

### Requirement: 轉子初始位置設定

系統 SHALL 允許設定每個轉子的初始位置（A–Z，共 26 個位置）。

#### Scenario: 設定初始位置

- **WHEN** 使用者將左轉子設為 M、中轉子設為 C、右轉子設為 K
- **THEN** 三個轉子的顯示位置 SHALL 分別為 M、C、K

### Requirement: 環設定（Ring Setting）

系統 SHALL 允許設定每個轉子的環設定（A–Z），環設定 SHALL 影響轉子線路的偏移與缺口觸發位置。

#### Scenario: 環設定影響加密結果

- **WHEN** 使用相同轉子順序與初始位置，但不同的環設定
- **THEN** 加密相同明文 SHALL 產生不同密文

### Requirement: 轉子旋轉機制

系統 SHALL 在每次按鍵時先旋轉轉子再進行加密。最右側轉子 SHALL 每次按鍵旋轉一格。

#### Scenario: 右轉子每次按鍵旋轉

- **WHEN** 右轉子位置為 A 且連續按下 3 個按鍵
- **THEN** 右轉子位置 SHALL 依序變為 B、C、D

### Requirement: 轉子進位機制

當右轉子到達缺口位置時，SHALL 帶動中轉子旋轉一格。當中轉子到達缺口位置時，SHALL 帶動左轉子旋轉一格。

#### Scenario: 正常進位

- **WHEN** 右轉子為 Rotor I 且位置到達 Q
- **THEN** 下次按鍵時中轉子 SHALL 同時旋轉一格

#### Scenario: 雙重進位（Double Stepping）

- **WHEN** 中轉子已在其缺口位置
- **THEN** 下次按鍵時中轉子 SHALL 再次旋轉一格（被自身缺口觸發），同時帶動左轉子旋轉

### Requirement: 反射器

系統 SHALL 支援 Reflector B 與 Reflector C 兩種反射器。反射器 SHALL 具有固定的字母對應表且不可旋轉。反射器 SHALL 確保沒有字母對應到自身。

#### Scenario: 反射器 B 對應正確

- **WHEN** 使用 Reflector B 且輸入字母 A
- **THEN** 輸出 SHALL 為 Y（符合歷史 Reflector B 線路表 YRUHQSLDPXNGOKMIEBFZCWVJAT）

#### Scenario: 反射器無自身對應

- **WHEN** 任意字母通過反射器
- **THEN** 輸出字母 SHALL 不等於輸入字母

### Requirement: 接線板

系統 SHALL 支援設定 0–13 組字母對交換。每個字母 SHALL 最多參與一組交換。

#### Scenario: 接線板交換

- **WHEN** 接線板設定 A-B 交換且輸入字母 A
- **THEN** 經過接線板後輸出 SHALL 為 B

#### Scenario: 未配對字母不變

- **WHEN** 字母 C 未在任何接線板配對中
- **THEN** 經過接線板後輸出 SHALL 仍為 C

#### Scenario: 拒絕重複字母

- **WHEN** 使用者嘗試將已配對的字母加入新配對
- **THEN** 系統 SHALL 拒絕此設定

### Requirement: 完整加密路徑

加密訊號 SHALL 依序通過：接線板 → 右轉子（正向）→ 中轉子（正向）→ 左轉子（正向）→ 反射器 → 左轉子（反向）→ 中轉子（反向）→ 右轉子（反向）→ 接線板。

#### Scenario: 端到端加密驗證

- **WHEN** 使用 Rotors I-II-III、Reflector B、初始位置 AAA、無接線板、輸入 AAAA
- **THEN** 輸出 SHALL 為已知的歷史正確密文

#### Scenario: 加密解密對稱性

- **WHEN** 使用相同設定將明文加密為密文，再以同一設定（重置轉子位置）輸入密文
- **THEN** 輸出 SHALL 還原為原始明文

### Requirement: 僅處理大寫英文字母

系統 SHALL 僅接受並處理大寫英文字母 A–Z。非字母字元 SHALL 被忽略。

#### Scenario: 忽略非字母輸入

- **WHEN** 輸入包含數字或標點符號
- **THEN** 系統 SHALL 忽略這些字元，僅處理字母部分

#### Scenario: 小寫自動轉換

- **WHEN** 輸入小寫字母
- **THEN** 系統 SHALL 自動轉換為大寫後進行加密
