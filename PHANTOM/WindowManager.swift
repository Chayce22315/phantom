import SwiftUI

enum AppWindow: String, CaseIterable, Identifiable {
    case terminal = "Terminal"
    case notes = "Notes"
    case calculator = "Calculator"
    case systemInfo = "System Info"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .terminal: return "terminal.fill"
        case .notes: return "note.text"
        case .calculator: return "function"
        case .systemInfo: return "info.circle.fill"
        }
    }

    var defaultSize: CGSize {
        switch self {
        case .terminal: return CGSize(width: 320, height: 380)
        case .notes: return CGSize(width: 300, height: 340)
        case .calculator: return CGSize(width: 260, height: 400)
        case .systemInfo: return CGSize(width: 310, height: 350)
        }
    }
}

class WindowState: ObservableObject, Identifiable {
    let id = UUID()
    let app: AppWindow
    @Published var position: CGPoint
    @Published var isMinimized = false
    @Published var zIndex: Int

    init(app: AppWindow, position: CGPoint, zIndex: Int) {
        self.app = app
        self.position = position
        self.zIndex = zIndex
    }
}

class WindowManager: ObservableObject {
    @Published var windows: [WindowState] = []
    private var nextZ = 1

    func open(_ app: AppWindow, screenSize: CGSize) {
        if let existing = windows.first(where: { $0.app == app }) {
            existing.isMinimized = false
            bringToFront(existing)
            return
        }
        let offset = CGPoint(
            x: CGFloat(windows.count % 4) * 20 + 30,
            y: CGFloat(windows.count % 4) * 20 + 80
        )
        let win = WindowState(
            app: app,
            position: CGPoint(
                x: (screenSize.width - app.defaultSize.width) / 2 + offset.x,
                y: (screenSize.height - app.defaultSize.height) / 2 + offset.y
            ),
            zIndex: nextZ
        )
        nextZ += 1
        windows.append(win)
    }

    func close(_ win: WindowState) {
        windows.removeAll { $0.id == win.id }
    }

    func minimize(_ win: WindowState) {
        win.isMinimized = true
    }

    func bringToFront(_ win: WindowState) {
        nextZ += 1
        win.zIndex = nextZ
    }
}
