import SwiftUI

struct GeneratingView: View {
    var message: String = "Creating your visualization"
    let onCancel: () -> Void

    @State private var cloudOffset: CGFloat = 0
    @State private var dotCount = 0

    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        ZStack {
            // Semi-transparent background
            Color.white.opacity(0.9)
                .ignoresSafeArea()

            VStack(spacing: DMFSpacing.xl) {
                Spacer()

                // Floating cloud icon
                Image(systemName: "cloud.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.skyBlue)
                    .offset(y: cloudOffset)
                    .onAppear {
                        withAnimation(
                            .easeInOut(duration: 2)
                            .repeatForever(autoreverses: true)
                        ) {
                            cloudOffset = -6
                        }
                    }
                    .shadowSoft()

                // Loading text with animated dots
                HStack(spacing: 0) {
                    Text(message)
                        .font(.dmfHeadline)
                        .foregroundColor(.textPrimary)

                    Text(String(repeating: ".", count: dotCount))
                        .font(.dmfHeadline)
                        .foregroundColor(.textPrimary)
                        .frame(width: 30, alignment: .leading)
                }
                .onReceive(timer) { _ in
                    dotCount = (dotCount + 1) % 4
                }

                Spacer()

                // Cancel button
                Button(action: onCancel) {
                    Text("Cancel")
                        .font(.dmfButtonSmall)
                        .foregroundColor(.textSecondary)
                        .padding(.horizontal, DMFSpacing.lg)
                        .padding(.vertical, DMFSpacing.sm)
                        .background(
                            RoundedRectangle(cornerRadius: DMFRadius.small)
                                .stroke(Color.skyBlueDisabled, lineWidth: 1)
                        )
                }
                .padding(.bottom, DMFSpacing.xxl)
            }
        }
    }
}

#Preview {
    GeneratingView(onCancel: { print("Cancelled") })
}
