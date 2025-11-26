import SwiftUI

// MARK: - Colors
extension Color {
    // Primary Blues
    static let skyBlue = Color(hex: "87CEEB")
    static let lightBlue = Color(hex: "ADD8E6")
    static let paleBlue = Color(hex: "B0E0E6")
    static let aliceBlue = Color(hex: "F0F8FF")

    // Cloud Colors
    static let cloudWhite = Color(hex: "FAFCFF")
    static let cloudGradientStart = Color(hex: "ADD8E6")
    static let cloudGradientEnd = Color(hex: "E0F4FF")

    // Interaction States
    static let skyBluePressed = Color(hex: "6BB8D9")
    static let skyBlueDisabled = Color(hex: "D0D0D0")

    // Text Colors
    static let textPrimary = Color(hex: "333333")
    static let textSecondary = Color(hex: "666666")
    static let textPlaceholder = Color(hex: "999999")

    // Semantic Colors
    static let successGreen = Color(hex: "4CAF50")
    static let warningRed = Color(hex: "E74C3C")

    // Helper initializer for hex colors
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Gradients
extension LinearGradient {
    static let cloudGradient = LinearGradient(
        colors: [Color(hex: "ADD8E6"), Color(hex: "E0F4FF")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let questionnaireCloudGradient = LinearGradient(
        colors: [Color(hex: "E8F4FC"), Color(hex: "F5FAFD")],
        startPoint: .top,
        endPoint: .bottom
    )

    static let buttonGradient = LinearGradient(
        colors: [Color(hex: "87CEEB"), Color(hex: "6BB8D9")],
        startPoint: .top,
        endPoint: .bottom
    )

    static let screenBackground = LinearGradient(
        colors: [Color(hex: "F0F8FF"), Color(hex: "FFFFFF")],
        startPoint: .top,
        endPoint: .bottom
    )
}

// MARK: - Typography
extension Font {
    static let dmfTitle = Font.system(size: 24, weight: .semibold)
    static let dmfHeadline = Font.system(size: 20, weight: .semibold)
    static let dmfBody = Font.system(size: 17, weight: .regular)
    static let dmfButtonLarge = Font.system(size: 18, weight: .semibold)
    static let dmfButtonSmall = Font.system(size: 16, weight: .medium)
    static let dmfCaption = Font.system(size: 14, weight: .regular)
    static let dmfLabel = Font.system(size: 15, weight: .medium)
    static let dmfEmotionLabel = Font.system(size: 13, weight: .regular)
}

// MARK: - Spacing
enum DMFSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
}

// MARK: - Corner Radius
enum DMFRadius {
    static let small: CGFloat = 12
    static let medium: CGFloat = 20
    static let large: CGFloat = 28
    static let xlarge: CGFloat = 32
}

// MARK: - Shadows
extension View {
    func shadowSoft() -> some View {
        self.shadow(
            color: Color.black.opacity(0.08),
            radius: 8,
            x: 0,
            y: 4
        )
    }

    func shadowMedium() -> some View {
        self.shadow(
            color: Color.black.opacity(0.12),
            radius: 12,
            x: 0,
            y: 6
        )
    }

    func shadowStrong() -> some View {
        self.shadow(
            color: Color.black.opacity(0.16),
            radius: 16,
            x: 0,
            y: 8
        )
    }
}

// MARK: - Animations
extension Animation {
    static let dmfQuick = Animation.easeOut(duration: 0.2)
    static let dmfStandard = Animation.easeInOut(duration: 0.3)
    static let dmfEmphasis = Animation.easeOut(duration: 0.4)
    static let dmfSpringy = Animation.spring(response: 0.4, dampingFraction: 0.8)
    static let dmfGentle = Animation.easeInOut(duration: 0.6)
}
