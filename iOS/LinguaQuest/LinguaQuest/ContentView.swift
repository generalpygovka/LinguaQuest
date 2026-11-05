import SwiftUI

@MainActor
struct ContentView: View {
    @StateObject private var viewModel: LessonViewModel

    init(viewModel: LessonViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("LinguaQuest")
                    .font(.largeTitle)
                    .bold()

                Text(viewModel.lessonTitle)
                    .font(.title2)

                Text("Бали: \(viewModel.score)")
                    .font(.headline)

                if viewModel.isCompleted {
                    resultsView
                } else if let question = viewModel.currentQuestion {
                    questionView(for: question)
                } else {
                    Text("Не вдалося отримати запитання.")
                }
            }
            .padding()
        }
    }

    private func questionView(for question: Question) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(
                "Запитання \(viewModel.questionNumber) " +
                "із \(viewModel.questionCount)"
            )
            .foregroundStyle(.secondary)

            Text("Як перекладається слово?")
                .font(.headline)

            Text(question.word)
                .font(.largeTitle)
                .bold()

            ForEach(question.options.indices, id: \.self) { index in
                Button {
                    viewModel.submitAnswer(at: index)
                } label: {
                    Text(question.options[index])
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 6)
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.questionFinished)
            }

            Button("Підказка") {
                viewModel.showHint()
            }
            .buttonStyle(.bordered)
            .disabled(viewModel.questionFinished)

            if let hintText = viewModel.hintText {
                Text(hintText)
            }

            if !viewModel.message.isEmpty {
                Text(viewModel.message)
                    .font(.headline)
            }

            if viewModel.questionFinished {
                Button(viewModel.nextButtonTitle) {
                    viewModel.nextQuestion()
                }
                .buttonStyle(.borderedProminent)
            }
        }
    }

    private var resultsView: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Урок завершено!")
                .font(.title)
                .bold()

            Text(
                "Правильно виконано запитань: " +
                "\(viewModel.correctAnswers) " +
                "із \(viewModel.questionCount)."
            )

            Text(
                "Бали: \(viewModel.score). " +
                "Максимум: \(viewModel.questionCount)."
            )

            Button("Пройти ще раз") {
                viewModel.restart()
            }
            .buttonStyle(.borderedProminent)
        }
    }
}
