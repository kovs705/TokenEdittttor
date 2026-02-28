//
//  Tokenization.swift
//  TokenEditttor
//
//  Created by Eugene Kovs on 26.02.2026.
//  https://github.com/kovs705
//

import Foundation
import NaturalLanguage

public enum AITokenizer: Equatable, Sendable {
    case words
    case characters
    case approximateCharactersPerToken(Double)

    public func count(in text: String) -> Int {
        guard !text.isEmpty else { return 0 }

        switch self {
        case .words:
            let tokenizer = NLTokenizer(unit: .word)
            tokenizer.string = text
            return tokenizer.tokens(for: text.startIndex..<text.endIndex).count
        case .characters:
            return text.count
        case .approximateCharactersPerToken(let divisor):
            let normalizedDivisor = max(divisor, 0.1)
            return Int(ceil(Double(text.count) / normalizedDivisor))
        }
    }
}

public struct TokenUsage: Equatable, Sendable {
    public let used: Int
    public let remaining: Int
    public let maxTokens: Int

    public init(used: Int, maxTokens: Int) {
        self.used = max(used, 0)
        self.maxTokens = max(maxTokens, 1)
        self.remaining = self.maxTokens - self.used
    }

    public var isOverLimit: Bool {
        remaining < 0
    }

    public var percentageUsed: Double {
        Double(used) / Double(maxTokens)
    }

    public var percentageRemaining: Double {
        Double(remaining) / Double(maxTokens)
    }

    public var percentageRemainingClamped: Double {
        min(max(percentageRemaining, 0), 1)
    }
}

public struct AIEditorConfiguration: Equatable, Sendable {
    public var maxTokens: Int
    public var tokenizer: AITokenizer
    public var placeholder: String
    public var showsRemainingLabel: Bool

    public init(
        maxTokens: Int = 280,
        tokenizer: AITokenizer = .words,
        placeholder: String = "",
        showsRemainingLabel: Bool = true
    ) {
        self.maxTokens = max(maxTokens, 1)
        self.tokenizer = tokenizer
        self.placeholder = placeholder
        self.showsRemainingLabel = showsRemainingLabel
    }
}
