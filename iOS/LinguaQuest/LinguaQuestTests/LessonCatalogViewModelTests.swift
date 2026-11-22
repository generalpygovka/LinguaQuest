import XCTest
import Foundation
import Combine
import LinguaQuestCore
@testable import LinguaQuest

final class LessonCatalogViewModelTests: XCTestCase {
    @MainActor
    func testLoadingPublishesLessons() throws {
        let repository =
            try InMemoryLessonCatalogRepository()

        let expectedLessons = try repository.loadLessons()

        let viewModel = LessonCatalogViewModel(
            repository: repository
        )

        var receivedIdentifiers: [[UUID]] = []

        let subscription = viewModel.$lessons.sink { lessons in
            receivedIdentifiers.append(
                lessons.map { $0.id }
            )
        }

        defer {
            subscription.cancel()
        }

        viewModel.loadLessons()

        XCTAssertEqual(viewModel.lessons.count, 2)

        XCTAssertEqual(
            viewModel.lessons.map { $0.id },
            expectedLessons.map { $0.id }
        )

        XCTAssertEqual(
            receivedIdentifiers,
            [
                [],
                expectedLessons.map { $0.id }
            ]
        )

        XCTAssertNil(viewModel.errorMessage)
    }

    @MainActor
    func testRenamingUpdatesSelectedLesson() throws {
        let repository =
            try InMemoryLessonCatalogRepository()

        let viewModel = LessonCatalogViewModel(
            repository: repository
        )

        viewModel.loadLessons()

        let before = viewModel.lessons
        let firstLesson = before[0]

        let updatedLesson = try viewModel.renameLesson(
            id: firstLesson.id,
            title: "Мій оновлений урок"
        )

        XCTAssertEqual(
            updatedLesson.id,
            firstLesson.id
        )

        XCTAssertEqual(
            viewModel.lesson(for: firstLesson.id)?.title,
            "Мій оновлений урок"
        )

        XCTAssertEqual(
            viewModel.lessons.map { $0.id },
            before.map { $0.id }
        )

        XCTAssertEqual(
            viewModel.lessons[1].title,
            before[1].title
        )

        XCTAssertNil(viewModel.errorMessage)
    }

    @MainActor
    func testBlankTitleKeepsPreviousStateAndShowsError() throws {
        let repository =
            try InMemoryLessonCatalogRepository()

        let viewModel = LessonCatalogViewModel(
            repository: repository
        )

        viewModel.loadLessons()

        let before = viewModel.lessons

        XCTAssertThrowsError(
            try viewModel.renameLesson(
                id: before[0].id,
                title: " \n\t "
            )
        )

        XCTAssertEqual(
            viewModel.lessons.map { $0.title },
            before.map { $0.title }
        )

        XCTAssertEqual(
            viewModel.lessons.map { $0.id },
            before.map { $0.id }
        )

        XCTAssertEqual(
            viewModel.errorMessage,
            "Введіть назву уроку."
        )
    }

    @MainActor
    func testUnknownIdentifierShowsError() throws {
        let repository =
            try InMemoryLessonCatalogRepository()

        let viewModel = LessonCatalogViewModel(
            repository: repository
        )

        viewModel.loadLessons()

        let before = viewModel.lessons
        let missingID = UUID()

        XCTAssertThrowsError(
            try viewModel.renameLesson(
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

        XCTAssertNil(
            viewModel.lesson(for: missingID)
        )

        XCTAssertEqual(
            viewModel.lessons.map { $0.title },
            before.map { $0.title }
        )

        XCTAssertEqual(
            viewModel.errorMessage,
            "Урок не знайдено. Оновіть список."
        )
    }

    @MainActor
    func testFailedLoadingPreservesStateAndCanBeRetried() throws {
        let actualRepository =
            try InMemoryLessonCatalogRepository()

        let repository = FailingLessonCatalogRepository(
            wrapping: actualRepository
        )

        let viewModel = LessonCatalogViewModel(
            repository: repository
        )

        viewModel.loadLessons()

        let before = viewModel.lessons

        repository.shouldFailLoading = true

        viewModel.loadLessons()

        XCTAssertEqual(
            viewModel.lessons.map { $0.id },
            before.map { $0.id }
        )

        XCTAssertEqual(
            viewModel.lessons.map { $0.title },
            before.map { $0.title }
        )

        XCTAssertNotNil(viewModel.errorMessage)

        try actualRepository.renameLesson(
            id: before[0].id,
            title: "Назва після оновлення"
        )

        repository.shouldFailLoading = false

        viewModel.loadLessons()

        XCTAssertEqual(
            viewModel.lesson(for: before[0].id)?.title,
            "Назва після оновлення"
        )

        XCTAssertNil(viewModel.errorMessage)
    }

    @MainActor
    func testFailedRenamePreservesStateAndCanBeRetried() throws {
        let repository = FailingLessonCatalogRepository(
            wrapping: try InMemoryLessonCatalogRepository()
        )

        let viewModel = LessonCatalogViewModel(
            repository: repository
        )

        viewModel.loadLessons()

        let before = viewModel.lessons

        repository.shouldFailRenaming = true

        XCTAssertThrowsError(
            try viewModel.renameLesson(
                id: before[0].id,
                title: "Моя нова назва"
            )
        ) { error in
            XCTAssertEqual(
                error as? CatalogViewModelTestError,
                CatalogViewModelTestError.simulatedFailure
            )
        }

        XCTAssertEqual(
            viewModel.lessons.map { $0.title },
            before.map { $0.title }
        )

        XCTAssertEqual(
            viewModel.errorMessage,
            "Не вдалося зберегти назву. Спробуй ще раз."
        )

        repository.shouldFailRenaming = false

        try viewModel.renameLesson(
            id: before[0].id,
            title: "Моя нова назва"
        )

        XCTAssertEqual(
            viewModel.lesson(for: before[0].id)?.title,
            "Моя нова назва"
        )

        XCTAssertNil(viewModel.errorMessage)
    }
}

private enum CatalogViewModelTestError: Error, Equatable {
    case simulatedFailure
}

private final class FailingLessonCatalogRepository:
    LessonCatalogRepository
{
    var shouldFailLoading = false
    var shouldFailRenaming = false

    private let wrapped: any LessonCatalogRepository

    init(wrapping repository: any LessonCatalogRepository) {
        self.wrapped = repository
    }

    func loadLessons() throws -> [Lesson] {
        if shouldFailLoading {
            throw CatalogViewModelTestError.simulatedFailure
        }

        return try wrapped.loadLessons()
    }

    func renameLesson(
        id: UUID,
        title: String
    ) throws -> Lesson {
        if shouldFailRenaming {
            throw CatalogViewModelTestError.simulatedFailure
        }

        return try wrapped.renameLesson(
            id: id,
            title: title
        )
    }
}