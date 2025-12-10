import SwiftUI

// A reusable gray rounded background style for TextFields (and any View).
struct TextFieldGrayBackgroundColor: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(10)
            .background(
                // Uses system-provided adaptive color that looks good in Light/Dark Mode
                Color(uiColor: .secondarySystemBackground)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// Optional convenience to use as `.textFieldGrayBackground()`
extension View {
    func textFieldGrayBackground() -> some View {
        self.modifier(TextFieldGrayBackgroundColor())
    }
}
