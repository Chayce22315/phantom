import SwiftUI

struct FloatingWindow: View {
    @ObservedObject var win: WindowState
    @ObservedObject var wm: WindowManager
    let screenSize: CGSize
    @GestureState private var dragOffset: CGSize = .zero
    @State private var basePos: CGPoint = .zero

    var size: CGSize { win.app.defaultSize }

    var clampedPos: CGPoint {
        let drag = CGPoint(x: basePos.x + dragOffset.width, y: basePos.y + dragOffset.height)
        return CGPoint(
            x: max(0, min(screenSize.width - size.width, drag.x)),
            y: max(40, min(screenSize.height - size.height - 80, drag.y))
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            // Title bar
            WindowTitleBar(win: win, wm: wm)
                .gesture(
                    DragGesture()
                        .updating($dragOffset) { val, state, _ in state = val.translation }
                        .onEnded { val in
                            basePos = CGPoint(
                                x: max(0, min(screenSize.width - size.width, basePos.x + val.translation.width)),
                                y: max(40, min(screenSize.height - size.height - 80, basePos.y + val.translation.height))
                            )
                        }
                )
                .onTapGesture { wm.bringToFront(win) }

            // Content
            WindowContent(app: win.app)
                .frame(width: size.width, height: size.height - 36)
                .clipped()
        }
        .frame(width: size.width, height: size.height)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color(hex: "050A0F").opacity(0.7))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .strokeBorder(Color(hex: "00FFC8").opacity(0.18), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.6), radius: 24, x: 0, y: 8)
        .shadow(color: Color(hex: "00FFC8").opacity(0.05), radius: 20)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .position(x: clampedPos.x + size.width / 2, y: clampedPos.y + size.height / 2)
        .onAppear { basePos = win.position }
        .onTapGesture { wm.bringToFront(win) }
    }
}

struct WindowTitleBar: View {
    @ObservedObject var win: WindowState
    @ObservedObject var wm: WindowManager

    var body: some View {
        HStack(spacing: 8) {
            // Traffic lights
            Button { wm.close(win) } label: {
                Circle().fill(Color(hex: "FF5F57")).frame(width: 12, height: 12)
            }
            Button { wm.minimize(win) } label: {
                Circle().fill(Color(hex: "FEBC2E")).frame(width: 12, height: 12)
            }
            Circle().fill(Color(hex: "28C840")).frame(width: 12, height: 12)

            Spacer()

            Image(systemName: win.app.icon)
                .font(.system(size: 11))
                .foregroundColor(Color(hex: "00FFC8").opacity(0.8))
            Text(win.app.rawValue)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .foregroundColor(.white.opacity(0.8))

            Spacer()
        }
        .padding(.horizontal, 12)
        .frame(height: 36)
        .background(Color.white.opacity(0.04))
        .overlay(
            Rectangle()
                .fill(Color(hex: "00FFC8").opacity(0.1))
                .frame(height: 1),
            alignment: .bottom
        )
        .buttonStyle(PlainButtonStyle())
    }
}

struct WindowContent: View {
    let app: AppWindow

    var body: some View {
        Group {
            switch app {
            case .terminal: TerminalView()
            case .notes: NotesView()
            case .calculator: CalculatorView()
            case .systemInfo: SystemInfoView()
            }
        }
    }
}
