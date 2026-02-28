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

    public init(
        _ text: Binding<String>,
        _ percentageRemaining: Binding<Double>,
        configuration: AIEditorConfiguration = .init()
    ) {
        self._text = text
        self._percentageRemaining = percentageRemaining
        self.configuration = configuration
        self.style = .init()
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
                Spacer()
                TokenRingView(
                    usage: TokenUsage(
                        used: configuration.tokenizer.count(in: text),
                        maxTokens: configuration.maxTokens
                    ),
                    style: styleWithConfigurationValue
                )
            }
        }
        .onAppear(perform: updatePercentageBinding)
        .onChange(of: text) { _, _ in updatePercentageBinding() }
        .onChange(of: configuration.maxTokens) { _, _ in updatePercentageBinding() }
        .onChange(of: configuration.tokenizer) { _, _ in updatePercentageBinding() }
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

    private var styleWithConfigurationValue: AITextEditorStyle {
        var updatedStyle = style
        updatedStyle.showTokenLabel = configuration.showsRemainingLabel && style.showTokenLabel
        return updatedStyle
    }

    private func updatePercentageBinding() {
        let usage = TokenUsage(
            used: configuration.tokenizer.count(in: text),
            maxTokens: configuration.maxTokens
        )
        percentageRemaining = usage.percentageRemainingClamped
    }
}
