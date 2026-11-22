import Foundation
import Combine
import LinguaQuestCore

@MainActor
final class LessonProgressStore: ObservableObject {
    @Published private var viewModels: [UUID: LessonViewModel] = [:]

    private var subscriptions: [UUID: AnyCancellable] = [:]

    private let makeViewModel:
        @MainActor (Lesson) throws -> LessonViewModel

    init(
        makeViewModel:
            @escaping @MainActor (Lesson) throws -> LessonViewModel
    ) {
        self.makeViewModel = makeViewModel
    }

    @discardableResult
    func startOrResume(
        lessonID: UUID,
        lesson: Lesson
    ) throws -> LessonViewModel {
        if let viewModel = viewModels[lessonID] {
            viewModel.updateLessonTitle(lesson.title)

            if viewModel.isCompleted {
                viewModel.restart()
            }

            return viewModel
        }

        return try createViewModel(
            lessonID: lessonID,
            lesson: lesson
        )
    }

    func viewModel(for lessonID: UUID) -> LessonViewModel? {
        return viewModels[lessonID]
    }

    func isInProgress(for lessonID: UUID) -> Bool {
        guard let viewModel = viewModels[lessonID] else {
            return false
        }

        return !viewModel.isCompleted
    }

    @discardableResult
    func restart(
        lessonID: UUID,
        lesson: Lesson
    ) throws -> LessonViewModel {
        if let viewModel = viewModels[lessonID] {
            viewModel.updateLessonTitle(lesson.title)
            viewModel.restart()
            return viewModel
        }

        return try createViewModel(
            lessonID: lessonID,
            lesson: lesson
        )
    }

    private func createViewModel(
        lessonID: UUID,
        lesson: Lesson
    ) throws -> LessonViewModel {
        let viewModel = try makeViewModel(lesson)

        viewModels[lessonID] = viewModel

        subscriptions[lessonID] =
            viewModel.objectWillChange.sink { [weak self] _ in
                self?.objectWillChange.send()
            }

        return viewModel
    }
}
