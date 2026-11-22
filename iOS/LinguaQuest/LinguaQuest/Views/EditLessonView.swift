import SwiftUI
import Foundation

@MainActor
struct EditLessonView: View {
    let onSave: (String) throws -> Void
    let onCancel: () -> Void

    @State private var draftTitle: String
    @State private var errorMessage: String? = nil

    @FocusState private var isTitleFocused: Bool

    init(
        title: String,
        onSave: @escaping (String) throws -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.onSave = onSave
        self.onCancel = onCancel
        _draftTitle = State(initialValue: title)
    }

    private var cleanedTitle: String {
        draftTitle.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Назва уроку") {
                    TextField(
                        "Введіть назву",
                        text: $draftTitle
                    )
                    .textInputAutocapitalization(.sentences)
                    .focused($isTitleFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        save()
                    }
                }

                if let errorMessage = errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Редагування")
            .navigationBarTitleDisplayMode(.inline)
            .onChange(of: draftTitle) { _, _ in
                errorMessage = nil
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Скасувати") {
                        isTitleFocused = false
                        onCancel()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Зберегти") {
                        save()
                    }
                    .disabled(cleanedTitle.isEmpty)
                }

                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()

                    Button("Готово") {
                        isTitleFocused = false
                    }
                }
            }
        }
    }

    private func save() {
        guard !cleanedTitle.isEmpty else {
            errorMessage = "Введіть назву уроку."
            isTitleFocused = true
            return
        }

        do {
            try onSave(cleanedTitle)
            errorMessage = nil
            isTitleFocused = false
        } catch {
            errorMessage =
                "Не вдалося зберегти назву. Спробуй ще раз."
        }
    }
}
