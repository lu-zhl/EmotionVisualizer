import SwiftUI

struct FreeTextCloudView: View {
    @Binding var text: String
    let maxCharacters: Int
    let warningThreshold: Int
    let hasContent: Bool

    @FocusState private var isFocused: Bool

    private var characterCount: Int {
        text.count
    }

    private var isNearLimit: Bool {
        characterCount > warningThreshold
    }

    private var counterColor: Color {
        isNearLimit ? .warningRed : .textPlaceholder
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            // Cloud container
            ZStack {
                // Cloud background
                CloudShape()
                    .fill(Color.cloudWhite)
                CloudShape()
                    .stroke(Color.lightBlue, lineWidth: 1)

                // Content
                VStack(spacing: DMFSpacing.xs) {
                    // Text editor area
                    ZStack(alignment: .topLeading) {
                        // Placeholder
                        if text.isEmpty {
                            Text("Type how you're feeling...")
                                .font(.dmfBody)
                                .foregroundColor(.textPlaceholder)
                                .padding(.top, 8)
                                .padding(.leading, 5)
                        }

                        TextEditor(text: $text)
                            .font(.dmfBody)
                            .foregroundColor(.textPrimary)
                            .scrollContentBackground(.hidden)
                            .background(Color.clear)
                            .focused($isFocused)
                            .onChange(of: text) { _, newValue in
                                // Enforce character limit
                                if newValue.count > maxCharacters {
                                    text = String(newValue.prefix(maxCharacters))
                                }
                            }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                    // Character counter
                    HStack {
                        Spacer()
                        Text("\(characterCount) / \(maxCharacters)")
                            .font(.dmfCaption)
                            .foregroundColor(counterColor)
                    }
                }
                .padding(.horizontal, DMFSpacing.lg)
                .padding(.vertical, DMFSpacing.xl)
                .padding(.bottom, DMFSpacing.sm)
            }
            .frame(width: 320, height: 200)
            .shadowMedium()

            // Has content badge
            if hasContent {
                ContentBadge()
                    .offset(x: -10, y: 10)
            }
        }
        .accessibilityLabel("Free text input. Type how you're feeling.")
        .accessibilityHint("Maximum \(maxCharacters) characters")
    }
}

struct ContentBadge: View {
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.successGreen)
                .frame(width: 24, height: 24)

            Image(systemName: "checkmark")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
        }
        .shadowSoft()
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var text = ""

        var body: some View {
            ZStack {
                LinearGradient.screenBackground
                    .ignoresSafeArea()

                FreeTextCloudView(
                    text: $text,
                    maxCharacters: 5000,
                    warningThreshold: 4500,
                    hasContent: !text.isEmpty
                )
            }
        }
    }

    return PreviewWrapper()
}
