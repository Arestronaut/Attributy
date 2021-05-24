import SwiftUI
import UIKit

final class AttributyTextView: UIViewRepresentable {
    @Binding private var size: CGSize

    private let tokenizedContent: [ParserToken]
    private let ruleMap: [ParsableElement: AttributyStyable]

    private var attributedString: NSAttributedString?
    private var linkAttributes: [NSAttributedString.Key: Any]?

    init(tokenizedContent: [ParserToken], ruleMap: [ParsableElement: AttributyStyable], size: Binding<CGSize>) {
        self.tokenizedContent = tokenizedContent
        self.ruleMap = ruleMap
        self._size = size

        makeAttributedString()
    }

    private func makeAttributedString() {
        let mutableAttributedString = NSMutableAttributedString(string: "")

        var linkAttributes: [NSAttributedString.Key: Any]?

        for token in tokenizedContent {
            let styableContent = token.parsedElement.content
            let rule = ruleMap[token.parsedElement.parsableElement]

            var attributes = rule?.attributes

            if case let .url(_, url) = token.parsedElement {
                attributes?[.link] = url.absoluteString

                linkAttributes = attributes
            }

            let attributedString = NSMutableAttributedString(
                string: styableContent,
                attributes: attributes
            )

            mutableAttributedString.append(attributedString)
        }

        self.attributedString = mutableAttributedString
        self.linkAttributes = linkAttributes
    }

    func makeCoordinator() -> Coordinator {
        .init(ruleMap: ruleMap)
    }

    func makeUIView(context: Context) -> UITextView {
        let textField: UITextView = .init()
        textField.delegate = context.coordinator
        textField.isEditable = false
        textField.isSelectable = true

        return textField
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if let attributedString = attributedString {
            uiView.attributedText = attributedString
        }

        if let linkAttributes = linkAttributes {
            uiView.linkTextAttributes = linkAttributes
        }

        DispatchQueue.main.async {
            self.size = uiView.sizeThatFits(uiView.superview?.bounds.size ?? .zero)
        }
    }
}

extension AttributyTextView {
    class Coordinator: NSObject, UITextViewDelegate {
        let ruleMap: [ParsableElement: AttributyStyable]

        init(ruleMap: [ParsableElement: AttributyStyable]) {
            self.ruleMap = ruleMap
        }

        func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
            guard
                let urlRule = ruleMap[.url],
                let urlModifier = urlRule.modifiers.first(where: { modifier in
                    guard case .url(_) = modifier else { return false }
                    return true
                })
            else { return false }

            if case let .url(callback) = urlModifier {
                callback(URL)
            }

            return false
        }

        func textViewDidChange(_ textView: UITextView) {
            let fixedWidth = textView.frame.width
            let newSize = textView.sizeThatFits(.init(width: fixedWidth, height: .greatestFiniteMagnitude))

            textView.frame.size = .init(width: max(newSize.width, fixedWidth), height: newSize.height)
        }
    }
}
