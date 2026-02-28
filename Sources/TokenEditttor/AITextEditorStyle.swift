//
//  AITextEditorStyle.swift
//  TokenEditttor
//
//  Created by Eugene Kovs on 26.02.2026.
//  https://github.com/kovs705
//

import SwiftUI

public struct AITextEditorStyle {
    public var font: Font
    public var isBold: Bool
    public var textColor: Color
    public var backgroundColor: Color
    public var cornerRadius: CGFloat
    public var ringSize: CGFloat
    public var ringLineWidth: CGFloat
    public var ringTrackColor: Color
    public var ringProgressColor: Color
    public var ringOverLimitColor: Color
    public var showTokenLabel: Bool
    public var placeholderColor: Color

    public init(
        font: Font = .body,
        isBold: Bool = false,
        textColor: Color = .primary,
        backgroundColor: Color = .secondary.opacity(0.12),
        cornerRadius: CGFloat = 14,
        ringSize: CGFloat = 34,
        ringLineWidth: CGFloat = 4,
        ringTrackColor: Color = .secondary.opacity(0.2),
        ringProgressColor: Color = .blue,
        ringOverLimitColor: Color = .red,
        showTokenLabel: Bool = true,
        placeholderColor: Color = .secondary
    ) {
        self.font = font
        self.isBold = isBold
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.ringSize = ringSize
        self.ringLineWidth = ringLineWidth
        self.ringTrackColor = ringTrackColor
        self.ringProgressColor = ringProgressColor
        self.ringOverLimitColor = ringOverLimitColor
        self.showTokenLabel = showTokenLabel
        self.placeholderColor = placeholderColor
    }
}
