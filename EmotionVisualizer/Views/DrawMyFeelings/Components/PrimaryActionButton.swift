import SwiftUI

struct PrimaryActionButton: View {
    let title: String
    let isEnabled: Bool
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            if isEnabled {
                action()
            }
        }) {
            Text(title)
                .font(.dmfButtonLarge)
                .foregroundColor(isEnabled ? .white : .textPlaceholder)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    RoundedRectangle(cornerRadius: DMFRadius.large)
                        .fill(isEnabled ? AnyShapeStyle(LinearGradient.buttonGradient) : AnyShapeStyle(Color.skyBlueDisabled))
                )
                .scaleEffect(isPressed && isEnabled ? 0.97 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(!isEnabled)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if isEnabled {
                        withAnimation(.dmfQuick) { isPressed = true }
                    }
                }
                .onEnded { _ in
                    withAnimation(.dmfQuick) { isPressed = false }
                }
        )
        .shadow(
            color: isEnabled ? Color.black.opacity(0.08) : Color.clear,
            radius: 8,
            x: 0,
            y: 4
        )
        .animation(.dmfStandard, value: isEnabled)
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryActionButton(
            title: "Draw my feelings",
            isEnabled: true,
            action: { print("Tapped!") }
        )

        PrimaryActionButton(
            title: "Draw my feelings",
            isEnabled: false,
            action: { print("Tapped!") }
        )
    }
    .padding()
    .background(LinearGradient.screenBackground)
}
