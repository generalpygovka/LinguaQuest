import Foundation

struct LessonResult: Hashable {
    let lessonID: UUID
    let lessonTitle: String
    let correctAnswers: Int
    let questionCount: Int
    let score: Int
}
