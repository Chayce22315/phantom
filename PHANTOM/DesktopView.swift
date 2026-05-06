import SwiftUI

struct DesktopView: View {
    @StateObject private var wm = WindowManager()
    @State private var screenSize: CGSize = .zero
    @State private var showDock = true
    @State private var currentTime = Date()
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Wallpaper
                ParticleWallpaper()

                // Windows (non-minimized)
                ForEach(wm.windows.filter { !$0.isMinimized }.sorted(by: { $0.zIndex < $1.zIndex })) { win in
                    FloatingWindow(win: win, wm: wm, screenSize: geo.size)
                        .zIndex(Double(win.zIndex))
                }

                // Top bar
                VStack {
                    TopBar(time: currentTime)
                    Spacer()
                    DockBar(wm: wm, screenSize: geo.size)
                        .padding(.bottom, 8)
                }
                .zIndex(9999)
            }
            .onAppear { screenSize = geo.size }
            .onReceive(timer) { currentTime = $0 }
        }
        .ignoresSafeArea()
    }
}

struct TopBar: View {
    let time: Date
    private var timeStr: String {
        let f = DateFormatter(); f.dateFormat = "HH:mm:ss"
        return f.string(from: time)
    }
    private var dateStr: String {
        let f = DateFormatter(); f.dateFormat = "EEE dd MMM"
        return f.string(from: time)
    }

    var body: some View {
        HStack {
            Text("◈ PHANTOM OS")
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(Color(hex: "00FFC8"))

            Spacer()

            HStack(spacing: 16) {
                Text(dateStr)
                Text(timeStr)
                    .monospacedDigit()
            }
            .font(.system(size: 12, design: .monospaced))
            .foregroundColor(.white.opacity(0.7))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .overlay(
                    Rectangle()
                        .fill(Color(hex: "00FFC8").opacity(0.04))
                )
        )
        .overlay(
            Rectangle()
                .fill(Color(hex: "00FFC8").opacity(0.15))
                .frame(height: 1),
            alignment: .bottom
        )
    }
}

struct DockBar: View {
    @ObservedObject var wm: WindowManager
    let screenSize: CGSize
    private let apps = AppWindow.allCases

    var body: some View {
        HStack(spacing: 8) {
            ForEach(apps) { app in
                DockIcon(app: app, isOpen: wm.windows.contains(where: { $0.app == app })) {
                    wm.open(app, screenSize: screenSize)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(Color(hex: "00FFC8").opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.5), radius: 20)
    }
}

struct DockIcon: View {
    let app: AppWindow
    let isOpen: Bool
    let action: () -> Void
    @State private var pressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            LinearGradient(
                                colors: isOpen
                                    ? [Color(hex: "00FFC8").opacity(0.3), Color(hex: "00A8FF").opacity(0.2)]
                                    : [Color.white.opacity(0.07), Color.white.opacity(0.03)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 52, height: 52)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(
                                    isOpen ? Color(hex: "00FFC8").opacity(0.5) : Color.white.opacity(0.1),
                                    lineWidth: 1
                                )
                        )

                    Image(systemName: app.icon)
                        .font(.system(size: 22))
                        .foregroundColor(isOpen ? Color(hex: "00FFC8") : .white.opacity(0.7))
                }
                .shadow(color: isOpen ? Color(hex: "00FFC8").opacity(0.4) : .clear, radius: 8)
                .scaleEffect(pressed ? 0.88 : 1.0)

                if isOpen {
                    Circle()
                        .fill(Color(hex: "00FFC8"))
                        .frame(width: 4, height: 4)
                        .shadow(color: Color(hex: "00FFC8"), radius: 3)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.spring(response: 0.2)) { pressed = true } }
                .onEnded { _ in withAnimation(.spring(response: 0.3)) { pressed = false } }
        )
    }
}
