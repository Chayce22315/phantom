import SwiftUI

struct Note: Identifiable {
    let id = UUID()
    var title: String
    var content: String
    var date: Date = Date()
}

struct NotesView: View {
    @State private var notes: [Note] = [
        Note(title: "Welcome", content: "This is PHANTOM Notes.\nTap + to create a new note."),
        Note(title: "Ideas", content: "• Build something cool\n• Ship it\n• ???\n• Profit"),
    ]
    @State private var selected: Note?
    @State private var showingNew = false
    @State private var newTitle = ""

    var body: some View {
        HStack(spacing: 0) {
            // Sidebar
            VStack(alignment: .leading, spacing: 0) {
                HStack {
                    Text("Notes")
                        .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(hex: "00FFC8"))
                    Spacer()
                    Button {
                        let n = Note(title: "Untitled", content: "")
                        notes.append(n)
                        selected = n
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 13))
                            .foregroundColor(Color(hex: "00FFC8"))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)

                Divider().background(Color(hex: "00FFC8").opacity(0.15))

                ScrollView {
                    VStack(spacing: 1) {
                        ForEach(notes) { note in
                            NoteSidebarRow(note: note, isSelected: selected?.id == note.id) {
                                selected = note
                            }
                        }
                    }
                }
            }
            .frame(width: 110)
            .background(Color.black.opacity(0.3))

            Divider().background(Color(hex: "00FFC8").opacity(0.1))

            // Editor
            if let binding = noteBinding {
                NoteEditor(note: binding)
            } else {
                VStack {
                    Text("Select a note")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.white.opacity(0.3))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.2))
            }
        }
    }

    private var noteBinding: Binding<Note>? {
        guard let s = selected,
              let idx = notes.firstIndex(where: { $0.id == s.id }) else { return nil }
        return $notes[idx]
    }
}

struct NoteSidebarRow: View {
    let note: Note
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 2) {
                Text(note.title)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(isSelected ? Color(hex: "00FFC8") : .white.opacity(0.8))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(isSelected ? Color(hex: "00FFC8").opacity(0.1) : .clear)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct NoteEditor: View {
    @Binding var note: Note

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("Title", text: $note.title)
                .font(.system(size: 14, weight: .semibold, design: .monospaced))
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .autocorrectionDisabled()
                .tint(Color(hex: "00FFC8"))

            Divider().background(Color(hex: "00FFC8").opacity(0.1))

            TextEditor(text: $note.content)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.white.opacity(0.85))
                .scrollContentBackground(.hidden)
                .background(.clear)
                .padding(.horizontal, 8)
                .tint(Color(hex: "00FFC8"))
        }
        .background(Color.black.opacity(0.2))
    }
}
