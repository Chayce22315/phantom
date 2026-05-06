import SwiftUI

struct POSTView: View {
    let onDone: () -> Void
    @State private var lines: [String] = []
    @State private var cursor = true

    private let postLines = [
        "PHANTOM BIOS v2.1.0  Copyright (C) 2024",
        "CPU: Apple Silicon A-Series @ 3.46GHz",
        "Memory Test: ████████████████ 8192MB OK",
        "Initializing storage controller.......... OK",
        "Detecting boot device: PHANTOM_OS",
        "Verifying kernel integrity............... OK",
        "Loading bootloader........................",
        "",
        "Press any key to continue or wait...",
    ]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 4) {
                ForEach(lines.indices, id: \.self) { i in
                    Text(lines[i])
                        .font(.system(size: 13, design: .monospaced))
                        .foregroundColor(i == 0 ? Color(hex: "00FFC8") : .white.opacity(0.85))
                }
                if lines.count == postLines.count {
                    HStack(spacing: 0) {
                        Text("> _")
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(Color(hex: "00FFC8"))
                            .opacity(cursor ? 1 : 0)
                    }
                }
                Spacer()
            }
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .onTapGesture { onDone() }
        .onAppear {
            animateLines()
            blinkCursor()
        }
    }

    private func animateLines() {
        for (i, line) in postLines.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 0.18) {
                withAnimation { lines.append(line) }
                if i == postLines.count - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
                        onDone()
                    }
                }
            }
        }
    }

    private func blinkCursor() {
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            cursor.toggle()
        }
    }
}
