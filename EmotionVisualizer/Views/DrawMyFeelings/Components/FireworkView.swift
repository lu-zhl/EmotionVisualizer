import SwiftUI

struct FireworkView: View {
    let colors: [Color]

    @State private var particles: [FireworkParticle] = []

    private let fallbackColors: [Color] = [
        Color(hex: "FFD700"),
        Color(hex: "FF6B6B"),
        Color(hex: "4ECDC4"),
        Color(hex: "A78BFA")
    ]

    private var activeColors: [Color] {
        colors.isEmpty ? fallbackColors : colors
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(particles) { particle in
                    Circle()
                        .fill(particle.color)
                        .frame(width: particle.size, height: particle.size)
                        .position(particle.position)
                        .opacity(particle.opacity)
                }
            }
            .onAppear {
                generateParticles(in: geometry.size)
            }
        }
        .ignoresSafeArea()
    }

    private func generateParticles(in size: CGSize) {
        let centerX = size.width / 2
        let burstY = size.height * 0.4

        // Generate 50-100 particles
        let particleCount = Int.random(in: 50...100)

        for i in 0..<particleCount {
            let color = activeColors[i % activeColors.count]
            let particleSize = CGFloat.random(in: 4...8)

            // Initial position at burst point
            let startPosition = CGPoint(x: centerX, y: burstY)

            // Random velocity for burst
            let angle = Double.random(in: 0...(2 * .pi))
            let speed = CGFloat.random(in: 100...250)
            let vx = cos(angle) * speed
            let vy = sin(angle) * speed

            let particle = FireworkParticle(
                id: UUID(),
                color: color,
                size: particleSize,
                position: startPosition,
                velocity: CGPoint(x: vx, y: vy),
                opacity: 1.0
            )

            particles.append(particle)
        }

        // Animate particles
        animateParticles(screenHeight: size.height)
    }

    private func animateParticles(screenHeight: CGFloat) {
        let duration: Double = 2.0
        let steps = 60
        let gravity: CGFloat = 300

        for step in 0..<steps {
            let delay = Double(step) / Double(steps) * duration

            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                let t = CGFloat(step) / CGFloat(steps)

                for i in particles.indices {
                    // Update position with gravity
                    let dt = CGFloat(duration) / CGFloat(steps)
                    particles[i].position.x += particles[i].velocity.x * dt
                    particles[i].position.y += particles[i].velocity.y * dt + 0.5 * gravity * dt * dt

                    // Apply gravity to velocity
                    particles[i].velocity.y += gravity * dt

                    // Fade out
                    particles[i].opacity = Double(1.0 - t)
                }
            }
        }

        // Clear particles after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            particles.removeAll()
        }
    }
}

struct FireworkParticle: Identifiable {
    let id: UUID
    let color: Color
    let size: CGFloat
    var position: CGPoint
    var velocity: CGPoint
    var opacity: Double
}
