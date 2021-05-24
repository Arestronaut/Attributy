import Foundation

public final class HTMLParser: AttributyParser {
    public var parsableElements: Set<ParsableElement> = .init(ParsableElement.allCases)

    public init() { }

    public func pattern(for parsableElement: ParsableElement) -> String? {
        switch parsableElement {
        case .bold: return "<b>(.|\n)*?<\\/b>"
        case .italic: return "<i>(.|\n)*?<\\/i>"
        case .url: return "<a\\b[^>]*\\bhref\\s*=\\s*(\"[^\"]*\"|'[^']*')[^>]*>((?:(?!</a).)*)</a\\s*>"
        case .text: return nil
        }
    }

    public func parse(_ parsableString: String) -> [ParserToken] {
        var tokens: [ParserToken] = []

        for parsableElement in parsableElements {
            guard let pattern  = pattern(for: parsableElement) else { continue }

            do {
                let regex = try NSRegularExpression(pattern: pattern, options: .caseInsensitive)
                let matches = regex.matches(in: parsableString, options: [], range: .init(location: 0, length: parsableString.count))
                let parsableString = parsableString as NSString

                switch parsableElement {
                case .bold:
                    tokens.append(contentsOf: parseBold(matches, in: parsableString))

                case .italic:
                    tokens.append(contentsOf: parseItalic(matches, in: parsableString))

                case .url:
                    tokens.append(contentsOf: parseURL(matches, in: parsableString))

                case .text:
                    continue
                }

            } catch {
                print(error.localizedDescription)
                continue
            }
        }

        return tokens
    }

    private func parseBold(_ matches: [NSTextCheckingResult], in parsableString: NSString) -> [ParserToken] {
        matches.map { match in
            let innerTextRange = NSRange(location: match.range.location + 3, length: match.range.length - 7)
            let innerText = parsableString.substring(with: innerTextRange)

            return ParserToken(parsedElement: .bold(innerText), range: match.range)
        }
    }

    private func parseItalic(_ matches: [NSTextCheckingResult], in parsableString: NSString) -> [ParserToken] {
        matches.map { match in
            let innerTextRange = NSRange(location: match.range.location + 3, length: match.range.length - 7)
            let innerText = parsableString.substring(with: innerTextRange)

            return ParserToken(parsedElement: .italic(innerText), range: match.range)
        }
    }

    private func parseURL(_ matches: [NSTextCheckingResult], in parsableString: NSString) -> [ParserToken] {
        matches.map { match in
            let hrefRange = NSRange(location: match.range(at: 1).location + 1, length: match.range(at: 1).length - 2)
            let innerTextRange = match.range(at: 2)

            let href = parsableString.substring(with: hrefRange)
            let text = parsableString.substring(with: innerTextRange)

            return ParserToken(parsedElement: .url(text, URL(string: href)!), range: match.range)
        }
    }
}
