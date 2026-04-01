import Foundation

/// Enigma 密碼機設定（可序列化為 JSON）
public struct MachineConfiguration: Codable, Sendable {
    public var leftRotorName: String
    public var middleRotorName: String
    public var rightRotorName: String
    public var reflectorName: String

    public var leftPosition: Int
    public var middlePosition: Int
    public var rightPosition: Int

    public var leftRingSetting: Int
    public var middleRingSetting: Int
    public var rightRingSetting: Int

    /// 接線板配對，以字串陣列表示（例如 ["AB", "CD"]）
    public var plugboardPairStrings: [String]

    /// 接線板配對索引
    public var plugboardPairs: [(Int, Int)] {
        plugboardPairStrings.compactMap { str in
            let chars = Array(str)
            guard chars.count == 2 else { return nil }
            let a = Int(chars[0].asciiValue! - Character("A").asciiValue!)
            let b = Int(chars[1].asciiValue! - Character("A").asciiValue!)
            return (a, b)
        }
    }

    /// 預設設定
    public static var defaultConfig: MachineConfiguration {
        MachineConfiguration(
            leftRotorName: "I",
            middleRotorName: "II",
            rightRotorName: "III",
            reflectorName: "B",
            leftPosition: 0,
            middlePosition: 0,
            rightPosition: 0,
            leftRingSetting: 0,
            middleRingSetting: 0,
            rightRingSetting: 0,
            plugboardPairStrings: []
        )
    }

    public init(
        leftRotorName: String = "I",
        middleRotorName: String = "II",
        rightRotorName: String = "III",
        reflectorName: String = "B",
        leftPosition: Int = 0,
        middlePosition: Int = 0,
        rightPosition: Int = 0,
        leftRingSetting: Int = 0,
        middleRingSetting: Int = 0,
        rightRingSetting: Int = 0,
        plugboardPairStrings: [String] = []
    ) {
        self.leftRotorName = leftRotorName
        self.middleRotorName = middleRotorName
        self.rightRotorName = rightRotorName
        self.reflectorName = reflectorName
        self.leftPosition = leftPosition
        self.middlePosition = middlePosition
        self.rightPosition = rightPosition
        self.leftRingSetting = leftRingSetting
        self.middleRingSetting = middleRingSetting
        self.rightRingSetting = rightRingSetting
        self.plugboardPairStrings = plugboardPairStrings
    }

    /// 從 EnigmaMachine 擷取當前設定
    public static func from(machine: EnigmaMachine) -> MachineConfiguration {
        let pairStrings = machine.plugboard.pairs.map { pair in
            let a = Character(UnicodeScalar(pair.0 + Int(Character("A").asciiValue!))!)
            let b = Character(UnicodeScalar(pair.1 + Int(Character("A").asciiValue!))!)
            return "\(a)\(b)"
        }

        return MachineConfiguration(
            leftRotorName: machine.leftRotor.name,
            middleRotorName: machine.middleRotor.name,
            rightRotorName: machine.rightRotor.name,
            reflectorName: machine.reflector.name,
            leftPosition: machine.leftRotor.position,
            middlePosition: machine.middleRotor.position,
            rightPosition: machine.rightRotor.position,
            leftRingSetting: machine.leftRotor.ringSetting,
            middleRingSetting: machine.middleRotor.ringSetting,
            rightRingSetting: machine.rightRotor.ringSetting,
            plugboardPairStrings: pairStrings
        )
    }

    /// 驗證設定合法性
    public func validate() -> [String] {
        var errors: [String] = []

        // 檢查轉子名稱有效
        let validRotors = Set(Rotor.availableNames)
        if !validRotors.contains(leftRotorName) { errors.append("左轉子名稱無效: \(leftRotorName)") }
        if !validRotors.contains(middleRotorName) { errors.append("中轉子名稱無效: \(middleRotorName)") }
        if !validRotors.contains(rightRotorName) { errors.append("右轉子名稱無效: \(rightRotorName)") }

        // 檢查轉子不重複
        let rotorSet = Set([leftRotorName, middleRotorName, rightRotorName])
        if rotorSet.count < 3 { errors.append("轉子不可重複使用") }

        // 檢查反射器名稱有效
        if !Reflector.availableNames.contains(reflectorName) {
            errors.append("反射器名稱無效: \(reflectorName)")
        }

        // 檢查位置範圍
        let range = 0..<26
        if !range.contains(leftPosition) { errors.append("左轉子位置超出範圍") }
        if !range.contains(middlePosition) { errors.append("中轉子位置超出範圍") }
        if !range.contains(rightPosition) { errors.append("右轉子位置超出範圍") }
        if !range.contains(leftRingSetting) { errors.append("左轉子環設定超出範圍") }
        if !range.contains(middleRingSetting) { errors.append("中轉子環設定超出範圍") }
        if !range.contains(rightRingSetting) { errors.append("右轉子環設定超出範圍") }

        // 檢查接線板配對
        var usedLetters = Set<Int>()
        for pairStr in plugboardPairStrings {
            let chars = Array(pairStr)
            guard chars.count == 2 else {
                errors.append("接線板配對格式無效: \(pairStr)")
                continue
            }
            let a = Int(chars[0].asciiValue! - Character("A").asciiValue!)
            let b = Int(chars[1].asciiValue! - Character("A").asciiValue!)
            if usedLetters.contains(a) || usedLetters.contains(b) {
                errors.append("接線板字母重複使用: \(pairStr)")
            }
            usedLetters.insert(a)
            usedLetters.insert(b)
        }

        return errors
    }

    // MARK: - JSON 序列化

    /// 匯出為 JSON Data
    public func toJSON() throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(self)
    }

    /// 從 JSON Data 匯入
    public static func fromJSON(_ data: Data) throws -> MachineConfiguration {
        let decoder = JSONDecoder()
        return try decoder.decode(MachineConfiguration.self, from: data)
    }
}
