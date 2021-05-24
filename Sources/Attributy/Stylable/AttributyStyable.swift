import SwiftUI

internal enum StyleModifier: Hashable {
    case font(UIFont)
    case foregroundColor(UIColor)
    case bold
    case italic
    case url((URL) -> Void)

    func hash(into hasher: inout Hasher) {
        switch self {
        case let .font(font):
            hasher.combine("font \(font)")

        case let .foregroundColor(color):
            hasher.combine("foregroundColor \(color)")

        case .bold:
            hasher.combine("bold")

        case .italic:
            hasher.combine("italic")

        case .url:
            hasher.combine("url")
        }
    }

    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

struct AttributyStyable {
    internal var modifiers: Set<StyleModifier> = []

    var attributes: [NSAttributedString.Key: Any] {
        var _attributes: [NSAttributedString.Key: Any] = [:]

        modifiers.forEach { modifier in
            switch modifier {
            case let .font(font):
                _attributes[.font] = font

            case let .foregroundColor(color):
                _attributes[.foregroundColor] = color

            case .bold:
                let font = (attributes[.font] as? UIFont) ?? .systemFont(ofSize: 14.0)
                _attributes[.font] = font.bold()

            case .italic:
                let font = (attributes[.font] as? UIFont) ?? .systemFont(ofSize: 14.0)
                _attributes[.font] = font.italic()

            case .url:
                return
            }
        }

        return _attributes
    }

    func font(_ font: UIFont) -> Self {
        var modifiers = self.modifiers
        modifiers.insert(.font(font))

        let stylable = Self(modifiers: modifiers)
        return stylable
    }

    func foregroundColor(_ color: UIColor) -> Self {
        var modifiers = self.modifiers
        modifiers.insert(.foregroundColor(color))

        let stylable = Self(modifiers: modifiers)
        return stylable
    }

    func bold() -> Self {
        var modifiers = self.modifiers
        modifiers.insert(.bold)

        let stylable = Self(modifiers: modifiers)
        return stylable
    }

    func italic() -> Self {
        var modifiers = self.modifiers
        modifiers.insert(.italic)

        let stylable = Self(modifiers: modifiers)
        return stylable
    }

    func url(_ callback: @escaping (URL) -> Void) -> Self {
        var modifiers = self.modifiers
        modifiers.insert(.url(callback))

        let stylable = Self(modifiers: modifiers)
        return stylable
    }
}

private extension UIFont {
    func withTraits(traits: UIFontDescriptor.SymbolicTraits) -> UIFont {
        let descriptor = fontDescriptor.withSymbolicTraits(traits)
        return UIFont(descriptor: descriptor!, size: 0)
    }

    func bold() -> UIFont {
        return withTraits(traits: .traitBold)
    }

    func italic() -> UIFont {
        return withTraits(traits: .traitItalic)
    }
}
