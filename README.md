# Attributy

... is a framework that enables you to style marked-up text however you want. Sounds a bit vague? Here's an example using `HTML`:
Given the string: 
```html
I have <b>read</b> and hereby accept the <a href="http://link-to-data-privacy.com/">Privacy Policy</a>!
```

Attributy will automatically parse the string and apply provided style rules:

```swift
struct ContentView: View {
    let htmlString = "I have <b>read</b> and hereby accept the <a href=\"http://link-to-data-privacy.com/\">Privacy Policy</a>"

    var body: some View {
        AttributyText(htmlString, HTMLParser()) { element in
            switch element {
                case .bold: return { $0.font(.systemFont(ofSize: 18.0)).bold() }
                case .url: return { $0.foregroundColor(.blue).bold().underline(.black).url({ print($0.absoluteString) }) }
                default: return { $0.font(.systemFont(ofSize: 14.0)) }
            }
        }
    }
}
```

This will result in: 
![Preview](preview.png "Preview")

Clicking on the link will result in the execution of the provided callback.

## General Information
This framework was initially done in less than a day therefore there will be a lot of undiscovered bugs and huge room for potential improvements and extensions. If you are in any case interested in contributing to the codebase, feel free to open up new issues or create pull requests. 
## Installation
Attributy is available only through SPM.

## Custom Parser
Attributy heavily relies on Parsers. The used `HTMLParser` is already predefined and will be extended in upcoming versions. 
Custom parsers can be done by adapting the `AttributyParser` protocol.

## Style Attributes
Most of the common text styling attributes are available (.e.g. font, foregroundColor, backgroundColor, bold, italic, etc.) and can be applied in a similar fashion as known from SwiftUI.