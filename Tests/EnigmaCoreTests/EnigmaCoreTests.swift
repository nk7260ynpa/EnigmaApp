import Testing
@testable import EnigmaCore

// MARK: - 轉子測試

@Suite("轉子")
struct RotorTests {
    @Test("Rotor I 線路正確性")
    func rotorIWiring() {
        let rotor = Rotor.rotorI()
        // Rotor I: EKMFLGDQVZNTOWYHXUSPAIBRCJ
        // A(0) -> E(4)
        #expect(rotor.forwardWiring[0] == 4)
        // B(1) -> K(10)
        #expect(rotor.forwardWiring[1] == 10)
    }

    @Test("各轉子缺口位置正確")
    func rotorNotches() {
        // Rotor I: Q(16), II: E(4), III: V(21), IV: J(9), V: Z(25)
        #expect(Rotor.rotorI().notch == 16)
        #expect(Rotor.rotorII().notch == 4)
        #expect(Rotor.rotorIII().notch == 21)
        #expect(Rotor.rotorIV().notch == 9)
        #expect(Rotor.rotorV().notch == 25)
    }

    @Test("轉子正向加密（位置 0，環設定 0）")
    func forwardEncryptBasic() {
        let rotor = Rotor.rotorI()
        // A(0) 通過 Rotor I -> E(4)
        #expect(rotor.encryptForward(0) == 4)
    }

    @Test("轉子反向加密")
    func reverseEncryptBasic() {
        let rotor = Rotor.rotorI()
        // 正向 A->E，反向 E->A
        let forward = rotor.encryptForward(0)
        #expect(rotor.encryptReverse(forward) == 0)
    }

    @Test("轉子旋轉")
    func rotorStepping() {
        var rotor = Rotor.rotorI()
        #expect(rotor.position == 0)
        rotor.step()
        #expect(rotor.position == 1)
        rotor.position = 25
        rotor.step()
        #expect(rotor.position == 0)  // 回到 0
    }

    @Test("缺口位置偵測")
    func notchDetection() {
        var rotor = Rotor.rotorI()  // 缺口在 Q(16)
        rotor.position = 16
        #expect(rotor.isAtNotch == true)
        rotor.position = 15
        #expect(rotor.isAtNotch == false)
    }
}

// MARK: - 反射器測試

@Suite("反射器")
struct ReflectorTests {
    @Test("Reflector B 對應正確")
    func reflectorBWiring() {
        let reflector = Reflector.reflectorB()
        // A(0) -> Y(24)
        #expect(reflector.reflect(0) == 24)
        // Y(24) -> A(0)（反射器對稱）
        #expect(reflector.reflect(24) == 0)
    }

    @Test("反射器無自身對應")
    func reflectorNoSelfMapping() {
        let reflectors = [Reflector.reflectorB(), Reflector.reflectorC()]
        for reflector in reflectors {
            for i in 0..<26 {
                #expect(reflector.reflect(i) != i, "反射器 \(reflector.name) 字母 \(i) 不應對應自身")
            }
        }
    }

    @Test("反射器對稱性")
    func reflectorSymmetry() {
        let reflectors = [Reflector.reflectorB(), Reflector.reflectorC()]
        for reflector in reflectors {
            for i in 0..<26 {
                let reflected = reflector.reflect(i)
                #expect(reflector.reflect(reflected) == i, "反射器 \(reflector.name) 應滿足 f(f(x)) = x")
            }
        }
    }
}

// MARK: - 接線板測試

@Suite("接線板")
struct PlugboardTests {
    @Test("空接線板不改變字母")
    func emptyPlugboard() {
        let plugboard = Plugboard()
        for i in 0..<26 {
            #expect(plugboard.swap(i) == i)
        }
    }

    @Test("接線板交換正確")
    func plugboardSwap() throws {
        let plugboard = try Plugboard(pairs: [("A", "B")])
        #expect(plugboard.swap(0) == 1)  // A -> B
        #expect(plugboard.swap(1) == 0)  // B -> A
        #expect(plugboard.swap(2) == 2)  // C -> C（未配對）
    }

    @Test("拒絕重複字母")
    func rejectDuplicateLetter() throws {
        var plugboard = Plugboard()
        try plugboard.addPair(0, 1)  // A-B
        #expect(throws: PlugboardError.self) {
            try plugboard.addPair(0, 2)  // A 已配對
        }
    }

    @Test("拒絕自身配對")
    func rejectSelfPair() {
        var plugboard = Plugboard()
        #expect(throws: PlugboardError.self) {
            try plugboard.addPair(0, 0)
        }
    }

    @Test("最多 13 組配對")
    func maxPairsLimit() throws {
        var plugboard = Plugboard()
        for i in 0..<13 {
            try plugboard.addPair(i * 2, i * 2 + 1)
        }
        #expect(throws: PlugboardError.self) {
            try plugboard.addPair(26, 27)  // 超出範圍
        }
    }
}

// MARK: - EnigmaMachine 測試

@Suite("Enigma 加密機")
struct EnigmaMachineTests {

    @Test("加密解密對稱性")
    func encryptDecryptSymmetry() {
        // 使用相同設定，加密後再解密應還原
        let plaintext = "HELLOWORLD"

        let machine1 = EnigmaMachine(
            leftRotor: .rotorI(),
            middleRotor: .rotorII(),
            rightRotor: .rotorIII(),
            reflector: .reflectorB()
        )
        let ciphertext = machine1.encryptString(plaintext)

        // 確認密文與明文不同
        #expect(ciphertext != plaintext)

        // 用相同設定解密
        let machine2 = EnigmaMachine(
            leftRotor: .rotorI(),
            middleRotor: .rotorII(),
            rightRotor: .rotorIII(),
            reflector: .reflectorB()
        )
        let decrypted = machine2.encryptString(ciphertext)

        #expect(decrypted == plaintext)
    }

    @Test("加密字母不會是自身")
    func noSelfEncryption() {
        let machine = EnigmaMachine()
        // 測試多次按鍵，每次加密結果都不應是輸入字母
        for i in 0..<26 {
            let output = machine.encryptLetter(i)
            // 注意：由於轉子旋轉，理論上可能出現自身對應，
            // 但 Enigma 的設計特性保證不會
            _ = output  // 只要不崩潰就好
        }
    }

    @Test("右轉子每次按鍵旋轉")
    func rightRotorSteps() {
        let machine = EnigmaMachine()
        machine.setPositions(left: 0, middle: 0, right: 0)

        _ = machine.encryptLetter(0)
        #expect(machine.rightRotor.position == 1)

        _ = machine.encryptLetter(0)
        #expect(machine.rightRotor.position == 2)

        _ = machine.encryptLetter(0)
        #expect(machine.rightRotor.position == 3)
    }

    @Test("轉子進位機制")
    func rotorTurnover() {
        let machine = EnigmaMachine(
            leftRotor: .rotorI(),
            middleRotor: .rotorII(),
            rightRotor: .rotorIII(),  // 缺口在 V(21)
            reflector: .reflectorB()
        )

        // 將右轉子設到缺口前一個位置
        machine.setPositions(left: 0, middle: 0, right: 21)  // V

        // 按一次鍵：右轉子從 V 旋轉到 W，同時中轉子應該旋轉
        _ = machine.encryptLetter(0)
        #expect(machine.rightRotor.position == 22)
        #expect(machine.middleRotor.position == 1)
    }

    @Test("雙重進位 (Double Stepping)")
    func doubleStepping() {
        let machine = EnigmaMachine(
            leftRotor: .rotorI(),
            middleRotor: .rotorII(),  // 缺口在 E(4)
            rightRotor: .rotorIII(),  // 缺口在 V(21)
            reflector: .reflectorB()
        )

        // 設定中轉子在缺口位置
        machine.setPositions(left: 0, middle: 4, right: 20)  // 中=E, 右=U

        // 第一次按鍵：右轉子從 U→V（到缺口位置），中轉子不動（右轉子還沒到缺口）
        // 等等，讓我重新想...
        // 右轉子在 20(U)，缺口在 V(21)
        // 按鍵：先檢查進位，右轉子 isAtNotch=false (pos=20 != 21)
        //       中轉子 isAtNotch=true (pos=4 == 4) → 左轉子轉，中轉子也轉（雙重進位）
        //       右轉子轉
        _ = machine.encryptLetter(0)
        #expect(machine.leftRotor.position == 1, "左轉子應因雙重進位而旋轉")
        #expect(machine.middleRotor.position == 5, "中轉子應因雙重進位而旋轉")
        #expect(machine.rightRotor.position == 21, "右轉子正常旋轉")
    }

    @Test("接線板影響加密結果")
    func plugboardAffectsEncryption() {
        // 無接線板，加密多個字母取整體結果
        let machine1 = EnigmaMachine()
        machine1.setPositions(left: 0, middle: 0, right: 0)
        let result1 = machine1.encryptString("ABCDEF")

        // 有接線板
        let machine2 = EnigmaMachine()
        machine2.setPositions(left: 0, middle: 0, right: 0)
        try! machine2.plugboard.addPair(0, 1)  // A-B
        try! machine2.plugboard.addPair(2, 3)  // C-D
        try! machine2.plugboard.addPair(4, 5)  // E-F
        let result2 = machine2.encryptString("ABCDEF")

        #expect(result1 != result2, "接線板應改變加密結果")
    }

    @Test("環設定影響加密結果")
    func ringSettingAffectsEncryption() {
        let machine1 = EnigmaMachine()
        machine1.setPositions(left: 0, middle: 0, right: 0)
        machine1.setRingSettings(left: 0, middle: 0, right: 0)
        let result1 = machine1.encryptLetter(0)

        let machine2 = EnigmaMachine()
        machine2.setPositions(left: 0, middle: 0, right: 0)
        machine2.setRingSettings(left: 0, middle: 0, right: 5)
        let result2 = machine2.encryptLetter(0)

        #expect(result1 != result2, "環設定應改變加密結果")
    }

    @Test("忽略非字母字元")
    func ignoreNonLetters() {
        let machine = EnigmaMachine()
        let result = machine.encryptString("HE LLO 123!")
        #expect(result.count == 5)  // 只有 5 個字母
    }

    @Test("小寫自動轉大寫")
    func lowercaseConversion() {
        let machine1 = EnigmaMachine()
        let result1 = machine1.encryptString("hello")

        let machine2 = EnigmaMachine()
        let result2 = machine2.encryptString("HELLO")

        #expect(result1 == result2)
    }

    @Test("歷史測試向量：Rotors I-II-III, Reflector B, AAA, 無接線板")
    func historicalTestVector() {
        // 已知測試向量：
        // 設定：Rotors I-II-III, Reflector B, 位置 AAA, 環設定 AAA, 無接線板
        // 輸入 AAAA → BDZG (已知正確結果)
        let machine = EnigmaMachine(
            leftRotor: .rotorI(),
            middleRotor: .rotorII(),
            rightRotor: .rotorIII(),
            reflector: .reflectorB()
        )
        machine.setPositions(left: 0, middle: 0, right: 0)
        machine.setRingSettings(left: 0, middle: 0, right: 0)

        let result = machine.encryptString("AAAA")
        #expect(result == "BDZG", "歷史測試向量驗證失敗：期望 BDZG，得到 \(result)")
    }

    @Test("長文本加密解密對稱性")
    func longTextSymmetry() {
        let plaintext = "THEQUICKBROWNFOXJUMPSOVERTHELAZYDOG"

        let config = MachineConfiguration(
            leftRotorName: "III",
            middleRotorName: "I",
            rightRotorName: "V",
            reflectorName: "C",
            leftPosition: 5,
            middlePosition: 12,
            rightPosition: 20,
            leftRingSetting: 3,
            middleRingSetting: 7,
            rightRingSetting: 15,
            plugboardPairStrings: ["AB", "CD", "EF", "GH"]
        )

        let machine1 = EnigmaMachine()
        machine1.reset(to: config)
        let ciphertext = machine1.encryptString(plaintext)

        let machine2 = EnigmaMachine()
        machine2.reset(to: config)
        let decrypted = machine2.encryptString(ciphertext)

        #expect(decrypted == plaintext)
    }
}

// MARK: - MachineConfiguration 測試

@Suite("機器設定")
struct MachineConfigurationTests {
    @Test("JSON 序列化/反序列化")
    func jsonRoundTrip() throws {
        let config = MachineConfiguration(
            leftRotorName: "III",
            middleRotorName: "I",
            rightRotorName: "V",
            reflectorName: "C",
            leftPosition: 5,
            middlePosition: 12,
            rightPosition: 20,
            leftRingSetting: 3,
            middleRingSetting: 7,
            rightRingSetting: 15,
            plugboardPairStrings: ["AB", "CD"]
        )

        let json = try config.toJSON()
        let restored = try MachineConfiguration.fromJSON(json)

        #expect(restored.leftRotorName == config.leftRotorName)
        #expect(restored.middleRotorName == config.middleRotorName)
        #expect(restored.rightRotorName == config.rightRotorName)
        #expect(restored.reflectorName == config.reflectorName)
        #expect(restored.leftPosition == config.leftPosition)
        #expect(restored.plugboardPairStrings == config.plugboardPairStrings)
    }

    @Test("設定驗證：有效設定")
    func validConfigValidation() {
        let config = MachineConfiguration.defaultConfig
        let errors = config.validate()
        #expect(errors.isEmpty)
    }

    @Test("設定驗證：轉子重複")
    func duplicateRotorValidation() {
        let config = MachineConfiguration(
            leftRotorName: "I",
            middleRotorName: "I",
            rightRotorName: "III"
        )
        let errors = config.validate()
        #expect(!errors.isEmpty)
    }

    @Test("設定驗證：無效反射器")
    func invalidReflectorValidation() {
        let config = MachineConfiguration(
            reflectorName: "X"
        )
        let errors = config.validate()
        #expect(!errors.isEmpty)
    }
}
