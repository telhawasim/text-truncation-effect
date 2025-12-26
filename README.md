# text-truncation-effect

A SwiftUI truncation + expand effect for `Text`:
- Truncates to a fixed number of lines
- Draws a trailing “...More” hint on the last visible line
- Animates expansion by progressively revealing remaining lines with a blur/fade

## Requirements

- iOS 26.0+ (uses SwiftUI `onGeometryChange`)
- Swift 6.0+
- Xcode 16+ recommended

> Note: This implementation currently uses `UIFont`, so it’s iOS-focused.

## Installation

### Xcode (Swift Package Manager)

1. **File → Add Package Dependencies…**
2. Paste:
   `https://github.com/telhawasim/TextTruncationEffect.git`
3. Select a version (example: `main` from `1.0.0`)
4. Add the package to your app target.

### Package.swift

```swift
dependencies: [
  .package(url: "https://github.com/telhawasim/TextTruncationEffect.git", from: "1.0.0")
]
```

### How to use

```swift
import SwiftUI
import TextTruncationEffect

struct DemoView: View {
    @State private var isTruncated: Bool = true

    let text = "Lorem Ipsum is simply dummy text of the printing and typesetting industry..."

    var body: some View {
        Text(text)
            .font(.caption)
            .truncationEffect(length: 2, isEnabled: isTruncated, animation: .smooth(duration: 0.5))
            .onTapGesture { isTruncated.toggle() }
            .padding(16)
    }
}
```

### API

```swift
Text.truncationEffect(length: Int, isEnabled: Bool, animation: Animation) -> some View
```
- `length`: number of lines shown when truncation is enabled
- `isEnabled`: `true` = truncated, `false` = expanded
- `animation`: animation used when toggling

## Attribution / Credit

This package is based on the original work/concept demonstrated by Kavsoft:

[Kavsoft Youtube Channel](https://www.youtube.com/@Kavsoft)

> Note: This project is not affiliated with or endorsed by Kavsoft.

## Contribution

Thanks for your interest in contributing!

## Contribution policy (PRs only)

- Please **do not push directly to `main`**.
- All changes must be submitted via a **Pull Request (PR)**.
- Maintainers will review and approve PRs before merging.

GitHub branch protection is enabled on `main`, so direct pushes are blocked.

## How to contribute

1. **Fork** the repository
2. Create a new branch from `main`:

   ```bash
   git checkout -b feature/your-change
