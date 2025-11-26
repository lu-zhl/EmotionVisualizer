import SwiftUI

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    let onStartOver: () -> Void

    var body: some View {
        ZStack {
            Color.white.opacity(0.9)
                .ignoresSafeArea()

            VStack(spacing: DMFSpacing.lg) {
                Spacer()

                // Error icon
                ZStack {
                    Circle()
                        .fill(Color.aliceBlue)
                        .frame(width: 100, height: 100)

                    Image(systemName: "cloud.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.skyBlueDisabled)
                        .overlay(
                            Image(systemName: "xmark")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.warningRed)
                                .offset(x: 15, y: -10)
                        )
                }
                .shadowSoft()

                // Error message
                Text(message)
                    .font(.dmfHeadline)
                    .foregroundColor(.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, DMFSpacing.xl)

                Text("Please try again.")
                    .font(.dmfBody)
                    .foregroundColor(.textSecondary)

                Spacer()

                // Action buttons
                VStack(spacing: DMFSpacing.md) {
                    // Retry button (primary)
                    Button(action: onRetry) {
                        Text("Try again")
                            .font(.dmfButtonLarge)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: DMFRadius.large)
                                    .fill(LinearGradient.buttonGradient)
                            )
                    }
                    .shadowSoft()

                    // Start over button (secondary)
                    Button(action: onStartOver) {
                        Text("Start over")
                            .font(.dmfButtonSmall)
                            .foregroundColor(.textSecondary)
                    }
                }
                .padding(.horizontal, DMFSpacing.lg)
                .padding(.bottom, DMFSpacing.xxl)
            }
        }
    }
}

#Preview {
    ErrorView(
        message: "Oops! We couldn't create your visualization.",
        onRetry: { print("Retry") },
        onStartOver: { print("Start over") }
    )
}
