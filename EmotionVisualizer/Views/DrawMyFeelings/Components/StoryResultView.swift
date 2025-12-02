import SwiftUI

struct StoryResultView: View {
    let visualization: GeneratedVisualization?
    let onCelebrate: () -> Void
    let onStartOver: () -> Void

    @State private var isImageVisible = false
    @State private var selectedFactor: GeneratedPsychologicalFactor? = nil
    @State private var showInsightPopout = false

    var body: some View {
        ZStack {
            // Main content
            ScrollView {
                VStack(spacing: DMFSpacing.lg) {
                    Spacer(minLength: DMFSpacing.lg)

                    // Tappable infographic image with 4-corner zones (v2.4)
                    ZStack {
                        // Background placeholder
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

                        // Generated image
                        if let imageData = visualization?.imageData,
                           let uiImage = UIImage(data: imageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 300, height: 300)
                                .clipShape(RoundedRectangle(cornerRadius: DMFRadius.xlarge))
                        } else {
                            VStack(spacing: DMFSpacing.md) {
                                Image(systemName: "brain.head.profile")
                                    .font(.system(size: 60))
                                    .foregroundColor(.skyBlue)

                                Text("Your mood analysis")
                                    .font(.dmfHeadline)
                                    .foregroundColor(.textPrimary)
                            }
                        }

                        // Tappable 4-corner zones overlay (v2.4)
                        if let analysis = visualization?.storyAnalysis {
                            TappableZonesOverlay(
                                factors: analysis.factors,
                                onTapFactor: { factor in
                                    selectedFactor = factor
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        showInsightPopout = true
                                    }
                                }
                            )
                            .frame(width: 300, height: 300)
                        }
                    }
                    .shadowMedium()
                    .scaleEffect(isImageVisible ? 1.0 : 0.95)
                    .opacity(isImageVisible ? 1 : 0)

                    // Hint text
                    if visualization?.storyAnalysis != nil {
                        Text("Tap icons to explore insights")
                            .font(.system(size: 14))
                            .foregroundColor(.textSecondary)
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

            // Insight Popout Modal (v2.4)
            if showInsightPopout, let factor = selectedFactor {
                InsightPopoutView(
                    factor: factor,
                    onClose: {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            showInsightPopout = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            selectedFactor = nil
                        }
                    }
                )
                .transition(.opacity)
            }
        }
        .onAppear {
            withAnimation(.dmfGentle.delay(0.1)) {
                isImageVisible = true
            }
        }
    }
}

// MARK: - Tappable Zones Overlay (v2.4)

struct TappableZonesOverlay: View {
    let factors: [GeneratedPsychologicalFactor]
    let onTapFactor: (GeneratedPsychologicalFactor) -> Void

    // Icon positions match backend: 22% and 78% of image size
    private let iconPositionNear: CGFloat = 0.22
    private let iconPositionFar: CGFloat = 0.78
    // Tap target size as percentage of image (covers the icon circle)
    private let tapTargetSize: CGFloat = 0.18

    var body: some View {
        GeometryReader { geo in
            let size = geo.size.width * tapTargetSize

            // Top-left icon (factor 0)
            if factors.count > 0 {
                Button(action: { onTapFactor(factors[0]) }) {
                    Circle()
                        .fill(Color.white.opacity(0.001)) // Nearly invisible but tappable
                        .frame(width: size, height: size)
                }
                .buttonStyle(.plain)
                .position(x: geo.size.width * iconPositionNear, y: geo.size.height * iconPositionNear)
            }

            // Top-right icon (factor 1)
            if factors.count > 1 {
                Button(action: { onTapFactor(factors[1]) }) {
                    Circle()
                        .fill(Color.white.opacity(0.001))
                        .frame(width: size, height: size)
                }
                .buttonStyle(.plain)
                .position(x: geo.size.width * iconPositionFar, y: geo.size.height * iconPositionNear)
            }

            // Bottom-left icon (factor 2)
            if factors.count > 2 {
                Button(action: { onTapFactor(factors[2]) }) {
                    Circle()
                        .fill(Color.white.opacity(0.001))
                        .frame(width: size, height: size)
                }
                .buttonStyle(.plain)
                .position(x: geo.size.width * iconPositionNear, y: geo.size.height * iconPositionFar)
            }

            // Bottom-right icon (factor 3)
            if factors.count > 3 {
                Button(action: { onTapFactor(factors[3]) }) {
                    Circle()
                        .fill(Color.white.opacity(0.001))
                        .frame(width: size, height: size)
                }
                .buttonStyle(.plain)
                .position(x: geo.size.width * iconPositionFar, y: geo.size.height * iconPositionFar)
            }
        }
    }
}

// MARK: - Insight Popout View (v2.4)

struct InsightPopoutView: View {
    let factor: GeneratedPsychologicalFactor
    let onClose: () -> Void

    var body: some View {
        ZStack {
            // Dimmed background
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    onClose()
                }

            // Popout card
            VStack(alignment: .leading, spacing: DMFSpacing.md) {
                // Header with close button
                HStack {
                    Text(factor.factor)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.textPrimary)

                    Spacer()

                    Button(action: onClose) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.textSecondary)
                            .frame(width: 32, height: 32)
                            .background(Color(hex: "F0F0F0"))
                            .clipShape(Circle())
                    }
                }

                // Insight text
                Text(factor.insight)
                    .font(.system(size: 15, weight: .regular))
                    .foregroundColor(Color(hex: "555555"))
                    .multilineTextAlignment(.leading)
                    .lineSpacing(4)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(DMFSpacing.lg)
            .frame(width: UIScreen.main.bounds.width * 0.85)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white)
            )
            .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
        }
    }
}
