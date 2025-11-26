import SwiftUI

struct Level2EmotionsView: View {
    let emotions: [DMFEmotion]
    let selectedEmotions: Set<String>
    let onToggleEmotion: (DMFEmotion) -> Void
    let onDone: () -> Void
    let onBack: () -> Void
    let onStartOver: () -> Void

    @State private var isVisible = false

    private let columns = [
        GridItem(.flexible(), spacing: DMFSpacing.md),
        GridItem(.flexible(), spacing: DMFSpacing.md),
        GridItem(.flexible(), spacing: DMFSpacing.md)
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Navigation bar
            HStack {
                Button(action: onBack) {
                    HStack(spacing: DMFSpacing.xxs) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20))
                        Text("Back")
                            .font(.dmfButtonSmall)
                    }
                    .foregroundColor(.textPrimary)
                }
                .frame(width: 44, height: 44)
                .accessibilityLabel("Back. Return to previous question.")

                Spacer()

                Button(action: onStartOver) {
                    HStack(spacing: DMFSpacing.xxs) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 16))
                        Text("Start over")
                            .font(.dmfButtonSmall)
                    }
                    .foregroundColor(.textSecondary)
                }
            }
            .padding(.horizontal, DMFSpacing.lg)
            .padding(.top, DMFSpacing.md)

            // Title
            Text("I feel like:")
                .font(.dmfTitle)
                .foregroundColor(.textPrimary)
                .padding(.top, DMFSpacing.lg)
                .padding(.bottom, DMFSpacing.lg)

            // Emotions grid
            ScrollView {
                LazyVGrid(columns: columns, spacing: DMFSpacing.lg) {
                    ForEach(Array(emotions.enumerated()), id: \.element.id) { index, emotion in
                        EmotionButton(
                            emotion: emotion,
                            isSelected: selectedEmotions.contains(emotion.id),
                            onTap: { onToggleEmotion(emotion) }
                        )
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : 20)
                        .animation(
                            .easeOut(duration: 0.25).delay(Double(index) * 0.05),
                            value: isVisible
                        )
                    }
                }
                .padding(.horizontal, DMFSpacing.lg)
            }

            Spacer()

            // Done button
            Button(action: onDone) {
                Text("Done")
                    .font(.dmfButtonLarge)
                    .foregroundColor(selectedEmotions.isEmpty ? .textPlaceholder : .white)
                    .frame(width: 160, height: 48)
                    .background(
                        RoundedRectangle(cornerRadius: DMFRadius.large)
                            .fill(selectedEmotions.isEmpty ? Color.skyBlueDisabled : Color.skyBlue)
                    )
            }
            .disabled(selectedEmotions.isEmpty)
            .shadowSoft()
            .padding(.bottom, DMFSpacing.xl)
            .accessibilityLabel("Done. Confirm emotion selections.")
        }
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
    }
}

struct EmotionButton: View {
    let emotion: DMFEmotion
    let isSelected: Bool
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: DMFSpacing.xs) {
                ZStack(alignment: .topTrailing) {
                    Image(systemName: emotion.iconName)
                        .font(.system(size: 36))
                        .foregroundColor(isSelected ? emotion.accentColor : .textSecondary)
                        .frame(width: 60, height: 60)

                    // Selection indicator
                    if isSelected {
                        Circle()
                            .fill(emotion.accentColor)
                            .frame(width: 16, height: 16)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.white)
                            )
                            .offset(x: 4, y: -4)
                    }
                }

                Text(emotion.displayName)
                    .font(.dmfEmotionLabel)
                    .foregroundColor(.textPrimary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, DMFSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: DMFRadius.small)
                    .fill(isSelected ? emotion.accentColor.opacity(0.2) : Color.white)
            )
            .overlay(
                RoundedRectangle(cornerRadius: DMFRadius.small)
                    .stroke(
                        isSelected ? emotion.accentColor : Color(hex: "E8E8E8"),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.dmfQuick) { isPressed = true }
                }
                .onEnded { _ in
                    withAnimation(.dmfQuick) { isPressed = false }
                }
        )
        .shadowSoft()
        .accessibilityLabel("\(emotion.displayName). \(isSelected ? "Selected" : "Not selected"). Button. Double tap to \(isSelected ? "deselect" : "select").")
    }
}

#Preview {
    ZStack {
        LinearGradient.screenBackground
            .ignoresSafeArea()

        Level2EmotionsView(
            emotions: DMFEmotion.emotions(for: .good),
            selectedEmotions: ["superHappy", "chill"],
            onToggleEmotion: { emotion in print("Toggle: \(emotion.displayName)") },
            onDone: { print("Done") },
            onBack: { print("Back") },
            onStartOver: { print("Start over") }
        )
    }
}
