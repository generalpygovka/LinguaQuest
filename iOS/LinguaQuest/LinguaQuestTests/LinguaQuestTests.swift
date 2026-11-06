import XCTest
import Combine
@testable import LinguaQuest

final class LinguaQuestTests: XCTestCase {
    func testAllCorrectAnswersGiveThreePoints() throws {
        let session = try makeSession()

        for answerIndex in [0, 1, 2] {
            session.submitAnswer(answerIndex)
            XCTAssertTrue(session.nextQuestion())
        }

        XCTAssertTrue(session.isCompleted)
        XCTAssertEqual(session.correctAnswers, 3)
        XCTAssertEqual(session.score, 3)
    }

    func testMixedAnswersGiveTwoPoints() throws {
        let session = try makeSession()

        session.submitAnswer(1)
        session.submitAnswer(2)
        session.nextQuestion()

        session.submitAnswer(0)
        session.submitAnswer(1)
        session.nextQuestion()

        session.submitAnswer(2)
        session.nextQuestion()

        XCTAssertTrue(session.isCompleted)
        XCTAssertEqual(session.correctAnswers, 2)
        XCTAssertEqual(session.score, 2)
    }

    func testInvalidAnswerDoesNotSpendAttempt() throws {
        let session = try makeSession()

        session.submitAnswer(-1)
        session.submitAnswer(99)

        XCTAssertEqual(session.wrongAttempts, 0)
        XCTAssertEqual(session.score, 0)
        XCTAssertFalse(session.questionFinished)
        XCTAssertFalse(session.nextQuestion())
        XCTAssertEqual(session.questionIndex, 0)
    }

    func testFinishedQuestionCannotAwardPointsTwice() throws {
        let session = try makeSession()

        session.submitAnswer(0)

        XCTAssertNil(session.submitAnswer(0))
        XCTAssertEqual(session.score, 1)
        XCTAssertEqual(session.correctAnswers, 1)
    }

    func testEmptyLessonIsRejected() {
        let lesson = Lesson(
            title: "Порожній урок",
            questions: []
        )

        XCTAssertThrowsError(
            try LessonSession(
                lesson: lesson,
                checker: AnswerChecker(),
                points: { isCorrect in
                    return isCorrect ? 1 : 0
                }
            )
        )
    }

    func testInvalidCorrectAnswerIndexIsRejected() {
        let question = Question(
            word: "apple",
            options: ["яблуко"],
            correctAnswerIndex: 9
        )

        let lesson = Lesson(
            title: "Некоректний урок",
            questions: [question]
        )

        XCTAssertThrowsError(
            try LessonSession(
                lesson: lesson,
                checker: AnswerChecker(),
                points: { isCorrect in
                    return isCorrect ? 1 : 0
                }
            )
        )
    }

    func testInjectedCheckerIsUsed() throws {
        let checker = TestAnswerChecker()
        let session = try makeSession(checker: checker)

        session.submitAnswer(0)

        XCTAssertEqual(checker.callCount, 1)
        XCTAssertEqual(session.score, 1)
    }

    @MainActor
    func testHintsDoNotChangeScoreOrSpendAttempts() throws {
        let session = try makeSession()
        let viewModel = LessonViewModel(session: session)

        viewModel.showHint()

        XCTAssertEqual(
            viewModel.hintText,
            "Підказка: Це фрукт."
        )
        XCTAssertEqual(viewModel.score, 0)
        XCTAssertEqual(session.wrongAttempts, 0)

        viewModel.submitAnswer(at: 0)
        viewModel.nextQuestion()

        viewModel.submitAnswer(at: 1)
        viewModel.nextQuestion()

        viewModel.showHint()

        XCTAssertEqual(
            viewModel.hintText,
            "Для цього запитання підказки немає."
        )
        XCTAssertEqual(viewModel.score, 2)
        XCTAssertEqual(session.wrongAttempts, 0)
    }

    @MainActor
    func testRestartClearsResultHintsAndMessages() throws {
        let session = try makeSession()
        let viewModel = LessonViewModel(session: session)

        viewModel.showHint()
        viewModel.submitAnswer(at: 0)

        XCTAssertFalse(viewModel.message.isEmpty)
        XCTAssertNotNil(viewModel.hintText)

        viewModel.restart()

        XCTAssertEqual(viewModel.score, 0)
        XCTAssertEqual(viewModel.correctAnswers, 0)
        XCTAssertEqual(viewModel.questionNumber, 1)
        XCTAssertEqual(viewModel.currentQuestion?.word, "apple")
        XCTAssertNil(viewModel.hintText)
        XCTAssertEqual(viewModel.message, "")
        XCTAssertFalse(viewModel.questionFinished)
        XCTAssertFalse(viewModel.isCompleted)
    }

    @MainActor
    func testScoreChangesNotifyObserver() throws {
        let session = try makeSession()
        let viewModel = LessonViewModel(session: session)

        var receivedScores: [Int] = []

        let subscription = viewModel.$score.sink { value in
            receivedScores.append(value)
        }

        defer {
            subscription.cancel()
        }

        viewModel.submitAnswer(at: 0)

        XCTAssertEqual(receivedScores, [0, 1])
    }

    private func makeSession(
        checker: any AnswerChecking = AnswerChecker()
    ) throws -> LessonSession {
        return try LessonSession(
            lesson: makeLesson(),
            checker: checker,
            points: { isCorrect in
                return isCorrect ? 1 : 0
            }
        )
    }

    private func makeLesson() -> Lesson {
        return Lesson(
            title: "Тестовий урок",
            questions: [
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
        )
    }
}

private final class TestAnswerChecker: AnswerChecking {
    private(set) var callCount = 0

    func check(
        answerIndex: Int,
        question: Question
    ) -> AnswerResult {
        callCount += 1
        return .correct
    }
}
