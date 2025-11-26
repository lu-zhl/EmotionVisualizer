import SwiftUI

struct CloudShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let width = rect.width
        let height = rect.height

        // Create a unified cloud shape using bezier curves
        // Start from bottom left and draw clockwise

        let bottomY = height * 0.85
        let leftX = width * 0.08
        let rightX = width * 0.92

        // Start at bottom left
        path.move(to: CGPoint(x: leftX, y: bottomY))

        // Left bump - arc going up
        path.addQuadCurve(
            to: CGPoint(x: width * 0.15, y: height * 0.55),
            control: CGPoint(x: leftX - width * 0.05, y: height * 0.7)
        )

        // Left-top bump
        path.addQuadCurve(
            to: CGPoint(x: width * 0.3, y: height * 0.35),
            control: CGPoint(x: width * 0.1, y: height * 0.35)
        )

        // Center-left bump (higher)
        path.addQuadCurve(
            to: CGPoint(x: width * 0.45, y: height * 0.15),
            control: CGPoint(x: width * 0.28, y: height * 0.1)
        )

        // Top center bump
        path.addQuadCurve(
            to: CGPoint(x: width * 0.62, y: height * 0.18),
            control: CGPoint(x: width * 0.53, y: height * 0.05)
        )

        // Center-right bump
        path.addQuadCurve(
            to: CGPoint(x: width * 0.78, y: height * 0.38),
            control: CGPoint(x: width * 0.75, y: height * 0.12)
        )

        // Right bump
        path.addQuadCurve(
            to: CGPoint(x: rightX, y: height * 0.6),
            control: CGPoint(x: width * 0.95, y: height * 0.35)
        )

        // Right side going down to bottom
        path.addQuadCurve(
            to: CGPoint(x: rightX, y: bottomY),
            control: CGPoint(x: width * 1.0, y: height * 0.75)
        )

        // Bottom edge (flat)
        path.addLine(to: CGPoint(x: leftX, y: bottomY))

        path.closeSubpath()

        return path
    }
}

struct CloudView<Content: View>: View {
    let width: CGFloat
    let height: CGFloat
    let gradient: LinearGradient
    let borderColor: Color?
    let borderWidth: CGFloat
    let content: () -> Content

    init(
        width: CGFloat = 320,
        height: CGFloat = 200,
        gradient: LinearGradient = .cloudGradient,
        borderColor: Color? = nil,
        borderWidth: CGFloat = 1,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.width = width
        self.height = height
        self.gradient = gradient
        self.borderColor = borderColor
        self.borderWidth = borderWidth
        self.content = content
    }

    var body: some View {
        ZStack {
            // Cloud background
            CloudShape()
                .fill(gradient)

            // Cloud border
            if let borderColor = borderColor {
                CloudShape()
                    .stroke(borderColor, lineWidth: borderWidth)
            }

            // Content
            content()
                .padding(.horizontal, DMFSpacing.lg)
                .padding(.vertical, DMFSpacing.xl)
        }
        .frame(width: width, height: height)
        .shadowMedium()
    }
}

#Preview {
    VStack(spacing: 30) {
        CloudView(width: 280, height: 160) {
            Text("How are you feeling?")
                .font(.dmfHeadline)
                .foregroundColor(.textPrimary)
        }

        CloudView(
            width: 320,
            height: 200,
            gradient: .questionnaireCloudGradient,
            borderColor: .paleBlue
        ) {
            Text("Cloud with border")
                .font(.dmfBody)
                .foregroundColor(.textPrimary)
        }
    }
    .padding()
    .background(LinearGradient.screenBackground)
}
