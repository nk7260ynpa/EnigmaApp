import Foundation
import SceneKit
import AppKit
import Observation
import EnigmaCore

/// 操作歷史記錄項目
struct HistoryEntry: Identifiable, Sendable {
    let id = UUID()
    let input: Character
    let output: Character
    let timestamp: Date = Date()
}

/// 3D 場景的 ViewModel，連接 EnigmaMachine 與 SceneKit 場景
@Observable
final class SceneViewModel {
    // MARK: - 加密引擎
    let machine: EnigmaMachine
    var initialConfig: MachineConfiguration

    // MARK: - 3D 場景
    let scene: SCNScene
    private let sceneBuilder: EnigmaSceneBuilder

    // MARK: - 操作狀態
    var inputText: String = ""
    var outputText: String = ""
    var history: [HistoryEntry] = []
    var lastLitLamp: SCNNode?
    var showSettings: Bool = true

    // MARK: - 拖曳狀態
    private var dragTarget: DragTarget?

    enum DragTarget {
        case rotor(index: Int, startPosition: Int)
        case plugboard(fromLetter: Int)
    }

    // MARK: - 初始化

    init() {
        let machine = EnigmaMachine()
        self.machine = machine
        self.initialConfig = MachineConfiguration.from(machine: machine)
        self.scene = SCNScene()
        self.sceneBuilder = EnigmaSceneBuilder()
        sceneBuilder.buildScene(in: scene)
    }

    // MARK: - 加密操作

    /// 按下按鍵進行加密
    func pressKey(_ letter: Character) {
        guard let encrypted = machine.encryptCharacter(letter) else { return }

        let letterUpper = letter.uppercased().first!

        // 更新文字
        inputText.append(letterUpper)
        outputText.append(encrypted)

        // 記錄歷史
        history.append(HistoryEntry(input: letterUpper, output: encrypted))

        // 3D 動畫：按鍵按壓
        let keyName = "key_\(letterUpper)"
        if let keyNode = scene.rootNode.childNode(withName: keyName, recursively: true) {
            animateKeyPress(keyNode)
        }

        // 3D 動畫：燈泡亮起
        turnOffLastLamp()
        let lampName = "lamp_\(encrypted)"
        if let lampNode = scene.rootNode.childNode(withName: lampName, recursively: true) {
            animateLampOn(lampNode)
            lastLitLamp = lampNode
        }

        // 3D 動畫：更新轉子位置
        updateRotorDisplays()
    }

    /// 關閉前一個亮起的燈泡
    private func turnOffLastLamp() {
        guard let lamp = lastLitLamp else { return }
        animateLampOff(lamp)
        lastLitLamp = nil
    }

    // MARK: - 鍵盤事件處理

    /// 處理實體鍵盤事件
    func handleKeyEvent(_ event: NSEvent) -> NSEvent? {
        // 忽略帶修飾鍵（⌘、⌃、⌥）的按鍵
        if event.modifierFlags.contains(.command) ||
           event.modifierFlags.contains(.control) ||
           event.modifierFlags.contains(.option) {
            return event
        }

        guard let chars = event.characters?.uppercased(),
              let char = chars.first,
              char >= "A", char <= "Z" else {
            return event
        }

        pressKey(char)
        return nil  // 消費事件
    }

    // MARK: - 3D 互動處理

    /// 處理點擊 3D 物件
    func handleHitTestResult(_ hit: SCNHitTestResult) {
        let node = hit.node
        let name = node.name ?? node.parent?.name ?? ""

        if name.hasPrefix("key_") {
            let letter = name.dropFirst(4).first!
            pressKey(letter)
        }
    }

    /// 開始拖曳
    func handleDragBegan(_ hit: SCNHitTestResult, translation: CGPoint) {
        let node = hit.node
        let name = node.name ?? node.parent?.name ?? ""

        if name.hasPrefix("rotor_display_") {
            if let indexStr = name.dropFirst(14).first,
               let index = Int(String(indexStr)) {
                let currentPos: Int
                switch index {
                case 0: currentPos = machine.leftRotor.position
                case 1: currentPos = machine.middleRotor.position
                case 2: currentPos = machine.rightRotor.position
                default: return
                }
                dragTarget = .rotor(index: index, startPosition: currentPos)
            }
        } else if name.hasPrefix("plug_") {
            let letter = EnigmaMachine.letterToIndex(name.dropFirst(5).first!)
            dragTarget = .plugboard(fromLetter: letter)
        }
    }

    /// 拖曳中
    func handleDragChanged(translation: CGPoint) {
        guard let target = dragTarget else { return }

        switch target {
        case .rotor(let index, let startPosition):
            // AppKit Y 軸向上為正：向上拖曳遞減（字母往前），向下拖曳遞增
            let steps = Int(-translation.y / 15.0)
            let newPosition = (startPosition + steps + 26) % 26

            switch index {
            case 0: machine.leftRotor.position = newPosition
            case 1: machine.middleRotor.position = newPosition
            case 2: machine.rightRotor.position = newPosition
            default: break
            }
            updateRotorDisplays()

        case .plugboard:
            break  // 接線板拖曳在 dragEnded 處理
        }
    }

    /// 結束拖曳
    func handleDragEnded() {
        dragTarget = nil
    }

    // MARK: - 設定管理

    /// 重置轉子到初始位置
    func resetPositions() {
        machine.setPositions(
            left: initialConfig.leftPosition,
            middle: initialConfig.middlePosition,
            right: initialConfig.rightPosition
        )
        inputText = ""
        outputText = ""
        history.removeAll()
        turnOffLastLamp()
        updateRotorDisplays()
    }

    /// 套用新設定
    func applyConfiguration(_ config: MachineConfiguration) {
        machine.reset(to: config)
        initialConfig = config
        inputText = ""
        outputText = ""
        turnOffLastLamp()
        updateRotorDisplays()
        updatePlugboardDisplay()
    }

    /// 取得當前設定
    func currentConfiguration() -> MachineConfiguration {
        MachineConfiguration.from(machine: machine)
    }

    // MARK: - 3D 動畫

    /// 按鍵按壓動畫
    private func animateKeyPress(_ node: SCNNode) {
        let pressDown = SCNAction.moveBy(x: 0, y: -0.003, z: 0, duration: 0.05)
        let pressUp = SCNAction.moveBy(x: 0, y: 0.003, z: 0, duration: 0.1)
        pressUp.timingMode = .easeOut
        node.runAction(SCNAction.sequence([pressDown, pressUp]))
    }

    /// 燈泡亮起動畫
    private func animateLampOn(_ node: SCNNode) {
        guard let material = node.geometry?.firstMaterial else { return }
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.1
        material.emission.contents = NSColor(red: 1.0, green: 0.9, blue: 0.5, alpha: 1.0)
        material.diffuse.contents = NSColor(red: 1.0, green: 0.95, blue: 0.7, alpha: 1.0)
        SCNTransaction.commit()
    }

    /// 燈泡熄滅動畫
    private func animateLampOff(_ node: SCNNode) {
        guard let material = node.geometry?.firstMaterial else { return }
        SCNTransaction.begin()
        SCNTransaction.animationDuration = 0.3
        material.emission.contents = NSColor.black
        material.diffuse.contents = NSColor(red: 0.9, green: 0.85, blue: 0.7, alpha: 1.0)
        SCNTransaction.commit()
    }

    /// 更新轉子顯示
    /// 只旋轉 rotor_spin_ 群組（盤面），窗口框架與標籤固定不動
    func updateRotorDisplays() {
        let positions = [
            machine.leftRotor.position,
            machine.middleRotor.position,
            machine.rightRotor.position
        ]

        for (index, position) in positions.enumerated() {
            let spinName = "rotor_spin_\(index)"
            if let spinNode = scene.rootNode.childNode(withName: spinName, recursively: true) {
                // 繞 X 軸旋轉（圓柱體經 Z 旋轉 π/2 後軸心指向 X）
                // 負角度使 position 增加時字母向上滾入窗口
                let angle = -CGFloat(position) * (.pi * 2.0 / 26.0)
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0.15
                SCNTransaction.animationTimingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                spinNode.eulerAngles.x = angle
                SCNTransaction.commit()
            }

            // 更新文字標籤（固定在容器上，不隨盤面旋轉）
            let labelName = "rotor_label_\(index)"
            if let labelNode = scene.rootNode.childNode(withName: labelName, recursively: true),
               let textGeom = labelNode.geometry as? SCNText {
                textGeom.string = String(EnigmaMachine.indexToLetter(position))
            }
        }
    }

    /// 更新接線板顯示
    func updatePlugboardDisplay() {
        // 移除現有連線
        scene.rootNode.childNodes(passingTest: { node, _ in
            node.name?.hasPrefix("plugwire_") ?? false
        }).forEach { $0.removeFromParentNode() }

        // 繪製新連線
        for pair in machine.plugboard.pairs {
            sceneBuilder.addPlugWire(
                from: pair.0,
                to: pair.1,
                in: scene
            )
        }
    }
}
