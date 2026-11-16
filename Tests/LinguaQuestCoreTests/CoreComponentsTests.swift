import XCTest
import LinguaQuestCore

final class CoreComponentsTests: XCTestCase {
    private func appleQuestion() -> Question {
        return Question(
            word: "apple",
            options: ["яблуко", "вікно"],
            correctAnswerIndex: 0,
            hint: "Це фрукт."
        )
    }

    func testBuilderPreservesQuestionOrder() throws {
        let builder = LessonBuilder(title: "Тестовий урок")

        builder.addQuestion(appleQuestion())
        builder.addQuestion(
            Question(
                word: "book",
                options: ["книга", "вода"],
                correctAnswerIndex: 0
            )
        )

        let lesson = try builder.build()

        XCTAssertEqual(lesson.title, "Тестовий урок")
        XCTAssertEqual(lesson.questions.map { $0.word }, ["apple", "book"])
    }

    func testBuilderRejectsEmptyLesson() {
        let builder = LessonBuilder(title: "Тестовий урок")

        XCTAssertThrowsError(try builder.build())
    }

    func testBuilderRejectsBlankTitle() {
        let builder = LessonBuilder(title: "   ")
        builder.addQuestion(appleQuestion())

        XCTAssertThrowsError(try builder.build())
    }

    func testBuilderRejectsInvalidCorrectAnswerIndex() {
        let builder = LessonBuilder(title: "Тестовий урок")
        builder.addQuestion(
            Question(
                word: "apple",
                options: ["яблуко"],
                correctAnswerIndex: 5
            )
        )

        XCTAssertThrowsError(try builder.build())
    }

    func testRepositoryLoadsProvidedLessonData() throws {
        let repository: any LessonRepository = InMemoryLessonRepository(
            title: "Власний урок",
            questions: [appleQuestion()]
        )

        let lesson = try repository.loadLesson()

        XCTAssertEqual(lesson.title, "Власний урок")
        XCTAssertEqual(lesson.questionCount, 1)
        XCTAssertEqual(lesson.questions.first?.word, "apple")
    }

    func testDecoratorPreservesResultsAndLogsOncePerCheck() {
        let wrapped = CountingAnswerChecker()
        var messages: [String] = []

        let checker = LoggingAnswerChecker(
            wrapping: wrapped,
            log: { message in messages.append(message) }
        )

        let question = appleQuestion()
        let cases: [(index: Int, expected: AnswerResult)] = [
            (0, .correct),
            (1, .incorrect),
            (-1, .invalid),
            (99, .invalid)
        ]

        for (offset, item) in cases.enumerated() {
            let result = checker.check(
                answerIndex: item.index,
                question: question
            )

            XCTAssertEqual(result, item.expected)
            XCTAssertEqual(wrapped.callCount, offset + 1)
            XCTAssertEqual(messages.count, offset + 1)
        }
    }
}

private final class CountingAnswerChecker: AnswerChecking {
    private let checker = AnswerChecker()
    private(set) var callCount = 0

    func check(
        answerIndex: Int,
        question: Question
    ) -> AnswerResult {
        callCount += 1

        return checker.check(
            answerIndex: answerIndex,
            question: question
        )
    }
}