import SwiftUI
import LinguaQuestCore

@main
@MainActor
struct LinguaQuestApp: App {
    private let viewModel: LessonViewModel?
    private let startupError: String?

    init() {
        do {
            let repository: any LessonRepository =
                InMemoryLessonRepository()

            let lesson = try repository.loadLesson()

            let checker: any AnswerChecking = LoggingAnswerChecker(
                wrapping: AnswerChecker(),
                log: { message in
                    print("[Перевірка] \(message)")
                }
            )

            let session = try LessonSession(
                lesson: lesson,
                checker: checker,
                points: { isCorrect in
                    return isCorrect ? 1 : 0
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
        if let builderError = error as? LessonBuilderError {
            switch builderError {
            case .emptyTitle:
                return "Урок не має назви."

            case .emptyLesson:
                return "У цьому уроці поки немає запитань."

            case .invalidQuestion(let index):
                return "Запитання \(index + 1) містить некоректні дані."
            }
        }

        if let sessionError = error as? LessonSessionError {
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

        return "Сталася помилка підготовки уроку."
    }
}
