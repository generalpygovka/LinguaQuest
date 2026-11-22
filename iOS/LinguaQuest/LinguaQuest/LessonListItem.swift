import Foundation

struct LessonListItem: Identifiable {
    let id: UUID
    let title: String
    let questionCount: Int
    let isInProgress: Bool
}
