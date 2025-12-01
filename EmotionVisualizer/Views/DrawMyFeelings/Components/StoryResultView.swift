import SwiftUI

struct StoryResultView: View {
    let visualization: GeneratedVisualization?
    let onCelebrate: () -> Void
    let onStartOver: () -> Void

    @State private var isImageVisible = false

    var body: some View {
        VStack(spacing: DMFSpacing.xl) {
            Spacer()

            // Generated story visualization image
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

                if let imageData = visualization?.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 300, height: 300)
                        .clipShape(RoundedRectangle(cornerRadius: DMFRadius.xlarge))
                } else {
                    VStack(spacing: DMFSpacing.md) {
                        Image(systemName: "book.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.skyBlue)

                        Text("Your story")
                            .font(.dmfHeadline)
                            .foregroundColor(.textPrimary)
                    }
                }
            }
            .shadowMedium()
            .scaleEffect(isImageVisible ? 1.0 : 0.95)
            .opacity(isImageVisible ? 1 : 0)

            Spacer()

            // Celebrate button (centered)
            Button(action: onCelebrate) {
                HStack(spacing: DMFSpacing.xs) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 16))
                    Text("Let it out!")
                        .font(.dmfButton)
                }
                .foregroundColor(.white)
                .frame(height: 48)
                .padding(.horizontal, DMFSpacing.xl)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "FFD700"), Color(hex: "FFA500")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(Capsule())
            }
            .shadowSoft()
            .opacity(isImageVisible ? 1 : 0)
            .animation(.dmfStandard.delay(0.3), value: isImageVisible)

            // Start over button
            Button(action: onStartOver) {
                HStack(spacing: DMFSpacing.xxs) {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.system(size: 16))
                    Text("Start over")
                        .font(.dmfButtonSmall)
                }
                .foregroundColor(.textSecondary)
            }
            .opacity(isImageVisible ? 1 : 0)
            .animation(.dmfStandard.delay(0.4), value: isImageVisible)
            .padding(.bottom, DMFSpacing.xxl)
        }
        .onAppear {
            withAnimation(.dmfGentle.delay(0.1)) {
                isImageVisible = true
            }
        }
    }
}
