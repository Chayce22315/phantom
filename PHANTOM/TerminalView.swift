import SwiftUI

struct TerminalLine: Identifiable {
    let id = UUID()
    let text: String
    let isOutput: Bool
    let color: Color
}

struct TerminalView: View {
    @State private var input = ""
    @State private var lines: [TerminalLine] = [
        TerminalLine(text: "PHANTOM Terminal v1.0.0", isOutput: true, color: Color(hex: "00FFC8")),
        TerminalLine(text: "Type 'help' for available commands.", isOutput: true, color: .white.opacity(0.5)),
        TerminalLine(text: "", isOutput: true, color: .clear),
    ]
    @FocusState private var focused: Bool
    @State private var historyIndex = -1
    @State private var commandHistory: [String] = []

    private var prompt: String { "phantom@os:~$ " }

    var body: some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 2) {
                        ForEach(lines) { line in
                            Text(line.text)
                                .font(.system(size: 12, design: .monospaced))
                                .foregroundColor(line.color)
                                .textSelection(.enabled)
                                .id(line.id)
                        }
                    }
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .onChange(of: lines.count) { _ in
                    if let last = lines.last {
                        withAnimation { proxy.scrollTo(last.id, anchor: .bottom) }
                    }
                }
            }

            Divider().background(Color(hex: "00FFC8").opacity(0.2))

            HStack(spacing: 0) {
                Text(prompt)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(Color(hex: "00FFC8"))

                TextField("", text: $input)
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.white)
                    .autocorrectionDisabled()
                    .autocapitalization(.none)
                    .focused($focused)
                    .onSubmit { submitCommand() }
                    .tint(Color(hex: "00FFC8"))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.3))
        }
        .background(Color.black.opacity(0.6))
        .onAppear { focused = true }
    }

    private func submitCommand() {
        let cmd = input.trimmingCharacters(in: .whitespaces)
        lines.append(TerminalLine(text: prompt + cmd, isOutput: false, color: .white.opacity(0.9)))
        if !cmd.isEmpty { commandHistory.insert(cmd, at: 0) }
        let output = processCommand(cmd)
        for line in output {
            lines.append(line)
        }
        input = ""
        historyIndex = -1
    }

    private func processCommand(_ cmd: String) -> [TerminalLine] {
        let parts = cmd.split(separator: " ").map(String.init)
        let base = parts.first ?? ""

        switch base {
        case "":
            return []
        case "help":
            return [
                TerminalLine(text: "Available commands:", isOutput: true, color: Color(hex: "00FFC8")),
                TerminalLine(text: "  help        Show this message", isOutput: true, color: .white.opacity(0.7)),
                TerminalLine(text: "  ls          List files", isOutput: true, color: .white.opacity(0.7)),
                TerminalLine(text: "  cat <file>  View file contents", isOutput: true, color: .white.opacity(0.7)),
                TerminalLine(text: "  pwd         Print working directory", isOutput: true, color: .white.opacity(0.7)),
                TerminalLine(text: "  whoami      Print current user", isOutput: true, color: .white.opacity(0.7)),
                TerminalLine(text: "  uname       System information", isOutput: true, color: .white.opacity(0.7)),
                TerminalLine(text: "  neofetch    System info with art", isOutput: true, color: .white.opacity(0.7)),
                TerminalLine(text: "  clear        Clear terminal", isOutput: true, color: .white.opacity(0.7)),
                TerminalLine(text: "  echo <text>  Print text", isOutput: true, color: .white.opacity(0.7)),
                TerminalLine(text: "  date         Show current date", isOutput: true, color: .white.opacity(0.7)),
                TerminalLine(text: "  matrix       ???", isOutput: true, color: .white.opacity(0.7)),
            ]
        case "ls":
            return [
                TerminalLine(text: "drwxr-xr-x  documents/", isOutput: true, color: Color(hex: "00A8FF")),
                TerminalLine(text: "drwxr-xr-x  downloads/", isOutput: true, color: Color(hex: "00A8FF")),
                TerminalLine(text: "drwxr-xr-x  system/", isOutput: true, color: Color(hex: "00A8FF")),
                TerminalLine(text: "-rw-r--r--  readme.txt", isOutput: true, color: .white.opacity(0.8)),
                TerminalLine(text: "-rwxr-xr-x  phantom.core", isOutput: true, color: Color(hex: "00FFC8")),
                TerminalLine(text: "-rw-------  .secrets", isOutput: true, color: .white.opacity(0.4)),
            ]
        case "cat":
            let file = parts.count > 1 ? parts[1] : ""
            switch file {
            case "readme.txt":
                return [
                    TerminalLine(text: "Welcome to PHANTOM OS.", isOutput: true, color: .white.opacity(0.85)),
                    TerminalLine(text: "This system is experimental.", isOutput: true, color: .white.opacity(0.85)),
                    TerminalLine(text: "Proceed with caution.", isOutput: true, color: .white.opacity(0.85)),
                ]
            case ".secrets":
                return [TerminalLine(text: "Permission denied.", isOutput: true, color: Color(hex: "FF5F57"))]
            case "":
                return [TerminalLine(text: "cat: missing operand", isOutput: true, color: Color(hex: "FF5F57"))]
            default:
                return [TerminalLine(text: "cat: \(file): No such file or directory", isOutput: true, color: Color(hex: "FF5F57"))]
            }
        case "pwd":
            return [TerminalLine(text: "/home/phantom", isOutput: true, color: .white.opacity(0.85))]
        case "whoami":
            return [TerminalLine(text: "phantom", isOutput: true, color: .white.opacity(0.85))]
        case "uname":
            return [TerminalLine(text: "PHANTOM OS 1.0.0 arm64", isOutput: true, color: .white.opacity(0.85))]
        case "date":
            let f = DateFormatter(); f.dateStyle = .full; f.timeStyle = .long
            return [TerminalLine(text: f.string(from: Date()), isOutput: true, color: .white.opacity(0.85))]
        case "echo":
            let msg = parts.dropFirst().joined(separator: " ")
            return [TerminalLine(text: msg, isOutput: true, color: .white.opacity(0.85))]
        case "clear":
            lines = []
            return []
        case "neofetch":
            return neofetch()
        case "matrix":
            return matrixEgg()
        default:
            return [TerminalLine(text: "\(base): command not found. Type 'help'.", isOutput: true, color: Color(hex: "FF5F57"))]
        }
    }

    private func neofetch() -> [TerminalLine] {
        let c = Color(hex: "00FFC8")
        let w = Color.white.opacity(0.8)
        return [
            TerminalLine(text: "  ◈◈◈◈◈◈◈    phantom@phantom-os", isOutput: true, color: c),
            TerminalLine(text: " ◈       ◈   ─────────────────", isOutput: true, color: c),
            TerminalLine(text: "◈  ◈◈◈◈◈ ◈   OS:     PHANTOM OS 1.0.0", isOutput: true, color: w),
            TerminalLine(text: "◈  ◈   ◈ ◈   Kernel: phantom-core 5.0", isOutput: true, color: w),
            TerminalLine(text: "◈  ◈◈◈◈◈ ◈   Shell:  phantom-sh", isOutput: true, color: w),
            TerminalLine(text: " ◈       ◈   CPU:    Apple Silicon", isOutput: true, color: w),
            TerminalLine(text: "  ◈◈◈◈◈◈◈    RAM:    8192MB", isOutput: true, color: w),
            TerminalLine(text: "             Theme:  Phantom Dark", isOutput: true, color: w),
            TerminalLine(text: "             Colors: ████████", isOutput: true, color: c),
        ]
    }

    private func matrixEgg() -> [TerminalLine] {
        let chars = "ﾊﾋﾌﾍﾎﾏﾐﾑﾒﾓﾔﾕﾖﾗﾘﾙﾚﾛﾜﾝ01"
        return (0..<6).map { _ in
            let s = (0..<30).map { _ in String(chars.randomElement()!) }.joined()
            return TerminalLine(text: s, isOutput: true, color: Color(hex: "00FFC8").opacity(Double.random(in: 0.4...1.0)))
        } + [TerminalLine(text: "Wake up, phantom...", isOutput: true, color: Color(hex: "00FFC8"))]
    }
}
