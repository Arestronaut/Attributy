import SwiftUI

struct AttributyText: View {
    typealias RuleModifierCallback = (ParsableElement) -> ((AttributyStyable) -> AttributyStyable)

    private let content: String
    private let parser: AttributyParser
    private let callback: RuleModifierCallback
    private var ruleMap: [ParsableElement: AttributyStyable] = [:]
    private let tokenizedContent: [ParserToken]

    init<Parser: AttributyParser>(_ content: String, _ parser: Parser, _ callback: @escaping RuleModifierCallback) {
        self.content = content
        self.parser = parser
        self.callback = callback

        let parsedTokens = parser.parse(content)
        tokenizedContent = AttributyTokenizer
            .tokenize(content: content, tokens: parsedTokens)
            .sorted { first, second -> Bool in
                return first.range.lowerBound < second.range.lowerBound
            }

        parser.parsableElements.forEach { parsableElement in
            let stylable = AttributyStyable()
            let rules = callback(parsableElement)(stylable)

            ruleMap[parsableElement] = rules
        }
    }

    var body: some View {
        AttributyTextView(tokenizedContent: tokenizedContent, ruleMap: ruleMap)
    }
}
