import SwiftUI
import EnigmaCore

/// 設定面板（側邊欄）
struct SettingsPanel: View {
    @Bindable var viewModel: SceneViewModel

    // 轉子選擇
    @State private var leftRotorName: String = "I"
    @State private var middleRotorName: String = "II"
    @State private var rightRotorName: String = "III"

    // 轉子位置
    @State private var leftPosition: Int = 0
    @State private var middlePosition: Int = 0
    @State private var rightPosition: Int = 0

    // 環設定
    @State private var leftRing: Int = 0
    @State private var middleRing: Int = 0
    @State private var rightRing: Int = 0

    // 反射器
    @State private var reflectorName: String = "B"

    // 接線板
    @State private var plugboardInput: String = ""
    @State private var plugboardError: String?

    private let rotorNames = Rotor.availableNames
    private let reflectorNames = Reflector.availableNames
    private let letters = (0..<26).map { String(Character(UnicodeScalar($0 + Int(Character("A").asciiValue!))!)) }

    var body: some View {
        Form {
            // MARK: - 轉子選擇
            Section("轉子選擇") {
                Picker("左轉子", selection: $leftRotorName) {
                    ForEach(rotorNames, id: \.self) { Text("Rotor \($0)") }
                }
                Picker("中轉子", selection: $middleRotorName) {
                    ForEach(rotorNames, id: \.self) { Text("Rotor \($0)") }
                }
                Picker("右轉子", selection: $rightRotorName) {
                    ForEach(rotorNames, id: \.self) { Text("Rotor \($0)") }
                }
            }

            // MARK: - 轉子位置
            Section("初始位置") {
                Picker("左轉子", selection: $leftPosition) {
                    ForEach(0..<26, id: \.self) { Text(letters[$0]) }
                }
                Picker("中轉子", selection: $middlePosition) {
                    ForEach(0..<26, id: \.self) { Text(letters[$0]) }
                }
                Picker("右轉子", selection: $rightPosition) {
                    ForEach(0..<26, id: \.self) { Text(letters[$0]) }
                }
            }

            // MARK: - 環設定
            Section("環設定 (Ring Setting)") {
                Picker("左轉子", selection: $leftRing) {
                    ForEach(0..<26, id: \.self) { Text(letters[$0]) }
                }
                Picker("中轉子", selection: $middleRing) {
                    ForEach(0..<26, id: \.self) { Text(letters[$0]) }
                }
                Picker("右轉子", selection: $rightRing) {
                    ForEach(0..<26, id: \.self) { Text(letters[$0]) }
                }
            }

            // MARK: - 反射器
            Section("反射器") {
                Picker("反射器", selection: $reflectorName) {
                    ForEach(reflectorNames, id: \.self) { Text("Reflector \($0)") }
                }
            }

            // MARK: - 接線板
            Section("接線板 (Plugboard)") {
                TextField("配對（例如：AB CD EF）", text: $plugboardInput)
                    .textFieldStyle(.roundedBorder)

                if let error = plugboardError {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Text("輸入字母對，以空格分隔（最多 13 組）")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            // MARK: - 套用按鈕
            Section {
                Button("套用設定") {
                    applySettings()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .onAppear {
            loadCurrentSettings()
        }
    }

    /// 載入當前設定到 UI
    private func loadCurrentSettings() {
        let config = viewModel.currentConfiguration()
        leftRotorName = config.leftRotorName
        middleRotorName = config.middleRotorName
        rightRotorName = config.rightRotorName
        reflectorName = config.reflectorName
        leftPosition = config.leftPosition
        middlePosition = config.middlePosition
        rightPosition = config.rightPosition
        leftRing = config.leftRingSetting
        middleRing = config.middleRingSetting
        rightRing = config.rightRingSetting
        plugboardInput = config.plugboardPairStrings.joined(separator: " ")
    }

    /// 套用設定到加密引擎
    private func applySettings() {
        plugboardError = nil

        // 檢查轉子不重複
        let rotors = Set([leftRotorName, middleRotorName, rightRotorName])
        if rotors.count < 3 {
            plugboardError = "轉子不可重複使用"
            return
        }

        // 解析接線板配對
        let pairStrings = plugboardInput
            .uppercased()
            .split(separator: " ")
            .map(String.init)
            .filter { !$0.isEmpty }

        let config = MachineConfiguration(
            leftRotorName: leftRotorName,
            middleRotorName: middleRotorName,
            rightRotorName: rightRotorName,
            reflectorName: reflectorName,
            leftPosition: leftPosition,
            middlePosition: middlePosition,
            rightPosition: rightPosition,
            leftRingSetting: leftRing,
            middleRingSetting: middleRing,
            rightRingSetting: rightRing,
            plugboardPairStrings: pairStrings
        )

        let errors = config.validate()
        if !errors.isEmpty {
            plugboardError = errors.joined(separator: "\n")
            return
        }

        viewModel.applyConfiguration(config)
    }
}
