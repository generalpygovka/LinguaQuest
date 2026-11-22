import XCTest
import Foundation
import LinguaQuestCore

final class LessonCatalogTests: XCTestCase {
    func testBuilderPreservesProvidedIdentifier() throws {
        let id = UUID()

        let builder = LessonBuilder(
            id: id,
            title: "Тестовий урок"
        )

        builder.addQuestion(
            Question(
                word: "apple",
                options: ["яблуко", "книга"],
                correctAnswerIndex: 0
            )
        )

        let lesson = try builder.build()

        XCTAssertEqual(lesson.id, id)
    }

    func testDemoCatalogKeepsIdentifiersBetweenLoads() throws {
        let repository: any LessonCatalogRepository =
            try InMemoryLessonCatalogRepository()

        let firstLoad = try repository.loadLessons()
        let secondLoad = try repository.loadLessons()

        XCTAssertEqual(firstLoad.count, 2)

        XCTAssertEqual(
            firstLoad.map { $0.id },
            secondLoad.map { $0.id }
        )

        XCTAssertEqual(
            Set(firstLoad.map { $0.id }).count,
            2
        )

        XCTAssertEqual(
            firstLoad.map { $0.questionCount },
            [3, 3]
        )
    }

    func testRenamingPreservesIdentityQuestionsAndOtherLessons()
        throws
    {
        let firstLesson = Lesson.beginner()

        let secondLesson = Lesson(
            title: "Другий урок",
            questions: firstLesson.questions
        )

        let repository = try InMemoryLessonCatalogRepository(
            lessons: [firstLesson, secondLesson]
        )

        let updatedLesson = try repository.renameLesson(
            id: firstLesson.id,
            title: "  Мої перші слова \n"
        )

        let loadedLessons = try repository.loadLessons()

        XCTAssertEqual(
            updatedLesson.title,
            "Мої перші слова"
        )

        XCTAssertEqual(
            updatedLesson.id,
            firstLesson.id
        )

        XCTAssertEqual(
            loadedLessons.map { $0.id },
            [firstLesson.id, secondLesson.id]
        )

        XCTAssertEqual(
            loadedLessons[0].title,
            "Мої перші слова"
        )

        XCTAssertEqual(
            loadedLessons[1].title,
            secondLesson.title
        )

        XCTAssertEqual(
            updatedLesson.questions.map { $0.word },
            firstLesson.questions.map { $0.word }
        )

        XCTAssertEqual(
            updatedLesson.questions.map { $0.options },
            firstLesson.questions.map { $0.options }
        )

        XCTAssertEqual(
            updatedLesson.questions.map {
                $0.correctAnswerIndex
            },
            firstLesson.questions.map {
                $0.correctAnswerIndex
            }
        )

        XCTAssertEqual(
            updatedLesson.questions.map { $0.hint },
            firstLesson.questions.map { $0.hint }
        )
    }

    func testBlankTitleDoesNotChangeCatalog() throws {
        let repository =
            try InMemoryLessonCatalogRepository()

        let before = try repository.loadLessons()

        XCTAssertThrowsError(
            try repository.renameLesson(
                id: before[0].id,
                title: " \n\t "
            )
        ) { error in
            guard let builderError =
                    error as? LessonBuilderError,
                  case .emptyTitle = builderError
            else {
                XCTFail("Очікувалася помилка emptyTitle.")
                return
            }
        }

        let after = try repository.loadLessons()

        XCTAssertEqual(
            after.map { $0.id },
            before.map { $0.id }
        )

        XCTAssertEqual(
            after.map { $0.title },
            before.map { $0.title }
        )
    }

    func testUnknownIdentifierDoesNotChangeCatalog() throws {
        let repository =
            try InMemoryLessonCatalogRepository()

        let before = try repository.loadLessons()
        let missingID = UUID()

        XCTAssertThrowsError(
            try repository.renameLesson(
                id: missingID,
                title: "Нова назва"
            )
        ) { error in
            XCTAssertEqual(
                error as? LessonCatalogError,
                LessonCatalogError.lessonNotFound(
                    id: missingID
                )
            )
        }

        let after = try repository.loadLessons()

        XCTAssertEqual(
            after.map { $0.id },
            before.map { $0.id }
        )

        XCTAssertEqual(
            after.map { $0.title },
            before.map { $0.title }
        )
    }

    func testCatalogRejectsDuplicateIdentifiers() {
        let firstLesson = Lesson.beginner()

        let duplicate = Lesson(
            id: firstLesson.id,
            title: "Інша назва",
            questions: firstLesson.questions
        )

        XCTAssertThrowsError(
            try InMemoryLessonCatalogRepository(
                lessons: [firstLesson, duplicate]
            )
        ) { error in
            XCTAssertEqual(
                error as? LessonCatalogError,
                LessonCatalogError.duplicateLessonID(
                    id: firstLesson.id
                )
            )
        }
    }

    func testCatalogRejectsInvalidLesson() {
        let invalidLesson = Lesson(
            title: "Некоректний урок",
            questions: [
                Question(
                    word: "apple",
                    options: ["яблуко"],
                    correctAnswerIndex: 10
                )
            ]
        )

        XCTAssertThrowsError(
            try InMemoryLessonCatalogRepository(
                lessons: [invalidLesson]
            )
        ) { error in
            guard let builderError =
                    error as? LessonBuilderError,
                  case .invalidQuestion(let index) =
                    builderError
            else {
                XCTFail(
                    "Очікувалася помилка invalidQuestion."
                )
                return
            }

            XCTAssertEqual(index, 0)
        }
    }
}