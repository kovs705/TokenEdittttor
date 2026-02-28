//
//  AITextEditor.swift
//  TokenEditttor
//
//  Created by Eugene Kovs on 26.02.2026.
//  https://github.com/kovs705
//

import SwiftUI

@MainActor
public struct AITextEditor: View {
    @Binding private var text: String
    @Binding private var percentageRemaining: Double
    private var configuration: AIEditorConfiguration
    private var style: AITextEditorStyle
    private var onMetricsChange: ((TokenMetrics) -> Void)?

    @State private var metrics: TokenMetrics = .init(
        wordCount: 0,
        tokenCount: 0,
        usage: .init(used: 0, maxTokens: 1)
    )
    @State private var countingTask: Task<Void, Never>?

    public init(
        _ text: Binding<String>,
        _ percentageRemaining: Binding<Double>,
        configuration: AIEditorConfiguration = .init()
    ) {
        self._text = text
        self._percentageRemaining = percentageRemaining
        self.configuration = configuration
        self.style = .init()
        self.onMetricsChange = nil
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topLeading) {
                if text.isEmpty, !configuration.placeholder.isEmpty {
                    Text(configuration.placeholder)
                        .font(style.font)
                        .foregroundStyle(style.placeholderColor)
                        .padding(.top, 15)
                        .padding(.leading, 12)
                }

                TextEditor(text: $text)
                    .font(style.font)
                    .fontWeight(style.isBold ? .bold : .regular)
                    .foregroundStyle(style.textColor)
                    .scrollContentBackground(.hidden)
                    .padding(8)
                    .frame(minHeight: 120)
            }
            .background(style.backgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: style.cornerRadius, style: .continuous))

            HStack {
                if configuration.showsWordCountLabel {
                    Text("Words: \(metrics.wordCount)")
                        .font(.footnote.monospacedDigit())
                        .foregroundStyle(.secondary)
                }
                Spacer()
                TokenRingView(
                    usage: metrics.usage,
                    style: styleWithConfigurationValue
                )
            }
        }
        .onAppear(perform: refreshMetrics)
        .onChange(of: text) { _, _ in refreshMetrics() }
        .onChange(of: configuration.maxTokens) { _, _ in refreshMetrics() }
        .onChange(of: configuration.tokenizer) { _, _ in refreshMetrics() }
        .onDisappear { countingTask?.cancel() }
    }

    public func bold(_ isBold: Bool = true) -> Self {
        var copy = self
        copy.style.isBold = isBold
        return copy
    }

    public func editorFont(_ font: Font) -> Self {
        var copy = self
        copy.style.font = font
        return copy
    }

    public func textColor(_ color: Color) -> Self {
        var copy = self
        copy.style.textColor = color
        return copy
    }

    public func placeholder(_ text: String) -> Self {
        var copy = self
        copy.configuration.placeholder = text
        return copy
    }

    public func maxTokens(_ value: Int) -> Self {
        var copy = self
        copy.configuration.maxTokens = max(value, 1)
        return copy
    }

    public func tokenizer(_ tokenizer: AITokenizer) -> Self {
        var copy = self
        copy.configuration.tokenizer = tokenizer
        return copy
    }

    public func backgroundColor(_ color: Color, in cornerRadius: CGFloat = 14) -> Self {
        var copy = self
        copy.style.backgroundColor = color
        copy.style.cornerRadius = cornerRadius
        return copy
    }

    public func ringStyle(size: CGFloat = 34, lineWidth: CGFloat = 4) -> Self {
        var copy = self
        copy.style.ringSize = size
        copy.style.ringLineWidth = lineWidth
        return copy
    }

    public func ringColors(track: Color, progress: Color, overLimit: Color = .red) -> Self {
        var copy = self
        copy.style.ringTrackColor = track
        copy.style.ringProgressColor = progress
        copy.style.ringOverLimitColor = overLimit
        return copy
    }

    public func showTokenLabel(_ visible: Bool) -> Self {
        var copy = self
        copy.style.showTokenLabel = visible
        return copy
    }

    public func showsRemainingLabel(_ visible: Bool) -> Self {
        var copy = self
        copy.configuration.showsRemainingLabel = visible
        return copy
    }

    public func showsWordCountLabel(_ visible: Bool) -> Self {
        var copy = self
        copy.configuration.showsWordCountLabel = visible
        return copy
    }

    public func onMetricsChange(_ action: @escaping (TokenMetrics) -> Void) -> Self {
        var copy = self
        copy.onMetricsChange = action
        return copy
    }

    private var styleWithConfigurationValue: AITextEditorStyle {
        var updatedStyle = style
        updatedStyle.showTokenLabel = configuration.showsRemainingLabel && style.showTokenLabel
        return updatedStyle
    }

    private func refreshMetrics() {
        let textSnapshot = text
        let configurationSnapshot = configuration
        countingTask?.cancel()
        countingTask = Task(priority: .userInitiated) {
            let updatedMetrics = await TokenMetrics.calculate(
                text: textSnapshot,
                maxTokens: configurationSnapshot.maxTokens,
                tokenizer: configurationSnapshot.tokenizer
            )
            guard !Task.isCancelled else { return }
            metrics = updatedMetrics
            percentageRemaining = updatedMetrics.usage.percentageRemainingClamped
            onMetricsChange?(updatedMetrics)
        }
    }
}

#if DEBUG
@MainActor
private struct AITextEditorTypingPreview: View {
    @State private var text: String = ""
    @State private var percentageRemaining: Double = 1
    @State private var tokenCount: Int = 0
    @State private var wordCount: Int = 0
    private let previewTokenizer: AITokenizer = .openAIEncoding(.cl100kBase)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ProgressView(value: percentageRemaining)
                .tint(percentageRemaining > 0.15 ? .blue : .red)

            Text("Number of tokens: \(tokenCount)")
                .font(.footnote.monospacedDigit())
                .foregroundStyle(.secondary)

            Text("Number of words: \(wordCount)")
                .font(.footnote.monospacedDigit())
                .foregroundStyle(.secondary)

            AITextEditor($text, $percentageRemaining)
                .placeholder("Start typing...")
                .maxTokens(80)
                .tokenizer(previewTokenizer)
                .showsWordCountLabel(true)
                .backgroundColor(.blue.opacity(0.08), in: 14)
                .onMetricsChange { metrics in
                    tokenCount = metrics.tokenCount
                    wordCount = metrics.wordCount
                }
        }
        .padding()
        .frame(maxWidth: 520)
    }
}

#Preview("Typing Preview") {
    AITextEditorTypingPreview()
}
#endif
