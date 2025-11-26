import SwiftUI

struct VisualizationResultView: View {
    let visualization: GeneratedVisualization?
    let onStartOver: () -> Void

    @State private var isImageVisible = false

    var body: some View {
        VStack(spacing: DMFSpacing.xl) {
            Spacer()

            // Generated visualization placeholder
            ZStack {
                RoundedRectangle(cornerRadius: DMFRadius.xlarge)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "E8F4FC"),
                                Color(hex: "D4E8F2"),
                                Color(hex: "F0F8FF")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 300, height: 300)

                // Placeholder content - in future this will show actual generated image
                VStack(spacing: DMFSpacing.md) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 60))
                        .foregroundColor(.skyBlue)

                    Text("Your visualization")
                        .font(.dmfHeadline)
                        .foregroundColor(.textPrimary)

                    if let prompt = visualization?.prompt {
                        Text(prompt)
                            .font(.dmfCaption)
                            .foregroundColor(.textSecondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(3)
                            .padding(.horizontal, DMFSpacing.md)
                    }
                }
            }
            .shadowMedium()
            .scaleEffect(isImageVisible ? 1.0 : 0.95)
            .opacity(isImageVisible ? 1 : 0)
            .onAppear {
                withAnimation(.dmfGentle.delay(0.1)) {
                    isImageVisible = true
                }
            }

            Spacer()

            // Start over button
            Button(action: onStartOver) {
                Text("Start over")
                    .font(.dmfButtonSmall)
                    .foregroundColor(.textPrimary)
                    .frame(width: 140, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: DMFRadius.medium)
                            .fill(Color.aliceBlue)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: DMFRadius.medium)
                            .stroke(Color.lightBlue, lineWidth: 1)
                    )
            }
            .shadowSoft()
            .opacity(isImageVisible ? 1 : 0)
            .animation(.dmfStandard.delay(0.5), value: isImageVisible)
            .padding(.bottom, DMFSpacing.xxl)
        }
    }
}

#Preview {
    ZStack {
        LinearGradient.screenBackground
            .ignoresSafeArea()

        VisualizationResultView(
            visualization: GeneratedVisualization(
                imageURL: "test",
                prompt: "User feels super happy and chill"
            ),
            onStartOver: { print("Start over") }
        )
    }
}
