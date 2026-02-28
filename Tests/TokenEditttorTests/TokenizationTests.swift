//
//  TokenizationTests.swift
//  TokenEditttor
//
//  Created by Eugene Kovs on 26.02.2026.
//  https://github.com/kovs705
//

import XCTest
@testable import TokenEditttor

final class TokenEditttorTests: XCTestCase {
    func testWordTokenizerCountsWords() {
        let text = "hello world from nl tokenizer"
        let count = AITokenizer.words.count(in: text)
        XCTAssertEqual(count, 5)
    }

    func testCharacterTokenizerCountsGraphemes() {
        let text = "A🙂B"
        let count = AITokenizer.characters.count(in: text)
        XCTAssertEqual(count, 3)
    }

    func testApproximateTokenizerUsesCeiling() {
        let count = AITokenizer.approximateCharactersPerToken(4).count(in: "123456789")
        XCTAssertEqual(count, 3)
    }

    func testTokenUsageOverLimit() {
        let usage = TokenUsage(used: 120, maxTokens: 100)
        XCTAssertTrue(usage.isOverLimit)
        XCTAssertEqual(usage.remaining, -20)
        XCTAssertEqual(usage.percentageRemainingClamped, 0)
    }

    func testConfigurationClampsMinimumTokenLimit() {
        let configuration = AIEditorConfiguration(maxTokens: 0)
        XCTAssertEqual(configuration.maxTokens, 1)
    }
}
