import Foundation

public struct Lesson: Identifiable {
    public let id: UUID
    public let title: String
    public let questions: [Question]

    public init(
        id: UUID = UUID(),
        title: String,
        questions: [Question]
    ) {
        self.id = id
        self.title = title
        self.questions = questions
    }

    public var questionCount: Int {
        return questions.count
    }

    public static func beginner() -> Lesson {
        return Lesson(
            title: BeginnerLessonData.title,
            questions: BeginnerLessonData.questions
        )
    }
}

enum BeginnerLessonData {
    static let title = "Перші кроки англійською"

    static let questions: [Question] = [
        Question(
            word: "apple",
            options: ["яблуко", "вікно", "книга"],
            correctAnswerIndex: 0,
            hint: "Це фрукт."
        ),
        Question(
            word: "book",
            options: ["стіл", "книга", "вода"],
            correctAnswerIndex: 1,
            hint: "Її читають."
        ),
        Question(
            word: "sun",
            options: ["місяць", "дощ", "сонце"],
            correctAnswerIndex: 2
        )
    ]
}