import SceneKit
import AppKit

/// 使用 SceneKit 程式碼建構 Enigma 密碼機 3D 場景
/// 尺寸參考歷史 Wehrmacht Enigma I 實機
final class EnigmaSceneBuilder {

    // MARK: - 尺寸常數（以公尺為單位，SceneKit 預設）

    /// 機體外殼（歷史實機約 340×150×270mm）
    private let caseWidth: CGFloat = 0.34
    private let caseHeight: CGFloat = 0.13
    private let caseDepth: CGFloat = 0.27

    /// 按鍵（歷史實機按鍵直徑約 12–15mm）
    private let keyRadius: CGFloat = 0.007
    private let keyHeight: CGFloat = 0.005
    private let keySpacing: CGFloat = 0.022
    /// 按鍵圓環邊框
    private let keyRingRadius: CGFloat = 0.009
    private let keyRingHeight: CGFloat = 0.002

    /// 燈板
    private let lampRadius: CGFloat = 0.006
    private let lampSpacing: CGFloat = 0.022
    /// 燈板底座燈罩
    private let lampBaseRadius: CGFloat = 0.009
    private let lampBaseHeight: CGFloat = 0.003

    /// 轉子（歷史實機直徑約 100–110mm）
    private let rotorRadius: CGFloat = 0.050
    private let rotorWidth: CGFloat = 0.018
    private let rotorSpacing: CGFloat = 0.040

    /// 鍵盤排列（歷史 Enigma QWERTZ 佈局）
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

    private func woodMaterial() -> SCNMaterial {
        let mat = SCNMaterial()
        mat.lightingModel = .physicallyBased
        mat.diffuse.contents = NSColor(red: 0.42, green: 0.28, blue: 0.16, alpha: 1.0)
        mat.roughness.contents = 0.75
        mat.metalness.contents = 0.0
        mat.normal.intensity = 0.3
        return mat
    }

    private func darkWoodMaterial() -> SCNMaterial {
        let mat = SCNMaterial()
        mat.lightingModel = .physicallyBased
        mat.diffuse.contents = NSColor(red: 0.30, green: 0.20, blue: 0.12, alpha: 1.0)
        mat.roughness.contents = 0.65
        mat.metalness.contents = 0.0
        return mat
    }

    private func keyMetalMaterial() -> SCNMaterial {
        let mat = SCNMaterial()
        mat.lightingModel = .physicallyBased
        mat.diffuse.contents = NSColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0)
        mat.roughness.contents = 0.35
        mat.metalness.contents = 0.7
        return mat
    }

    private func keyRingMaterial() -> SCNMaterial {
        let mat = SCNMaterial()
        mat.lightingModel = .physicallyBased
        mat.diffuse.contents = NSColor(red: 0.72, green: 0.68, blue: 0.60, alpha: 1.0)
        mat.roughness.contents = 0.25
        mat.metalness.contents = 0.95
        return mat
    }

    private func keyLabelMaterial() -> SCNMaterial {
        let mat = SCNMaterial()
        mat.lightingModel = .physicallyBased
        mat.diffuse.contents = NSColor.white
        mat.roughness.contents = 0.5
        mat.metalness.contents = 0.0
        return mat
    }

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

    private func lampBaseMaterial() -> SCNMaterial {
        let mat = SCNMaterial()
        mat.lightingModel = .physicallyBased
        mat.diffuse.contents = NSColor(red: 0.18, green: 0.18, blue: 0.18, alpha: 1.0)
        mat.roughness.contents = 0.5
        mat.metalness.contents = 0.6
        return mat
    }

    /// 轉子材質（依 index 使用不同色調）
    private func rotorMaterial(index: Int = 0) -> SCNMaterial {
        let mat = SCNMaterial()
        mat.lightingModel = .physicallyBased
        let colors: [(CGFloat, CGFloat, CGFloat)] = [
            (0.55, 0.52, 0.48),  // 左：銀灰
            (0.50, 0.45, 0.38),  // 中：古銅
            (0.48, 0.50, 0.52),  // 右：鋼藍灰
        ]
        let c = colors[index % colors.count]
        mat.diffuse.contents = NSColor(red: c.0, green: c.1, blue: c.2, alpha: 1.0)
        mat.roughness.contents = 0.35
        mat.metalness.contents = 0.9
        return mat
    }

    /// 轉子軸轂材質
    private func rotorHubMaterial() -> SCNMaterial {
        let mat = SCNMaterial()
        mat.lightingModel = .physicallyBased
        mat.diffuse.contents = NSColor(red: 0.40, green: 0.38, blue: 0.35, alpha: 1.0)
        mat.roughness.contents = 0.2
        mat.metalness.contents = 0.95
        return mat
    }

    // MARK: - 字母貼圖快取

    private var letterTextureCache: [Character: NSImage] = [:]

    /// 生成字母貼圖（白色粗體字母於黑色圓形背景）
    private func letterTexture(for letter: Character) -> NSImage {
        if let cached = letterTextureCache[letter] { return cached }

        let size = NSSize(width: 64, height: 64)
        let image = NSImage(size: size)
        image.lockFocus()

        // 黑色圓形背景
        NSColor(red: 0.12, green: 0.12, blue: 0.12, alpha: 1.0).setFill()
        NSBezierPath(ovalIn: NSRect(origin: .zero, size: size)).fill()

        // 白色字母
        let str = String(letter)
        let font = NSFont.systemFont(ofSize: 36, weight: .bold)
        let attrs: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: NSColor.white,
        ]
        let textSize = str.size(withAttributes: attrs)
        let x = (size.width - textSize.width) / 2
        let y = (size.height - textSize.height) / 2
        str.draw(at: NSPoint(x: x, y: y), withAttributes: attrs)

        image.unlockFocus()
        letterTextureCache[letter] = image
        return image
    }

    private func rotorWindowFrameMaterial() -> SCNMaterial {
        let mat = SCNMaterial()
        mat.lightingModel = .physicallyBased
        mat.diffuse.contents = NSColor(red: 0.70, green: 0.65, blue: 0.55, alpha: 1.0)
        mat.roughness.contents = 0.2
        mat.metalness.contents = 0.95
        return mat
    }

    private func rotorWindowGlassMaterial() -> SCNMaterial {
        let mat = SCNMaterial()
        mat.lightingModel = .physicallyBased
        mat.diffuse.contents = NSColor(red: 0.92, green: 0.90, blue: 0.82, alpha: 1.0)
        mat.roughness.contents = 0.1
        mat.metalness.contents = 0.0
        mat.transparency = 0.7
        return mat
    }

    private func plugboardPanelMaterial() -> SCNMaterial {
        let mat = SCNMaterial()
        mat.lightingModel = .physicallyBased
        mat.diffuse.contents = NSColor(red: 0.10, green: 0.10, blue: 0.10, alpha: 1.0)
        mat.roughness.contents = 0.6
        mat.metalness.contents = 0.3
        return mat
    }

    private func plugSocketMaterial() -> SCNMaterial {
        let mat = SCNMaterial()
        mat.lightingModel = .physicallyBased
        mat.diffuse.contents = NSColor(red: 0.75, green: 0.65, blue: 0.35, alpha: 1.0)
        mat.roughness.contents = 0.3
        mat.metalness.contents = 0.95
        return mat
    }

    private func metalTrimMaterial() -> SCNMaterial {
        let mat = SCNMaterial()
        mat.lightingModel = .physicallyBased
        mat.diffuse.contents = NSColor(red: 0.65, green: 0.60, blue: 0.50, alpha: 1.0)
        mat.roughness.contents = 0.2
        mat.metalness.contents = 0.95
        return mat
    }

    // MARK: - 場景建構

    func buildScene(in scene: SCNScene) {
        let rootNode = scene.rootNode

        setupCamera(in: rootNode)
        setupLighting(in: rootNode)
        setupEnvironment(in: scene)

        // 機體外殼
        let caseNode = buildCase()
        rootNode.addChildNode(caseNode)

        // 鍵盤 — 機體上表面靠前方
        let keyboardNode = buildKeyboard()
        keyboardNode.position = SCNVector3(0, caseHeight / 2 + 0.001, 0.03)
        rootNode.addChildNode(keyboardNode)

        // 燈板 — 鍵盤後方
        let lampboardNode = buildLampboard()
        lampboardNode.position = SCNVector3(0, caseHeight / 2 + 0.001, -0.04)
        rootNode.addChildNode(lampboardNode)

        // 轉子 — 機體後上方
        let rotorAssembly = buildRotorAssembly()
        rotorAssembly.position = SCNVector3(0, caseHeight / 2 + 0.055, -0.10)
        rootNode.addChildNode(rotorAssembly)

        // 接線板 — 機體前方面板
        let plugboardNode = buildPlugboard()
        plugboardNode.position = SCNVector3(0, 0, caseDepth / 2 + 0.01)
        plugboardNode.eulerAngles.x = CGFloat.pi * 0.40
        rootNode.addChildNode(plugboardNode)
    }

    // MARK: - 攝影機（配合新尺寸）

    private func setupCamera(in rootNode: SCNNode) {
        let cameraNode = SCNNode()
        cameraNode.name = "camera"
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.fieldOfView = 40
        cameraNode.camera?.zNear = 0.01
        cameraNode.camera?.zFar = 100
        cameraNode.camera?.bloomIntensity = 0.5
        cameraNode.camera?.bloomThreshold = 0.8
        cameraNode.camera?.bloomBlurRadius = 10

        // 拉遠攝影機以容納更高的機體
        cameraNode.position = SCNVector3(0, 0.35, 0.45)
        cameraNode.look(at: SCNVector3(0, 0.04, -0.02))
        rootNode.addChildNode(cameraNode)
    }

    // MARK: - 光源（配合新尺寸調整位置）

    private func setupLighting(in rootNode: SCNNode) {
        let mainLight = SCNNode()
        mainLight.name = "mainLight"
        mainLight.light = SCNLight()
        mainLight.light?.type = .directional
        mainLight.light?.intensity = 900
        mainLight.light?.color = NSColor(white: 0.95, alpha: 1.0)
        mainLight.light?.castsShadow = true
        mainLight.light?.shadowMode = .deferred
        mainLight.light?.shadowSampleCount = 8
        mainLight.light?.shadowRadius = 3
        mainLight.position = SCNVector3(0.4, 0.6, 0.4)
        mainLight.look(at: SCNVector3(0, 0, 0))
        rootNode.addChildNode(mainLight)

        let ambientLight = SCNNode()
        ambientLight.name = "ambientLight"
        ambientLight.light = SCNLight()
        ambientLight.light?.type = .ambient
        ambientLight.light?.intensity = 350
        ambientLight.light?.color = NSColor(red: 0.9, green: 0.85, blue: 0.8, alpha: 1.0)
        rootNode.addChildNode(ambientLight)

        let fillLight = SCNNode()
        fillLight.name = "fillLight"
        fillLight.light = SCNLight()
        fillLight.light?.type = .directional
        fillLight.light?.intensity = 250
        fillLight.light?.color = NSColor(red: 0.8, green: 0.85, blue: 1.0, alpha: 1.0)
        fillLight.position = SCNVector3(-0.4, 0.4, -0.2)
        fillLight.look(at: SCNVector3(0, 0, 0))
        rootNode.addChildNode(fillLight)
    }

    // MARK: - 環境

    private func setupEnvironment(in scene: SCNScene) {
        scene.background.contents = NSColor(red: 0.13, green: 0.13, blue: 0.16, alpha: 1.0)
    }

    // MARK: - 機體外殼（歷史尺寸）

    private func buildCase() -> SCNNode {
        let caseNode = SCNNode()
        caseNode.name = "enigma_case"

        // 主體箱體
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

        // 上蓋板（打開狀態，角度約 25°）
        let lidBox = SCNBox(
            width: caseWidth - 0.005,
            height: 0.008,
            length: caseDepth * 0.45,
            chamferRadius: 0.003
        )
        lidBox.firstMaterial = darkWoodMaterial()
        let lidNode = SCNNode(geometry: lidBox)
        lidNode.name = "case_lid"
        // 蓋板鉸鏈在後方邊緣
        let lidPivotZ = -caseDepth / 2
        lidNode.pivot = SCNMatrix4MakeTranslation(0, 0, CGFloat(lidBox.length / 2))
        lidNode.position = SCNVector3(0, caseHeight / 2 + 0.001, lidPivotZ)
        lidNode.eulerAngles.x = -CGFloat.pi * 25.0 / 180.0
        caseNode.addChildNode(lidNode)

        // 前方面板邊框（接線板背板）
        let frontPanelBox = SCNBox(
            width: caseWidth,
            height: caseHeight * 0.6,
            length: 0.006,
            chamferRadius: 0.002
        )
        frontPanelBox.firstMaterial = darkWoodMaterial()
        let frontPanel = SCNNode(geometry: frontPanelBox)
        frontPanel.name = "case_front_panel"
        frontPanel.position = SCNVector3(0, -caseHeight * 0.1, caseDepth / 2 + 0.003)
        caseNode.addChildNode(frontPanel)

        // 金屬鉸鏈裝飾（上蓋板兩側）
        for side in [-1.0, 1.0] as [CGFloat] {
            let hinge = SCNCylinder(radius: 0.004, height: 0.015)
            hinge.firstMaterial = metalTrimMaterial()
            let hingeNode = SCNNode(geometry: hinge)
            hingeNode.position = SCNVector3(
                side * (caseWidth / 2 - 0.015),
                caseHeight / 2 + 0.002,
                -caseDepth / 2 + 0.005
            )
            hingeNode.eulerAngles.z = CGFloat.pi / 2
            caseNode.addChildNode(hingeNode)
        }

        return caseNode
    }

    // MARK: - 鍵盤（含圓環金屬邊框）

    private func buildKeyboard() -> SCNNode {
        let keyboardNode = SCNNode()
        keyboardNode.name = "keyboard"

        for (rowIndex, row) in keyboardRows.enumerated() {
            let rowOffset = CGFloat(rowIndex) * keySpacing
            let colCount = CGFloat(row.count)
            let rowStartX = -(colCount - 1) * keySpacing / 2
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

    private func buildKey(letter: Character) -> SCNNode {
        let keyGroup = SCNNode()
        keyGroup.name = "key_\(letter)"

        // 圓環金屬邊框
        let ring = SCNTorus(ringRadius: keyRingRadius, pipeRadius: 0.001)
        ring.firstMaterial = keyRingMaterial()
        let ringNode = SCNNode(geometry: ring)
        ringNode.position = SCNVector3(0, keyHeight / 2, 0)
        keyGroup.addChildNode(ringNode)

        // 按鍵圓柱體
        let keyCylinder = SCNCylinder(radius: keyRadius, height: keyHeight)
        keyCylinder.firstMaterial = keyMetalMaterial()
        let keyBody = SCNNode(geometry: keyCylinder)
        keyBody.name = "key_\(letter)"
        keyGroup.addChildNode(keyBody)

        // 字母貼圖平面（取代 SCNText，確保各角度清晰可讀）
        let labelSize = keyRadius * 1.6
        let labelPlane = SCNPlane(width: labelSize, height: labelSize)
        let labelMat = SCNMaterial()
        labelMat.diffuse.contents = letterTexture(for: letter)
        labelMat.isDoubleSided = true
        labelMat.lightingModel = .constant
        labelPlane.firstMaterial = labelMat

        let labelNode = SCNNode(geometry: labelPlane)
        labelNode.name = "key_label_\(letter)"
        labelNode.position = SCNVector3(0, keyHeight / 2 + 0.0004, 0)
        labelNode.eulerAngles.x = -CGFloat.pi / 2
        keyGroup.addChildNode(labelNode)

        return keyGroup
    }

    // MARK: - 燈板（含圓形底座燈罩）

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

    private func buildLamp(letter: Character) -> SCNNode {
        let lampGroup = SCNNode()
        lampGroup.name = "lamp_\(letter)"

        // 圓形底座燈罩
        let baseCylinder = SCNCylinder(radius: lampBaseRadius, height: lampBaseHeight)
        baseCylinder.firstMaterial = lampBaseMaterial()
        let baseNode = SCNNode(geometry: baseCylinder)
        baseNode.position = SCNVector3(0, -lampBaseHeight / 2, 0)
        lampGroup.addChildNode(baseNode)

        // 燈泡球體
        let sphere = SCNSphere(radius: lampRadius)
        sphere.firstMaterial = lampMaterial()
        let lampBody = SCNNode(geometry: sphere)
        lampBody.name = "lamp_\(letter)"
        lampBody.position = SCNVector3(0, lampBaseHeight / 2, 0)
        lampGroup.addChildNode(lampBody)

        // 字母標籤
        let text = SCNText(string: String(letter), extrusionDepth: 0.0003)
        text.font = NSFont.systemFont(ofSize: 0.005, weight: .medium)
        text.flatness = 0.1
        let textMat = SCNMaterial()
        textMat.diffuse.contents = NSColor(red: 0.3, green: 0.25, blue: 0.2, alpha: 1.0)
        text.firstMaterial = textMat

        let textNode = SCNNode(geometry: text)
        let (min, max) = textNode.boundingBox
        let textWidth = max.x - min.x
        textNode.position = SCNVector3(
            -textWidth / 2,
            lampRadius + lampBaseHeight / 2 + 0.001,
            0
        )
        textNode.eulerAngles.x = -CGFloat.pi / 2
        lampGroup.addChildNode(textNode)

        return lampGroup
    }

    // MARK: - 轉子（歷史尺寸，含金屬框窗口）

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

    private func buildRotor(index: Int) -> SCNNode {
        let rotorGroup = SCNNode()
        rotorGroup.name = "rotor_\(index)"

        // 轉子主體（依 index 使用不同色調）
        let cylinder = SCNCylinder(radius: rotorRadius, height: rotorWidth)
        cylinder.firstMaterial = rotorMaterial(index: index)
        let rotorBody = SCNNode(geometry: cylinder)
        rotorBody.name = "rotor_display_\(index)"
        rotorBody.eulerAngles.z = CGFloat.pi / 2
        rotorGroup.addChildNode(rotorBody)

        // 指輪（Finger Wheel）— 外圈 26 個凹槽
        let notchSize: CGFloat = 0.004
        let notchDepth: CGFloat = 0.006
        for i in 0..<26 {
            let angle = CGFloat(i) * (2.0 * CGFloat.pi / 26.0)
            let notchBox = SCNBox(
                width: notchSize,
                height: notchDepth,
                length: rotorWidth + 0.002,
                chamferRadius: 0.0005
            )
            notchBox.firstMaterial = metalTrimMaterial()
            let notchNode = SCNNode(geometry: notchBox)

            let r = rotorRadius + notchDepth / 2 - 0.001
            notchNode.position = SCNVector3(
                0,
                r * cos(angle),
                r * sin(angle)
            )
            // 旋轉指向圓心
            notchNode.eulerAngles.x = angle
            rotorGroup.addChildNode(notchNode)
        }

        // 中心軸轂（Hub）
        let hubOuter = SCNCylinder(radius: 0.012, height: rotorWidth + 0.004)
        hubOuter.firstMaterial = rotorHubMaterial()
        let hubOuterNode = SCNNode(geometry: hubOuter)
        hubOuterNode.eulerAngles.z = CGFloat.pi / 2
        rotorGroup.addChildNode(hubOuterNode)

        let hubInner = SCNCylinder(radius: 0.006, height: rotorWidth + 0.006)
        let hubInnerMat = SCNMaterial()
        hubInnerMat.lightingModel = .physicallyBased
        hubInnerMat.diffuse.contents = NSColor(red: 0.25, green: 0.24, blue: 0.22, alpha: 1.0)
        hubInnerMat.roughness.contents = 0.3
        hubInnerMat.metalness.contents = 0.95
        hubInner.firstMaterial = hubInnerMat
        let hubInnerNode = SCNNode(geometry: hubInner)
        hubInnerNode.eulerAngles.z = CGFloat.pi / 2
        rotorGroup.addChildNode(hubInnerNode)

        // 刻度標記 — 轉子側面 26 條等距刻線
        for i in 0..<26 {
            let angle = CGFloat(i) * (2.0 * CGFloat.pi / 26.0)
            let tickBox = SCNBox(width: 0.001, height: 0.008, length: 0.001, chamferRadius: 0)
            let tickMat = SCNMaterial()
            tickMat.lightingModel = .physicallyBased
            tickMat.diffuse.contents = NSColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
            tickMat.metalness.contents = 0.5
            tickBox.firstMaterial = tickMat

            let tickNode = SCNNode(geometry: tickBox)
            let tickR = rotorRadius - 0.003
            tickNode.position = SCNVector3(
                rotorWidth / 2 + 0.001,
                tickR * cos(angle),
                tickR * sin(angle)
            )
            tickNode.eulerAngles.x = angle
            rotorGroup.addChildNode(tickNode)
        }

        // 邊緣凹槽裝飾（細圓環）
        for offset in [-rotorWidth / 2 + 0.002, rotorWidth / 2 - 0.002] as [CGFloat] {
            let groove = SCNTorus(ringRadius: rotorRadius - 0.001, pipeRadius: 0.001)
            groove.firstMaterial = metalTrimMaterial()
            let grooveNode = SCNNode(geometry: groove)
            grooveNode.position = SCNVector3(offset, 0, 0)
            grooveNode.eulerAngles.z = CGFloat.pi / 2
            rotorGroup.addChildNode(grooveNode)
        }

        // 金屬框視窗
        let windowFrameBox = SCNBox(width: 0.025, height: 0.005, length: 0.020, chamferRadius: 0.002)
        windowFrameBox.firstMaterial = rotorWindowFrameMaterial()
        let windowFrame = SCNNode(geometry: windowFrameBox)
        windowFrame.position = SCNVector3(0, rotorRadius + 0.002, 0)
        rotorGroup.addChildNode(windowFrame)

        // 玻璃視窗
        let glassBox = SCNBox(width: 0.020, height: 0.003, length: 0.015, chamferRadius: 0.001)
        glassBox.firstMaterial = rotorWindowGlassMaterial()
        let glassNode = SCNNode(geometry: glassBox)
        glassNode.position = SCNVector3(0, rotorRadius + 0.004, 0)
        rotorGroup.addChildNode(glassNode)

        // 字母顯示
        let text = SCNText(string: "A", extrusionDepth: 0.0005)
        text.font = NSFont.monospacedSystemFont(ofSize: 0.012, weight: .bold)
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
            rotorRadius + 0.005,
            0.006
        )
        textNode.eulerAngles.x = -CGFloat.pi / 2
        rotorGroup.addChildNode(textNode)

        return rotorGroup
    }

    // MARK: - 接線板

    private func buildPlugboard() -> SCNNode {
        let plugboardNode = SCNNode()
        plugboardNode.name = "plugboard"

        let panelBox = SCNBox(width: 0.30, height: 0.08, length: 0.005, chamferRadius: 0.002)
        panelBox.firstMaterial = plugboardPanelMaterial()
        let panelNode = SCNNode(geometry: panelBox)
        plugboardNode.addChildNode(panelNode)

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

    private func buildPlugSocket(letter: Character) -> SCNNode {
        let socketGroup = SCNNode()
        socketGroup.name = "plug_\(letter)"

        let cylinder = SCNCylinder(radius: 0.004, height: 0.003)
        cylinder.firstMaterial = plugSocketMaterial()
        let socketBody = SCNNode(geometry: cylinder)
        socketBody.eulerAngles.x = CGFloat.pi / 2
        socketGroup.addChildNode(socketBody)

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

    func addPlugWire(from letterA: Int, to letterB: Int, in scene: SCNScene) {
        guard let plugboard = scene.rootNode.childNode(withName: "plugboard", recursively: true) else { return }

        let charA = Character(UnicodeScalar(letterA + Int(Character("A").asciiValue!))!)
        let charB = Character(UnicodeScalar(letterB + Int(Character("A").asciiValue!))!)

        guard let socketA = plugboard.childNode(withName: "plug_\(charA)", recursively: true),
              let socketB = plugboard.childNode(withName: "plug_\(charB)", recursively: true) else { return }

        let posA = socketA.position
        let posB = socketB.position

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

        wireNode.position = SCNVector3(
            (posA.x + posB.x) / 2,
            (posA.y + posB.y) / 2,
            (posA.z + posB.z) / 2 + 0.005
        )

        wireNode.look(at: SCNVector3(posB.x, posB.y, posB.z + 0.005))
        wireNode.eulerAngles.x += CGFloat.pi / 2

        plugboard.addChildNode(wireNode)
    }
}
