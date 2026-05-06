import SwiftUI

enum AppPhase {
    case post, boot, desktop
}

struct RootView: View {
    @State private var phase: AppPhase = .post

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            switch phase {
            case .post:
                POSTView {
                    withAnimation(.easeIn(duration: 0.4)) { phase = .boot }
                }
            case .boot:
                BootView {
                    withAnimation(.easeIn(duration: 0.6)) { phase = .desktop }
                }
            case .desktop:
                DesktopView()
                    .transition(.opacity)
            }
        }
        .ignoresSafeArea()
    }
}
