import Foundation

/// Enigma 密碼機轉子模型
public struct Rotor: Sendable {
    /// 轉子名稱
    public let name: String
    /// 正向線路對應表（A=0, B=1, ..., Z=25）
    public let forwardWiring: [Int]
    /// 反向線路對應表
    public let reverseWiring: [Int]
    /// 缺口位置（觸發下一個轉子進位）
    public let notch: Int

    /// 當前轉子位置（0–25）
    public var position: Int = 0
    /// 環設定（Ring Setting，0–25）
    public var ringSetting: Int = 0

    /// 以線路字串初始化轉子
    /// - Parameters:
    ///   - name: 轉子名稱
    ///   - wiring: 26 字母線路對應字串（例如 "EKMFLGDQVZNTOWYHXUSPAIBRCJ"）
    ///   - notch: 缺口字母（例如 'Q'）
    public init(name: String, wiring: String, notch: Character) {
        self.name = name
        self.notch = Int(notch.asciiValue! - Character("A").asciiValue!)

        let wiringChars = Array(wiring)
        var forward = [Int](repeating: 0, count: 26)
        var reverse = [Int](repeating: 0, count: 26)

        for i in 0..<26 {
            let mapped = Int(wiringChars[i].asciiValue! - Character("A").asciiValue!)
            forward[i] = mapped
            reverse[mapped] = i
        }

        self.forwardWiring = forward
        self.reverseWiring = reverse
    }

    /// 正向加密（右→左方向）
    public func encryptForward(_ input: Int) -> Int {
        let shifted = (input + position - ringSetting + 26) % 26
        let output = forwardWiring[shifted]
        return (output - position + ringSetting + 26) % 26
    }

    /// 反向加密（左→右方向，經反射器後）
    public func encryptReverse(_ input: Int) -> Int {
        let shifted = (input + position - ringSetting + 26) % 26
        let output = reverseWiring[shifted]
        return (output - position + ringSetting + 26) % 26
    }

    /// 轉子是否在缺口位置（將觸發左側轉子進位）
    public var isAtNotch: Bool {
        position == notch
    }

    /// 旋轉一格
    public mutating func step() {
        position = (position + 1) % 26
    }
}

// MARK: - 歷史轉子資料

extension Rotor {
    /// Wehrmacht Enigma Rotor I
    public static func rotorI() -> Rotor {
        Rotor(name: "I", wiring: "EKMFLGDQVZNTOWYHXUSPAIBRCJ", notch: "Q")
    }

    /// Wehrmacht Enigma Rotor II
    public static func rotorII() -> Rotor {
        Rotor(name: "II", wiring: "AJDKSIRUXBLHWTMCQGZNPYFVOE", notch: "E")
    }

    /// Wehrmacht Enigma Rotor III
    public static func rotorIII() -> Rotor {
        Rotor(name: "III", wiring: "BDFHJLCPRTXVZNYEIWGAKMUSQO", notch: "V")
    }

    /// Wehrmacht Enigma Rotor IV
    public static func rotorIV() -> Rotor {
        Rotor(name: "IV", wiring: "ESOVPZJAYQUIRHXLNFTGKDCMWB", notch: "J")
    }

    /// Wehrmacht Enigma Rotor V
    public static func rotorV() -> Rotor {
        Rotor(name: "V", wiring: "VZBRGITYUPSDNHLXAWMJQOFECK", notch: "Z")
    }

    /// 依名稱取得轉子工廠方法
    public static func rotor(named name: String) -> Rotor? {
        switch name {
        case "I": return rotorI()
        case "II": return rotorII()
        case "III": return rotorIII()
        case "IV": return rotorIV()
        case "V": return rotorV()
        default: return nil
        }
    }

    /// 所有可用的轉子名稱
    public static let availableNames = ["I", "II", "III", "IV", "V"]
}
