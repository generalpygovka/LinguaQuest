public protocol LessonRepository {
    func loadLesson() throws -> Lesson
}

public struct InMemoryLessonRepository: LessonRepository {
    private let title: String
    private let questions: [Question]

    public init(title: String, questions: [Question]) {
        self.title = title
        self.questions = questions
    }

    public init() {
        self.init(
            title: BeginnerLessonData.title,
            questions: BeginnerLessonData.questions
        )
    }

    public func loadLesson() throws -> Lesson {
        let builder = LessonBuilder(title: title)

        for question in questions {
            builder.addQuestion(question)
        }

        return try builder.build()
    }
}