import SwiftUI

@main
@MainActor
struct LinguaQuestApp: App {
    private let viewModel: LessonViewModel?
    private let startupError: String?

    init() {
        do {
            let lesson = Lesson.beginner()
            let checker: any AnswerChecking = AnswerChecker()

            let session = try LessonSession(
                lesson: lesson,
                checker: checker,
                points: { isCorrect in
                    return isCorrect ? 1 : -1
                }
            )

            self.viewModel = LessonViewModel(session: session)
            self.startupError = nil
        } catch {
            self.viewModel = nil
            self.startupError = Self.errorMessage(for: error)
        }
    }

    var body: some Scene {
        WindowGroup {
            if let viewModel = viewModel {
                ContentView(viewModel: viewModel)
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Не вдалося відкрити урок")
                        .font(.title)
                        .bold()

                    Text(
                        startupError ??
                        "Сталася помилка підготовки уроку."
                    )
                }
                .padding()
            }
        }
    }

    private static func errorMessage(for error: Error) -> String {
        guard let sessionError = error as? LessonSessionError else {
            return "Сталася помилка підготовки уроку."
        }

        switch sessionError {
        case .emptyLesson:
            return "У цьому уроці поки немає запитань."

        case .invalidQuestion(let index):
            return (
                "Запитання \(index + 1) містить " +
                "некоректні варіанти відповіді."
            )
        }
    }
}
