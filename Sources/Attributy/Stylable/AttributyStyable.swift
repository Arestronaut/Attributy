import SwiftUI

enum StyleModifier: Hashable {
    case font(UIFont)
    case foregroundColor(UIColor)
    case bold
    case italic
    case url((URL) -> Void)
    case underline(UIColor?)
    case strikethrough(UIColor?)
    case kerning(CGFloat)
    case backgroundColor(UIColor)

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

        case .underline:
            hasher.combine("underline")

        case .strikethrough:
            hasher.combine("strikethrough")

        case .kerning:
            hasher.combine("kerning")

        case .backgroundColor:
            hasher.combine("backgroundColor")
        }
    }

    static func ==(lhs: Self, rhs: Self) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

public struct AttributyStyable {
    var modifiers: Set<StyleModifier> = []

    var attributes: [NSAttributedString.Key: Any] {
        var _attributes: [NSAttributedString.Key: Any] = [:]

        modifiers.forEach { modifier in
            switch modifier {
            case let .font(font):
                _attributes[.font] = font

            case let .foregroundColor(color):
                _attributes[.foregroundColor] = color

            case .bold:
                let font = (_attributes[.font] as? UIFont) ?? .systemFont(ofSize: 14.0)
                _attributes[.font] = font.bold()

            case .italic:
                let font = (_attributes[.font] as? UIFont) ?? .systemFont(ofSize: 14.0)
                _attributes[.font] = font.italic()

            case .url:
                break

            case let .underline(color):
                _attributes[.underlineStyle] = NSUnderlineStyle.single.rawValue
                if let color = color {
                    _attributes[.underlineColor] = color
                }

            case let .strikethrough(color):
                _attributes[.strikethroughStyle] = NSUnderlineStyle.single.rawValue
                if let color = color {
                    _attributes[.strikethroughColor] = color
                }

            case let .kerning(kern):
                _attributes[.kern] = kern

            case let .backgroundColor(color):
                _attributes[.backgroundColor] = color
            }
        }

        return _attributes
    }

    private func apply(modifier: StyleModifier) -> Self {
        var modifiers = self.modifiers
        modifiers.insert(modifier)

        let stylable = Self(modifiers: modifiers)
        return stylable
    }

    public func font(_ font: UIFont) -> Self {
        apply(modifier: .font(font))
    }

    public func foregroundColor(_ color: UIColor) -> Self {
        apply(modifier: .foregroundColor(color))
    }

    public func bold() -> Self {
        apply(modifier: .bold)
    }

    public func italic() -> Self {
        apply(modifier: .italic)
    }

    public func url(_ callback: @escaping (URL) -> Void) -> Self {
        apply(modifier: .url(callback))
    }

    public func underline(_ color: UIColor?) -> Self {
        apply(modifier: .underline(color))
    }

    public func strikethrough(_ color: UIColor?) -> Self {
        apply(modifier: .strikethrough(color))
    }

    public func kerning(_ spacing: CGFloat) -> Self {
        apply(modifier: .kerning(spacing))
    }

    public func backgroundColor(_ color: UIColor) -> Self {
        apply(modifier: .backgroundColor(color))
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
