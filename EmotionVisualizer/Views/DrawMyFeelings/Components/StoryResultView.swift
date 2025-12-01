import SwiftUI

struct StoryResultView: View {
    let visualization: GeneratedVisualization?
    let onCelebrate: () -> Void
    let onStartOver: () -> Void

    @State private var isImageVisible = false

    var body: some View {
        ScrollView {
            VStack(spacing: DMFSpacing.lg) {
                Spacer(minLength: DMFSpacing.lg)

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
                        .frame(width: 280, height: 280)

                    if let imageData = visualization?.imageData,
                       let uiImage = UIImage(data: imageData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 280, height: 280)
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

                // Story Analysis Display
                if let analysis = visualization?.storyAnalysis {
                    VStack(alignment: .leading, spacing: DMFSpacing.sm) {
                        // Central Stressor Header
                        Text(analysis.centralStressor)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.textPrimary)
                            .multilineTextAlignment(.leading)

                        // Factors List
                        ForEach(analysis.factors, id: \.factor) { factor in
                            HStack(alignment: .top, spacing: DMFSpacing.xs) {
                                Text("•")
                                    .font(.system(size: 14))
                                    .foregroundColor(.skyBlue)

                                Text(factor.factor)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.textPrimary)
                            }
                        }
                    }
                    .padding(DMFSpacing.md)
                    .frame(maxWidth: 300)
                    .background(
                        RoundedRectangle(cornerRadius: DMFRadius.medium)
                            .fill(Color(hex: "F8FCFF"))
                            .overlay(
                                RoundedRectangle(cornerRadius: DMFRadius.medium)
                                    .stroke(Color.skyBlueDisabled, lineWidth: 1)
                            )
                    )
                    .opacity(isImageVisible ? 1 : 0)
                    .animation(.dmfStandard.delay(0.2), value: isImageVisible)
                }

                Spacer(minLength: DMFSpacing.md)

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
            .frame(maxWidth: .infinity)
        }
        .onAppear {
            withAnimation(.dmfGentle.delay(0.1)) {
                isImageVisible = true
            }
        }
    }
}
