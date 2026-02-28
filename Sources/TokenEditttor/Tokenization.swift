//
//  Tokenization.swift
//  TokenEditttor
//
//  Created by Eugene Kovs on 26.02.2026.
//  https://github.com/kovs705
//

import Foundation
import NaturalLanguage
@preconcurrency import Tiktoken

public enum OpenAITokenEncoding: String, CaseIterable, Sendable {
    case cl100kBase = "cl100k_base"
    case p50kBase = "p50k_base"
    case p50kEdit = "p50k_edit"
    case r50kBase = "r50k_base"
    case gpt2

    // Tiktoken Swift package resolves encodings from representative model ids.
    fileprivate var lookupModel: String {
        switch self {
        case .cl100kBase:
            return "gpt-4"
        case .p50kBase:
            return "text-davinci-003"
        case .p50kEdit:
            return "text-davinci-edit-001"
        case .r50kBase:
            return "davinci"
        case .gpt2:
            return "gpt2"
        }
    }
}

public enum AITokenizer: Equatable, Sendable {
    case words
    case characters
    case approximateCharactersPerToken(Double)
    case openAIEncoding(OpenAITokenEncoding)

    public static func wordCount(in text: String) -> Int {
        guard !text.isEmpty else { return 0 }
        let tokenizer = NLTokenizer(unit: .word)
        tokenizer.string = text
        return tokenizer.tokens(for: text.startIndex..<text.endIndex).count
    }

    public var supportsSynchronousCounting: Bool {
        if case .openAIEncoding = self {
            return false
        }
        return true
    }

    public func countSync(in text: String) -> Int? {
        guard !text.isEmpty else { return 0 }

        switch self {
        case .words:
            return Self.wordCount(in: text)
        case .characters:
            return text.count
        case .approximateCharactersPerToken(let divisor):
            let normalizedDivisor = max(divisor, 0.1)
            return Int(ceil(Double(text.count) / normalizedDivisor))
        case .openAIEncoding:
            return nil
        }
    }

    public func count(in text: String) -> Int {
        switch self {
        case .openAIEncoding:
            // Kept for backwards compatibility. Use countAsync(in:) for OpenAI encodings.
            return 0
        default:
            return countSync(in: text) ?? 0
        }
    }

    public func countAsync(in text: String) async -> Int {
        guard !text.isEmpty else { return 0 }

        switch self {
        case .openAIEncoding(let encoding):
            return await OpenAITokenCounter.shared.count(in: text, encoding: encoding)
        default:
            return countSync(in: text) ?? 0
        }
    }
}

actor OpenAITokenCounter {
    static let shared = OpenAITokenCounter()

    private var encodings: [OpenAITokenEncoding: Encoding] = [:]

    func count(in text: String, encoding: OpenAITokenEncoding) async -> Int {
        guard !text.isEmpty else { return 0 }

        if let cached = encodings[encoding] {
            return cached.encode(value: text).count
        }

        guard let resolved = try? await Tiktoken.shared.getEncoding(encoding.lookupModel) else { return 0 }
        encodings[encoding] = resolved
        return resolved.encode(value: text).count
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

public struct TokenMetrics: Equatable, Sendable {
    public let wordCount: Int
    public let tokenCount: Int
    public let usage: TokenUsage

    public init(wordCount: Int, tokenCount: Int, usage: TokenUsage) {
        self.wordCount = max(wordCount, 0)
        self.tokenCount = max(tokenCount, 0)
        self.usage = usage
    }

    public static func calculate(
        text: String,
        maxTokens: Int,
        tokenizer: AITokenizer
    ) async -> TokenMetrics {
        let words = AITokenizer.wordCount(in: text)
        let tokens = await tokenizer.countAsync(in: text)
        let usage = TokenUsage(used: tokens, maxTokens: maxTokens)
        return TokenMetrics(wordCount: words, tokenCount: tokens, usage: usage)
    }
}

public struct AIEditorConfiguration: Equatable, Sendable {
    public var maxTokens: Int
    public var tokenizer: AITokenizer
    public var placeholder: String
    public var showsRemainingLabel: Bool
    public var showsWordCountLabel: Bool

    public init(
        maxTokens: Int = 280,
        tokenizer: AITokenizer = .words,
        placeholder: String = "",
        showsRemainingLabel: Bool = true,
        showsWordCountLabel: Bool = false
    ) {
        self.maxTokens = max(maxTokens, 1)
        self.tokenizer = tokenizer
        self.placeholder = placeholder
        self.showsRemainingLabel = showsRemainingLabel
        self.showsWordCountLabel = showsWordCountLabel
    }
}
