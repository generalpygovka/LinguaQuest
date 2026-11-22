import SwiftUI
import LinguaQuestCore

@main
@MainActor
struct LinguaQuestApp: App {
    private let catalog: LessonCatalogViewModel?
    private let progressStore: LessonProgressStore
    private let startupError: String?

    init() {
        let checker: any AnswerChecking = LoggingAnswerChecker(
            wrapping: AnswerChecker(),
            log: { message in
                print("[Перевірка] \(message)")
            }
        )

        self.progressStore = LessonProgressStore(
            makeViewModel: { lesson in
                let session = try LessonSession(
                    lesson: lesson,
                    checker: checker,
                    points: { isCorrect in
                        return isCorrect ? 1 : 0
                    }
                )

                return LessonViewModel(session: session)
            }
        )

        do {
            let repository: any LessonCatalogRepository =
                try InMemoryLessonCatalogRepository()

            let catalog = LessonCatalogViewModel(
                repository: repository
            )

            catalog.loadLessons()

            self.catalog = catalog
            self.startupError = nil
        } catch {
            self.catalog = nil
            self.startupError =
                "Не вдалося підготувати каталог уроків."
        }
    }

    var body: some Scene {
        WindowGroup {
            if let catalog = catalog {
                ContentView(
                    catalog: catalog,
                    progressStore: progressStore
                )
            } else {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Не вдалося відкрити LinguaQuest")
                        .font(.title)
                        .bold()

                    Text(
                        startupError ??
                        "Сталася помилка підготовки застосунку."
                    )
                }
                .padding()
            }
        }
    }
}
