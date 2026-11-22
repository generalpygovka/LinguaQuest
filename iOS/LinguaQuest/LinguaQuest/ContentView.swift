import SwiftUI
import Foundation
import LinguaQuestCore

@MainActor
struct ContentView: View {
    @StateObject private var router = AppRouter()
    @StateObject private var catalog: LessonCatalogViewModel
    @StateObject private var progressStore: LessonProgressStore

    @State private var alertMessage = ""
    @State private var isAlertPresented = false

    init(
        catalog: LessonCatalogViewModel,
        progressStore: LessonProgressStore
    ) {
        _catalog = StateObject(wrappedValue: catalog)
        _progressStore = StateObject(
            wrappedValue: progressStore
        )
    }

    var body: some View {
        NavigationStack(path: $router.path) {
            VStack(spacing: 0) {
                if let errorMessage = catalog.errorMessage {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(errorMessage)
                            .foregroundStyle(.red)

                        Button("Оновити список") {
                            catalog.loadLessons()
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(
                        maxWidth: .infinity,
                        alignment: .leading
                    )
                    .padding()
                }

                LessonListView(
                    items: lessonItems,
                    onOpenLesson: { lessonID in
                        openLesson(id: lessonID)
                    },
                    onEditLesson: { lessonID in
                        router.openEditor(lessonID: lessonID)
                    }
                )
            }
            .navigationDestination(for: AppRoute.self) { route in
                destination(for: route)
            }
        }
        .sheet(item: $router.sheet) { sheet in
            editor(for: sheet)
        }
        .alert(
            "Помилка",
            isPresented: $isAlertPresented
        ) {
            Button("Гаразд", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
    }

    private var lessonItems: [LessonListItem] {
        return catalog.lessons.map { lesson in
            LessonListItem(
                id: lesson.id,
                title: lesson.title,
                questionCount: lesson.questionCount,
                isInProgress: progressStore.isInProgress(
                    for: lesson.id
                )
            )
        }
    }

    @ViewBuilder
    private func destination(
        for route: AppRoute
    ) -> some View {
        switch route {
        case .lesson(let lessonID):
            if let viewModel = progressStore.viewModel(
                for: lessonID
            ) {
                LessonPlayView(
                    viewModel: viewModel,
                    onCompleted: {
                        showResult(
                            lessonID: lessonID,
                            viewModel: viewModel
                        )
                    }
                )
                .navigationTitle("Урок")
                .navigationBarTitleDisplayMode(.inline)
            } else {
                missingLessonView {
                    router.showCatalog()
                }
            }

        case .result(let result):
            LessonResultView(
                lessonTitle: result.lessonTitle,
                correctAnswers: result.correctAnswers,
                questionCount: result.questionCount,
                score: result.score,
                onRestart: {
                    openLesson(
                        id: result.lessonID,
                        restart: true
                    )
                },
                onReturnToCatalog: {
                    router.showCatalog()
                }
            )
            .navigationTitle("Результат")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    @ViewBuilder
    private func editor(
        for sheet: AppSheet
    ) -> some View {
        switch sheet {
        case .editLesson(let lessonID):
            if let lesson = catalog.lesson(for: lessonID) {
                EditLessonView(
                    title: lesson.title,
                    onSave: { newTitle in
                        let updatedLesson =
                            try catalog.renameLesson(
                                id: lessonID,
                                title: newTitle
                            )

                        if let viewModel =
                            progressStore.viewModel(
                                for: lessonID
                            )
                        {
                            viewModel.updateLessonTitle(
                                updatedLesson.title
                            )
                        }

                        router.closeSheet()
                    },
                    onCancel: {
                        router.closeSheet()
                    }
                )
            } else {
                missingLessonView {
                    router.closeSheet()
                }
            }
        }
    }

    private func openLesson(
        id: UUID,
        restart: Bool = false
    ) {
        guard let lesson = catalog.lesson(for: id) else {
            reportError(
                "Урок не знайдено. Оновіть список."
            )
            return
        }

        do {
            if restart {
                try progressStore.restart(
                    lessonID: id,
                    lesson: lesson
                )
            } else {
                try progressStore.startOrResume(
                    lessonID: id,
                    lesson: lesson
                )
            }

            router.openLesson(id: id)
        } catch {
            reportError(
                "Не вдалося підготувати урок. " +
                "Перевірте його дані."
            )
        }
    }

    private func showResult(
        lessonID: UUID,
        viewModel: LessonViewModel
    ) {
        guard viewModel.isCompleted else {
            return
        }

        let result = LessonResult(
            lessonID: lessonID,
            lessonTitle: viewModel.lessonTitle,
            correctAnswers: viewModel.correctAnswers,
            questionCount: viewModel.questionCount,
            score: viewModel.score
        )

        router.showResult(result)
    }

    private func missingLessonView(
        onClose: @escaping () -> Void
    ) -> some View {
        VStack(spacing: 16) {
            Text("Урок не знайдено.")

            Button("Закрити") {
                onClose()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private func reportError(_ message: String) {
        alertMessage = message
        isAlertPresented = true
    }
}
