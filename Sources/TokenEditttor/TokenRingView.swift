//
//  TokenRingView.swift
//  TokenEditttor
//
//  Created by Eugene Kovs on 26.02.2026.
//  https://github.com/kovs705
//

import SwiftUI

@MainActor
struct TokenRingView: View {
    let usage: TokenUsage
    let style: AITextEditorStyle

    var body: some View {
        ZStack {
            Circle()
                .stroke(style.ringTrackColor, lineWidth: style.ringLineWidth)

            Circle()
                .trim(from: 0, to: usage.percentageRemainingClamped)
                .stroke(
                    usage.isOverLimit ? style.ringOverLimitColor : style.ringProgressColor,
                    style: StrokeStyle(lineWidth: style.ringLineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            if style.showTokenLabel {
                Text("\(usage.remaining)")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(usage.isOverLimit ? style.ringOverLimitColor : .secondary)
            }
        }
        .frame(width: style.ringSize, height: style.ringSize)
        .accessibilityLabel("Tokens remaining")
        .accessibilityValue("\(usage.remaining)")
    }
}
