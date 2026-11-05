import Combine

@MainActor
final class LessonViewModel: ObservableObject {
    let lessonTitle: String
    let questionCount: Int

    @Published private(set) var currentQuestion: Question? = nil
    @Published private(set) var questionNumber = 1
    @Published private(set) var correctAnswers = 0
    @Published private(set) var score = 0
    @Published private(set) var questionFinished = false
    @Published private(set) var isCompleted = false
    @Published private(set) var hintText: String? = nil
    @Published private(set) var message = ""

    private let session: LessonSession

    var nextButtonTitle: String {
        return questionNumber == questionCount
            ? "Завершити урок"
            : "Наступне запитання"
    }

    init(session: LessonSession) {
        self.session = session
        self.lessonTitle = session.lesson.title
        self.questionCount = session.lesson.questionCount

        synchronize()
    }

    func submitAnswer(at answerIndex: Int) {
        guard let question = session.currentQuestion else {
            return
        }

        let previousScore = session.score

        guard let result = session.submitAnswer(answerIndex) else {
            return
        }

        synchronize()

        let scoreChange = session.score - previousScore

        switch result {
        case .correct:
            message = "Правильно! \(pointsText(scoreChange))"

        case .incorrect:
            if session.questionFinished {
                let correctAnswer =
                    question.options[question.correctAnswerIndex]

                message =
                    "Неправильно. \(pointsText(scoreChange))\n" +
                    "Правильна відповідь: \(correctAnswer)."
            } else {
                message =
                    "Неправильно. Спробуй ще раз " +
                    "або скористайся підказкою."
            }

        case .invalid:
            message = "Не вдалося перевірити відповідь."
        }
    }

    func showHint() {
        guard !session.questionFinished,
              let question = session.currentQuestion
        else {
            return
        }

        if let hint = question.hint {
            hintText = "Підказка: \(hint)"
        } else {
            hintText = "Для цього запитання підказки немає."
        }
    }

    func nextQuestion() {
        guard session.nextQuestion() else {
            return
        }

        hintText = nil
        message = ""

        synchronize()
    }

    func restart() {
        session.restart()

        hintText = nil
        message = ""

        synchronize()
    }

    private func synchronize() {
        currentQuestion = session.currentQuestion
        questionNumber = min(
            session.questionIndex + 1,
            questionCount
        )
        correctAnswers = session.correctAnswers
        score = session.score
        questionFinished = session.questionFinished
        isCompleted = session.isCompleted
    }

    private func pointsText(_ value: Int) -> String {
        let prefix = value > 0 ? "+" : ""
        return "\(prefix)\(value) бал."
    }
}
