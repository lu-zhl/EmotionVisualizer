import SwiftUI

struct QuestionnaireCloudView: View {
    let onStartQuestionnaire: () -> Void
    let onModifySelections: () -> Void
    let hasSelections: Bool
    let selectedEmotions: [DMFEmotion]

    @State private var isPressed = false

    private var summaryText: String {
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
        ZStack(alignment: .topTrailing) {
            // Cloud container
            ZStack {
                // Cloud background with gradient
                CloudShape()
                    .fill(LinearGradient.questionnaireCloudGradient)
                CloudShape()
                    .stroke(Color.paleBlue, lineWidth: 1)

                // Content - depends on whether we have selections
                if hasSelections {
                    // State 2: Show summary text
                    Button(action: onModifySelections) {
                        Text(summaryText)
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.textPrimary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, DMFSpacing.lg)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel("Your mood selection: \(summaryText) Tap to modify.")
                } else {
                    // State 1: Show "Tap your moods" button
                    VStack {
                        Spacer()

                        Button(action: onStartQuestionnaire) {
                            Text("Tap your moods")
                                .font(.dmfButtonLarge)
                                .foregroundColor(.white)
                                .frame(width: 200, height: 50)
                                .background(
                                    RoundedRectangle(cornerRadius: DMFRadius.small)
                                        .fill(isPressed ? Color.skyBluePressed : Color.skyBlue)
                                )
                                .shadowSoft()
                        }
                        .buttonStyle(PlainButtonStyle())
                        .simultaneousGesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { _ in isPressed = true }
                                .onEnded { _ in isPressed = false }
                        )
                        .accessibilityLabel("Tap your moods. Start guided questionnaire.")

                        Spacer()
                    }
                    .padding(DMFSpacing.lg)
                }
            }
            .frame(width: 320, height: 200)
            .shadowMedium()

            // Has selections badge
            if hasSelections {
                ContentBadge()
                    .offset(x: -10, y: 10)
            }
        }
    }
}

#Preview {
    ZStack {
        LinearGradient.screenBackground
            .ignoresSafeArea()

        VStack(spacing: 30) {
            // State 1: No selections
            QuestionnaireCloudView(
                onStartQuestionnaire: { print("Start questionnaire") },
                onModifySelections: { print("Modify selections") },
                hasSelections: false,
                selectedEmotions: []
            )

            // State 2: With selections
            QuestionnaireCloudView(
                onStartQuestionnaire: { print("Start questionnaire") },
                onModifySelections: { print("Modify selections") },
                hasSelections: true,
                selectedEmotions: [
                    DMFEmotion.allEmotions[2], // cozy
                    DMFEmotion.allEmotions[4], // content
                    DMFEmotion.allEmotions[5]  // fuming
                ]
            )
        }
    }
}
