public enum LessonBuilderError: Error {
    case emptyTitle
    case emptyLesson
    case invalidQuestion(index: Int)
}

public final class LessonBuilder {
    private let title: String
    private var questions: [Question] = []

    public init(title: String) {
        self.title = title
    }

    public func addQuestion(_ question: Question) {
        questions.append(question)
    }

    public func build() throws -> Lesson {
        guard !isBlank(title) else {
            throw LessonBuilderError.emptyTitle
        }

        guard !questions.isEmpty else {
            throw LessonBuilderError.emptyLesson
        }

        for (index, question) in questions.enumerated() {
            guard !isBlank(question.word),
                  !question.options.isEmpty,
                  question.options.allSatisfy({ !isBlank($0) }),
                  question.options.indices.contains(
                      question.correctAnswerIndex
                  )
            else {
                throw LessonBuilderError.invalidQuestion(index: index)
            }
        }

        return Lesson(title: title, questions: questions)
    }

    private func isBlank(_ text: String) -> Bool {
        return text.allSatisfy { $0.isWhitespace }
    }
}