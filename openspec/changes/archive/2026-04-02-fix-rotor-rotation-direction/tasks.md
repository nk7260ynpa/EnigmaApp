## 1. 修正轉子旋轉動畫

- [x] 1.1 修改 updateRotorDisplays()：改為對 rotor_spin_\(index) 旋轉群組設定 eulerAngles.x
- [x] 1.2 修改拖曳方向：確保向上拖曳遞減、向下拖曳遞增

## 2. 重構節點層級

- [x] 2.1 buildRotor() 新增 spinGroup 節點，將盤面/凹槽/軸轂/刻度加入 spinGroup
- [x] 2.2 windowFrame/glass/text label 保持在 rotorGroup（固定不動）

## 3. 驗證

- [x] 3.1 編譯通過並執行單元測試
- [x] 3.2 執行 run.sh 確認轉子旋轉方向與動畫正確
