import SwiftUI

struct Level1QuestionnaireView: View {
    let onSelectCategory: (FeelingCategory) -> Void
    let onBack: () -> Void
    let onStartOver: () -> Void

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
                .accessibilityLabel("Back. Return to cloud selection.")

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

            // Title
            Text("Feel good?")
                .font(.dmfTitle)
                .foregroundColor(.textPrimary)
                .padding(.bottom, DMFSpacing.xl)

            // Options layout
            VStack(spacing: DMFSpacing.md) {
                // Top row: Good and Bad
                HStack(spacing: DMFSpacing.md) {
                    CategoryOptionButton(category: .good) {
                        onSelectCategory(.good)
                    }

                    CategoryOptionButton(category: .bad) {
                        onSelectCategory(.bad)
                    }
                }

                // Bottom row: Not Sure (centered)
                CategoryOptionButton(category: .notSure) {
                    onSelectCategory(.notSure)
                }
            }
            .padding(.horizontal, DMFSpacing.xl)

            Spacer()
            Spacer()
        }
    }
}

struct CategoryOptionButton: View {
    let category: FeelingCategory
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: DMFSpacing.sm) {
                Image(systemName: category.iconName)
                    .font(.system(size: 40))
                    .foregroundColor(iconColor)

                Text(category.displayName)
                    .font(.dmfLabel)
                    .foregroundColor(.textPrimary)
            }
            .frame(width: 120, height: 100)
            .background(
                RoundedRectangle(cornerRadius: DMFRadius.medium)
                    .fill(isPressed ? Color(hex: "E8F4FC") : Color(hex: "F5FAFD"))
            )
            .overlay(
                RoundedRectangle(cornerRadius: DMFRadius.medium)
                    .stroke(isPressed ? Color.skyBlue : Color(hex: "D0E4EF"), lineWidth: isPressed ? 2 : 1)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
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
        .accessibilityLabel(category.accessibilityLabel)
    }

    private var iconColor: Color {
        switch category {
        case .good: return Color(hex: "FFD700") // Golden yellow
        case .bad: return Color(hex: "6B8E9F") // Muted blue-gray
        case .notSure: return Color(hex: "A0A0A0") // Gray
        }
    }
}

#Preview {
    ZStack {
        LinearGradient.screenBackground
            .ignoresSafeArea()

        Level1QuestionnaireView(
            onSelectCategory: { category in print("Selected: \(category)") },
            onBack: { print("Back") },
            onStartOver: { print("Start over") }
        )
    }
}
