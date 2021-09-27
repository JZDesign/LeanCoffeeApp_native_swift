import SwiftUI

struct BoldButton: View {
    let action: () -> ()
    let title: String
    let backgroundColor: Color
    let foregroundColor: Color
    
    init(
        _ title: String,
        backgroundColor: Color = .red,
        foregroundColor: Color = .white,
        action: @escaping () -> ()
    ) {
        self.title = title
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.action = action
    }

    var body: some View {
        Button(action: action) {
            // iOS' default button is only clickable on the text.
            // This makes the clickable area on the button much bigger.
            Text(title)
                .frame(maxWidth: .infinity, minHeight: 48)
        }
            .font(.body.bold())
            .frame(maxWidth: 400) // Fill an iPhone but not an iPad
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(backgroundColor)
                    .shadow(color: .black.opacity(0.5), radius: 20, x: 4, y: 5)
                
            )
            .foregroundColor(foregroundColor)
    }
}
