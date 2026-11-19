import SwiftUI
import Foundation

@MainActor
struct LessonListView: View {
    let items: [LessonListItem]

    let onOpenLesson: (UUID) -> Void
    let onEditLesson: (UUID) -> Void

    var body: some View {
        List {
            if items.isEmpty {
                Text("Уроків поки немає.")
                    .foregroundStyle(.secondary)
            }

            ForEach(items) { item in
                lessonRow(for: item)
            }
        }
        .navigationTitle("Мої уроки")
    }

    private func lessonRow(
        for item: LessonListItem
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(item.title)
                .font(.headline)
                .fixedSize(horizontal: false, vertical: true)

            Text("Запитань: \(item.questionCount)")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                Button(
                    item.isInProgress ? "Продовжити" : "Почати"
                ) {
                    onOpenLesson(item.id)
                }
                .buttonStyle(.borderedProminent)

                Button("Редагувати") {
                    onEditLesson(item.id)
                }
                .buttonStyle(.bordered)
            }
            .controlSize(.large)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
    }
}
