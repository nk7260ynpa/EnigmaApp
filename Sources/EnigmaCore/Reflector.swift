import Foundation

/// Enigma 密碼機反射器模型
public struct Reflector: Sendable {
    /// 反射器名稱
    public let name: String
    /// 線路對應表
    public let wiring: [Int]

    /// 以線路字串初始化反射器
    /// - Parameters:
    ///   - name: 反射器名稱
    ///   - wiring: 26 字母線路對應字串
    public init(name: String, wiring: String) {
        self.name = name
        let wiringChars = Array(wiring)
        self.wiring = (0..<26).map { i in
            Int(wiringChars[i].asciiValue! - Character("A").asciiValue!)
        }
    }

    /// 反射訊號
    public func reflect(_ input: Int) -> Int {
        wiring[input]
    }
}

// MARK: - 歷史反射器資料

extension Reflector {
    /// Wehrmacht Enigma Reflector B (UKW-B)
    public static func reflectorB() -> Reflector {
        Reflector(name: "B", wiring: "YRUHQSLDPXNGOKMIEBFZCWVJAT")
    }

    /// Wehrmacht Enigma Reflector C (UKW-C)
    public static func reflectorC() -> Reflector {
        Reflector(name: "C", wiring: "FVPJIAOYEDRZXWGCTKUQSBNMHL")
    }

    /// 依名稱取得反射器
    public static func reflector(named name: String) -> Reflector? {
        switch name {
        case "B": return reflectorB()
        case "C": return reflectorC()
        default: return nil
        }
    }

    /// 所有可用的反射器名稱
    public static let availableNames = ["B", "C"]
}
