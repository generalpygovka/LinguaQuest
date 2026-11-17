import SwiftUI

@MainActor
struct ContentView: View {
    @StateObject private var viewModel: LessonViewModel

    init(viewModel: LessonViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        Group {
            if viewModel.isCompleted {
                LessonResultView(
                    lessonTitle: viewModel.lessonTitle,
                    correctAnswers: viewModel.correctAnswers,
                    questionCount: viewModel.questionCount,
                    score: viewModel.score,
                    onRestart: {
                        viewModel.restart()
                    }
                )
            } else {
                LessonPlayView(viewModel: viewModel)
            }
        }
    }
}
