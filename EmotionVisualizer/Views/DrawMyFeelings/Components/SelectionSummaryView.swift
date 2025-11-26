import SwiftUI

struct SelectionSummaryView: View {
    let selectedEmotions: [DMFEmotion]
    let onBack: () -> Void
    let onContinue: () -> Void
    let onStartOver: () -> Void

    @State private var isVisible = false

    var summaryText: String {
        let emotionNames = selectedEmotions.map { $0.displayName.lowercased() }

        switch emotionNames.count {
        case 0:
            return ""
        case 1:
            return "I feel \(emotionNames[0])."
        case 2:
            return "I feel \(emotionNames[0]) and \(emotionNames[1])."
        default:
            let allButLast = emotionNames.dropLast().joined(separator: ", ")
            let last = emotionNames.last!
            return "I feel \(allButLast) and \(last)."
        }
    }

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
                .accessibilityLabel("Back. Return to emotion selection.")

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

            Spacer()

            // Summary sentence
            Text(summaryText)
                .font(.system(size: 22, weight: .medium))
                .foregroundColor(.textPrimary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DMFSpacing.lg)
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 10)
                .animation(.easeOut(duration: 0.3).delay(0.2), value: isVisible)
                .accessibilityLabel("Your selected feelings: \(selectedEmotions.map { $0.displayName }.joined(separator: ", "))")

            Spacer()

            // Action buttons
            HStack(spacing: DMFSpacing.lg) {
                // Back button (secondary)
                Button(action: onBack) {
                    Text("Back")
                        .font(.dmfButtonSmall)
                        .foregroundColor(.textPrimary)
                        .frame(width: 100, height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: DMFRadius.small)
                                .fill(Color.aliceBlue)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: DMFRadius.small)
                                .stroke(Color.lightBlue, lineWidth: 1)
                        )
                }
                .shadowSoft()

                // Continue button (primary)
                Button(action: onContinue) {
                    Text("Continue")
                        .font(.dmfButtonLarge)
                        .foregroundColor(.white)
                        .frame(width: 140, height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: DMFRadius.small)
                                .fill(Color.skyBlue)
                        )
                }
                .shadowSoft()
                .accessibilityLabel("Continue. Save selections and return to input.")
            }
            .padding(.bottom, DMFSpacing.lg)

            // Start over text link
            Button(action: onStartOver) {
                Text("Start over")
                    .font(.dmfCaption)
                    .foregroundColor(.textSecondary)
            }
            .padding(.bottom, DMFSpacing.xl)
        }
        .onAppear {
            withAnimation {
                isVisible = true
            }
        }
    }
}

#Preview {
    ZStack {
        LinearGradient.screenBackground
            .ignoresSafeArea()

        SelectionSummaryView(
            selectedEmotions: [
                DMFEmotion.allEmotions[4], // content
                DMFEmotion.allEmotions[3], // chill
                DMFEmotion.allEmotions[8]  // blah
            ],
            onBack: { print("Back") },
            onContinue: { print("Continue") },
            onStartOver: { print("Start over") }
        )
    }
}
