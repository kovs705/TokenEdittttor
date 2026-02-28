//
//  AITokenTextView.swift
//  TokenEditttor
//
//  Created by Eugene Kovs on 26.02.2026.
//  https://github.com/kovs705
//

#if canImport(UIKit)
import UIKit

@MainActor
public final class AITokenTextView: UIView, UITextViewDelegate {
    public var onTextChange: ((String) -> Void)?
    public var onPercentageRemainingChange: ((Double) -> Void)?
    public var onTokenCountChange: ((Int) -> Void)?
    public var onWordCountChange: ((Int) -> Void)?
    public var onMetricsChange: ((TokenMetrics) -> Void)?

    public var text: String {
        get { textView.text ?? "" }
        set {
            textView.text = newValue
            textDidChange()
        }
    }

    public private(set) var configuration: AIEditorConfiguration
    public private(set) var style: AITokenTextViewStyle

    private let textView = UITextView()
    private let placeholderLabel = UILabel()
    private let ringContainer = UIView()
    private let ringTrackLayer = CAShapeLayer()
    private let ringProgressLayer = CAShapeLayer()
    private let remainingLabel = UILabel()
    private var ringWidthConstraint: NSLayoutConstraint?
    private var ringHeightConstraint: NSLayoutConstraint?
    private var metricsTask: Task<Void, Never>?

    public init(
        configuration: AIEditorConfiguration = .init(),
        style: AITokenTextViewStyle = .init()
    ) {
        self.configuration = configuration
        self.style = style
        super.init(frame: .zero)
        setupUI()
        applyStyle()
        updateUsageState()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        updateRingPath()
    }

    deinit {
        metricsTask?.cancel()
    }

    @discardableResult
    public func setMaximumTokens(_ value: Int) -> Self {
        configuration.maxTokens = max(value, 1)
        updateUsageState()
        return self
    }

    @discardableResult
    public func setTokenizer(_ tokenizer: AITokenizer) -> Self {
        configuration.tokenizer = tokenizer
        updateUsageState()
        return self
    }

    @discardableResult
    public func setPlaceholder(_ text: String) -> Self {
        configuration.placeholder = text
        placeholderLabel.text = text
        updatePlaceholderVisibility()
        return self
    }

    @discardableResult
    public func showsRemainingLabel(_ visible: Bool) -> Self {
        configuration.showsRemainingLabel = visible
        updateUsageState()
        return self
    }

    @discardableResult
    public func bold(_ isBold: Bool = true) -> Self {
        style.isBold = isBold
        applyStyle()
        return self
    }

    @discardableResult
    public func setFont(_ font: UIFont) -> Self {
        style.font = font
        applyStyle()
        return self
    }

    @discardableResult
    public func setTextColor(_ color: UIColor) -> Self {
        style.textColor = color
        applyStyle()
        return self
    }

    @discardableResult
    public func setEditorBackgroundColor(_ color: UIColor, cornerRadius: CGFloat? = nil) -> Self {
        style.editorBackgroundColor = color
        if let cornerRadius {
            style.cornerRadius = cornerRadius
        }
        applyStyle()
        return self
    }

    @discardableResult
    public func setRingStyle(size: CGFloat = 34, lineWidth: CGFloat = 4) -> Self {
        style.ringSize = size
        style.ringLineWidth = lineWidth
        ringWidthConstraint?.constant = size
        ringHeightConstraint?.constant = size
        setNeedsLayout()
        updateUsageState()
        return self
    }

    @discardableResult
    public func setRingColors(track: UIColor, progress: UIColor, overLimit: UIColor = .systemRed) -> Self {
        style.ringTrackColor = track
        style.ringProgressColor = progress
        style.ringOverLimitColor = overLimit
        updateUsageState()
        return self
    }

    public func textViewDidChange(_ textView: UITextView) {
        textDidChange()
    }

    private func setupUI() {
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear

        textView.delegate = self
        textView.isScrollEnabled = true
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 8, bottom: 12, right: 8)
        textView.translatesAutoresizingMaskIntoConstraints = false

        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        placeholderLabel.numberOfLines = 0
        placeholderLabel.isUserInteractionEnabled = false
        textView.addSubview(placeholderLabel)

        ringContainer.translatesAutoresizingMaskIntoConstraints = false
        ringContainer.layer.addSublayer(ringTrackLayer)
        ringContainer.layer.addSublayer(ringProgressLayer)
        ringContainer.addSubview(remainingLabel)

        remainingLabel.translatesAutoresizingMaskIntoConstraints = false
        remainingLabel.textAlignment = .center

        addSubview(textView)
        addSubview(ringContainer)

        ringWidthConstraint = ringContainer.widthAnchor.constraint(equalToConstant: style.ringSize)
        ringHeightConstraint = ringContainer.heightAnchor.constraint(equalToConstant: style.ringSize)

        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: topAnchor),
            textView.leadingAnchor.constraint(equalTo: leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: trailingAnchor),
            textView.heightAnchor.constraint(greaterThanOrEqualToConstant: 120),

            ringContainer.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 10),
            ringContainer.trailingAnchor.constraint(equalTo: trailingAnchor),
            ringContainer.bottomAnchor.constraint(equalTo: bottomAnchor),

            ringWidthConstraint!,
            ringHeightConstraint!,

            remainingLabel.centerXAnchor.constraint(equalTo: ringContainer.centerXAnchor),
            remainingLabel.centerYAnchor.constraint(equalTo: ringContainer.centerYAnchor),

            placeholderLabel.topAnchor.constraint(equalTo: textView.topAnchor, constant: 12),
            placeholderLabel.leadingAnchor.constraint(equalTo: textView.leadingAnchor, constant: 13),
            placeholderLabel.trailingAnchor.constraint(lessThanOrEqualTo: textView.trailingAnchor, constant: -12)
        ])
    }

    private func applyStyle() {
        textView.textColor = style.textColor
        textView.layer.cornerRadius = style.cornerRadius
        textView.backgroundColor = style.editorBackgroundColor

        if style.isBold {
            textView.font = .boldSystemFont(ofSize: style.font.pointSize)
        } else {
            textView.font = style.font
        }

        placeholderLabel.font = style.font
        placeholderLabel.textColor = style.placeholderColor
        placeholderLabel.text = configuration.placeholder

        remainingLabel.font = .monospacedDigitSystemFont(ofSize: 11, weight: .semibold)

        ringTrackLayer.fillColor = UIColor.clear.cgColor
        ringTrackLayer.strokeColor = style.ringTrackColor.cgColor
        ringTrackLayer.lineWidth = style.ringLineWidth

        ringProgressLayer.fillColor = UIColor.clear.cgColor
        ringProgressLayer.lineWidth = style.ringLineWidth
        ringProgressLayer.lineCap = .round

        updateRingPath()
        updateUsageState()
    }

    private func updateRingPath() {
        let inset = style.ringLineWidth / 2
        let rect = ringContainer.bounds.insetBy(dx: inset, dy: inset)
        let path = UIBezierPath(ovalIn: rect)
        ringTrackLayer.path = path.cgPath
        ringProgressLayer.path = path.cgPath
    }

    private func textDidChange() {
        updatePlaceholderVisibility()
        updateUsageState()
        onTextChange?(text)
    }

    private func updatePlaceholderVisibility() {
        placeholderLabel.isHidden = !text.isEmpty
    }

    private func updateUsageState() {
        let textSnapshot = text
        let configurationSnapshot = configuration
        metricsTask?.cancel()
        metricsTask = Task(priority: .userInitiated) { [weak self] in
            let metrics = await TokenMetrics.calculate(
                text: textSnapshot,
                maxTokens: configurationSnapshot.maxTokens,
                tokenizer: configurationSnapshot.tokenizer
            )
            guard !Task.isCancelled else { return }
            self?.apply(metrics: metrics)
        }
    }

    private func apply(metrics: TokenMetrics) {
        let usage = metrics.usage
        ringProgressLayer.strokeEnd = usage.percentageRemainingClamped
        ringProgressLayer.strokeColor = (usage.isOverLimit ? style.ringOverLimitColor : style.ringProgressColor).cgColor

        let shouldShowLabel = style.showTokenLabel && configuration.showsRemainingLabel
        remainingLabel.isHidden = !shouldShowLabel
        remainingLabel.text = shouldShowLabel ? "\(usage.remaining)" : nil
        remainingLabel.textColor = usage.isOverLimit ? style.ringOverLimitColor : .secondaryLabel

        onPercentageRemainingChange?(usage.percentageRemainingClamped)
        onTokenCountChange?(metrics.tokenCount)
        onWordCountChange?(metrics.wordCount)
        onMetricsChange?(metrics)
    }
}
#endif
