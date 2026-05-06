import SwiftUI

struct BootView: View {
    let onDone: () -> Void
    @State private var logoOpacity = 0.0
    @State private var logoScale = 0.8
    @State private var glowRadius = 0.0
    @State private var progress = 0.0
    @State private var statusText = "Initializing kernel..."
    @State private var scanLine = 0.0

    private let bootSteps: [(String, Double)] = [
        ("Initializing kernel...", 0.15),
        ("Mounting filesystem...", 0.30),
        ("Loading PHANTOM core...", 0.50),
        ("Starting window compositor...", 0.68),
        ("Applying user preferences...", 0.82),
        ("Launching desktop...", 1.0),
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // Scan line effect
            GeometryReader { geo in
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, Color(hex: "00FFC8").opacity(0.04), .clear],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(height: 60)
                    .offset(y: scanLine * geo.size.height)
                    .ignoresSafeArea()
            }

            VStack(spacing: 40) {
                Spacer()

                // Logo
                VStack(spacing: 8) {
                    Text("◈")
                        .font(.system(size: 64))
                        .foregroundColor(Color(hex: "00FFC8"))
                        .shadow(color: Color(hex: "00FFC8").opacity(0.8), radius: glowRadius)

                    Text("PHANTOM")
                        .font(.system(size: 36, weight: .thin, design: .monospaced))
                        .tracking(12)
                        .foregroundColor(.white)

                    Text("OS v1.0.0")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.white.opacity(0.4))
                        .tracking(4)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                Spacer()

                // Boot progress
                VStack(spacing: 12) {
                    Text(statusText)
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(Color(hex: "00FFC8").opacity(0.8))
                        .animation(.none, value: statusText)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white.opacity(0.08))
                                .frame(height: 3)

                            RoundedRectangle(cornerRadius: 2)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "00FFC8"), Color(hex: "00A8FF")],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * progress, height: 3)
                                .shadow(color: Color(hex: "00FFC8").opacity(0.6), radius: 4)
                        }
                    }
                    .frame(height: 3)
                    .padding(.horizontal, 60)
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear { startBoot() }
    }

    private func startBoot() {
        withAnimation(.easeOut(duration: 0.8)) {
            logoOpacity = 1
            logoScale = 1
        }
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            glowRadius = 20
        }
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            scanLine = 1
        }

        var delay = 0.6
        for (text, prog) in bootSteps {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                withAnimation(.easeInOut(duration: 0.3)) {
                    statusText = text
                    progress = prog
                }
            }
            delay += 0.5
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + delay + 0.4) {
            onDone()
        }
    }
}
