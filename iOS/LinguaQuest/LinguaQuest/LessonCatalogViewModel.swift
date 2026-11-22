import Foundation
import Combine
import LinguaQuestCore

@MainActor
final class LessonCatalogViewModel: ObservableObject {
    @Published private(set) var lessons: [Lesson] = []
    @Published private(set) var errorMessage: String? = nil

    private let repository: any LessonCatalogRepository

    init(repository: any LessonCatalogRepository) {
        self.repository = repository
    }

    func loadLessons() {
        do {
            let loadedLessons = try repository.loadLessons()

            lessons = loadedLessons
            errorMessage = nil
        } catch {
            errorMessage =
                "Не вдалося завантажити уроки. " +
                "Спробуй ще раз."
        }
    }

    func lesson(for id: UUID) -> Lesson? {
        return lessons.first { $0.id == id }
    }

    @discardableResult
    func renameLesson(
        id: UUID,
        title: String
    ) throws -> Lesson {
        do {
            guard let index = lessons.firstIndex(
                where: { $0.id == id }
            ) else {
                throw LessonCatalogError.lessonNotFound(id: id)
            }

            let updatedLesson = try repository.renameLesson(
                id: id,
                title: title
            )

            lessons[index] = updatedLesson
            errorMessage = nil

            return updatedLesson
        } catch {
            errorMessage = renameErrorMessage(for: error)
            throw error
        }
    }

    private func renameErrorMessage(
        for error: Error
    ) -> String {
        if let builderError = error as? LessonBuilderError {
            switch builderError {
            case .emptyTitle:
                return "Введіть назву уроку."

            case .emptyLesson, .invalidQuestion(index: _):
                return "Урок містить некоректні дані."
            }
        }

        if let catalogError = error as? LessonCatalogError {
            switch catalogError {
            case .lessonNotFound(id: _):
                return "Урок не знайдено. Оновіть список."

            case .duplicateLessonID(id: _):
                return "Каталог містить уроки з однаковим ID."
            }
        }

        return "Не вдалося зберегти назву. Спробуй ще раз."
    }
}