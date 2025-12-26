// The Swift Programming Language
// https://docs.swift.org/swift-book

import SwiftUI
import UIKit

public extension Text {
    
    /// In order to add a modifier against the text
    /// - Parameters:
    ///   - length: `Int` number of lines text will be displayed before expanding
    ///   - isEnabled: `Bool` will detemine whether to expand the text or not
    ///   - animation: `Animation` will expand with animation for smooth transition
    /// - Returns: `some View` will return us the text view
    @ViewBuilder
    func truncationEffect(length: Int, isEnabled: Bool, animation: Animation) -> some View {
        self
            .modifier(
                TruncationEffectViewModifier(
                    length: length,
                    isEnabled: isEnabled,
                    animation: animation
                )
            )
    }
}

fileprivate struct TruncationEffectViewModifier: ViewModifier {

    // MARK: - PROPERTIES -
    
    //Normal
    var length: Int
    var isEnabled: Bool
    var animation: Animation
    //State
    @State private var limitedSize: CGSize = .zero
    @State private var fullSize: CGSize = .zero
    @State private var animatedProgress: CGFloat = 0
    //Computed
    var isExpanded: Bool { animatedProgress == 1 }

    // MARK: - BODY -
    func body(content: Content) -> some View {
        content
            .lineLimit(length)
            .opacity(0)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .onGeometryChange(for: CGSize.self) { $0.size } action: { newValue in
                limitedSize = newValue
            }
            .frame(height: isExpanded ? fullSize.height : nil)
            .overlay {
                GeometryReader { proxy in
                    let contentSize = proxy.size

                    content
                        .textRenderer(
                            TruncationTextRenderer(length: length, progress: animatedProgress)
                        )
                        .fixedSize(horizontal: false, vertical: true)
                        .onGeometryChange(for: CGSize.self) { $0.size } action: { newValue in
                            fullSize = newValue
                        }
                        .frame(
                            width: contentSize.width,
                            height: contentSize.height,
                            alignment: isExpanded ? .leading : .topLeading
                        )
                }
            }
            .onChange(of: isEnabled) { _, newValue in
                withAnimation(animation) {
                    animatedProgress = (!newValue ? 1 : 0)
                }
            }
            .onAppear {
                animatedProgress = (!isEnabled ? 1 : 0)
            }
    }
}

@Animatable
fileprivate struct TruncationTextRenderer: TextRenderer {

    // MARK: - PROPERTIES -
    
    //AnimatableIgnored
    @AnimatableIgnored var length: Int
    //Normal
    var progress: CGFloat

    // MARK: - DRAW -
    func draw(layout: Text.Layout, in ctx: inout GraphicsContext) {
        for (index, line) in layout.enumerated() {
            var copy = ctx
            if index == length - 1 {
                drawMoreTextAtEnd(line: line, context: &copy)
            } else {
                if index < length {
                    copy.draw(line)
                } else {
                    drawLinesWithBlurEffect(index: index, layout: layout, in: &copy)
                }
            }
        }
    }

    func drawLinesWithBlurEffect(index: Int, layout: Text.Layout, in ctx: inout GraphicsContext) {
        let line = layout[index]

        let lineIndex = Double(index - length)
        let totalExtraLines = Double(layout.count - length)

        let lineStartProgress = lineIndex / max(1, totalExtraLines)
        let lineEndProgress = (lineIndex + 1) / max(1, totalExtraLines)

        let lineProgress = max(0, min(1, (progress - lineStartProgress) / (lineEndProgress - lineStartProgress)))

        ctx.opacity = lineProgress
        ctx.addFilter(.blur(radius: 6 - (6 * lineProgress)))
        ctx.draw(line)
    }

    func drawMoreTextAtEnd(line: Text.Layout.Element, context: inout GraphicsContext) {
        let runs = line.flatMap { $0 }
        let runsCount = runs.count

        let moreText = "...More"
        let moreCount = moreText.count

        for idx in 0..<max(runsCount - moreCount, 0) {
            context.draw(runs[idx])
        }

        for idx in max(runsCount - moreCount, 0)..<runsCount {
            context.opacity = progress
            context.draw(runs[idx])
        }

        let textRunIndex = max(runsCount - moreCount, 0)
        guard !runs.isEmpty, textRunIndex < runs.count else { return }

        let run = runs[textRunIndex]
        let typography = run.typographicBounds
        let fontSize: CGFloat = typography.ascent
        let font = UIFont.systemFont(ofSize: fontSize)

        let spacing: CGFloat = NSString(string: moreText)
            .size(withAttributes: [.font: font]).width / 2

        let swiftUIText = Text(moreText)
            .font(Font(font))
            .foregroundStyle(.gray)

        let origin = CGPoint(
            x: typography.rect.minX + spacing,
            y: typography.rect.midY
        )

        context.opacity = 1 - progress
        context.draw(swiftUIText, at: origin)
    }
}
