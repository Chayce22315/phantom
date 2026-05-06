import SwiftUI

struct Particle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var vx: CGFloat
    var vy: CGFloat
    var size: CGFloat
    var opacity: CGFloat
    var hue: CGFloat
}

class ParticleSystem: ObservableObject {
    @Published var particles: [Particle] = []
    var size: CGSize = .zero
    private var timer: Timer?

    func start(in size: CGSize) {
        self.size = size
        particles = (0..<60).map { _ in randomParticle(in: size) }
        timer = Timer.scheduledTimer(withTimeInterval: 1.0 / 30.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    func stop() { timer?.invalidate() }

    private func tick() {
        for i in particles.indices {
            particles[i].x += particles[i].vx
            particles[i].y += particles[i].vy
            if particles[i].x < 0 || particles[i].x > size.width ||
               particles[i].y < 0 || particles[i].y > size.height {
                particles[i] = randomParticle(in: size)
            }
        }
    }

    private func randomParticle(in size: CGSize) -> Particle {
        Particle(
            x: CGFloat.random(in: 0...size.width),
            y: CGFloat.random(in: 0...size.height),
            vx: CGFloat.random(in: -0.4...0.4),
            vy: CGFloat.random(in: -0.4...0.4),
            size: CGFloat.random(in: 1...3),
            opacity: CGFloat.random(in: 0.2...0.7),
            hue: CGFloat.random(in: 0.45...0.55)
        )
    }
}

struct ParticleWallpaper: View {
    @StateObject private var system = ParticleSystem()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Deep background gradient
                LinearGradient(
                    colors: [
                        Color(hex: "050A0F"),
                        Color(hex: "0A1520"),
                        Color(hex: "050A0F"),
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )

                // Grid overlay
                GridOverlay()

                // Particles
                Canvas { ctx, _ in
                    for p in system.particles {
                        let rect = CGRect(x: p.x - p.size/2, y: p.y - p.size/2,
                                         width: p.size, height: p.size)
                        ctx.opacity = p.opacity
                        ctx.fill(Path(ellipseIn: rect),
                                 with: .color(Color(hue: p.hue, saturation: 0.8, brightness: 1.0)))
                    }
                }

                // Ambient glow blobs
                RadialGradient(
                    colors: [Color(hex: "00FFC8").opacity(0.06), .clear],
                    center: .topLeading,
                    startRadius: 0, endRadius: 400
                )
                RadialGradient(
                    colors: [Color(hex: "0088FF").opacity(0.05), .clear],
                    center: .bottomTrailing,
                    startRadius: 0, endRadius: 500
                )
            }
            .onAppear { system.start(in: geo.size) }
            .onDisappear { system.stop() }
        }
        .ignoresSafeArea()
    }
}

struct GridOverlay: View {
    var body: some View {
        GeometryReader { geo in
            Canvas { ctx, size in
                let spacing: CGFloat = 40
                ctx.opacity = 0.04
                var path = Path()
                var x: CGFloat = 0
                while x <= size.width {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: size.height))
                    x += spacing
                }
                var y: CGFloat = 0
                while y <= size.height {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: size.width, y: y))
                    y += spacing
                }
                ctx.stroke(path, with: .color(Color(hex: "00FFC8")), lineWidth: 0.5)
            }
        }
        .ignoresSafeArea()
    }
}
