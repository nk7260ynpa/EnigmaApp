## MODIFIED Requirements

### Requirement: 轉子模型與操作

系統 SHALL 渲染 3 個可旋轉的轉子，顯示當前字母位置。每次按鍵後轉子 SHALL 繞自身軸心旋轉至新位置，旋轉方向 SHALL 與字母遞增方向一致。

#### Scenario: 按鍵後轉子旋轉方向

- **WHEN** 加密操作觸發右轉子從位置 A 旋轉至位置 B
- **THEN** 轉子 SHALL 繞自身軸心順時針旋轉一格，視窗中顯示的字母從 A 變為 B

#### Scenario: 拖曳旋轉方向

- **WHEN** 使用者向上拖曳轉子
- **THEN** 轉子位置 SHALL 遞減（字母往前），向下拖曳 SHALL 遞增（字母往後）

#### Scenario: 旋轉動畫不破壞姿態

- **WHEN** 轉子旋轉動畫播放時
- **THEN** 轉子圓柱體的橫放姿態 SHALL 維持不變，僅繞軸心旋轉
