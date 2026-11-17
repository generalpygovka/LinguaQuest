import Foundation

enum AppRoute: Hashable {
    case lesson(UUID)
    case result(LessonResult)
}

enum AppSheet: Identifiable {
    case editLesson(UUID)

    var id: UUID {
        switch self {
        case .editLesson(let lessonID):
            return lessonID
        }
    }
}
