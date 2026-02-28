# TokenEditttor

`TokenEditttor` is a Swift package for token-aware text input.
It gives you a text editor with a circular remaining-tokens indicator (similar to social post limit indicators), available in both SwiftUI and UIKit.

## Features

- SwiftUI component: `AITextEditor`
- UIKit component: `AITokenTextView`
- Token counting strategies: `.words`, `.characters`, `.approximateCharactersPerToken(Double)`
- Remaining-token ring with over-limit state
- Chainable configuration APIs for styling and behavior

## Requirements

- Swift 6.2+
- iOS 17+
- macCatalyst 17+
- macOS 14+

## Installation (Swift Package Manager)

Add this package to your `Package.swift` dependencies:

```swift
.package(url: "https://github.com/kovs705/TokenEditttor.git", branch: "main")
```

Then add the product to your target:

```swift
.product(name: "TokenEditttor", package: "TokenEditttor")
```

For local development:

```swift
.package(path: "../TokenEditttor")
```

## SwiftUI

### Quick Start

```swift
import SwiftUI
import TokenEditttor

struct ComposeView: View {
    @State private var text = ""
    @State private var remainingRatio: Double = 1

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            AITextEditor($text, $remainingRatio)
                .placeholder("Write your message...")
                .maxTokens(280)
                .tokenizer(.words)
                .bold()
                .backgroundColor(.blue.opacity(0.08), in: 16)
                .ringColors(track: .gray.opacity(0.2), progress: .blue, overLimit: .red)

            Text("Remaining: \(Int(remainingRatio * 100))%")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding()
    }
}
```

### SwiftUI Modifier API

`AITextEditor` supports chainable modifiers:

- `.bold(_ isBold: Bool = true)`
- `.editorFont(_ font: Font)`
- `.textColor(_ color: Color)`
- `.placeholder(_ text: String)`
- `.maxTokens(_ value: Int)`
- `.tokenizer(_ tokenizer: AITokenizer)`
- `.backgroundColor(_ color: Color, in cornerRadius: CGFloat = 14)`
- `.ringStyle(size: CGFloat = 34, lineWidth: CGFloat = 4)`
- `.ringColors(track: Color, progress: Color, overLimit: Color = .red)`
- `.showTokenLabel(_ visible: Bool)`
- `.showsRemainingLabel(_ visible: Bool)`

## UIKit

### Quick Start

```swift
import UIKit
import TokenEditttor

final class ComposeViewController: UIViewController {
    private let editor = AITokenTextView()
    private let statusLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        statusLabel.font = .preferredFont(forTextStyle: .footnote)
        statusLabel.textColor = .secondaryLabel

        editor
            .setPlaceholder("Write your message...")
            .setMaximumTokens(280)
            .setTokenizer(.words)
            .bold()
            .setEditorBackgroundColor(.secondarySystemBackground, cornerRadius: 16)
            .setRingColors(track: .systemGray4, progress: .systemBlue, overLimit: .systemRed)

        editor.onTextChange = { text in
            print("Current text length: \(text.count)")
        }

        editor.onPercentageRemainingChange = { [weak self] ratio in
            self?.statusLabel.text = "Remaining: \(Int(ratio * 100))%"
        }

        editor.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(editor)
        view.addSubview(statusLabel)

        NSLayoutConstraint.activate([
            editor.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            editor.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            editor.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),

            statusLabel.topAnchor.constraint(equalTo: editor.bottomAnchor, constant: 8),
            statusLabel.leadingAnchor.constraint(equalTo: editor.leadingAnchor),
            statusLabel.trailingAnchor.constraint(equalTo: editor.trailingAnchor)
        ])
    }
}
```

### UIKit Chainable API

`AITokenTextView` supports chainable methods:

- `.setMaximumTokens(_ value: Int)`
- `.setTokenizer(_ tokenizer: AITokenizer)`
- `.setPlaceholder(_ text: String)`
- `.showsRemainingLabel(_ visible: Bool)`
- `.bold(_ isBold: Bool = true)`
- `.setFont(_ font: UIFont)`
- `.setTextColor(_ color: UIColor)`
- `.setEditorBackgroundColor(_ color: UIColor, cornerRadius: CGFloat? = nil)`
- `.setRingStyle(size: CGFloat = 34, lineWidth: CGFloat = 4)`
- `.setRingColors(track: UIColor, progress: UIColor, overLimit: UIColor = .systemRed)`

Callbacks:

- `onTextChange: ((String) -> Void)?`
- `onPercentageRemainingChange: ((Double) -> Void)?`

## Tokenization

`AITokenizer` options:

- `.words`: Uses `NaturalLanguage.NLTokenizer(unit: .word)`. Best default for natural language input.
- `.characters`: Counts grapheme clusters (`String.count`).
- `.approximateCharactersPerToken(Double)`: Useful when approximating model token usage by average chars/token.

Example:

```swift
let tokenizer: AITokenizer = .approximateCharactersPerToken(4.0)
let used = tokenizer.count(in: "Hello world")
```

## Shared Configuration Model

You can initialize with `AIEditorConfiguration`:

```swift
let config = AIEditorConfiguration(
    maxTokens: 1000,
    tokenizer: .words,
    placeholder: "Start typing",
    showsRemainingLabel: true
)
```

Both UI layers support this configuration in their initializers.

SwiftUI initializer:

```swift
AITextEditor($text, $remainingRatio, configuration: config)
```

UIKit initializer:

```swift
let editor = AITokenTextView(configuration: config)
```

## Behavior Notes

- Minimum token limit is clamped to `1`.
- `percentageRemaining` is clamped to `0...1`.
- If text goes over limit, the remaining count becomes negative and the ring switches to over-limit color.

## Running Tests

```bash
swift test
```
