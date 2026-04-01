## 1. 修正轉子旋轉動畫

- [x] 1.1 修改 updateRotorDisplays()：改為對 rotor_\(index) 容器節點使用 SCNTransaction 設定 eulerAngles.x，取代 rotateTo 動畫
- [x] 1.2 修改拖曳方向：確保向上拖曳遞減、向下拖曳遞增

## 2. 驗證

- [x] 2.1 編譯通過並執行單元測試
- [x] 2.2 執行 run.sh 確認轉子旋轉方向與動畫正確
