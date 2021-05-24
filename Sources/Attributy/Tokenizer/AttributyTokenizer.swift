import Foundation

enum AttributyTokenizer {
    static func tokenize(content: String, tokens: [ParserToken]) -> [ParserToken] {
        let nsContent = content as NSString
        let indicies = Set<Int>(0 ..< content.count)

        var rangeIndices = Set<Int>()
        var completeTokens: [ParserToken] = tokens

        tokens.forEach {
            ($0.range.lowerBound ..< $0.range.upperBound).forEach { index in rangeIndices.insert(index)}
        }

        let missingIndicies = indicies.subtracting(rangeIndices).sorted()

        var location = missingIndicies.first ?? 0
        var length = 0

        missingIndicies.enumerated().forEach { enumerator in
            let (index, number) = enumerator

            length += 1

            guard index < missingIndicies.count - 1 else {
                let range = NSRange(location: location, length: length)
                return completeTokens.append(.init(parsedElement: .text(nsContent.substring(with: range)), range: range))
            }

            let nextNumber = missingIndicies[index + 1]

            if number + 1 < nextNumber {
                let range = NSRange(location: location, length: length)

                completeTokens.append(.init(parsedElement: .text(nsContent.substring(with: range)), range: range))

                location = nextNumber
                length = 0
            }
        }

        let correctedTokens: [ParserToken] = completeTokens.map { token in
            guard case .text = token.parsedElement, token.range.location > 0 else { return token }
            return .init(
                parsedElement: token.parsedElement,
                range: .init(location: token.range.location - 1, length: token.range.length + 1)
            )
        }

        return completeTokens
    }
}
