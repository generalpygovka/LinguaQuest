public enum LessonSessionError: Error {
    case emptyLesson
    case invalidQuestion(index: Int)
}

public final class LessonSession {
    public let lesson: Lesson

    private let checker: any AnswerChecking
    private let points: (Bool) -> Int

    public private(set) var questionIndex = 0
    public private(set) var correctAnswers = 0
    public private(set) var score = 0
    public private(set) var wrongAttempts = 0
    public private(set) var questionFinished = false

    public var currentQuestion: Question? {
        guard lesson.questions.indices.contains(questionIndex) else {
            return nil
        }

        return lesson.questions[questionIndex]
    }

    public var isCompleted: Bool {
        return questionIndex >= lesson.questionCount
    }

    public init(
        lesson: Lesson,
        checker: any AnswerChecking,
        points: @escaping (Bool) -> Int
    ) throws {
        guard !lesson.questions.isEmpty else {
            throw LessonSessionError.emptyLesson
        }

        for (index, question) in lesson.questions.enumerated() {
            guard !question.options.isEmpty,
                  question.options.indices.contains(
                      question.correctAnswerIndex
                  )
            else {
                throw LessonSessionError.invalidQuestion(index: index)
            }
        }

        self.lesson = lesson
        self.checker = checker
        self.points = points
    }

    @discardableResult
    public func submitAnswer(_ answerIndex: Int) -> AnswerResult? {
        guard !isCompleted,
              !questionFinished,
              let question = currentQuestion
        else {
            return nil
        }

        let result = checker.check(
            answerIndex: answerIndex,
            question: question
        )

        switch result {
        case .correct:
            correctAnswers += 1
            score += points(true)
            questionFinished = true

        case .incorrect:
            wrongAttempts += 1

            if wrongAttempts >= 2 {
                score += points(false)
                questionFinished = true
            }

        case .invalid:
            break
        }

        return result
    }

    @discardableResult
    public func nextQuestion() -> Bool {
        guard questionFinished, !isCompleted else {
            return false
        }

        questionIndex += 1
        resetQuestion()

        return true
    }

    public func restart() {
        questionIndex = 0
        correctAnswers = 0
        score = 0

        resetQuestion()
    }

    private func resetQuestion() {
        wrongAttempts = 0
        questionFinished = false
    }
}
