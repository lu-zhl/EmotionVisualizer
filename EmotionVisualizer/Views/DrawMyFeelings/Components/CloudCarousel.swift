import SwiftUI

struct CloudCarousel: View {
    @Binding var freeText: String
    @Binding var currentIndex: Int
    let maxCharacters: Int
    let warningThreshold: Int
    let hasFreeTextContent: Bool
    let hasQuestionnaireSelections: Bool
    let selectedEmotions: [DMFEmotion]
    let onStartQuestionnaire: () -> Void
    let onModifySelections: () -> Void

    @State private var dragOffset: CGFloat = 0
    private let swipeThreshold: CGFloat = 50

    var body: some View {
        VStack(spacing: DMFSpacing.xl) {
            // Carousel
            ZStack {
                // Back cloud (Cloud #2 or Cloud #1 depending on index)
                cloudAtIndex(currentIndex == 0 ? 1 : 0)
                    .scaleEffect(0.95)
                    .offset(x: currentIndex == 0 ? 30 : -30, y: 10)
                    .opacity(0.8)

                // Front cloud
                cloudAtIndex(currentIndex)
                    .offset(x: dragOffset)
            }
            .gesture(
                DragGesture()
                    .onChanged { value in
                        dragOffset = value.translation.width
                    }
                    .onEnded { value in
                        let horizontalAmount = value.translation.width

                        withAnimation(.dmfSpringy) {
                            if horizontalAmount < -swipeThreshold && currentIndex == 0 {
                                // Swipe left - show cloud #2
                                currentIndex = 1
                            } else if horizontalAmount > swipeThreshold && currentIndex == 1 {
                                // Swipe right - show cloud #1
                                currentIndex = 0
                            }
                            dragOffset = 0
                        }
                    }
            )

            // Page indicator
            PageIndicator(currentIndex: currentIndex, pageCount: 2)
        }
    }

    @ViewBuilder
    private func cloudAtIndex(_ index: Int) -> some View {
        if index == 0 {
            FreeTextCloudView(
                text: $freeText,
                maxCharacters: maxCharacters,
                warningThreshold: warningThreshold,
                hasContent: hasFreeTextContent
            )
        } else {
            QuestionnaireCloudView(
                onStartQuestionnaire: onStartQuestionnaire,
                onModifySelections: onModifySelections,
                hasSelections: hasQuestionnaireSelections,
                selectedEmotions: selectedEmotions
            )
        }
    }
}

struct PageIndicator: View {
    let currentIndex: Int
    let pageCount: Int

    var body: some View {
        HStack(spacing: DMFSpacing.sm) {
            ForEach(0..<pageCount, id: \.self) { index in
                Circle()
                    .fill(index == currentIndex ? Color.skyBlue : Color.skyBlueDisabled)
                    .frame(
                        width: index == currentIndex ? 8 : 6,
                        height: index == currentIndex ? 8 : 6
                    )
                    .animation(.dmfQuick, value: currentIndex)
            }
        }
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var text = ""
        @State private var currentIndex = 0

        var body: some View {
            ZStack {
                LinearGradient.screenBackground
                    .ignoresSafeArea()

                CloudCarousel(
                    freeText: $text,
                    currentIndex: $currentIndex,
                    maxCharacters: 5000,
                    warningThreshold: 4500,
                    hasFreeTextContent: !text.isEmpty,
                    hasQuestionnaireSelections: false,
                    selectedEmotions: [],
                    onStartQuestionnaire: { print("Start questionnaire") },
                    onModifySelections: { print("Modify selections") }
                )
            }
        }
    }

    return PreviewWrapper()
}
