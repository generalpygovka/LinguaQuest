import XCTest
import Foundation
import Combine
import LinguaQuestCore
@testable import LinguaQuest

final class LessonProgressStoreTests: XCTestCase {
    @MainActor
    func testReopeningRenamedLessonPreservesProgress() throws {
        let store = makeStore()
        let lessonID = UUID()
        let lesson = Lesson.beginner()

        let first = try store.startOrResume(
            lessonID: lessonID,
            lesson: lesson
        )

        first.submitAnswer(at: 0)
        first.nextQuestion()
        first.showHint()

        let renamedLesson = Lesson(
            title: "Мої англійські слова",
            questions: lesson.questions
        )

        let resumed = try store.startOrResume(
            lessonID: lessonID,
            lesson: renamedLesson
        )

        XCTAssertTrue(first === resumed)
        XCTAssertEqual(resumed.questionNumber, 2)
        XCTAssertEqual(resumed.score, 1)
        XCTAssertEqual(
            resumed.hintText,
            "Підказка: Її читають."
        )
        XCTAssertEqual(
            resumed.lessonTitle,
            "Мої англійські слова"
        )
        XCTAssertTrue(store.isInProgress(for: lessonID))
    }

    @MainActor
    func testLessonsKeepSeparateProgressAndRestartIndependently() throws {
        let store = makeStore()
        let firstID = UUID()
        let secondID = UUID()
        let lesson = Lesson.beginner()

        let first = try store.startOrResume(
            lessonID: firstID,
            lesson: lesson
        )

        let second = try store.startOrResume(
            lessonID: secondID,
            lesson: lesson
        )

        first.submitAnswer(at: 1)
        second.submitAnswer(at: 0)

        let resumed = try store.startOrResume(
            lessonID: firstID,
            lesson: lesson
        )

        resumed.submitAnswer(at: 2)

        XCTAssertTrue(resumed.questionFinished)
        XCTAssertEqual(resumed.score, 0)
        XCTAssertEqual(second.score, 1)

        let restarted = try store.restart(
            lessonID: firstID,
            lesson: lesson
        )

        XCTAssertTrue(restarted === first)
        XCTAssertFalse(restarted.questionFinished)
        XCTAssertEqual(restarted.message, "")

        restarted.submitAnswer(at: 1)

        XCTAssertFalse(restarted.questionFinished)
        XCTAssertEqual(second.score, 1)
        XCTAssertTrue(second.questionFinished)
    }

    @MainActor
    func testOpeningCompletedLessonStartsNewAttempt() throws {
        let store = makeStore()
        let lessonID = UUID()
        let lesson = Lesson.beginner()

        let viewModel = try store.startOrResume(
            lessonID: lessonID,
            lesson: lesson
        )

        for answerIndex in [0, 1, 2] {
            viewModel.submitAnswer(at: answerIndex)
            viewModel.nextQuestion()
        }

        XCTAssertTrue(viewModel.isCompleted)
        XCTAssertFalse(store.isInProgress(for: lessonID))

        let newAttempt = try store.startOrResume(
            lessonID: lessonID,
            lesson: lesson
        )

        XCTAssertEqual(newAttempt.questionNumber, 1)
        XCTAssertEqual(newAttempt.score, 0)
        XCTAssertEqual(newAttempt.correctAnswers, 0)
        XCTAssertNil(newAttempt.hintText)
        XCTAssertFalse(newAttempt.isCompleted)
        XCTAssertTrue(store.isInProgress(for: lessonID))
    }

    @MainActor
    func testStoredViewModelChangesNotifyObservers() throws {
        let store = makeStore()

        let viewModel = try store.startOrResume(
            lessonID: UUID(),
            lesson: Lesson.beginner()
        )

        var notifications = 0

        let subscription = store.objectWillChange.sink { _ in
            notifications += 1
        }

        defer {
            subscription.cancel()
        }

        viewModel.submitAnswer(at: 0)

        XCTAssertGreaterThan(notifications, 0)
    }

    @MainActor
    private func makeStore() -> LessonProgressStore {
        return LessonProgressStore(
            makeViewModel: { lesson in
                let session = try LessonSession(
                    lesson: lesson,
                    checker: AnswerChecker(),
                    points: { isCorrect in
                        return isCorrect ? 1 : 0
                    }
                )

                return LessonViewModel(session: session)
            }
        )
    }
}
