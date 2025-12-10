import SwiftUI

struct TextFieldGrayBackgroundColor: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(10)
            .background(
                Color(uiColor: .secondarySystemBackground)
            )
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

extension View {
    func textFieldGrayBackground() -> some View {
        self.modifier(TextFieldGrayBackgroundColor())
    }
}
