import Foundation

enum ParsableElement: CaseIterable {
    case bold
    case italic
    case url
    case text
}

enum ParsedElement: Hashable {
    case bold(String)
    case italic(String)
    case url(String, URL)
    case text(String)

    func hash(into hasher: inout Hasher) {
        switch self {
        case let .bold(text):
            hasher.combine("bold \(text)")

        case let .italic(text):
            hasher.combine("italic \(text)")

        case let .url(text, url):
            hasher.combine("url \(text) \(url.absoluteString)")

        case let .text(text):
            hasher.combine("text \(text)")
        }
    }

    var content: String {
        switch self {
        case let .bold(text): return text
        case let .italic(text): return text
        case let .url(text, _): return text
        case let .text(text): return text
        }
    }

    var parsableElement: ParsableElement {
        switch self {
        case .bold: return .bold
        case .italic: return .italic
        case .url: return .url
        case .text: return .text
        }
    }
}

struct ParserToken {
    let parsedElement: ParsedElement
    let range: NSRange
}

protocol AttributyParser: AnyObject {
    var parsableElements: Set<ParsableElement> { get }

    func pattern(for parsableElement: ParsableElement) -> String?
    func parse(_ parsableString: String) -> [ParserToken]
}
