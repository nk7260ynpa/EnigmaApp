import Foundation

/// Enigma 密碼機接線板模型
public struct Plugboard: Sendable {
    /// 交換對應表（26 個位置，未配對的字母對應自身）
    public private(set) var mapping: [Int]
    /// 已配對的字母對
    public private(set) var pairs: [(Int, Int)]

    /// 建立空的接線板（無任何配對）
    public init() {
        self.mapping = Array(0..<26)
        self.pairs = []
    }

    /// 以字母對陣列初始化接線板
    /// - Parameter pairs: 字母對陣列，例如 [("A", "B"), ("C", "D")]
    /// - Throws: 如果字母重複或超過 13 組配對
    public init(pairs: [(Character, Character)]) throws {
        self.mapping = Array(0..<26)
        self.pairs = []

        for (a, b) in pairs {
            let indexA = Int(a.asciiValue! - Character("A").asciiValue!)
            let indexB = Int(b.asciiValue! - Character("A").asciiValue!)
            try addPair(indexA, indexB)
        }
    }

    /// 新增一組字母對交換
    public mutating func addPair(_ a: Int, _ b: Int) throws {
        guard a != b else {
            throw PlugboardError.sameLetterPair
        }
        guard a >= 0, a < 26, b >= 0, b < 26 else {
            throw PlugboardError.invalidLetter
        }
        guard mapping[a] == a, mapping[b] == b else {
            throw PlugboardError.letterAlreadyPaired
        }
        guard pairs.count < 13 else {
            throw PlugboardError.tooManyPairs
        }

        mapping[a] = b
        mapping[b] = a
        pairs.append((a, b))
    }

    /// 移除包含指定字母的配對
    public mutating func removePair(containing letter: Int) {
        guard mapping[letter] != letter else { return }
        let partner = mapping[letter]
        mapping[letter] = letter
        mapping[partner] = partner
        pairs.removeAll { ($0.0 == letter || $0.1 == letter) }
    }

    /// 清除所有配對
    public mutating func clearAll() {
        mapping = Array(0..<26)
        pairs = []
    }

    /// 通過接線板進行字母替換
    public func swap(_ input: Int) -> Int {
        mapping[input]
    }
}

// MARK: - 錯誤類型

public enum PlugboardError: Error, CustomStringConvertible, Sendable {
    case sameLetterPair
    case invalidLetter
    case letterAlreadyPaired
    case tooManyPairs

    public var description: String {
        switch self {
        case .sameLetterPair:
            return "不可將同一字母與自身配對"
        case .invalidLetter:
            return "字母索引必須在 0–25 範圍內"
        case .letterAlreadyPaired:
            return "該字母已在其他配對中使用"
        case .tooManyPairs:
            return "接線板最多支援 13 組配對"
        }
    }
}
