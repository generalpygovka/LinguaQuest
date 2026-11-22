import Foundation
import Combine

@MainActor
final class AppRouter: ObservableObject {
    @Published var path: [AppRoute] = []
    @Published var sheet: AppSheet? = nil

    func openLesson(id: UUID) {
        sheet = nil
        path = [.lesson(id)]
    }

    func showResult(_ result: LessonResult) {
        sheet = nil
        path = [.result(result)]
    }

    func openEditor(lessonID: UUID) {
        sheet = .editLesson(lessonID)
    }

    func closeSheet() {
        sheet = nil
    }

    func showCatalog() {
        sheet = nil
        path.removeAll()
    }

    func goBack() {
        guard !path.isEmpty else {
            return
        }

        path.removeLast()
    }
}
