import SceneKit
import AppKit

/// 使用 SceneKit 程式碼建構 Enigma 密碼機 3D 場景
final class EnigmaSceneBuilder {

    // MARK: - 尺寸常數（以公尺為單位，SceneKit 預設）

    /// 機體外殼
    private let caseWidth: CGFloat = 0.34
    private let caseHeight: CGFloat = 0.06
    private let caseDepth: CGFloat = 0.28

    /// 按鍵
    private let keyRadius: CGFloat = 0.008
    private let keyHeight: CGFloat = 0.005
    private let keySpacing: CGFloat = 0.024

    /// 燈板
    private let lampRadius: CGFloat = 0.007
    private let lampSpacing: CGFloat = 0.024

    /// 轉子
    private let rotorRadius: CGFloat = 0.025
    private let rotorWidth: CGFloat = 0.02
    private let rotorSpacing: CGFloat = 0.06

    /// 鍵盤排列（依歷史 Enigma 鍵盤佈局）
    private let keyboardRows: [[Character]] = [
        ["Q", "W", "E", "R", "T", "Z", "U", "I", "O"],
        ["A", "S", "D", "F", "G", "H", "J", "K"],
        ["P", "Y", "X", "C", "V", "B", "N", "M", "L"]
    ]

    /// 燈板排列（同鍵盤佈局）
    private let lampRows: [[Character]] = [
        ["Q", "W", "E", "R", "T", "Z", "U", "I", "O"],
        ["A", "S", "D", "F", "G", "H", "J", "K"],
        ["P", "Y", "X", "C", "V", "B", "N", "M", "L"]
    ]

    // MARK: - PBR 材質

    /// 木質材質
    private func woodMaterial() -> SCNMaterial {
        let mat = SCNMaterial()
        mat.lightingModel = .physicallyBased
        mat.diffuse.contents = NSColor(red: 0.45, green: 0.30, blue: 0.18, alpha: 1.0)
        mat.roughness.contents = 0.7
        mat.metalness.contents = 0.0
        mat.normal.intensity = 0.3
        return mat
    }

    /// 金屬按鍵材質
    private func keyMetalMaterial() -> SCNMaterial {
        let mat = SCNMaterial()
        mat.lightingModel = .physicallyBased
        mat.diffuse.contents = NSColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1.0)
        mat.roughness.contents = 0.3
        mat.metalness.contents = 0.8
        return mat
    }

    /// 按鍵字母材質
    private func keyLabelMaterial() -> SCNMaterial {
        let mat = SCNMaterial()
        mat.lightingModel = .physicallyBased
        mat.diffuse.contents = NSColor.white
        mat.roughness.contents = 0.5
        mat.metalness.contents = 0.0
        return mat
    }

    /// 燈泡玻璃材質（熄滅狀態）
    private func lampMaterial() -> SCNMaterial {
        let mat = SCNMaterial()
        mat.lightingModel = .physicallyBased
        mat.diffuse.contents = NSColor(red: 0.9, green: 0.85, blue: 0.7, alpha: 1.0)
        mat.roughness.contents = 0.2
        mat.metalness.contents = 0.0
        mat.emission.contents = NSColor.black
        mat.transparency = 0.85
        return mat
    }

    /// 轉子金屬材質
    private func rotorMaterial() -> SCNMaterial {
        let mat = SCNMaterial()
        mat.lightingModel = .physicallyBased
        mat.diffuse.contents = NSColor(red: 0.6, green: 0.58, blue: 0.55, alpha: 1.0)
        mat.roughness.contents = 0.4
        mat.metalness.contents = 0.9
        return mat
    }

    /// 接線板面板材質
    private func plugboardPanelMaterial() -> SCNMaterial {
        let mat = SCNMaterial()
        mat.lightingModel = .physicallyBased
        mat.diffuse.contents = NSColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)
        mat.roughness.contents = 0.6
        mat.metalness.contents = 0.3
        return mat
    }

    /// 接線板插孔材質
    private func plugSocketMaterial() -> SCNMaterial {
        let mat = SCNMaterial()
        mat.lightingModel = .physicallyBased
        mat.diffuse.contents = NSColor(red: 0.75, green: 0.65, blue: 0.35, alpha: 1.0)
        mat.roughness.contents = 0.3
        mat.metalness.contents = 0.95
        return mat
    }

    // MARK: - 場景建構

    /// 建構完整的 Enigma 密碼機 3D 場景
    func buildScene(in scene: SCNScene) {
        let rootNode = scene.rootNode

        // 攝影機
        setupCamera(in: rootNode)

        // 光源
        setupLighting(in: rootNode)

        // 環境
        setupEnvironment(in: scene)

        // 機體外殼
        let caseNode = buildCase()
        rootNode.addChildNode(caseNode)

        // 鍵盤
        let keyboardNode = buildKeyboard()
        keyboardNode.position = SCNVector3(0, caseHeight / 2 + 0.001, 0.04)
        rootNode.addChildNode(keyboardNode)

        // 燈板
        let lampboardNode = buildLampboard()
        lampboardNode.position = SCNVector3(0, caseHeight / 2 + 0.001, -0.04)
        rootNode.addChildNode(lampboardNode)

        // 轉子
        let rotorAssembly = buildRotorAssembly()
        rotorAssembly.position = SCNVector3(0, caseHeight / 2 + 0.035, -0.095)
        rootNode.addChildNode(rotorAssembly)

        // 接線板
        let plugboardNode = buildPlugboard()
        plugboardNode.position = SCNVector3(0, -0.01, 0.16)
        plugboardNode.eulerAngles.x = CGFloat.pi * 0.35
        rootNode.addChildNode(plugboardNode)
    }

    // MARK: - 攝影機

    private func setupCamera(in rootNode: SCNNode) {
        let cameraNode = SCNNode()
        cameraNode.name = "camera"
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 45
        cameraNode.camera?.zNear = 0.01
        cameraNode.camera?.zFar = 100
        // Bloom 後處理效果
        cameraNode.camera?.bloomIntensity = 0.5
        cameraNode.camera?.bloomThreshold = 0.8
        cameraNode.camera?.bloomBlurRadius = 10

        cameraNode.position = SCNVector3(0, 0.25, 0.35)
        cameraNode.look(at: SCNVector3(0, 0, 0))
        rootNode.addChildNode(cameraNode)
    }

    // MARK: - 光源

    private func setupLighting(in rootNode: SCNNode) {
        // 主光源（方向光）
        let mainLight = SCNNode()
        mainLight.name = "mainLight"
        mainLight.light = SCNLight()
        mainLight.light?.type = .directional
        mainLight.light?.intensity = 800
        mainLight.light?.color = NSColor(white: 0.95, alpha: 1.0)
        mainLight.light?.castsShadow = true
        mainLight.light?.shadowMode = .deferred
        mainLight.light?.shadowSampleCount = 8
        mainLight.light?.shadowRadius = 3
        mainLight.position = SCNVector3(0.3, 0.5, 0.3)
        mainLight.look(at: SCNVector3(0, 0, 0))
        rootNode.addChildNode(mainLight)

        // 補光（柔和環境光）
        let ambientLight = SCNNode()
        ambientLight.name = "ambientLight"
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 300
        ambientLight.light?.color = NSColor(red: 0.9, green: 0.85, blue: 0.8, alpha: 1.0)
        rootNode.addChildNode(ambientLight)

        // 填充光（從側面）
        let fillLight = SCNNode()
        fillLight.name = "fillLight"
        fillLight.light = SCNLight()
        fillLight.light?.type = .directional
        fillLight.light?.intensity = 300
        fillLight.light?.color = NSColor(red: 0.8, green: 0.85, blue: 1.0, alpha: 1.0)
        fillLight.position = SCNVector3(-0.3, 0.3, -0.1)
        fillLight.look(at: SCNVector3(0, 0, 0))
        rootNode.addChildNode(fillLight)
    }

    // MARK: - 環境

    private func setupEnvironment(in scene: SCNScene) {
        // 環境光遮蔽
        scene.rootNode.childNodes.forEach { node in
            node.geometry?.firstMaterial?.ambientOcclusion.intensity = 0.5
        }

        // 背景色
        scene.background.contents = NSColor(red: 0.15, green: 0.15, blue: 0.18, alpha: 1.0)
    }

    // MARK: - 機體外殼

    private func buildCase() -> SCNNode {
        let caseNode = SCNNode()
        caseNode.name = "enigma_case"

        // 底座
        let baseBox = SCNBox(
            width: caseWidth,
            height: caseHeight,
            length: caseDepth,
            chamferRadius: 0.005
        )
        baseBox.firstMaterial = woodMaterial()
        let baseNode = SCNNode(geometry: baseBox)
        baseNode.name = "case_base"
        caseNode.addChildNode(baseNode)

        // 後方斜面（轉子蓋板）
        let lidBox = SCNBox(
            width: caseWidth,
            height: 0.04,
            length: 0.08,
            chamferRadius: 0.003
        )
        lidBox.firstMaterial = woodMaterial()
        let lidNode = SCNNode(geometry: lidBox)
        lidNode.name = "case_lid"
        lidNode.position = SCNVector3(0, caseHeight / 2 + 0.015, -0.10)
        lidNode.eulerAngles.x = -CGFloat.pi * 0.15
        caseNode.addChildNode(lidNode)

        return caseNode
    }

    // MARK: - 鍵盤

    private func buildKeyboard() -> SCNNode {
        let keyboardNode = SCNNode()
        keyboardNode.name = "keyboard"

        for (rowIndex, row) in keyboardRows.enumerated() {
            let rowOffset = CGFloat(rowIndex) * keySpacing
            let colCount = CGFloat(row.count)
            let rowStartX = -(colCount - 1) * keySpacing / 2
            // 奇數行偏移半格
            let stagger: CGFloat = rowIndex == 1 ? keySpacing * 0.5 : 0

            for (colIndex, letter) in row.enumerated() {
                let x = rowStartX + CGFloat(colIndex) * keySpacing + stagger
                let z = rowOffset

                let keyNode = buildKey(letter: letter)
                keyNode.position = SCNVector3(x, 0, z)
                keyboardNode.addChildNode(keyNode)
            }
        }

        return keyboardNode
    }

    /// 建構單一按鍵
    private func buildKey(letter: Character) -> SCNNode {
        let keyGroup = SCNNode()
        keyGroup.name = "key_\(letter)"

        // 按鍵圓柱體
        let keyCylinder = SCNCylinder(radius: keyRadius, height: keyHeight)
        keyCylinder.firstMaterial = keyMetalMaterial()
        let keyBody = SCNNode(geometry: keyCylinder)
        keyBody.name = "key_\(letter)"
        keyGroup.addChildNode(keyBody)

        // 字母標籤
        let text = SCNText(string: String(letter), extrusionDepth: 0.0005)
        text.font = NSFont.systemFont(ofSize: 0.008, weight: .bold)
        text.flatness = 0.1
        text.firstMaterial = keyLabelMaterial()

        let textNode = SCNNode(geometry: text)
        textNode.name = "key_label_\(letter)"
        // 置中文字
        let (min, max) = textNode.boundingBox
        let textWidth = max.x - min.x
        let textHeight = max.y - min.y
        textNode.position = SCNVector3(
            -textWidth / 2,
            keyHeight / 2 + 0.0003,
            textHeight / 2
        )
        textNode.eulerAngles.x = -CGFloat.pi / 2
        keyGroup.addChildNode(textNode)

        return keyGroup
    }

    // MARK: - 燈板

    private func buildLampboard() -> SCNNode {
        let lampboardNode = SCNNode()
        lampboardNode.name = "lampboard"

        for (rowIndex, row) in lampRows.enumerated() {
            let rowOffset = CGFloat(rowIndex) * lampSpacing
            let colCount = CGFloat(row.count)
            let rowStartX = -(colCount - 1) * lampSpacing / 2
            let stagger: CGFloat = rowIndex == 1 ? lampSpacing * 0.5 : 0

            for (colIndex, letter) in row.enumerated() {
                let x = rowStartX + CGFloat(colIndex) * lampSpacing + stagger
                let z = rowOffset

                let lampNode = buildLamp(letter: letter)
                lampNode.position = SCNVector3(x, 0, z)
                lampboardNode.addChildNode(lampNode)
            }
        }

        return lampboardNode
    }

    /// 建構單一燈泡
    private func buildLamp(letter: Character) -> SCNNode {
        let lampGroup = SCNNode()
        lampGroup.name = "lamp_\(letter)"

        // 燈泡球體
        let sphere = SCNSphere(radius: lampRadius)
        sphere.firstMaterial = lampMaterial()
        let lampBody = SCNNode(geometry: sphere)
        lampBody.name = "lamp_\(letter)"
        lampGroup.addChildNode(lampBody)

        // 字母標籤
        let text = SCNText(string: String(letter), extrusionDepth: 0.0003)
        text.font = NSFont.systemFont(ofSize: 0.006, weight: .medium)
        text.flatness = 0.1
        let textMat = SCNMaterial()
        textMat.diffuse.contents = NSColor(red: 0.3, green: 0.25, blue: 0.2, alpha: 1.0)
        text.firstMaterial = textMat

        let textNode = SCNNode(geometry: text)
        let (min, max) = textNode.boundingBox
        let textWidth = max.x - min.x
        textNode.position = SCNVector3(
            -textWidth / 2,
            lampRadius + 0.001,
            0
        )
        textNode.eulerAngles.x = -CGFloat.pi / 2
        lampGroup.addChildNode(textNode)

        return lampGroup
    }

    // MARK: - 轉子

    private func buildRotorAssembly() -> SCNNode {
        let assemblyNode = SCNNode()
        assemblyNode.name = "rotor_assembly"

        for i in 0..<3 {
            let rotorNode = buildRotor(index: i)
            let x = CGFloat(i - 1) * rotorSpacing
            rotorNode.position = SCNVector3(x, 0, 0)
            assemblyNode.addChildNode(rotorNode)
        }

        return assemblyNode
    }

    /// 建構單一轉子顯示
    private func buildRotor(index: Int) -> SCNNode {
        let rotorGroup = SCNNode()
        rotorGroup.name = "rotor_\(index)"

        // 轉子外殼（圓柱體）
        let cylinder = SCNCylinder(radius: rotorRadius, height: rotorWidth)
        cylinder.firstMaterial = rotorMaterial()
        let rotorBody = SCNNode(geometry: cylinder)
        rotorBody.name = "rotor_display_\(index)"
        rotorBody.eulerAngles.z = CGFloat.pi / 2
        rotorGroup.addChildNode(rotorBody)

        // 位置指示視窗（小方塊）
        let windowBox = SCNBox(width: 0.018, height: 0.003, length: 0.014, chamferRadius: 0.001)
        let windowMat = SCNMaterial()
        windowMat.lightingModel = .physicallyBased
        windowMat.diffuse.contents = NSColor(red: 0.95, green: 0.93, blue: 0.85, alpha: 1.0)
        windowMat.roughness.contents = 0.2
        windowBox.firstMaterial = windowMat
        let windowNode = SCNNode(geometry: windowBox)
        windowNode.position = SCNVector3(0, rotorRadius + 0.001, 0)
        rotorGroup.addChildNode(windowNode)

        // 字母顯示
        let text = SCNText(string: "A", extrusionDepth: 0.0005)
        text.font = NSFont.monospacedSystemFont(ofSize: 0.01, weight: .bold)
        text.flatness = 0.1
        let textMat = SCNMaterial()
        textMat.diffuse.contents = NSColor.black
        text.firstMaterial = textMat

        let textNode = SCNNode(geometry: text)
        textNode.name = "rotor_label_\(index)"
        let (min, max) = textNode.boundingBox
        let tw = max.x - min.x
        textNode.position = SCNVector3(
            -tw / 2,
            rotorRadius + 0.002,
            0.005
        )
        textNode.eulerAngles.x = -CGFloat.pi / 2
        rotorGroup.addChildNode(textNode)

        return rotorGroup
    }

    // MARK: - 接線板

    private func buildPlugboard() -> SCNNode {
        let plugboardNode = SCNNode()
        plugboardNode.name = "plugboard"

        // 面板背景
        let panelBox = SCNBox(width: 0.30, height: 0.08, length: 0.005, chamferRadius: 0.002)
        panelBox.firstMaterial = plugboardPanelMaterial()
        let panelNode = SCNNode(geometry: panelBox)
        plugboardNode.addChildNode(panelNode)

        // 26 個插孔（排成兩排）
        let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        let topRow = Array(alphabet[0..<13])
        let bottomRow = Array(alphabet[13..<26])

        for (rowIndex, row) in [topRow, bottomRow].enumerated() {
            let y = rowIndex == 0 ? CGFloat(0.02) : CGFloat(-0.02)
            let startX = -CGFloat(row.count - 1) * 0.02 / 2

            for (colIndex, letter) in row.enumerated() {
                let x = startX + CGFloat(colIndex) * 0.02

                let socketNode = buildPlugSocket(letter: letter)
                socketNode.position = SCNVector3(x, y, 0.003)
                plugboardNode.addChildNode(socketNode)
            }
        }

        return plugboardNode
    }

    /// 建構單一接線板插孔
    private func buildPlugSocket(letter: Character) -> SCNNode {
        let socketGroup = SCNNode()
        socketGroup.name = "plug_\(letter)"

        // 插孔圓柱
        let cylinder = SCNCylinder(radius: 0.004, height: 0.003)
        cylinder.firstMaterial = plugSocketMaterial()
        let socketBody = SCNNode(geometry: cylinder)
        socketBody.eulerAngles.x = CGFloat.pi / 2
        socketGroup.addChildNode(socketBody)

        // 字母標籤
        let text = SCNText(string: String(letter), extrusionDepth: 0.0002)
        text.font = NSFont.systemFont(ofSize: 0.004, weight: .medium)
        text.flatness = 0.1
        let textMat = SCNMaterial()
        textMat.diffuse.contents = NSColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
        text.firstMaterial = textMat

        let textNode = SCNNode(geometry: text)
        let (min, max) = textNode.boundingBox
        let tw = max.x - min.x
        textNode.position = SCNVector3(-tw / 2, 0.008, 0.002)
        textNode.eulerAngles.x = -CGFloat.pi / 2
        socketGroup.addChildNode(textNode)

        return socketGroup
    }

    // MARK: - 接線板連線

    /// 在接線板上新增連線視覺化
    func addPlugWire(from letterA: Int, to letterB: Int, in scene: SCNScene) {
        guard let plugboard = scene.rootNode.childNode(withName: "plugboard", recursively: true) else { return }

        let charA = Character(UnicodeScalar(letterA + Int(Character("A").asciiValue!))!)
        let charB = Character(UnicodeScalar(letterB + Int(Character("A").asciiValue!))!)

        guard let socketA = plugboard.childNode(withName: "plug_\(charA)", recursively: true),
              let socketB = plugboard.childNode(withName: "plug_\(charB)", recursively: true) else { return }

        let posA = socketA.position
        let posB = socketB.position

        // 以圓柱體模擬電線
        let dx = posB.x - posA.x
        let dy = posB.y - posA.y
        let dz = posB.z - posA.z
        let distance = sqrt(dx * dx + dy * dy + dz * dz)

        let wireCylinder = SCNCylinder(radius: 0.001, height: CGFloat(distance))
        let wireMat = SCNMaterial()
        wireMat.lightingModel = .physicallyBased
        wireMat.diffuse.contents = NSColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        wireMat.roughness.contents = 0.6
        wireMat.metalness.contents = 0.3
        wireCylinder.firstMaterial = wireMat

        let wireNode = SCNNode(geometry: wireCylinder)
        wireNode.name = "plugwire_\(charA)\(charB)"

        // 定位到兩插孔的中點
        wireNode.position = SCNVector3(
            (posA.x + posB.x) / 2,
            (posA.y + posB.y) / 2,
            (posA.z + posB.z) / 2 + 0.005
        )

        // 旋轉使圓柱體指向兩點之間
        let direction = SCNVector3(dx, dy, dz)
        wireNode.look(at: SCNVector3(posB.x, posB.y, posB.z + 0.005))
        wireNode.eulerAngles.x += CGFloat.pi / 2

        _ = direction  // 避免未使用警告

        plugboard.addChildNode(wireNode)
    }
}
