import SwiftUI

struct InitialCloudView: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: {
            onTap()
        }) {
            ZStack {
                // Cloud background
                RoundedRectangle(cornerRadius: 40)
                    .fill(LinearGradient.cloudGradient)
                    .frame(width: 280, height: 140)
                    .shadowMedium()

                Text("How are you feeling?")
                    .font(.dmfHeadline)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
            }
        }
        .buttonStyle(ScaleButtonStyle())
        .accessibilityLabel("How are you feeling? Tap to express your emotions")
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

#Preview {
    ZStack {
        LinearGradient.screenBackground
            .ignoresSafeArea()

        InitialCloudView {
            print("Cloud tapped!")
        }
    }
}
