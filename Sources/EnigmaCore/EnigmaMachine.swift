import Foundation
import Observation

/// Enigma 密碼機完整模型
@Observable
public final class EnigmaMachine: @unchecked Sendable {
    /// 左轉子
    public var leftRotor: Rotor
    /// 中轉子
    public var middleRotor: Rotor
    /// 右轉子
    public var rightRotor: Rotor
    /// 反射器
    public var reflector: Reflector
    /// 接線板
    public var plugboard: Plugboard

    /// 初始化 Enigma 密碼機
    public init(
        leftRotor: Rotor,
        middleRotor: Rotor,
        rightRotor: Rotor,
        reflector: Reflector,
        plugboard: Plugboard = Plugboard()
    ) {
        self.leftRotor = leftRotor
        self.middleRotor = middleRotor
        self.rightRotor = rightRotor
        self.reflector = reflector
        self.plugboard = plugboard
    }

    /// 使用預設設定初始化（Rotors I-II-III，Reflector B）
    public convenience init() {
        self.init(
            leftRotor: .rotorI(),
            middleRotor: .rotorII(),
            rightRotor: .rotorIII(),
            reflector: .reflectorB()
        )
    }

    // MARK: - 轉子旋轉機制

    /// 執行轉子旋轉（在加密前呼叫）
    ///
    /// 旋轉規則：
    /// 1. 右轉子每次都旋轉
    /// 2. 若右轉子在缺口位置，中轉子旋轉
    /// 3. 若中轉子在缺口位置，左轉子旋轉，且中轉子也旋轉（雙重進位）
    public func stepRotors() {
        // 雙重進位：中轉子在缺口位置時，自身再轉一格並帶動左轉子
        if middleRotor.isAtNotch {
            leftRotor.step()
            middleRotor.step()
        } else if rightRotor.isAtNotch {
            middleRotor.step()
        }

        // 右轉子每次都旋轉
        rightRotor.step()
    }

    // MARK: - 加密

    /// 加密單一字母（0–25）
    /// 訊號路徑：接線板 → 右轉子(正) → 中轉子(正) → 左轉子(正) → 反射器 → 左轉子(反) → 中轉子(反) → 右轉子(反) → 接線板
    public func encryptLetter(_ input: Int) -> Int {
        // 先旋轉轉子
        stepRotors()

        // 接線板（入）
        var signal = plugboard.swap(input)

        // 轉子正向（右→左）
        signal = rightRotor.encryptForward(signal)
        signal = middleRotor.encryptForward(signal)
        signal = leftRotor.encryptForward(signal)

        // 反射器
        signal = reflector.reflect(signal)

        // 轉子反向（左→右）
        signal = leftRotor.encryptReverse(signal)
        signal = middleRotor.encryptReverse(signal)
        signal = rightRotor.encryptReverse(signal)

        // 接線板（出）
        signal = plugboard.swap(signal)

        return signal
    }

    /// 加密字元（接受大寫或小寫英文字母）
    public func encryptCharacter(_ char: Character) -> Character? {
        let upper = char.uppercased().first!
        guard let ascii = upper.asciiValue,
              ascii >= Character("A").asciiValue!,
              ascii <= Character("Z").asciiValue! else {
            return nil
        }

        let input = Int(ascii - Character("A").asciiValue!)
        let output = encryptLetter(input)
        return Character(UnicodeScalar(output + Int(Character("A").asciiValue!))!)
    }

    /// 加密字串（忽略非字母字元）
    public func encryptString(_ text: String) -> String {
        var result = ""
        for char in text {
            if let encrypted = encryptCharacter(char) {
                result.append(encrypted)
            }
        }
        return result
    }

    // MARK: - 設定管理

    /// 設定轉子位置
    public func setPositions(left: Int, middle: Int, right: Int) {
        leftRotor.position = left
        middleRotor.position = middle
        rightRotor.position = right
    }

    /// 以字母設定轉子位置
    public func setPositions(left: Character, middle: Character, right: Character) {
        leftRotor.position = Int(left.asciiValue! - Character("A").asciiValue!)
        middleRotor.position = Int(middle.asciiValue! - Character("A").asciiValue!)
        rightRotor.position = Int(right.asciiValue! - Character("A").asciiValue!)
    }

    /// 設定環設定
    public func setRingSettings(left: Int, middle: Int, right: Int) {
        leftRotor.ringSetting = left
        middleRotor.ringSetting = middle
        rightRotor.ringSetting = right
    }

    /// 取得當前轉子位置（字母）
    public var positionLetters: (Character, Character, Character) {
        let l = Character(UnicodeScalar(leftRotor.position + Int(Character("A").asciiValue!))!)
        let m = Character(UnicodeScalar(middleRotor.position + Int(Character("A").asciiValue!))!)
        let r = Character(UnicodeScalar(rightRotor.position + Int(Character("A").asciiValue!))!)
        return (l, m, r)
    }

    /// 重置轉子到指定位置
    public func reset(to config: MachineConfiguration) {
        leftRotor = Rotor.rotor(named: config.leftRotorName) ?? .rotorI()
        middleRotor = Rotor.rotor(named: config.middleRotorName) ?? .rotorII()
        rightRotor = Rotor.rotor(named: config.rightRotorName) ?? .rotorIII()
        reflector = Reflector.reflector(named: config.reflectorName) ?? .reflectorB()

        setPositions(left: config.leftPosition, middle: config.middlePosition, right: config.rightPosition)
        setRingSettings(left: config.leftRingSetting, middle: config.middleRingSetting, right: config.rightRingSetting)

        plugboard = Plugboard()
        for pair in config.plugboardPairs {
            try? plugboard.addPair(pair.0, pair.1)
        }
    }
}

// MARK: - 輔助方法

extension EnigmaMachine {
    /// 字母轉索引
    public static func letterToIndex(_ letter: Character) -> Int {
        Int(letter.uppercased().first!.asciiValue! - Character("A").asciiValue!)
    }

    /// 索引轉字母
    public static func indexToLetter(_ index: Int) -> Character {
        Character(UnicodeScalar(index + Int(Character("A").asciiValue!))!)
    }
}
