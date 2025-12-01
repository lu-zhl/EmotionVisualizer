import SwiftUI

struct FreeTextInputView: View {
    @Binding var text: String
    let characterCount: Int
    let minCharacters: Int
    let maxCharacters: Int
    let canSubmit: Bool
    let onDrawStory: () -> Void
    let onStartOver: () -> Void

    @FocusState private var isTextFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            // Navigation bar
            HStack {
                Button(action: onStartOver) {
                    HStack(spacing: DMFSpacing.xxs) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 16))
                        Text("Start over")
                            .font(.dmfButtonSmall)
                    }
                    .foregroundColor(.textSecondary)
                }

                Spacer()
            }
            .padding(.horizontal, DMFSpacing.lg)
            .padding(.top, DMFSpacing.md)

            Spacer()

            // Cloud #1 - Text input
            VStack(spacing: DMFSpacing.md) {
                ZStack(alignment: .topLeading) {
                    // Cloud background
                    CloudShape()
                        .fill(Color.white)
                        .frame(width: 320, height: 200)
                        .shadowMedium()

                    // Text editor
                    VStack(spacing: DMFSpacing.xs) {
                        TextEditor(text: $text)
                            .font(.dmfBody)
                            .foregroundColor(.textPrimary)
                            .focused($isTextFocused)
                            .scrollContentBackground(.hidden)
                            .frame(height: 140)
                            .padding(.horizontal, DMFSpacing.md)
                            .padding(.top, DMFSpacing.md)

                        // Character counter
                        HStack {
                            if characterCount < minCharacters {
                                Text("min \(minCharacters) characters")
                                    .font(.dmfCaption)
                                    .foregroundColor(.textSecondary)
                            }

                            Spacer()

                            Text("\(characterCount) / \(maxCharacters)")
                                .font(.dmfCaption)
                                .foregroundColor(characterCount > maxCharacters - 500 ? .warningRed : .textSecondary)
                        }
                        .padding(.horizontal, DMFSpacing.md)
                        .padding(.bottom, DMFSpacing.sm)
                    }
                    .frame(width: 300, height: 180)
                    .offset(x: 10, y: 10)

                    // Placeholder
                    if text.isEmpty {
                        Text("Tell me more about your feelings...")
                            .font(.dmfBody)
                            .foregroundColor(Color(hex: "999999"))
                            .padding(.horizontal, DMFSpacing.md + 10)
                            .padding(.top, DMFSpacing.md + 18)
                            .allowsHitTesting(false)
                    }
                }
                .frame(width: 320, height: 200)
                .onTapGesture {
                    isTextFocused = true
                }
            }

            Spacer()

            // Draw my story button
            Button(action: onDrawStory) {
                Text("Draw my story")
                    .font(.dmfButton)
                    .foregroundColor(canSubmit ? .white : Color(hex: "999999"))
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(
                        Group {
                            if canSubmit {
                                LinearGradient(
                                    colors: [Color.skyBlue, Color(hex: "6BB8D9")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            } else {
                                Color(hex: "D0D0D0")
                            }
                        }
                    )
                    .clipShape(Capsule())
            }
            .disabled(!canSubmit)
            .shadowSoft()
            .padding(.horizontal, DMFSpacing.lg)
            .padding(.bottom, DMFSpacing.lg)
            .animation(.dmfStandard, value: canSubmit)
        }
    }
}
