import SwiftUI

struct CalculatorView: View {
    @State private var display = "0"
    @State private var expression = ""
    @State private var stored = 0.0
    @State private var pendingOp: String? = nil
    @State private var justResult = false

    private let buttons: [[String]] = [
        ["C", "+/-", "%", "÷"],
        ["7", "8", "9", "×"],
        ["4", "5", "6", "−"],
        ["1", "2", "3", "+"],
        ["0",  ".", "="],
    ]

    var body: some View {
        VStack(spacing: 0) {
            // Display
            VStack(alignment: .trailing, spacing: 2) {
                Text(expression)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.white.opacity(0.35))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                Text(display)
                    .font(.system(size: display.count > 9 ? 22 : 32, weight: .light, design: .monospaced))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.4)
                    .monospacedDigit()
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(Color.black.opacity(0.4))

            Divider().background(Color(hex: "00FFC8").opacity(0.15))

            // Buttons
            VStack(spacing: 6) {
                ForEach(buttons, id: \.self) { row in
                    HStack(spacing: 6) {
                        ForEach(row, id: \.self) { label in
                            CalcButton(
                                label: label,
                                isWide: label == "0",
                                isOp: ["÷","×","−","+","="].contains(label),
                                isFunc: ["C","+/-","%"].contains(label)
                            ) {
                                handleTap(label)
                            }
                        }
                    }
                }
            }
            .padding(10)
            .background(Color.black.opacity(0.2))
        }
    }

    private func handleTap(_ label: String) {
        switch label {
        case "C":
            display = "0"; expression = ""; stored = 0; pendingOp = nil; justResult = false
        case "+/-":
            if let v = Double(display) { display = format(-v) }
        case "%":
            if let v = Double(display) { display = format(v / 100) }
        case "÷","×","−","+":
            if let v = Double(display) { stored = v }
            pendingOp = label
            expression = display + " " + label
            justResult = true
        case "=":
            guard let op = pendingOp, let v = Double(display) else { return }
            var result = 0.0
            switch op {
            case "÷": result = stored / v
            case "×": result = stored * v
            case "−": result = stored - v
            case "+": result = stored + v
            default: break
            }
            expression = "\(format(stored)) \(op) \(display) ="
            display = format(result)
            pendingOp = nil; justResult = true
        case ".":
            if justResult { display = "0"; justResult = false }
            if !display.contains(".") { display += "." }
        default:
            if justResult || display == "0" {
                display = label; justResult = false
            } else {
                if display.replacingOccurrences(of: "-", with: "").replacingOccurrences(of: ".", with: "").count < 9 {
                    display += label
                }
            }
        }
    }

    private func format(_ v: Double) -> String {
        if v == v.rounded() && !v.isInfinite && abs(v) < 1e10 {
            return String(Int(v))
        }
        return String(format: "%.6g", v)
    }
}

struct CalcButton: View {
    let label: String
    var isWide = false
    var isOp = false
    var isFunc = false
    let action: () -> Void
    @State private var pressed = false

    var bg: Color {
        if isOp && label == "=" { return Color(hex: "00FFC8") }
        if isOp { return Color(hex: "00A8FF").opacity(0.6) }
        if isFunc { return Color.white.opacity(0.15) }
        return Color.white.opacity(0.08)
    }

    var fg: Color {
        if label == "=" { return .black }
        return .white
    }

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.system(size: 18, weight: .medium, design: .monospaced))
                .foregroundColor(fg)
                .frame(maxWidth: isWide ? .infinity : nil)
                .frame(width: isWide ? nil : 52, height: 46)
                .background(RoundedRectangle(cornerRadius: 10).fill(bg))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                )
                .scaleEffect(pressed ? 0.92 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in withAnimation(.spring(response: 0.15)) { pressed = true } }
                .onEnded { _ in withAnimation(.spring(response: 0.2)) { pressed = false } }
        )
    }
}
