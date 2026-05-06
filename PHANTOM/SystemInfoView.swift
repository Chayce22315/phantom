import SwiftUI

struct SystemInfoView: View {
    @State private var uptime = 0
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var cpuAnim = false

    private var uptimeStr: String {
        let h = uptime / 3600, m = (uptime % 3600) / 60, s = uptime % 60
        return String(format: "%02d:%02d:%02d", h, m, s)
    }

    private let specs: [(String, String)] = [
        ("OS", "PHANTOM OS 1.0.0"),
        ("Kernel", "phantom-core 5.0.0"),
        ("Shell", "phantom-sh 2.1"),
        ("CPU", "Apple Silicon"),
        ("RAM", "8192 MB"),
        ("Storage", "256 GB PHANTOM-SSD"),
        ("Display", "Super Retina XDR"),
        ("Theme", "Phantom Dark"),
        ("User", "phantom"),
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // ASCII Logo
                VStack(alignment: .leading, spacing: 1) {
                    ForEach([
                        " ██████╗ ██╗  ██╗",
                        " ██╔══██╗██║  ██║",
                        " ██████╔╝███████║",
                        " ██╔═══╝ ██╔══██║",
                        " ██║     ██║  ██║",
                        " ╚═╝     ╚═╝  ╚═╝",
                    ], id: \.self) { line in
                        Text(line)
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(Color(hex: "00FFC8"))
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)

                Divider()
                    .background(Color(hex: "00FFC8").opacity(0.15))
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)

                // Specs
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(specs, id: \.0) { key, val in
                        HStack(spacing: 0) {
                            Text(key.padding(toLength: 10, withPad: " ", startingAt: 0))
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(Color(hex: "00FFC8"))
                            Text(": ")
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.white.opacity(0.3))
                            Text(val)
                                .font(.system(size: 11, design: .monospaced))
                                .foregroundColor(.white.opacity(0.85))
                        }
                    }
                    HStack(spacing: 0) {
                        Text("Uptime    ")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(Color(hex: "00FFC8"))
                        Text(": ")
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.white.opacity(0.3))
                        Text(uptimeStr)
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.white.opacity(0.85))
                            .monospacedDigit()
                    }
                }
                .padding(.horizontal, 12)

                Divider()
                    .background(Color(hex: "00FFC8").opacity(0.15))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)

                // Color swatches
                HStack(spacing: 6) {
                    ForEach(["00FFC8","00A8FF","FF5F57","FEBC2E","28C840","A855F7","F97316","EC4899"], id: \.self) { hex in
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color(hex: hex))
                            .frame(width: 22, height: 22)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
        }
        .background(Color.black.opacity(0.5))
        .onReceive(timer) { _ in uptime += 1 }
    }
}
