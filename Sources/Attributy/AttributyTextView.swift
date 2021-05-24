import SwiftUI
import UIKit

final class AttributyTextView: UIViewRepresentable {
    private let tokenizedContent: [ParserToken]
    private let ruleMap: [ParsableElement: AttributyStyable]

    init(tokenizedContent: [ParserToken], ruleMap: [ParsableElement: AttributyStyable]) {
        self.tokenizedContent = tokenizedContent
        self.ruleMap = ruleMap
    }

    func makeCoordinator() -> Coordinator {
        .init(ruleMap: ruleMap)
    }

    func makeUIView(context: Context) -> some UIView {
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


        let textField: UITextView = .init()
        textField.delegate = context.coordinator
        textField.attributedText = mutableAttributedString

        if let _linkAttributes = linkAttributes {
            textField.linkTextAttributes = _linkAttributes
        }

        return textField
    }

    func updateUIView(_ uiView: UIViewType, context: Context) { }
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
    }
}
