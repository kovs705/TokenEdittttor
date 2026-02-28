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

    func testAsyncCountMatchesSyncForWordTokenizer() async {
        let text = "one two three"
        let syncCount = AITokenizer.words.count(in: text)
        let asyncCount = await AITokenizer.words.countAsync(in: text)
        XCTAssertEqual(syncCount, asyncCount)
    }

    func testTokenMetricsCalculationForWordsTokenizer() async {
        let metrics = await TokenMetrics.calculate(
            text: "hello world",
            maxTokens: 10,
            tokenizer: .words
        )
        XCTAssertEqual(metrics.wordCount, 2)
        XCTAssertEqual(metrics.tokenCount, 2)
        XCTAssertEqual(metrics.usage.remaining, 8)
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
