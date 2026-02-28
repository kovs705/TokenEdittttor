//
//  AITokenTextViewStyle.swift
//  TokenEditttor
//
//  Created by Eugene Kovs on 26.02.2026.
//  https://github.com/kovs705
//

#if canImport(UIKit)
import UIKit

public struct AITokenTextViewStyle {
    public var font: UIFont
    public var isBold: Bool
    public var textColor: UIColor
    public var editorBackgroundColor: UIColor
    public var cornerRadius: CGFloat
    public var ringSize: CGFloat
    public var ringLineWidth: CGFloat
    public var ringTrackColor: UIColor
    public var ringProgressColor: UIColor
    public var ringOverLimitColor: UIColor
    public var showTokenLabel: Bool
    public var placeholderColor: UIColor

    public init(
        font: UIFont = .systemFont(ofSize: 17),
        isBold: Bool = false,
        textColor: UIColor = .label,
        editorBackgroundColor: UIColor = .secondarySystemBackground,
        cornerRadius: CGFloat = 14,
        ringSize: CGFloat = 34,
        ringLineWidth: CGFloat = 4,
        ringTrackColor: UIColor = .systemGray4,
        ringProgressColor: UIColor = .systemBlue,
        ringOverLimitColor: UIColor = .systemRed,
        showTokenLabel: Bool = true,
        placeholderColor: UIColor = .secondaryLabel
    ) {
        self.font = font
        self.isBold = isBold
        self.textColor = textColor
        self.editorBackgroundColor = editorBackgroundColor
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
#endif
